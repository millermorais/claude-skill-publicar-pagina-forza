#!/bin/bash
# Salva e valida a chave Netlify do mentorado.
# Uso: setup-token.sh <token>
#
# O Claude chama isso passando o token que a pessoa colou no chat.
# Validar ANTES de salvar — token errado não fica gravado no disco.

set -e

TOKEN_FILE="$HOME/.netlify-token"
API="https://api.netlify.com/api/v1"

TOKEN=$(echo "$1" | tr -d '[:space:]')

if [ -z "$TOKEN" ]; then
  echo "ERRO: cole o token como argumento. Ex: setup-token.sh nfp_abc123..." >&2
  exit 1
fi

# Validar via GET /user (endpoint leve)
RESPONSE=$(curl -sS -w "\n%{http_code}" -H "Authorization: Bearer $TOKEN" "$API/user")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

case "$HTTP_CODE" in
  200)
    EMAIL=$(echo "$BODY" | jq -r '.email // empty')
    NAME=$(echo "$BODY" | jq -r '.full_name // empty')
    echo "$TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    echo "OK"
    [ -n "$NAME" ] && echo "Conectado como: $NAME"
    [ -n "$EMAIL" ] && echo "E-mail: $EMAIL"
    echo "Chave salva em $TOKEN_FILE (só seu usuário lê esse arquivo)."
    exit 0
    ;;
  401)
    echo "CHAVE_INVALIDA" >&2
    echo "A chave não foi aceita pela Netlify (401 Unauthorized)." >&2
    echo "Pode ter copiado errado, ou a chave foi revogada. Gera uma nova e tenta de novo." >&2
    exit 2
    ;;
  *)
    echo "ERRO_API: Netlify respondeu HTTP $HTTP_CODE" >&2
    echo "$BODY" >&2
    exit 3
    ;;
esac
