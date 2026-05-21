---
name: publicar-pagina
description: Publica páginas HTML no ar (Netlify, grátis) gerando uma URL pública pronta pra compartilhar. Use sempre que a pessoa disser "publica essa página", "sobe essa proposta", "deixa isso no ar", "manda como link pro cliente", "coloca essa landing no ar", ou tiver acabado de gerar um HTML e quiser link. Funciona com arquivo único OU pasta com HTML + CSS + imagens. Usa o connector oficial Netlify do Cowork (OAuth) — sem token cru, sem expiração, persiste entre sessões.
---

# /publicar-pagina (v1.0.1 — connector Netlify)

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

## REGRA CRÍTICA — tools MCP do connector Netlify

Os nomes exatos das ferramentas do connector **variam por instalação** (prefixo MCP é UUID único e o connector usa wrappers com `selectSchema`). NÃO assumir nomes hardcoded.

Em vez disso: **busque pelas tools disponíveis** com a palavra `netlify`. O padrão real do connector é:

- Wrappers `*-reader` pra leitura (ex: `netlify-project-services-reader`, `netlify-user-services-reader`, `netlify-deploy-services-reader`)
- Wrappers `*-updater` pra escrita (ex: `netlify-project-services-updater`, `netlify-deploy-services-updater`)
- Cada wrapper recebe um campo `selectSchema.operation` que escolhe a operação real (ex: `operation: "create-new-project"`, `operation: "get-projects"`, `operation: "deploy-site"`, `operation: "get-deploy"`, `operation: "get-user"`)

Se as tools `netlify-*` não aparecerem listadas, faça uma busca por `netlify` pra carregá-las (em alguns ambientes elas vêm como `deferred` até serem requisitadas).

## Pré-checks antes de tentar publicar

### 1. Verificar que está no Cowork (sandbox Linux com npm/node)

A skill executa o CLI `npx @netlify/mcp` pra fazer upload dos arquivos. Isso só roda no **Cowork** (aba com sandbox Linux), não no Chat simples.

Como checar: tente rodar `which node && which npm` via Bash. Se falhar (sem sandbox), diga:

> "Essa skill precisa rodar no **Cowork** (a aba com sandbox no topo do Claude Desktop, entre as abas Chat e Code). Você tá na aba Chat agora. Clica na aba **Cowork** lá em cima, abre uma conversa nova e pede de novo pra publicar."

### 2. Verificar que o connector Netlify está conectado

Tente chamar a operação `get-user` via um dos wrappers `netlify-user-services-reader`. Se a tool não existir ou retornar erro de autenticação, dispare o onboarding:

> "Você ainda não conectou sua conta Netlify ao Claude. É rápido — 1 vez só, depois fica salvo pra sempre.
>
> 1. Na sidebar esquerda do Claude Desktop, clica em **Personalizar** (em inglês: Customize)
> 2. Clica em **Conectores** (em inglês: Connectors)
> 3. No canto superior direito do painel, clica no sinal **+**
> 4. Clica em **Navegar Conectores**
> 5. Pesquisa por **Netlify**
> 6. Clica em **Vincular** (em inglês: Link)
> 7. Vai abrir uma página no navegador — autoriza com sua conta Netlify
> 8. Volta aqui e me chama de novo."

### 3. Verificar se a pessoa tem o HTML pronto

Se o usuário pediu "publica essa página" mas **não tem nenhum HTML criado** (não anexou, não acabou de gerar, não citou arquivo existente), pergunte primeiro:

> "Você já tem o HTML pronto ou quer que eu crie pra você antes de publicar? Se quer que eu crie, me conta o que você precisa (ex: 'página simples sobre mim com nome, bio e Instagram')."

Crie o HTML primeiro, mostre pra confirmação, e SÓ DEPOIS publica.

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

Use a operação `get-projects` (via wrapper `netlify-project-services-reader` ou equivalente). Se já existir um projeto com o nome escolhido:

> "Já tem uma página chamada `nome-escolhido` na sua conta Netlify. Você quer atualizar essa mesma página (mesmo link) ou criar uma nova com nome diferente?"

### Passo 4 — Criar projeto (se for nova)

Use a operação `create-new-project` (via wrapper `netlify-project-services-updater` ou equivalente) com o nome escolhido. Guarde o `siteId` retornado.

Se retornar erro "name must be unique" (nome já em uso globalmente na Netlify, mesmo que não seja sua conta):

> "O nome `nome-escolhido` já tá em uso por outra pessoa na Netlify. Sugiro `nome-escolhido-2026`, `nome-escolhido-clinica`, ou outro variante. Qual prefere?"

### Passo 5 — Preparar diretório de upload em /tmp

O `npx @netlify/mcp` faz upload do **diretório atual**. Crie um diretório temporário **dentro de `/tmp`** (NÃO use o cwd ou a pasta `outputs/` — o Cowork protege essas contra deleção e o cleanup do passo 9 vai falhar).

```bash
TMPDIR=$(mktemp -d -t pub-XXXXXX)  # cria em /tmp por default
# Se for arquivo único HTML:
cp /caminho/arquivo.html "$TMPDIR/index.html"
# Se for pasta:
cp -R /caminho/pasta/. "$TMPDIR/"
# Se a pasta não tiver index.html, promova o primeiro .html pra index.html
[ ! -f "$TMPDIR/index.html" ] && cp "$(find "$TMPDIR" -name '*.html' | head -1)" "$TMPDIR/index.html"
```

### Passo 6 — Loop de deploy com retry orquestrado pelo agente

O JWT retornado por `deploy-site` é **uso único**. Cada tentativa de deploy precisa de um JWT novo. Por isso, o retry **NÃO pode ser um loop bash com `$JWT` reusado** — o agente (você) é quem orquestra as tentativas.

**Tente até 3 vezes**, com backoff de 2s, 5s e 10s entre tentativas. A cada tentativa:

1. **Pedir JWT novo:** chame a operação `deploy-site` passando o `siteId`. Vai retornar um comando do tipo:

   ```
   npx -y @netlify/mcp@latest --site-id <id> --proxy-path "<JWT>"
   ```

2. **Executar upload:** rode esse comando **dentro do TMPDIR** via Bash:

   ```bash
   cd "$TMPDIR" && npx -y @netlify/mcp@latest --site-id "$SITE_ID" --proxy-path "$JWT"
   ```

3. **Avaliar resultado:**
   - Se sair com sucesso (exit 0) e produzir um `deployId`: vá pro Passo 7
   - Se sair com erro de rede ("server isn't responding", timeout, ECONNRESET): durma o backoff da rodada (2s na 1ª retentativa, 5s na 2ª) e volte pra etapa 1 desse loop (pedir JWT novo)
   - Se sair com erro de autenticação ou erro funcional não-transitório: reporte e pare

Se as 3 tentativas falharem, reporte o último erro pro usuário e ofereça tentar de novo em alguns minutos.

### Passo 7 — Validar deploy ficou ready

Use a operação `get-deploy` com o `deployId`, aguarde estado `ready` (até 60s, com polling a cada 2s). Se ficar `error`, reporte o erro.

### Passo 8 — Devolver URL pro usuário

Formate a resposta:

> ✅ **Publicado!**
>
> URL pública: https://nome-escolhido.netlify.app
> Painel Netlify: https://app.netlify.com/projects/nome-escolhido
>
> Dica: HTTPS pode levar uns segundos pra ficar ativo numa página recém-criada. Se aparecer aviso de certificado, espera 30s e recarrega.

### Passo 9 — Limpeza (com fallback se permissão negada)

Após sucesso (ou falha), tente remover o TMPDIR + qualquer lixo (`.netlify/`, `deploy-*.zip`) que o CLI tenha deixado:

```bash
rm -rf "$TMPDIR" 2>/dev/null
```

Se a remoção falhar com "Operation not permitted" (acontece se o TMPDIR caiu em pasta protegida do Cowork tipo `outputs/`), use a tool de gestão de arquivos do Cowork pra pedir permissão de deleção daquele path antes de desistir. Não bloqueie o resultado da publicação por causa de cleanup falho — devolva a URL pro usuário e só logue o aviso de cleanup.

## Atualizar página existente

Quando o usuário pedir "atualiza aquela página", "publica de novo no mesmo link", etc:

1. Liste projetos via operação `get-projects`
2. Se for óbvio qual (ex: só tem 1 ou o usuário citou o nome), use direto
3. Senão pergunte: "Qual delas você quer atualizar?" + lista numerada
4. Quando confirmar, faça Passos 5-9 acima (sem criar projeto — usa o `siteId` existente)

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

- ❌ Hardcodar nomes de tools MCP do connector (eles variam por instalação; descobrir via list)
- ❌ Fazer retry em bash loop reusando o JWT (token é uso único — peça novo a cada tentativa)
- ❌ Pedir pra pessoa criar Personal Access Token ou colar `nfp_...` no chat (era o caminho da v0.x — descontinuado)
- ❌ Tentar usar a skill na aba Chat simples (sem sandbox Linux) — sempre redirecionar pra Cowork
- ❌ Mostrar comando técnico (`npx`, `mcp`) pro usuário leigo — só executar
- ❌ Inventar URL antes de o deploy ficar `ready`
- ❌ Criar TMPDIR dentro de pasta protegida do Cowork (use `/tmp/`)
- ❌ Bloquear o resultado da publicação por causa de cleanup falho (devolva URL primeiro, cleanup é best-effort)
- ❌ Tentar publicar Next.js/React build (vai falhar)
