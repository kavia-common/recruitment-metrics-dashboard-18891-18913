--
-- PostgreSQL database dump
--

\restrict hh5dBXiruTSvUNzQajJ0pAaebSy5lFDVtxpyyl7CUipKerItL1d7GnS01tqg82G

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

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

DROP DATABASE IF EXISTS myapp;
--
-- Name: myapp; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE myapp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE myapp OWNER TO postgres;

\unrestrict hh5dBXiruTSvUNzQajJ0pAaebSy5lFDVtxpyyl7CUipKerItL1d7GnS01tqg82G
\connect myapp
\restrict hh5dBXiruTSvUNzQajJ0pAaebSy5lFDVtxpyyl7CUipKerItL1d7GnS01tqg82G

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

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: candidate_status; Type: TYPE; Schema: public; Owner: appuser
--

CREATE TYPE public.candidate_status AS ENUM (
    'applied',
    'screening',
    'interviewing',
    'offered',
    'hired',
    'rejected',
    'withdrawn'
);


ALTER TYPE public.candidate_status OWNER TO appuser;

--
-- Name: interview_outcome; Type: TYPE; Schema: public; Owner: appuser
--

CREATE TYPE public.interview_outcome AS ENUM (
    'pending',
    'passed',
    'failed',
    'no_show',
    'rescheduled',
    'offer_extended',
    'offer_accepted',
    'offer_declined'
);


ALTER TYPE public.interview_outcome OWNER TO appuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.activities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    application_id uuid,
    candidate_id uuid,
    job_id uuid,
    client_id uuid,
    activity_type text NOT NULL,
    activity_ts timestamp with time zone DEFAULT now() NOT NULL,
    details jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.activities OWNER TO appuser;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.applications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    candidate_id uuid NOT NULL,
    job_id uuid NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL,
    stage text DEFAULT 'applied'::text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    rejected_reason text,
    hired boolean DEFAULT false,
    offer_amount numeric(12,2),
    offer_currency text DEFAULT 'USD'::text,
    offer_extended_at timestamp with time zone,
    offer_accepted_at timestamp with time zone,
    hired_at timestamp with time zone
);


ALTER TABLE public.applications OWNER TO appuser;

--
-- Name: candidates; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.candidates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text,
    phone text,
    linkedin_url text,
    source text,
    current_company text,
    current_title text,
    years_experience numeric(4,1),
    expected_salary numeric(12,2),
    currency text DEFAULT 'USD'::text,
    status public.candidate_status DEFAULT 'applied'::public.candidate_status NOT NULL,
    resume_url text,
    notes text,
    uploaded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.candidates OWNER TO appuser;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.clients (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    industry text,
    contact_name text,
    contact_email text,
    contact_phone text,
    status text DEFAULT 'active'::text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.clients OWNER TO appuser;

--
-- Name: interviews; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.interviews (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    application_id uuid NOT NULL,
    interview_type text NOT NULL,
    scheduled_at timestamp with time zone NOT NULL,
    duration_minutes integer,
    interviewer text,
    outcome public.interview_outcome DEFAULT 'pending'::public.interview_outcome NOT NULL,
    score numeric(4,2),
    feedback text,
    rescheduled_from uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.interviews OWNER TO appuser;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.jobs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    client_id uuid NOT NULL,
    title text NOT NULL,
    department text,
    location text,
    employment_type text,
    seniority text,
    openings integer DEFAULT 1 NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    budget numeric(12,2),
    currency text DEFAULT 'USD'::text,
    posted_at timestamp with time zone,
    closed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.jobs OWNER TO appuser;

--
-- Name: metrics_daily; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.metrics_daily (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    metric_date date NOT NULL,
    client_id uuid,
    job_id uuid,
    total_candidates integer DEFAULT 0,
    new_candidates integer DEFAULT 0,
    total_applications integer DEFAULT 0,
    new_applications integer DEFAULT 0,
    interviews_scheduled integer DEFAULT 0,
    interviews_completed integer DEFAULT 0,
    offers_extended integer DEFAULT 0,
    offers_accepted integer DEFAULT 0,
    hires integer DEFAULT 0,
    rejections integer DEFAULT 0,
    time_to_hire_days numeric(6,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.metrics_daily OWNER TO appuser;

--
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.activities (id, application_id, candidate_id, job_id, client_id, activity_type, activity_ts, details) FROM stdin;
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.applications (id, candidate_id, job_id, applied_at, stage, status, rejected_reason, hired, offer_amount, offer_currency, offer_extended_at, offer_accepted_at, hired_at) FROM stdin;
\.


--
-- Data for Name: candidates; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.candidates (id, first_name, last_name, email, phone, linkedin_url, source, current_company, current_title, years_experience, expected_salary, currency, status, resume_url, notes, uploaded_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.clients (id, name, industry, contact_name, contact_email, contact_phone, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: interviews; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.interviews (id, application_id, interview_type, scheduled_at, duration_minutes, interviewer, outcome, score, feedback, rescheduled_from, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.jobs (id, client_id, title, department, location, employment_type, seniority, openings, status, budget, currency, posted_at, closed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: metrics_daily; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.metrics_daily (id, metric_date, client_id, job_id, total_candidates, new_candidates, total_applications, new_applications, interviews_scheduled, interviews_completed, offers_extended, offers_accepted, hires, rejections, time_to_hire_days, created_at) FROM stdin;
\.


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: applications applications_candidate_id_job_id_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_candidate_id_job_id_key UNIQUE (candidate_id, job_id);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: candidates candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.candidates
    ADD CONSTRAINT candidates_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: interviews interviews_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: metrics_daily metrics_daily_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.metrics_daily
    ADD CONSTRAINT metrics_daily_pkey PRIMARY KEY (id);


--
-- Name: idx_applications_candidate_job; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_applications_candidate_job ON public.applications USING btree (candidate_id, job_id);


--
-- Name: idx_candidates_status; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_candidates_status ON public.candidates USING btree (status);


--
-- Name: idx_candidates_uploaded_at; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_candidates_uploaded_at ON public.candidates USING btree (uploaded_at);


--
-- Name: idx_interviews_application; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_interviews_application ON public.interviews USING btree (application_id);


--
-- Name: idx_interviews_outcome; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_interviews_outcome ON public.interviews USING btree (outcome);


--
-- Name: idx_interviews_scheduled_at; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_interviews_scheduled_at ON public.interviews USING btree (scheduled_at);


--
-- Name: idx_jobs_status; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_jobs_status ON public.jobs USING btree (status);


--
-- Name: idx_metrics_daily_date; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_metrics_daily_date ON public.metrics_daily USING btree (metric_date);


--
-- Name: ux_metrics_daily_date_scope; Type: INDEX; Schema: public; Owner: appuser
--

CREATE UNIQUE INDEX ux_metrics_daily_date_scope ON public.metrics_daily USING btree (metric_date, client_id, job_id);


--
-- Name: activities activities_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.applications(id) ON DELETE CASCADE;


--
-- Name: activities activities_candidate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id) ON DELETE CASCADE;


--
-- Name: activities activities_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: activities activities_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE CASCADE;


--
-- Name: applications applications_candidate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id) ON DELETE CASCADE;


--
-- Name: applications applications_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE CASCADE;


--
-- Name: metrics_daily fk_metrics_client; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.metrics_daily
    ADD CONSTRAINT fk_metrics_client FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;


--
-- Name: metrics_daily fk_metrics_job; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.metrics_daily
    ADD CONSTRAINT fk_metrics_job FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE SET NULL;


--
-- Name: interviews interviews_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.applications(id) ON DELETE CASCADE;


--
-- Name: interviews interviews_rescheduled_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_rescheduled_from_fkey FOREIGN KEY (rescheduled_from) REFERENCES public.interviews(id) ON DELETE SET NULL;


--
-- Name: jobs jobs_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: DATABASE myapp; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE myapp TO appuser;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO appuser;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v1() TO appuser;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v1mc() TO appuser;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v3(namespace uuid, name text) TO appuser;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v4() TO appuser;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v5(namespace uuid, name text) TO appuser;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_nil() TO appuser;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_dns() TO appuser;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_oid() TO appuser;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_url() TO appuser;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_x500() TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TYPES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO appuser;


--
-- PostgreSQL database dump complete
--

\unrestrict hh5dBXiruTSvUNzQajJ0pAaebSy5lFDVtxpyyl7CUipKerItL1d7GnS01tqg82G

