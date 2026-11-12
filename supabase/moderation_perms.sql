-- Permissions réglables par le propriétaire : pour chaque pouvoir, le rang minimum
-- (1 = Assistant et plus, 2 = Modérateur et plus, 3 = Admin seulement).
-- Inventaire des joueurs : le staff ajoute ou retire des objets (livrés au joueur comme les cadeaux).

insert into private.settings(key, value) values ('perms',
  '{"warn":1,"timeout":1,"timeout_long":2,"reports":1,"log":1,"ban":2,"automod":2,"players":1,"inventory":3,"economy":3,"codes":3,"staff":3}')
  on conflict (key) do nothing;

create or replace function private.can(p text) returns boolean
language sql stable security definer set search_path to '' as $$
  select private.my_rank_n() >= greatest(1, least(3, coalesce(
    ((select value from private.settings where key = 'perms')::jsonb ->> p)::int, 3))); $$;
create or replace function private.need_p(p text) returns void
language plpgsql stable security definer set search_path to '' as $$
begin
  if not private.can(p) then raise exception 'ton rang n''a pas ce pouvoir (réglable par le propriétaire dans Permissions)' using errcode = '42501'; end if;
end; $$;
revoke all on function private.can(text), private.need_p(text) from public, anon, authenticated;

create or replace function public.perms_get() returns jsonb
language plpgsql stable security definer set search_path to '' as $$
begin
  perform private.need(1);
  return jsonb_build_object('perms', (select value from private.settings where key = 'perms')::jsonb,
                            'owner', private.is_owner_uid((select auth.uid())));
end; $$;
create or replace function public.perms_set(cfg text) returns void
language plpgsql security definer set search_path to '' as $$
declare j jsonb; k text; o jsonb := '{}';
begin
  if not private.is_owner_uid((select auth.uid())) then raise exception 'seul le propriétaire règle les permissions' using errcode = '42501'; end if;
  j := cfg::jsonb;
  foreach k in array array['warn','timeout','timeout_long','reports','log','ban','automod','players','inventory','economy','codes','staff'] loop
    o := o || jsonb_build_object(k, greatest(1, least(3, coalesce((j ->> k)::int, 3))));
  end loop;
  update private.settings set value = o::text where key = 'perms';
  perform private.log('permissions modifiées', null, o::text);
end; $$;

-- les fonctions existantes passent des rangs fixes aux permissions
do $$ declare r record; d text; begin
  for r in select * from (values
    ('mod_warn(text,text)', 'perform private.need(1)', 'perform private.need_p(''warn'')'),
    ('mod_timeout(text,integer,text)', 'perform private.need(1)', 'perform private.need_p(''timeout'')'),
    ('mod_timeout(text,integer,text)', 'if minutes > 60 and private.my_rank_n() < 2 then raise exception ''un Assistant peut exclure 1 h au plus''',
                                       'if minutes > 60 and not private.can(''timeout_long'') then raise exception ''ton rang ne peut pas exclure plus d''''1 h'''),
    ('mod_untimeout(text)', 'perform private.need(1)', 'perform private.need_p(''timeout'')'),
    ('mod_ban_minutes(text,integer,text)', 'perform private.need(2)', 'perform private.need_p(''ban'')'),
    ('mod_unban(text)', 'perform private.need(2)', 'perform private.need_p(''ban'')'),
    ('mod_reports_list()', 'perform private.need(1)', 'perform private.need_p(''reports'')'),
    ('mod_report_delete(bigint)', 'perform private.need(1)', 'perform private.need_p(''reports'')'),
    ('mod_log_list(integer,text)', 'perform private.need(1)', 'perform private.need_p(''log'')'),
    ('automod_set(text)', 'perform private.need(2)', 'perform private.need_p(''automod'')'),
    ('staff_add(text)', 'perform private.need(3)', 'perform private.need_p(''staff'')'),
    ('staff_remove(text)', 'perform private.need(3)', 'perform private.need_p(''staff'')'),
    ('staff_set_rank(text,text)', 'perform private.need(3)', 'perform private.need_p(''staff'')'),
    ('staff_grant(text,text,integer)', 'perform private.need(3)', 'perform private.need_p(''economy'')'),
    ('code_create(text,text,integer,integer,integer)', 'perform private.need(3)', 'perform private.need_p(''codes'')'),
    ('code_delete(text)', 'perform private.need(3)', 'perform private.need_p(''codes'')')
  ) v(f, a, b) loop
    d := pg_get_functiondef(('public.' || r.f)::regprocedure);
    if position(r.a in d) = 0 then raise exception 'texte introuvable dans %', r.f; end if;
    execute replace(d, r.a, r.b);
  end loop;
end $$;
-- liste des joueurs : permission « players »
do $$ declare d text; begin
  d := pg_get_functiondef('public.staff_players(text)'::regprocedure);
  if position('if not private.is_staff() then' in d) = 0 then raise exception 'staff_players inattendu'; end if;
  execute replace(d, 'if not private.is_staff() then raise exception ''réservé au staff''', 'if not private.can(''players'') then raise exception ''ton rang n''''a pas ce pouvoir''');
end $$;

-- ---------- inventaire ----------
alter table private.player_grants add column if not exists item text check (item is null or item ~ '^[a-z]+:[a-z0-9_]{1,40}$');
alter table private.player_grants drop constraint if exists player_grants_kind_check;
alter table private.player_grants add constraint player_grants_kind_check
  check (kind in ('coins_add','xp_add','coins_set','xp_set','item_add','item_remove'));

drop function if exists public.my_grants();
create function public.my_grants() returns table(id bigint, kind text, amount integer, by_pseudo text, item text)
language sql stable security definer set search_path to '' as $$
  select g.id, g.kind, g.amount, s.pseudo, g.item from private.player_grants g left join public.profiles s on s.id = g.granted_by
  where g.user_id = (select auth.uid()) and g.claimed_at is null order by g.id; $$;

-- ce que le joueur possède (dernière sauvegarde) et les changements en attente de livraison
create or replace function public.staff_inventory(target_pseudo text)
returns table(skins jsonb, wraps jsonb, picks jsonb, cars jsonb, emotes jsonb, pending jsonb)
language plpgsql stable security definer set search_path to '' as $$
declare t uuid := private.uid_by_pseudo(target_pseudo);
begin
  perform private.need_p('inventory');
  if t is null then raise exception 'aucun joueur avec ce pseudo' using errcode = 'P0002'; end if;
  return query select coalesce(p.progress->'skins', '[]'), coalesce(p.progress->'wraps', '[]'), coalesce(p.progress->'picks', '[]'),
      coalesce(p.progress->'cars', '[]'), coalesce(p.progress->'emotes', '[]'),
      coalesce((select jsonb_agg(jsonb_build_object('kind', g.kind, 'item', g.item) order by g.id) from private.player_grants g
                where g.user_id = t and g.claimed_at is null and g.item is not null), '[]')
    from public.profiles p where p.id = t;
end; $$;
create or replace function public.staff_item(target_pseudo text, p_item text, p_add boolean) returns void
language plpgsql security definer set search_path to '' as $$
declare t uuid := private.uid_by_pseudo(target_pseudo);
begin
  perform private.need_p('inventory');
  if t is null then raise exception 'aucun joueur avec ce pseudo' using errcode = 'P0002'; end if;
  if p_item !~ '^(skin|wrap|pick|car|emote):[a-z0-9_]{1,40}$' then raise exception 'objet invalide' using errcode = '22023'; end if;
  if p_item = 'skin:staff' then raise exception 'la tenue staff est réservée au staff' using errcode = '42501'; end if;
  if private.is_owner_uid(t) and t <> (select auth.uid()) then raise exception 'seul le propriétaire modifie son inventaire' using errcode = '42501'; end if;
  insert into private.player_grants (user_id, kind, amount, granted_by, item) values (t, case when p_add then 'item_add' else 'item_remove' end, 0, (select auth.uid()), p_item);
  perform private.log(case when p_add then 'objet donné' else 'objet retiré' end, t, p_item);
end; $$;

do $$ declare f text; begin
  foreach f in array array['perms_get()','perms_set(text)','my_grants()','staff_inventory(text)','staff_item(text,text,boolean)'] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
