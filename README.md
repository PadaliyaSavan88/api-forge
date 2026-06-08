# api-forge

A collection of Claude Code slash commands for building production-grade backend APIs. Based on battle-tested boilerplate patterns.

**Author:** Savan Padaliya

---

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| [backend](./skills/backend/) | `/backend` | Express + TypeScript backend — 3-layer architecture, scaffold or extend |

More skills coming: `/frontend`, `/devops`, `/database`

---

## Install a skill

**One-liner (no clone needed):**

```bash
curl -fsSL https://raw.githubusercontent.com/PadaliyaSavan88/api-forge/main/install.sh | bash -s backend
```

**Or clone and install:**

```bash
git clone https://github.com/PadaliyaSavan88/api-forge
cd api-forge
./install.sh backend      # install one skill
./install.sh all          # install all skills
```

Skills are installed to `~/.claude/commands/`. Restart Claude Code or open a new session after installing.

---

## How it works

Each skill is a markdown file that Claude Code loads as a slash command. When you type `/backend` in Claude Code, the skill file is injected into context and Claude follows its instructions — analyzing your project, asking the right questions, and scaffolding production-ready code.

---

## `/backend` — Express + Node.js

**3 modes:**

1. **New project** — asks 13 init questions (DB, roles, TypeScript strictness, auth, rate limiting, HTTPS strategy, etc.), then generates the full project structure
2. **Align existing** — reads your current `src/` structure, identifies gaps vs the pattern, proposes improvements
3. **Extend** — adds a new resource (Controller + Service + Zod schema) to an existing project

**Architecture:**
```
Controller (HTTP) → Service (business logic) → DB Model (query only)
```

**Always enforced:**
- `{ success, data, message }` on every response
- Named error classes (ValidationError, NotFoundError, UnauthorizedError, ForbiddenError)
- Zod validation in services
- Centralised config with startup validation
- Winston logging, no console.log
- Pagination on all list endpoints
- Graceful shutdown
- Helmet security headers

**Optional (decided at init):** ESLint, Prettier, Husky, Vitest/Jest, rate limiting, health check, Swagger, PM2, Docker, HTTPS strategy

---

## Contributing

To add a skill:

1. Create `skills/{skill-name}/{skill-name}.md`
2. Add a `skills/{skill-name}/README.md`
3. Add the skill name to `AVAILABLE_SKILLS` in `install.sh`
4. Add a row to the skills table in this README
