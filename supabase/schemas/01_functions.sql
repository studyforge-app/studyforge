-- =============================================================================
-- 01_functions.sql
-- Generic trigger functions shared by several tables.
-- =============================================================================

-- Keeps `updated_at` current on every UPDATE.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

comment on function public.set_updated_at() is
  'BEFORE UPDATE trigger: sets updated_at = now().';
