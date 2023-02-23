drop table if exists sequencing.wnv_sequenced;
create table if not exists sequencing.wnv_sequenced
(
    filepath text
);

alter table sequencing.wnv_sequenced
    add column filename        text,
    add column collection_date date,
    add column sample_id       text,
    owner to cridenour;

update sequencing.wnv_sequenced
set filename = regexp_replace(filepath, '.+/', '')
where filename is null;

update sequencing.wnv_sequenced
set collection_date = case
                          when substring(filename, '20[012][0-9][01][0-9][0123][0-9]') is not null
                              then to_date(substring(filename, '20[012][0-9][01][0-9][0123][0-9]'), 'YYYYMMDD')
                          when substring(filename, '[01][0-9][0123][0-9]20[012][0-9]') is not null
                              then to_date(substring(filename, '[01][0-9][0123][0-9]20[012][0-9]'), 'MMDDYYYY')
    end;


update sequencing.wnv_sequenced
set sample_id = (case
                     when split_part(filename, 'xx', 2) = 'COAV' then split_part(filename, 'xx', 3)
                     when split_part(filename, 'xx', 2) = 'MCVC' then split_part(filename, 'xx', 3)
                     when split_part(filename, 'xx', 2) = 'YUMA' then split_part(filename, 'xx', 3)
                     when split_part(filename, 'x', 2) = 'USDA' then split_part(filename, 'x', 3)
                     when split_part(filename, 'xx', 2) = '' then split_part(filename, 'x', 2)
                     else split_part(filename, 'xx', 2)
    end)
where sample_id is null;
;

create index if not exists wnv_sequenced_filename_index
    on sequencing.wnv_sequenced using gin (filename public.gin_trgm_ops);



select *
from nextstrain.wnv_metadata wm
         left join sequencing.wnv_sequenced ws
                   on (
                               wm.strain ilike '%' || 'x' || ws.sample_id || 'x' || '%' or
                               wm.strain ilike '%' || '\_' || ws.sample_id || '\_' || '%' or
                               ws.filename ilike '%' || wm.strain || '%'
                       )
where wm.source = 'VECTR'
  and wm.date >= '2021-01-01'
  and wm.date = ws.collection_date;

with ids as (select *
             from nextstrain.wnv_metadata wm
                      left join sequencing.wnv_sequenced ws
                                on (
                                            wm.strain ilike '%' || 'x' || ws.sample_id || 'x' || '%' or
                                            wm.strain ilike '%' || '\_' || ws.sample_id || '\_' || '%' or
                                            ws.filename ilike '%' || wm.strain || '%'
                                    )
             where wm.source = 'VECTR'
               and wm.date >= '2021-01-01'
               and wm.date = ws.collection_date)
select ws.*
from sequencing.wnv_sequenced ws
         left join ids
                   on ws.filename = ids.filename
where ids.filename is null
  and ws.collection_date > '2021-01-01'
  and ws.filepath ilike '%BySequencingRun%';
