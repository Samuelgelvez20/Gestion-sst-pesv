-- ============================================================================
-- SST-PESV: Creación de tablas (19 tablas)
-- Sesión 2.1 — Modelo físico / DDL
-- Archivo: 001_create_tables.sql
-- PostgreSQL 16
-- ============================================================================
-- Este archivo crea las 19 tablas definidas en el modelo lógico/físico.
-- Las FKs se agregan en 002_foreign_keys.sql.
-- Los constraints UNIQUE/CHECK se agregan en 003_constraints.sql.
-- Los índices se agregan en 004_indexes.sql.
-- ============================================================================

-- ============================================================================
-- CATÁLOGOS GLOBALES (sin tenant_id)
-- ============================================================================

-- 1. countries
CREATE TABLE countries (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        varchar(100) NOT NULL
);

-- 2. departments
CREATE TABLE departments (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_id  integer NOT NULL,
    name        varchar(100) NOT NULL
);

-- 3. municipalities
CREATE TABLE municipalities (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_id   integer NOT NULL,
    name            varchar(100) NOT NULL
);

-- 4. tenant_sizes
CREATE TABLE tenant_sizes (
    id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name    varchar(50) NOT NULL
);

-- 5. type_system_sst
CREATE TABLE type_system_sst (
    id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name    varchar(100) NOT NULL
);

-- 6. phva_stages
CREATE TABLE phva_stages (
    id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code    char(1) NOT NULL,
    name    varchar(50) NOT NULL
);

-- 7. modules
CREATE TABLE modules (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title               varchar(150) NOT NULL,
    description         text,
    sort_order          integer NOT NULL DEFAULT 0,
    type_system_sst_id  integer NOT NULL
);

-- 8. formats_sst
CREATE TABLE formats_sst (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    module_id   integer NOT NULL,
    name        varchar(150) NOT NULL
);

-- 9. templates
CREATE TABLE templates (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        varchar(150) NOT NULL,
    description text
);

-- ============================================================================
-- TENANT / OPERACIÓN
-- ============================================================================

-- 10. tenants
CREATE TABLE tenants (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                varchar(200) NOT NULL,
    contact_email       varchar(200),
    phone               varchar(30),
    tenant_size_id      integer,
    municipality_id     integer,
    is_active           boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz
);

-- 12. positions (debe crearse antes que persons)
CREATE TABLE positions (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id   integer NOT NULL,
    description varchar(150) NOT NULL
);

-- 11. persons
CREATE TABLE persons (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id       integer NOT NULL,
    first_name      varchar(100) NOT NULL,
    last_name       varchar(100) NOT NULL,
    email           varchar(200),
    position_id     integer,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz
);

-- 13. tenant_modules
CREATE TABLE tenant_modules (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id   integer NOT NULL,
    module_id   integer NOT NULL
);

-- 14. tenantsystems
CREATE TABLE tenantsystems (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id           integer NOT NULL,
    type_system_sst_id  integer NOT NULL
);

-- 15. tenanttemplates
CREATE TABLE tenanttemplates (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id           integer NOT NULL,
    template_id         integer NOT NULL,
    type_system_sst_id  integer NOT NULL,
    phva_stage_id       integer NOT NULL,
    format_id           integer,
    updated_at          timestamptz,
    created_at          timestamptz NOT NULL DEFAULT now()
);

-- 16. documents
CREATE TABLE documents (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id           integer NOT NULL,
    tenanttemplate_id   integer NOT NULL,
    status              varchar(20) NOT NULL DEFAULT 'no_iniciado',
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz
);

-- 17. evaluations (AMBIGUA — estructura propuesta en modelo físico)
CREATE TABLE evaluations (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id   integer NOT NULL,
    name        varchar(150) NOT NULL,
    description text,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- 18. editing_locks
CREATE TABLE editing_locks (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id       integer NOT NULL,
    resource_type   varchar(50) NOT NULL,
    resource_id     integer NOT NULL,
    locked_by       varchar(100) NOT NULL,
    locked_at       timestamptz NOT NULL DEFAULT now(),
    expires_at      timestamptz NOT NULL
);

-- 19. audit_log
CREATE TABLE audit_log (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id   integer,
    table_name  varchar(100) NOT NULL,
    record_id   integer NOT NULL,
    action      varchar(10) NOT NULL,
    old_values  jsonb,
    new_values  jsonb,
    changed_at  timestamptz NOT NULL DEFAULT now(),
    changed_by  varchar(100)
);
