--
-- PostgreSQL database dump
--

\restrict ALBiA9yoGh9pdyc3KWHNQyE8K5N51NCQemcbyDv0pmKF6WA9yT0upbcdFRawLPD

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.9 (Ubuntu 17.9-1.pgdg24.04+1)

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
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: graphql(text, text, jsonb, jsonb); Type: FUNCTION; Schema: graphql_public; Owner: -
--

CREATE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_
        -- Filter by action early - only get subscriptions interested in this action
        -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
        and (subs.action_filter = '*' or subs.action_filter = action::text);

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL AND ppt.tablename NOT LIKE '% %'),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  -- Count raw slot entries before apply_rls/subscription filter
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  -- Apply RLS and filter as before
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  -- Real rows with slot count attached
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  -- Sentinel row: always returned when no real rows exist so Elixir can
  -- always read slot_changes_count. Identified by wal IS NULL.
  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: allow_any_operation(text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;


--
-- Name: allow_only_operation(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


--
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: Budget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Budget" (
    id text NOT NULL,
    "categoryName" text NOT NULL,
    "categoryId" text,
    "familyId" text,
    "limitValue" double precision NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Category" (
    id text NOT NULL,
    name text NOT NULL,
    type text DEFAULT 'expense'::text NOT NULL,
    "familyId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: CoupleModeConfig; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoupleModeConfig" (
    id text NOT NULL,
    "familyId" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "splitType" text DEFAULT 'equal'::text NOT NULL,
    participants jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: CreditCard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CreditCard" (
    id text NOT NULL,
    "familyId" text,
    "ownerId" text,
    name text NOT NULL,
    bank text,
    brand text DEFAULT 'other'::text,
    color text DEFAULT '#334155'::text,
    "limitAmount" double precision NOT NULL,
    "availableLimit" double precision NOT NULL,
    "closingDay" integer NOT NULL,
    "dueDay" integer NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: CreditCardInstallment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CreditCardInstallment" (
    id text NOT NULL,
    "purchaseId" text NOT NULL,
    "invoiceId" text NOT NULL,
    "installmentNumber" integer NOT NULL,
    "totalInstallments" integer NOT NULL,
    amount double precision NOT NULL,
    "referenceMonth" integer NOT NULL,
    "referenceYear" integer NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: CreditCardInvoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CreditCardInvoice" (
    id text NOT NULL,
    "creditCardId" text NOT NULL,
    "referenceMonth" integer NOT NULL,
    "referenceYear" integer NOT NULL,
    "closingDate" timestamp(3) without time zone NOT NULL,
    "dueDate" timestamp(3) without time zone NOT NULL,
    "totalAmount" double precision DEFAULT 0 NOT NULL,
    "paidAmount" double precision DEFAULT 0 NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: CreditCardPurchase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CreditCardPurchase" (
    id text NOT NULL,
    "creditCardId" text NOT NULL,
    "familyId" text,
    "ownerId" text,
    "categoryId" text,
    description text NOT NULL,
    "purchaseDate" timestamp(3) without time zone NOT NULL,
    "totalAmount" double precision NOT NULL,
    installments integer DEFAULT 1 NOT NULL,
    observation text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Expense; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Expense" (
    id text NOT NULL,
    description text NOT NULL,
    value double precision NOT NULL,
    "categoryName" text NOT NULL,
    "categoryId" text,
    type text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    "isCreditCard" boolean DEFAULT false NOT NULL,
    "creditCardId" text,
    "personId" text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    dt_deleted timestamp(3) without time zone,
    "recurringId" text,
    "isShared" boolean DEFAULT true NOT NULL
);


--
-- Name: ExpenseAdjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ExpenseAdjustment" (
    id text NOT NULL,
    "familyId" text NOT NULL,
    "fromPersonId" text NOT NULL,
    "toPersonId" text NOT NULL,
    amount double precision NOT NULL,
    description text DEFAULT 'Ajuste de contas'::text NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ExtraIncome; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ExtraIncome" (
    id text NOT NULL,
    description text NOT NULL,
    value double precision NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    "personId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    dt_deleted timestamp(3) without time zone
);


--
-- Name: Family; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Family" (
    id text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Goal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Goal" (
    id text NOT NULL,
    description text NOT NULL,
    type text DEFAULT 'savings'::text NOT NULL,
    "targetValue" double precision NOT NULL,
    "currentValue" double precision DEFAULT 0 NOT NULL,
    deadline timestamp(3) without time zone,
    "familyId" text,
    "personId" text,
    status text DEFAULT 'active'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: GoalContribution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."GoalContribution" (
    id text NOT NULL,
    "goalId" text NOT NULL,
    value double precision NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    observation text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Income; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Income" (
    id text NOT NULL,
    description text NOT NULL,
    value double precision NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    type text NOT NULL,
    "personId" text NOT NULL,
    "sourceId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    dt_deleted timestamp(3) without time zone
);


--
-- Name: IncomeSource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."IncomeSource" (
    id text NOT NULL,
    description text NOT NULL,
    value double precision NOT NULL,
    type text NOT NULL,
    "isRecurring" boolean DEFAULT true NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone,
    active boolean DEFAULT true NOT NULL,
    "personId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Person" (
    id text NOT NULL,
    name text NOT NULL,
    phone text,
    email text,
    cpf text,
    "birthDate" timestamp(3) without time zone,
    "userId" text,
    "familyId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "hasAccess" boolean DEFAULT false NOT NULL
);


--
-- Name: RecurringExpense; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RecurringExpense" (
    id text NOT NULL,
    description text NOT NULL,
    value double precision NOT NULL,
    "categoryName" text NOT NULL,
    "personId" text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone,
    active boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Salary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Salary" (
    id text NOT NULL,
    "personId" text NOT NULL,
    value double precision NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    dt_deleted timestamp(3) without time zone
);


--
-- Name: TelegramActivationCode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TelegramActivationCode" (
    id text NOT NULL,
    "userId" text NOT NULL,
    code text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: TelegramLink; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TelegramLink" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "telegramUserId" text NOT NULL,
    "telegramChatId" text NOT NULL,
    "telegramUsername" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: TelegramPendingAction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TelegramPendingAction" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "telegramChatId" text NOT NULL,
    "actionType" text NOT NULL,
    payload jsonb NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
20260219120000
20260302000000
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_challenges (id, user_id, challenge_type, session_data, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_credentials (id, user_id, credential_id, public_key, attestation_type, aaguid, sign_count, transports, backup_eligible, backed_up, friendly_name, created_at, updated_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: Budget; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Budget" (id, "categoryName", "categoryId", "familyId", "limitValue", month, year, "createdAt") FROM stdin;
55529168-b2bf-4058-a594-974171ac7ff3	Alimentação	46054cf5-1dbc-4bd2-808d-325d686a90c6	93b2a024-d640-4ba8-b738-7439ad968345	150	3	2026	2026-03-20 15:18:56.038
9b4e25fe-0d4d-4c8c-82c3-afd9f2d7a8ac	Emprestimos	8b48ec2f-ef41-429a-9aae-ed9e9b4c80bb	93b2a024-d640-4ba8-b738-7439ad968345	15000	3	2026	2026-03-20 15:19:11.467
\.


--
-- Data for Name: Category; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Category" (id, name, type, "familyId", "createdAt") FROM stdin;
15e27a91-b1e0-43b0-92b9-1e26596975e9	teste 	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 01:24:18.782
d01a1ec9-01b8-4db9-92db-e8e3189c8700	Transporte	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:09:30.674
46054cf5-1dbc-4bd2-808d-325d686a90c6	Alimentação	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:09:38.081
8b48ec2f-ef41-429a-9aae-ed9e9b4c80bb	Emprestimos	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:09:46.233
7227840b-c0d9-4287-a63c-ff05185daaf8	Pets	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:09:51.745
1637b51f-2d91-4b2f-a418-95ec29a170ea	Crédito	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:10:30.82
2c7a4f34-0c0f-4040-9bb4-fae7be5fc9cb	Escola	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:10:37.962
7b40458d-2279-4ef4-8f6d-1317e5eaff4f	Lazer	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:11:28.982
53eeddd2-412c-4e68-af30-e7c10fbd807c	Materiais De Contrução	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:12:58.662
e3dac876-23b2-4905-b321-858d33be4ed8	teste 2	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:13:37.879
9e25602d-96b8-45f1-b670-ee9396b8e761	teste 3	expense	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 21:13:41.296
f0b7da84-6098-48e2-8c94-a93aa6c52f89	Lazer	expense	73992fc9-64a8-4cef-be57-a009c080d1ae	2026-04-06 21:40:57.852
933ecbd2-623d-46c9-b686-f24567ec71cd	Moradia	expense	73992fc9-64a8-4cef-be57-a009c080d1ae	2026-04-06 21:41:00.046
00f4b8c5-bed6-43fd-bb08-dd16a50b0f98	Saúde	expense	73992fc9-64a8-4cef-be57-a009c080d1ae	2026-04-06 21:41:02.621
d611b36f-88ac-458c-b00e-3451e15f2883	Alimentação	expense	73992fc9-64a8-4cef-be57-a009c080d1ae	2026-04-06 21:41:05.148
559567e2-4b93-450e-907c-9f594eb90751	Emprestimos	expense	73992fc9-64a8-4cef-be57-a009c080d1ae	2026-04-06 21:41:20.346
0b8ba15e-951b-48d5-8669-76d2c2622720	Pets	expense	73992fc9-64a8-4cef-be57-a009c080d1ae	2026-04-06 22:00:41.949
\.


--
-- Data for Name: CoupleModeConfig; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CoupleModeConfig" (id, "familyId", "isActive", "splitType", participants, "createdAt", "updatedAt") FROM stdin;
48da605d-da04-4f41-8846-a89d653f1c38	93b2a024-d640-4ba8-b738-7439ad968345	t	proportional	[{"income": 2100, "personId": "b0a52965-93c0-4486-8c58-c4c73e2b8967"}, {"income": 5000, "personId": "4a6fd93e-eda3-48ea-a57f-582cfdc1b43b"}]	2026-03-18 18:58:56.478	2026-03-18 18:58:56.478
\.


--
-- Data for Name: CreditCard; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CreditCard" (id, "familyId", "ownerId", name, bank, brand, color, "limitAmount", "availableLimit", "closingDay", "dueDay", "isActive", "createdAt", "updatedAt") FROM stdin;
12812374-728f-499a-ad06-b76c0da0e648	93b2a024-d640-4ba8-b738-7439ad968345	\N	Nubank Felipe	Nubank	mastercard	#7c3aed	800	755.1	10	15	t	2026-03-18 01:53:21.485	2026-03-18 02:22:50.543
69b81d7d-02b0-4040-a103-1a2e25ac805b	25aa2fbe-54b1-48e1-9c94-7f1d1e1b41a7	\N	Felipe G. Augusto	Nubank	mastercard	#7c3aed	800	800	6	13	t	2026-03-18 21:55:28.883	2026-03-18 21:55:28.883
dcd6a138-be8f-4e12-94f6-28cc3a3961d1	25aa2fbe-54b1-48e1-9c94-7f1d1e1b41a7	\N	Shirlley M. Augusto	Nubank	mastercard	#db2777	450	450	5	12	t	2026-03-18 21:56:40.073	2026-03-18 21:56:40.073
5fae747f-f8ce-49dd-8f20-b3be9ae44d51	f019492c-c7bc-4477-9f93-2b4be9316978	\N	nubank Gustavo	Nubank	mastercard	#7c3aed	10000	10000	1	8	t	2026-03-25 20:36:12.815	2026-03-25 20:36:12.815
1f9f9684-e886-435f-8fb2-cf726b906270	73992fc9-64a8-4cef-be57-a009c080d1ae	\N	Felipe G. Augusto	Nubank	mastercard	#7c3aed	800	206	6	13	f	2026-04-07 00:03:49.022	2026-04-28 22:21:34.613
\.


--
-- Data for Name: CreditCardInstallment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CreditCardInstallment" (id, "purchaseId", "invoiceId", "installmentNumber", "totalInstallments", amount, "referenceMonth", "referenceYear", status, "createdAt", "updatedAt") FROM stdin;
cfaabf1e-1127-4ea2-b60c-4a6dd40defc5	75a67136-793a-487c-98e5-04fd653df552	ff548e69-a911-4007-98ca-6c6529cede31	1	1	66	5	2026	pending	2026-03-18 02:14:23.392	2026-03-18 02:14:23.392
359cc3cd-1fab-4dc6-9307-9bf7831cfe36	e5cd9b3a-4fe1-49c1-9456-e56810f7f12b	ff548e69-a911-4007-98ca-6c6529cede31	1	1	44.9	5	2026	pending	2026-03-18 02:22:50.383	2026-03-18 02:22:50.383
fbd8b6b2-6334-4323-b51d-f47f12b8ad06	4e632ac1-690d-4701-842d-c656c065c72b	090c37d8-8cbd-4ae3-937b-6ecef8ef8c6d	1	1	594	6	2026	pending	2026-04-08 11:14:40.493	2026-04-08 11:14:40.493
\.


--
-- Data for Name: CreditCardInvoice; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CreditCardInvoice" (id, "creditCardId", "referenceMonth", "referenceYear", "closingDate", "dueDate", "totalAmount", "paidAmount", status, "createdAt", "updatedAt") FROM stdin;
ff548e69-a911-4007-98ca-6c6529cede31	12812374-728f-499a-ad06-b76c0da0e648	5	2026	2026-04-10 00:00:00	2026-05-15 00:00:00	110.9	66	paid	2026-03-18 02:14:23.325	2026-03-18 02:22:50.463
090c37d8-8cbd-4ae3-937b-6ecef8ef8c6d	1f9f9684-e886-435f-8fb2-cf726b906270	6	2026	2026-05-06 00:00:00	2026-06-13 00:00:00	594	0	open	2026-04-08 11:14:40.397	2026-04-08 11:14:40.601
\.


--
-- Data for Name: CreditCardPurchase; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CreditCardPurchase" (id, "creditCardId", "familyId", "ownerId", "categoryId", description, "purchaseDate", "totalAmount", installments, observation, "createdAt", "updatedAt") FROM stdin;
75a67136-793a-487c-98e5-04fd653df552	12812374-728f-499a-ad06-b76c0da0e648	93b2a024-d640-4ba8-b738-7439ad968345	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	\N	Disney	2026-03-18 00:00:00	66	1		2026-03-18 02:14:23.185	2026-03-18 02:14:23.185
e5cd9b3a-4fe1-49c1-9456-e56810f7f12b	12812374-728f-499a-ad06-b76c0da0e648	93b2a024-d640-4ba8-b738-7439ad968345	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	\N	Netflix	2026-03-18 00:00:00	44.9	1		2026-03-18 02:22:50.221	2026-03-18 02:22:50.221
4e632ac1-690d-4701-842d-c656c065c72b	1f9f9684-e886-435f-8fb2-cf726b906270	73992fc9-64a8-4cef-be57-a009c080d1ae	d8c5dd89-683e-4d5d-9981-3b3545345573	d611b36f-88ac-458c-b00e-3451e15f2883	Mercado	2026-04-08 00:00:00	594	1		2026-04-08 11:14:40.136	2026-04-08 11:14:40.136
\.


--
-- Data for Name: Expense; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Expense" (id, description, value, "categoryName", "categoryId", type, date, month, year, "isCreditCard", "creditCardId", "personId", status, "createdAt", is_deleted, dt_deleted, "recurringId", "isShared") FROM stdin;
78d7f9ca-5d97-4847-abd1-144f48633b53	gasolina	50	Transporte	\N	variable	2026-03-16 00:00:00	3	2026	f	\N	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	PAID	2026-03-18 01:25:24.335	f	\N	\N	t
284201bb-0cb7-4268-ae90-3e949fe2cdbd	Investimento — Comprar uma casa	2500	Investimento	\N	variable	2026-03-17 00:00:00	3	2026	f	\N	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	PAID	2026-03-18 01:29:31.162	f	\N	\N	t
9ce6ba8e-a9f3-4d68-bc52-0f7d7bd84b8f	Padaria	25	Alimentação	\N	variable	2026-03-17 00:00:00	3	2026	f	\N	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	PAID	2026-03-18 01:24:54.83	f	\N	\N	t
e92792d9-9128-42f1-bf79-1cec0855a28a	Investimento — Quitar Santander	100	Investimento	\N	variable	2026-03-17 00:00:00	3	2026	f	\N	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	PAID	2026-03-18 01:38:03.885	f	\N	\N	t
7c4e76d0-c3b7-4fe3-a657-b0a4dc6a1bb2	IFood	30	Alimentação	\N	variable	2026-03-19 00:00:00	3	2026	f	\N	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	PAID	2026-03-18 01:44:32.135	f	\N	\N	t
17b1fa7b-ddcb-4d3b-9f60-701acd0879a1	no mercado	120	Alimentação	46054cf5-1dbc-4bd2-808d-325d686a90c6	variable	2026-03-20 00:00:00	3	2026	f	\N	1e6968e3-5390-46fc-bf76-7613eb4e3f08	PENDING	2026-03-20 17:52:08.938	t	2026-03-20 22:44:07.745	\N	t
1ee78c91-5a1d-44d0-8ae5-b4078eb50e6a	Paguei internet 99.90	99.9	Internet	\N	variable	2026-03-25 00:00:00	3	2026	f	\N	1e6968e3-5390-46fc-bf76-7613eb4e3f08	PENDING	2026-03-25 16:28:48.065	f	\N	\N	t
24ccc789-e2d2-49f0-bb1f-68f3a89d12e5	Gilmara	500	Moradia	\N	fixed	2026-06-06 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-06 21:48:52.3	f	\N	68f7fb28-7988-484a-8c74-de09f3159d2f	t
55add55d-1305-4904-bb08-6060832e087e	Loja de Roupa	453.3	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	fixed	2026-04-06 00:00:00	4	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PAID	2026-04-06 21:50:38.153	f	\N	3b2f3e77-9eec-4e0b-b662-0f1dcf113de3	t
1ec7d172-3ca0-4377-82fc-aa68fc7bf73f	Quebra Galho	219.37	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	variable	2026-04-06 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 22:05:44.163	f	\N	\N	t
fb854d17-fd4e-4157-a0d1-af57c7664b93	Emprestimo NU (Felipe)	174.46	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-04-07 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-07 00:19:21.287	f	\N	\N	t
9d165e7e-e2f5-4695-b896-784ac3e02774	Cartão de Crédito Felipe	794.77	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	variable	2026-04-13 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-07 00:04:57.853	f	\N	\N	t
f7fa3e2b-c657-4f00-91a8-d7ef4f8fe0e6	Emprestimos (Felipe)	1147.93	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-04-07 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-07 00:10:38.469	f	\N	\N	t
452aba76-7d76-4fcc-a992-c8643591ebe6	Cartão de Crédito Shirlley	320.36	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	variable	2026-04-13 00:00:00	4	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PAID	2026-04-07 00:05:25.029	f	\N	\N	t
3b626775-70f4-425b-9d2c-5fcab0e9eb38	Gilmara	500	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	fixed	2026-04-06 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 21:48:08.491	f	\N	68f7fb28-7988-484a-8c74-de09f3159d2f	t
b30b1381-0b20-4067-96d5-90d589300876	Energia	258.68	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	variable	2026-04-06 00:00:00	4	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PAID	2026-04-07 00:01:49.032	f	\N	\N	t
8ed0cf08-665d-4c9f-9e4f-877dcbafb3a7	Conta de Agua	84.95	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	variable	2026-04-06 00:00:00	4	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PAID	2026-04-06 22:08:14.744	f	\N	\N	t
2950c1bb-3a0b-4c04-b80c-88f15022eb35	Maria Rossa	380	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	fixed	2026-04-06 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 21:56:43.176	f	\N	749a5941-bec2-41cf-80ad-5077e40bc7a4	t
2afddc36-771d-49c6-91cd-f99faa2a9d23	Conta de Agua	84.95	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	variable	2026-04-10 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 22:16:06.883	t	2026-04-07 00:45:31.582	\N	t
979b25f2-880a-4561-bc50-88348ba11da7	Emprestimo Casamento (Eucharis)	800	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	fixed	2026-04-06 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 22:07:27.459	f	\N	954b5792-164f-4598-a45c-53dff0596f15	t
f90b1fc2-8ca5-4e39-a1e7-eddc2e8cccc5	Aluguel	1300	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	fixed	2026-04-06 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 21:50:06.87	f	\N	aecda765-4698-4f8e-b905-e02387f669fc	t
0e71ef99-a862-41c9-a94b-afb03852755b	Celular (Felipe)	450	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	fixed	2026-04-06 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 21:42:01.604	f	\N	e60ecfa3-ef07-4587-99ba-a75d8a10fed2	t
8e519690-e4db-43fa-929f-8140af480c99	Internet	99.9	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	fixed	2026-04-10 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-07 00:00:06.111	f	\N	184de8b8-4161-4fa2-b5be-29b5ed75807b	t
5b1faf99-64de-4380-b458-0949214e1fba	Aliança	400	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	variable	2026-04-06 00:00:00	4	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PAID	2026-04-06 21:49:20.676	f	\N	\N	t
9ccf5960-97d6-4d8d-986e-77f01781d4be	Tramontin	262.8	Pets	0b8ba15e-951b-48d5-8669-76d2c2622720	fixed	2026-04-11 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 22:03:06.561	f	\N	19a9d493-2f38-4f9e-bb06-52d96064c0a9	t
c9cb82a0-3e7d-4481-8062-739e3100b382	Picados	77.86	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	variable	2026-04-07 00:00:00	4	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PAID	2026-04-07 01:02:40.112	f	\N	\N	t
f2c4efcb-519d-42ef-9688-4dc7dcf32873	Rafael Cardoso	1000	Emprestimos	\N	fixed	2026-05-06 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-07 01:12:09.508	t	2026-05-05 14:26:31.462	07209b93-143a-4950-8bfb-2f7eb393bab3	t
1adae6e1-a0b5-4c80-acf8-ff44628c4f10	Rafael Cardoso	500	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	fixed	2026-04-15 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 21:59:25.634	f	\N	07209b93-143a-4950-8bfb-2f7eb393bab3	t
c9f505b0-629f-48fb-ba01-7ac541b38800	Maria Rossa	380	Emprestimos	\N	fixed	2026-05-06 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-07 01:12:09.367	t	2026-05-06 19:18:03.304	749a5941-bec2-41cf-80ad-5077e40bc7a4	t
1de7106c-73ff-4631-9026-4151a2b88c7b	Gilmara	500	Moradia	\N	fixed	2026-05-06 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 21:48:50.217	f	\N	68f7fb28-7988-484a-8c74-de09f3159d2f	t
ee66738c-7339-4424-b357-bce9c1e4364b	Aluguel	1300	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	fixed	2026-05-06 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-07 01:12:09.068	f	\N	aecda765-4698-4f8e-b905-e02387f669fc	t
e70d9005-9521-41ca-9edc-ad9841bea8bc	Celular (Felipe)	450	Lazer	\N	fixed	2026-05-06 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-06 21:42:20.556	f	\N	e60ecfa3-ef07-4587-99ba-a75d8a10fed2	t
5a40e08a-7b2f-4164-8f67-7bd7191af0de	Loja de Roupa	453.3	Lazer	\N	fixed	2026-05-06 00:00:00	5	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PENDING	2026-04-07 01:12:10.084	f	\N	3b2f3e77-9eec-4e0b-b662-0f1dcf113de3	t
e69d58f3-e735-4c1c-b1a0-ffcf1c9ca573	Futebol Segunda	50	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	fixed	2026-05-08 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-08 11:00:14.596	f	\N	472116b1-c60a-4a85-a744-0bfb439b7d4c	t
390c10c8-0960-479b-957a-c863ac1abe00	Aluguel	1300	Moradia	\N	fixed	2026-06-06 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-08 11:00:41.005	f	\N	aecda765-4698-4f8e-b905-e02387f669fc	t
268cd41f-a8d9-444f-9c10-53c6647ae63e	Maria Rossa	380	Emprestimos	\N	fixed	2026-06-06 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-08 11:00:41.089	f	\N	749a5941-bec2-41cf-80ad-5077e40bc7a4	t
b081c0bf-026b-4e3c-8fea-1240feeee302	Emprestimo Casamento (Eucharis)	800	Emprestimos	\N	fixed	2026-06-06 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-08 11:00:41.337	f	\N	954b5792-164f-4598-a45c-53dff0596f15	t
d261ed91-12ad-4018-8be9-78243880dcd6	Internet	99.9	Moradia	\N	fixed	2026-06-10 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-08 11:00:41.418	f	\N	184de8b8-4161-4fa2-b5be-29b5ed75807b	t
3d3d7797-1fc0-4b7c-a789-a35ad3382559	Futebol Segunda	50	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	fixed	2026-06-08 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-08 11:00:41.5	f	\N	472116b1-c60a-4a85-a744-0bfb439b7d4c	t
fb8feda1-045f-49b6-b9af-4a08d6f98d08	Futebol Segunda	50	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	fixed	2026-04-08 00:00:00	4	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-08 10:59:32.124	f	\N	472116b1-c60a-4a85-a744-0bfb439b7d4c	t
b6dc4979-d604-44dd-bf1c-449501be9c7c	Emprestimos (Shirlley)	432.83	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-04-07 00:00:00	4	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PAID	2026-04-07 00:18:10.527	f	\N	\N	t
e8a572c8-c5c2-4a53-b6ec-608a349ad2f2	Aluguel	1300	Moradia	\N	fixed	2026-07-06 00:00:00	7	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-22 17:50:48.872	f	\N	aecda765-4698-4f8e-b905-e02387f669fc	t
c6819440-26e4-47e8-b2c3-50d836f79f47	Maria Rossa	380	Emprestimos	\N	fixed	2026-07-06 00:00:00	7	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-22 17:50:48.985	f	\N	749a5941-bec2-41cf-80ad-5077e40bc7a4	t
126c0f69-63c3-45ce-9358-20bf32043f12	Rafael Cardoso	1000	Emprestimos	\N	fixed	2026-07-06 00:00:00	7	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-22 17:50:49.061	f	\N	07209b93-143a-4950-8bfb-2f7eb393bab3	t
ea533f6c-2f49-4a66-8a5c-3d79ac53be55	Tramontin	262.8	Pets	\N	fixed	2026-07-11 00:00:00	7	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-22 17:50:49.137	f	\N	19a9d493-2f38-4f9e-bb06-52d96064c0a9	t
6948096c-aba7-4274-95dd-6d78b0e8c1e0	Emprestimo Casamento (Eucharis)	800	Emprestimos	\N	fixed	2026-07-06 00:00:00	7	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-22 17:50:49.212	f	\N	954b5792-164f-4598-a45c-53dff0596f15	t
da26ddc1-62c5-4249-8e81-c38aa314d37c	Internet	99.9	Moradia	\N	fixed	2026-07-10 00:00:00	7	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-22 17:50:49.289	f	\N	184de8b8-4161-4fa2-b5be-29b5ed75807b	t
17f43aec-fe7d-4ade-8af9-0231b267abe8	Tramontin	262.8	Pets	\N	fixed	2026-05-11 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-07 01:12:09.651	t	2026-05-05 14:24:49.863	19a9d493-2f38-4f9e-bb06-52d96064c0a9	t
66bac5fe-1732-41ef-8909-5b2e960def14	Rafael Cardoso	500	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-05-05 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-05 14:26:46.684	f	\N	\N	t
01556395-776d-4e30-be3b-6ab4f206d84f	Shoppe	120.28	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-05-10 00:00:00	5	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PENDING	2026-05-06 19:10:56.242	f	\N	\N	t
e80394f9-1bdf-41b4-99bc-23abd565b4d4	Dona Maria	123	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-05-08 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 19:18:23.998	f	\N	\N	t
9cf77a97-737d-404b-a2a0-d38c7b020592	Itau Shirlley	443.12	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-05-10 00:00:00	5	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PENDING	2026-05-06 19:16:34.318	t	2026-05-06 19:34:37.393	\N	t
926d76ca-50f1-4da7-88ea-21f8a0f93301	Conta de Agua	83.03	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	variable	2026-06-10 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 21:25:40.511	f	\N	\N	t
6de50414-f9e9-4ddd-9ef7-e926b3af3141	Blipay	264.01	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-05-07 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-05-06 19:14:12.961	f	\N	\N	t
86121073-9b12-40ff-9a6e-4b6addb826b9	Joia	429.99	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-05-08 00:00:00	5	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PAID	2026-05-06 19:18:57.1	f	\N	\N	t
fabc4e57-2e16-4593-901e-a10dc805ac4d	Internet	99.9	Moradia	\N	fixed	2026-05-10 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-07 01:12:09.943	f	\N	184de8b8-4161-4fa2-b5be-29b5ed75807b	t
c3e375e1-628e-4ed5-8c20-01846564db44	Cartão de Crédito Felipe	897.79	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	variable	2026-05-13 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-30 22:41:25.964	f	\N	\N	t
e2ba4111-fcc1-4202-9545-1ecafc4e7201	Emprestimo NU	174.75	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-05-08 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-05-06 19:21:59.766	f	\N	\N	t
7c85c96b-db35-447b-8e3c-2ff20bc871f6	Conta de Agua	126.59	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	variable	2026-05-06 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-05-06 21:24:54.587	f	\N	\N	t
83beebc3-3685-4414-9f03-08f347f3da84	Mercado Livre	491.05	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-05-08 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-05-06 19:12:46.833	f	\N	\N	t
8e9e9961-74c0-47c6-b6df-1acdc021463d	Shoppe	458.96	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-05-15 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-05-06 19:08:51.646	f	\N	\N	t
b45cf2a4-57c0-4698-b172-24b862085823	Tramontin	633.58	Pets	0b8ba15e-951b-48d5-8669-76d2c2622720	variable	2026-05-13 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-05 14:25:18.645	f	\N	\N	t
34689170-2072-4f85-8e91-b04a6c27da2b	Cartão de Crédito Shirlley	145.61	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	variable	2026-05-13 00:00:00	5	2026	f	\N	e03ee0ea-9d10-4b28-8600-e230ae0a266d	PAID	2026-04-30 22:42:45.515	f	\N	\N	t
c0994979-c0c9-44f9-85ab-ef4e9a07eb70	Emprestimo Casamento (Eucharis)	800	Emprestimos	\N	fixed	2026-05-06 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-04-07 01:12:09.804	f	\N	954b5792-164f-4598-a45c-53dff0596f15	t
8f25df19-3fbb-46be-b1aa-4f64ab50ffd8	Conta de Agua	90.65	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	variable	2026-07-10 00:00:00	7	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 21:26:21.444	f	\N	\N	t
61513eb4-b7c4-4816-8f37-f01239ef8e9e	Conta de Luz	273.35	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	variable	2026-06-10 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 21:28:47.081	f	\N	\N	t
b7f12e66-a93b-40a4-a212-64a3358dd383	Aluguel	1300	Moradia	\N	fixed	2026-08-06 00:00:00	8	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 21:48:46.705	f	\N	aecda765-4698-4f8e-b905-e02387f669fc	t
9697009f-40b3-4764-985a-2c7a99d226f1	Maria Rossa	380	Emprestimos	\N	fixed	2026-08-06 00:00:00	8	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 21:48:46.734	f	\N	749a5941-bec2-41cf-80ad-5077e40bc7a4	t
6617db97-f370-43ec-a314-e728b7729f75	Rafael Cardoso	1000	Emprestimos	\N	fixed	2026-08-06 00:00:00	8	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 21:48:46.756	f	\N	07209b93-143a-4950-8bfb-2f7eb393bab3	t
e5f9d4b1-324f-4986-88f5-e2268e1b24a0	Internet	99.9	Moradia	\N	fixed	2026-08-10 00:00:00	8	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 21:48:46.814	f	\N	184de8b8-4161-4fa2-b5be-29b5ed75807b	t
4694a138-ec34-419d-b7fd-17a2036fb279	Rafael Cardoso	1000	Emprestimos	\N	fixed	2026-06-06 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-08 11:00:41.171	t	2026-05-06 22:22:58.604	07209b93-143a-4950-8bfb-2f7eb393bab3	t
ea2450be-6543-4faf-84b7-3d2951c0773c	Carro Rafael	500	Emprestimos	559567e2-4b93-450e-907c-9f594eb90751	variable	2026-06-15 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 22:23:28.516	f	\N	\N	t
7e03ca67-5a11-4497-8848-e85c69c3f005	Tramontin	537.25	Pets	0b8ba15e-951b-48d5-8669-76d2c2622720	fixed	2026-06-11 00:00:00	6	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-04-08 11:00:41.254	f	\N	19a9d493-2f38-4f9e-bb06-52d96064c0a9	t
409b229f-ab9f-4640-ad54-b5658fa67b96	Quebra Galho	414.94	Lazer	f0b7da84-6098-48e2-8c94-a93aa6c52f89	variable	2026-05-08 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-05-06 21:38:45.373	f	\N	\N	t
1ee14fc5-db12-4906-8138-034ba5ae4b35	Conta de Luz	175.9	Moradia	933ecbd2-623d-46c9-b686-f24567ec71cd	variable	2026-05-08 00:00:00	5	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PAID	2026-05-06 21:27:31.398	f	\N	\N	t
4b14c21a-d67d-4b89-84fa-ff2f83721c4c	Maria Rossa	380	Emprestimos	\N	fixed	2026-09-06 00:00:00	9	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-08 17:04:58.001	f	\N	749a5941-bec2-41cf-80ad-5077e40bc7a4	t
a370328e-5d86-4ed6-973e-c57ade6e2544	Rafael Cardoso	1000	Emprestimos	\N	fixed	2026-09-06 00:00:00	9	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-08 17:04:58.034	f	\N	07209b93-143a-4950-8bfb-2f7eb393bab3	t
5fdf1223-ffe7-401b-8d87-50b2716b28af	Internet	99.9	Moradia	\N	fixed	2026-09-10 00:00:00	9	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-08 17:04:58.055	f	\N	184de8b8-4161-4fa2-b5be-29b5ed75807b	t
dd3356f5-5f1b-45d9-95c4-89163cdfc011	Emprestimo Casamento (Eucharis)	800	Emprestimos	\N	fixed	2026-08-06 00:00:00	8	2026	f	\N	d8c5dd89-683e-4d5d-9981-3b3545345573	PENDING	2026-05-06 21:48:46.776	t	2026-05-08 17:05:49.098	954b5792-164f-4598-a45c-53dff0596f15	t
\.


--
-- Data for Name: ExpenseAdjustment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ExpenseAdjustment" (id, "familyId", "fromPersonId", "toPersonId", amount, description, date, month, year, "createdAt") FROM stdin;
\.


--
-- Data for Name: ExtraIncome; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ExtraIncome" (id, description, value, date, month, year, "personId", "createdAt", is_deleted, dt_deleted) FROM stdin;
dec0fdb2-22cf-467c-931c-bbf8b580061c	Meu pai me deu	150	2026-03-16 00:00:00	3	2026	1e6968e3-5390-46fc-bf76-7613eb4e3f08	2026-03-18 21:36:02.031	t	2026-03-18 21:37:45.17
f42dfc20-6c85-4988-a351-ee849214d456	Ganhei do meu pai	150	2026-03-17 00:00:00	3	2026	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	2026-03-18 21:38:24.245	f	\N
3b557584-1694-404d-a631-01ac74cb6589	recebi da minha irmã	60	2026-03-20 00:00:00	3	2026	1e6968e3-5390-46fc-bf76-7613eb4e3f08	2026-03-20 17:52:09.813	t	2026-03-20 18:33:45.633
ed35759c-514d-4268-aea9-4267b8eba761	Emprestimo (Felipe)	641.98	2026-04-07 00:00:00	4	2026	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-07 00:59:04.163	f	\N
1137f7ca-14d8-4587-ba35-a1ab51fcf755	Celular (Estefani)	75	2026-04-07 00:00:00	4	2026	e03ee0ea-9d10-4b28-8600-e230ae0a266d	2026-04-07 01:00:23.911	f	\N
fcda3350-e670-47ed-96d5-a2dc6ff1ca2f	Emprestimo Shopee	444	2026-05-08 00:00:00	5	2026	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-05-08 13:06:31.45	f	\N
e1c94048-c057-400f-ac93-cb776b34c453	Emprestimo Mercado Pago	257.78	2026-05-08 00:00:00	5	2026	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-05-08 13:07:06.74	f	\N
\.


--
-- Data for Name: Family; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Family" (id, name, "createdAt") FROM stdin;
93b2a024-d640-4ba8-b738-7439ad968345	Família de Felipe Gross Teste	2026-03-18 01:22:45.115
f019492c-c7bc-4477-9f93-2b4be9316978	Família de Gustavo Quinhonero	2026-03-20 18:46:51.455
087e26fc-406b-42ad-abb6-b88bf7e4a082	Família de Lucas Trindade	2026-03-21 03:37:03.074
cc923faf-ec91-460a-8f0a-0a478d438459	Família de FERNANDO ESCANDIEL DOS SANTOS	2026-03-31 19:29:12.094
25aa2fbe-54b1-48e1-9c94-7f1d1e1b41a7	Família Maciel Augusto	2026-03-18 21:52:32.834
73992fc9-64a8-4cef-be57-a009c080d1ae	Família Maciel Augusto	2026-04-06 21:13:21.802
\.


--
-- Data for Name: Goal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Goal" (id, description, type, "targetValue", "currentValue", deadline, "familyId", "personId", status, "createdAt") FROM stdin;
109f8b52-4397-4470-9f0b-646f3a20534f	Casa	purchase	500000	0	1999-07-31 00:00:00	25aa2fbe-54b1-48e1-9c94-7f1d1e1b41a7	\N	active	2026-03-18 22:10:53.77
4b61bff0-7a35-4090-a6d9-ac11881e430a	Carro	purchase	130000	0	\N	93b2a024-d640-4ba8-b738-7439ad968345	\N	active	2026-03-20 15:03:38.257
30ec2dd3-b4d6-4cfc-875c-972758c31909	Quitar Santander	debt	14500	0	2026-12-31 00:00:00	93b2a024-d640-4ba8-b738-7439ad968345	\N	active	2026-03-20 15:18:18.126
\.


--
-- Data for Name: GoalContribution; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."GoalContribution" (id, "goalId", value, date, observation, "createdAt") FROM stdin;
\.


--
-- Data for Name: Income; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Income" (id, description, value, date, month, year, type, "personId", "sourceId", "createdAt", is_deleted, dt_deleted) FROM stdin;
41b541ac-3b02-4a5a-a1c2-54093d33d781	salario	5000	2026-03-17 00:00:00	3	2026	fixed	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	\N	2026-03-18 01:24:38.209	f	\N
2c781205-ea8b-494a-85c6-6f97536c6317	Salario	2100	2026-03-18 00:00:00	3	2026	fixed	1e6968e3-5390-46fc-bf76-7613eb4e3f08	\N	2026-03-18 18:44:00.513	t	2026-03-18 18:57:51.592
dbb7254f-9fb6-4f26-9db8-2942cb9969e6	salario	2100	2026-03-18 00:00:00	3	2026	fixed	b0a52965-93c0-4486-8c58-c4c73e2b8967	\N	2026-03-18 18:58:18.366	f	\N
bd13b56e-3261-40cc-99c6-a6fdd4500c51	Salário	2300	2026-02-09 00:00:00	2	2026	fixed	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	\N	2026-03-20 16:15:35.226	f	\N
c6e1872f-12e7-4d3e-882f-f76b6100a7dc	Recebi 3000 de salário	3000	2026-03-25 00:00:00	3	2026	flex	4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	\N	2026-03-25 16:42:14.527	f	\N
02e164fc-0a48-4847-be81-074d25f02e0f	Salário	7044.58	2026-04-06 00:00:00	4	2026	fixed	d8c5dd89-683e-4d5d-9981-3b3545345573	\N	2026-04-06 21:31:24.13	f	\N
cf6ff7ba-4964-47a5-8c48-575ed242ee0f	Salário	1500	2026-04-06 00:00:00	4	2026	fixed	e03ee0ea-9d10-4b28-8600-e230ae0a266d	\N	2026-04-06 21:59:56.804	t	2026-04-08 11:17:53.151
5d731318-4eaf-4c1f-b7dc-610e63883906	Salário	766.56	2026-04-07 00:00:00	4	2026	fixed	e03ee0ea-9d10-4b28-8600-e230ae0a266d	\N	2026-04-08 11:20:18.419	f	\N
4fc7f8cc-292e-4ac0-955c-82fb33f8ef59	Salario	627.26	2026-05-06 00:00:00	5	2026	fixed	e03ee0ea-9d10-4b28-8600-e230ae0a266d	\N	2026-04-30 22:43:17.56	f	\N
d3a202a5-1845-4eb8-81dd-fe72405bfd33	Salário	6616.74	2026-05-08 00:00:00	5	2026	fixed	d8c5dd89-683e-4d5d-9981-3b3545345573	\N	2026-04-30 22:36:19.914	t	2026-05-04 00:26:26.119
d1713fba-cc4a-4d96-acc1-28421eeb9db2	Salário	6731.34	2026-05-08 00:00:00	5	2026	fixed	d8c5dd89-683e-4d5d-9981-3b3545345573	\N	2026-05-04 00:26:44.529	t	2026-05-05 00:55:25.12
2204c159-414a-488f-800c-b373ef80759c	Salário	6613.56	2026-05-05 00:00:00	5	2026	fixed	d8c5dd89-683e-4d5d-9981-3b3545345573	\N	2026-05-05 00:55:39.143	f	\N
0a147cb4-f80e-4b07-a96f-f4247dfda099	Salário	7256.59	2026-06-10 00:00:00	6	2026	fixed	d8c5dd89-683e-4d5d-9981-3b3545345573	\N	2026-05-05 14:31:51.972	f	\N
cfa5eb98-0426-4033-b9c4-5323b0acb2eb	Salario Shirlley	1712.97	2026-06-05 00:00:00	6	2026	fixed	e03ee0ea-9d10-4b28-8600-e230ae0a266d	\N	2026-05-06 22:25:03.426	f	\N
\.


--
-- Data for Name: IncomeSource; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."IncomeSource" (id, description, value, type, "isRecurring", "startDate", "endDate", active, "personId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Person; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Person" (id, name, phone, email, cpf, "birthDate", "userId", "familyId", "createdAt", "hasAccess") FROM stdin;
1e6968e3-5390-46fc-bf76-7613eb4e3f08	Pietro Maciel Augusto	\N	\N	\N	\N	244814b8-1021-70b6-0a0f-d837b8a2de02	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 15:47:51.994	f
b0a52965-93c0-4486-8c58-c4c73e2b8967	Felipe Teste 2	48991239950	felipe.3107.augusto@outlook.com	\N	\N	34f83438-9001-709a-9f2c-0922a6640b70	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 15:46:24.729	t
4a6fd93e-eda3-48ea-a57f-582cfdc1b43b	Felipe Gross Teste	48991239950	felipe.066183.augusto@gmail.com	06618396999	1999-07-31 00:00:00	244814b8-1021-70b6-0a0f-d837b8a2de02	93b2a024-d640-4ba8-b738-7439ad968345	2026-03-18 01:22:45.545	t
337796f0-1c6e-49ce-8c58-10c493ee9008	Gustavo Quinhonero	11945904590	gustavosantos962@gmail.com	45470746828	1996-10-11 00:00:00	e49824d8-a061-7095-34c8-267a1e80d34f	f019492c-c7bc-4477-9f93-2b4be9316978	2026-03-20 18:46:53.234	f
52aecba0-7491-46c5-86c7-a54c4ea2d5a8	Lucas Trindade	11962498126	trindadebra@gmail.com	\N	1996-07-28 00:00:00	64f82438-c081-7060-e008-baafa34a3c77	087e26fc-406b-42ad-abb6-b88bf7e4a082	2026-03-21 03:37:03.961	f
9ba7e60f-fc15-4f37-955d-0dec271a2dc9	FERNANDO ESCANDIEL DOS SANTOS	48992116065	fernando@escandiel.com.br	\N	2026-03-24 00:00:00	14d82498-9071-70c0-21b6-cc3063f9490d	cc923faf-ec91-460a-8f0a-0a478d438459	2026-03-31 19:29:13.391	f
d8c5dd89-683e-4d5d-9981-3b3545345573	Felipe G. Augusto	48991239950	felipe.3107.augusto@gmail.com	06618396999	1999-07-31 00:00:00	34188428-f0c1-70ae-81d4-c86e916f4ec0	73992fc9-64a8-4cef-be57-a009c080d1ae	2026-04-06 21:13:22.357	f
e03ee0ea-9d10-4b28-8600-e230ae0a266d	Shirlley M. Augusto	\N	shirlleymaciel85@gmail.com	\N	\N	94289458-6031-70a6-e9a4-448d9f4e9a15	73992fc9-64a8-4cef-be57-a009c080d1ae	2026-04-06 21:14:26.253	t
\.


--
-- Data for Name: RecurringExpense; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."RecurringExpense" (id, description, value, "categoryName", "personId", "startDate", "endDate", active, "createdAt", "updatedAt") FROM stdin;
e60ecfa3-ef07-4587-99ba-a75d8a10fed2	Celular (Felipe)	450	Lazer	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-06 00:00:00	2026-05-06 00:00:00	t	2026-04-06 21:42:01.507	2026-04-06 21:42:01.507
68f7fb28-7988-484a-8c74-de09f3159d2f	Gilmara	500	Moradia	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-06 00:00:00	2026-06-06 00:00:00	t	2026-04-06 21:48:08.408	2026-04-06 21:48:08.408
aecda765-4698-4f8e-b905-e02387f669fc	Aluguel	1300	Moradia	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-06 00:00:00	2026-08-06 00:00:00	t	2026-04-06 21:50:06.795	2026-04-06 21:50:06.795
3b2f3e77-9eec-4e0b-b662-0f1dcf113de3	Loja de Roupa	453.3	Lazer	e03ee0ea-9d10-4b28-8600-e230ae0a266d	2026-04-06 00:00:00	2026-05-06 00:00:00	t	2026-04-06 21:50:38.069	2026-04-06 21:50:38.069
749a5941-bec2-41cf-80ad-5077e40bc7a4	Maria Rossa	380	Emprestimos	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-06 00:00:00	2026-10-06 00:00:00	t	2026-04-06 21:56:43.094	2026-04-06 21:56:43.094
07209b93-143a-4950-8bfb-2f7eb393bab3	Rafael Cardoso	1000	Emprestimos	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-06 00:00:00	2026-09-06 00:00:00	t	2026-04-06 21:59:25.563	2026-04-06 21:59:25.563
19a9d493-2f38-4f9e-bb06-52d96064c0a9	Tramontin	262.8	Pets	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-11 00:00:00	2026-07-11 00:00:00	t	2026-04-06 22:03:06.485	2026-04-06 22:03:06.485
954b5792-164f-4598-a45c-53dff0596f15	Emprestimo Casamento (Eucharis)	800	Emprestimos	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-06 00:00:00	2026-08-06 00:00:00	t	2026-04-06 22:07:27.37	2026-04-06 22:07:27.37
184de8b8-4161-4fa2-b5be-29b5ed75807b	Internet	99.9	Moradia	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-10 00:00:00	2026-12-10 00:00:00	t	2026-04-07 00:00:06.025	2026-04-07 00:00:06.025
472116b1-c60a-4a85-a744-0bfb439b7d4c	Futebol Segunda	40	Lazer	d8c5dd89-683e-4d5d-9981-3b3545345573	2026-04-08 00:00:00	2026-06-08 00:00:00	t	2026-04-08 10:59:31.992	2026-04-08 10:59:31.992
\.


--
-- Data for Name: Salary; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Salary" (id, "personId", value, month, year, "createdAt", "updatedAt", is_deleted, dt_deleted) FROM stdin;
\.


--
-- Data for Name: TelegramActivationCode; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TelegramActivationCode" (id, "userId", code, "expiresAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: TelegramLink; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TelegramLink" (id, "userId", "telegramUserId", "telegramChatId", "telegramUsername", "createdAt", "updatedAt") FROM stdin;
bc0324b4-6cdc-4a9e-80c0-80ea1da4f396	244814b8-1021-70b6-0a0f-d837b8a2de02	8699401298	8699401298	felipe_g_augusto	2026-03-25 16:28:17.159	2026-03-25 16:28:17.159
\.


--
-- Data for Name: TelegramPendingAction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TelegramPendingAction" (id, "userId", "telegramChatId", "actionType", payload, status, "createdAt", "updatedAt") FROM stdin;
e66fc4c9-1e0c-4b47-83d0-b1ffca734eaa	244814b8-1021-70b6-0a0f-d837b8a2de02	8699401298	create_record	{"type": "expense", "value": 99.9, "description": "Paguei internet 99.90", "categoryName": "Internet"}	confirmed	2026-03-25 16:28:42.763	2026-03-25 16:28:47.303
10f69d2f-d5d7-4df9-b8cd-b04f5601c2aa	244814b8-1021-70b6-0a0f-d837b8a2de02	8699401298	create_record	{"type": "income", "value": 3000, "description": "Recebi 3000 de salário", "categoryName": "Salário"}	confirmed	2026-03-25 16:42:10.723	2026-03-25 16:42:13.982
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2026-02-22 16:51:50
20211116045059	2026-02-22 16:51:50
20211116050929	2026-02-22 16:51:50
20211116051442	2026-02-22 16:51:50
20211116212300	2026-02-22 16:51:50
20211116213355	2026-02-22 16:51:50
20211116213934	2026-02-22 16:51:50
20211116214523	2026-02-22 16:51:50
20211122062447	2026-02-22 16:51:50
20211124070109	2026-02-22 16:51:50
20211202204204	2026-02-22 16:51:50
20211202204605	2026-02-22 16:51:50
20211210212804	2026-02-22 16:51:50
20211228014915	2026-02-22 16:51:50
20220107221237	2026-02-22 16:51:50
20220228202821	2026-02-22 16:51:50
20220312004840	2026-02-22 16:51:50
20220603231003	2026-02-22 16:51:50
20220603232444	2026-02-22 16:51:50
20220615214548	2026-02-22 16:51:50
20220712093339	2026-02-22 16:51:50
20220908172859	2026-02-22 16:51:50
20220916233421	2026-02-22 16:51:50
20230119133233	2026-02-22 16:51:50
20230128025114	2026-02-22 16:51:51
20230128025212	2026-02-22 16:51:51
20230227211149	2026-02-22 16:51:51
20230228184745	2026-02-22 16:51:51
20230308225145	2026-02-22 16:51:51
20230328144023	2026-02-22 16:51:51
20231018144023	2026-02-22 16:51:51
20231204144023	2026-02-22 16:51:51
20231204144024	2026-02-22 16:51:51
20231204144025	2026-02-22 16:51:51
20240108234812	2026-02-22 16:51:51
20240109165339	2026-02-22 16:51:51
20240227174441	2026-02-22 16:51:51
20240311171622	2026-02-22 16:51:51
20240321100241	2026-02-22 16:51:51
20240401105812	2026-02-22 16:51:51
20240418121054	2026-02-22 16:51:51
20240523004032	2026-02-22 16:51:51
20240618124746	2026-02-22 16:51:51
20240801235015	2026-02-22 16:51:51
20240805133720	2026-02-22 16:51:51
20240827160934	2026-02-22 16:51:51
20240919163303	2026-02-22 16:51:51
20240919163305	2026-02-22 16:51:51
20241019105805	2026-02-22 16:51:51
20241030150047	2026-02-22 16:51:51
20241108114728	2026-02-22 16:51:51
20241121104152	2026-02-22 16:51:51
20241130184212	2026-02-22 16:51:51
20241220035512	2026-02-22 16:51:51
20241220123912	2026-02-22 16:51:51
20241224161212	2026-02-22 16:51:51
20250107150512	2026-02-22 16:51:51
20250110162412	2026-02-22 16:51:51
20250123174212	2026-02-22 16:51:51
20250128220012	2026-02-22 16:51:51
20250506224012	2026-02-22 16:51:51
20250523164012	2026-02-22 16:51:51
20250714121412	2026-02-22 16:51:51
20250905041441	2026-02-22 16:51:51
20251103001201	2026-02-22 16:51:51
20251120212548	2026-02-22 16:51:51
20251120215549	2026-02-22 16:51:51
20260218120000	2026-04-17 14:11:11
20260326120000	2026-04-17 14:11:11
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at, action_filter) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2026-02-22 16:51:44.101268
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2026-02-22 16:51:44.133636
2	storage-schema	f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd	2026-02-22 16:51:44.140651
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2026-02-22 16:51:44.164189
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2026-02-22 16:51:44.17754
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2026-02-22 16:51:44.182889
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2026-02-22 16:51:44.189432
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2026-02-22 16:51:44.195933
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2026-02-22 16:51:44.201699
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2026-02-22 16:51:44.207287
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2026-02-22 16:51:44.212925
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2026-02-22 16:51:44.219429
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2026-02-22 16:51:44.225
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2026-02-22 16:51:44.230373
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2026-02-22 16:51:44.236112
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2026-02-22 16:51:44.256528
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2026-02-22 16:51:44.262024
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2026-02-22 16:51:44.267361
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2026-02-22 16:51:44.273799
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2026-02-22 16:51:44.281247
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2026-02-22 16:51:44.286862
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2026-02-22 16:51:44.292978
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2026-02-22 16:51:44.305351
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2026-02-22 16:51:44.315437
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2026-02-22 16:51:44.321053
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2026-02-22 16:51:44.32655
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2026-02-22 16:51:44.332527
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2026-02-22 16:51:44.338371
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2026-02-22 16:51:44.344256
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2026-02-22 16:51:44.349388
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2026-02-22 16:51:44.354547
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2026-02-22 16:51:44.359729
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2026-02-22 16:51:44.365069
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2026-02-22 16:51:44.370231
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2026-02-22 16:51:44.375384
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2026-02-22 16:51:44.380546
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2026-02-22 16:51:44.386907
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2026-02-22 16:51:44.392219
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2026-02-22 16:51:44.398157
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2026-02-22 16:51:44.408065
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2026-02-22 16:51:44.414728
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2026-02-22 16:51:44.420358
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2026-02-22 16:51:44.425515
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2026-02-22 16:51:44.430452
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2026-02-22 16:51:44.437519
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2026-02-22 16:51:44.443302
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2026-02-22 16:51:44.456882
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2026-02-22 16:51:44.463608
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2026-02-22 16:51:44.468899
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2026-02-22 16:51:44.483388
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-02-22 16:51:44.489315
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-02-22 16:51:45.261726
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-02-22 16:51:45.264086
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-02-22 16:51:45.274022
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-02-22 16:51:45.277978
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-02-22 16:51:45.280256
57	s3-multipart-uploads-metadata	f127886e00d1b374fadbc7c6b31e09336aad5287	2026-04-01 16:39:44.485709
58	operation-ergonomics	00ca5d483b3fe0d522133d9002ccc5df98365120	2026-04-01 16:39:44.51199
56	fix-optimized-search-function	b823ed1e418101032fa01374edc9a436e54e3ed4	2026-02-22 16:51:45.286446
59	drop-unused-functions	38456f13e39691c2bbb4b5151d0d1cdbabd4a8c4	2026-05-08 18:28:03.367321
60	optimize-existing-functions-again	db35e1c91a9201e59f4fef8d972c2f277d68b157	2026-05-08 18:28:03.377609
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata, metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: Budget Budget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Budget"
    ADD CONSTRAINT "Budget_pkey" PRIMARY KEY (id);


--
-- Name: Category Category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Category"
    ADD CONSTRAINT "Category_pkey" PRIMARY KEY (id);


--
-- Name: CoupleModeConfig CoupleModeConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoupleModeConfig"
    ADD CONSTRAINT "CoupleModeConfig_pkey" PRIMARY KEY (id);


--
-- Name: CreditCardInstallment CreditCardInstallment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardInstallment"
    ADD CONSTRAINT "CreditCardInstallment_pkey" PRIMARY KEY (id);


--
-- Name: CreditCardInvoice CreditCardInvoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardInvoice"
    ADD CONSTRAINT "CreditCardInvoice_pkey" PRIMARY KEY (id);


--
-- Name: CreditCardPurchase CreditCardPurchase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardPurchase"
    ADD CONSTRAINT "CreditCardPurchase_pkey" PRIMARY KEY (id);


--
-- Name: CreditCard CreditCard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "CreditCard_pkey" PRIMARY KEY (id);


--
-- Name: ExpenseAdjustment ExpenseAdjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExpenseAdjustment"
    ADD CONSTRAINT "ExpenseAdjustment_pkey" PRIMARY KEY (id);


--
-- Name: Expense Expense_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_pkey" PRIMARY KEY (id);


--
-- Name: ExtraIncome ExtraIncome_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExtraIncome"
    ADD CONSTRAINT "ExtraIncome_pkey" PRIMARY KEY (id);


--
-- Name: Family Family_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Family"
    ADD CONSTRAINT "Family_pkey" PRIMARY KEY (id);


--
-- Name: GoalContribution GoalContribution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GoalContribution"
    ADD CONSTRAINT "GoalContribution_pkey" PRIMARY KEY (id);


--
-- Name: Goal Goal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Goal"
    ADD CONSTRAINT "Goal_pkey" PRIMARY KEY (id);


--
-- Name: IncomeSource IncomeSource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."IncomeSource"
    ADD CONSTRAINT "IncomeSource_pkey" PRIMARY KEY (id);


--
-- Name: Income Income_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Income"
    ADD CONSTRAINT "Income_pkey" PRIMARY KEY (id);


--
-- Name: Person Person_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Person"
    ADD CONSTRAINT "Person_pkey" PRIMARY KEY (id);


--
-- Name: RecurringExpense RecurringExpense_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RecurringExpense"
    ADD CONSTRAINT "RecurringExpense_pkey" PRIMARY KEY (id);


--
-- Name: Salary Salary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Salary"
    ADD CONSTRAINT "Salary_pkey" PRIMARY KEY (id);


--
-- Name: TelegramActivationCode TelegramActivationCode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TelegramActivationCode"
    ADD CONSTRAINT "TelegramActivationCode_pkey" PRIMARY KEY (id);


--
-- Name: TelegramLink TelegramLink_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TelegramLink"
    ADD CONSTRAINT "TelegramLink_pkey" PRIMARY KEY (id);


--
-- Name: TelegramPendingAction TelegramPendingAction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TelegramPendingAction"
    ADD CONSTRAINT "TelegramPendingAction_pkey" PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- Name: Budget_categoryName_month_year_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Budget_categoryName_month_year_key" ON public."Budget" USING btree ("categoryName", month, year);


--
-- Name: Budget_familyId_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Budget_familyId_month_year_idx" ON public."Budget" USING btree ("familyId", month, year);


--
-- Name: Budget_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Budget_month_year_idx" ON public."Budget" USING btree (month, year);


--
-- Name: Category_familyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Category_familyId_idx" ON public."Category" USING btree ("familyId");


--
-- Name: Category_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Category_type_idx" ON public."Category" USING btree (type);


--
-- Name: CoupleModeConfig_familyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoupleModeConfig_familyId_idx" ON public."CoupleModeConfig" USING btree ("familyId");


--
-- Name: CoupleModeConfig_familyId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoupleModeConfig_familyId_key" ON public."CoupleModeConfig" USING btree ("familyId");


--
-- Name: CreditCardInstallment_invoiceId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardInstallment_invoiceId_idx" ON public."CreditCardInstallment" USING btree ("invoiceId");


--
-- Name: CreditCardInstallment_purchaseId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardInstallment_purchaseId_idx" ON public."CreditCardInstallment" USING btree ("purchaseId");


--
-- Name: CreditCardInstallment_referenceMonth_referenceYear_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardInstallment_referenceMonth_referenceYear_idx" ON public."CreditCardInstallment" USING btree ("referenceMonth", "referenceYear");


--
-- Name: CreditCardInstallment_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardInstallment_status_idx" ON public."CreditCardInstallment" USING btree (status);


--
-- Name: CreditCardInvoice_creditCardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardInvoice_creditCardId_idx" ON public."CreditCardInvoice" USING btree ("creditCardId");


--
-- Name: CreditCardInvoice_creditCardId_referenceMonth_referenceYear_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardInvoice_creditCardId_referenceMonth_referenceYear_idx" ON public."CreditCardInvoice" USING btree ("creditCardId", "referenceMonth", "referenceYear");


--
-- Name: CreditCardInvoice_creditCardId_referenceMonth_referenceYear_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CreditCardInvoice_creditCardId_referenceMonth_referenceYear_key" ON public."CreditCardInvoice" USING btree ("creditCardId", "referenceMonth", "referenceYear");


--
-- Name: CreditCardInvoice_dueDate_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardInvoice_dueDate_idx" ON public."CreditCardInvoice" USING btree ("dueDate");


--
-- Name: CreditCardInvoice_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardInvoice_status_idx" ON public."CreditCardInvoice" USING btree (status);


--
-- Name: CreditCardPurchase_creditCardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardPurchase_creditCardId_idx" ON public."CreditCardPurchase" USING btree ("creditCardId");


--
-- Name: CreditCardPurchase_familyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardPurchase_familyId_idx" ON public."CreditCardPurchase" USING btree ("familyId");


--
-- Name: CreditCardPurchase_ownerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardPurchase_ownerId_idx" ON public."CreditCardPurchase" USING btree ("ownerId");


--
-- Name: CreditCardPurchase_purchaseDate_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCardPurchase_purchaseDate_idx" ON public."CreditCardPurchase" USING btree ("purchaseDate");


--
-- Name: CreditCard_familyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCard_familyId_idx" ON public."CreditCard" USING btree ("familyId");


--
-- Name: CreditCard_familyId_isActive_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCard_familyId_isActive_idx" ON public."CreditCard" USING btree ("familyId", "isActive");


--
-- Name: CreditCard_ownerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditCard_ownerId_idx" ON public."CreditCard" USING btree ("ownerId");


--
-- Name: ExpenseAdjustment_familyId_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExpenseAdjustment_familyId_month_year_idx" ON public."ExpenseAdjustment" USING btree ("familyId", month, year);


--
-- Name: Expense_categoryId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_categoryId_idx" ON public."Expense" USING btree ("categoryId");


--
-- Name: Expense_creditCardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_creditCardId_idx" ON public."Expense" USING btree ("creditCardId");


--
-- Name: Expense_is_deleted_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_is_deleted_month_year_idx" ON public."Expense" USING btree (is_deleted, month, year);


--
-- Name: Expense_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_month_year_idx" ON public."Expense" USING btree (month, year);


--
-- Name: Expense_personId_is_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_personId_is_deleted_idx" ON public."Expense" USING btree ("personId", is_deleted);


--
-- Name: Expense_personId_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_personId_month_year_idx" ON public."Expense" USING btree ("personId", month, year);


--
-- Name: Expense_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_status_idx" ON public."Expense" USING btree (status);


--
-- Name: ExtraIncome_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExtraIncome_month_year_idx" ON public."ExtraIncome" USING btree (month, year);


--
-- Name: ExtraIncome_personId_is_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExtraIncome_personId_is_deleted_idx" ON public."ExtraIncome" USING btree ("personId", is_deleted);


--
-- Name: ExtraIncome_personId_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExtraIncome_personId_month_year_idx" ON public."ExtraIncome" USING btree ("personId", month, year);


--
-- Name: GoalContribution_goalId_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GoalContribution_goalId_date_idx" ON public."GoalContribution" USING btree ("goalId", date);


--
-- Name: GoalContribution_goalId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GoalContribution_goalId_idx" ON public."GoalContribution" USING btree ("goalId");


--
-- Name: Goal_familyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Goal_familyId_idx" ON public."Goal" USING btree ("familyId");


--
-- Name: Goal_familyId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Goal_familyId_status_idx" ON public."Goal" USING btree ("familyId", status);


--
-- Name: Goal_personId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Goal_personId_idx" ON public."Goal" USING btree ("personId");


--
-- Name: IncomeSource_personId_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IncomeSource_personId_active_idx" ON public."IncomeSource" USING btree ("personId", active);


--
-- Name: IncomeSource_personId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IncomeSource_personId_idx" ON public."IncomeSource" USING btree ("personId");


--
-- Name: Income_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Income_month_year_idx" ON public."Income" USING btree (month, year);


--
-- Name: Income_personId_is_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Income_personId_is_deleted_idx" ON public."Income" USING btree ("personId", is_deleted);


--
-- Name: Income_personId_month_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Income_personId_month_year_idx" ON public."Income" USING btree ("personId", month, year);


--
-- Name: Income_sourceId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Income_sourceId_idx" ON public."Income" USING btree ("sourceId");


--
-- Name: Person_familyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Person_familyId_idx" ON public."Person" USING btree ("familyId");


--
-- Name: Person_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Person_userId_idx" ON public."Person" USING btree ("userId");


--
-- Name: RecurringExpense_personId_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RecurringExpense_personId_active_idx" ON public."RecurringExpense" USING btree ("personId", active);


--
-- Name: RecurringExpense_personId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RecurringExpense_personId_idx" ON public."RecurringExpense" USING btree ("personId");


--
-- Name: Salary_personId_is_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Salary_personId_is_deleted_idx" ON public."Salary" USING btree ("personId", is_deleted);


--
-- Name: Salary_personId_month_year_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Salary_personId_month_year_key" ON public."Salary" USING btree ("personId", month, year);


--
-- Name: TelegramActivationCode_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TelegramActivationCode_code_idx" ON public."TelegramActivationCode" USING btree (code);


--
-- Name: TelegramActivationCode_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TelegramActivationCode_code_key" ON public."TelegramActivationCode" USING btree (code);


--
-- Name: TelegramActivationCode_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TelegramActivationCode_userId_key" ON public."TelegramActivationCode" USING btree ("userId");


--
-- Name: TelegramLink_telegramUserId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TelegramLink_telegramUserId_idx" ON public."TelegramLink" USING btree ("telegramUserId");


--
-- Name: TelegramLink_telegramUserId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TelegramLink_telegramUserId_key" ON public."TelegramLink" USING btree ("telegramUserId");


--
-- Name: TelegramLink_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TelegramLink_userId_idx" ON public."TelegramLink" USING btree ("userId");


--
-- Name: TelegramLink_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TelegramLink_userId_key" ON public."TelegramLink" USING btree ("userId");


--
-- Name: TelegramPendingAction_telegramChatId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TelegramPendingAction_telegramChatId_status_idx" ON public."TelegramPendingAction" USING btree ("telegramChatId", status);


--
-- Name: TelegramPendingAction_userId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TelegramPendingAction_userId_status_idx" ON public."TelegramPendingAction" USING btree ("userId", status);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_key ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: Budget Budget_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Budget"
    ADD CONSTRAINT "Budget_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public."Category"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Category Category_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Category"
    ADD CONSTRAINT "Category_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public."Family"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditCardInstallment CreditCardInstallment_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardInstallment"
    ADD CONSTRAINT "CreditCardInstallment_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public."CreditCardInvoice"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CreditCardInstallment CreditCardInstallment_purchaseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardInstallment"
    ADD CONSTRAINT "CreditCardInstallment_purchaseId_fkey" FOREIGN KEY ("purchaseId") REFERENCES public."CreditCardPurchase"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CreditCardInvoice CreditCardInvoice_creditCardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardInvoice"
    ADD CONSTRAINT "CreditCardInvoice_creditCardId_fkey" FOREIGN KEY ("creditCardId") REFERENCES public."CreditCard"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CreditCardPurchase CreditCardPurchase_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardPurchase"
    ADD CONSTRAINT "CreditCardPurchase_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public."Category"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditCardPurchase CreditCardPurchase_creditCardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardPurchase"
    ADD CONSTRAINT "CreditCardPurchase_creditCardId_fkey" FOREIGN KEY ("creditCardId") REFERENCES public."CreditCard"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CreditCardPurchase CreditCardPurchase_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardPurchase"
    ADD CONSTRAINT "CreditCardPurchase_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public."Family"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditCardPurchase CreditCardPurchase_ownerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCardPurchase"
    ADD CONSTRAINT "CreditCardPurchase_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES public."Person"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditCard CreditCard_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "CreditCard_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public."Family"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CreditCard CreditCard_ownerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "CreditCard_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES public."Person"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Expense Expense_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public."Category"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Expense Expense_personId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_personId_fkey" FOREIGN KEY ("personId") REFERENCES public."Person"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Expense Expense_recurringId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_recurringId_fkey" FOREIGN KEY ("recurringId") REFERENCES public."RecurringExpense"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ExtraIncome ExtraIncome_personId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExtraIncome"
    ADD CONSTRAINT "ExtraIncome_personId_fkey" FOREIGN KEY ("personId") REFERENCES public."Person"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GoalContribution GoalContribution_goalId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GoalContribution"
    ADD CONSTRAINT "GoalContribution_goalId_fkey" FOREIGN KEY ("goalId") REFERENCES public."Goal"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: IncomeSource IncomeSource_personId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."IncomeSource"
    ADD CONSTRAINT "IncomeSource_personId_fkey" FOREIGN KEY ("personId") REFERENCES public."Person"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Income Income_personId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Income"
    ADD CONSTRAINT "Income_personId_fkey" FOREIGN KEY ("personId") REFERENCES public."Person"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Income Income_sourceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Income"
    ADD CONSTRAINT "Income_sourceId_fkey" FOREIGN KEY ("sourceId") REFERENCES public."IncomeSource"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Person Person_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Person"
    ADD CONSTRAINT "Person_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public."Family"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RecurringExpense RecurringExpense_personId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RecurringExpense"
    ADD CONSTRAINT "RecurringExpense_personId_fkey" FOREIGN KEY ("personId") REFERENCES public."Person"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Salary Salary_personId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Salary"
    ADD CONSTRAINT "Salary_personId_fkey" FOREIGN KEY ("personId") REFERENCES public."Person"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict ALBiA9yoGh9pdyc3KWHNQyE8K5N51NCQemcbyDv0pmKF6WA9yT0upbcdFRawLPD

