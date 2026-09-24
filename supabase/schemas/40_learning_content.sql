-- =============================================================================
-- 40_learning_content.sql
-- Generated learning content (flashcards, quiz questions) per chunk, and each
-- user's spaced-repetition state per flashcard.
-- Related: chunk, profile, card_review, quiz_answer.
-- =============================================================================

create table public.flashcard (
  id         uuid        primary key default gen_random_uuid(),
  chunk_id   uuid        not null,
  front      text        not null,
  back       text        not null,
  source_ref text,
  edited     boolean     not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint fk_flashcard_chunk
    foreign key (chunk_id) references public.chunk (id) on delete cascade
);

create index idx_flashcard_chunk_id_active
  on public.flashcard (chunk_id)
  where deleted_at is null;

create trigger trg_flashcard_set_updated_at
  before update on public.flashcard
  for each row execute function public.set_updated_at();

comment on table  public.flashcard is 'Generated flashcard. Shared by all users of the underlying document.';
comment on column public.flashcard.edited is 'True once the card was changed after generation.';
comment on column public.flashcard.deleted_at is 'Soft delete; null = active.';

-- -----------------------------------------------------------------------------

create table public.quiz_question (
  id            uuid        primary key default gen_random_uuid(),
  chunk_id      uuid        not null,
  question      text        not null,
  options       jsonb       not null,
  correct_index smallint    not null,
  explanation   text,
  source_ref    text,
  deleted_at    timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  constraint fk_quiz_question_chunk
    foreign key (chunk_id) references public.chunk (id) on delete cascade,
  constraint chk_quiz_question_options_array check (jsonb_typeof(options) = 'array'),
  constraint chk_quiz_question_correct_index
    check (correct_index >= 0 and correct_index < jsonb_array_length(options))
);

create index idx_quiz_question_chunk_id_active
  on public.quiz_question (chunk_id)
  where deleted_at is null;

create trigger trg_quiz_question_set_updated_at
  before update on public.quiz_question
  for each row execute function public.set_updated_at();

comment on table  public.quiz_question is 'Generated multiple-choice question. Shared by all users of the underlying document.';
comment on column public.quiz_question.options is 'JSON array of answer option strings.';
comment on column public.quiz_question.correct_index is '0-based index into options.';
comment on column public.quiz_question.deleted_at is 'Soft delete; null = active.';

-- -----------------------------------------------------------------------------

create table public.card_state (
  user_id      uuid        not null,
  flashcard_id uuid        not null,
  last_result  text,
  due_at       timestamptz not null default now(),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint pk_card_state primary key (user_id, flashcard_id),
  constraint fk_card_state_user
    foreign key (user_id) references public.profile (id) on delete cascade,
  constraint fk_card_state_flashcard
    foreign key (flashcard_id) references public.flashcard (id) on delete cascade,
  constraint chk_card_state_last_result check (last_result in ('knew', 'didnt_know'))
);

-- "Which cards are due for me?"
create index idx_card_state_user_due on public.card_state (user_id, due_at);
create index idx_card_state_flashcard_id on public.card_state (flashcard_id);

create trigger trg_card_state_set_updated_at
  before update on public.card_state
  for each row execute function public.set_updated_at();

comment on table  public.card_state is 'Per-user spaced-repetition state for one flashcard.';
comment on column public.card_state.due_at is 'When the card is next due for review.';
