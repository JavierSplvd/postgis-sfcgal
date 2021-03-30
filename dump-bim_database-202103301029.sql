SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER SCHEMA public OWNER TO postgres;

COMMENT ON SCHEMA public IS 'standard public schema';

ALTER SCHEMA topology OWNER TO postgres;

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


SET default_tablespace = '';

CREATE TABLE public.element_types (
    id character varying(255) NOT NULL,
    model_id character varying(255) NOT NULL,
    name character varying(255),
    category character varying(255),
    bim_parameters jsonb NOT NULL
);


ALTER TABLE public.element_types OWNER TO postgres;

CREATE TABLE public.elements (
    id character varying(255) NOT NULL,
    model_id character varying NOT NULL,
    name character varying(255),
    category character varying(255),
    bim_parameters jsonb NOT NULL,
    geometry public.geometry NOT NULL,
    element_type character varying
);


ALTER TABLE public.elements OWNER TO postgres;

CREATE TABLE public.models (
    id character varying(255) NOT NULL,
    project_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    discipline character varying(255),
    description character varying(255),
    bim_parameters jsonb
);


ALTER TABLE public.models OWNER TO postgres;

CREATE TABLE public.projects (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(512)
);


ALTER TABLE public.projects OWNER TO postgres;

CREATE TABLE public.spatial_elements (
    id character varying NOT NULL,
    model_id character varying NOT NULL,
    name character varying,
    type character varying,
    bim_parameters jsonb NOT NULL,
    geometry public.geometry NOT NULL
);


ALTER TABLE public.spatial_elements OWNER TO postgres;


ALTER TABLE ONLY public.element_types
    ADD CONSTRAINT element_type_pk PRIMARY KEY (id);


ALTER TABLE ONLY public.elements
    ADD CONSTRAINT elements_pk PRIMARY KEY (id);


ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_pk PRIMARY KEY (id);


ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pk PRIMARY KEY (id);


ALTER TABLE ONLY public.spatial_elements
    ADD CONSTRAINT spatial_elements_pk PRIMARY KEY (id);


ALTER TABLE ONLY public.element_types
    ADD CONSTRAINT element_type_fk FOREIGN KEY (model_id) REFERENCES public.models(id);


ALTER TABLE ONLY public.elements
    ADD CONSTRAINT elements_fk FOREIGN KEY (model_id) REFERENCES public.models(id);


ALTER TABLE ONLY public.elements
    ADD CONSTRAINT elements_fk_type FOREIGN KEY (element_type) REFERENCES public.element_types(id);


ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_fk FOREIGN KEY (project_id) REFERENCES public.projects(id);


ALTER TABLE ONLY public.spatial_elements
    ADD CONSTRAINT spatial_elements_fk FOREIGN KEY (model_id) REFERENCES public.models(id);


