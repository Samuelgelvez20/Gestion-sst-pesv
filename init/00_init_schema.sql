-- ============================================================================
-- SST-PESV: Script maestro de inicialización del esquema
-- Sesión 2.1 — Modelo físico / DDL
-- Archivo: init/00_init_schema.sql
-- PostgreSQL 16
-- ============================================================================
-- Ejecutar este script para crear todo el esquema desde cero:
--   psql -U sst_pesv_user -d sst_pesv -f init/00_init_schema.sql
--
-- O ejecutar cada archivo individualmente en orden:
--   sql/01_schema/000_extensions.sql
--   sql/01_schema/001_create_tables.sql
--   sql/01_schema/002_foreign_keys.sql
--   sql/01_schema/003_constraints.sql
--   sql/01_schema/004_indexes.sql
-- ============================================================================

\echo '========================================'
\echo 'SST-PESV: Inicialización del esquema'
\echo '========================================'

\echo ''
\echo '--- 000: Extensiones ---'
\i sql/01_schema/000_extensions.sql

\echo ''
\echo '--- 001: Creación de tablas (19 tablas) ---'
\i sql/01_schema/001_create_tables.sql

\echo ''
\echo '--- 002: Claves foráneas (FKs) ---'
\i sql/01_schema/002_foreign_keys.sql

\echo ''
\echo '--- 003: Constraints (UNIQUE, CHECK) ---'
\i sql/01_schema/003_constraints.sql

\echo ''
\echo '--- 004: Índices ---'
\i sql/01_schema/004_indexes.sql

\echo ''
\echo '========================================'
\echo 'SST-PESV: Esquema inicializado OK'
\echo '========================================'
