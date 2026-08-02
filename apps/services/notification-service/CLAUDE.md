# Notification Service

> Contexto específico do microserviço de notificações (feed de notificações, e-mails transacionais, 2FA) do Vibester.
> Este documento complementa o `CLAUDE.md` da raiz do monorepo. Em caso de conflito, o `CLAUDE.md` raiz prevalece nas diretrizes gerais de produto/arquitetura; este arquivo prevalece em convenções específicas deste serviço. Código-fonte é sempre a fonte de verdade final.
>
> **Atenção**: este serviço foi reescrito de Go para Node.js/TypeScript/Prisma (SCRUM-184) e, até a correção de testes (SCRUM-215), não tinha nenhum teste nem CI funcional — o pipeline antigo ainda referenciava `go.mod`/`go test`. Diferente do `event-service`, este serviço **tem Kafka** (consumidor único, múltiplos handlers) e **não tem** `AppError` nem validação de env via Zod. Não copie padrões de outro serviço para cá sem verificar contra o código deste diretório.

---

## Responsabilidade do Serviço

O `notification-service` é responsável exclusivamente por:

- persistir e servir o feed de notificações do usuário (`Notification`: tipo, destinatário, ator, referência, conteúdo, lida/não-lida), com agrupamento (ex.: vários likes no mesmo post viram um único item de feed) e paginação por cursor;
- consumir eventos Kafka de outros serviços (`user.followed`, `post.liked`, `post.commented`, `user.deleted`, `user.registered`, `auth.email.verification`) e transformá-los em notificações e/ou e-mails;
- enviar e-mails transacionais (boas-vindas, recuperação de senha, código 2FA, genérico) via SMTP (nodemailer), com fila em memória e retry;
- gerar, persistir e validar códigos de autenticação em duas etapas (`TwoFactorCode`).

Este serviço não conhece regras de negócio de posts, eventos, estabelecimentos ou pagamento — ele só reage a eventos e serve o feed/e-mails. Se uma feature nova exigir dados de outro domínio (ex. detalhes de um post), busque-os via os clients HTTP existentes (`PostClient`, `UserClient`), nunca duplicando a lógica de negócio do serviço dono.

---

## Stack e Dependências deste Serviço

- Fastify 5 + `@fastify/cors`, `@fastify/jwt`, `@fastify/swagger` (+ `swagger-ui`)
- **`@fastify/type-provider-zod`** — rotas usam `app.withTypeProvider<ZodTypeProvider>()` com schemas Zod declarados no topo de cada controller (`notification.controller.ts`, `email.controller.ts`), mesmo padrão do `event-service`/`user-service`.
- Prisma 7 com `@prisma/adapter-pg` (driver adapter sobre `pg.Pool`, `max: 5`).
- PostgreSQL.
- Redis (`ioredis`) — hoje usado **apenas** em `GET /health` (`redis.ping()`); nenhuma rota usa `cacheAside` neste serviço (diferente do `event-service`/`establishment-service`). O cliente é criado com `lazyConnect: true` + `enableOfflineQueue: false` — ver a nota de bug conhecido na seção Performance antes de reutilizar essa configuração em outro lugar.
- **Kafka (`kafkajs`)** — único consumidor (`src/kafka/consumer.ts`, grupo `notification-service-group`) assinando 6 tópicos, despachando por `switch/case` para um handler dedicado em `src/kafka/handlers/`. Este serviço não produz eventos Kafka, apenas consome.
- **nodemailer + handlebars** — `email.service.ts` calcula `transporter`/`hasSmtpAuth` **no import do módulo** a partir de `env.smtpEmail`/`env.smtpPassword`; sem credenciais, cai em "modo dev" (só loga, não envia). `templateRenderer.service.ts` renderiza os `.html` em `templates/` via Handlebars (escapa HTML por padrão — cuidado ao testar valores com `&`/`=` em querystrings).
- `email.worker.ts` é uma fila em memória (array `emailQueue`) com até 5 workers concorrentes (`MAX_CONCURRENT_WORKERS`) — **não é durável**: um restart do processo perde e-mails enfileirados e não enviados ainda.
- **Sem Kafka producer, sem `AppError`, sem validação de env via Zod**: `src/config/env.ts` usa o mesmo helper `required(key)` manual do `event-service` (lança `Error` na subida se ausente) com fallbacks para o resto.
- Vitest para testes (unit co-localizado em `__tests__` ao lado de cada módulo + integration via `app.inject`), `ioredis-mock` para mockar Redis.

Não introduza um ORM alternativo, `AppError`, produção de eventos Kafka por este serviço, ou `@fastify/rate-limit` sem necessidade real e alinhamento explícito — reutilize o que já existe.

---

## Estrutura de Pastas

```
src/
  clients/        post.client.ts (PostClient.getPost), user.client.ts (UserClient.getProfile)
                  → fetch com AbortController + timeout (env.httpClientTimeoutMs), retornam null em erro/timeout/!ok
    __tests__/    → testes unitários (mock de global.fetch)
  config/         env.ts (required() + fallbacks, SEM Zod), redis.ts (client ioredis + cacheAside, não usado hoje), swagger.ts
  controllers/    notification.controller.ts (feed, unread-count, mark-as-read + rotas "legacy" por :userId)
                  email.controller.ts (envio de e-mail genérico/reset/welcome/2FA + validação de 2FA)
  kafka/
    consumer.ts   → assina os 6 tópicos e despacha para os handlers
    handlers/      follow, postLiked, postCommented, registration, verification, userDeleted
      __tests__/   → um teste por handler (payload → chamada correta ou ignora + captura erro sem lançar)
  prisma/         index.ts → singleton do PrismaClient com adapter pg.Pool (max 5)
  services/       insertNotification, listNotifications (paginação por cursor + agrupamento), markAllRead,
                   notificationGrouping (função pura), unreadCount, templateRenderer, twoFactor, email
    __tests__/    → testes unitários co-localizados (Vitest)
  types/          notification.types.ts, email.types.ts, fastify-jwt.d.ts (payload { userId })
  workers/        email.worker.ts (fila em memória + concorrência limitada)
    __tests__/
  routes.ts       → GET /health (checa db + redis), registra notificationRoutes e emailRoutes com prefix /notifications
  server.ts       → bootstrap Fastify, CORS, JWT, swagger, Kafka consumer, porta 3006
prisma/
  schema.prisma   → models Notification e TwoFactorCode
  migrations/     → gerado em 02/08/2026 (SCRUM-215); antes disso não existia nenhuma migration real
tests/
  helpers/        fastify.test.helper.ts → buildServer + generateToken(app, userId) — payload JWT é { userId }, NÃO { sub }
  setup/          vitest.setup.ts → mocka src/config/env com valores fixos de teste
  integration/     notification.integration.spec.ts, email.integration.spec.ts → mockam Prisma/Redis/clients inline
  integration-real/ notification.real.spec.ts → roda contra Postgres + Redis reais (fora do `npm test` padrão)
```

### Padrão de uma feature nova

1. Se precisar de input/output novo, adicionar em `types/notification.types.ts` ou `types/email.types.ts`.
2. `services/<feature>.service.ts` — funções soltas (não uma classe única, diferente do `event-service`) ou uma classe quando fizer sentido reaproveitar estado (ex.: `ListNotificationsService` guarda instâncias de `UserClient`/`PostClient`). Erros esperados propagam como exceção comum (`try/catch` genérico no controller) — não introduza `AppError`.
3. Em `controllers/*.controller.ts`: schema Zod do `body`/`params`/`querystring`/`response` no topo do arquivo, rota via `router.get/post/patch(...)` com `app.withTypeProvider<ZodTypeProvider>()`, handler com `try/catch` que loga (`request.log.error`) e retorna `500 { message: "..." }` genérico em caso de erro não mapeado.
4. Se a rota for mutação sensível (ex. marcar como lida, listar feed), adicionar `preHandler: [authenticate]` (função local no topo do controller) — mas veja a seção Segurança: as 3 rotas "legacy" por `:userId` **não têm** essa proteção, não copie esse padrão para rotas novas.
5. Se a feature reagir a um evento de outro serviço, adicionar um handler novo em `kafka/handlers/`, registrar o tópico em `TOPICS` e o `case` no `switch` de `consumer.ts` — sempre com `try/catch` envolvendo todo o handler (um evento malformado não pode derrubar o consumidor).
6. Testes: unitário do service/handler/client em `__tests__` co-localizado, e teste de integração da rota em `tests/integration/*.spec.ts` quando a feature expuser um endpoint HTTP.

---

## Segurança — obrigatório em qualquer alteração

1. **As 3 rotas "legacy" em `notification.controller.ts` não têm `preHandler: [authenticate]`**: `GET /:userId`, `GET /:userId/unread-count`, `PATCH /:userId/read`. Qualquer chamador com acesso de rede ao serviço pode ler o feed, contar não-lidas ou marcar como lidas as notificações de **qualquer** usuário, bastando saber o `userId`. Os testes de integração (`tests/integration/notification.integration.spec.ts`) documentam esse comportamento explicitamente para que uma correção futura não regrida silenciosamente sem que alguém perceba nos testes. Ao tocar nessas rotas, não assuma que existe alguma verificação de identidade por trás — se forem expostas a clientes finais (e não só a um gateway/BFF confiável), essa checagem precisa ser adicionada.
2. **`authenticate` só verifica que o JWT é válido, nunca se `userId` do token corresponde ao recurso acessado** — mesmo nas rotas autenticadas (`GET /`, `GET /unread-count`, `PATCH /read`), o `userId` vem do próprio payload do token (`request.user.userId`), então esse ponto específico já é seguro (o usuário só pode operar sobre o próprio feed nessas 3 rotas "modernas"). O risco descrito no item 1 é exclusivo das rotas legacy.
3. **Payload dos eventos Kafka não é validado por schema** (`JSON.parse(value)` com cast direto para uma interface TS, sem Zod) — campos ausentes são tratados com checagens manuais (`if (!x) return`), mas um payload malicioso/malformado com tipos inesperados (ex. `postId` sendo um objeto) não é bloqueado antes de chegar em `insertNotification`. Isso é aceitável hoje porque os tópicos só são publicados por serviços internos confiáveis, mas não assuma essa confiança se um tópico novo vier a ser exposto a um produtor menos confiável.
4. **Validação de entrada via Zod é obrigatória** em toda rota HTTP nova, seguindo os schemas já existentes (`.email()`, `.uuid()` quando aplicável).
5. **Erros internos nunca vazam para o cliente**: exceção não mapeada vira `request.log.error(error)` + `500 { message: "..." }` genérico — nunca stack trace ou detalhe interno na resposta.
6. **Segredos**: `JWT_SECRET` tem fallback hardcoded (`"default-jwt-secret"`) em `env.ts` caso a env não esteja setada — diferente do `event-service`/`auth-service`, que lançam erro na ausência. Garanta que `JWT_SECRET` esteja sempre definido explicitamente em cada ambiente de deploy; não confie no fallback fora de desenvolvimento local. `SMTP_EMAIL`/`SMTP_PASSWORD` vazios são tratados como "modo dev" (não lança erro, só desativa envio real).
7. Antes de fechar qualquer tarefa que mexa nas rotas de notificação ou no fluxo de 2FA, considere sugerir `/security-review` ao usuário, dado o gap de autorização descrito no item 1.

---

## Performance — obrigatório em qualquer alteração

1. **Bug conhecido, baixa severidade, não corrigido neste card**: o cliente Redis (`src/config/redis.ts`) usa `lazyConnect: true` + `enableOfflineQueue: false`. O primeiro comando emitido antes da conexão TCP terminar de subir lança `"Stream isn't writeable and enableOfflineQueue options is false"` em vez de aguardar ou enfileirar. Na prática isso afeta só o campo informativo `redis` no corpo de `GET /health` na primeiríssima chamada após o processo subir (a chamada seguinte já funciona, pois a conexão sobe em background) — **não** derruba o status HTTP do health check, que depende só do Postgres (`const healthy = dbStatus === "ok"`). Se for mexer em `redis.ts`, considere resolver isso de vez (ex.: `await redis.connect()` explícito no bootstrap do `server.ts`, ou remover `enableOfflineQueue: false`) em vez de reproduzir esse padrão em outro lugar.
2. **Sem cache-aside**: nenhuma rota usa `cacheAside` hoje, mesmo o helper existindo em `config/redis.ts` — se uma leitura nova se tornar quente (ex. `GET /unread-count` sob alto tráfego), considere aplicar o mesmo padrão já usado no `event-service`/`establishment-service` em vez de inventar um novo.
3. **`ListNotificationsService.buildFeed` já cacheia lookups de rede dentro de uma mesma requisição** (`actorCache`/`postCache`, `Map<string, Promise<...>>`) para não duplicar chamadas a `UserClient`/`PostClient` quando vários grupos referenciam o mesmo ator/post — reutilize esse padrão ao adicionar novos enriquecimentos.
4. **Paginação por cursor com `rawFetchLimit = 200`**: `buildFeed` busca até 200 linhas brutas do Postgres antes de agrupar e paginar por `limit` — para volumes muito altos de notificações por usuário, considere se 200 continua suficiente para garantir uma página cheia após o agrupamento (um usuário com muitos grupos pequenos pode esgotar as 200 linhas brutas antes de preencher `limit` itens agrupados).
5. **`countUnreadGroups` limita a 500 linhas não lidas** antes de agrupar — um usuário com mais de 500 notificações não lidas terá uma contagem truncada (nunca maior que o número de grupos possíveis dentre essas 500 linhas). Aceitável para o caso de uso (badge de contagem), mas não assuma que é um valor exato para volumes muito altos.
6. **Fila de e-mail em memória, não durável** (`email.worker.ts`): um restart do processo descarta e-mails enfileirados que ainda não foram processados. Se a confiabilidade de envio precisar aumentar (ex. e-mails transacionais críticos), isso precisa evoluir para uma fila persistente (Kafka próprio tópico, Redis, ou fila dedicada) — não existe hoje.
7. **Pool de conexões do Postgres compartilhado e pequeno** (`max: 5` em `src/prisma/index.ts`) — não abra pools adicionais; reavalie junto com o limite de conexões do Postgres se o tráfego crescer.

---

## Testes

- `npm test` (`vitest run`) — roda testes unitários (`src/**/*.test.ts`, co-localizados em `__tests__` ao lado de cada módulo em `services/`, `clients/`, `kafka/handlers/`, `workers/`) e de integração mockada (`tests/integration/*.spec.ts`).
- `npm run test:coverage` — cobertura de `src/services`, `src/controllers`, `src/routes.ts`, `src/kafka/handlers`, `src/clients` com thresholds mínimos: **70% linhas, 70% funções, 60% branches** — não reduza esses thresholds para fazer um PR passar; escreva o teste que falta.
- `npm run test:integration` — roda `tests/integration-real/*.spec.ts` contra Postgres + Redis **reais** (precisa das variáveis `DATABASE_URL`/`REDIS_URL`/`JWT_SECRET` apontando para instâncias de verdade, com as migrations aplicadas via `prisma migrate deploy`). Ver comandos de setup local no `README`/PR de SCRUM-215 ou replicar o job `integration-test` do workflow.
- `tests/helpers/fastify.test.helper.ts`: `generateToken(app, userId)` assina `{ userId }` — **não** `{ sub }` como no `event-service`. Confira `src/types/fastify-jwt.d.ts` antes de assumir o formato do payload em qualquer serviço novo que você for comparar com este.
- `tests/setup/vitest.setup.ts` mocka `src/config/env` com valores fixos, incluindo `templatesDir: ""` (faz `templateRenderer` cair no fallback `process.cwd()/templates`, resolvendo para os templates reais do repo) e `smtpEmail`/`smtpPassword` vazios (mantém `email.service` em "modo dev" por padrão nos testes). **Toda env nova lida em `env.ts` precisa ser adicionada aqui também**, senão os testes que dependem dela vão quebrar silenciosamente ou usar `undefined`.
- `email.service.test.ts` usa `vi.resetModules()` + `vi.doMock` + `import()` dinâmico por teste (em vez de um único `vi.mock` estático) porque `transporter`/`hasSmtpAuth` são computados **no import do módulo** — não copie o padrão de mock estático de outros serviços para este arquivo.
- Os testes de integração mockada (`tests/integration/*.spec.ts`) mockam `src/config/redis` via `ioredis-mock` mesmo sem nenhuma rota usar `cacheAside`, porque `GET /health` chama `redis.ping()` de verdade ao importar `routes.ts`.
- Handlebars escapa HTML por padrão nos templates — evite usar valores com `=`/`&` em asserts de conteúdo renderizado (`{{resetLink}}` vira `&#x3D;` em vez de `=`), ou o teste vai falhar por um detalhe de escaping, não por um bug real.

Toda feature nova precisa de: teste unitário (service/client/handler, incluindo branches de erro), e teste de integração da rota quando aplicável (incluindo caso autenticado/não autenticado nas rotas que usam `authenticate`).

---

## Variáveis de Ambiente

Toda variável é lida em `src/config/env.ts` através do helper `required(key)` (lança `Error` na subida se ausente — hoje só `DATABASE_URL`) ou de um acesso direto a `process.env` com fallback (todas as demais, incluindo `JWT_SECRET` com fallback inseguro — ver Segurança item 6). Não leia `process.env` diretamente em outro arquivo; centralize em `env.ts`. Propague qualquer variável nova no `k8s/deployment.yaml`. Variáveis relevantes: `PORT`, `DATABASE_URL`, `JWT_SECRET`, `KAFKA_BROKERS`, `REDIS_URL`, `ALLOWED_ORIGINS`, `SMTP_HOST`/`SMTP_PORT`/`SMTP_EMAIL`/`SMTP_PASSWORD`/`SMTP_FROM_NAME`, `USER_SERVICE_URL`, `POST_SERVICE_URL`, `HTTP_CLIENT_TIMEOUT_MS`, `TEMPLATES_DIR`.

---

## Infra deste Serviço

- `docker/Dockerfile`: build em 2 estágios (`builder` roda `prisma generate` + `npm run build`; `runtime` reinstala só dependências de produção via `npm ci --omit=dev` e copia `dist/`, o cliente Prisma gerado, `templates/`, `prisma/` e `prisma.config.ts`); `CMD` roda `node_modules/.bin/prisma migrate deploy && node dist/server.js`. **O pacote `prisma` (CLI) precisa estar em `dependencies`, não `devDependencies`** — `npm ci --omit=dev` no estágio `runtime` não instala devDependencies, e sem o binário `prisma` presente o `CMD` falha antes mesmo de iniciar o servidor. Isso foi corrigido em SCRUM-215 (o pacote estava em `devDependencies` até então); não mova de volta sem entender essa consequência.
- `prisma/migrations/`: gerada pela primeira vez em SCRUM-215 (`prisma migrate dev --name init`). Antes disso, `prisma migrate deploy` no `CMD` do Dockerfile era um no-op silencioso — o schema de produção precisava ter sido provisionado por outro meio. A partir de agora, qualquer mudança em `prisma/schema.prisma` precisa de uma migration nova gerada via `prisma migrate dev` e comitada, ou o deploy não vai refletir a mudança.
- `src/generated/prisma/client/` é ignorado no `.gitignore` (`src/generated`) — diferente do `event-service`, que comita essa pasta. Rode `prisma generate` (via `postinstall` do `npm install`) antes de rodar o serviço localmente.
- `k8s/`: `deployment.yaml`, `hpa.yaml`, `pdb.yaml`, `service.yaml` — não documentados em detalhe aqui; confira o arquivo diretamente antes de assumir réplica mínima/máxima ou thresholds de autoscaling.
- `GET /health` retorna `503` apenas se o Postgres estiver indisponível; se o Redis estiver indisponível, o campo `redis` reporta `"unavailable"` mas o status HTTP continua `200`/`"ok"` — mesmo comportamento "cache é best-effort" do `event-service`. Ver também o bug conhecido de cold-start do Redis na seção Performance.
- CI/CD (`.github/workflows/notification-service.yml`): reescrito em SCRUM-215 do padrão Go (`go test`, `actions/setup-go`) — que estava quebrado desde a reescrita do serviço para Node em SCRUM-184 — para o mesmo padrão Node/Vitest usado pelo `event-service` (`unit-test` → `integration-test` com containers `postgres:15-alpine` + `redis:7-alpine` → `build-and-push` → `deploy`). Este era o único serviço do monorepo com CI ainda quebrado; os demais já seguiam esse padrão.
