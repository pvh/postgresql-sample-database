create extension if not exists plpgsql with schema pg_catalog;
create extension if not exists dblink with schema public;
create extension if not exists hstore with schema public;
create extension if not exists "uuid-ossp" with schema public;
create extension if not exists btree_gist with schema public;

create table agent_statuses (
    agent_uuid uuid,
    state text,
    "time" timestamp with time zone
);

create domain currency as numeric(10, 2);
create table agents (
    uuid uuid default uuid_generate_v4() primary key,
    name text,
    birth date,
    affiliation text,
    tags text[]
);

create table countries (
    name text primary key
);

create table expenses (
    agent_uuid uuid,
    incurred date,
    price currency,
    name text
);

create table secret_missions (
    operation_name text primary key,
    agent_uuid uuid,
    location text,
    mission_timeline tstzrange
);

create table expensive_items (
    item text
);

create table gear_names (
    name text
);

create table reports (
    agent_uuid uuid,
    "time" timestamp with time zone,
    attrs hstore default '',
    report text,
    report_tsv tsvector
);

create trigger report_tsv_update before insert or update on reports
for each row execute procedure
  tsvector_update_trigger(report_tsv, 'pg_catalog.english', report);

copy agents (uuid, name, birth, affiliation, tags) from stdin;
95d0d92e-414a-4654-a010-4c2c9eecb716	Cyril Figgis	1972-05-14	ISIS	{}
c79d954d-0780-45e9-b533-b845398d5e20	Lana Kane	1981-06-27	ISIS	{}
28ec01ab-ab5e-4901-93b7-0fca7a320965	Pam Poovey	1980-11-07	ISIS	{}
e151b10e-faf3-41bf-8b11-8ea06f82d6dd	Ray Gillette	1978-08-02	ISIS	{}
13b9eb52-5c8f-4a8d-be73-6d7a22322176	Doctor Krieger	1968-06-19	ISIS	{double-agent}
8aefec35-1088-48ff-b075-b2330eebf630	Mallory Archer	1949-09-18	ISIS	{double-agent}
9f184afc-6aad-49a4-b9d1-4cdb1a54f6ff	Woodhouse	1942-11-09	ISIS	{probation}
548084df-6296-4cff-9542-758c1d26e282	Cheryl Tunt	1982-07-26	ISIS	{probation,arrears}
5be9dc1b-d1f8-44f0-b0e9-4dafa91b591d	Len Trexler	1948-06-25	ODIN	{probation,arrears}
6ab41fe3-0f58-40c1-8e42-5a74e4265a21	Sterling Archer	1976-04-11	ISIS	{double-agent,probation,arrears}
5049ee7f-b016-4e0a-aed8-2b8566b7045a	Barry Dylan	1980-04-22	ODIN	{double-agent,probation,arrears}
\.

insert into agent_statuses
  (select
    (select uuid from agents order by random()+g*0 limit 1) as agent_uuid,
    (array['training','idle','assigned','captured','recovering'])[random() * 4 + 1] as state,
    now() - '1 year ago'::interval * random() as time
  from generate_series(1, 1000) as g);

copy countries (name) from stdin;
Switzerland
France
England
New Orleans
New York
Space
Zimbabwe
Miami
Cuba
Vancouver
Chicago
Moscow
Prague
Australia
Tokyo
Delhi
\.

create temporary table temp_report_texts (
    id serial,
    report text
);
copy temp_report_texts (report) from stdin;
Agent infiltrated the mansion and spiked the opposition leader''s footwear with the specified hallucinogenic substance. No security mechanisms were encountered.
Echelon was compromised without detection and the desired results for conversations matching the search terms "nuclear", "3d printer", "matinee idol", and "infidelity" were recovered.\n\nAwaiting further instructions in the field.
As directed, a listening device was planted inside the hoodie of the target''s coat. Detected evidence of counter-measures being deployed; suspect target is actively spying on our team. Determined location of target''s hideout in Vancouver suburbs; hideout looks like an ordinary camping tent, but contains various mechanisms and machines inside.
Agent scaled office building using suction cups, located target, and planted listening device. Agent was detected by security; attempted to flee but was entangled in a net. Agent was dumped into a lava chamber.
Mission was harder than it appeared. Successfully released captured agent from their constraints, but failed to detect a trap that burned off much of the agent''s clothes. After subduing opposition guards with a whip, a suitable uniform was acquired and we eluded detection for the remainder of the mission.
Attempted to defuse a time bomb located deep in a red diamond mine. Asked a friendly miner to guide us through the mine; team member trailed at an insconspicuous distance. Sufficient quantities of water were available to defuse the bomb; but unfortunately, the water simply evaporated due to the extreme heat of the mine.\n\nAborted mission on first attempt, but returned with a sealed water container and successfully doused the bomb one second before it was scheduled to detonate. Mission accomplished.
Agent located the misile launcher in the primary school yard disguised as playground equipment; however, arrived too late to prevent the missile from being launched at the university. The agent notified the university administration, and the building was successfully evacuated before the missile landed, but unfortunately the academics were directed into the path of a rock slide initiated by the enemy agent''s tectonic blaster. Disaster was only averted by the use of our sonic pulverizer; while all lives were spared, the enemy is now aware of our latest defenses.
Mission was communicated via self-destructing message to our most experienced agent in the field, whose memory is unfortunately beginning to fail. Agent improvised by drinking a variety of martinis and gambling, losing most of our agency''s annual budget to the yakuza. In the process, the agent tried (but failed miserably) to seduce a number of members of the opposite sex. Mission failed. Also, our agency is financially ruined and has suffered a severe blow to its reputation.
\.

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

copy expensive_items (item) from stdin;
dark black turtleneck
slightly darker black turtleneck
crisis vest
duffle bag
ant poison
doughnuts
coarse sand
vodka
pedicure
fan-boat rental
zoom lens
armani suit
sunglasses
plane tickets
night-vision goggles
grappling hook
ak-47
walther ppk
ammunition
grenades
sleeping gas
silver platter
\.

insert into agent_statuses(agent_uuid, state, time)
  (select
    (select uuid from agents order by random()+g*0 limit 1) as agent_uuid,
    (array['training','idle','assigned','captured','recovering'])[random() * 4 + 1] as state,
    now() - '1 year ago'::interval * random() as time
  from generate_series(1, 1000) as g);

copy gear_names (name) from stdin;
cloning machine
spy car
body armor
bionic arm
reentry capsule
laser watch
\.

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

create table points as (
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

create index reports_attrs_idx on reports using gin (attrs);
create index reports_report_idx on reports using gin (report_tsv);

