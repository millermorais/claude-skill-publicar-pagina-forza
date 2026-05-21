# assets/

Pasta pra screenshots usados em `SETUP.md`.

## Por que ainda não tem nada aqui

A primeira tentativa de capturar via Playwright headless travou em OAuth (Netlify não tem mais signup com e-mail/senha próprios — só federa via Google/GitHub/etc, então captura automatizada precisaria de credencial real). A captura ficou pendente pra ser feita à mão na primeira vez que alguém passar pelo fluxo.

## Como completar (quando passar pelo fluxo)

Salvar nesta pasta, com esses nomes exatos, e referenciar em `SETUP.md`:

| Nome do arquivo | Onde capturar | O que mostrar |
|---|---|---|
| `01-signup.png` | https://app.netlify.com/signup (aba anônima) | Botão "Sign up with Google" visível |
| `02-personal-access-tokens.png` | https://app.netlify.com/user/applications#personal-access-tokens (logada) | Seção "Personal access tokens" com botão "New access token" |
| `03-new-token-form.png` | Modal após clicar "New access token" | Campos "Description" e "Expiration" (com "No expiration" selecionado) |
| `04-token-generated.png` | Tela após gerar | Chave `nfp_...` com botão "Copy" — **mascarar a chave antes de commitar** |

Após adicionar as imagens, editar `SETUP.md` pra incluir `![alt](assets/NOME.png)` nos pontos correspondentes.

## Cuidado óbvio

Nunca commitar um screenshot com chave Netlify real visível. Mascarar com tarja preta ou borrar antes de salvar.
