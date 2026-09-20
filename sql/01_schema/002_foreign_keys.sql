-- ============================================================================
-- SST-PESV: Claves foráneas (FKs)
-- Sesión 2.1 — Modelo físico / DDL
-- Archivo: 002_foreign_keys.sql
-- PostgreSQL 16
-- ============================================================================
-- Ejecutar después de 001_create_tables.sql.
-- Todas las acciones ON DELETE/ON UPDATE según docs/modelo_fisico.md §4.2.
-- ============================================================================

-- ============================================================================
-- CATÁLOGOS GLOBALES → catálogos superiores
-- ============================================================================

-- departments.country_id → countries.id
-- ON DELETE RESTRICT: No se puede eliminar un país con departamentos
ALTER TABLE departments
    ADD CONSTRAINT fk_departments_country
    FOREIGN KEY (country_id) REFERENCES countries(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- municipalities.department_id → departments.id
-- ON DELETE RESTRICT: No se puede eliminar un departamento con municipios
ALTER TABLE municipalities
    ADD CONSTRAINT fk_municipalities_department
    FOREIGN KEY (department_id) REFERENCES departments(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- modules.type_system_sst_id → type_system_sst.id
-- ON DELETE RESTRICT: No se puede eliminar un tipo de sistema SST con módulos
ALTER TABLE modules
    ADD CONSTRAINT fk_modules_system
    FOREIGN KEY (type_system_sst_id) REFERENCES type_system_sst(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- formats_sst.module_id → modules.id
-- ON DELETE RESTRICT: No se puede eliminar un módulo con formatos
ALTER TABLE formats_sst
    ADD CONSTRAINT fk_formats_sst_module
    FOREIGN KEY (module_id) REFERENCES modules(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- ============================================================================
-- TENANTS → catálogos
-- ============================================================================

-- tenants.tenant_size_id → tenant_sizes.id
-- ON DELETE SET NULL: Si se elimina un tamaño, la organización queda sin tamaño
ALTER TABLE tenants
    ADD CONSTRAINT fk_tenants_size
    FOREIGN KEY (tenant_size_id) REFERENCES tenant_sizes(id)
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

-- tenants.municipality_id → municipalities.id
-- ON DELETE SET NULL: Si se elimina un municipio, la organización queda sin ubicación
ALTER TABLE tenants
    ADD CONSTRAINT fk_tenants_municipality
    FOREIGN KEY (municipality_id) REFERENCES municipalities(id)
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

-- ============================================================================
-- ENTIDADES DEPENDIENTES → tenants
-- ============================================================================

-- persons.tenant_id → tenants.id
-- ON DELETE RESTRICT: No se puede eliminar un tenant si tiene personas asociadas.
-- Trigger 8 (BEFORE DELETE) también impide esta eliminación, pero RESTRICT
-- proporciona protección declarativa en el esquema sin depender del trigger.
-- Coherente con la protección de integridad en relaciones similares.
-- Fuente: Examen.md — Trigger 8, Procedimiento 8 ("trasladar")
ALTER TABLE persons
    ADD CONSTRAINT fk_persons_tenant
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- persons.position_id → positions.id
-- ON DELETE SET NULL: Si se elimina un cargo, la persona queda sin cargo
ALTER TABLE persons
    ADD CONSTRAINT fk_persons_position
    FOREIGN KEY (position_id) REFERENCES positions(id)
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

-- positions.tenant_id → tenants.id
-- ON DELETE CASCADE: Si se elimina un tenant, se eliminan sus cargos
ALTER TABLE positions
    ADD CONSTRAINT fk_positions_tenant
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

-- tenant_modules.tenant_id → tenants.id
-- ON DELETE CASCADE: Si se elimina un tenant, se eliminan sus módulos
ALTER TABLE tenant_modules
    ADD CONSTRAINT fk_tenant_modules_tenant
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

-- tenant_modules.module_id → modules.id
-- ON DELETE RESTRICT: No se puede eliminar un módulo asignado a tenants
-- (Trigger 10 lo impide)
ALTER TABLE tenant_modules
    ADD CONSTRAINT fk_tenant_modules_module
    FOREIGN KEY (module_id) REFERENCES modules(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- tenantsystems.tenant_id → tenants.id
-- ON DELETE CASCADE: Si se elimina un tenant, se eliminan sus sistemas SST
ALTER TABLE tenantsystems
    ADD CONSTRAINT fk_tenantsystems_tenant
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

-- tenantsystems.type_system_sst_id → type_system_sst.id
-- ON DELETE RESTRICT: No se puede eliminar un tipo de sistema SST asignado
-- (Trigger 9 lo impide)
ALTER TABLE tenantsystems
    ADD CONSTRAINT fk_tenantsystems_system
    FOREIGN KEY (type_system_sst_id) REFERENCES type_system_sst(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- tenanttemplates.tenant_id → tenants.id
-- ON DELETE CASCADE: Si se elimina un tenant, se eliminan sus plantillas
ALTER TABLE tenanttemplates
    ADD CONSTRAINT fk_tenanttemplates_tenant
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

-- tenanttemplates.template_id → templates.id
-- ON DELETE RESTRICT: No se puede eliminar una plantilla asignada
ALTER TABLE tenanttemplates
    ADD CONSTRAINT fk_tenanttemplates_template
    FOREIGN KEY (template_id) REFERENCES templates(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- tenanttemplates.type_system_sst_id → type_system_sst.id
-- ON DELETE RESTRICT: No se puede eliminar un tipo de sistema SST en uso
ALTER TABLE tenanttemplates
    ADD CONSTRAINT fk_tenanttemplates_system
    FOREIGN KEY (type_system_sst_id) REFERENCES type_system_sst(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- tenanttemplates.phva_stage_id → phva_stages.id
-- ON DELETE RESTRICT: No se puede eliminar una etapa PHVA en uso
ALTER TABLE tenanttemplates
    ADD CONSTRAINT fk_tenanttemplates_phva
    FOREIGN KEY (phva_stage_id) REFERENCES phva_stages(id)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

-- tenanttemplates.format_id → formats_sst.id
-- ON DELETE SET NULL: Si se elimina un formato, la plantilla queda sin formato (opcional)
ALTER TABLE tenanttemplates
    ADD CONSTRAINT fk_tenanttemplates_format
    FOREIGN KEY (format_id) REFERENCES formats_sst(id)
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

-- documents.tenant_id → tenants.id
-- ON DELETE CASCADE: Si se elimina un tenant, se eliminan sus documentos
ALTER TABLE documents
    ADD CONSTRAINT fk_documents_tenant
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

-- documents.tenanttemplate_id → tenanttemplates.id
-- ON DELETE CASCADE: Si se elimina la asignación, se eliminan los documentos
ALTER TABLE documents
    ADD CONSTRAINT fk_documents_tenanttemplate
    FOREIGN KEY (tenanttemplate_id) REFERENCES tenanttemplates(id)
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

-- evaluations.tenant_id → tenants.id
-- ON DELETE CASCADE: Si se elimina un tenant, se eliminan sus evaluaciones
ALTER TABLE evaluations
    ADD CONSTRAINT fk_evaluations_tenant
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

-- editing_locks.tenant_id → tenants.id
-- ON DELETE CASCADE: Si se elimina un tenant, se eliminan sus bloqueos
ALTER TABLE editing_locks
    ADD CONSTRAINT fk_editing_locks_tenant
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

-- audit_log.tenant_id → tenants.id
-- ON DELETE SET NULL: Si se elimina un tenant, el registro de auditoría se mantiene
ALTER TABLE audit_log
    ADD CONSTRAINT fk_audit_log_tenant
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
