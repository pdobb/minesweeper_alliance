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
-- Name: check_game_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_game_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN IF ( NEW.status IN ('Standing By', 'Sweep in Progress') ) THEN IF EXISTS ( SELECT 1 FROM games WHERE status = CASE WHEN NEW.status = 'Sweep in Progress' THEN 'Standing By' ELSE 'Sweep in Progress' END AND id != NEW.id ) THEN RAISE EXCEPTION 'Key (status) IN (Standing By, Sweep in Progress) already exists'; END IF; END IF; RETURN NEW; END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: boards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.boards (
    id bigint NOT NULL,
    game_id bigint NOT NULL,
    columns integer,
    rows integer,
    mines integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: boards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.boards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: boards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.boards_id_seq OWNED BY public.boards.id;


--
-- Name: cells; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cells (
    id bigint NOT NULL,
    board_id bigint NOT NULL,
    coordinates jsonb DEFAULT '{}'::jsonb NOT NULL,
    value character varying,
    mine boolean DEFAULT false NOT NULL,
    flagged boolean DEFAULT false NOT NULL,
    highlighted boolean DEFAULT false NOT NULL,
    revealed boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cells_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cells_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cells_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cells_id_seq OWNED BY public.cells.id;


--
-- Name: games; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.games (
    id bigint NOT NULL,
    status character varying DEFAULT 'Standing By'::character varying NOT NULL,
    difficulty_level character varying NOT NULL,
    started_at timestamp(6) without time zone,
    ended_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.games_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.games_id_seq OWNED BY public.games.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: boards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boards ALTER COLUMN id SET DEFAULT nextval('public.boards_id_seq'::regclass);


--
-- Name: cells id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells ALTER COLUMN id SET DEFAULT nextval('public.cells_id_seq'::regclass);


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: boards boards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boards
    ADD CONSTRAINT boards_pkey PRIMARY KEY (id);


--
-- Name: cells cells_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT cells_pkey PRIMARY KEY (id);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_boards_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_boards_on_created_at ON public.boards USING btree (created_at);


--
-- Name: index_boards_on_game_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_boards_on_game_id ON public.boards USING btree (game_id);


--
-- Name: index_cells_on_board_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_board_id ON public.cells USING btree (board_id);


--
-- Name: index_cells_on_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_coordinates ON public.cells USING gin (coordinates);


--
-- Name: index_cells_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_created_at ON public.cells USING btree (created_at);


--
-- Name: index_cells_on_flagged; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_flagged ON public.cells USING btree (flagged);


--
-- Name: index_cells_on_highlighted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_highlighted ON public.cells USING btree (highlighted);


--
-- Name: index_cells_on_mine; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_mine ON public.cells USING btree (mine);


--
-- Name: index_cells_on_revealed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_revealed ON public.cells USING btree (revealed);


--
-- Name: index_games_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_created_at ON public.games USING btree (created_at);


--
-- Name: index_games_on_ended_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_ended_at ON public.games USING btree (ended_at);


--
-- Name: index_games_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_games_on_status ON public.games USING btree (status) WHERE ((status)::text = ANY ((ARRAY['Standing By'::character varying, 'Sweep in Progress'::character varying])::text[]));


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: games game_status_check; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER game_status_check BEFORE INSERT OR UPDATE ON public.games FOR EACH ROW EXECUTE FUNCTION public.check_game_status();


--
-- Name: boards fk_rails_1f4dcdc327; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boards
    ADD CONSTRAINT fk_rails_1f4dcdc327 FOREIGN KEY (game_id) REFERENCES public.games(id) ON DELETE CASCADE;


--
-- Name: cells fk_rails_d04db06fd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT fk_rails_d04db06fd5 FOREIGN KEY (board_id) REFERENCES public.boards(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240911180310'),
('20240809213941'),
('20240809213716'),
('20240809213612');

