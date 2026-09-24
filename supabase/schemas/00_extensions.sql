-- =============================================================================
-- 00_extensions.sql
-- Extensions required by the studyforge schema.
--
-- gen_random_uuid() is built into Postgres 13+ (we run PG 17), so no extension
-- is needed for uuid primary keys. pgcrypto is preinstalled on Supabase in the
-- `extensions` schema; this statement is a no-op there and only documents the
-- dependency.
-- =============================================================================

create extension if not exists pgcrypto with schema extensions;
