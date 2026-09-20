-- ============================================================================
-- SST-PESV: Constraints (UNIQUE, CHECK)
-- Sesión 2.1 — Modelo físico / DDL
-- Archivo: 003_constraints.sql
-- PostgreSQL 16
-- ============================================================================
-- Ejecutar después de 002_foreign_keys.sql.
-- NOT NULL ya está en 001_create_tables.sql (definido en CREATE TABLE).
-- ============================================================================

-- ============================================================================
-- UNIQUE constraints (docs/modelo_fisico.md §6.2)
-- ============================================================================

-- countries.name
ALTER TABLE countries
    ADD CONSTRAINT uq_countries_name
    UNIQUE (name);

-- tenant_sizes.name
ALTER TABLE tenant_sizes
    ADD CONSTRAINT uq_tenant_sizes_name
    UNIQUE (name);

-- type_system_sst.name
ALTER TABLE type_system_sst
    ADD CONSTRAINT uq_type_system_sst_name
    UNIQUE (name);

-- phva_stages.code
ALTER TABLE phva_stages
    ADD CONSTRAINT uq_phva_stages_code
    UNIQUE (code);

-- phva_stages.name
ALTER TABLE phva_stages
    ADD CONSTRAINT uq_phva_stages_name
    UNIQUE (name);

-- tenant_modules(tenant_id, module_id)
-- Trigger 4 lo impide, pero UNIQUE es la capa de integridad declarativa
ALTER TABLE tenant_modules
    ADD CONSTRAINT uq_tenant_modules_tenant_module
    UNIQUE (tenant_id, module_id);

-- tenantsystems(tenant_id, type_system_sst_id)
-- Trigger 9 lo impide, pero UNIQUE es la capa de integridad declarativa
ALTER TABLE tenantsystems
    ADD CONSTRAINT uq_tenantsystems_tenant_system
    UNIQUE (tenant_id, type_system_sst_id);

-- tenanttemplates(tenant_id, template_id, type_system_sst_id, phva_stage_id)
-- Una plantilla no puede estar asignada dos veces con la misma configuración
ALTER TABLE tenanttemplates
    ADD CONSTRAINT uq_tenanttemplates_assignment
    UNIQUE (tenant_id, template_id, type_system_sst_id, phva_stage_id);

-- ============================================================================
-- CHECK constraints (docs/modelo_fisico.md §6.3)
-- ============================================================================

-- phva_stages.code IN ('P', 'H', 'V', 'A')
ALTER TABLE phva_stages
    ADD CONSTRAINT ck_phva_stages_code
    CHECK (code IN ('P', 'H', 'V', 'A'));

-- modules.sort_order >= 0
ALTER TABLE modules
    ADD CONSTRAINT ck_modules_sort_order
    CHECK (sort_order >= 0);

-- documents.status IN ('finalizado', 'borrador', 'no_iniciado', 'pendiente')
ALTER TABLE documents
    ADD CONSTRAINT ck_documents_status
    CHECK (status IN ('finalizado', 'borrador', 'no_iniciado', 'pendiente'));

-- audit_log.action IN ('INSERT', 'UPDATE', 'DELETE')
ALTER TABLE audit_log
    ADD CONSTRAINT ck_audit_log_action
    CHECK (action IN ('INSERT', 'UPDATE', 'DELETE'));
