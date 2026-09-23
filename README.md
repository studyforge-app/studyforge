# studyforge

StudyForge is an npm workspaces monorepo that contains a backend API, a React frontend and their shared TypeScript types.

## Project structure

```
studyforge/
├── backend/        # Express API (TypeScript), entry point: src/app.ts
├── frontend/       # React app (TypeScript) built with Vite
└── shared-types/   # TypeScript types shared by backend and frontend
```

## Prerequisites

- Node.js 22+
- npm 10+

## Getting started

Install dependencies for all workspaces from the repo root:

```sh
npm install
```

## Scripts

Run these from the repo root:

| Script                 | Description                                     |
| ---------------------- | ----------------------------------------------- |
| `npm run dev:backend`  | Start the backend in watch mode (tsx)           |
| `npm run dev:frontend` | Start the Vite dev server                       |
| `npm run build`        | Build all workspaces (backend to `backend/dist`, frontend to `frontend/dist`) |

## API

The backend listens on port `3000` by default. Set `PORT` to change it.

| Method | Path          | Response                                    |
| ------ | ------------- | ------------------------------------------- |
| GET    | `/api/health` | `{ "status": "ok", "timestamp": "<ISO>" }` |

## Frontend

The Vite dev server runs at http://localhost:5173.
