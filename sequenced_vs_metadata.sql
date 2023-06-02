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



drop table if exists nextstrain.wnv_metadata;
create table if not exists nextstrain.wnv_metadata
(
    virus       varchar(10),
    strain      text,
    date        date,
    location    text,
    source      varchar(25),
    county      text,
    state       text,
    vector      text,
    host        text,
    vector_host text
);

alter table nextstrain.wnv_metadata
    owner to cridenour;

create index if not exists wnv_metadata_strain_index
    on nextstrain.wnv_metadata using gin (strain public.gin_trgm_ops);


update nextstrain.wnv_metadata
set vector = (case
                  when strain ilike '%ct%' then 'Ct'
                  when strain ilike '%cq%' then 'Cq'
                  else 'NA'
    end)
where vector is null;

update nextstrain.wnv_metadata wm
set "date" = case
                 when substring(strain, '20[012][0-9][01][0-9][0123][0-9]') is not null
                     then to_date(substring(strain, '20[012][0-9][01][0-9][0123][0-9]'), 'YYYYMMDD')
                 when substring(strain, '[01][0-9][0123][0-9]20[012][0-9]') is not null
                     then to_date(substring(strain, '[01][0-9][0123][0-9]20[012][0-9]'), 'MMDDYYYY')
    end
where "date" is null;

update nextstrain.wnv_metadata
set host        = 'NA',
    vector_host = 'NA'
where host is null
  and vector_host is null;


select strain, source, count(*)
from nextstrain.wnv_metadata
group by strain, source
having count(strain) > 1;

delete
from nextstrain.wnv_metadata
where ctid in (select max(ctid)
               from nextstrain.wnv_metadata
               group by strain
               having count(*) > 1);
update nextstrain.wnv_metadata
set "date" = ws.collection_date
from sequencing.wnv_sequenced ws
where ws.filename ilike '%' || strain || '%'
  and county is null;

select *
from nextstrain.wnv_metadata wm,
     sequencing.wnv_sequenced ws
where ws.filename ilike '%' || wm.strain || '%'
  and wm.county is null;


drop table if exists nextstrain.wnv_maricopa_coav_with_location;
create table if not exists nextstrain.wnv_maricopa_coav_with_location as
    (select distinct on (strain) wm.*,
                                 mp.location as trap_location,
                                 latitude,
                                 longitude,
                                 null
     from nextstrain.wnv_metadata wm,
          merged_years.merged_2006_thru_01jun2018 mp
     where wm.date = mp.entered_date::date
       and mp.virus_tested = 'WNV'
       and mp.final_result = 1
       and (wm.state ilike 'AZ')
     union
     select distinct on (strain) wm.*,
                                 mp.location as trap_location,
                                 latitude,
                                 longitude,
                                 sample_id
     from nextstrain.wnv_metadata wm,
          merged_years.merged_pool_01jun2018_to_2019 mp
     where wm.date = mp.entered_date::date
       and mp.virus_tested = 'WNV'
       and mp.final_result_binary = 1
       and (wm.state ilike 'AZ')
     union
     select distinct on (strain) wm.*,
                                 mp.location as trap_location,
                                 latitude,
                                 longitude,
                                 sample_id
     from nextstrain.wnv_metadata wm,
          merged_years.merged_pool_2019_to_2021 mp
     where wm.date = mp.entered_date::date
       and mp.virus_tested = 'WNV'
       and mp.final_result_binary = 1
       and (wm.state ilike 'AZ')
     union
     select distinct on (strain) wm.*,
                                 mp.location as trap_location,
                                 latitude,
                                 longitude,
                                 sample_id
     from nextstrain.wnv_metadata wm,
          merged_years.merged_pool_2021_to_01jun2022 mp
     where wm.date = mp.entered_date::date
       and mp.virus_tested = 'WNV'
       and mp.final_result_binary = 1
       and (wm.state ilike 'AZ')
   union
    select distinct on(strain) wm.*, mp.location_id, latitude, longitude, sampleid
    from nextstrain.wnv_metadata wm,
         sequencing.wnv_pos_2022 mp
    where wm.strain ilike '%' || mp.sampleid || '%'

     union
     select distinct on (strain) wm.*, wc.sampleid, latitude, longitude, sampleid
     from nextstrain.wnv_metadata wm,
          sequencing.wnv_coav_2021 wc
     where wm.strain ilike '%' || wc.agency_code || '%'
       and wm.strain ilike '%' || wc.sampleid || '%'
       and wm.date >= '2021-01-01'
     order by date);


alter table nextstrain.wnv_maricopa_coav_with_location
    rename column "?column?" to sample_id;


drop table if exists nextstrain.wnv_lat_long;
create table if not exists nextstrain.wnv_lat_long
(
    location  text,
    strain    text,
    latitude  double precision,
    longitude double precision
);

select *
from nextstrain.wnv_lat_long wll,
     merged_years.loc_lat_lon lll,
     nextstrain.wnv_metadata wm
where round(lll.latitude::numeric, 2) = wll.latitude
  and round(lll.longitude::numeric, 2) = wll.longitude
  and wm.strain = wll.strain;

update nextstrain.wnv_lat_long wll
set latitude  = wml.latitude,
    longitude = wml.longitude
from nextstrain.wnv_maricopa_coav_with_location wml
where wll.strain = wml.strain;

update nextstrain.wnv_lat_long wll
set latitude  = wc.latitude,
    longitude = wc.longitude
from wnv_coav_2021 wc
where wll.strain ilike '%' || wc.agency_code || '%'
  and wll.strain ilike '%' || wc.sampleid || '%';

update nextstrain.wnv_lat_long wll
set latitude  = wc.latitude,
    longitude = wc.longitude
from wnv_pos_2022 wc
where wll.strain ilike '%' || wc.sampleid || '%';

update nextstrain.wnv_lat_long wll
set latitude  = wc.latitude,
    longitude = wc.longitude
from wnv_pos_2021 wc
where split_part(wll.strain, 'xx', 2) = wc.sample_id
  and wll.longitude is null
  and wll.latitude is null;


update nextstrain.wnv_lat_long wll
set latitude  = round(latitude::numeric, 2),
    longitude = round(longitude::numeric, 2)
where latitude is not null
  and longitude is not null;


select distinct on (strain) *
from nextstrain.wnv_metadata;



drop table if exists culex_popgen.metadata;
create table if not exists culex_popgen.metadata
(
    sample_id      text,
    barcode_id     text,
    epiweek        text,
    location_id    text,
    entered_date   text,
    species        text,
    number_in_pool int,
    district       text,
    latitude       double precision,
    longitude      double precision,
    zipcode        text,
    city           text,
    county         text,
    state          text,
    habitat        text,
    landuse        text,
    disease        text,
    final_result   text

);

ALTER TABLE culex_popgen.metadata
    ADD COLUMN geom public.geometry(Point, 4326);
UPDATE culex_popgen.metadata
SET geom = public.ST_SetSRID(public.ST_MakePoint(longitude, latitude), 4326);

select count(*)
from (select distinct on (strain ) *
      from nextstrain.wnv_metadata wm
      where source = 'VECTR'
        and wm.date >= '2021-01-01') as s;

select *
from nextstrain.wnv_metadata wm,
     sequencing.wnv_coav_2021 wc
where wm.strain ilike '%' || wc.agency_code || '%'
  and wm.strain ilike '%' || wc.sampleid || '%'
  and wm.date >= '2021-01-01';

select distinct on (strain ) *
from nextstrain.wnv_maricopa_coav_with_location wm
where source = 'VECTR'
  and wm.date >= '2021-01-01';