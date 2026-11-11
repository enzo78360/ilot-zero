-- Matchmaking : salons publics (« Partie rapide »)
create table public.mm_lobbies (
  code text primary key check (code ~ '^[A-Z0-9]{4}$'),
  host uuid not null unique default auth.uid() references auth.users(id) on delete cascade,
  game text not null check (game in ('br','zombie')),
  mode text not null check (mode in ('solo','duo','escouade')),
  players int not null default 1 check (players between 1 and 8),
  updated_at timestamptz not null default now()
);
alter table public.mm_lobbies enable row level security;
create policy mm_select on public.mm_lobbies for select to authenticated using (true);
create policy mm_insert on public.mm_lobbies for insert to authenticated with check (host = (select auth.uid()));
create policy mm_update on public.mm_lobbies for update to authenticated using (host = (select auth.uid())) with check (host = (select auth.uid()));
create policy mm_delete on public.mm_lobbies for delete to authenticated using (host = (select auth.uid()));
create index mm_lobbies_find on public.mm_lobbies (game, mode, updated_at);
revoke all on public.mm_lobbies from anon;
grant select, insert, update, delete on public.mm_lobbies to authenticated;

create or replace function public.mm_find(p_game text, p_mode text, p_exclude text[] default '{}')
returns table(code text, players int)
language sql stable security invoker set search_path = ''
as $$
  select l.code, l.players from public.mm_lobbies l
  where l.game = p_game and l.mode = p_mode and l.players < 8
    and l.updated_at > now() - interval '15 seconds'
    and l.host <> (select auth.uid())
    and not (l.code = any(coalesce(p_exclude, '{}')))
  order by l.players desc, l.updated_at asc
  limit 1;
$$;
revoke execute on function public.mm_find(text,text,text[]) from public, anon;
grant execute on function public.mm_find(text,text,text[]) to authenticated;
