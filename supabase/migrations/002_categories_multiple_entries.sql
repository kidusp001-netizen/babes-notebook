-- Allow multiple journal entries per day + category tags.
-- Run in Supabase SQL Editor after 001_journal_entries.sql.

alter table public.journal_entries
  drop constraint if exists journal_entries_user_id_entry_date_key;

alter table public.journal_entries
  add column if not exists category text not null default 'reflection'
  check (category in ('gratitude', 'prayer', 'reflection'));

create index if not exists journal_entries_user_date_updated_idx
  on public.journal_entries (user_id, entry_date desc, updated_at desc);
