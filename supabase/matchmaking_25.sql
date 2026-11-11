-- Salons jusqu'à 25 joueurs (hôte compris)
alter table public.mm_lobbies drop constraint if exists mm_lobbies_players_check;
alter table public.mm_lobbies add constraint mm_lobbies_players_check check (players between 1 and 25);
create or replace function public.mm_find(p_game text, p_mode text, p_exclude text[] default '{}')
returns table(code text, players int)
language sql stable security invoker set search_path = ''
as $$
  select l.code, l.players from public.mm_lobbies l
  where l.game = p_game and l.mode = p_mode and l.players < 25
    and l.updated_at > now() - interval '15 seconds'
    and l.host <> (select auth.uid())
    and not (l.code = any(coalesce(p_exclude, '{}')))
  order by l.players desc, l.updated_at asc
  limit 1;
$$;
