# Conectar meu próprio domínio à página

> ⚠️ **Status na v1.0.0:** suporte a domínio próprio **NÃO está incluso** nessa versão da skill. O connector oficial Netlify do Claude Desktop não expõe ferramentas pra configurar domínio customizado — apenas deploy e gestão de site básico.
>
> **Workaround atual:** se você precisa de domínio próprio agora, configure manualmente pelo painel da Netlify (`https://app.netlify.com/projects/SEU-SITE → Domain management → Add custom domain`). O passo a passo abaixo serve como referência do processo manual.
>
> **Planejado pra v1.1:** caminho complementar usando Personal Access Token só pra configurar domínio (mantendo o connector como caminho principal). Estimativa sem data.

---

Por padrão, uma página publicada com essa skill vira algo tipo `proposta-joana.netlify.app`. Funciona, mas talvez você queira usar o seu próprio domínio: `clinica-joana.com.br`, `proposta.suamarca.com`, etc.

Esse documento descreve o processo (manual por enquanto). Tem 2 partes:

1. Avisar a Netlify que você quer usar o seu domínio (no painel web por enquanto)
2. Configurar o seu domínio pra apontar pra Netlify (você faz no painel de quem te vendeu o domínio)

---

## O que você precisa antes de começar

- [ ] Uma página já publicada com essa skill
- [ ] Um domínio comprado em alguma empresa (Registro.br, GoDaddy, Hostgator, Hostinger, etc.)
- [ ] Acesso ao painel de DNS dessa empresa (login + senha)

---

## Passo 1 — Decidir como vai usar o domínio

**Opção A — Domínio raiz (`clinica-joana.com.br`)**
A página vai abrir direto no domínio principal. Use isso se a página é o site principal da marca/cliente.

**Opção B — Subdomínio (`proposta.clinica-joana.com.br`)**
A página vai abrir num "ramo" do domínio. Use isso se você já tem outro site no domínio principal e quer só uma página separada (ex: uma proposta, uma landing específica).

> **Recomendação prática:** se você está mandando proposta pra cliente, **use subdomínio**. Assim você não precisa mexer no site principal dele.

---

## Passo 2 — Falar com o Claude pra conectar

Diz pra ele:

> *"Quero conectar o domínio `[seu-dominio.com.br]` na página `[nome-da-pagina]`"*

O Claude vai:
1. Conectar o domínio à página na Netlify
2. Te mostrar **2 ou 3 endereços** que você precisa cadastrar no painel do seu domínio
3. Te dar instruções específicas pro tipo de domínio que você escolheu (raiz ou subdomínio)

---

## Passo 3 — Cadastrar no painel do seu domínio

Aqui depende de onde você comprou o domínio. As empresas mais comuns:

### Registro.br (.com.br, .br)

1. Entra em https://registro.br e faz login
2. Vai em **"Painel"** → escolhe o seu domínio
3. No menu lateral, clica em **"DNS"** → **"Configurar Editor de Zona"**
4. Adiciona os registros que o Claude te passou

### GoDaddy

1. Entra em https://godaddy.com e faz login
2. No menu, vai em **"My Products"** → encontra o domínio → **"DNS"**
3. Adiciona os registros que o Claude te passou

### Hostgator / Hostinger

1. Entra no painel de hospedagem
2. Encontra **"Zone Editor"** ou **"Editor de DNS"**
3. Adiciona os registros que o Claude te passou

> Se não encontrar o painel de DNS, busca no Google: *"como configurar DNS no [nome da empresa]"*. Toda empresa tem tutorial.

---

## Passo 4 — Esperar

Depois de cadastrar, **o DNS demora pra propagar**. Pode levar de 5 minutos a 24 horas.

Pra checar se já tá funcionando:
1. Espera 10 minutos
2. Abre o seu domínio no navegador (modo anônimo, pra evitar cache)
3. Se aparecer sua página, deu certo

Se depois de 24h ainda não funcionar, fala com o Claude:

> *"Já configurei o DNS faz mais de 1 dia mas o domínio não abre. Me ajuda a verificar?"*

---

## Sobre o cadeado seguro (HTTPS)

A Netlify faz isso automaticamente. Depois que o DNS propagar, ela detecta seu domínio e ativa o certificado de segurança em 5-15 minutos. Você não precisa fazer nada extra — o cadeado aparece sozinho.

---

## Sobre o custo

Conectar um domínio próprio na Netlify é **grátis**. Você só paga pelo domínio em si (na empresa onde comprou — geralmente R$40-100/ano).

---

## Se algo der errado

### "Configurei o DNS mas não abre"

3 causas mais comuns:
1. **Cache do navegador** → testa em aba anônima
2. **DNS ainda propagando** → espera mais (até 24h)
3. **Cadastrei o registro errado** → o Claude pode revisar contigo, manda print do painel pra ele

### "Aparece aviso de certificado de segurança"

Espera mais 15 minutos. A Netlify ainda tá ativando o cadeado. Se depois de 1h ainda aparecer, conta pro Claude.

### "Comprei o domínio mas não sei onde mexer no DNS"

Conta pro Claude onde você comprou (Registro.br, GoDaddy, etc) — ele te guia.

---

## Para o Claude — comandos internos

> Esta seção é técnica, só pra quando o Claude precisar de referência. Ignora se você é usuária.

**Conectar domínio raiz à página:**
```bash
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"custom_domain":"DOMINIO.com.br"}' \
  "https://api.netlify.com/api/v1/sites/SITE_ID"
```

**Adicionar subdomínio (domain alias):**
```bash
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"domain_aliases":["sub.DOMINIO.com.br"]}' \
  "https://api.netlify.com/api/v1/sites/SITE_ID"
```

**Registros DNS que a pessoa precisa criar:**

- **Domínio raiz** (`exemplo.com.br`):
  - Tipo `A`, nome `@` (ou em branco), valor `75.2.60.5`
  - Tipo `AAAA`, nome `@`, valor `2600:1f18:3fff:c001::5` *(opcional, IPv6)*

- **Subdomínio** (`sub.exemplo.com.br`):
  - Tipo `CNAME`, nome `sub`, valor `NOME-DA-PAGINA.netlify.app`

**Forçar provisão SSL após DNS propagar:**
```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  "https://api.netlify.com/api/v1/sites/SITE_ID/ssl"
```

**Conferir status do SSL:**
```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.netlify.com/api/v1/sites/SITE_ID/ssl"
```

> **Atenção pra IP**: o IP `75.2.60.5` é o IP oficial atual do load balancer Netlify (documentado em https://docs.netlify.com/domains-https/custom-domains/configure-external-dns/). Se a Netlify mudar isso, atualizar aqui.
