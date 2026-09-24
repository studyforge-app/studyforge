SET local check_function_bodies = off;

CREATE TABLE "public"."card_review" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "session_id"   uuid                     NOT NULL,
  "flashcard_id" uuid                     NOT NULL,
  "knew"         boolean                  NOT NULL,
  "reviewed_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "card_review_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."card_review"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."card_state" (
  "user_id"      uuid                     NOT NULL,
  "flashcard_id" uuid                     NOT NULL,
  "last_result"  text,
  "due_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "chk_card_state_last_result" CHECK ((last_result = ANY (ARRAY['knew'::text, 'didnt_know'::text]))),
  CONSTRAINT "pk_card_state" PRIMARY KEY (user_id, flashcard_id)
);

ALTER TABLE "public"."card_state"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."chunk" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "document_id" uuid                     NOT NULL,
  "position"    integer                  NOT NULL,
  "source_ref"  text,
  "text"        text                     NOT NULL,
  "status"      text                     NOT NULL DEFAULT 'pending'::text,
  "attempts"    integer                  NOT NULL DEFAULT 0,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "chk_chunk_attempts" CHECK ((attempts >= 0)),
  CONSTRAINT "chk_chunk_position" CHECK (("position" >= 0)),
  CONSTRAINT "chk_chunk_status" CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'done'::text, 'failed'::text]))),
  CONSTRAINT "chunk_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_chunk_document_position" UNIQUE (document_id, "position")
);

ALTER TABLE "public"."chunk"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."document" (
  "id"            uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "file_hash"     text                     NOT NULL,
  "file_path"     text                     NOT NULL,
  "file_type"     text                     NOT NULL,
  "page_count"    integer,
  "status"        text                     NOT NULL DEFAULT 'pending'::text,
  "locked_at"     timestamp with time zone,
  "attempts"      integer                  NOT NULL DEFAULT 0,
  "error_message" text,
  "created_at"    timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"    timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "chk_document_attempts" CHECK ((attempts >= 0)),
  CONSTRAINT "chk_document_page_count" CHECK ((page_count >= 0)),
  CONSTRAINT "chk_document_status" CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'ready'::text, 'failed'::text]))),
  CONSTRAINT "document_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_document_file_hash" UNIQUE (file_hash)
);

ALTER TABLE "public"."document"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."flashcard" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "chunk_id"   uuid                     NOT NULL,
  "front"      text                     NOT NULL,
  "back"       text                     NOT NULL,
  "source_ref" text,
  "edited"     boolean                  NOT NULL DEFAULT false,
  "deleted_at" timestamp with time zone,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "flashcard_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."flashcard"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."material" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "module_id"   uuid                     NOT NULL,
  "document_id" uuid                     NOT NULL,
  "title"       text,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "material_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_material_module_document" UNIQUE (module_id, document_id)
);

ALTER TABLE "public"."material"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."module" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "owner_id"   uuid                     NOT NULL,
  "course_id"  uuid,
  "name"       text                     NOT NULL,
  "exam_date"  date,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "chk_module_name_not_empty" CHECK ((length(TRIM(BOTH FROM name)) > 0)),
  CONSTRAINT "module_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."module"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."profile" (
  "id"              uuid                     NOT NULL,
  "display_name"    text,
  "avatar_url"      text,
  "xp_total"        integer                  NOT NULL DEFAULT 0,
  "current_streak"  integer                  NOT NULL DEFAULT 0,
  "longest_streak"  integer                  NOT NULL DEFAULT 0,
  "last_study_date" date,
  "timezone"        text                     NOT NULL DEFAULT 'Europe/Berlin'::text,
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "chk_profile_current_streak_nonneg" CHECK ((current_streak >= 0)),
  CONSTRAINT "chk_profile_longest_streak_nonneg" CHECK ((longest_streak >= 0)),
  CONSTRAINT "chk_profile_xp_total_nonneg" CHECK ((xp_total >= 0)),
  CONSTRAINT "profile_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."profile"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."quiz_answer" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "session_id"   uuid                     NOT NULL,
  "question_id"  uuid                     NOT NULL,
  "chosen_index" smallint                 NOT NULL,
  "is_correct"   boolean                  NOT NULL,
  "answered_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "chk_quiz_answer_chosen_index" CHECK ((chosen_index >= 0)),
  CONSTRAINT "quiz_answer_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."quiz_answer"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."quiz_question" (
  "id"            uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "chunk_id"      uuid                     NOT NULL,
  "question"      text                     NOT NULL,
  "options"       jsonb                    NOT NULL,
  "correct_index" smallint                 NOT NULL,
  "explanation"   text,
  "source_ref"    text,
  "deleted_at"    timestamp with time zone,
  "created_at"    timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"    timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "chk_quiz_question_correct_index" CHECK (((correct_index >= 0) AND (correct_index < jsonb_array_length(options)))),
  CONSTRAINT "chk_quiz_question_options_array" CHECK ((jsonb_typeof(options) = 'array'::text)),
  CONSTRAINT "quiz_question_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."quiz_question"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."study_session" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "user_id"     uuid                     NOT NULL,
  "module_id"   uuid                     NOT NULL,
  "type"        text                     NOT NULL,
  "started_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "finished_at" timestamp with time zone,
  "completed"   boolean                  NOT NULL DEFAULT false,
  CONSTRAINT "chk_study_session_finished_after_start" CHECK (((finished_at IS NULL) OR (finished_at >= started_at))),
  CONSTRAINT "chk_study_session_type" CHECK ((type = ANY (ARRAY['flashcards'::text, 'quiz'::text]))),
  CONSTRAINT "study_session_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."study_session"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."xp_event" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "user_id"    uuid                     NOT NULL,
  "session_id" uuid,
  "amount"     integer                  NOT NULL,
  "reason"     text                     NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "chk_xp_event_amount_nonzero" CHECK ((amount <> 0)),
  CONSTRAINT "chk_xp_event_reason" CHECK ((reason = ANY (ARRAY['session_completed'::text, 'card_reviewed'::text, 'quiz_correct'::text, 'streak_bonus'::text]))),
  CONSTRAINT "xp_event_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."xp_event"
  ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.handle_new_user()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
  insert into public.profile (id, display_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data ->> 'display_name',
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.protect_profile_stats()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO ''
  AS $function$
begin
  if coalesce(auth.jwt() ->> 'role', '') in ('authenticated', 'anon')
     and (new.xp_total        is distinct from old.xp_total
       or new.current_streak  is distinct from old.current_streak
       or new.longest_streak  is distinct from old.longest_streak
       or new.last_study_date is distinct from old.last_study_date)
  then
    raise exception 'profile stats (xp_total, streaks, last_study_date) are server-managed'
      using errcode = '42501';
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.set_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO ''
  AS $function$
begin
  new.updated_at := now();
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.user_can_access_document (
  doc_id uuid
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select exists (
    select 1
    from public.material ma
    join public.module mo on mo.id = ma.module_id
    where ma.document_id = doc_id
      and mo.owner_id = (select auth.uid())
  );
$function$;

ALTER TABLE "public"."chunk"
  ADD CONSTRAINT "fk_chunk_document" FOREIGN KEY (document_id) REFERENCES public.document(id) ON DELETE CASCADE;

ALTER TABLE "public"."flashcard"
  ADD CONSTRAINT "fk_flashcard_chunk" FOREIGN KEY (chunk_id) REFERENCES public.chunk(id) ON DELETE CASCADE;

ALTER TABLE "public"."card_review"
  ADD CONSTRAINT "fk_card_review_flashcard" FOREIGN KEY (flashcard_id) REFERENCES public.flashcard(id) ON DELETE CASCADE;

ALTER TABLE "public"."card_state"
  ADD CONSTRAINT "fk_card_state_flashcard" FOREIGN KEY (flashcard_id) REFERENCES public.flashcard(id) ON DELETE CASCADE;

ALTER TABLE "public"."material"
  ADD CONSTRAINT "fk_material_document" FOREIGN KEY (document_id) REFERENCES public.document(id) ON DELETE RESTRICT;

ALTER TABLE "public"."material"
  ADD CONSTRAINT "fk_material_module" FOREIGN KEY (module_id) REFERENCES public.module(id) ON DELETE CASCADE;

ALTER TABLE "public"."profile"
  ADD CONSTRAINT "fk_profile_user" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE "public"."card_state"
  ADD CONSTRAINT "fk_card_state_user" FOREIGN KEY (user_id) REFERENCES public.profile(id) ON DELETE CASCADE;

ALTER TABLE "public"."module"
  ADD CONSTRAINT "fk_module_owner" FOREIGN KEY (owner_id) REFERENCES public.profile(id) ON DELETE CASCADE;

ALTER TABLE "public"."quiz_question"
  ADD CONSTRAINT "fk_quiz_question_chunk" FOREIGN KEY (chunk_id) REFERENCES public.chunk(id) ON DELETE CASCADE;

ALTER TABLE "public"."quiz_answer"
  ADD CONSTRAINT "fk_quiz_answer_question" FOREIGN KEY (question_id) REFERENCES public.quiz_question(id) ON DELETE CASCADE;

ALTER TABLE "public"."study_session"
  ADD CONSTRAINT "fk_study_session_module" FOREIGN KEY (module_id) REFERENCES public.module(id) ON DELETE CASCADE;

ALTER TABLE "public"."study_session"
  ADD CONSTRAINT "fk_study_session_user" FOREIGN KEY (user_id) REFERENCES public.profile(id) ON DELETE CASCADE;

ALTER TABLE "public"."card_review"
  ADD CONSTRAINT "fk_card_review_session" FOREIGN KEY (session_id) REFERENCES public.study_session(id) ON DELETE CASCADE;

ALTER TABLE "public"."quiz_answer"
  ADD CONSTRAINT "fk_quiz_answer_session" FOREIGN KEY (session_id) REFERENCES public.study_session(id) ON DELETE CASCADE;

ALTER TABLE "public"."xp_event"
  ADD CONSTRAINT "fk_xp_event_session" FOREIGN KEY (session_id) REFERENCES public.study_session(id) ON DELETE SET NULL;

ALTER TABLE "public"."xp_event"
  ADD CONSTRAINT "fk_xp_event_user" FOREIGN KEY (user_id) REFERENCES public.profile(id) ON DELETE CASCADE;

CREATE INDEX idx_card_review_flashcard_id ON public.card_review USING btree (flashcard_id);

CREATE INDEX idx_card_review_session_id ON public.card_review USING btree (session_id);

CREATE INDEX idx_card_state_flashcard_id ON public.card_state USING btree (flashcard_id);

CREATE INDEX idx_card_state_user_due ON public.card_state USING btree (user_id, due_at);

CREATE INDEX idx_document_queue ON public.document USING btree (status, locked_at)
  WHERE (status = ANY (ARRAY['pending'::text, 'processing'::text]));

CREATE INDEX idx_flashcard_chunk_id_active ON public.flashcard USING btree (chunk_id)
  WHERE (deleted_at IS NULL);

CREATE INDEX idx_material_document_id ON public.material USING btree (document_id);

CREATE INDEX idx_module_owner_id ON public.module USING btree (owner_id);

CREATE INDEX idx_quiz_answer_question_id ON public.quiz_answer USING btree (question_id);

CREATE INDEX idx_quiz_answer_session_id ON public.quiz_answer USING btree (session_id);

CREATE INDEX idx_quiz_question_chunk_id_active ON public.quiz_question USING btree (chunk_id)
  WHERE (deleted_at IS NULL);

CREATE INDEX idx_study_session_module_id ON public.study_session USING btree (module_id);

CREATE INDEX idx_study_session_user_started ON public.study_session USING btree (user_id, started_at DESC);

CREATE INDEX idx_xp_event_session_id ON public.xp_event USING btree (session_id);

CREATE INDEX idx_xp_event_user_created ON public.xp_event USING btree (user_id, created_at DESC);

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER trg_card_state_set_updated_at
  BEFORE UPDATE ON public.card_state
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_chunk_set_updated_at
  BEFORE UPDATE ON public.chunk
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_document_set_updated_at
  BEFORE UPDATE ON public.document
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_flashcard_set_updated_at
  BEFORE UPDATE ON public.flashcard
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_module_set_updated_at
  BEFORE UPDATE ON public.module
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_profile_protect_stats
  BEFORE UPDATE ON public.profile
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_profile_stats();

CREATE TRIGGER trg_profile_set_updated_at
  BEFORE UPDATE ON public.profile
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_quiz_question_set_updated_at
  BEFORE UPDATE ON public.quiz_question
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE POLICY "card_review: delete via own session" ON "public"."card_review"
  FOR DELETE
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.study_session s
  WHERE ((s.id = card_review.session_id) AND (s.user_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "card_review: insert into own session" ON "public"."card_review"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (((EXISTS ( SELECT 1
   FROM public.study_session s
  WHERE ((s.id = card_review.session_id) AND (s.user_id = ( SELECT auth.uid() AS uid))))) AND (EXISTS ( SELECT 1
   FROM (public.flashcard f
     JOIN public.chunk c ON ((c.id = f.chunk_id)))
  WHERE ((f.id = card_review.flashcard_id) AND public.user_can_access_document(c.document_id))))));

CREATE POLICY "card_review: select via own session" ON "public"."card_review"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.study_session s
  WHERE ((s.id = card_review.session_id) AND (s.user_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "card_state: delete own" ON "public"."card_state"
  FOR DELETE
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = user_id));

CREATE POLICY "card_state: insert own" ON "public"."card_state"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));

CREATE POLICY "card_state: select own" ON "public"."card_state"
  FOR SELECT
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = user_id));

CREATE POLICY "card_state: update own" ON "public"."card_state"
  FOR UPDATE
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = user_id))
  WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));

CREATE POLICY "chunk: select via document" ON "public"."chunk"
  FOR SELECT
  TO "authenticated"
  USING (public.user_can_access_document(document_id));

CREATE POLICY "document: select via material" ON "public"."document"
  FOR SELECT
  TO "authenticated"
  USING (public.user_can_access_document(id));

CREATE POLICY "flashcard: select via document" ON "public"."flashcard"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.chunk c
  WHERE ((c.id = flashcard.chunk_id) AND public.user_can_access_document(c.document_id)))));

CREATE POLICY "material: delete via own module" ON "public"."material"
  FOR DELETE
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.module m
  WHERE ((m.id = material.module_id) AND (m.owner_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "material: insert into own module" ON "public"."material"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((EXISTS ( SELECT 1
   FROM public.module m
  WHERE ((m.id = material.module_id) AND (m.owner_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "material: select via own module" ON "public"."material"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.module m
  WHERE ((m.id = material.module_id) AND (m.owner_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "material: update via own module" ON "public"."material"
  FOR UPDATE
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.module m
  WHERE ((m.id = material.module_id) AND (m.owner_id = ( SELECT auth.uid() AS uid))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM public.module m
  WHERE ((m.id = material.module_id) AND (m.owner_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "module: delete own" ON "public"."module"
  FOR DELETE
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = owner_id));

CREATE POLICY "module: insert own" ON "public"."module"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((( SELECT auth.uid() AS uid) = owner_id));

CREATE POLICY "module: select own" ON "public"."module"
  FOR SELECT
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = owner_id));

CREATE POLICY "module: update own" ON "public"."module"
  FOR UPDATE
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = owner_id))
  WITH CHECK ((( SELECT auth.uid() AS uid) = owner_id));

CREATE POLICY "profile: select own" ON "public"."profile"
  FOR SELECT
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = id));

CREATE POLICY "profile: update own" ON "public"."profile"
  FOR UPDATE
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = id))
  WITH CHECK ((( SELECT auth.uid() AS uid) = id));

CREATE POLICY "quiz_answer: delete via own session" ON "public"."quiz_answer"
  FOR DELETE
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.study_session s
  WHERE ((s.id = quiz_answer.session_id) AND (s.user_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "quiz_answer: insert into own session" ON "public"."quiz_answer"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (((EXISTS ( SELECT 1
   FROM public.study_session s
  WHERE ((s.id = quiz_answer.session_id) AND (s.user_id = ( SELECT auth.uid() AS uid))))) AND (EXISTS ( SELECT 1
   FROM (public.quiz_question q
     JOIN public.chunk c ON ((c.id = q.chunk_id)))
  WHERE ((q.id = quiz_answer.question_id) AND public.user_can_access_document(c.document_id))))));

CREATE POLICY "quiz_answer: select via own session" ON "public"."quiz_answer"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.study_session s
  WHERE ((s.id = quiz_answer.session_id) AND (s.user_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "quiz_question: select via document" ON "public"."quiz_question"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.chunk c
  WHERE ((c.id = quiz_question.chunk_id) AND public.user_can_access_document(c.document_id)))));

CREATE POLICY "study_session: delete own" ON "public"."study_session"
  FOR DELETE
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = user_id));

CREATE POLICY "study_session: insert own in own module" ON "public"."study_session"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (((( SELECT auth.uid() AS uid) = user_id) AND (EXISTS ( SELECT 1
   FROM public.module m
  WHERE ((m.id = study_session.module_id) AND (m.owner_id = ( SELECT auth.uid() AS uid)))))));

CREATE POLICY "study_session: select own" ON "public"."study_session"
  FOR SELECT
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = user_id));

CREATE POLICY "study_session: update own" ON "public"."study_session"
  FOR UPDATE
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = user_id))
  WITH CHECK (((( SELECT auth.uid() AS uid) = user_id) AND (EXISTS ( SELECT 1
   FROM public.module m
  WHERE ((m.id = study_session.module_id) AND (m.owner_id = ( SELECT auth.uid() AS uid)))))));

CREATE POLICY "xp_event: select own" ON "public"."xp_event"
  FOR SELECT
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = user_id));

COMMENT ON COLUMN "public"."card_state"."due_at" IS 'When the card is next due for review.';

COMMENT ON COLUMN "public"."chunk"."position" IS '0-based order of the chunk within its document.';

COMMENT ON COLUMN "public"."chunk"."source_ref" IS 'Human-readable source location, e.g. "p. 12".';

COMMENT ON COLUMN "public"."chunk"."status" IS 'Generation status for this chunk.';

COMMENT ON COLUMN "public"."document"."attempts" IS 'Number of processing attempts by the worker.';

COMMENT ON COLUMN "public"."document"."file_hash" IS 'Content hash (e.g. SHA-256 hex) used for deduplication.';

COMMENT ON COLUMN "public"."document"."file_path" IS 'Object path in Supabase Storage.';

COMMENT ON COLUMN "public"."document"."locked_at" IS 'Worker lease timestamp; stale leases may be re-claimed.';

COMMENT ON COLUMN "public"."flashcard"."deleted_at" IS 'Soft delete; null = active.';

COMMENT ON COLUMN "public"."flashcard"."edited" IS 'True once the card was changed after generation.';

COMMENT ON COLUMN "public"."material"."title" IS 'User-facing title; defaults to the file name in the app.';

COMMENT ON COLUMN "public"."module"."course_id" IS 'Reserved for the shared course catalogue (Phase 2); no FK yet.';

COMMENT ON COLUMN "public"."profile"."last_study_date" IS 'Local date (profile.timezone) of the last study activity; drives streaks.';

COMMENT ON COLUMN "public"."profile"."timezone" IS 'IANA timezone used for streak day boundaries.';

COMMENT ON COLUMN "public"."profile"."xp_total" IS 'Cached sum of xp_event.amount. Server-managed.';

COMMENT ON COLUMN "public"."quiz_question"."correct_index" IS '0-based index into options.';

COMMENT ON COLUMN "public"."quiz_question"."deleted_at" IS 'Soft delete; null = active.';

COMMENT ON COLUMN "public"."quiz_question"."options" IS 'JSON array of answer option strings.';

COMMENT ON COLUMN "public"."xp_event"."session_id" IS 'Session that earned the XP, if any. Kept as null if the session is deleted.';

COMMENT ON FUNCTION "public"."handle_new_user"() IS 'Trigger on auth.users: inserts the matching profile row.';

COMMENT ON FUNCTION "public"."protect_profile_stats"() IS 'Blocks client-side changes to XP/streak columns.';

COMMENT ON FUNCTION "public"."set_updated_at"() IS 'BEFORE UPDATE trigger: sets updated_at = now().';

COMMENT ON FUNCTION "public"."user_can_access_document"(uuid) IS 'True if the calling user has this document attached to one of their modules.';

COMMENT ON TABLE "public"."card_review" IS 'A single flashcard review within a session (append-only).';

COMMENT ON TABLE "public"."card_state" IS 'Per-user spaced-repetition state for one flashcard.';

COMMENT ON TABLE "public"."chunk" IS 'Text segment of a document; unit of flashcard/quiz generation.';

COMMENT ON TABLE "public"."document" IS 'Uploaded source file, shared by all users who upload the same content (dedup by file_hash).';

COMMENT ON TABLE "public"."flashcard" IS 'Generated flashcard. Shared by all users of the underlying document.';

COMMENT ON TABLE "public"."material" IS 'Attaches a (shared) document to a user''s module. Grants the user read access to the document''s content.';

COMMENT ON TABLE "public"."module" IS 'A study module owned by one user.';

COMMENT ON TABLE "public"."profile" IS 'Per-user profile and gamification stats. 1:1 with auth.users.';

COMMENT ON TABLE "public"."quiz_answer" IS 'A single quiz answer within a session (append-only).';

COMMENT ON TABLE "public"."quiz_question" IS 'Generated multiple-choice question. Shared by all users of the underlying document.';

COMMENT ON TABLE "public"."study_session" IS 'One flashcard or quiz session of a user within a module.';

COMMENT ON TABLE "public"."xp_event" IS 'Append-only XP ledger. Written by the server only; profile.xp_total caches the sum.';

GRANT EXECUTE ON FUNCTION "public"."handle_new_user"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."protect_profile_stats"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."set_updated_at"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ON FUNCTION "public"."user_can_access_document"(uuid) FROM PUBLIC;

REVOKE ALL ON FUNCTION "public"."user_can_access_document"(uuid) FROM "anon";

GRANT EXECUTE ON FUNCTION "public"."user_can_access_document"(uuid) TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."card_review" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."card_state" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."chunk" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."document" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."flashcard" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."material" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."module" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."profile" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."quiz_answer" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."quiz_question" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."study_session" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."xp_event" TO "anon", "authenticated", "postgres", "service_role";
