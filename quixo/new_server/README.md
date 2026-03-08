# New Quixo Server

This entry point runs the **same API** as the old server (`../server`) so that all quixo frontend and backend code can stay unchanged. It connects to the **new database** (`quixo-new`).

## Run

From the **quixo** monorepo root:

```bash
npm run dev:new-server
```

Or:

```bash
node new_server/server.js
```

## Environment

- Copy `quixo/.env.example` (or `new_server/.env.example`) and set:
  - `MONGODB_URI` or `MONGO_URI` — e.g. `mongodb://localhost:27017/quixo-new`
  - `JWT_SECRET`, `JWT_ADMIN_SECRET`, `REDIS_URL` — same as old server if you use auth/Redis features
- Frontend apps (client, vendor, rider, admin) use `.env` with `VITE_API_URL` / `VITE_ADMIN_API_URL` pointing to `http://localhost:5000/api` so they talk to this server.

## Switching from old server

1. Stop the old server (if it was running on port 5000).
2. Start the new server: `npm run dev:new-server`.
3. Use the same frontend apps; no code changes needed.
