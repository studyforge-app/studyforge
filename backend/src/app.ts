import express from "express";
import type { HealthResponse } from "@studyforge/shared-types";

const app = express();
const port = Number(process.env.PORT ?? 3000);

app.use(express.json());

app.get("/api/health", (_req, res) => {
  const body: HealthResponse = { status: "ok", timestamp: new Date().toISOString() };
  res.json(body);
});

app.listen(port, () => {
  console.log(`Backend listening on http://localhost:${port}`);
});
