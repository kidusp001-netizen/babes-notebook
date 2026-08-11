-- Babe's Notebook — Supabase schema
-- Run this in the Supabase SQL Editor for your project.

create table if not exists public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  entry_date date not null,
  content text not null default '',
  category text not null default 'reflection'
    check (category in ('gratitude', 'prayer', 'reflection')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists journal_entries_user_date_updated_idx
  on public.journal_entries (user_id, entry_date desc, updated_at desc);

alter table public.journal_entries enable row level security;

create policy "Users can view own entries"
  on public.journal_entries for select
  using (auth.uid() = user_id);

create policy "Users can insert own entries"
  on public.journal_entries for insert
  with check (auth.uid() = user_id);

create policy "Users can update own entries"
  on public.journal_entries for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own entries"
  on public.journal_entries for delete
  using (auth.uid() = user_id);

-- Keep updated_at in sync
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists journal_entries_updated_at on public.journal_entries;
create trigger journal_entries_updated_at
  before update on public.journal_entries
  for each row execute function public.set_updated_at();
