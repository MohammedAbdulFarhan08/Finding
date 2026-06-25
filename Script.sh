-- =============================================================================
-- CORE-1745 : IAM-auth read-only / read-write database roles
-- =============================================================================
-- This run targets : dev / cluster pass-community / database "community"
-- Connect AS       : the cluster MASTER user (e.g. dbadmin) via the SSM tunnel
-- Table owner      : dbcommunity (the app service account that owns public.*)
--
-- Re-use for the other clusters by editing the two \set values below
-- (and the database name is taken from :appdb automatically):
--     eligibility  ->  owner = dbeligibility , appdb = eligibility
--     offerings    ->  owner = dbofferings   , appdb = offerings
--
-- app_ro / app_rw are cluster-scoped roles, so this is run once per cluster.
-- The script is idempotent for role creation and safe to re-run.
-- =============================================================================

\set owner   dbcommunity
\set appdb   community

-- Stop on first error so a failed GRANT doesn't hide behind later success.
\set ON_ERROR_STOP on

\echo '>> [1/5] Creating IAM login roles app_ro / app_rw (idempotent) ...'
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_ro') THEN
    CREATE ROLE app_ro WITH LOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_rw') THEN
    CREATE ROLE app_rw WITH LOGIN;
  END IF;
END $$;

\echo '>> [2/5] Granting rds_iam (forces IAM-token auth; password login rejected) ...'
GRANT rds_iam TO app_ro;
GRANT rds_iam TO app_rw;

\echo '>> [3/5] Granting database + schema entry ...'
GRANT CONNECT ON DATABASE :"appdb" TO app_ro, app_rw;
GRANT USAGE   ON SCHEMA public      TO app_ro, app_rw;

-- Object privileges must be granted by the table OWNER. The RDS master user is
-- rds_superuser (not a true superuser), so it cannot grant on tables it does not
-- own. Become a member of the owning role and act as it.
\echo '>> [4/5] Switching to owner role to grant table/sequence privileges ...'
GRANT :"owner" TO CURRENT_USER;
SET ROLE :"owner";

-- Existing objects
GRANT SELECT                         ON ALL TABLES    IN SCHEMA public TO app_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES    IN SCHEMA public TO app_rw;
GRANT USAGE, SELECT                  ON ALL SEQUENCES IN SCHEMA public TO app_rw;

-- Future objects created by the owner. WITHOUT THIS, any table created after
-- this script runs is invisible to app_ro/app_rw and you get a "can't see the
-- new table" bug weeks later. This is the single most-missed step.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT                         ON TABLES    TO app_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES    TO app_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT                  ON SEQUENCES TO app_rw;

RESET ROLE;

\echo '>> [5/5] Verification ...'
\du app_ro
\du app_rw
\echo '>> Done. app_ro = read-only, app_rw = read-write, both IAM-token auth.'
\echo '>> If your DB uses schemas other than public, repeat steps 3-4 per schema.'
