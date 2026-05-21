---
name: publicar-pagina
description: Publica páginas HTML no ar (Netlify, grátis) gerando uma URL pública pronta pra compartilhar. Use sempre que a pessoa disser "publica essa página", "sobe essa proposta", "deixa isso no ar", "manda como link pro cliente", "coloca essa landing no ar", ou tiver acabado de gerar um HTML e quiser link. Funciona com arquivo único OU pasta com HTML + CSS + imagens. Usa o connector oficial Netlify do Cowork (OAuth) — sem token cru, sem expiração, persiste entre sessões.
---

# /publicar-pagina (v1.0.0 — connector Netlify)

Publica uma página HTML ou pasta de site estático na Netlify usando o connector oficial via MCP, devolvendo a URL pública pronta pra enviar.

## Quando ativar

- "Publica essa página"
- "Sobe essa proposta como link"
- "Quero mandar essa landing pro cliente"
- "Pega esse HTML e deixa no ar"
- "Cria uma URL pra essa página"
- "Atualiza aquela página que eu publiquei"
- "Lista minhas páginas publicadas"

## REGRA CRÍTICA — fluxo conversacional

Essa skill é usada por **mentorados da Forza** (e outros leigos). Não assumir que sabem o que é OAuth, MCP, sandbox, npx. **Nunca** jogar comando técnico na cara. Guiar passo a passo dentro do próprio chat.

## Pré-checks antes de tentar publicar

### 1. Verificar que está no Cowork (sandbox Linux com npm/node)

A skill executa o CLI `npx @netlify/mcp` pra fazer upload dos arquivos. Isso só roda no **Cowork** (aba com sandbox Linux), não no Chat simples.

Como checar: tente rodar `which node && which npm` via Bash. Se falhar (sem sandbox), diga:

> "Essa skill precisa rodar no **Cowork** (a aba com sandbox no topo do Claude Desktop, entre as abas Chat e Code). Você tá na aba Chat agora. Clica na aba **Cowork** lá em cima, abre uma conversa nova e pede de novo pra publicar."

### 2. Verificar que o connector Netlify está conectado

Tente chamar a tool do connector (algo como `mcp__netlify-deploy-services__get-user`). Se retornar erro de autenticação ou a tool não existir, dispare o onboarding:

> "Você ainda não conectou sua conta Netlify ao Claude. É rápido — 1 vez só, depois fica salvo pra sempre.
>
> 1. No Claude Desktop, vai em **Settings** (configurações, canto do seu nome/foto)
> 2. Procura por **Connectors** (ou "Conectores")
> 3. Encontra **Netlify** na lista e clica em **Connect** ou **Login**
> 4. Vai abrir o site da Netlify pra você fazer login (se ainda não tiver conta, cria grátis lá mesmo)
> 5. Autoriza o acesso
> 6. Volta aqui e me chama de novo — pode falar 'publica essa página'."

## Fluxo padrão de publicação (página nova com nome custom)

Quando passar dos pré-checks e o usuário pedir publicação:

### Passo 1 — Decidir nome da página

Se o usuário não disse nome, pergunte:

> "Que nome você quer pra essa página? Vai virar `nome-escolhido.netlify.app`. Sugiro algo descritivo tipo `proposta-joana`, `landing-curso`, `clinica-bia`."

Regras pro nome:
- Só letras minúsculas, números e hífen
- Sem espaço, sem acento, sem caractere especial
- Slugificar input do usuário se necessário

### Passo 2 — Confirmar arquivo/pasta a publicar

Se o contexto deixar óbvio qual HTML/pasta publicar, use direto. Senão pergunte.

### Passo 3 — Verificar se o site já existe na conta

Use a tool `get-projects` do connector. Se já existir um projeto com o nome escolhido:

> "Já tem uma página chamada `nome-escolhido` na sua conta Netlify. Você quer atualizar essa mesma página (mesmo link) ou criar uma nova com nome diferente?"

### Passo 4 — Criar projeto (se for nova)

Chame `create-new-project` com o nome escolhido. Guarde o `siteId` retornado.

Se retornar erro "name must be unique" (nome já em uso globalmente na Netlify, mesmo que não seja sua conta):

> "O nome `nome-escolhido` já tá em uso por outra pessoa na Netlify. Sugiro `nome-escolhido-2026`, `nome-escolhido-clinica`, ou outro variante. Qual prefere?"

### Passo 5 — Preparar diretório de upload

O `npx @netlify/mcp` faz upload do **diretório atual**. Você precisa garantir que o conteúdo está num diretório limpo:

```bash
TMPDIR=$(mktemp -d -t pub-XXXXXX)
# Se for arquivo único HTML:
cp /caminho/arquivo.html "$TMPDIR/index.html"
# Se for pasta:
cp -R /caminho/pasta/. "$TMPDIR/"
# Se a pasta não tiver index.html, promova o primeiro .html pra index.html
[ ! -f "$TMPDIR/index.html" ] && cp "$(find "$TMPDIR" -name '*.html' | head -1)" "$TMPDIR/index.html"
```

### Passo 6 — Pedir token de deploy + executar upload

Chame `deploy-site` passando o `siteId`. Vai retornar um comando do tipo:

```
npx -y @netlify/mcp@latest --site-id <id> --proxy-path "<JWT>"
```

Execute esse comando **dentro do TMPDIR** (`cd $TMPDIR && <comando>`). Esse JWT é **uso único** — peça novo a cada deploy.

### Passo 7 — Retry com backoff em caso de falha transitória

O connector teve falhas intermitentes "server isn't responding" em alguns dos testes. Implementar **até 3 tentativas** com backoff: 2s, 5s, 10s.

```bash
for try in 1 2 3; do
  if (cd "$TMPDIR" && npx -y @netlify/mcp@latest --site-id "$SITE_ID" --proxy-path "$JWT" 2>&1); then
    break
  fi
  [ $try -lt 3 ] && sleep $((try * 3))
  # Pra retry, peça novo JWT via deploy-site (token é uso único)
done
```

### Passo 8 — Validar deploy ficou ready

Chame `get-deploy` com o `deployId` retornado, aguarde estado `ready` (até 60s, com retry). Se ficar `error`, reporte o erro.

### Passo 9 — Limpeza

Após sucesso (ou falha), remova o diretório temporário e qualquer lixo de deploy (`.netlify/`, `deploy-*.zip`) que o CLI tenha deixado:

```bash
rm -rf "$TMPDIR"
```

### Passo 10 — Devolver URL pro usuário

Formate a resposta:

> ✅ **Publicado!**
>
> URL pública: https://nome-escolhido.netlify.app
> Painel Netlify: https://app.netlify.com/projects/nome-escolhido
>
> Dica: HTTPS pode levar uns segundos pra ficar ativo numa página recém-criada. Se aparecer aviso de certificado, espera 30s e recarrega.

## Atualizar página existente

Quando o usuário pedir "atualiza aquela página", "publica de novo no mesmo link", etc:

1. Liste projetos via `get-projects`
2. Se for óbvio qual (ex: só tem 1 ou o usuário citou o nome), use direto
3. Senão pergunte: "Qual delas você quer atualizar?" + lista numerada
4. Quando confirmar, faça Passos 5-10 acima (sem criar projeto — usa o `siteId` existente)

## Listar páginas publicadas

Quando o usuário pedir "lista minhas páginas", "quais páginas eu tenho publicadas":

1. Chame `get-projects` do connector
2. Formate a resposta como lista:

> Suas páginas publicadas:
>
> 1. **proposta-joana** — https://proposta-joana.netlify.app
> 2. **landing-curso** — https://landing-curso.netlify.app
> 3. **clinica-bia** — https://clinica-bia.netlify.app
>
> Quer atualizar alguma? Ou criar uma nova?

## Apagar página — LIMITE CONHECIDO

O connector Netlify **não tem ferramenta de delete**. Se o usuário pedir pra apagar uma página:

> "Eu não consigo apagar páginas direto daqui — esse caminho não tá disponível pelo connector do Claude. Mas dá pra apagar em 30 segundos pelo painel da Netlify:
>
> 1. Abre: https://app.netlify.com/projects/NOME-DA-PAGINA
> 2. Clica em **Site configuration** (ou Configurações)
> 3. Rola até o fim, clica em **Delete this site**
> 4. Confirma escrevendo o nome
>
> Depois disso o nome fica livre pra você reusar."

## Domínio próprio — FORA DO ESCOPO DESSA VERSÃO

Conectar domínio próprio (`clinica-bia.com.br`) também não está disponível via connector. Se o usuário pedir:

> "Conectar domínio próprio ainda não tá disponível por aqui — vou precisar adicionar isso numa próxima versão da skill. Por enquanto, a página fica em `nome-escolhido.netlify.app` mesmo. Se quiser usar o domínio próprio agora, dá pra configurar manualmente pelo painel da Netlify, mas o caminho é mais técnico — me chama que te oriento."

## Limites + dicas

- Só HTML estático (HTML + CSS + JS + imagens). Next.js/React build não funciona aqui.
- Free tier Netlify: 100GB/mês de banda. Pra proposta, landing, ferramenta, sobra muito.
- Pasta com subpastas: preservadas no deploy (`/style.css`, `/img/logo.png`, etc).
- Cada deploy gera URL nova de preview, mas a URL principal `nome.netlify.app` aponta sempre pro último deploy ready.

## O que NÃO fazer

- ❌ Pedir pra pessoa criar Personal Access Token ou colar `nfp_...` no chat (era o caminho da v0.x — descontinuado)
- ❌ Tentar usar a skill na aba Chat simples (sem sandbox Linux) — sempre redirecionar pra Cowork
- ❌ Mostrar comando técnico (`npx`, `mcp`) pro usuário leigo — só executar
- ❌ Inventar URL antes de o deploy ficar `ready`
- ❌ Deixar lixo no diretório (sempre limpar `.netlify/` e `deploy-*.zip`)
- ❌ Tentar publicar Next.js/React build (vai falhar)
