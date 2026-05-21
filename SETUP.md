# Configurar Netlify no Claude Desktop (passo a passo)

Você só precisa fazer isso **uma vez**. Depois disso, é só pedir pro Claude publicar.

A v1.0.0 da skill usa o **connector oficial Netlify** do Claude Desktop. Você não precisa lidar com tokens, chaves nem cola de credencial — é OAuth normal, igual login com Google.

---

## Passo 1 — Criar conta grátis na Netlify

1. Abre esse link: **https://app.netlify.com/signup**
2. Clica em **Sign up with Google** (é o jeito mais rápido)
3. Escolhe sua conta Google e confirma

> *Tela esperada: formulário de signup da Netlify com botões "Sign up with GitHub", "Sign up with GitLab", "Sign up with Bitbucket", "Sign up with Email", "Sign up with Google".*

**⚠ Importante:** depois de criar a conta, a Netlify vai te empurrar uma sequência chata de telas pedindo pra criar projeto, perguntando seu plano, oferecendo IA, pedindo pra preencher dados. **Ignora tudo.** Clica em "Skip" / "No thanks" / fecha o que der. Você não precisa criar nenhum projeto pelo painel — a skill cuida disso.

Quando livrar dessas telas (ou deixar a aba aberta), vai pro Passo 2.

---

## Passo 2 — Conectar Netlify no Claude Desktop

1. Abre o **Claude Desktop**
2. Vai em **Settings** (configurações da sua conta)
3. Procura por **Connectors** (ou "Conectores")
4. Encontra **Netlify** na lista
5. Clica em **Connect** ou **Login**
6. Vai abrir uma janela do navegador no site da Netlify pedindo pra você autorizar o acesso
7. Confirma com a mesma conta que você criou no Passo 1
8. Pronto — a conexão fica salva pra sempre

---

## Pronto

Daí em diante, sempre que você quiser publicar uma página:

1. Abre o Claude Desktop, vai pra aba **Cowork** (entre Chat e Code no topo)
2. Pede: *"publica essa página pra mim, chama de proposta-bia"*

Ele faz tudo. Não precisa colar token, não precisa configurar nada de novo.

---

## Se algo der errado

### "Não tenho o Netlify na lista de Connectors"

A lista de connectors disponíveis depende da sua versão do Claude Desktop. Atualize pra última versão (geralmente tem um botão "Atualizar" no canto inferior do app).

### "Cliquei em Connect mas o navegador não abriu"

Tente de novo. Se persistir, copia o link que aparece e cola no navegador manualmente.

### "Autorizei mas a skill ainda diz que não tô conectado"

Fecha e abre o Claude Desktop. Tenta usar a skill de novo.

### "Eu tinha uma versão antiga (v0.x) que pedia pra colar um token nfp_..."

Essa versão foi descontinuada na v1.0.0. Você pode revogar o token antigo (já que não vai mais usar):
1. Abre https://app.netlify.com/user/applications#personal-access-tokens
2. Encontra o token chamado `claude-publicar` (ou nome que você deu)
3. Clica em **Options → Revoke**

Conta gratuita atende tranquilamente — não precisa do token mais.

### Outros problemas

Conta pro Claude exatamente o que apareceu na tela. Ele sabe interpretar a maioria dos erros.
