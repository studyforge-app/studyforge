# studyforge

StudyForge is an npm workspaces monorepo that contains a backend API, a React frontend, their shared TypeScript types and the Supabase project (database, migrations).

## Project structure

```
studyforge/
├── backend/        # Express API (TypeScript), entry point: src/app.ts
├── frontend/       # React app (TypeScript) built with Vite
├── shared-types/   # TypeScript types shared by backend and frontend (incl. generated Supabase types)
└── supabase/       # Supabase CLI project: config.toml, migrations
```

## Prerequisites

- Node.js 22+
- npm 10+
- Docker (only for running Supabase locally)

## Getting started

Install dependencies for all workspaces from the repo root:

```sh
npm install
```

Copy `.env.example` to `.env` at the repo root and fill in your Supabase keys. The backend and the frontend both read this file.

## Scripts

Run these from the repo root:

| Script                 | Description                                     |
| ---------------------- | ----------------------------------------------- |
| `npm run dev:backend`  | Start the backend in watch mode (tsx)           |
| `npm run dev:frontend` | Start the Vite dev server                       |
| `npm run build`        | Build all workspaces (backend to `backend/dist`, frontend to `frontend/dist`) |
| `npm run supabase:start` | Start the local Supabase stack (Docker)      |
| `npm run supabase:stop`  | Stop the local Supabase stack                |
| `npm run db:migration:new -- <name>` | Create a new migration in `supabase/migrations` |
| `npm run db:push`      | Apply migrations to the linked remote project   |
| `npm run db:reset`     | Reset the local database and re-run migrations  |
| `npm run db:types`     | Regenerate `shared-types/src/database.types.ts` from the linked project |

## API

The backend listens on port `3000` by default. Set `PORT` to change it.

| Method | Path          | Response                                    |
| ------ | ------------- | ------------------------------------------- |
| GET    | `/api/health` | `{ "status": "ok", "timestamp": "<ISO>" }` |

## Frontend

The Vite dev server runs at http://localhost:5173.
