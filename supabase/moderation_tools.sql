-- Outils de modération en plus : expulsion de la partie en cours, renommage forcé d'un pseudo (pseudos interdits),
-- notes internes, fiche joueur complète, annonce à tous, mode maintenance, salons publics, vidage des signalements.
update private.settings set value = ('{"kick":1,"rename":2,"notes":1,"announce":2,"maintenance":3,"lobbies":2}'::jsonb || value::jsonb)::text where key = 'perms';
insert into private.settings(key, value) values ('announce', '{"text":"","until":null}') on conflict (key) do nothing;
insert into private.settings(key, value) values ('maintenance', '{"on":false,"msg":""}') on conflict (key) do nothing;

create table if not exists private.kicks (
  user_id uuid primary key references auth.users(id) on delete cascade,
  reason text not null default '', by_user uuid, created_at timestamptz not null default now(), seen boolean not null default false);
create table if not exists private.player_notes (
  id bigserial primary key, user_id uuid not null references auth.users(id) on delete cascade,
  note text not null, by_user uuid, created_at timestamptz not null default now());
create index if not exists player_notes_user_idx on private.player_notes(user_id, created_at desc);
create table if not exists private.banned_pseudos (
  pseudo_lower text primary key, by_user uuid, created_at timestamptz not null default now());
alter table private.kicks enable row level security;
alter table private.player_notes enable row level security;
alter table private.banned_pseudos enable row level security;

create or replace function public.perms_set(cfg text) returns void
language plpgsql security definer set search_path to '' as $$
declare j jsonb; k text; o jsonb := '{}';
begin
  if not private.is_owner_uid((select auth.uid())) then raise exception 'seul le propriétaire règle les permissions' using errcode = '42501'; end if;
  j := cfg::jsonb;
  foreach k in array array['warn','timeout','timeout_long','reports','log','ban','automod','players','inventory','economy','codes','staff',
    'kick','rename','notes','announce','maintenance','lobbies',
    'pw_god','pw_ammo','pw_mats','pw_speed','pw_radar','pw_coins','pw_xp','pw_heal','pw_gun','pw_kit','pw_tp','pw_sky'] loop
    o := o || jsonb_build_object(k, greatest(1, least(3, coalesce((j ->> k)::int, 3))));
  end loop;
  update private.settings set value = o::text where key = 'perms';
  perform private.log('permissions modifiées', null, o::text);
end; $$;

-- ---------- pseudos interdits (renommage forcé + mots de l'AutoMod) ----------
create or replace function private.pseudo_check() returns trigger
language plpgsql security definer set search_path to '' as $$
declare n text; w text; words jsonb;
begin
  if new.pseudo is null or new.pseudo is not distinct from old.pseudo then return new; end if;
  if private.rank_of(new.id) > 0 then return new; end if;
  if exists (select 1 from private.banned_pseudos where pseudo_lower = lower(new.pseudo)) then
    raise exception 'ce pseudo a été refusé par le staff, choisis-en un autre' using errcode = '23514'; end if;
  n := regexp_replace(translate(lower(new.pseudo), '0134578@$', 'oleastbas'), '[^a-z]', '', 'g');
  words := coalesce((select value from private.settings where key = 'automod')::jsonb -> 'words', '[]')
           || '["connard","connasse","salope","salaud","pute","putain","encule","batard","nique","negre","negro","nigger","nigga","fuck","bitch","merde","enfoire","pedophile","hitler","nazi"]'::jsonb;
  for w in select lower(jsonb_array_elements_text(words)) loop
    w := regexp_replace(w, '[^a-z]', '', 'g');
    if length(w) >= 4 and position(w in n) > 0 then raise exception 'ce pseudo contient un mot interdit' using errcode = '23514'; end if;
    if length(w) between 2 and 3 and n = w then raise exception 'ce pseudo contient un mot interdit' using errcode = '23514'; end if;
  end loop;
  return new;
end; $$;
drop trigger if exists profiles_pseudo_check on public.profiles;
create trigger profiles_pseudo_check before update of pseudo on public.profiles for each row execute function private.pseudo_check();

create or replace function public.mod_rename(target_pseudo text, why text) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid; old text;
begin
  perform private.need_p('rename'); t := private.target(target_pseudo);
  select pseudo into old from public.profiles where id = t;
  insert into private.banned_pseudos(pseudo_lower, by_user) values (lower(old), (select auth.uid())) on conflict do nothing;
  update public.profiles set pseudo = null where id = t;
  insert into private.warnings(user_id, reason, by_user) values (t, 'Ton pseudo « ' || old || ' » a été refusé' || coalesce(' : ' || nullif(trim(why), ''), '') || '. Choisis-en un autre.', (select auth.uid()));
  perform private.log('pseudo refusé', t, old || coalesce(' · ' || nullif(trim(why), ''), ''));
end; $$;
create or replace function public.mod_pseudo_unban(p text) returns void
language plpgsql security definer set search_path to '' as $$
begin
  perform private.need_p('rename');
  delete from private.banned_pseudos where pseudo_lower = lower(trim(p));
  perform private.log('pseudo de nouveau autorisé', null, p);
end; $$;

-- ---------- expulsion de la partie en cours ----------
create or replace function public.mod_kick(target_pseudo text, why text) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid;
begin
  perform private.need_p('kick'); t := private.target(target_pseudo);
  insert into private.kicks(user_id, reason, by_user) values (t, left(coalesce(why, ''), 200), (select auth.uid()))
    on conflict (user_id) do update set reason = excluded.reason, by_user = excluded.by_user, created_at = now(), seen = false;
  delete from public.mm_lobbies where host = t;
  perform private.log('expulsion de partie', t, coalesce(why, ''));
end; $$;

-- ---------- état envoyé à chaque joueur (expulsion, annonce, maintenance, pseudo) ----------
create or replace function public.my_status() returns jsonb
language plpgsql security definer set search_path to '' as $$
declare me uuid := (select auth.uid()); kr text; a jsonb; m jsonb;
begin
  if me is null then return '{}'; end if;
  update private.kicks x set seen = true where x.user_id = me and not x.seen and x.created_at > now() - interval '15 minutes' returning x.reason into kr;
  a := (select value from private.settings where key = 'announce')::jsonb;
  m := (select value from private.settings where key = 'maintenance')::jsonb;
  return jsonb_build_object(
    'kick', case when kr is not null then jsonb_build_object('reason', kr) else null end,
    'announce', case when coalesce(a->>'text', '') <> '' and (a->>'until' is null or (a->>'until')::timestamptz > now()) then a else null end,
    'maint', case when coalesce((m->>'on')::boolean, false) then m else null end,
    'pseudo', (select pseudo from public.profiles where id = me));
end; $$;

-- ---------- notes internes ----------
create or replace function public.mod_note_add(target_pseudo text, p_note text) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid := private.uid_by_pseudo(target_pseudo);
begin
  perform private.need_p('notes');
  if t is null then raise exception 'aucun joueur avec ce pseudo' using errcode = 'P0002'; end if;
  if coalesce(trim(p_note), '') = '' then raise exception 'note vide' using errcode = '22023'; end if;
  insert into private.player_notes(user_id, note, by_user) values (t, left(trim(p_note), 500), (select auth.uid()));
  perform private.log('note ajoutée', t, left(trim(p_note), 120));
end; $$;
create or replace function public.mod_note_delete(nid bigint) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid;
begin
  perform private.need_p('notes');
  delete from private.player_notes where id = nid returning user_id into t;
  perform private.log('note supprimée', t, '');
end; $$;

-- ---------- fiche joueur ----------
create or replace function public.mod_player_card(target_pseudo text) returns jsonb
language plpgsql stable security definer set search_path to '' as $$
declare t uuid := private.uid_by_pseudo(target_pseudo); p record;
begin
  perform private.need_p('players');
  if t is null then raise exception 'aucun joueur avec ce pseudo' using errcode = 'P0002'; end if;
  select * into p from public.profiles where id = t;
  return jsonb_build_object(
    'pseudo', p.pseudo, 'created_at', p.created_at, 'last_seen', p.last_seen,
    'online', coalesce(p.last_seen > now() - interval '2 minutes', false), 'lobby', p.lobby_code,
    'rank', case private.rank_of(t) when 3 then 'admin' when 2 then 'mod' when 1 then 'helper' else null end,
    'xp', coalesce((p.progress->>'xp')::numeric, 0)::int, 'coins', coalesce((p.progress->>'coins')::numeric, 0)::int,
    'ban', (select jsonb_build_object('until', b.until, 'reason', b.reason) from private.bans b where b.user_id = t and (b.until is null or b.until > now())),
    'timeout', (select jsonb_build_object('until', x.until, 'reason', x.reason) from private.timeouts x where x.user_id = t and x.until > now()),
    'warnings', coalesce((select jsonb_agg(jsonb_build_object('reason', w.reason, 'at', w.created_at, 'by', s.pseudo, 'seen', w.seen) order by w.created_at desc)
                 from private.warnings w left join public.profiles s on s.id = w.by_user where w.user_id = t), '[]'),
    'reports', coalesce((select jsonb_agg(jsonb_build_object('msg', r.msg, 'at', r.created_at, 'by', s.pseudo, 'ctx', r.ctx) order by r.created_at desc)
                 from private.chat_reports r left join public.profiles s on s.id = r.reporter where lower(r.target_pseudo) = lower(p.pseudo)), '[]'),
    'notes', case when private.can('notes') then coalesce((select jsonb_agg(jsonb_build_object('id', n.id, 'note', n.note, 'at', n.created_at, 'by', s.pseudo) order by n.created_at desc)
                 from private.player_notes n left join public.profiles s on s.id = n.by_user where n.user_id = t), '[]') else null end,
    'actions', (select count(*) from private.mod_log l where l.target = t));
end; $$;

-- ---------- annonce et maintenance ----------
create or replace function public.announce_set(p_text text, minutes int) returns void
language plpgsql security definer set search_path to '' as $$
begin
  perform private.need_p('announce');
  update private.settings set value = jsonb_build_object('text', left(coalesce(trim(p_text), ''), 300),
    'until', case when minutes is null or minutes <= 0 then null else now() + make_interval(mins => least(minutes, 525600)) end,
    'by', (select pseudo from public.profiles where id = (select auth.uid())))::text where key = 'announce';
  perform private.log(case when coalesce(trim(p_text), '') = '' then 'annonce retirée' else 'annonce publiée' end, null, left(coalesce(p_text, ''), 200));
end; $$;
create or replace function public.maintenance_set(p_on boolean, p_msg text) returns void
language plpgsql security definer set search_path to '' as $$
begin
  perform private.need_p('maintenance');
  update private.settings set value = jsonb_build_object('on', coalesce(p_on, false), 'msg', left(coalesce(trim(p_msg), ''), 300))::text where key = 'maintenance';
  perform private.log(case when p_on then 'maintenance activée' else 'maintenance terminée' end, null, coalesce(p_msg, ''));
end; $$;
create or replace function public.mod_tools_get() returns jsonb
language plpgsql stable security definer set search_path to '' as $$
begin
  perform private.need(1);
  return jsonb_build_object('announce', (select value from private.settings where key = 'announce')::jsonb,
    'maint', (select value from private.settings where key = 'maintenance')::jsonb,
    'pseudos', coalesce((select jsonb_agg(pseudo_lower order by created_at desc) from private.banned_pseudos), '[]'));
end; $$;

-- ---------- salons publics ----------
create or replace function public.mod_lobbies_list() returns table(code text, host_pseudo text, game text, mode text, players int, updated_at timestamptz)
language plpgsql stable security definer set search_path to '' as $$
begin
  perform private.need_p('lobbies');
  return query select l.code, p.pseudo, l.game, l.mode, l.players, l.updated_at from public.mm_lobbies l left join public.profiles p on p.id = l.host order by l.updated_at desc;
end; $$;
create or replace function public.mod_lobby_close(p_code text) returns void
language plpgsql security definer set search_path to '' as $$
begin
  perform private.need_p('lobbies');
  delete from public.mm_lobbies where code = upper(trim(p_code));
  perform private.log('salon public fermé', null, upper(trim(p_code)));
end; $$;

-- ---------- signalements : tout vider ----------
create or replace function public.mod_reports_clear() returns void
language plpgsql security definer set search_path to '' as $$
declare n int;
begin
  perform private.need_p('reports');
  with d as (delete from private.chat_reports returning 1) select count(*) into n from d;
  perform private.log('signalements vidés', null, n || ' signalements');
end; $$;

do $$ declare f text; begin
  foreach f in array array['perms_set(text)','mod_rename(text,text)','mod_pseudo_unban(text)','mod_kick(text,text)','my_status()','mod_note_add(text,text)',
    'mod_note_delete(bigint)','mod_player_card(text)','announce_set(text,integer)','maintenance_set(boolean,text)','mod_tools_get()',
    'mod_lobbies_list()','mod_lobby_close(text)','mod_reports_clear()'] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
revoke all on function private.pseudo_check() from public, anon, authenticated;
