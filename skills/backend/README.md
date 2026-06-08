# /backend — Express + Node.js Backend Skill

A Claude Code slash command that guides building or extending an Express + TypeScript Node.js backend using a battle-tested 3-layer architecture.

## What it does

| Scenario | Behaviour |
|----------|-----------|
| Empty directory | Runs an init conversation (13 questions), then scaffolds the full project |
| Existing project (no pattern) | Reads the structure, identifies gaps, proposes alignment |
| Project with controllers/services | Adds a new resource following the established pattern |

## Architecture enforced

```
Controller  →  Service  →  Database
(HTTP only)    (logic)     (query only)
```

## Key conventions

- **Response envelope**: `{ success, data, message }` on every response
- **Error types**: `ValidationError`, `NotFoundError`, `UnauthorizedError`, `ForbiddenError`
- **Validation**: Zod schemas in `lib/validations/`, `validateOrThrow()` in services
- **Config**: centralised `src/config/index.ts`, throws on missing env vars
- **Constants**: all messages in `constants/messages.ts`, all enums in `constants/enums.ts`
- **Logging**: Winston always, no `console.log`
- **Pagination**: built into every list endpoint (`page`, `limit`, `sortBy`, `order`)
- **Auth**: `authenticate` + `authorize(...roles)` middleware, declared per-route
- **Graceful shutdown**: SIGTERM, SIGINT, uncaughtException, unhandledRejection

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/PadaliyaSavan88/api-forge/main/install.sh | bash -s backend
```

Then in any project, type `/backend` in Claude Code.

## Technologies

- **Framework**: Express.js
- **Language**: TypeScript (full strict mode)
- **Validation**: Zod
- **Logging**: Winston + Morgan
- **Auth**: JWT
- **DB options**: MongoDB (Mongoose), PostgreSQL (Sequelize or Prisma)
- **Security**: Helmet, CORS, express-rate-limit
- **Testing**: Vitest or Jest (optional)
- **Docs**: Swagger/OpenAPI (optional)
