import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  // Load env vars from the shared .env at the repo root.
  envDir: "..",
});
