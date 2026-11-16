-- Pouvoirs du staff (menu O) dans le salon de quelqu'un d'autre.
-- En entrant dans un salon, un membre du staff déclare à la base un jeton secret tiré au hasard (colonne peer), puis le donne
-- à l'hôte dans la connexion chiffrée entre eux. L'hôte demande ensuite à la base quels pouvoirs vont avec les jetons reçus :
-- un joueur ne peut pas se faire passer pour un membre du staff (il ne connaît pas son jeton).

create table if not exists private.staff_peers (
  peer text primary key check (char_length(peer) between 4 and 80),
  uid uuid not null references auth.users(id) on delete cascade,
  at timestamptz not null default now());
alter table private.staff_peers enable row level security;
create index if not exists staff_peers_uid on private.staff_peers(uid);

create or replace function public.staff_peer_claim(p_peer text) returns void
language plpgsql security definer set search_path to '' as $$
declare me uuid := (select auth.uid());
begin
  perform private.need(1);
  delete from private.staff_peers where uid = me or at < now() - interval '1 day';
  insert into private.staff_peers(peer, uid) values (p_peer, me)
    on conflict (peer) do update set uid = excluded.uid, at = now();
end; $$;

-- pour chaque identifiant reconnu : la liste des pouvoirs pw_* du membre du staff (["*"] pour le propriétaire)
create or replace function public.staff_peers_check(p_peers text[]) returns table(peer text, perms jsonb)
language sql stable security definer set search_path to '' as $$
  select s.peer,
    case when private.is_owner_uid(s.uid) then '["*"]'::jsonb
      else coalesce((select jsonb_agg(p) from private.roles r, jsonb_array_elements_text(r.perms) p
        where r.id = private.role_of(s.uid) and p like 'pw\_%'), '[]'::jsonb) end
  from private.staff_peers s
  where (select auth.uid()) is not null and s.peer = any(p_peers[1:40])
    and s.at > now() - interval '12 hours' and private.rank_of(s.uid) > 0; $$;

revoke all on function public.staff_peer_claim(text), public.staff_peers_check(text[]) from public, anon;
grant execute on function public.staff_peer_claim(text), public.staff_peers_check(text[]) to authenticated;
