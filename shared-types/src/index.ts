export interface HealthResponse {
  status: "ok";
  timestamp: string;
}

export type { Database, Json, Tables, TablesInsert, TablesUpdate, Enums } from "./database.types.js";
