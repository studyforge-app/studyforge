-- =============================================================================
-- 10_profile.sql
-- One profile row per auth user. Holds display data and gamification stats.
-- Related: auth.users (1:1), module, card_state, study_session, xp_event.
-- =============================================================================

create table public.profile (
  id              uuid        primary key,
  display_name    text,
  avatar_url      text,
  xp_total        integer     not null default 0,
  current_streak  integer     not null default 0,
  longest_streak  integer     not null default 0,
  last_study_date date,
  timezone        text        not null default 'Europe/Berlin',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  constraint fk_profile_user
    foreign key (id) references auth.users (id) on delete cascade,
  constraint chk_profile_xp_total_nonneg       check (xp_total >= 0),
  constraint chk_profile_current_streak_nonneg check (current_streak >= 0),
  constraint chk_profile_longest_streak_nonneg check (longest_streak >= 0)
);

-- Triggers --------------------------------------------------------------------

create trigger trg_profile_set_updated_at
  before update on public.profile
  for each row execute function public.set_updated_at();

-- Clients may edit their own profile (RLS), but not the gamification stats.
-- Those are written by the server/worker with the service_role key.
create or replace function public.protect_profile_stats()
returns trigger
language plpgsql
set search_path = ''
as $$
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
$$;

create trigger trg_profile_protect_stats
  before update on public.profile
  for each row execute function public.protect_profile_stats();

-- Creates the profile row when a user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profile (id, display_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data ->> 'display_name',
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Documentation ---------------------------------------------------------------

comment on table  public.profile is 'Per-user profile and gamification stats. 1:1 with auth.users.';
comment on column public.profile.xp_total is 'Cached sum of xp_event.amount. Server-managed.';
comment on column public.profile.last_study_date is 'Local date (profile.timezone) of the last study activity; drives streaks.';
comment on column public.profile.timezone is 'IANA timezone used for streak day boundaries.';
comment on function public.protect_profile_stats() is 'Blocks client-side changes to XP/streak columns.';
comment on function public.handle_new_user() is 'Trigger on auth.users: inserts the matching profile row.';
