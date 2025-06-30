--
-- PostgreSQL database dump
--

-- Dumped from database version 17rc1
-- Dumped by pg_dump version 17rc1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    title text NOT NULL,
    description text,
    completed boolean DEFAULT false,
    team_id bigint,
    assignee_id bigint,
    creator_id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tasks_id_seq OWNER TO postgres;

--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name text NOT NULL,
    owner_id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.teams OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teams_id_seq OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: user_teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_teams (
    user_id integer NOT NULL,
    team_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_teams OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, title, description, completed, team_id, assignee_id, creator_id, created_at, updated_at, deleted_at) FROM stdin;
1	Доделать ВСЕ	Надеемся на лучшее 	t	1	1	1	2025-06-29 21:14:11.473701+03	2025-06-29 22:04:48.263242+03	2025-06-29 22:05:42.630227+03
3	Доделать ВСЕ	ывапрол ьс м и т	f	1	1	1	2025-06-29 22:06:50.107083+03	2025-06-29 22:06:50.107083+03	2025-06-29 22:07:04.75219+03
4	ывапро	ывапро	t	2	1	1	2025-06-29 22:20:25.199937+03	2025-06-29 22:20:30.465416+03	2025-06-29 22:20:33.472068+03
6	 Чилить потом	Что-то еще	f	3	1	1	2025-06-29 22:22:10.455173+03	2025-06-29 22:22:10.455173+03	\N
7	Хочу DMC	Пройду блади пелес за данте	t	1	1	1	2025-06-29 22:22:35.894856+03	2025-06-29 22:23:03.202522+03	\N
8	фыва	фыва	t	2	1	1	2025-06-29 22:22:42.262461+03	2025-06-29 22:23:07.157309+03	\N
5	Доделать ВСЕ	таска 1\n	t	1	1	1	2025-06-29 22:21:49.189091+03	2025-06-30 01:00:55.231302+03	\N
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams (id, name, owner_id, created_at, updated_at, deleted_at) FROM stdin;
2	Команда жаждущих силы	1	2025-06-29 18:05:36.334983+03	2025-06-29 18:05:36.338276+03	\N
1	Команда жаждущих счастья 	1	2025-06-29 09:05:33.071478+03	2025-06-30 01:00:01.319527+03	\N
3	Maybe like this?	1	2025-06-29 18:10:44.729081+03	2025-06-29 18:10:44.730549+03	2025-06-30 01:08:58.975606+03
\.


--
-- Data for Name: user_teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_teams (user_id, team_id, created_at) FROM stdin;
1	2	2025-06-29 18:05:36.338389+03
1	1	2025-06-30 00:54:35.387301+03
2	1	2025-06-30 00:59:59.447714+03
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, created_at, updated_at, deleted_at) FROM stdin;
1	Амир	$2a$14$EcEs0EdqtHCegwkFtq3n/uP8Ydjf7HqLc80zh9KmQYtsv/FsH9xi.	2025-06-29 09:00:54.476464+03	2025-06-29 09:00:54.476464+03	\N
2	Иосиф	$2a$14$Pmz4Qj6PhS7wCFZk152aAOg0mRjj7talwrdVC95QB46523vWJ2FK.	2025-06-30 00:55:21.495541+03	2025-06-30 00:55:21.495541+03	\N
3	Влад	$2a$14$cTQs7fl1D6X9CmfSrMLgVuDjKJKvMxePtBJx3w537kFYPCj7r.w0G	2025-06-30 00:55:38.579376+03	2025-06-30 00:55:38.579376+03	\N
\.


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tasks_id_seq', 8, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teams_id_seq', 3, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: user_teams user_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_teams
    ADD CONSTRAINT user_teams_pkey PRIMARY KEY (user_id, team_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_tasks_assignee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_assignee_id ON public.tasks USING btree (assignee_id);


--
-- Name: idx_tasks_completed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_completed ON public.tasks USING btree (completed);


--
-- Name: idx_tasks_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_creator_id ON public.tasks USING btree (creator_id);


--
-- Name: idx_tasks_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_deleted_at ON public.tasks USING btree (deleted_at);


--
-- Name: idx_tasks_team_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_team_id ON public.tasks USING btree (team_id);


--
-- Name: idx_teams_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teams_deleted_at ON public.teams USING btree (deleted_at);


--
-- Name: idx_teams_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_teams_owner_id ON public.teams USING btree (owner_id);


--
-- Name: idx_users_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_deleted_at ON public.users USING btree (deleted_at);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_username ON public.users USING btree (username);


--
-- Name: tasks fk_assignee; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT fk_assignee FOREIGN KEY (assignee_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tasks fk_creator; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT fk_creator FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: teams fk_owner; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_owner FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tasks fk_tasks_creator; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT fk_tasks_creator FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: user_teams fk_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_teams
    ADD CONSTRAINT fk_team FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: tasks fk_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT fk_team FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: teams fk_teams_owner; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_teams_owner FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: tasks fk_teams_tasks; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT fk_teams_tasks FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: user_teams fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_teams
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_teams fk_user_teams_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_teams
    ADD CONSTRAINT fk_user_teams_team FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: user_teams fk_user_teams_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_teams
    ADD CONSTRAINT fk_user_teams_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tasks fk_users_tasks; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT fk_users_tasks FOREIGN KEY (assignee_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

