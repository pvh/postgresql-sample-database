create extension if not exists plpgsql with schema pg_catalog;
create extension if not exists dblink with schema public;
create extension if not exists hstore with schema public;
create extension if not exists "uuid-ossp" with schema public;
create extension if not exists btree_gist with schema public;

create table IF NOT EXISTS agent_statuses (
    agent_uuid uuid,
    state text,
    "time" timestamp with time zone
);



create domain currency as numeric(10, 2);
create table IF NOT EXISTS agents (
    uuid uuid default uuid_generate_v4() primary key,
    name text,
    birth date,
    affiliation text,
    tags text[]
);

create table IF NOT EXISTS countries (
    name text primary key
);

create table IF NOT EXISTS expenses (
    agent_uuid uuid,
    incurred date,
    price currency,
    name text
);

create table IF NOT EXISTS secret_missions (
    operation_name text primary key,
    agent_uuid uuid,
    location text,
    mission_timeline tstzrange
);

create table IF NOT EXISTS expensive_items (
    item text
);

create table IF NOT EXISTS gear_names (
    name text
);

create table IF NOT EXISTS reports (
    agent_uuid uuid,
    "time" timestamp with time zone,
    attrs hstore default '',
    report text,
    report_tsv tsvector
);

create trigger report_tsv_update before insert or update on reports
for each row execute procedure
  tsvector_update_trigger(report_tsv, 'pg_catalog.english', report);

-- Agents
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('95d0d92e-414a-4654-a010-4c2c9eecb716', 'Cyril Figgis', '1972-05-14', 'ISIS', '{}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('c79d954d-0780-45e9-b533-b845398d5e20', 'Lana Kane', '1981-06-27', 'ISIS', '{}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('28ec01ab-ab5e-4901-93b7-0fca7a320965', 'Pam Poovey', '1980-11-07', 'ISIS', '{}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('e151b10e-faf3-41bf-8b11-8ea06f82d6dd', 'Ray Gillette', '1978-08-02', 'ISIS', '{}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('13b9eb52-5c8f-4a8d-be73-6d7a22322176', 'Doctor Krieger', '1968-06-19', 'ISIS', '{double-agent}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('8aefec35-1088-48ff-b075-b2330eebf630', 'Mallory Archer', '1949-09-18', 'ISIS', '{double-agent}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('9f184afc-6aad-49a4-b9d1-4cdb1a54f6ff', 'Woodhouse', '1942-11-09', 'ISIS', '{probation}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('548084df-6296-4cff-9542-758c1d26e282', 'Cheryl Tunt', '1982-07-26', 'ISIS', '{probation,arrears}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('5be9dc1b-d1f8-44f0-b0e9-4dafa91b591d', 'Len Trexler', '1948-06-25', 'ODIN', '{probation,arrears}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('6ab41fe3-0f58-40c1-8e42-5a74e4265a21', 'Sterling Archer', '1976-04-11', 'ISIS', '{double-agent,probation,arrears}');
INSERT INTO public.agents (uuid, name, birth, affiliation, tags) VALUES ('5049ee7f-b016-4e0a-aed8-2b8566b7045a', 'Barry Dylan', '1980-04-22', 'ODIN', '{double-agent,probation,arrears}');


insert into agent_statuses
  (select
    (select uuid from agents order by random()+g*0 limit 1) as agent_uuid,
    (array['training','idle','assigned','captured','recovering'])[random() * 4 + 1] as state,
    now() - '1 year ago'::interval * random() as time
  from generate_series(1, 1000) as g);

--countries
INSERT INTO public.countries (name) VALUES ('Switzerland');
INSERT INTO public.countries (name) VALUES ('France');
INSERT INTO public.countries (name) VALUES ('England');
INSERT INTO public.countries (name) VALUES ('New Orleans');
INSERT INTO public.countries (name) VALUES ('New York');
INSERT INTO public.countries (name) VALUES ('Space');
INSERT INTO public.countries (name) VALUES ('Zimbabwe');
INSERT INTO public.countries (name) VALUES ('Miami');
INSERT INTO public.countries (name) VALUES ('Cuba');
INSERT INTO public.countries (name) VALUES ('Vancouver');
INSERT INTO public.countries (name) VALUES ('Chicago');
INSERT INTO public.countries (name) VALUES ('Moscow');
INSERT INTO public.countries (name) VALUES ('Prague');
INSERT INTO public.countries (name) VALUES ('Australia');
INSERT INTO public.countries (name) VALUES ('Tokyo');
INSERT INTO public.countries (name) VALUES ('Delhi');

create temporary table temp_report_texts (
    id serial,
    report text
);

INSERT INTO temp_report_texts (report) VALUES ('Agent infiltrated the mansion and spiked the opposition leader''s footwear with the specified hallucinogenic substance. No security mechanisms were encountered.');
INSERT INTO temp_report_texts (report) VALUES ('Echelon was compromised without detection and the desired results for conversations matching the search terms "nuclear", "3d printer", "matinee idol", and "infidelity" were recovered.\n\nAwaiting further instructions in the field.');


insert into reports (agent_uuid, "time", report, attrs)
    (select
        (select uuid from agents order by random()+g*0 limit 1) as agent_uuid,
        now() - '1 year ago'::interval * random() as time,
        (select report from temp_report_texts order by random()+g*0 limit 1) as report,
        ''::hstore as attrs
    from generate_series(1,100) as g);


update reports set attrs =
    attrs || hstore('witnessed', (round(random())::int::boolean::text));

update reports set attrs =
    attrs || hstore('injury', (array['mild', 'moderate', 'severe', 'lethal'])[random() * 4 + 1]);

-- we need to correlate the sub-select with the outer query or postgres will only evaluate it once
update reports set attrs = 
    attrs || hstore('location', (select * from countries order by random(), reports limit 1));

INSERT INTO public.expensive_items (item) VALUES ('dark black turtleneck');
INSERT INTO public.expensive_items (item) VALUES ('slightly darker black turtleneck');
INSERT INTO public.expensive_items (item) VALUES ('crisis vest');
INSERT INTO public.expensive_items (item) VALUES ('duffle bag');
INSERT INTO public.expensive_items (item) VALUES ('ant poison');
INSERT INTO public.expensive_items (item) VALUES ('doughnuts');
INSERT INTO public.expensive_items (item) VALUES ('coarse sand');
INSERT INTO public.expensive_items (item) VALUES ('vodka');
INSERT INTO public.expensive_items (item) VALUES ('pedicure');
INSERT INTO public.expensive_items (item) VALUES ('fan-boat rental');
INSERT INTO public.expensive_items (item) VALUES ('zoom lens');
INSERT INTO public.expensive_items (item) VALUES ('armani suit');
INSERT INTO public.expensive_items (item) VALUES ('sunglasses');
INSERT INTO public.expensive_items (item) VALUES ('plane tickets');
INSERT INTO public.expensive_items (item) VALUES ('night-vision goggles');
INSERT INTO public.expensive_items (item) VALUES ('grappling hook');
INSERT INTO public.expensive_items (item) VALUES ('ak-47');
INSERT INTO public.expensive_items (item) VALUES ('walther ppk');
INSERT INTO public.expensive_items (item) VALUES ('ammunition');
INSERT INTO public.expensive_items (item) VALUES ('grenades');
INSERT INTO public.expensive_items (item) VALUES ('sleeping gas');
INSERT INTO public.expensive_items (item) VALUES ('silver platter');

insert into agent_statuses(agent_uuid, state, time)
  (select
    (select uuid from agents order by random()+g*0 limit 1) as agent_uuid,
    (array['training','idle','assigned','captured','recovering'])[random() * 4 + 1] as state,
    now() - '1 year ago'::interval * random() as time
  from generate_series(1, 1000) as g);


INSERT INTO public.gear_names (name) VALUES ('cloning machine');
INSERT INTO public.gear_names (name) VALUES ('spy car');
INSERT INTO public.gear_names (name) VALUES ('body armor');
INSERT INTO public.gear_names (name) VALUES ('bionic arm');
INSERT INTO public.gear_names (name) VALUES ('reentry capsule');
INSERT INTO public.gear_names (name) VALUES ('laser watch');

alter table secret_missions
    add constraint fk_secret_mission_agent
    foreign key (agent_uuid) references agents(uuid);
    
alter table secret_missions
    add constraint fk_secret_mission_location
    foreign key (location) references countries(name);
    
alter table secret_missions
    add constraint cnt_solo_agent
    exclude using gist (location with =, mission_timeline with &&);
    
comment on constraint cnt_solo_agent on secret_missions
    IS 'Only one agent must be allowed to operate in any one country at any one time.';

create table IF NOT EXISTS points as (
  with clusters as (
    select 
      random() * 1000 as x,
      random() * 1000 as y, 
      (random() * 5000)::int + 100 as count, 
      random() * 100 + 10 as sigma 
    from 
      generate_series(1,100)
  ) 
  select 
    x + sin(a) * b as x, 
    y + cos(a) * b as y 
  from 
  (
    select 
      generate_series(1, c.count) as index, 
      c.x, 
      c.y, 
      2 * pi() * random() as a, 
      c.sigma * sqrt(-2 * ln(random())) as b 
    from clusters c
  ) t
);

create index IF NOT EXISTS reports_attrs_idx on reports using gin (attrs);
create index IF NOT EXISTS reports_report_idx on reports using gin (report_tsv);

