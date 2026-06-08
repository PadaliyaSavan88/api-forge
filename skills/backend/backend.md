# /backend — Express + Node.js Backend Skill

**Author:** Savan Padaliya  
**Version:** 1.0.0  
**Scope:** Express + TypeScript + Node.js  
**Repo:** https://github.com/PadaliyaSavan88/api-forge

---

## What this skill does

Guides building or extending an Express + TypeScript Node.js backend using a battle-tested 3-layer architecture. Works in three modes:

- **New project** — runs an init conversation, then scaffolds the full project structure
- **Align existing** — reads what's already built, identifies gaps, proposes alignment
- **Extend** — adds a new resource (Controller + Service + Zod schema) to an existing project

---

## Phase 1: Analyze the Project

When invoked, ALWAYS start by reading the project. Run these checks:

1. Does `package.json` exist? Read it — note `dependencies`, `devDependencies`, `scripts`
2. Does `src/` exist? If yes, list its contents
3. Do `src/controllers/` and any `*Controller.ts` / `*Service.ts` files exist?
4. Does `src/abstraction/ApiError.ts` exist?
5. Does `src/config/index.ts` exist?

Then decide which mode to run:

| Observation | Mode |
|-------------|------|
| No `package.json` or no `src/` | **New Project** |
| `src/` exists but no Controller/Service pattern | **Align Existing** |
| Controller/Service pattern already present | **Extend** |

Report the finding to the user before proceeding: _"I can see this is a [new project / existing project without the 3-layer pattern / existing project with N controllers]. I'll [scaffold / align / extend]."_

---

## Phase 2A: New Project — Init Conversation

Ask these questions **one at a time**. Show your recommendation. Wait for the user's answer before moving on.

```
Q1.  What is the project name?

Q2.  Which database will you use?
       1. MongoDB (Mongoose)        ← document DB, flexible schema
       2. PostgreSQL (Sequelize)    ← relational, ORM
       3. PostgreSQL (Prisma)       ← relational, type-safe query builder [recommended]

Q3.  What user roles does your app need?
       Examples: admin, user, agent, manager
       [default: admin, user]

Q4.  API version prefix?
       [default: v1  →  routes served at /api/v1/]

Q5.  TypeScript strictness?
       1. Full strict (recommended) — strict: true, noImplicitAny, noUnusedLocals,
          noUnusedParameters, noUncheckedIndexedAccess
       2. Relaxed — basic tsc only

Q6.  ESLint + Prettier? (recommended)
       [Yes / No]
       → If Yes: Add Husky git hooks to enforce lint on commit?  [Yes / No]

Q7.  Testing?
       [Yes / No]
       → If Yes: preferred runner?
           1. Vitest (recommended) — fast, native TS, Jest-compatible API
           2. Jest

Q8.  Rate limiting?
       [Yes / No]
       → If Yes, confirm this config before proceeding:
           windowMs : 15 minutes
           max      : 100 requests per window
           message  : { success: false, data: null, message: 'Too many requests, please try again later.' }
         Change any values?

Q9.  Content Security Policy via Helmet?
       Only enable if your API serves HTML pages.
       [Yes / No — default: No]

Q10. CORS allowed origins?
       Enter comma-separated origins.
       [default: http://localhost:3000]

Q11. Health check endpoint?
       GET /api/v1/system/health — no auth, returns uptime + DB status
       [Yes / No]

Q12. Swagger API docs?
       Served at /api/docs (dev only)
       [Yes / No]

Q13. Production setup — confirm each:

  A) Process manager:
       1. PM2          — ecosystem.config.js scaffolded
       2. Docker       — Dockerfile (multi-stage) + docker-compose.yml + .dockerignore
       3. Both
       4. Neither

  B) Separate environment files for staging and production?
       (.env, .env.staging, .env.production — all gitignored; .env.example committed)
       [Yes / No]

  C) HTTPS strategy:

     Dev  → HTTP only (no cert needed) ✓

     Production options — choose one:
       1. Reverse proxy handles HTTPS (Nginx/Caddy in front, app stays HTTP) [RECOMMENDED]
          → No app-level changes needed
       2. App enforces HTTPS redirect + HSTS header
          → express-sslify or manual redirect middleware added
          → Helmet strictTransportSecurity enabled
       3. HTTP only in production (not recommended)

     → If option 1 or 2: enable secure cookies + trust proxy?  [Yes / No]
       (Required when behind a load balancer or reverse proxy)

  → Show full production config summary and ask user to confirm before writing any files.
```

After all questions are answered, display a summary:

```
Ready to scaffold. Here's what I'll create:

  Project : {name}
  DB      : {choice}
  Roles   : {roles}
  API     : /api/{version}/
  TS      : {strictness}
  ESLint  : {yes/no}  Husky: {yes/no}
  Tests   : {yes/no}  Runner: {runner}
  Rate limiting : {yes/no}
  Helmet CSP    : {yes/no}
  CORS origins  : {list}
  Health check  : {yes/no}
  Swagger docs  : {yes/no}
  Process mgr   : {choice}
  HTTPS (prod)  : {strategy}

Proceed?  [Yes / change something]
```

---

## Phase 2B: Align Existing

1. Read the existing `src/` structure
2. List what IS present vs what the 3-layer pattern requires
3. Identify the gaps (missing service layer, no ApiError, no config module, etc.)
4. Present a prioritised list of recommended changes
5. Ask: _"Which of these would you like me to implement?"_
6. Implement approved changes one file at a time, confirming each

---

## Phase 2C: Extend (Add a New Resource)

Ask:
1. What is the resource name? (singular, PascalCase — e.g. `Order`, `Invoice`)
2. What fields does it have? (name, type, required/optional)
3. Does any route need authentication? Which ones?
4. Does any route need role restriction? Which roles?
5. Any cascade deletes? (e.g. deleting an Order also deletes its OrderItems)

Then scaffold:
- `src/lib/validations/{resource}.schema.ts`
- `src/controllers/{Resource}/{Resource}Controller.ts`
- `src/controllers/{Resource}/{Resource}Service.ts`
- Register in `src/routes.ts`

Confirm no TypeScript errors after scaffolding.

---

## Architecture: 3-Layer Pattern

```
Request
  │
  ▼
[Controller]  — HTTP only. Parse req, call service, call this.send(res). No business logic.
  │
  ▼
[Service]     — All business logic. Validate input, query DB, throw named errors, return data.
  │
  ▼
[DB / Model]  — Mongoose model | Sequelize model | Prisma client. No logic here.
```

**Rules that must never be broken:**
- Controllers NEVER query the DB directly
- Services NEVER touch `req` or `res`
- No `console.log` anywhere — always use `logger`
- No magic strings — all messages from `constants/messages.ts`, all enums from `constants/enums.ts`
- No `process.env.X` outside `src/config/index.ts`
- Authorization is always middleware — never inside a service

---

## Standard Response Envelope

Every response — success AND failure — uses this exact shape:

```ts
// Success
{ success: true,  data: T,    message: string }

// Error (sent by errorHandler middleware)
{ success: false, data: null, message: string }
```

HTTP status codes:
- `200` — GET (list or single), PUT, PATCH
- `201` — POST (created)
- `204` — DELETE (empty body — omit data and message)
- `400` — validation error
- `401` — unauthenticated
- `403` — forbidden (authenticated but wrong role)
- `404` — resource not found
- `429` — rate limit exceeded
- `500` — unexpected server error

---

## Code Templates

Use these exact templates when scaffolding. Replace `{Resource}` / `{resource}` with the actual name.

---

### `src/types/RouteDefinition.ts`

```ts
import { RequestHandler } from 'express';

export interface RouteDefinition {
  path: string;
  method: 'get' | 'post' | 'put' | 'patch' | 'delete';
  handler: RequestHandler;
  middlewares?: RequestHandler[];
}
```

---

### `src/abstraction/ApiError.ts`

```ts
export class ApiError extends Error {
  public status: number;
  public success = false;

  constructor(message: string, statusCode: number) {
    super(message);
    this.status = statusCode;
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}
```

---

### `src/abstraction/errors/ValidationError.ts`

```ts
import { ApiError } from '../ApiError';

export class ValidationError extends ApiError {
  constructor(message: string) {
    super(message, 400);
  }
}
```

### `src/abstraction/errors/NotFoundError.ts`

```ts
import { ApiError } from '../ApiError';

export class NotFoundError extends ApiError {
  constructor(resource = 'Resource') {
    super(`${resource} not found`, 404);
  }
}
```

### `src/abstraction/errors/UnauthorizedError.ts`

```ts
import { ApiError } from '../ApiError';

export class UnauthorizedError extends ApiError {
  constructor(message = 'Unauthorized') {
    super(message, 401);
  }
}
```

### `src/abstraction/errors/ForbiddenError.ts`

```ts
import { ApiError } from '../ApiError';

export class ForbiddenError extends ApiError {
  constructor(message = 'Forbidden') {
    super(message, 403);
  }
}
```

---

### `src/constants/enums.ts`

```ts
export enum Role {
  ADMIN = 'admin',
  USER  = 'user',
  // Add roles confirmed during init
}

// Add other app-specific enums here
// export enum OrderStatus { PENDING = 'pending', CONFIRMED = 'confirmed', ... }
```

---

### `src/constants/messages.ts`

```ts
export const SUCCESS = {
  // Generic
  LISTED:   (resource: string) => `${resource} listed successfully`,
  FETCHED:  (resource: string) => `${resource} fetched successfully`,
  CREATED:  (resource: string) => `${resource} created successfully`,
  UPDATED:  (resource: string) => `${resource} updated successfully`,
  DELETED:  (resource: string) => `${resource} deleted successfully`,

  // System
  HEALTHY: 'System is healthy',
} as const;

export const ERROR = {
  NOT_FOUND:       (resource: string) => `${resource} not found`,
  ALREADY_EXISTS:  (resource: string) => `${resource} already exists`,
  UNAUTHORIZED:    'Unauthorized',
  FORBIDDEN:       'Forbidden',
  VALIDATION:      'Validation failed',
  SERVER:          'Internal server error',
  RATE_LIMITED:    'Too many requests, please try again later.',
} as const;
```

---

### `src/constants/index.ts`

```ts
export * from './enums';
export * from './messages';
```

---

### `src/config/index.ts`

```ts
function required(key: string): string {
  const value = process.env[key];
  if (!value) throw new Error(`Missing required environment variable: ${key}`);
  return value;
}

export const config = {
  env:      process.env.NODE_ENV || 'development',
  isDev:    process.env.NODE_ENV !== 'production',
  port:     Number(process.env.PORT) || 3000,

  db: {
    url: required('DATABASE_URL'),
  },

  jwt: {
    secret:    required('JWT_SECRET'),
    expiresIn: process.env.JWT_EXPIRES_IN || '8h',
  },

  cors: {
    origins: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3000'],
  },

  rateLimit: {
    windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
    max:      Number(process.env.RATE_LIMIT_MAX)       || 100,
  },

  logLevel: process.env.NODE_ENV === 'production' ? 'warn' : 'debug',
} as const;
```

---

### `src/lib/logger.ts`

```ts
import { existsSync, mkdirSync } from 'fs';
import winston from 'winston';
import { config } from '@config';

const logDir = './logs';
if (!existsSync(logDir)) mkdirSync(logDir);

const logger = winston.createLogger({
  level: config.logLevel,
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json(),
  ),
  transports: [
    new winston.transports.Console({
      format: config.isDev
        ? winston.format.combine(winston.format.colorize(), winston.format.simple())
        : winston.format.json(),
    }),
    new winston.transports.File({ filename: `${logDir}/error.log`,    level: 'error' }),
    new winston.transports.File({ filename: `${logDir}/combined.log` }),
  ],
});

export default logger;
```

---

### `src/lib/utils/validate.ts`

```ts
import { ZodSchema, ZodError } from 'zod';
import { ValidationError } from '@abstraction/errors/ValidationError';

export function validateOrThrow<T>(schema: ZodSchema<T>, payload: unknown): T {
  try {
    return schema.parse(payload);
  } catch (err) {
    if (err instanceof ZodError) {
      const message = err.errors.map((e) => `${e.path.join('.')}: ${e.message}`).join('; ');
      throw new ValidationError(message);
    }
    throw err;
  }
}
```

---

### `src/lib/utils/paginate.ts`

```ts
export interface PaginationQuery {
  page?:    string | number;
  limit?:   string | number;
  sortBy?:  string;
  order?:   'asc' | 'desc';
}

export interface PaginationParams {
  skip:      number;
  take:      number;
  page:      number;
  limit:     number;
  sortBy:    string;
  order:     'asc' | 'desc';
}

export interface PaginatedResponse<T> {
  items:      T[];
  total:      number;
  page:       number;
  limit:      number;
  totalPages: number;
}

export function paginate(query: PaginationQuery, defaultSortBy = 'createdAt'): PaginationParams {
  const page   = Math.max(1, Number(query.page)  || 1);
  const limit  = Math.min(100, Math.max(1, Number(query.limit) || 20));
  const sortBy = query.sortBy || defaultSortBy;
  const order  = query.order === 'asc' ? 'asc' : 'desc';

  return { skip: (page - 1) * limit, take: limit, page, limit, sortBy, order };
}

export function buildPaginatedResponse<T>(
  items: T[],
  total: number,
  params: PaginationParams,
): PaginatedResponse<T> {
  return {
    items,
    total,
    page:       params.page,
    limit:      params.limit,
    totalPages: Math.ceil(total / params.limit),
  };
}
```

---

### `src/middleware/authenticate.ts`

```ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '@config';
import { UnauthorizedError } from '@abstraction/errors/UnauthorizedError';

export interface SessionUser {
  id:    string;
  role:  string;
  email: string;
}

declare global {
  namespace Express {
    interface Locals {
      user: SessionUser;
    }
  }
}

export function authenticate(req: Request, res: Response, next: NextFunction): void {
  try {
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) throw new UnauthorizedError();

    const token   = header.split(' ')[1];
    const payload = jwt.verify(token, config.jwt.secret) as SessionUser;
    res.locals.user = payload;
    next();
  } catch {
    next(new UnauthorizedError());
  }
}
```

---

### `src/middleware/authorize.ts`

```ts
import { Request, Response, NextFunction } from 'express';
import { ForbiddenError } from '@abstraction/errors/ForbiddenError';

export function authorize(...roles: string[]) {
  return (_req: Request, res: Response, next: NextFunction): void => {
    const user = res.locals.user;
    if (!user || !roles.includes(user.role)) {
      return next(new ForbiddenError());
    }
    next();
  };
}
```

---

### `src/middleware/errorHandler.ts`

```ts
import { Request, Response, NextFunction } from 'express';
import { ApiError } from '@abstraction/ApiError';
import logger from '@lib/logger';
import { ERROR } from '@constants';

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  if (err instanceof ApiError) {
    res.status(err.status).json({
      success: false,
      data:    null,
      message: err.message,
    });
    return;
  }

  logger.error('[errorHandler] Unexpected error:', err);
  res.status(500).json({
    success: false,
    data:    null,
    message: ERROR.SERVER,
  });
}
```

---

### `src/controllers/BaseController.ts`

```ts
import { Response } from 'express';
import { StatusCodes } from 'http-status-codes';
import { RouteDefinition } from '@types/RouteDefinition';

export abstract class BaseController {
  public abstract basePath: string;
  public abstract routes(): RouteDefinition[];

  protected send<T>(
    res: Response,
    data: T,
    message: string,
    statusCode: number = StatusCodes.OK,
  ): void {
    res.status(statusCode).json({ success: true, data, message });
  }

  protected noContent(res: Response): void {
    res.status(204).send();
  }
}
```

---

### `src/lib/validations/{resource}.schema.ts`

```ts
import { z } from 'zod';

export const create{Resource}Schema = z.object({
  name: z.string().min(1, 'Name is required'),
  // Add fields here
});

export const update{Resource}Schema = create{Resource}Schema.partial();

export type Create{Resource}Input = z.infer<typeof create{Resource}Schema>;
export type Update{Resource}Input = z.infer<typeof update{Resource}Schema>;
```

---

### `src/controllers/{Resource}/{Resource}Service.ts`

```ts
import logger from '@lib/logger';
import { validateOrThrow } from '@lib/utils/validate';
import { paginate, buildPaginatedResponse, PaginationQuery, PaginatedResponse } from '@lib/utils/paginate';
import { NotFoundError } from '@abstraction/errors/NotFoundError';
import { create{Resource}Schema, update{Resource}Schema, Create{Resource}Input, Update{Resource}Input } from '@lib/validations/{resource}.schema';
import { SUCCESS } from '@constants';

// Replace with actual model import based on DB choice:
// import { {Resource} } from '@database/models/{resource}';

export class {Resource}Service {
  async getAll(query: PaginationQuery): Promise<PaginatedResponse<any>> {
    try {
      const params = paginate(query);
      // DB query here — example for Prisma:
      // const [items, total] = await Promise.all([
      //   prisma.{resource}.findMany({ skip: params.skip, take: params.take, orderBy: { [params.sortBy]: params.order } }),
      //   prisma.{resource}.count(),
      // ]);
      const items: any[] = [];
      const total = 0;
      return buildPaginatedResponse(items, total, params);
    } catch (err) {
      logger.error('[{Resource}Service] getAll failed:', err);
      throw err;
    }
  }

  async getById(id: string): Promise<any> {
    try {
      // const record = await prisma.{resource}.findUnique({ where: { id } });
      const record = null;
      if (!record) throw new NotFoundError('{Resource}');
      return record;
    } catch (err) {
      logger.error('[{Resource}Service] getById failed:', err);
      throw err;
    }
  }

  async create(payload: Create{Resource}Input): Promise<any> {
    const data = validateOrThrow(create{Resource}Schema, payload);
    try {
      // const record = await prisma.{resource}.create({ data });
      return data;
    } catch (err) {
      logger.error('[{Resource}Service] create failed:', err);
      throw err;
    }
  }

  async update(id: string, payload: Update{Resource}Input): Promise<any> {
    const data = validateOrThrow(update{Resource}Schema, payload);
    try {
      await this.getById(id); // throws NotFoundError if missing
      // const record = await prisma.{resource}.update({ where: { id }, data });
      return data;
    } catch (err) {
      logger.error('[{Resource}Service] update failed:', err);
      throw err;
    }
  }

  async remove(id: string): Promise<void> {
    try {
      await this.getById(id); // throws NotFoundError if missing
      // await prisma.{resource}.delete({ where: { id } });
      // If cascade needed: delete related records first
    } catch (err) {
      logger.error('[{Resource}Service] remove failed:', err);
      throw err;
    }
  }
}
```

---

### `src/controllers/{Resource}/{Resource}Controller.ts`

```ts
import { Request, Response, NextFunction } from 'express';
import { StatusCodes } from 'http-status-codes';
import { BaseController } from '@controllers/BaseController';
import { RouteDefinition } from '@types/RouteDefinition';
import { {Resource}Service } from './{Resource}Service';
import { authenticate } from '@middleware/authenticate';
import { authorize } from '@middleware/authorize';
import { SUCCESS } from '@constants';
import { Role } from '@constants/enums';

export class {Resource}Controller extends BaseController {
  public basePath = '{resources}'; // plural, kebab-case
  private service: {Resource}Service;

  constructor() {
    super();
    this.service = new {Resource}Service();
  }

  public routes(): RouteDefinition[] {
    return [
      {
        path: '/',
        method: 'get',
        handler: this.list.bind(this),
        // middlewares: [authenticate],   // add if route needs auth
      },
      {
        path: '/:id',
        method: 'get',
        handler: this.getOne.bind(this),
      },
      {
        path: '/',
        method: 'post',
        middlewares: [authenticate, authorize(Role.ADMIN)],
        handler: this.create.bind(this),
      },
      {
        path: '/:id',
        method: 'put',
        middlewares: [authenticate, authorize(Role.ADMIN)],
        handler: this.update.bind(this),
      },
      {
        path: '/:id',
        method: 'delete',
        middlewares: [authenticate, authorize(Role.ADMIN)],
        handler: this.remove.bind(this),
      },
    ];
  }

  private async list(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const data = await this.service.getAll(req.query);
      this.send(res, data, SUCCESS.LISTED('{Resource}'));
    } catch (err) { next(err); }
  }

  private async getOne(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const data = await this.service.getById(req.params.id);
      this.send(res, data, SUCCESS.FETCHED('{Resource}'));
    } catch (err) { next(err); }
  }

  private async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const data = await this.service.create(req.body);
      this.send(res, data, SUCCESS.CREATED('{Resource}'), StatusCodes.CREATED);
    } catch (err) { next(err); }
  }

  private async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const data = await this.service.update(req.params.id, req.body);
      this.send(res, data, SUCCESS.UPDATED('{Resource}'));
    } catch (err) { next(err); }
  }

  private async remove(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      await this.service.remove(req.params.id);
      this.noContent(res);
    } catch (err) { next(err); }
  }
}
```

---

### `src/routes.ts`

```ts
import { Router } from 'express';
import { RouteDefinition } from '@types/RouteDefinition';
import { BaseController } from '@controllers/BaseController';
import logger from '@lib/logger';
// Import controllers here:
// import { UserController } from '@controllers/User/UserController';

function registerControllerRoutes(routes: RouteDefinition[]): Router {
  const router = Router();
  routes.forEach((route) => {
    const handlers = [...(route.middlewares || []), route.handler];
    router[route.method](route.path, ...handlers);
  });
  return router;
}

export default function registerRoutes(version = 'v1'): Router {
  try {
    const router = Router();

    const controllers: BaseController[] = [
      // new UserController(),
      // Register new controllers here
    ];

    controllers.forEach((controller) => {
      router.use(`/${version}/${controller.basePath}`, registerControllerRoutes(controller.routes()));
    });

    return router;
  } catch (err) {
    logger.error('[routes] Failed to register routes:', err);
    throw err;
  }
}
```

---

### `src/App.ts`

```ts
import express, { Application } from 'express';
import http from 'http';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { config } from '@config';
import logger from '@lib/logger';
import { errorHandler } from '@middleware/errorHandler';
import { ERROR } from '@constants';
import registerRoutes from './routes';

export class App {
  public express!: Application;
  public httpServer!: http.Server;

  public async init(): Promise<void> {
    this.express = express();
    this.httpServer = http.createServer(this.express);
    this.middleware();
    this.routes();
    this.errorHandling();
    await this.connectDatabase();
  }

  private middleware(): void {
    this.express.use(helmet({ contentSecurityPolicy: false })); // set to true if serving HTML

    this.express.use(express.json({ limit: '10mb' }));
    this.express.use(express.urlencoded({ extended: true, limit: '10mb' }));

    this.express.use(cors({ origin: config.cors.origins }));

    this.express.use(
      morgan(config.isDev ? 'dev' : 'combined', {
        skip: (_req, res) => !config.isDev && res.statusCode < 400,
        stream: { write: (msg) => logger.http(msg.trim()) },
      }),
    );

    // Remove if rate limiting not enabled during init
    this.express.use(
      '/api/',
      rateLimit({
        windowMs: config.rateLimit.windowMs,
        max:      config.rateLimit.max,
        message:  { success: false, data: null, message: ERROR.RATE_LIMITED },
      }),
    );

    if (!config.isDev) {
      this.express.set('trust proxy', 1); // required behind reverse proxy
    }
  }

  private routes(): void {
    this.express.get('/', (_req, res) => res.json({ success: true, data: null, message: 'API is running' }));
    this.express.use('/api', registerRoutes());
  }

  private errorHandling(): void {
    this.express.use(errorHandler);
  }

  private async connectDatabase(): Promise<void> {
    try {
      // await prisma.$connect();          // Prisma
      // await sequelize.authenticate();   // Sequelize
      // await mongoose.connect(...)       // Mongoose
      logger.info('[database] Connection established');
    } catch (err) {
      logger.error('[database] Connection failed:', err);
      process.exit(1);
    }
  }
}
```

---

### `src/index.ts`

```ts
import 'dotenv/config';
import { App } from './App';
import logger from '@lib/logger';
import { config } from '@config';

const app = new App();

async function start(): Promise<void> {
  await app.init();

  const server = app.httpServer.listen(config.port, () => {
    logger.info(`[server] Running on port ${config.port} in ${config.env} mode`);
  });

  const shutdown = (signal: string) => {
    logger.warn(`[server] ${signal} received — shutting down gracefully`);
    server.close(async () => {
      // await prisma.$disconnect();    // Prisma
      // await sequelize.close();       // Sequelize
      // await mongoose.disconnect();   // Mongoose
      logger.info('[server] Closed — exiting');
      process.exit(0);
    });
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT',  () => shutdown('SIGINT'));
  process.on('uncaughtException',  (err) => { logger.error('[server] uncaughtException:', err);  process.exit(1); });
  process.on('unhandledRejection', (err) => { logger.error('[server] unhandledRejection:', err); process.exit(1); });
}

start().catch((err) => {
  logger.error('[server] Failed to start:', err);
  process.exit(1);
});
```

---

## 21 Conventions — Quick Reference

| # | Rule |
|---|------|
| 1 | Validation: Zod schema in `lib/validations/`, `validateOrThrow()` called at top of service method |
| 2 | Config: all `process.env` access in `src/config/index.ts` only, throws on missing required vars |
| 3 | Constants: all string messages from `constants/messages.ts`, all enums from `constants/enums.ts` |
| 4 | TypeScript: full strict mode (`strict: true` + `noImplicitAny` + `noUnusedLocals` + `noUncheckedIndexedAccess`) |
| 5 | Linting: ESLint + Prettier optional — decided at init |
| 6 | Testing: Vitest optional — decided at init; services are primary test target |
| 7 | Versioning: `/api/v1/` default prefix — decided at init |
| 8 | Pagination: every `getAll()` accepts `page`, `limit`, `sortBy`, `order` via `paginate()` helper |
| 9 | Auth: `authenticate` middleware, declared per-route in `middlewares[]` on `RouteDefinition` |
| 10 | Authorization: `authorize(...roles)` middleware, never inside service |
| 11 | Rate limiting: optional — confirm config at init, applied globally to `/api/` |
| 12 | Security: Helmet always on, CSP decided at init |
| 13 | CORS: origins from `config.cors.origins`, never hardcoded |
| 14 | Errors: named subclasses — `ValidationError(400)`, `NotFoundError(404)`, `UnauthorizedError(401)`, `ForbiddenError(403)` |
| 15 | Database: decided at init — Mongoose | Sequelize | Prisma |
| 16 | Logging: Winston always, `logger.error/warn/info/http` — NO `console.log` in any file |
| 17 | Path aliases: `@config`, `@lib/*`, `@controllers/*`, `@middleware/*`, `@abstraction/*`, `@constants`, `@types/*` |
| 18 | Graceful shutdown: SIGTERM + SIGINT + uncaughtException + unhandledRejection in `index.ts` |
| 19 | Health check: optional — decided at init |
| 20 | API docs: Swagger optional — decided at init, `/api/docs` dev-only |
| 21 | Production: PM2/Docker decided at init, HTTPS strategy confirmed before writing |

---

## Extend Checklist (adding a resource to an existing project)

```
[ ] 1. Create src/lib/validations/{resource}.schema.ts      (create + update Zod schemas)
[ ] 2. Create src/controllers/{Resource}/{Resource}Service.ts  (getAll, getById, create, update, remove)
[ ] 3. Create src/controllers/{Resource}/{Resource}Controller.ts  (5 routes, middlewares declared)
[ ] 4. Register in src/routes.ts                             (new XController() in controllers array)
[ ] 5. Verify no TS errors: npx tsc --noEmit
[ ] 6. Test manually: POST → GET list → GET one → PUT → DELETE
```

---

## Installation

```bash
# Install this skill globally on your machine
curl -fsSL https://raw.githubusercontent.com/PadaliyaSavan88/api-forge/main/install.sh | bash -s backend

# Or clone and run locally
git clone https://github.com/PadaliyaSavan88/api-forge
cd api-forge && ./install.sh backend
```

Then in any project, type `/backend` in Claude Code.
