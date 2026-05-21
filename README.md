# Publicar Página — skill pro Claude Desktop

Coloca uma página HTML no ar e te dá um link público pra mandar pro cliente, lead, parceiro. Tudo dentro do Claude.

Você fala: *"publica essa página pra mim"*.
Em segundos, recebe: `https://nome-da-pagina.netlify.app`.

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
- Não precisa lidar com token/chave — conexão é OAuth via Claude Desktop, fica salva pra sempre

## Como instalar (faz 1 vez)

1. Baixa o ZIP da skill: [publicar-pagina.zip](https://github.com/millermorais/claude-skill-publicar-pagina-forza/releases/latest/download/publicar-pagina.zip)
2. No Claude Desktop, vai em **Customize → Habilidades → + → Criar habilidade → Fazer upload de uma habilidade**
3. Arrasta o ZIP

## Como configurar (faz 1 vez, dentro do Claude Desktop)

Você precisa conectar sua conta Netlify ao Claude — sem token, é OAuth normal:

1. Cria conta grátis na Netlify (entrar com Google é mais rápido): https://app.netlify.com/signup
2. No Claude Desktop, vai em **Settings → Connectors → Netlify → Login**
3. Faz login e autoriza
4. Pronto, conexão fica salva pra sempre

## Como usar (no dia a dia, sempre na aba Cowork)

A skill executa comandos no sandbox Linux do Claude, então sempre use **na aba Cowork** (no topo do Claude Desktop, entre Chat e Code).

Você tem um HTML pronto? Fala com o Claude:

> *"Publica essa página pra mim, chama de `proposta-joana`"*

O Claude responde com a URL. Você manda pra cliente.

Se quiser **atualizar** uma página que já publicou:

> *"Atualiza a página `proposta-joana` com esse novo HTML"*

Se quiser **listar** as páginas publicadas:

> *"Quais páginas eu tenho publicadas?"*

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

## Limites conhecidos (v1.0.0)

- **Apagar página:** precisa apagar manualmente pelo painel da Netlify (`https://app.netlify.com/projects/NOME → Site configuration → Delete`). O Claude te orienta quando você pedir pra apagar.
- **Domínio próprio (`clinica.com.br`):** ainda não disponível nessa versão. Suporte planejado pra v1.1.

## Quanto pode usar (de graça)

Plano grátis da Netlify cobre:
- **100 GB/mês** de tráfego (ou seja: ~50.000 visitas em uma página comum)
- **Páginas ilimitadas** (pode ter quantas quiser)
- **Atualizações ilimitadas** (pode publicar versão nova quando quiser)
- **HTTPS automático** (o cadeado verde no navegador)

## Se travar

- **"A skill diz pra ir pro Cowork"** → você tá na aba Chat. Clica em **Cowork** no topo do Claude Desktop e tenta de novo.
- **"Você ainda não conectou sua conta Netlify"** → segue o setup acima (Settings → Connectors → Netlify → Login).
- **"Erro no deploy" / "server isn't responding"** → o connector às vezes tem falhas transitórias. A skill tenta de novo automaticamente, mas se persistir, espera 1-2 min e pede de novo.
- **Outros problemas** → conta pro Claude exatamente o erro — ele sabe interpretar.

## Quem fez

Skill montada por Miller Morais como parte da [Forza Platform](https://forza.gabiarchetti.com) — programa de aceleração de negócios da Gabi Archetti. Distribuída em código aberto pra qualquer pessoa usar.
