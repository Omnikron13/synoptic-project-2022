-- TODO: consider citext extension
-- Preamble; making sure the schema/namespace is created and active
-- TODO: name this properly
DROP SCHEMA flood_dist CASCADE;
CREATE SCHEMA IF NOT EXISTS flood_dist;
SET search_path = flood_dist;

-- Function checking for (functionally) empty strings in constraints, useful to validate names, etc.
CREATE OR REPLACE FUNCTION not_blank(c char) RETURNS boolean 
   AS 'select length(trim(coalesce(c, ''''))) > 0'
   LANGUAGE SQL
   IMMUTABLE
   LEAKPROOF
   CALLED ON NULL INPUT
   PARALLEL SAFE;


-- As user
CREATE TABLE IF NOT EXISTS person (
   id
      INTEGER
      PRIMARY KEY,

   -- Intended to be real name
   name
      TEXT
      NOT NULL
      CHECK(not_blank(name)),

   email
      TEXT
      NOT NULL
      -- Regex from html spec, as suggested on https://dba.stackexchange.com/questions/68266/what-is-the-best-way-to-store-an-email-address-in-postgresql
      -- (creating a domain seems overkill for this single usage, though note without citext the datatype is skill case sensitive)
      CHECK(email ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')
);


-- Could represent villages/towns, ranches, cattle stations, farm houses, etc.
CREATE TABLE IF NOT EXISTS location (
   id
      INTEGER
      PRIMARY KEY,

   -- The exact details of usage, implementation, etc. here would need investigating...
   name
      TEXT
      NOT NULL
      CHECK(not_blank(name)),

   coords
      POINT -- generic built-in (x,y) datatype
      NOT NULL
      -- Should really be UNIQUE, though indexing POINT is more involved than other data types.
      -- Also probably shouldn't allow points to close to one another. A proper extension such as
      -- PostGIS would probably be the way to go.
);


-- Tracks user-submitted reports of accessibility between locations during the rainy season.
-- This might actually work best with a graph database, or graph extension for postgres?
CREATE TABLE IF NOT EXISTS location_access (
   id
      INTEGER
      PRIMARY KEY,

   location_a
      INTEGER
      NOT NULL
      REFERENCES location(id)
         ON UPDATE CASCADE
         ON DELETE RESTRICT,

   location_b
      INTEGER
      NOT NULL
      REFERENCES location(id)
         ON UPDATE CASCADE
         ON DELETE RESTRICT,

   submitter
      INTEGER
      NOT NULL
      REFERENCES person(id)
         ON UPDATE CASCADE
         ON DELETE RESTRICT,

   -- More granual information would be nice, but isn't _essential_
   -- This would also need collating in some way considering it is user-derived.
   -- Simply going by the majority opinion/report would be a start.
   accessibility
      BOOLEAN
      NOT NULL,

   -- Exactly how best to log the time or range of time which the report relates to
   -- would want to be more thoroughly investigated...
   -- How recent a report is would probably also factor into the collation.
   datestamp
      DATE
      NOT NULL
);


-- Representing a generic organisation of some kind, a community organisation, town or village council, etc.
-- to track which resources would be available where during flooding.
-- In this simplified prototype model it is intended to be the sole abstraction which resources are linked to,
-- though tracking service/skill type resources would probably actually be best modelled linking to people.
CREATE TABLE IF NOT EXISTS organisation (
   id
      INTEGER
      PRIMARY KEY,

   name
      TEXT
      NOT NULL
      CHECK(not_blank(name)),

   -- In the prototype model organisations are treated as being located at a single location for the sake
   -- of simplicity.
   location_id
      INTEGER
      NOT NULL
      REFERENCES location(id)
         ON UPDATE CASCADE
         ON DELETE RESTRICT
);


-- TODO: link to people


-- Various umbrella categories of resources would probably be supported. Services could be
-- things such as medical/first-aid skills, or mechanical training. 'Cache' is essentially
-- a parent for records of physical supplies (food, potable water, medical supplies, etc.)
-- Generic exists as a fallback for anything that doesn't have a defined category, although
-- notably I believe postgres allows new categories to be added to existing ENUM types.
CREATE TYPE resource_type AS ENUM (
   'cache',
   'generic',
   'service'
);

CREATE TABLE IF NOT EXISTS resource (
   -- 
   id
      INTEGER
      PRIMARY KEY,

   -- 
   type
      resource_type
      NOT NULL
   -- TODO: fill out
);


-- TODO: supplies/supply types, etc.

