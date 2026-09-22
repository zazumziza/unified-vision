create extension if not exists pgcrypto;
create extension if not exists citext;
create extension if not exists pg_trgm;

do $$ begin create type public.artist_claim_status as enum ('UNCLAIMED','CLAIM_PENDING','VERIFIED','APPROVED','SUSPENDED','REVOKED','DISPUTED'); exception when duplicate_object then null; end $$;
do $$ begin create type public.entity_match_confidence as enum ('HIGH','MEDIUM','LOW','UNRESOLVED'); exception when duplicate_object then null; end $$;
do $$ begin create type public.publish_status as enum ('DRAFT','PUBLISHED','ARCHIVED'); exception when duplicate_object then null; end $$;
do $$ begin create type public.payment_status as enum ('PENDING','PAID','FAILED','REFUNDED','CHARGEBACK','CANCELLED'); exception when duplicate_object then null; end $$;
do $$ begin create type public.source_kind as enum ('RSS','ATOM','WEB','EDITORIAL','ARTIST','RIGHTS_HOLDER','EXTERNAL_MUSIC'); exception when duplicate_object then null; end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_url text,
  country_code char(2) default 'KE',
  city text,
  bio text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.profile_roles (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  role text not null,
  created_at timestamptz not null default now(),
  primary key (profile_id, role)
);

create table if not exists public.artist_identities (
  id uuid primary key default gen_random_uuid(),
  person_id uuid references public.profiles(id) on delete set null,
  stage_name citext not null,
  slug text unique,
  claim_status public.artist_claim_status not null default 'UNCLAIMED',
  claim_confidence public.entity_match_confidence not null default 'UNRESOLVED',
  bio text,
  country_code char(2) default 'KE',
  city text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.genres (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique
);

create table if not exists public.scenes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text,
  county text,
  country_code char(2) default 'KE',
  description text,
  unique(name, city, country_code)
);

create table if not exists public.works (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  isrc text,
  iswc text,
  canonical_status text not null default 'candidate',
  created_at timestamptz not null default now()
);

create table if not exists public.recordings (
  id uuid primary key default gen_random_uuid(),
  work_id uuid not null references public.works(id) on delete cascade,
  title text not null,
  duration_seconds integer,
  audio_source_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.releases (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.artist_identities(id) on delete cascade,
  title text not null,
  release_date date,
  catalog_number text,
  status public.publish_status not null default 'DRAFT',
  cover_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.tracks (
  id uuid primary key default gen_random_uuid(),
  release_id uuid references public.releases(id) on delete set null,
  recording_id uuid references public.recordings(id) on delete set null,
  artist_id uuid not null references public.artist_identities(id) on delete cascade,
  title text not null,
  track_number integer,
  status public.publish_status not null default 'DRAFT',
  preview_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.media_assets (
  id uuid primary key default gen_random_uuid(),
  owner_profile_id uuid references public.profiles(id) on delete set null,
  artist_id uuid references public.artist_identities(id) on delete set null,
  kind text not null,
  storage_path text not null,
  is_listed boolean not null default false,
  is_rights_locked boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.external_links (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid references public.artist_identities(id) on delete cascade,
  profile_id uuid references public.profiles(id) on delete cascade,
  service text not null,
  url text not null,
  is_official boolean not null default false,
  created_at timestamptz not null default now(),
  check (artist_id is not null or profile_id is not null)
);

create table if not exists public.venues (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text,
  county text,
  country_code char(2) default 'KE',
  address text
);

create table if not exists public.sources (
  id uuid primary key default gen_random_uuid(),
  kind public.source_kind not null,
  publisher text,
  url text not null,
  title text,
  published_at timestamptz,
  observed_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  organizer_profile_id uuid references public.profiles(id) on delete set null,
  venue_id uuid references public.venues(id) on delete set null,
  title text not null,
  starts_at timestamptz not null,
  ends_at timestamptz,
  city text,
  county text,
  country_code char(2) default 'KE',
  external_ticket_url text,
  status text not null default 'PUBLISHED',
  source_id uuid references public.sources(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.event_artists (
  event_id uuid not null references public.events(id) on delete cascade,
  artist_id uuid not null references public.artist_identities(id) on delete cascade,
  lineup_order integer,
  primary key (event_id, artist_id)
);

create table if not exists public.follows (
  follower_profile_id uuid not null references public.profiles(id) on delete cascade,
  artist_id uuid not null references public.artist_identities(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_profile_id, artist_id)
);

create table if not exists public.support_signals (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  artist_id uuid not null references public.artist_identities(id) on delete cascade,
  signal_type text not null,
  source_track_id uuid references public.tracks(id) on delete set null,
  occurred_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb
);

create table if not exists public.mentions (
  id uuid primary key default gen_random_uuid(),
  source_id uuid not null references public.sources(id) on delete cascade,
  raw_text text not null,
  entity_candidate text,
  artist_candidate_id uuid references public.artist_identities(id) on delete set null,
  match_confidence public.entity_match_confidence not null default 'UNRESOLVED',
  evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.observations (
  id uuid primary key default gen_random_uuid(),
  observation_type text not null,
  subject_type text not null,
  subject_id uuid,
  source_id uuid references public.sources(id) on delete set null,
  observed_at timestamptz not null default now(),
  payload jsonb not null default '{}'::jsonb
);

create table if not exists public.referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_profile_id uuid references public.profiles(id) on delete set null,
  recipient_profile_id uuid references public.profiles(id) on delete set null,
  artist_id uuid references public.artist_identities(id) on delete set null,
  track_id uuid references public.tracks(id) on delete set null,
  conversion_state text not null default 'OPENED',
  created_at timestamptz not null default now()
);

create table if not exists public.memberships (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  plan_code text not null default 'BT_MEMBER',
  status text not null default 'ACTIVE',
  started_at timestamptz not null default now(),
  ended_at timestamptz
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete set null,
  membership_id uuid references public.memberships(id) on delete set null,
  provider text not null default 'PESAPAL',
  provider_reference text,
  amount_minor bigint not null check (amount_minor >= 0),
  currency char(3) not null default 'KES',
  status public.payment_status not null default 'PENDING',
  created_at timestamptz not null default now(),
  verified_at timestamptz
);

create table if not exists public.ledger_entries (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid references public.payments(id) on delete restrict,
  entry_type text not null,
  amount_minor bigint not null,
  currency char(3) not null default 'KES',
  owner_type text not null,
  owner_id uuid,
  evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.allocations (
  id uuid primary key default gen_random_uuid(),
  ledger_entry_id uuid not null references public.ledger_entries(id) on delete restrict,
  artist_id uuid not null references public.artist_identities(id) on delete restrict,
  amount_minor bigint not null check (amount_minor >= 0),
  algorithm_version text not null,
  signals_used jsonb not null default '[]'::jsonb,
  eligibility_rules jsonb not null default '{}'::jsonb,
  effective_at timestamptz not null default now()
);

create table if not exists public.claims (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.artist_identities(id) on delete cascade,
  claimant_profile_id uuid not null references public.profiles(id) on delete cascade,
  status public.artist_claim_status not null default 'CLAIM_PENDING',
  evidence jsonb not null default '{}'::jsonb,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.audit_events (
  id uuid primary key default gen_random_uuid(),
  actor_profile_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists artist_identities_stage_name_idx on public.artist_identities using gin (stage_name gin_trgm_ops);
create index if not exists tracks_artist_status_idx on public.tracks (artist_id, status);
create index if not exists events_starts_at_idx on public.events (starts_at);
create index if not exists support_signals_artist_time_idx on public.support_signals (artist_id, occurred_at desc);
create index if not exists observations_subject_time_idx on public.observations (subject_id, observed_at desc);
create index if not exists sources_published_idx on public.sources (published_at desc);

create or replace function public.current_profile_id() returns uuid language sql stable as $$ select auth.uid() $$;
create or replace function public.is_admin() returns boolean language sql stable as $$
  select exists (
    select 1 from public.profile_roles pr
    where pr.profile_id = auth.uid() and pr.role in ('admin','moderator')
  );
$$;
create or replace function public.owns_artist(target_artist uuid) returns boolean language sql stable as $$
  select exists (
    select 1 from public.artist_identities a
    where a.id = target_artist and a.person_id = auth.uid()
  );
$$;

alter table public.profiles enable row level security;
alter table public.profile_roles enable row level security;
alter table public.artist_identities enable row level security;
alter table public.genres enable row level security;
alter table public.scenes enable row level security;
alter table public.works enable row level security;
alter table public.recordings enable row level security;
alter table public.releases enable row level security;
alter table public.tracks enable row level security;
alter table public.media_assets enable row level security;
alter table public.external_links enable row level security;
alter table public.venues enable row level security;
alter table public.sources enable row level security;
alter table public.events enable row level security;
alter table public.event_artists enable row level security;
alter table public.follows enable row level security;
alter table public.support_signals enable row level security;
alter table public.mentions enable row level security;
alter table public.observations enable row level security;
alter table public.referrals enable row level security;
alter table public.memberships enable row level security;
alter table public.payments enable row level security;
alter table public.ledger_entries enable row level security;
alter table public.allocations enable row level security;
alter table public.claims enable row level security;
alter table public.audit_events enable row level security;

create policy "profiles_public_read" on public.profiles for select using (true);
create policy "profile_self_insert" on public.profiles for insert with check (id = auth.uid());
create policy "profile_self_update" on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());
create policy "roles_self_read" on public.profile_roles for select using (profile_id = auth.uid() or public.is_admin());

create policy "artist_public_read" on public.artist_identities for select using (
  claim_status in ('UNCLAIMED','VERIFIED','APPROVED') or person_id = auth.uid() or public.is_admin()
);
create policy "artist_owner_update" on public.artist_identities for update using (
  person_id = auth.uid() or public.is_admin()
) with check (person_id = auth.uid() or public.is_admin());

create policy "claims_self_insert" on public.claims for insert with check (claimant_profile_id = auth.uid());
create policy "claims_self_read" on public.claims for select using (claimant_profile_id = auth.uid() or public.is_admin());

create policy "genres_read" on public.genres for select using (true);
create policy "scenes_read" on public.scenes for select using (true);
create policy "works_read" on public.works for select using (true);
create policy "recordings_read" on public.recordings for select using (true);
create policy "venues_read" on public.venues for select using (true);
create policy "sources_read" on public.sources for select using (true);
create policy "mentions_read" on public.mentions for select using (true);
create policy "observations_read" on public.observations for select using (true);
create policy "events_read" on public.events for select using (true);
create policy "event_artists_read" on public.event_artists for select using (true);

create policy "releases_read" on public.releases for select using (
  status = 'PUBLISHED' or public.owns_artist(artist_id) or public.is_admin()
);
create policy "releases_owner_write" on public.releases for all using (
  public.owns_artist(artist_id) or public.is_admin()
) with check (public.owns_artist(artist_id) or public.is_admin());

create policy "tracks_read" on public.tracks for select using (
  status = 'PUBLISHED' or public.owns_artist(artist_id) or public.is_admin()
);
create policy "tracks_owner_write" on public.tracks for all using (
  public.owns_artist(artist_id) or public.is_admin()
) with check (public.owns_artist(artist_id) or public.is_admin());

create policy "media_listed_read" on public.media_assets for select using (
  (is_listed and not is_rights_locked) or owner_profile_id = auth.uid() or public.is_admin()
);
create policy "media_owner_insert" on public.media_assets for insert with check (
  owner_profile_id = auth.uid() or public.is_admin()
);
create policy "media_owner_update" on public.media_assets for update using (
  owner_profile_id = auth.uid() or public.is_admin()
) with check (owner_profile_id = auth.uid() or public.is_admin());

create policy "links_public_read" on public.external_links for select using (true);
create policy "links_owner_write" on public.external_links for all using (
  profile_id = auth.uid() or public.owns_artist(artist_id) or public.is_admin()
) with check (
  profile_id = auth.uid() or public.owns_artist(artist_id) or public.is_admin()
);

create policy "follows_self_read" on public.follows for select using (follower_profile_id = auth.uid());
create policy "follows_self_write" on public.follows for all using (follower_profile_id = auth.uid()) with check (follower_profile_id = auth.uid());

create policy "support_self_insert" on public.support_signals for insert with check (profile_id = auth.uid());
create policy "support_self_read" on public.support_signals for select using (profile_id = auth.uid() or public.is_admin());

create policy "referrals_participant_read" on public.referrals for select using (
  referrer_profile_id = auth.uid() or recipient_profile_id = auth.uid() or public.is_admin()
);
create policy "referrals_self_insert" on public.referrals for insert with check (referrer_profile_id = auth.uid());

create policy "membership_self_read" on public.memberships for select using (profile_id = auth.uid() or public.is_admin());
create policy "payments_self_read" on public.payments for select using (profile_id = auth.uid() or public.is_admin());
create policy "payments_server_write" on public.payments for all using (false) with check (false);
create policy "ledger_server_only" on public.ledger_entries for all using (false) with check (false);
create policy "allocations_server_only" on public.allocations for all using (false) with check (false);
create policy "audit_admin_read" on public.audit_events for select using (public.is_admin());
create policy "audit_server_insert" on public.audit_events for insert with check (false);

insert into public.genres (name, slug) values
  ('Gengetone','gengetone'), ('Genge','genge'), ('Afropop','afropop'), ('Hip Hop','hip-hop'),
  ('Dancehall','dancehall'), ('Gospel','gospel'), ('Ohangla','ohangla'), ('Benga','benga')
on conflict (slug) do nothing;

insert into public.scenes (name, city, county, country_code) values
  ('Nairobi Street Sound','Nairobi','Nairobi','KE'),
  ('Mombasa Coastal Wave','Mombasa','Mombasa','KE'),
  ('Kisumu Lakeside','Kisumu','Kisumu','KE')
on conflict do nothing;

insert into public.artist_identities (stage_name, slug, claim_status, claim_confidence, country_code, city)
values
  ('Toxic Lyrikali','toxic-lyrikali','UNCLAIMED','UNRESOLVED','KE','Nairobi'),
  ('Mbogi Genje','mbogi-genje','UNCLAIMED','UNRESOLVED','KE','Nairobi')
on conflict (slug) do nothing;
