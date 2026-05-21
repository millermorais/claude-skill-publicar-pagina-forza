# Configurar a chave da Netlify (passo a passo)

Você só precisa fazer isso **uma vez**. Depois disso, é só pedir pro Claude publicar e ele já sabe como.

> O melhor caminho é deixar o **Claude te guiar dentro do chat**.
> Mas se você quiser ver tudo escrito antes, é isso aqui:

---

## Passo 1 — Criar conta grátis na Netlify

1. Abre esse link: **https://app.netlify.com/signup**
2. Clica em **Sign up with Google** (é o jeito mais rápido)
3. Escolhe sua conta Google e confirma

> *Tela esperada: formulário de signup da Netlify com botões "Sign up with GitHub", "Sign up with GitLab", "Sign up with Bitbucket", "Sign up with Email", "Sign up with Google".*

**⚠ Importante:** depois de criar a conta, a Netlify vai abrir **várias telas perguntando qual seu projeto, oferecendo IA, sugerindo templates**. Ignora tudo. Pula, fecha, clica em qualquer "skip", "no thanks". Você não precisa criar nenhum projeto pelo painel — o Claude faz isso pra você.

Se ficar travada em alguma tela, fecha tudo e vai direto pro Passo 2.

---

## Passo 2 — Gerar a chave de acesso

1. Abre esse link (já logada): **https://app.netlify.com/user/applications#personal-access-tokens**

   > *Tela esperada: aba "Applications" com seções "OAuth applications" no topo e "Personal access tokens" no meio da página.*

2. Na seção **Personal access tokens**, clica no botão **New access token**

3. Aparece uma janela pedindo:
   - **Description**: coloca `claude-publicar` (ou qualquer nome — só pra você lembrar pra que serve)
   - **Expiration**: deixa **No expiration** ✅ (pra nunca precisar refazer essa etapa)
   - Clica em **Generate token**

4. A próxima tela mostra a **chave grande**, que começa com `nfp_` seguida de muitas letras e números.

   **⚠ MUITO IMPORTANTE:** a Netlify mostra essa chave **uma única vez**. Se você fechar a tela sem copiar, vai precisar gerar outra (não tem problema gerar outra, só dá trabalho).

5. **Copia a chave inteira** (clica no botão "Copy" ao lado dela).

---

## Passo 3 — Colar a chave no chat

Volta pro Claude Code (ou pra conversa em que você estava falando com o Claude) e cola a chave. Pode ser direto:

> `nfp_abc123XYZ456...` *(a chave completa)*

O Claude vai:
1. Validar se a chave funciona (testa com a Netlify)
2. Salvar pra você em um lugar seguro do seu computador
3. Te avisar: "ok, conectei sua conta da Netlify"

**Você não vai precisar dessa chave de novo.** Fica salva. Se trocar de computador, refaz esses 3 passos.

---

## Pronto

Daí em diante, é só pedir:

> *"publica essa página pra mim"*

E o Claude usa a skill automaticamente.

---

## Se algo der errado

### "A chave que colei não foi aceita"

Provavelmente você copiou a chave incompleta. Volta no link do Passo 2, gera uma chave nova, copia ela inteira (use Ctrl+A no campo dela ou o botão "Copy") e cola de novo no Claude.

### "Não consigo achar a conta na Netlify depois que criei"

Tenta entrar de novo aqui: https://app.netlify.com/login — usa o mesmo método que escolheu pra criar (Google, GitHub, etc).

### "A Netlify tá me pedindo cartão de crédito"

Não pede. Se pediu, você clicou em "upgrade" sem querer. Recusa e continua no plano free. O plano free não pede cartão.

### Outros problemas

Conta pro Claude exatamente o que apareceu na tela. Ele sabe interpretar a maioria dos erros.

---

> 💡 **Pra que serve essa chave?**
> A chave dá ao Claude permissão de publicar páginas na sua conta da Netlify. Sem ela, o Claude não consegue subir nada no seu nome. Ela fica só no seu computador (nunca vai pra GitHub nem pra outro lugar).
