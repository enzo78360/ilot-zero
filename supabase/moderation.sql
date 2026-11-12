-- Modération façon Discord : rangs du staff, exclusions temporaires du chat, avertissements,
-- journal de modération et AutoMod réglable par le staff.
-- Rangs : 3 = Admin (le propriétaire l'est toujours), 2 = Modérateur, 1 = Assistant, 0 = pas staff.
--   Assistant : avertir, exclure du chat jusqu'à 1 h, traiter les signalements, lire le journal.
--   Modérateur : + exclure jusqu'à 7 jours, bannir et débannir, régler l'AutoMod.
--   Admin : + gérer le staff et les rangs, cadeaux aux joueurs, codes cadeaux.
-- On n'agit jamais sur quelqu'un de rang égal ou supérieur (sauf l'Admin propriétaire).

alter table private.staff_emails add column if not exists rank text not null default 'admin'
  check (rank in ('admin','mod','helper'));
alter table private.staff_emails alter column rank set default 'helper';

create table if not exists private.timeouts (
  user_id uuid primary key references auth.users(id) on delete cascade,
  until timestamptz not null,
  reason text not null default '',
  by_user uuid,
  created_at timestamptz not null default now());
create table if not exists private.warnings (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  reason text not null default '',
  by_user uuid,
  seen boolean not null default false,
  created_at timestamptz not null default now());
create index if not exists warnings_user_idx on private.warnings(user_id, created_at desc);
create table if not exists private.mod_log (
  id bigserial primary key,
  actor uuid,
  action text not null,
  target uuid,
  target_pseudo text,
  detail text not null default '',
  created_at timestamptz not null default now());
create index if not exists mod_log_time_idx on private.mod_log(created_at desc);
create index if not exists mod_log_target_idx on private.mod_log(target, created_at desc);
alter table private.timeouts enable row level security;
alter table private.warnings enable row level security;
alter table private.mod_log enable row level security;

insert into private.settings(key, value) values ('automod',
  '{"words":[],"links":true,"spamN":4,"spamWin":6,"dupN":3,"muteS":30,"slow":0,"caps":true}')
  on conflict (key) do nothing;

-- ---------- outils internes ----------
create or replace function private.rank_of(u uuid) returns int
language sql stable security definer set search_path to '' as $$
  select case
    when u is null then 0
    when not exists (select 1 from public.profiles where id = u and role = 'staff') then 0
    when private.is_owner_uid(u) then 3
    else coalesce((select case s.rank when 'admin' then 3 when 'mod' then 2 else 1 end
                   from private.staff_emails s join auth.users a on lower(a.email) = s.email where a.id = u), 1)
  end; $$;
create or replace function private.my_rank_n() returns int
language sql stable security definer set search_path to '' as $$ select private.rank_of((select auth.uid())); $$;
create or replace function private.need(r int) returns void
language plpgsql stable security definer set search_path to '' as $$
begin
  if private.my_rank_n() < r then
    raise exception '%', case r when 3 then 'réservé aux Admins' when 2 then 'réservé aux Modérateurs et aux Admins' else 'réservé au staff' end
      using errcode = '42501';
  end if;
end; $$;
-- cible valide : existe, et rang strictement inférieur au sien (le propriétaire peut tout)
create or replace function private.target(p text) returns uuid
language plpgsql stable security definer set search_path to '' as $$
declare t uuid := private.uid_by_pseudo(p); me uuid := (select auth.uid());
begin
  if t is null then raise exception 'aucun joueur avec ce pseudo' using errcode = 'P0002'; end if;
  if t = me then raise exception 'impossible sur toi-même' using errcode = '42501'; end if;
  if private.rank_of(t) >= private.rank_of(me) and not private.is_owner_uid(me) then
    raise exception 'impossible : ce membre du staff a un rang égal ou supérieur au tien' using errcode = '42501'; end if;
  return t;
end; $$;
create or replace function private.log(act text, t uuid, d text) returns void
language sql security definer set search_path to '' as $$
  insert into private.mod_log(actor, action, target, target_pseudo, detail)
  values ((select auth.uid()), act, t, (select pseudo from public.profiles where id = t), left(coalesce(d, ''), 300)); $$;
create or replace function private.fmt_min(m int) returns text
language sql immutable set search_path to '' as $$
  select case when m is null then 'définitif' when m < 60 then m || ' min' when m < 1440 then round(m/60.0, 1) || ' h' else round(m/1440.0, 1) || ' j' end; $$;

-- ---------- rang ----------
create or replace function public.my_rank() returns text
language sql stable security definer set search_path to '' as $$
  select case private.my_rank_n() when 3 then 'admin' when 2 then 'mod' when 1 then 'helper' else null end; $$;

-- ---------- avertissements ----------
create or replace function public.mod_warn(target_pseudo text, why text) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid;
begin
  perform private.need(1); t := private.target(target_pseudo);
  if coalesce(trim(why), '') = '' then raise exception 'indique un motif' using errcode = '22023'; end if;
  insert into private.warnings(user_id, reason, by_user) values (t, left(trim(why), 200), (select auth.uid()));
  perform private.log('avertissement', t, why);
end; $$;
-- avertissements pas encore lus par le joueur (ils sont marqués comme lus)
create or replace function public.my_warnings() returns table(reason text, created_at timestamptz)
language plpgsql security definer set search_path to '' as $$
begin
  return query with w as (update private.warnings x set seen = true
      where x.user_id = (select auth.uid()) and not x.seen returning x.reason as r, x.created_at as c)
    select w.r, w.c from w order by w.c;
end; $$;

-- ---------- exclusions temporaires du chat ----------
create or replace function public.mod_timeout(target_pseudo text, minutes int, why text) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid;
begin
  perform private.need(1); t := private.target(target_pseudo);
  if minutes is null or minutes < 1 then raise exception 'durée invalide' using errcode = '22023'; end if;
  if minutes > 60 and private.my_rank_n() < 2 then raise exception 'un Assistant peut exclure 1 h au plus' using errcode = '42501'; end if;
  if minutes > 10080 then raise exception 'exclusion de 7 jours au plus (sinon bannir)' using errcode = '22023'; end if;
  insert into private.timeouts(user_id, until, reason, by_user) values (t, now() + make_interval(mins => minutes), left(coalesce(why, ''), 200), (select auth.uid()))
    on conflict (user_id) do update set until = excluded.until, reason = excluded.reason, by_user = excluded.by_user, created_at = now();
  perform private.log('exclusion', t, private.fmt_min(minutes) || coalesce(' · ' || nullif(trim(why), ''), ''));
end; $$;
create or replace function public.mod_untimeout(target_pseudo text) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid;
begin
  perform private.need(1); t := private.target(target_pseudo);
  delete from private.timeouts where user_id = t;
  perform private.log('fin d''exclusion', t, '');
end; $$;
create or replace function public.mod_timeouts_list() returns table(pseudo text, until timestamptz, reason text, by_pseudo text)
language plpgsql stable security definer set search_path to '' as $$
begin
  perform private.need(1);
  return query select p.pseudo, x.until, x.reason, s.pseudo from private.timeouts x
    join public.profiles p on p.id = x.user_id left join public.profiles s on s.id = x.by_user
    where x.until > now() order by x.until;
end; $$;
create or replace function public.my_timeout() returns table(until timestamptz, reason text)
language sql stable security definer set search_path to '' as $$
  select x.until, x.reason from private.timeouts x where x.user_id = (select auth.uid()) and x.until > now(); $$;
-- l'hôte d'un salon demande qui est exclu du chat parmi ses joueurs (pour ignorer leurs messages)
create or replace function public.chat_muted(pseudos text[]) returns setof text
language sql stable security definer set search_path to '' as $$
  select p.pseudo from private.timeouts x join public.profiles p on p.id = x.user_id
  where x.until > now() and (select auth.uid()) is not null and lower(p.pseudo) = any (select lower(unnest(pseudos[1:40]))); $$;

-- ---------- bannissements (Modérateur et plus) ----------
create or replace function public.mod_ban_minutes(target_pseudo text, minutes integer, why text) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid;
begin
  perform private.need(2); t := private.target(target_pseudo);
  if minutes is not null and (minutes < 1 or minutes > 5256000) then raise exception 'durée invalide (1 minute à 10 ans)' using errcode = '22023'; end if;
  insert into private.bans (user_id, until, reason, banned_by)
    values (t, case when minutes is null then null else now() + make_interval(mins => minutes) end, left(coalesce(why, ''), 200), (select auth.uid()))
    on conflict (user_id) do update set until = excluded.until, reason = excluded.reason, banned_by = excluded.banned_by, created_at = now();
  perform private.log('bannissement', t, private.fmt_min(minutes) || coalesce(' · ' || nullif(trim(why), ''), ''));
end; $$;
create or replace function public.mod_ban(target_pseudo text, hours integer, why text) returns void
language plpgsql security definer set search_path to '' as $$
begin perform public.mod_ban_minutes(target_pseudo, case when hours is null then null else hours * 60 end, why); end; $$;
create or replace function public.mod_unban(target_pseudo text) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid := private.uid_by_pseudo(target_pseudo);
begin
  perform private.need(2);
  if t is null then raise exception 'aucun joueur avec ce pseudo' using errcode = 'P0002'; end if;
  delete from private.bans where user_id = t;
  perform private.log('débannissement', t, '');
end; $$;
create or replace function public.mod_bans_list()
returns table(pseudo text, until timestamptz, reason text, banned_by text, created_at timestamptz)
language plpgsql stable security definer set search_path to '' as $$
begin
  perform private.need(1);
  return query select p.pseudo, b.until, b.reason, s.pseudo, b.created_at
    from private.bans b join public.profiles p on p.id = b.user_id left join public.profiles s on s.id = b.banned_by
    where b.until is null or b.until > now() order by b.created_at desc;
end; $$;

-- ---------- signalements ----------
create or replace function public.mod_reports_list()
returns table(id bigint, target_pseudo text, msg text, ctx text, reporter text, created_at timestamptz)
language plpgsql stable security definer set search_path to '' as $$
begin
  perform private.need(1);
  return query select r.id, r.target_pseudo, r.msg, r.ctx, p.pseudo, r.created_at
    from private.chat_reports r left join public.profiles p on p.id = r.reporter order by r.created_at desc limit 60;
end; $$;
create or replace function public.mod_report_delete(rid bigint) returns void
language plpgsql security definer set search_path to '' as $$
declare tp text;
begin
  perform private.need(1);
  delete from private.chat_reports where id = rid returning target_pseudo into tp;
  if tp is not null then perform private.log('signalement traité', private.uid_by_pseudo(tp), ''); end if;
end; $$;

-- ---------- journal ----------
create or replace function public.mod_log_list(lim int, target_pseudo text)
returns table(id bigint, actor text, action text, target text, detail text, created_at timestamptz)
language plpgsql stable security definer set search_path to '' as $$
declare t uuid := case when coalesce(trim(target_pseudo), '') = '' then null else private.uid_by_pseudo(target_pseudo) end;
begin
  perform private.need(1);
  if coalesce(trim(target_pseudo), '') <> '' and t is null then raise exception 'aucun joueur avec ce pseudo' using errcode = 'P0002'; end if;
  return query select l.id, a.pseudo, l.action, coalesce(p.pseudo, l.target_pseudo), l.detail, l.created_at
    from private.mod_log l left join public.profiles a on a.id = l.actor left join public.profiles p on p.id = l.target
    where t is null or l.target = t
    order by l.created_at desc limit least(greatest(coalesce(lim, 80), 1), 300);
end; $$;

-- ---------- AutoMod ----------
create or replace function public.automod_get() returns text
language sql stable security definer set search_path to '' as $$ select value from private.settings where key = 'automod'; $$;
create or replace function public.automod_set(cfg text) returns void
language plpgsql security definer set search_path to '' as $$
declare j jsonb;
begin
  perform private.need(2);
  if length(cfg) > 8000 then raise exception 'réglages trop longs' using errcode = '22023'; end if;
  j := cfg::jsonb;
  if jsonb_typeof(j->'words') <> 'array' or jsonb_array_length(j->'words') > 300 then raise exception 'liste de mots invalide' using errcode = '22023'; end if;
  update private.settings set value = j::text where key = 'automod';
  perform private.log('AutoMod modifié', null, jsonb_array_length(j->'words') || ' mots, liens ' || case when (j->>'links')::boolean then 'retirés' else 'autorisés' end
    || ', mode lent ' || coalesce(j->>'slow', '0') || ' s');
end; $$;

-- ---------- staff et rangs (Admin) ----------
create or replace function public.staff_add(target_email text) returns void
language plpgsql security definer set search_path to '' as $$
declare e text := lower(trim(target_email));
begin
  perform private.need(3);
  if e !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'adresse e-mail invalide' using errcode = '22023'; end if;
  insert into private.staff_emails (email, rank) values (e, 'helper') on conflict (email) do nothing;
  update public.profiles set role = 'staff' where id in (select id from auth.users where lower(email) = e);
  perform private.log('staff ajouté', (select id from auth.users where lower(email) = e), 'Assistant');
end; $$;
create or replace function public.staff_remove(target_email text) returns void
language plpgsql security definer set search_path to '' as $$
declare e text := lower(trim(target_email)); t uuid := (select id from auth.users where lower(email) = lower(trim(target_email)));
begin
  perform private.need(3);
  if e = (select value from private.settings where key = 'owner_email') then raise exception 'le propriétaire ne peut pas être retiré' using errcode = '42501'; end if;
  if e = (select lower(email) from auth.users where id = (select auth.uid())) then raise exception 'tu ne peux pas te retirer toi-même' using errcode = '42501'; end if;
  if t is not null and private.rank_of(t) >= private.my_rank_n() and not private.is_owner_uid((select auth.uid())) then
    raise exception 'impossible : rang égal ou supérieur au tien' using errcode = '42501'; end if;
  delete from private.staff_emails where email = e;
  update public.profiles set role = 'joueur' where id = t;
  perform private.log('staff retiré', t, '');
end; $$;
create or replace function public.staff_set_rank(target_email text, p_rank text) returns void
language plpgsql security definer set search_path to '' as $$
declare e text := lower(trim(target_email)); t uuid := (select id from auth.users where lower(email) = lower(trim(target_email)));
begin
  perform private.need(3);
  if p_rank not in ('admin','mod','helper') then raise exception 'rang invalide' using errcode = '22023'; end if;
  if e = (select value from private.settings where key = 'owner_email') then raise exception 'le propriétaire reste Admin' using errcode = '42501'; end if;
  if not exists (select 1 from private.staff_emails where email = e) then raise exception 'cette adresse n''est pas dans le staff' using errcode = 'P0002'; end if;
  if not private.is_owner_uid((select auth.uid())) and (p_rank = 'admin' or (t is not null and private.rank_of(t) >= 3)) then
    raise exception 'seul le propriétaire nomme ou rétrograde un Admin' using errcode = '42501'; end if;
  update private.staff_emails set rank = p_rank where email = e;
  perform private.log('rang modifié', t, case p_rank when 'admin' then 'Admin' when 'mod' then 'Modérateur' else 'Assistant' end);
end; $$;
drop function if exists public.staff_list();
create function public.staff_list() returns table(email text, name text, connected boolean, owner boolean, rank text)
language plpgsql stable security definer set search_path to '' as $$
begin
  perform private.need(1);
  return query
    select s.email, p.name, (u.id is not null), s.email = (select value from private.settings where key = 'owner_email'),
           case when s.email = (select value from private.settings where key = 'owner_email') then 'admin' else s.rank end
    from private.staff_emails s left join auth.users u on lower(u.email) = s.email left join public.profiles p on p.id = u.id
    order by s.added_at;
end; $$;

-- cadeaux et codes : Admin
create or replace function public.staff_grant(target_pseudo text, p_kind text, p_amount integer) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid := private.uid_by_pseudo(target_pseudo);
begin
  perform private.need(3);
  if t is null then raise exception 'aucun joueur avec ce pseudo' using errcode = 'P0002'; end if;
  if private.is_owner_uid(t) and t <> (select auth.uid()) then
    raise exception 'seul le propriétaire peut modifier son niveau et ses coquillages' using errcode = '42501'; end if;
  if p_kind in ('coins_set', 'xp_set') and p_amount < 0 then raise exception 'valeur négative impossible' using errcode = '22023'; end if;
  insert into private.player_grants (user_id, kind, amount, granted_by) values (t, p_kind, p_amount, (select auth.uid()));
  perform private.log('cadeau', t, p_kind || ' ' || p_amount);
end; $$;
create or replace function public.code_create(p_code text, p_type text, p_amount integer, p_hours integer, p_max_uses integer) returns void
language plpgsql security definer set search_path to '' as $$
begin
  perform private.need(3);
  insert into private.promo_codes (code, reward_type, amount, expires_at, max_uses, created_by)
    values (upper(trim(p_code)), p_type, p_amount, case when p_hours is null then null else now() + make_interval(hours => p_hours) end, p_max_uses, (select auth.uid()));
  perform private.log('code créé', null, upper(trim(p_code)));
exception when unique_violation then raise exception 'ce code existe déjà' using errcode = '23505';
end; $$;
create or replace function public.code_delete(p_code text) returns void
language plpgsql security definer set search_path to '' as $$
begin
  perform private.need(3);
  delete from private.promo_codes where code = upper(trim(p_code));
  perform private.log('code supprimé', null, upper(trim(p_code)));
end; $$;

-- droits : fonctions publiques réservées aux comptes connectés, outils internes fermés
revoke all on function private.rank_of(uuid), private.my_rank_n(), private.need(int), private.target(text), private.log(text, uuid, text) from public, anon, authenticated;
do $$ declare f text; begin
  foreach f in array array['my_rank()','mod_warn(text,text)','my_warnings()','mod_timeout(text,integer,text)','mod_untimeout(text)','mod_timeouts_list()',
    'my_timeout()','chat_muted(text[])','mod_ban_minutes(text,integer,text)','mod_ban(text,integer,text)','mod_unban(text)','mod_bans_list()',
    'mod_reports_list()','mod_report_delete(bigint)','mod_log_list(integer,text)','automod_get()','automod_set(text)','staff_add(text)',
    'staff_remove(text)','staff_set_rank(text,text)','staff_list()','staff_grant(text,text,integer)','code_create(text,text,integer,integer,integer)','code_delete(text)']
  loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
