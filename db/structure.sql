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
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: boards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.boards (
    id bigint NOT NULL,
    game_id bigint NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
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
-- Name: cell_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cell_transactions (
    id bigint NOT NULL,
    type character varying NOT NULL,
    user_id uuid,
    cell_id bigint NOT NULL,
    created_at timestamp(6) with time zone NOT NULL
);


--
-- Name: cell_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cell_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cell_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cell_transactions_id_seq OWNED BY public.cell_transactions.id;


--
-- Name: cells; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cells (
    id bigint NOT NULL,
    board_id bigint NOT NULL,
    coordinates jsonb DEFAULT '{}'::jsonb NOT NULL,
    mine boolean DEFAULT false NOT NULL,
    flagged boolean DEFAULT false NOT NULL,
    revealed boolean DEFAULT false NOT NULL,
    value integer,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
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
-- Name: game_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.game_transactions (
    id bigint NOT NULL,
    type character varying NOT NULL,
    user_id uuid,
    game_id bigint NOT NULL,
    created_at timestamp(6) with time zone NOT NULL
);


--
-- Name: game_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.game_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: game_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.game_transactions_id_seq OWNED BY public.game_transactions.id;


--
-- Name: games; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.games (
    id bigint NOT NULL,
    type character varying NOT NULL,
    status character varying DEFAULT 'Standing By'::character varying NOT NULL,
    started_at timestamp(6) with time zone,
    ended_at timestamp(6) with time zone,
    score double precision,
    bbbv integer,
    bbbvps double precision,
    efficiency double precision,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
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
-- Name: participant_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.participant_transactions (
    id bigint NOT NULL,
    user_id uuid,
    game_id bigint NOT NULL,
    active boolean DEFAULT false NOT NULL,
    started_actively_participating_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: participant_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.participant_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participant_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.participant_transactions_id_seq OWNED BY public.participant_transactions.id;


--
-- Name: patterns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patterns (
    id bigint NOT NULL,
    name character varying NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    coordinates_array jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: patterns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.patterns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patterns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.patterns_id_seq OWNED BY public.patterns.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: user_update_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_update_transactions (
    id bigint NOT NULL,
    user_id uuid,
    change_set jsonb NOT NULL,
    created_at timestamp(6) with time zone NOT NULL
);


--
-- Name: user_update_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_update_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_update_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_update_transactions_id_seq OWNED BY public.user_update_transactions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying,
    time_zone character varying,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    user_agent character varying
);


--
-- Name: boards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.boards ALTER COLUMN id SET DEFAULT nextval('public.boards_id_seq'::regclass);


--
-- Name: cell_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cell_transactions ALTER COLUMN id SET DEFAULT nextval('public.cell_transactions_id_seq'::regclass);


--
-- Name: cells id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells ALTER COLUMN id SET DEFAULT nextval('public.cells_id_seq'::regclass);


--
-- Name: game_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_transactions ALTER COLUMN id SET DEFAULT nextval('public.game_transactions_id_seq'::regclass);


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: participant_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participant_transactions ALTER COLUMN id SET DEFAULT nextval('public.participant_transactions_id_seq'::regclass);


--
-- Name: patterns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patterns ALTER COLUMN id SET DEFAULT nextval('public.patterns_id_seq'::regclass);


--
-- Name: user_update_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_update_transactions ALTER COLUMN id SET DEFAULT nextval('public.user_update_transactions_id_seq'::regclass);


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
-- Name: cell_transactions cell_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cell_transactions
    ADD CONSTRAINT cell_transactions_pkey PRIMARY KEY (id);


--
-- Name: cells cells_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT cells_pkey PRIMARY KEY (id);


--
-- Name: game_transactions game_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_transactions
    ADD CONSTRAINT game_transactions_pkey PRIMARY KEY (id);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: participant_transactions participant_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participant_transactions
    ADD CONSTRAINT participant_transactions_pkey PRIMARY KEY (id);


--
-- Name: patterns patterns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patterns
    ADD CONSTRAINT patterns_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: user_update_transactions user_update_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_update_transactions
    ADD CONSTRAINT user_update_transactions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_on_active_started_actively_participating_at_0a92ef0ee6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_active_started_actively_participating_at_0a92ef0ee6 ON public.participant_transactions USING btree (active, started_actively_participating_at);


--
-- Name: index_boards_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_boards_on_created_at ON public.boards USING btree (created_at);


--
-- Name: index_boards_on_game_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_boards_on_game_id ON public.boards USING btree (game_id);


--
-- Name: index_cell_transactions_on_cell_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cell_transactions_on_cell_id ON public.cell_transactions USING btree (cell_id);


--
-- Name: index_cell_transactions_on_cell_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_cell_transactions_on_cell_id_and_type ON public.cell_transactions USING btree (cell_id, type) WHERE ((type)::text = ANY ((ARRAY['CellChordTransaction'::character varying, 'CellRevealTransaction'::character varying])::text[]));


--
-- Name: index_cell_transactions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cell_transactions_on_created_at ON public.cell_transactions USING btree (created_at);


--
-- Name: index_cell_transactions_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cell_transactions_on_type ON public.cell_transactions USING btree (type);


--
-- Name: index_cell_transactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cell_transactions_on_user_id ON public.cell_transactions USING btree (user_id);


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
-- Name: index_cells_on_mine; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_mine ON public.cells USING btree (mine);


--
-- Name: index_cells_on_revealed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cells_on_revealed ON public.cells USING btree (revealed);


--
-- Name: index_game_transactions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_game_transactions_on_created_at ON public.game_transactions USING btree (created_at);


--
-- Name: index_game_transactions_on_game_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_game_transactions_on_game_id ON public.game_transactions USING btree (game_id);


--
-- Name: index_game_transactions_on_game_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_game_transactions_on_game_id_and_type ON public.game_transactions USING btree (game_id, type);


--
-- Name: index_game_transactions_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_game_transactions_on_type ON public.game_transactions USING btree (type);


--
-- Name: index_game_transactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_game_transactions_on_user_id ON public.game_transactions USING btree (user_id);


--
-- Name: index_games_on_bbbv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_bbbv ON public.games USING btree (bbbv);


--
-- Name: index_games_on_bbbvps; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_bbbvps ON public.games USING btree (bbbvps);


--
-- Name: index_games_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_created_at ON public.games USING btree (created_at);


--
-- Name: index_games_on_efficiency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_efficiency ON public.games USING btree (efficiency);


--
-- Name: index_games_on_ended_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_ended_at ON public.games USING btree (ended_at);


--
-- Name: index_games_on_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_score ON public.games USING btree (score);


--
-- Name: index_games_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_games_on_status ON public.games USING btree (status) WHERE ((status)::text = ANY ((ARRAY['Standing By'::character varying, 'Sweep in Progress'::character varying])::text[]));


--
-- Name: index_participant_transactions_on_game_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participant_transactions_on_game_id ON public.participant_transactions USING btree (game_id);


--
-- Name: index_participant_transactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participant_transactions_on_user_id ON public.participant_transactions USING btree (user_id);


--
-- Name: index_participant_transactions_on_user_id_and_game_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_participant_transactions_on_user_id_and_game_id ON public.participant_transactions USING btree (user_id, game_id);


--
-- Name: index_patterns_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_patterns_on_created_at ON public.patterns USING btree (created_at);


--
-- Name: index_patterns_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_patterns_on_name ON public.patterns USING btree (name);


--
-- Name: index_user_update_transactions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_update_transactions_on_created_at ON public.user_update_transactions USING btree (created_at);


--
-- Name: index_user_update_transactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_update_transactions_on_user_id ON public.user_update_transactions USING btree (user_id);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: unique_coordinates_per_board_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_coordinates_per_board_index ON public.cells USING btree (board_id, ((coordinates ->> 'x'::text)), ((coordinates ->> 'y'::text)));


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
-- Name: participant_transactions fk_rails_23486ea260; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participant_transactions
    ADD CONSTRAINT fk_rails_23486ea260 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: user_update_transactions fk_rails_52bf7868db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_update_transactions
    ADD CONSTRAINT fk_rails_52bf7868db FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: cell_transactions fk_rails_8ae22ea0ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cell_transactions
    ADD CONSTRAINT fk_rails_8ae22ea0ff FOREIGN KEY (cell_id) REFERENCES public.cells(id) ON DELETE CASCADE;


--
-- Name: game_transactions fk_rails_adddf1bd52; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_transactions
    ADD CONSTRAINT fk_rails_adddf1bd52 FOREIGN KEY (game_id) REFERENCES public.games(id) ON DELETE CASCADE;


--
-- Name: cell_transactions fk_rails_baaa458a22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cell_transactions
    ADD CONSTRAINT fk_rails_baaa458a22 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: game_transactions fk_rails_c020c31c6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_transactions
    ADD CONSTRAINT fk_rails_c020c31c6a FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: participant_transactions fk_rails_c85491b2ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participant_transactions
    ADD CONSTRAINT fk_rails_c85491b2ac FOREIGN KEY (game_id) REFERENCES public.games(id) ON DELETE CASCADE;


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
('20250127005408'),
('20250124190315'),
('20250117181518'),
('20241115023724'),
('20241112041937'),
('20240927195322'),
('20240912030247'),
('20240911180310'),
('20240809213941'),
('20240809213716'),
('20240809213612');

