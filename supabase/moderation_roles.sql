-- Rôles personnalisés façon Discord : nom, couleur, niveau (hiérarchie 1 à 99) et liste de pouvoirs.
-- Les trois rangs d'avant deviennent trois rôles modifiables (Admin 30, Modérateur 20, Assistant 10).
-- Le propriétaire a tous les pouvoirs. On ne gère que les rôles et les membres de niveau inférieur au sien,
-- et on ne peut donner à un rôle que des pouvoirs que l'on a soi-même.

create table if not exists private.roles (
  id bigserial primary key,
  name text not null check (char_length(name) between 1 and 24),
  color text not null default '#7f8c8d' check (color ~ '^#[0-9a-fA-F]{6}$'),
  level int not null check (level between 1 and 99),
  perms jsonb not null default '[]' check (jsonb_typeof(perms) = 'array'),
  created_at timestamptz not null default now());
alter table private.roles enable row level security;
alter table private.staff_emails add column if not exists role_id bigint references private.roles(id) on delete set null;
update private.settings set value = ('{"roles":3}'::jsonb || value::jsonb)::text where key = 'perms';

-- rôles de départ, à partir du tableau de permissions actuel
do $$ declare pm jsonb := (select value from private.settings where key = 'perms')::jsonb; a bigint; m bigint; h bigint;
begin
  if not exists (select 1 from private.roles) then
    insert into private.roles(name, color, level, perms) values ('Admin', '#c0392b', 30,
      (select coalesce(jsonb_agg(k), '[]') from jsonb_each_text(pm) e(k, v) where v::int <= 3)) returning id into a;
    insert into private.roles(name, color, level, perms) values ('Modérateur', '#2e86de', 20,
      (select coalesce(jsonb_agg(k), '[]') from jsonb_each_text(pm) e(k, v) where v::int <= 2)) returning id into m;
    insert into private.roles(name, color, level, perms) values ('Assistant', '#16a085', 10,
      (select coalesce(jsonb_agg(k), '[]') from jsonb_each_text(pm) e(k, v) where v::int <= 1)) returning id into h;
    update private.staff_emails set role_id = case rank when 'admin' then a when 'mod' then m else h end where role_id is null;
  end if;
end $$;

create or replace function private.role_of(u uuid) returns bigint
language sql stable security definer set search_path to '' as $$
  select s.role_id from private.staff_emails s join auth.users a on lower(a.email) = s.email where a.id = u; $$;
create or replace function private.rank_of(u uuid) returns int
language sql stable security definer set search_path to '' as $$
  select case
    when u is null then 0
    when not exists (select 1 from public.profiles where id = u and role = 'staff') then 0
    when private.is_owner_uid(u) then 1000
    else coalesce((select r.level from private.roles r where r.id = private.role_of(u)), 1)
  end; $$;
create or replace function private.can(p text) returns boolean
language sql stable security definer set search_path to '' as $$
  select private.my_rank_n() > 0 and (private.is_owner_uid((select auth.uid()))
    or exists (select 1 from private.roles r where r.id = private.role_of((select auth.uid())) and r.perms ? p)); $$;
create or replace function private.my_perms() returns jsonb
language sql stable security definer set search_path to '' as $$
  select coalesce((select r.perms from private.roles r where r.id = private.role_of((select auth.uid()))), '[]'); $$;
revoke all on function private.role_of(uuid), private.my_perms() from public, anon, authenticated;

create or replace function public.my_rank() returns text
language sql stable security definer set search_path to '' as $$
  select case when private.my_rank_n() = 0 then null when private.is_owner_uid((select auth.uid())) then 'Propriétaire'
    else coalesce((select r.name from private.roles r where r.id = private.role_of((select auth.uid()))), 'Staff') end; $$;

create or replace function public.perms_get() returns jsonb
language plpgsql stable security definer set search_path to '' as $$
declare me uuid := (select auth.uid()); own boolean := private.is_owner_uid((select auth.uid()));
begin
  perform private.need(1);
  return jsonb_build_object(
    'owner', own, 'level', private.my_rank_n(),
    'perms', case when own then '["*"]'::jsonb else private.my_perms() end,
    'role', (select jsonb_build_object('id', r.id, 'name', r.name, 'color', r.color, 'level', r.level) from private.roles r where r.id = private.role_of(me)),
    'roles', coalesce((select jsonb_agg(jsonb_build_object('id', r.id, 'name', r.name, 'color', r.color, 'level', r.level, 'perms', r.perms,
       'members', (select count(*) from private.staff_emails s where s.role_id = r.id)) order by r.level desc, r.id) from private.roles r), '[]'));
end; $$;

create or replace function public.role_save(p_id bigint, p_name text, p_color text, p_level int, p_perms jsonb) returns bigint
language plpgsql security definer set search_path to '' as $$
declare me uuid := (select auth.uid()); own boolean := private.is_owner_uid((select auth.uid())); lv int := private.my_rank_n(); mine jsonb := private.my_perms(); k text; nid bigint;
begin
  perform private.need_p('roles');
  if coalesce(trim(p_name), '') = '' then raise exception 'donne un nom au rôle' using errcode = '22023'; end if;
  if p_level is null or p_level < 1 or p_level > 99 then raise exception 'niveau de 1 à 99' using errcode = '22023'; end if;
  if jsonb_typeof(p_perms) <> 'array' then raise exception 'pouvoirs invalides' using errcode = '22023'; end if;
  if not own then
    if p_level >= lv then raise exception 'le niveau doit être inférieur au tien (%)', lv using errcode = '42501'; end if;
    if p_id is not null and (select level from private.roles where id = p_id) >= lv then raise exception 'ce rôle est de niveau égal ou supérieur au tien' using errcode = '42501'; end if;
    for k in select jsonb_array_elements_text(p_perms) loop
      if not (mine ? k) then raise exception 'tu ne peux pas donner un pouvoir que tu n''as pas (%)', k using errcode = '42501'; end if;
    end loop;
  end if;
  if p_id is null then
    insert into private.roles(name, color, level, perms) values (trim(p_name), coalesce(p_color, '#7f8c8d'), p_level, p_perms) returning id into nid;
    perform private.log('rôle créé', null, trim(p_name) || ' (niveau ' || p_level || ')');
  else
    update private.roles set name = trim(p_name), color = coalesce(p_color, color), level = p_level, perms = p_perms where id = p_id returning id into nid;
    if nid is null then raise exception 'rôle introuvable' using errcode = 'P0002'; end if;
    perform private.log('rôle modifié', null, trim(p_name) || ' (niveau ' || p_level || ', ' || jsonb_array_length(p_perms) || ' pouvoirs)');
  end if;
  return nid;
end; $$;
create or replace function public.role_delete(p_id bigint) returns void
language plpgsql security definer set search_path to '' as $$
declare r record;
begin
  perform private.need_p('roles');
  select * into r from private.roles where id = p_id;
  if r.id is null then raise exception 'rôle introuvable' using errcode = 'P0002'; end if;
  if r.level >= private.my_rank_n() and not private.is_owner_uid((select auth.uid())) then raise exception 'ce rôle est de niveau égal ou supérieur au tien' using errcode = '42501'; end if;
  if exists (select 1 from private.staff_emails where role_id = p_id) then raise exception 'des membres ont encore ce rôle : donne-leur un autre rôle d''abord' using errcode = '23503'; end if;
  delete from private.roles where id = p_id;
  perform private.log('rôle supprimé', null, r.name);
end; $$;
create or replace function public.staff_set_role(target_email text, p_role bigint) returns void
language plpgsql security definer set search_path to '' as $$
declare e text := lower(trim(target_email)); t uuid := (select id from auth.users where lower(email) = lower(trim(target_email))); own boolean := private.is_owner_uid((select auth.uid())); rl record;
begin
  perform private.need_p('staff');
  if e = (select value from private.settings where key = 'owner_email') then raise exception 'le propriétaire a déjà tous les pouvoirs' using errcode = '42501'; end if;
  if not exists (select 1 from private.staff_emails where email = e) then raise exception 'cette adresse n''est pas dans le staff' using errcode = 'P0002'; end if;
  select * into rl from private.roles where id = p_role;
  if rl.id is null then raise exception 'rôle introuvable' using errcode = 'P0002'; end if;
  if not own then
    if rl.level >= private.my_rank_n() then raise exception 'tu ne peux donner qu''un rôle de niveau inférieur au tien' using errcode = '42501'; end if;
    if t is not null and private.rank_of(t) >= private.my_rank_n() then raise exception 'ce membre a un niveau égal ou supérieur au tien' using errcode = '42501'; end if;
  end if;
  update private.staff_emails set role_id = p_role where email = e;
  perform private.log('rôle attribué', t, rl.name);
end; $$;
drop function if exists public.staff_set_rank(text, text);

create or replace function public.staff_add(target_email text) returns void
language plpgsql security definer set search_path to '' as $$
declare e text := lower(trim(target_email)); low bigint := (select id from private.roles order by level, id limit 1);
begin
  perform private.need_p('staff');
  if e !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'adresse e-mail invalide' using errcode = '22023'; end if;
  insert into private.staff_emails (email, rank, role_id) values (e, 'helper', low) on conflict (email) do nothing;
  update public.profiles set role = 'staff' where id in (select id from auth.users where lower(email) = e);
  perform private.log('staff ajouté', (select id from auth.users where lower(email) = e), coalesce((select name from private.roles where id = low), ''));
end; $$;

drop function if exists public.staff_list();
create function public.staff_list() returns table(email text, name text, connected boolean, owner boolean, role_id bigint, role_name text, role_color text, role_level int)
language plpgsql stable security definer set search_path to '' as $$
begin
  perform private.need(1);
  return query
    select s.email, p.name, (u.id is not null), s.email = (select value from private.settings where key = 'owner_email'), r.id, r.name, r.color, r.level
    from private.staff_emails s left join auth.users u on lower(u.email) = s.email left join public.profiles p on p.id = u.id
    left join private.roles r on r.id = s.role_id
    order by (s.email = (select value from private.settings where key = 'owner_email')) desc, r.level desc nulls last, s.added_at;
end; $$;

do $$ declare d text; begin
  d := pg_get_functiondef('public.mod_player_card(text)'::regprocedure);
  if position('''rank'', case private.rank_of(t) when 3 then ''admin'' when 2 then ''mod'' when 1 then ''helper'' else null end' in d) = 0 then raise exception 'mod_player_card inattendu'; end if;
  execute replace(d, '''rank'', case private.rank_of(t) when 3 then ''admin'' when 2 then ''mod'' when 1 then ''helper'' else null end',
    '''rank'', case when private.rank_of(t) = 0 then null when private.is_owner_uid(t) then ''Propriétaire'' else (select r.name from private.roles r where r.id = private.role_of(t)) end');
end $$;

do $$ declare f text; begin
  foreach f in array array['my_rank()','perms_get()','role_save(bigint,text,text,integer,jsonb)','role_delete(bigint)','staff_set_role(text,bigint)','staff_add(text)','staff_list()'] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;

create or replace function private.need_p(p text) returns void
language plpgsql stable security definer set search_path to '' as $$
begin
  if not private.can(p) then raise exception 'ton rôle n''a pas ce pouvoir (réglable dans Compte → Rôles)' using errcode = '42501'; end if;
end; $$;
revoke all on function private.need_p(text) from public, anon, authenticated;
