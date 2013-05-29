--
-- PostgreSQL database cluster dump
--

\connect postgres

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET escape_string_warning = off;

--
-- Roles
--

CREATE ROLE feusers;
ALTER ROLE feusers WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION;

CREATE ROLE gemdba;
ALTER ROLE gemdba WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION;

-- CREATE ROLE oqplatform;
-- ALTER ROLE oqplatform WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION;

GRANT feusers TO oqplatform GRANTED BY postgres;

