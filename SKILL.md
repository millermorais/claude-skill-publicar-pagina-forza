---
name: publicar-pagina
description: Publica páginas HTML no ar (Netlify, grátis) gerando uma URL pública pronta pra compartilhar. Use sempre que a pessoa disser "publica essa página", "sobe essa proposta", "deixa isso no ar", "manda como link pro cliente", "coloca essa landing no ar", ou tiver acabado de gerar um HTML e quiser link. Funciona com arquivo único OU pasta com HTML + CSS + imagens. Inclui onboarding conversacional na primeira vez (configura chave Netlify dentro do chat).
---

# /publicar-pagina

Pega um HTML (ou pasta de site estático) e devolve uma URL pública pronta pra mandar pro cliente, lead, parceiro, quem for. Free tier Netlify — sem cartão, sem custo.

## Quando ativar

- "Publica essa página"
- "Sobe essa proposta como link"
- "Quero mandar essa landing pro cliente"
- "Pega esse HTML e deixa no ar"
- "Cria uma URL pra essa página"
- Pessoa acabou de gerar landing/proposta/carta-de-vendas/qualquer HTML e quer link pra compartilhar

## REGRA CRÍTICA — onboarding conversacional na primeira vez

Essa skill é usada por **mentorados da Forza** (e outros leigos). Não assumir que sabem o que é token, terminal, env var. **Nunca** jogar SETUP.md na cara — guiar passo a passo dentro do próprio chat.

### Fluxo padrão (4 passos)

#### Passo 1 — Checar se já tem chave configurada

Rodar:
```bash
bash ~/.claude/skills/publicar-pagina/scripts/deploy.sh
```
*(sem argumento — o script vai falhar e retornar exit code 2 se faltar token)*

Mais simples: tentar uma chamada de teste:
```bash
[ -f ~/.netlify-token ] && echo "tem" || echo "falta"
```

Se já tem chave → **pular pro Passo 4**.
Se falta → seguir Passo 2.

#### Passo 2 — Onboarding (só na primeira vez)

Dizer pra pessoa exatamente isso (adapte o tom mas mantenha a estrutura):

> Boa! Pra publicar tua página eu vou usar a Netlify — é grátis, sem cartão, e gera uma URL https automática.
>
> Como é a primeira vez, preciso que você faça 2 coisinhas rápidas (leva 3 minutos):
>
> **1.** Cria uma conta grátis aqui: https://app.netlify.com/signup
>    *(pode entrar com Google que é mais rápido)*
>
> **2.** Já logada, abre esse link e clica em **New access token**:
>    https://app.netlify.com/user/applications#personal-access-tokens
>    - Coloca um nome qualquer (ex: `claude-publicar`)
>    - Em expiração, deixa **No expiration** (pra nunca precisar renovar)
>    - Clica em **Generate token**
>    - **Copia o código que aparece** (a Netlify só mostra 1 vez)
>
> Aí me cola o código aqui no chat que eu salvo pra você. Não precisa fazer mais nada.

Aguardar resposta.

#### Passo 3 — Salvar a chave

Quando a pessoa colar o token (formato típico: `nfp_` seguido de letras/números), rodar:

```bash
bash ~/.claude/skills/publicar-pagina/scripts/setup-token.sh "TOKEN_QUE_ELA_COLOU"
```

- Saída começa com `OK` → chave válida, salva. Confirmar pra pessoa: "Pronto, conectei. Agora bora publicar tua página."
- Saída começa com `CHAVE_INVALIDA` → "A chave não foi aceita. Confere se copiou ela inteira ou gera outra no mesmo link e me manda de novo."
- Saída começa com `ERRO_API` → erro de rede ou Netlify fora. Pedir pra tentar de novo em 1 min.

Ao salvar, **nunca repetir o token em texto pro usuário** (segurança).

#### Passo 4 — Publicar

Antes de subir, perguntar 2 coisas (ou só 1 se for óbvio):

1. **"Qual nome quer pra essa página?"** — explica que vai virar `nome-escolhido.netlify.app`. Sugerir baseado no contexto (ex: se é proposta pra Joana, sugerir `proposta-joana`; se é landing do produto X, sugerir `landing-x`).

   Regras pro nome:
   - Só letras minúsculas, números e hífen
   - Sem espaço, sem acento, sem caractere especial
   - Se a pessoa disser "tanto faz" ou pular, deixar a Netlify gerar nome aleatório (não passar `--name`)

2. **Confirmar o arquivo/pasta** — se óbvio do contexto, só executar. Se múltiplos HTMLs no projeto, perguntar qual.

Rodar:

```bash
bash ~/.claude/skills/publicar-pagina/scripts/deploy.sh /caminho/arquivo.html --name nome-escolhido
```

Ou pra pasta:
```bash
bash ~/.claude/skills/publicar-pagina/scripts/deploy.sh /caminho/pasta/ --name nome-escolhido
```

Se a saída tiver `NOME_INDISPONIVEL`, sugerir variações (`-2026`, `-clinica`, etc) e tentar de novo até passar.

Devolver pra pessoa:
- URL pública (em destaque)
- Nome da página (pra ela lembrar)
- Dica do HTTPS (link da própria mensagem do script)

## Atualizar uma página já publicada

Quando a pessoa pedir "atualiza aquela página de antes", "muda essa página", "publica de novo no mesmo link":

```bash
bash ~/.claude/skills/publicar-pagina/scripts/deploy.sh /caminho/arquivo.html --update
```

`--update` usa o último site publicado nessa máquina (cache em `~/.netlify-last-site`).

Se a pessoa quiser atualizar uma página específica que não é a última:
```bash
bash ~/.claude/skills/publicar-pagina/scripts/deploy.sh /caminho/arquivo.html --site nome-da-pagina
```

## Conectar domínio próprio

Se a pessoa pedir "quero usar meu domínio", "quero `clinica-x.com.br` em vez de netlify.app", ler `DOMINIO.md` na pasta da skill e seguir o fluxo de lá. Não tentar improvisar — DNS tem ciladas específicas.

## Limitações (avisar se a pessoa pedir algo fora do escopo)

- Só HTML estático (HTML + CSS + JS + imagens). Se a pessoa pedir pra publicar Next.js, React build, app com backend → explicar que essa skill não cobre e que ela precisa de Vercel/outra solução.
- Free tier Netlify: 100GB/mês de banda. Pra proposta, landing, ferramenta sobra muito. Se a página viralizar e estourar, Netlify avisa.

## Erros comuns

- **`PRECISA_CONFIGURAR_TOKEN`** → primeira vez. Disparar fluxo do Passo 2.
- **`CHAVE_INVALIDA`** no setup → token errado. Pedir pra gerar outro.
- **`NOME_INDISPONIVEL`** → nome já em uso (Netlify é global, todo mundo compete). Sugerir variação.
- **"nenhum .html encontrado"** → pasta sem HTML. Confirmar o que ela quer publicar.

## O que NÃO fazer

- ❌ Pedir pra pessoa abrir terminal e digitar comando
- ❌ Falar em "env var", "PAT", "chmod", "API key" — usar "chave de acesso", "código", "configurar"
- ❌ Mostrar o token de volta pra pessoa depois que ela colou
- ❌ Inventar URL antes do deploy terminar — sempre esperar o `OK Publicado` do script
- ❌ Tentar publicar Next.js/React build com essa skill (vai falhar)
