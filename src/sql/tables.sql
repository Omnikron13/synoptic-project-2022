-- Preamble; making sure the schema/namespace is created and active
-- TODO: name this properly
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

-- 
CREATE TABLE IF NOT EXISTS person (
   -- 
   id
      INTEGER
      PRIMARY KEY,

   -- 
   name
      TEXT
      NOT NULL
      CHECK(not_blank(name))
);


-- 
CREATE TABLE IF NOT EXISTS organisation (
   -- 
   id
      INTEGER
      PRIMARY KEY,

   -- 
   name
      TEXT
      NOT NULL
      CHECK(not_blank(name))
);


-- TODO: link


-- 
CREATE TABLE IF NOT EXISTS location (
   -- 
   id
      INTEGER
      PRIMARY KEY,

   -- 
   name
      TEXT
      NOT NULL
      CHECK(not_blank(name))
);


-- TODO: link


-- 
CREATE TYPE resource_type AS ENUM (
   'cache',
   'generic',
   'service'
);

-- 
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

