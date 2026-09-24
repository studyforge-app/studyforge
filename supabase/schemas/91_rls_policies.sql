-- =============================================================================
-- 91_rls_policies.sql
-- Row Level Security for every table in `public`.
--
-- Rules of thumb:
--   * Policies target `authenticated` only; `anon` gets nothing.
--   * (select auth.uid()) is wrapped in a subquery so Postgres caches it per
--     statement instead of evaluating it per row.
--   * The worker/server uses the service_role (secret) key, which bypasses RLS.
--     Shared generated content and the XP ledger are therefore read-only here.
-- =============================================================================

-- profile ---------------------------------------------------------------------
alter table public.profile enable row level security;

create policy "profile: select own" on public.profile
  for select to authenticated
  using ((select auth.uid()) = id);

-- Stats columns are additionally guarded by trg_profile_protect_stats.
create policy "profile: update own" on public.profile
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- document (shared, read via material) ----------------------------------------
alter table public.document enable row level security;

create policy "document: select via material" on public.document
  for select to authenticated
  using (public.user_can_access_document(id));

-- chunk -----------------------------------------------------------------------
alter table public.chunk enable row level security;

create policy "chunk: select via document" on public.chunk
  for select to authenticated
  using (public.user_can_access_document(document_id));

-- module ----------------------------------------------------------------------
alter table public.module enable row level security;

create policy "module: select own" on public.module
  for select to authenticated
  using ((select auth.uid()) = owner_id);

create policy "module: insert own" on public.module
  for insert to authenticated
  with check ((select auth.uid()) = owner_id);

create policy "module: update own" on public.module
  for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create policy "module: delete own" on public.module
  for delete to authenticated
  using ((select auth.uid()) = owner_id);

-- material --------------------------------------------------------------------
alter table public.material enable row level security;

create policy "material: select via own module" on public.material
  for select to authenticated
  using (exists (
    select 1 from public.module m
    where m.id = module_id and m.owner_id = (select auth.uid())
  ));

create policy "material: insert into own module" on public.material
  for insert to authenticated
  with check (exists (
    select 1 from public.module m
    where m.id = module_id and m.owner_id = (select auth.uid())
  ));

create policy "material: update via own module" on public.material
  for update to authenticated
  using (exists (
    select 1 from public.module m
    where m.id = module_id and m.owner_id = (select auth.uid())
  ))
  with check (exists (
    select 1 from public.module m
    where m.id = module_id and m.owner_id = (select auth.uid())
  ));

create policy "material: delete via own module" on public.material
  for delete to authenticated
  using (exists (
    select 1 from public.module m
    where m.id = module_id and m.owner_id = (select auth.uid())
  ));

-- flashcard (shared, read-only for clients) -----------------------------------
alter table public.flashcard enable row level security;

create policy "flashcard: select via document" on public.flashcard
  for select to authenticated
  using (exists (
    select 1 from public.chunk c
    where c.id = chunk_id and public.user_can_access_document(c.document_id)
  ));

-- quiz_question (shared, read-only for clients) -------------------------------
alter table public.quiz_question enable row level security;

create policy "quiz_question: select via document" on public.quiz_question
  for select to authenticated
  using (exists (
    select 1 from public.chunk c
    where c.id = chunk_id and public.user_can_access_document(c.document_id)
  ));

-- card_state ------------------------------------------------------------------
alter table public.card_state enable row level security;

create policy "card_state: select own" on public.card_state
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "card_state: insert own" on public.card_state
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "card_state: update own" on public.card_state
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "card_state: delete own" on public.card_state
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- study_session ---------------------------------------------------------------
alter table public.study_session enable row level security;

create policy "study_session: select own" on public.study_session
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "study_session: insert own in own module" on public.study_session
  for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.module m
      where m.id = module_id and m.owner_id = (select auth.uid())
    )
  );

create policy "study_session: update own" on public.study_session
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.module m
      where m.id = module_id and m.owner_id = (select auth.uid())
    )
  );

create policy "study_session: delete own" on public.study_session
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- card_review -----------------------------------------------------------------
alter table public.card_review enable row level security;

create policy "card_review: select via own session" on public.card_review
  for select to authenticated
  using (exists (
    select 1 from public.study_session s
    where s.id = session_id and s.user_id = (select auth.uid())
  ));

create policy "card_review: insert into own session" on public.card_review
  for insert to authenticated
  with check (
    exists (
      select 1 from public.study_session s
      where s.id = session_id and s.user_id = (select auth.uid())
    )
    and exists (
      select 1 from public.flashcard f
      join public.chunk c on c.id = f.chunk_id
      where f.id = flashcard_id and public.user_can_access_document(c.document_id)
    )
  );

create policy "card_review: delete via own session" on public.card_review
  for delete to authenticated
  using (exists (
    select 1 from public.study_session s
    where s.id = session_id and s.user_id = (select auth.uid())
  ));

-- quiz_answer -----------------------------------------------------------------
alter table public.quiz_answer enable row level security;

create policy "quiz_answer: select via own session" on public.quiz_answer
  for select to authenticated
  using (exists (
    select 1 from public.study_session s
    where s.id = session_id and s.user_id = (select auth.uid())
  ));

create policy "quiz_answer: insert into own session" on public.quiz_answer
  for insert to authenticated
  with check (
    exists (
      select 1 from public.study_session s
      where s.id = session_id and s.user_id = (select auth.uid())
    )
    and exists (
      select 1 from public.quiz_question q
      join public.chunk c on c.id = q.chunk_id
      where q.id = question_id and public.user_can_access_document(c.document_id)
    )
  );

create policy "quiz_answer: delete via own session" on public.quiz_answer
  for delete to authenticated
  using (exists (
    select 1 from public.study_session s
    where s.id = session_id and s.user_id = (select auth.uid())
  ));

-- xp_event (server-written ledger) --------------------------------------------
alter table public.xp_event enable row level security;

create policy "xp_event: select own" on public.xp_event
  for select to authenticated
  using ((select auth.uid()) = user_id);
