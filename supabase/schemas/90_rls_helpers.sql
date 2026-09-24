-- =============================================================================
-- 90_rls_helpers.sql
-- Helper functions used by RLS policies. Defined after the tables they read.
-- security definer avoids recursive RLS evaluation on module/material.
-- =============================================================================

create or replace function public.user_can_access_document(doc_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.material ma
    join public.module mo on mo.id = ma.module_id
    where ma.document_id = doc_id
      and mo.owner_id = (select auth.uid())
  );
$$;

revoke execute on function public.user_can_access_document(uuid) from public, anon;
grant  execute on function public.user_can_access_document(uuid) to authenticated;

comment on function public.user_can_access_document(uuid) is
  'True if the calling user has this document attached to one of their modules.';
