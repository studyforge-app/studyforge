import { createClient } from "@supabase/supabase-js";
import type { Database } from "@studyforge/shared-types";

const url = process.env.SUPABASE_URL;
const secretKey = process.env.SUPABASE_SECRET_KEY;

if (!url || !secretKey) {
  throw new Error("SUPABASE_URL and SUPABASE_SECRET_KEY must be set (see .env.example)");
}

// Server-side client: bypasses RLS, never expose this key to the browser.
export const supabase = createClient<Database>(url, secretKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});
