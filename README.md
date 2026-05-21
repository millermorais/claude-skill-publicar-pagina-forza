# Publicar Página — skill pro Claude Code

Coloca uma página HTML no ar e te dá um link público pra mandar pro cliente, lead, parceiro. Tudo dentro do Claude Code.

Você fala: *"publica essa página pra mim"*.
Em segundos, recebe: `https://nome-da-pagina.netlify.app`.

Pronto, é isso.

## Pra que serve

- Mandar uma **proposta personalizada** como link (em vez de PDF)
- Subir uma **landing rápida** pra um teste de mercado
- Publicar uma **ferramenta web** (calculadora, formulário, quiz)
- Compartilhar uma **carta de vendas** sem precisar de site
- Publicar uma **prévia de página** pra um cliente aprovar antes de virar oficial

## O que você ganha

- URL `https://...` automática (com cadeado seguro)
- Não precisa instalar nada complicado no computador
- Não precisa saber programar
- Custo: zero (plano gratuito da Netlify cobre tudo isso)
- Pode trocar pro seu domínio próprio depois (`suamarca.com.br`)

## Como instalar (faz 1 vez)

Cole esse comando no Claude Code:

```
Quero instalar a skill publicar-pagina. Roda esses comandos:

mkdir -p ~/.claude/skills
cd ~/.claude/skills
git clone https://github.com/millermorais/claude-skill-publicar-pagina-forza publicar-pagina

Depois me confirma que instalou.
```

Pronto. Daí em diante é só pedir pro Claude publicar uma página.

## Como configurar (faz 1 vez, dentro do chat)

Na primeira vez que você pedir pra publicar alguma coisa, o Claude vai te guiar em 3 minutos:

1. Você cria conta grátis na Netlify (entrar com Google é mais rápido)
2. Pega uma chave de acesso (link direto, 2 cliques)
3. Cola a chave no chat — o Claude salva pra você

Depois disso, nunca mais precisa configurar. Só pedir.

## Como usar (no dia a dia)

Você tem um HTML pronto? Fala com o Claude:

> *"Publica essa página pra mim, chama de `proposta-joana`"*

O Claude responde com a URL. Você manda pra cliente.

Se quiser **atualizar** uma página que já publicou:

> *"Atualiza a página de antes com esse novo HTML"*

Se quiser **conectar o seu próprio domínio** (ex: `clinica-x.com.br`):

> *"Quero usar meu domínio nessa página"*

O Claude segue o passo a passo do arquivo `DOMINIO.md` da skill.

## O que dá pra publicar (e o que não dá)

✅ **Dá pra publicar:**
- Página HTML simples
- Pasta com HTML + CSS + imagens + JavaScript
- Site estático completo (várias páginas)
- Ferramentas que rodam só no navegador (calculadora, quiz, formulário)

❌ **Não dá pra publicar:**
- App em Next.js, React, Vue com build (precisa de Vercel ou outro)
- Site WordPress (precisa de servidor com PHP)
- Site com banco de dados (login, painel admin)

Se a sua página é "abre no navegador e funciona", esse é seu caso. Se precisa de servidor pra rodar, não é.

## Quanto pode usar (de graça)

Plano grátis da Netlify cobre:
- **100 GB/mês** de tráfego (ou seja: ~50.000 visitas em uma página comum)
- **Páginas ilimitadas** (pode ter quantas quiser)
- **Atualizações ilimitadas** (pode publicar versão nova quando quiser)
- **HTTPS automático** (o cadeado verde no navegador)

Pra proposta, landing, ferramenta — sobra muito. Se uma página explodir e estourar o limite, a Netlify avisa antes de cobrar.

## Se travar

- **"Não consigo achar onde pegar o token na Netlify"** → veja `SETUP.md`
- **"A chave que colei não funcionou"** → gera outra no mesmo link (Netlify só mostra uma vez quando cria, então copia ela inteira)
- **"O nome que escolhi tá indisponível"** → o nome é compartilhado por todo mundo da Netlify. Tenta com seu sobrenome ou com `-2026`
- **Outros problemas** → pede ajuda pro Claude direto: *"deu erro X, o que faço?"*

## Quem fez

Skill montada por Miller Morais como parte da [Forza Platform](https://forza.gabiarchetti.com) — programa de aceleração de negócios da Gabi Archetti. Distribuída em código aberto pra qualquer pessoa usar.
