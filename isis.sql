CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;

CREATE TABLE agent_statuses (
    agent_uuid uuid,
    state text,
    "time" timestamp with time zone
);
CREATE TABLE agents (
    uuid uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    name text,
    birthday date,
    affiliation text,
    tags text[]
);
CREATE TABLE countries (
    name text PRIMARY KEY
);
CREATE TABLE expenses (
    agent_uuid uuid,
    date date,
    price numeric,
    name text
);

CREATE TABLE secret_missions (
    operation_name text PRIMARY KEY,
    agent_uuid uuid,
    location text,
    mission_timeline tstzrange
);


CREATE TABLE expensive_items (
    item text
);
CREATE TABLE gear_names (
    name text
);
CREATE TABLE reports (
    agent_uuid uuid,
    "time" timestamp with time zone,
    attrs hstore default ''
);

COPY agents (uuid, name, birthday, affiliation, tags) FROM stdin;
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

INSERT INTO agent_statuses
  (SELECT
    (SELECT uuid FROM agents ORDER BY random()+g*0 LIMIT 1) as agent_uuid,
    (ARRAY['training','idle','assigned','captured','recovering'])[random() * 4 + 1] as state,
    now() - '1 year ago'::interval * random() as time
  FROM generate_series(1, 1000) as g);

COPY countries (name) FROM stdin;
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

COPY expensive_items (item) FROM stdin;
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
AK-47
Walther PPK
ammunition
grenades
sleeping gas
silver platter
\.

COPY gear_names (name) FROM stdin;
cloning machine
spy car
body armor
bionic arm
reentry capsule
laser watch
\.

ALTER TABLE secret_missions
    ADD CONSTRAINT fk_secret_mission_agent
    FOREIGN KEY (agent_uuid) REFERENCES agents(uuid);
    
ALTER TABLE secret_missions
    ADD CONSTRAINT fk_secret_mission_location
    FOREIGN KEY (location) REFERENCES countries(name);
    
ALTER TABLE secret_missions
    ADD CONSTRAINT cnt_solo_agent
    EXCLUDE USING gist (location WITH =, mission_timeline WITH &&);
    
COMMENT ON CONSTRAINT cnt_solo_agent ON secret_missions
    IS 'Only one agent must be allowed to operate in any one country at any one time.';

CREATE INDEX reports_attrs_idx ON reports USING gin (attrs);

