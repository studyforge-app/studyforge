-- =============================================================================
-- 20_documents.sql
-- Uploaded files (deduplicated across users by content hash) and the text
-- chunks the worker extracts from them.
-- Related: material (user → document link), flashcard, quiz_question.
-- =============================================================================

create table public.document (
  id            uuid        primary key default gen_random_uuid(),
  file_hash     text        not null,
  file_path     text        not null,
  file_type     text        not null,
  page_count    integer,
  status        text        not null default 'pending',
  locked_at     timestamptz,
  attempts      integer     not null default 0,
  error_message text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  constraint uq_document_file_hash      unique (file_hash),
  constraint chk_document_status        check (status in ('pending', 'processing', 'ready', 'failed')),
  constraint chk_document_page_count    check (page_count >= 0),
  constraint chk_document_attempts      check (attempts >= 0)
);

-- Worker queue: pick up pending work and expired leases.
create index idx_document_queue
  on public.document (status, locked_at)
  where status in ('pending', 'processing');

create trigger trg_document_set_updated_at
  before update on public.document
  for each row execute function public.set_updated_at();

comment on table  public.document is 'Uploaded source file, shared by all users who upload the same content (dedup by file_hash).';
comment on column public.document.file_hash is 'Content hash (e.g. SHA-256 hex) used for deduplication.';
comment on column public.document.file_path is 'Object path in Supabase Storage.';
comment on column public.document.locked_at is 'Worker lease timestamp; stale leases may be re-claimed.';
comment on column public.document.attempts is 'Number of processing attempts by the worker.';

-- -----------------------------------------------------------------------------

create table public.chunk (
  id          uuid        primary key default gen_random_uuid(),
  document_id uuid        not null,
  position    integer     not null,
  source_ref  text,
  text        text        not null,
  status      text        not null default 'pending',
  attempts    integer     not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  constraint fk_chunk_document
    foreign key (document_id) references public.document (id) on delete cascade,
  constraint uq_chunk_document_position unique (document_id, position),
  constraint chk_chunk_position   check (position >= 0),
  constraint chk_chunk_status     check (status in ('pending', 'processing', 'done', 'failed')),
  constraint chk_chunk_attempts   check (attempts >= 0)
);

-- uq_chunk_document_position already covers lookups by document_id.

create trigger trg_chunk_set_updated_at
  before update on public.chunk
  for each row execute function public.set_updated_at();

comment on table  public.chunk is 'Text segment of a document; unit of flashcard/quiz generation.';
comment on column public.chunk.position is '0-based order of the chunk within its document.';
comment on column public.chunk.source_ref is 'Human-readable source location, e.g. "p. 12".';
comment on column public.chunk.status is 'Generation status for this chunk.';
