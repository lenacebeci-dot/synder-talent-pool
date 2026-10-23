-- ============================================================
-- Talent pool: database, storage and security rules (Supabase)
-- Run this once in Supabase → SQL Editor → New query → Run
-- ============================================================

-- 1. Candidates table ----------------------------------------
create table if not exists public.candidates (
  id                 uuid primary key default gen_random_uuid(),
  created_at         timestamptz not null default now(),

  -- filled in by the candidate
  full_name          text not null check (char_length(full_name) between 2 and 200),
  email              text not null check (char_length(email) <= 320),
  phone              text check (char_length(phone) <= 50),
  location           text check (char_length(location) <= 200),
  linkedin_url       text check (char_length(linkedin_url) <= 500),
  portfolio_url      text check (char_length(portfolio_url) <= 500),
  role_area          text not null check (char_length(role_area) <= 100),
  seniority          text check (char_length(seniority) <= 50),
  work_setup         text check (char_length(work_setup) <= 50),
  availability       text check (char_length(availability) <= 50),
  motivation         text check (char_length(motivation) <= 3000),
  cv_path            text check (char_length(cv_path) <= 500),

  -- consent (GDPR)
  consent_given      boolean not null default false,
  consent_at         timestamptz,
  consent_expires_at timestamptz,

  -- filled in by you
  status             text not null default 'New'
                     check (status in ('New','Reviewed','Contacted','Interviewing','Not a fit','Hired')),
  tags               text[] not null default '{}',
  rating             smallint check (rating between 1 and 3),
  notes              text,
  last_contacted_at  timestamptz
);

create index if not exists candidates_created_at_idx on public.candidates (created_at desc);
create index if not exists candidates_email_idx on public.candidates (email);

-- 1b. Extra questions (safe to re-run; adds columns if you ran an older version)
alter table public.candidates add column if not exists experience_domains text[] not null default '{}';
alter table public.candidates add column if not exists english_level      text check (char_length(english_level) <= 50);
alter table public.candidates add column if not exists employment_type    text check (char_length(employment_type) <= 50);
alter table public.candidates add column if not exists salary_expectation text check (char_length(salary_expectation) <= 100);
alter table public.candidates add column if not exists referral_source    text check (char_length(referral_source) <= 100);
alter table public.candidates add column if not exists proud_of           text check (char_length(proud_of) <= 3000);

-- 2. Admins ----------------------------------------------------
-- Only users listed here can see candidates. Add yourself after creating
-- your login (see README, step 3).
create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade
);
alter table public.admins enable row level security;  -- no policies: invisible via the API

create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- 3. Normalise every new submission ----------------------------
-- Candidates can't set their own status, rating, notes or consent dates.
-- Change '24 months' here if you change RETENTION_MONTHS in config.js.
create or replace function public.candidates_before_insert()
returns trigger language plpgsql
as $$
begin
  new.created_at         := now();
  new.email              := lower(trim(new.email));
  new.consent_at         := now();
  new.consent_expires_at := now() + interval '24 months';
  new.status             := 'New';
  new.tags               := '{}';
  new.rating             := null;
  new.notes              := null;
  new.last_contacted_at  := null;
  return new;
end;
$$;

drop trigger if exists candidates_before_insert on public.candidates;
create trigger candidates_before_insert
  before insert on public.candidates
  for each row execute function public.candidates_before_insert();

-- 4. Row-level security ----------------------------------------
alter table public.candidates enable row level security;

grant insert on public.candidates to anon, authenticated;
grant select, update, delete on public.candidates to authenticated;

drop policy if exists "Anyone can submit with consent" on public.candidates;
create policy "Anyone can submit with consent" on public.candidates
  for insert to anon, authenticated
  with check (consent_given = true);

drop policy if exists "Admins can read" on public.candidates;
create policy "Admins can read" on public.candidates
  for select to authenticated using (public.is_admin());

drop policy if exists "Admins can update" on public.candidates;
create policy "Admins can update" on public.candidates
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Admins can delete" on public.candidates;
create policy "Admins can delete" on public.candidates
  for delete to authenticated using (public.is_admin());

-- 5. Private CV storage ----------------------------------------
-- Private bucket, 10 MB limit, PDF / Word only.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'cvs', 'cvs', false, 10485760,
  array[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
)
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Anyone can upload a CV" on storage.objects;
create policy "Anyone can upload a CV" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'cvs');

drop policy if exists "Admins can read CVs" on storage.objects;
create policy "Admins can read CVs" on storage.objects
  for select to authenticated
  using (bucket_id = 'cvs' and public.is_admin());

drop policy if exists "Admins can delete CVs" on storage.objects;
create policy "Admins can delete CVs" on storage.objects
  for delete to authenticated
  using (bucket_id = 'cvs' and public.is_admin());
