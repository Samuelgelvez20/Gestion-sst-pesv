-- ============================================================================
-- SST-PESV: Índices
-- Sesión 2.1 — Modelo físico / DDL
-- Archivo: 004_indexes.sql
-- PostgreSQL 16
-- ============================================================================
-- Ejecutar después de 003_constraints.sql.
-- Todos los índices documentados en docs/modelo_fisico.md §7.
-- Los UNIQUE constraints ya crean índices implícitos (no se duplican).
-- ============================================================================

-- ============================================================================
-- 7.2 Índices en FKs
-- ============================================================================

-- persons
CREATE INDEX ix_persons_tenant_id ON persons (tenant_id);
CREATE INDEX ix_persons_position_id ON persons (position_id);

-- positions
CREATE INDEX ix_positions_tenant_id ON positions (tenant_id);

-- tenant_modules
CREATE INDEX ix_tenant_modules_tenant_id ON tenant_modules (tenant_id);
CREATE INDEX ix_tenant_modules_module_id ON tenant_modules (module_id);

-- tenantsystems
CREATE INDEX ix_tenantsystems_tenant_id ON tenantsystems (tenant_id);
CREATE INDEX ix_tenantsystems_system_id ON tenantsystems (type_system_sst_id);

-- tenanttemplates
CREATE INDEX ix_tenanttemplates_tenant_id ON tenanttemplates (tenant_id);
CREATE INDEX ix_tenanttemplates_template_id ON tenanttemplates (template_id);
CREATE INDEX ix_tenanttemplates_system_id ON tenanttemplates (type_system_sst_id);
CREATE INDEX ix_tenanttemplates_phva_id ON tenanttemplates (phva_stage_id);

-- documents
CREATE INDEX ix_documents_tenant_id ON documents (tenant_id);
CREATE INDEX ix_documents_tenanttemplate_id ON documents (tenanttemplate_id);

-- evaluations
CREATE INDEX ix_evaluations_tenant_id ON evaluations (tenant_id);

-- editing_locks
CREATE INDEX ix_editing_locks_tenant_id ON editing_locks (tenant_id);

-- audit_log
CREATE INDEX ix_audit_log_tenant_id ON audit_log (tenant_id);
CREATE INDEX ix_audit_log_table_name ON audit_log (table_name);

-- departments
CREATE INDEX ix_departments_country_id ON departments (country_id);

-- municipalities
CREATE INDEX ix_municipalities_department_id ON municipalities (department_id);

-- tenants
CREATE INDEX ix_tenants_municipality_id ON tenants (municipality_id);
CREATE INDEX ix_tenants_tenant_size_id ON tenants (tenant_size_id);

-- modules
CREATE INDEX ix_modules_system_id ON modules (type_system_sst_id);

-- formats_sst
CREATE INDEX ix_formats_sst_module_id ON formats_sst (module_id);

-- ============================================================================
-- 7.3 Índices compuestos
-- ============================================================================

-- editing_locks: búsqueda de locks por recurso
CREATE INDEX ix_editing_locks_tenant_resource ON editing_locks (tenant_id, resource_type, resource_id);

-- editing_locks: limpieza de locks vencidos (Trigger 15)
CREATE INDEX ix_editing_locks_expires_at ON editing_locks (expires_at);

-- audit_log: búsqueda de auditoría por registro
CREATE INDEX ix_audit_log_tenant_table_record ON audit_log (tenant_id, table_name, record_id);

-- audit_log: consultas temporales de auditoría
CREATE INDEX ix_audit_log_changed_at ON audit_log (changed_at);

-- documents: filtro por organización y estado (consulta 3.23)
CREATE INDEX ix_documents_tenant_status ON documents (tenant_id, status);
