-- Pouvoirs du staff (menu O et Espace staff) ajoutés aux permissions réglables par le propriétaire.
-- Par défaut ils restent permis à tout le staff (comme avant).
update private.settings set value = (
  '{"pw_god":1,"pw_ammo":1,"pw_mats":1,"pw_speed":1,"pw_radar":1,"pw_coins":1,"pw_xp":1,"pw_heal":1,"pw_gun":1,"pw_kit":1,"pw_tp":1,"pw_sky":1}'::jsonb
  || value::jsonb)::text where key = 'perms';
create or replace function public.perms_set(cfg text) returns void
language plpgsql security definer set search_path to '' as $$
declare j jsonb; k text; o jsonb := '{}';
begin
  if not private.is_owner_uid((select auth.uid())) then raise exception 'seul le propriétaire règle les permissions' using errcode = '42501'; end if;
  j := cfg::jsonb;
  foreach k in array array['warn','timeout','timeout_long','reports','log','ban','automod','players','inventory','economy','codes','staff',
    'pw_god','pw_ammo','pw_mats','pw_speed','pw_radar','pw_coins','pw_xp','pw_heal','pw_gun','pw_kit','pw_tp','pw_sky'] loop
    o := o || jsonb_build_object(k, greatest(1, least(3, coalesce((j ->> k)::int, 3))));
  end loop;
  update private.settings set value = o::text where key = 'perms';
  perform private.log('permissions modifiées', null, o::text);
end; $$;
revoke all on function public.perms_set(text) from public, anon;
grant execute on function public.perms_set(text) to authenticated;
