-- =============================================================================
-- 50_study_sessions.sql
-- Study sessions, the individual reviews/answers inside them, and the XP
-- ledger.
-- Related: profile, module, flashcard, quiz_question.
-- =============================================================================

create table public.study_session (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null,
  module_id   uuid        not null,
  type        text        not null,
  started_at  timestamptz not null default now(),
  finished_at timestamptz,
  completed   boolean     not null default false,

  constraint fk_study_session_user
    foreign key (user_id) references public.profile (id) on delete cascade,
  constraint fk_study_session_module
    foreign key (module_id) references public.module (id) on delete cascade,
  constraint chk_study_session_type check (type in ('flashcards', 'quiz')),
  constraint chk_study_session_finished_after_start
    check (finished_at is null or finished_at >= started_at)
);

create index idx_study_session_user_started on public.study_session (user_id, started_at desc);
create index idx_study_session_module_id on public.study_session (module_id);

comment on table public.study_session is 'One flashcard or quiz session of a user within a module.';

-- -----------------------------------------------------------------------------

create table public.card_review (
  id           uuid        primary key default gen_random_uuid(),
  session_id   uuid        not null,
  flashcard_id uuid        not null,
  knew         boolean     not null,
  reviewed_at  timestamptz not null default now(),

  constraint fk_card_review_session
    foreign key (session_id) references public.study_session (id) on delete cascade,
  constraint fk_card_review_flashcard
    foreign key (flashcard_id) references public.flashcard (id) on delete cascade
);

create index idx_card_review_session_id on public.card_review (session_id);
create index idx_card_review_flashcard_id on public.card_review (flashcard_id);

comment on table public.card_review is 'A single flashcard review within a session (append-only).';

-- -----------------------------------------------------------------------------

create table public.quiz_answer (
  id           uuid        primary key default gen_random_uuid(),
  session_id   uuid        not null,
  question_id  uuid        not null,
  chosen_index smallint    not null,
  is_correct   boolean     not null,
  answered_at  timestamptz not null default now(),

  constraint fk_quiz_answer_session
    foreign key (session_id) references public.study_session (id) on delete cascade,
  constraint fk_quiz_answer_question
    foreign key (question_id) references public.quiz_question (id) on delete cascade,
  constraint chk_quiz_answer_chosen_index check (chosen_index >= 0)
);

create index idx_quiz_answer_session_id on public.quiz_answer (session_id);
create index idx_quiz_answer_question_id on public.quiz_answer (question_id);

comment on table public.quiz_answer is 'A single quiz answer within a session (append-only).';

-- -----------------------------------------------------------------------------

create table public.xp_event (
  id         uuid        primary key default gen_random_uuid(),
  user_id    uuid        not null,
  session_id uuid,
  amount     integer     not null,
  reason     text        not null,
  created_at timestamptz not null default now(),

  constraint fk_xp_event_user
    foreign key (user_id) references public.profile (id) on delete cascade,
  constraint fk_xp_event_session
    foreign key (session_id) references public.study_session (id) on delete set null,
  constraint chk_xp_event_amount_nonzero check (amount <> 0),
  constraint chk_xp_event_reason
    check (reason in ('session_completed', 'card_reviewed', 'quiz_correct', 'streak_bonus'))
);

create index idx_xp_event_user_created on public.xp_event (user_id, created_at desc);
create index idx_xp_event_session_id on public.xp_event (session_id);

comment on table  public.xp_event is 'Append-only XP ledger. Written by the server only; profile.xp_total caches the sum.';
comment on column public.xp_event.session_id is 'Session that earned the XP, if any. Kept as null if the session is deleted.';
