-- ============================================
-- EventDesk database schema (Supabase / Postgres)
-- Run this in Supabase: SQL Editor > New query
-- ============================================

-- 1. Events being offered
create table events (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null,
  category text not null,
  event_date date not null,
  event_time text not null,
  venue text not null,
  seats_total integer not null,
  created_at timestamptz not null default now()
);

-- 2. Registrations against an event
create table registrations (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  name text not null,
  email text not null,
  phone text not null,
  roll_no text not null,
  created_at timestamptz not null default now()
);

-- Speeds up "how many people registered for this event" lookups
create index idx_registrations_event_id on registrations(event_id);

-- 3. View: live seat availability per event
-- Joins events with a count of their registrations, so the frontend
-- never has to compute seats-left itself.
create view event_availability as
select
  e.*,
  coalesce(r.registered_count, 0) as registered_count,
  e.seats_total - coalesce(r.registered_count, 0) as seats_left
from events e
left join (
  select event_id, count(*) as registered_count
  from registrations
  group by event_id
) r on r.event_id = e.id;

-- 4. Row Level Security
-- This is a public registration site: anyone can view events and register,
-- but no one can edit or delete through the anon key.
alter table events enable row level security;
alter table registrations enable row level security;

create policy "Public can view events"
  on events for select
  using (true);

create policy "Public can view registrations"
  on registrations for select
  using (true);

create policy "Public can register"
  on registrations for insert
  with check (true);

-- 5. Seed data — sample events for the demo
insert into events (name, description, category, event_date, event_time, venue, seats_total) values
('CodeSprint: 24-Hour Build', 'A day-long build sprint — form a team, ship a working prototype, demo it to judges.', 'Hackathon', '2026-10-18', '9:00 AM', 'TCET Innovation Lab', 60),
('UI/UX Design Jam', 'Hands-on workshop on wireframing and prototyping, ending with a mini design critique.', 'Workshop', '2026-10-05', '2:00 PM', 'Seminar Hall 2', 40),
('AI & ML Demo Day', 'Students showcase ML projects in five-minute lightning demos, open floor for Q&A.', 'Showcase', '2026-10-25', '11:00 AM', 'Main Auditorium', 100),
('Capture The Flag: CyberChase', 'Team-based CTF covering web, crypto, and forensics challenges.', 'Competition', '2026-11-02', '10:00 AM', 'Computer Lab 4', 50);
