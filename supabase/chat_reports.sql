-- Signalements du chat : envoyés par les joueurs, lus et traités par le staff
create table if not exists private.chat_reports (
  id bigint generated always as identity primary key,
  reporter uuid not null references auth.users(id) on delete cascade,
  target_pseudo text not null,
  msg text not null,
  ctx text,
  created_at timestamptz not null default now()
);
create index if not exists chat_reports_recent on private.chat_reports (created_at desc);

create or replace function public.report_chat(target_pseudo text, msg text, ctx text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'connexion requise' using errcode = '42501'; end if;
  if (select count(*) from private.chat_reports r where r.reporter = auth.uid() and r.created_at > now() - interval '1 hour') >= 10 then
    raise exception 'trop de signalements, réessaie plus tard' using errcode = '54000'; end if;
  insert into private.chat_reports(reporter, target_pseudo, msg, ctx)
  values (auth.uid(), left(coalesce(target_pseudo, ''), 20), left(coalesce(msg, ''), 200), left(coalesce(ctx, ''), 40));
end; $$;

create or replace function public.mod_reports_list()
returns table(id bigint, target_pseudo text, msg text, ctx text, reporter text, created_at timestamptz)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not private.is_staff() then raise exception 'réservé au staff' using errcode = '42501'; end if;
  return query select r.id, r.target_pseudo, r.msg, r.ctx, p.pseudo, r.created_at
    from private.chat_reports r left join public.profiles p on p.id = r.reporter
    order by r.created_at desc limit 60;
end; $$;

create or replace function public.mod_report_delete(rid bigint)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_staff() then raise exception 'réservé au staff' using errcode = '42501'; end if;
  delete from private.chat_reports where id = rid;
end; $$;

revoke execute on function public.report_chat(text, text, text) from public, anon;
revoke execute on function public.mod_reports_list() from public, anon;
revoke execute on function public.mod_report_delete(bigint) from public, anon;
grant execute on function public.report_chat(text, text, text) to authenticated;
grant execute on function public.mod_reports_list() to authenticated;
grant execute on function public.mod_report_delete(bigint) to authenticated;
