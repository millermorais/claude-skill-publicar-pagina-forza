#!/bin/bash
# Publica HTML/pasta no Netlify via API HTTP (sem CLI).
# Versão Forza — pensada pra mentorado leigo via Claude Code.
#
# Uso:
#   deploy.sh <arquivo.html|pasta>                          # cria site com nome aleatório
#   deploy.sh <arquivo.html|pasta> --name minha-pagina      # cria site com nome escolhido
#   deploy.sh <arquivo.html|pasta> --update                 # atualiza último site publicado nesta máquina
#   deploy.sh <arquivo.html|pasta> --site nome-existente    # atualiza site específico

set -e

TOKEN_FILE="$HOME/.netlify-token"
LAST_SITE_FILE="$HOME/.netlify-last-site"
API="https://api.netlify.com/api/v1"

# --- Token ---
TOKEN=""
if [ -n "$NETLIFY_AUTH_TOKEN" ]; then
  TOKEN=$(echo "$NETLIFY_AUTH_TOKEN" | tr -d '[:space:]')
elif [ -f "$TOKEN_FILE" ]; then
  TOKEN=$(cat "$TOKEN_FILE" | tr -d '[:space:]')
fi

if [ -z "$TOKEN" ]; then
  echo "PRECISA_CONFIGURAR_TOKEN" >&2
  echo "" >&2
  echo "Antes de publicar, precisa cadastrar a chave Netlify uma vez." >&2
  echo "Rode o setup chamando o Claude e dizendo: 'configura a chave da Netlify'" >&2
  exit 2
fi

# --- Args ---
SOURCE="$1"
SITE_NAME_ARG=""
NEW_NAME=""
USE_LAST=0

shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --site)
      SITE_NAME_ARG="$2"
      shift 2
      ;;
    --name)
      NEW_NAME=$(echo "$2" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
      shift 2
      ;;
    --update)
      USE_LAST=1
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ -z "$SOURCE" ]; then
  echo "Uso: deploy.sh <arquivo.html|pasta> [--name nome | --update | --site nome]" >&2
  exit 1
fi

if [ ! -e "$SOURCE" ]; then
  echo "ERRO: '$SOURCE' não existe." >&2
  exit 1
fi

# --update usa o último site salvo
if [ "$USE_LAST" = "1" ]; then
  if [ -f "$LAST_SITE_FILE" ]; then
    SITE_NAME_ARG=$(cat "$LAST_SITE_FILE" | tr -d '[:space:]')
  else
    echo "ERRO: nenhuma página publicada antes nessa máquina. Use sem --update pra criar a primeira." >&2
    exit 1
  fi
fi

# --- Payload ---
WORKDIR=$(mktemp -d -t netlify-deploy)
PAYLOAD_DIR="$WORKDIR/payload"
mkdir -p "$PAYLOAD_DIR"

cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

if [ -f "$SOURCE" ]; then
  case "$SOURCE" in
    *.html|*.htm)
      cp "$SOURCE" "$PAYLOAD_DIR/index.html"
      ;;
    *)
      echo "ERRO: arquivo único precisa ser .html ou .htm. Recebi: $SOURCE" >&2
      exit 1
      ;;
  esac
elif [ -d "$SOURCE" ]; then
  cp -R "$SOURCE"/. "$PAYLOAD_DIR/"
  if [ ! -f "$PAYLOAD_DIR/index.html" ]; then
    FIRST_HTML=$(find "$PAYLOAD_DIR" -maxdepth 2 -type f -name '*.html' | head -1)
    if [ -n "$FIRST_HTML" ]; then
      cp "$FIRST_HTML" "$PAYLOAD_DIR/index.html"
    else
      echo "ERRO: nenhum .html encontrado na pasta." >&2
      exit 1
    fi
  fi
fi

# --- Resolve site existente, se for atualização ---
SITE_ID=""
if [ -n "$SITE_NAME_ARG" ]; then
  SITE_INFO=$(curl -sS -H "Authorization: Bearer $TOKEN" "$API/sites?name=$SITE_NAME_ARG")
  SITE_ID=$(echo "$SITE_INFO" | jq -r ".[] | select(.name==\"$SITE_NAME_ARG\") | .id" | head -1)
  if [ -z "$SITE_ID" ]; then
    echo "ERRO: página '$SITE_NAME_ARG' não encontrada na sua conta Netlify." >&2
    exit 1
  fi
fi

# --- File digests ---
FILES_JSON=$(cd "$PAYLOAD_DIR" && find . -type f | while read -r f; do
  REL="${f#./}"
  SHA=$(shasum -a 1 "$f" | awk '{print $1}')
  printf '%s\t%s\n' "/$REL" "$SHA"
done | jq -Rs 'split("\n") | map(select(length > 0) | split("\t") | {key: .[0], value: .[1]}) | from_entries')

if [ -z "$FILES_JSON" ] || [ "$FILES_JSON" = "{}" ]; then
  echo "ERRO: nenhum arquivo pra publicar em $PAYLOAD_DIR" >&2
  exit 1
fi

# Body: se for criação com nome custom, incluir name no body do site
if [ -z "$SITE_ID" ] && [ -n "$NEW_NAME" ]; then
  REQUEST_BODY=$(jq -n --arg name "$NEW_NAME" --argjson files "$FILES_JSON" '{name: $name, files: $files}')
else
  REQUEST_BODY=$(jq -n --argjson files "$FILES_JSON" '{files: $files}')
fi

# --- Endpoint: site novo ou existente ---
if [ -n "$SITE_ID" ]; then
  ENDPOINT="$API/sites/$SITE_ID/deploys"
else
  ENDPOINT="$API/sites"
fi

DEPLOY_RESPONSE=$(curl -sS -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "$REQUEST_BODY" \
  "$ENDPOINT")

DEPLOY_ID=$(echo "$DEPLOY_RESPONSE" | jq -r '.deploy_id // .id // empty')
[ -z "$SITE_ID" ] && SITE_ID=$(echo "$DEPLOY_RESPONSE" | jq -r '.site_id // .id // empty')
REQUIRED=$(echo "$DEPLOY_RESPONSE" | jq -r '.required // [] | .[]')
ERR=$(echo "$DEPLOY_RESPONSE" | jq -r '.message // .error // empty')

if [ -z "$DEPLOY_ID" ]; then
  # Erro comum: nome já em uso (Netlify retorna 422)
  if echo "$ERR" | grep -qi "must be unique"; then
    echo "NOME_INDISPONIVEL: o nome '$NEW_NAME' já está em uso por outra pessoa na Netlify." >&2
    echo "Tente outro nome (ex: $NEW_NAME-2026, $NEW_NAME-clinica, etc.)" >&2
    exit 3
  fi
  echo "ERRO ao criar página:" >&2
  [ -n "$ERR" ] && echo "$ERR" >&2
  echo "$DEPLOY_RESPONSE" | jq . >&2 2>/dev/null || echo "$DEPLOY_RESPONSE" >&2
  exit 1
fi

# --- Upload dos arquivos requeridos ---
if [ -n "$REQUIRED" ]; then
  for SHA in $REQUIRED; do
    FILE=$(cd "$PAYLOAD_DIR" && find . -type f | while read -r f; do
      THIS_SHA=$(shasum -a 1 "$f" | awk '{print $1}')
      if [ "$THIS_SHA" = "$SHA" ]; then
        echo "${f#./}"
        break
      fi
    done | head -1)

    if [ -z "$FILE" ]; then
      echo "ERRO: não achei arquivo com sha $SHA" >&2
      exit 1
    fi

    UPLOAD_RESP=$(curl -sS -X PUT \
      -H "Content-Type: application/octet-stream" \
      -H "Authorization: Bearer $TOKEN" \
      --data-binary "@$PAYLOAD_DIR/$FILE" \
      "$API/deploys/$DEPLOY_ID/files/$FILE")

    UPLOAD_ERR=$(echo "$UPLOAD_RESP" | jq -r '.message // empty' 2>/dev/null)
    if [ -n "$UPLOAD_ERR" ]; then
      echo "ERRO no upload de $FILE: $UPLOAD_ERR" >&2
      exit 1
    fi
  done
fi

# --- Aguarda ready (até 30s) ---
for i in $(seq 1 15); do
  DEPLOY_STATE=$(curl -sS -H "Authorization: Bearer $TOKEN" "$API/deploys/$DEPLOY_ID" | jq -r '.state // empty')
  if [ "$DEPLOY_STATE" = "ready" ]; then
    break
  fi
  if [ "$DEPLOY_STATE" = "error" ]; then
    echo "ERRO: publicação falhou no Netlify." >&2
    exit 1
  fi
  sleep 2
done

# --- Info final ---
SITE_INFO=$(curl -sS -H "Authorization: Bearer $TOKEN" "$API/sites/$SITE_ID")

NAME=$(echo "$SITE_INFO" | jq -r '.name // empty')
SSL_URL=$(echo "$SITE_INFO" | jq -r '.ssl_url // empty')
PLAIN_URL=$(echo "$SITE_INFO" | jq -r '.url // empty')
ADMIN=$(echo "$SITE_INFO" | jq -r '.admin_url // empty')

if [ -n "$SSL_URL" ]; then
  URL="$SSL_URL"
elif [ -n "$NAME" ]; then
  URL="https://${NAME}.netlify.app"
else
  URL="$PLAIN_URL"
fi

if [ -z "$URL" ]; then
  echo "ERRO: publicação foi feita mas não consegui pegar a URL final." >&2
  echo "Site ID: $SITE_ID" >&2
  exit 1
fi

# --- Salva último site pra próxima vez ---
if [ -n "$NAME" ]; then
  echo "$NAME" > "$LAST_SITE_FILE"
fi

echo ""
echo "OK Publicado."
echo ""
echo "URL pública:   $URL"
[ -n "$NAME" ] && echo "Nome da página: $NAME"
[ -n "$ADMIN" ] && echo "Painel:        $ADMIN"
echo ""
echo "Dica: HTTPS pode levar alguns segundos pra ficar pronto em páginas recém-criadas."
echo "Se aparecer aviso de certificado na primeira vez, espera 30s e recarrega."
echo ""
