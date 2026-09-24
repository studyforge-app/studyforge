-- =============================================================================
-- 30_modules.sql
-- A user's study modules (e.g. one per university course) and the materials
-- (documents) attached to them.
-- Related: profile (owner), document, study_session.
-- =============================================================================

create table public.module (
  id         uuid        primary key default gen_random_uuid(),
  owner_id   uuid        not null,
  course_id  uuid,
  name       text        not null,
  exam_date  date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint fk_module_owner
    foreign key (owner_id) references public.profile (id) on delete cascade,
  constraint chk_module_name_not_empty check (length(trim(name)) > 0)
);

create index idx_module_owner_id on public.module (owner_id);

create trigger trg_module_set_updated_at
  before update on public.module
  for each row execute function public.set_updated_at();

comment on table  public.module is 'A study module owned by one user.';
comment on column public.module.course_id is 'Reserved for the shared course catalogue (Phase 2); no FK yet.';

-- -----------------------------------------------------------------------------

create table public.material (
  id          uuid        primary key default gen_random_uuid(),
  module_id   uuid        not null,
  document_id uuid        not null,
  title       text,
  created_at  timestamptz not null default now(),

  constraint fk_material_module
    foreign key (module_id) references public.module (id) on delete cascade,
  constraint fk_material_document
    foreign key (document_id) references public.document (id) on delete restrict,
  constraint uq_material_module_document unique (module_id, document_id)
);

-- uq_material_module_document covers lookups by module_id.
create index idx_material_document_id on public.material (document_id);

comment on table  public.material is 'Attaches a (shared) document to a user''s module. Grants the user read access to the document''s content.';
comment on column public.material.title is 'User-facing title; defaults to the file name in the app.';
