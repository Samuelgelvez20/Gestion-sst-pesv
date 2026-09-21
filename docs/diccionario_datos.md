# Diccionario de Datos — SST-PESV

> Documentación del modelo físico real del proyecto.
> Fuente primaria: SQL ejecutable en PostgreSQL 16.
> **Este documento describe el esquema TÁL COMO EXISTE en la base de datos, no como se planeó.**

---

## Convenciones

| Elemento | Convención | Ejemplo |
|---|---|---|
| PK | `id` (integer GENERATED ALWAYS AS IDENTITY) | `id` en todas las tablas |
| FK | `{entidad}_id` | `tenant_id`, `module_id` |
| UNIQUE | `uq_{tabla}_{columna(s)}` | `uq_countries_name` |
| CHECK | `ck_{tabla}_{campo}` | `ck_documents_status` |
| Índices | `ix_{tabla}_{columna(s)}` | `ix_persons_tenant_id` |

---

## Evidencia PostgreSQL

### Conteos reales (desde catálogos)

```sql
-- Tablas
SELECT count(*) FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
-- Resultado: 19

-- FK
SELECT count(*) FROM information_schema.table_constraints
WHERE table_schema = 'public' AND constraint_type = 'FOREIGN KEY';
-- Resultado: 23

-- UNIQUE
SELECT count(*) FROM information_schema.table_constraints
WHERE table_schema = 'public' AND constraint_type = 'UNIQUE';
-- Resultado: 8

-- CHECK (solo definidas por usuario, excluyendo NOT NULL implícitos)
SELECT count(*) FROM pg_constraint
WHERE connamespace = 'public'::regnamespace AND contype = 'c';
-- Resultado: 4
```

> **Nota:** `information_schema.table_constraints` reporta 74 CHECK porque incluye los NOT NULL implícitos de PostgreSQL. El valor real de CHECK definidos por el usuario es **4**.

### Listado de tablas

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

```
   table_name
-----------------
 audit_log
 countries
 departments
 documents
 editing_locks
 evaluations
 formats_sst
 modules
 municipalities
 persons
 phva_stages
 positions
 templates
 tenant_modules
 tenant_sizes
 tenants
 tenantsystems
 tenanttemplates
 type_system_sst
```

---

## Clasificación de tablas

| Tipo | Cantidad | Tablas |
|---|---|---|
| Catálogos globales | 9 | countries, departments, municipalities, tenant_sizes, type_system_sst, phva_stages, modules, formats_sst, templates |
| Entidad central | 1 | tenants |
| Dependientes de tenant | 9 | persons, positions, tenant_modules, tenantsystems, tenanttemplates, documents, evaluations, editing_locks, audit_log |
| **Total** | **19** | |

---

## Tablas globales / catálogos

---

### countries

**Propósito:** Catálogo de países. Referenciado por departments.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | name | varchar(100) | NO | | Nombre del país |

**PK:** `id`

**FK:** Ninguna

**UNIQUE:** `uq_countries_name` → `(name)`

**CHECK:** Ninguno

**Índices:** `countries_pkey` (PK), `uq_countries_name` (UNIQUE)

**Multi-tenancy:** Global. Sin `tenant_id`.

---

### departments

**Propósito:** Catálogo de departamentos/regiones. Pertenecen a un país.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | country_id | integer | NO | | FK → countries(id) |
| 3 | name | varchar(100) | NO | | Nombre del departamento |

**PK:** `id`

**FK:**
- `fk_departments_country`: `country_id` → `countries(id)` ON DELETE RESTRICT ON UPDATE NO ACTION

**UNIQUE:** Ninguna

**CHECK:** Ninguno

**Índices:** `departments_pkey` (PK), `ix_departments_country_id` → `(country_id)`

**Multi-tenancy:** Global. Sin `tenant_id`.

---

### municipalities

**Propósito:** Catálogo de municipios/ciudades. Pertenecen a un departamento.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | department_id | integer | NO | | FK → departments(id) |
| 3 | name | varchar(100) | NO | | Nombre del municipio |

**PK:** `id`

**FK:**
- `fk_municipalities_department`: `department_id` → `departments(id)` ON DELETE RESTRICT ON UPDATE NO ACTION

**UNIQUE:** Ninguna

**CHECK:** Ninguno

**Índices:** `municipalities_pkey` (PK), `ix_municipalities_department_id` → `(department_id)`

**Multi-tenancy:** Global. Sin `tenant_id`.

---

### tenant_sizes

**Propósito:** Catálogo de tamaños de empresa (Micro, Pequeña, Mediana, Grande).

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | name | varchar(50) | NO | | Nombre del tamaño |

**PK:** `id`

**FK:** Ninguna

**UNIQUE:** `uq_tenant_sizes_name` → `(name)`

**CHECK:** Ninguno

**Índices:** `tenant_sizes_pkey` (PK), `uq_tenant_sizes_name` (UNIQUE)

**Multi-tenancy:** Global. Sin `tenant_id`.

---

### type_system_sst

**Propósito:** Catálogo de tipos de sistema SST (SST, PESV, etc.).

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | name | varchar(100) | NO | | Nombre del tipo de sistema |

**PK:** `id`

**FK:** Ninguna

**UNIQUE:** `uq_type_system_sst_name` → `(name)`

**CHECK:** Ninguno

**Índices:** `type_system_sst_pkey` (PK), `uq_type_system_sst_name` (UNIQUE)

**Multi-tenancy:** Global. Sin `tenant_id`.

---

### phva_stages

**Propósito:** Catálogo fijo de etapas del ciclo PHVA (Planear, Hacer, Verificar, Actuar). 4 registros.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | code | char(1) | NO | | Código: P, H, V, A |
| 3 | name | varchar(50) | NO | | Nombre: Planear, Hacer, Verificar, Actuar |

**PK:** `id`

**FK:** Ninguna

**UNIQUE:**
- `uq_phva_stages_code` → `(code)`
- `uq_phva_stages_name` → `(name)`

**CHECK:**
- `ck_phva_stages_code`: `code IN ('P', 'H', 'V', 'A')`

**Índices:** `phva_stages_pkey` (PK), `uq_phva_stages_code` (UNIQUE), `uq_phva_stages_name` (UNIQUE)

**Multi-tenancy:** Global. Sin `tenant_id`. 4 registros fijos.

---

### modules

**Propósito:** Catálogo de módulos funcionales del sistema. Cada módulo pertenece a un tipo de sistema SST.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | title | varchar(150) | NO | | Título del módulo |
| 3 | description | text | SI | | Descripción del módulo |
| 4 | sort_order | integer | NO | 0 | Orden de presentación |
| 5 | type_system_sst_id | integer | NO | | FK → type_system_sst(id) |

**PK:** `id`

**FK:**
- `fk_modules_system`: `type_system_sst_id` → `type_system_sst(id)` ON DELETE RESTRICT ON UPDATE NO ACTION

**UNIQUE:** Ninguna

**CHECK:**
- `ck_modules_sort_order`: `sort_order >= 0`

**Índices:** `modules_pkey` (PK), `ix_modules_system_id` → `(type_system_sst_id)`

**Multi-tenancy:** Global. Sin `tenant_id`. Los módulos son compartidos entre tenants.

---

### formats_sst

**Propósito:** Catálogo de formatos SST asociados a módulos.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | module_id | integer | NO | | FK → modules(id) |
| 3 | name | varchar(150) | NO | | Nombre del formato |

**PK:** `id`

**FK:**
- `fk_formats_sst_module`: `module_id` → `modules(id)` ON DELETE RESTRICT ON UPDATE NO ACTION

**UNIQUE:** Ninguna

**CHECK:** Ninguno

**Índices:** `formats_sst_pkey` (PK), `ix_formats_sst_module_id` → `(module_id)`

**Multi-tenancy:** Global. Sin `tenant_id`.

---

### templates

**Propósito:** Catálogo de plantillas globales reutilizables.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | name | varchar(150) | NO | | Nombre de la plantilla |
| 3 | description | text | SI | | Descripción de la plantilla |

**PK:** `id`

**FK:** Ninguna

**UNIQUE:** Ninguna

**CHECK:** Ninguno

**Índices:** `templates_pkey` (PK)

**Multi-tenancy:** Global. Sin `tenant_id`.

---

## Entidad central multi-tenant

---

### tenants

**Propósito:** Organizaciones/empresas registradas en la plataforma. Entidad central del modelo multi-tenant.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | name | varchar(200) | NO | | Nombre de la organización |
| 3 | contact_email | varchar(200) | SI | | Correo de contacto |
| 4 | phone | varchar(30) | SI | | Teléfono de contacto |
| 5 | tenant_size_id | integer | SI | | FK → tenant_sizes(id) |
| 6 | municipality_id | integer | SI | | FK → municipalities(id) |
| 7 | is_active | boolean | NO | true | Estado activo/inactivo |
| 8 | created_at | timestamptz | NO | now() | Fecha de creación |
| 9 | updated_at | timestamptz | SI | | Última actualización (trigger T1) |

**PK:** `id`

**FK:**
- `fk_tenants_size`: `tenant_size_id` → `tenant_sizes(id)` ON DELETE SET NULL ON UPDATE NO ACTION
- `fk_tenants_municipality`: `municipality_id` → `municipalities(id)` ON DELETE SET NULL ON UPDATE NO ACTION

**UNIQUE:** Ninguna

**CHECK:** Ninguno

**Índices:** `tenants_pkey` (PK), `ix_tenants_municipality_id` → `(municipality_id)`, `ix_tenants_tenant_size_id` → `(tenant_size_id)`

**Multi-tenancy:** Es el tenant. `id` es referenciado por todas las tablas tenant-scoped.

**Triggers:**
- T1 (`trg_tenants_updated_at`): BEFORE UPDATE → `NEW.updated_at := CURRENT_TIMESTAMP`
- T8 (`trg_tenants_no_delete_with_persons`): BEFORE DELETE → impide si tiene personas
- T12 (`trg_tenants_audit_general`): AFTER UPDATE → INSERT en `audit_log`
- T13 (`trg_tenants_audit_status_change`): AFTER UPDATE OF is_active → INSERT en `audit_log` cuando cambia `is_active`

---

## Tablas dependientes de tenant

---

### persons

**Propósito:** Personas/trabajadores asociados a una organización.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | tenant_id | integer | NO | | FK → tenants(id) |
| 3 | first_name | varchar(100) | NO | | Nombres |
| 4 | last_name | varchar(100) | NO | | Apellidos |
| 5 | email | varchar(200) | SI | | Correo electrónico |
| 6 | position_id | integer | SI | | FK → positions(id) |
| 7 | is_active | boolean | NO | true | Estado activo/inactivo |
| 8 | created_at | timestamptz | NO | now() | Fecha de creación |
| 9 | updated_at | timestamptz | SI | | Última actualización (trigger T2) |

**PK:** `id`

**FK:**
- `fk_persons_tenant`: `tenant_id` → `tenants(id)` ON DELETE RESTRICT ON UPDATE NO ACTION
- `fk_persons_position`: `position_id` → `positions(id)` ON DELETE SET NULL ON UPDATE NO ACTION

**UNIQUE:** Ninguna

**CHECK:** Ninguno

**Índices:** `persons_pkey` (PK), `ix_persons_tenant_id` → `(tenant_id)`, `ix_persons_position_id` → `(position_id)`

**Multi-tenancy:** Tenant-scoped vía `tenant_id`.

**Triggers:**
- T2 (`trg_persons_updated_at`): BEFORE UPDATE → `NEW.updated_at := CURRENT_TIMESTAMP`
- T3 (`trg_persons_tenant_active`): BEFORE INSERT → valida `tenants.is_active`
- T6 (`trg_persons_position_same_tenant`): BEFORE INSERT OR UPDATE → valida `positions.tenant_id = NEW.tenant_id`

---

### positions

**Propósito:** Cargos definidos por cada organización.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | tenant_id | integer | NO | | FK → tenants(id) |
| 3 | description | varchar(150) | NO | | Descripción del cargo |

**PK:** `id`

**FK:**
- `fk_positions_tenant`: `tenant_id` → `tenants(id)` ON DELETE CASCADE ON UPDATE NO ACTION

**UNIQUE:** Ninguna (la coexistencia con T6 y la FK `persons → positions` previene duplicados por tenant)

**CHECK:** Ninguno

**Índices:** `positions_pkey` (PK), `ix_positions_tenant_id` → `(tenant_id)`

**Multi-tenancy:** Tenant-scoped vía `tenant_id`.

---

### tenant_modules

**Propósito:** Módulos habilitados por cada organización (relación N:M tenant ↔ modules).

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | tenant_id | integer | NO | | FK → tenants(id) |
| 3 | module_id | integer | NO | | FK → modules(id) |

**PK:** `id`

**FK:**
- `fk_tenant_modules_tenant`: `tenant_id` → `tenants(id)` ON DELETE CASCADE ON UPDATE NO ACTION
- `fk_tenant_modules_module`: `module_id` → `modules(id)` ON DELETE RESTRICT ON UPDATE NO ACTION

**UNIQUE:**
- `uq_tenant_modules_tenant_module` → `(tenant_id, module_id)`

**CHECK:** Ninguno

**Índices:** `tenant_modules_pkey` (PK), `uq_tenant_modules_tenant_module` (UNIQUE), `ix_tenant_modules_tenant_id` → `(tenant_id)`, `ix_tenant_modules_module_id` → `(module_id)`

**Multi-tenancy:** Tenant-scoped vía `tenant_id`.

**Triggers:**
- T4 (`trg_tenant_modules_no_duplicate`): BEFORE INSERT → valida duplicado (coexiste con UNIQUE)

---

### tenantsystems

**Propósito:** Sistemas SST habilitados por cada organización (relación N:M tenant ↔ type_system_sst).

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | tenant_id | integer | NO | | FK → tenants(id) |
| 3 | type_system_sst_id | integer | NO | | FK → type_system_sst(id) |

**PK:** `id`

**FK:**
- `fk_tenantsystems_tenant`: `tenant_id` → `tenants(id)` ON DELETE CASCADE ON UPDATE NO ACTION
- `fk_tenantsystems_system`: `type_system_sst_id` → `type_system_sst(id)` ON DELETE RESTRICT ON UPDATE NO ACTION

**UNIQUE:**
- `uq_tenantsystems_tenant_system` → `(tenant_id, type_system_sst_id)`

**CHECK:** Ninguno

**Índices:** `tenantsystems_pkey` (PK), `uq_tenantsystems_tenant_system` (UNIQUE), `ix_tenantsystems_tenant_id` → `(tenant_id)`, `ix_tenantsystems_system_id` → `(type_system_sst_id)`

**Multi-tenancy:** Tenant-scoped vía `tenant_id`.

---

### tenanttemplates

**Propósito:** Plantillas asignadas por cada organización, con su sistema SST, etapa PHVA y formato asociado.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | tenant_id | integer | NO | | FK → tenants(id) |
| 3 | template_id | integer | NO | | FK → templates(id) |
| 4 | type_system_sst_id | integer | NO | | FK → type_system_sst(id) |
| 5 | phva_stage_id | integer | NO | | FK → phva_stages(id) |
| 6 | format_id | integer | SI | | FK → formats_sst(id) |
| 7 | updated_at | timestamptz | SI | | Última actualización (trigger T7) |
| 8 | created_at | timestamptz | NO | now() | Fecha de asignación |
| 9 | modified_by | varchar(100) | SI | | Último usuario que modificó (trigger T14) |

**PK:** `id`

**FK:**
- `fk_tenanttemplates_tenant`: `tenant_id` → `tenants(id)` ON DELETE CASCADE ON UPDATE NO ACTION
- `fk_tenanttemplates_template`: `template_id` → `templates(id)` ON DELETE RESTRICT ON UPDATE NO ACTION
- `fk_tenanttemplates_system`: `type_system_sst_id` → `type_system_sst(id)` ON DELETE RESTRICT ON UPDATE NO ACTION
- `fk_tenanttemplates_phva`: `phva_stage_id` → `phva_stages(id)` ON DELETE RESTRICT ON UPDATE NO ACTION
- `fk_tenanttemplates_format`: `format_id` → `formats_sst(id)` ON DELETE SET NULL ON UPDATE NO ACTION

**UNIQUE:**
- `uq_tenanttemplates_assignment` → `(tenant_id, template_id, type_system_sst_id, phva_stage_id)`

**CHECK:** Ninguno

**Índices:** `tenanttemplates_pkey` (PK), `uq_tenanttemplates_assignment` (UNIQUE), `ix_tenanttemplates_tenant_id` → `(tenant_id)`, `ix_tenanttemplates_template_id` → `(template_id)`, `ix_tenanttemplates_system_id` → `(type_system_sst_id)`, `ix_tenanttemplates_phva_id` → `(phva_stage_id)`, `ix_tenanttemplates_format_id` → `(format_id)` *(agregado Sesión 4.1 — migración 006)*

**Multi-tenancy:** Tenant-scoped vía `tenant_id`.

**Triggers:**
- T5 (`trg_tenanttemplates_tenant_active`): BEFORE INSERT → valida `tenants.is_active`
- T7 (`trg_tenanttemplates_updated_at`): BEFORE UPDATE → `NEW.updated_at := CURRENT_TIMESTAMP`
- T14 (`trg_tenanttemplates_modified_by`): BEFORE UPDATE → `NEW.modified_by := current_setting('app.current_user', true)`

**Nota sobre `modified_by`:** Columna agregada por `sql/01_schema/005_alter_tenanttemplates.sql`. No forma parte del DDL original de `001_create_tables.sql`.

---

### documents

**Propósito:** Documentos generados a partir de plantillas asignadas.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | tenant_id | integer | NO | | FK → tenants(id) |
| 3 | tenanttemplate_id | integer | NO | | FK → tenanttemplates(id) |
| 4 | status | varchar(20) | NO | 'no_iniciado' | Estado del documento |
| 5 | created_at | timestamptz | NO | now() | Fecha de creación |
| 6 | updated_at | timestamptz | SI | | Última actualización |

**PK:** `id`

**FK:**
- `fk_documents_tenant`: `tenant_id` → `tenants(id)` ON DELETE CASCADE ON UPDATE NO ACTION
- `fk_documents_tenanttemplate`: `tenanttemplate_id` → `tenanttemplates(id)` ON DELETE CASCADE ON UPDATE NO ACTION

**UNIQUE:** Ninguna (A-04: relación documents ↔ tenanttemplates puede ser 1:1 o 1:N; se preserva la cardinalidad abierta)

**CHECK:**
- `ck_documents_status`: `status IN ('finalizado', 'borrador', 'no_iniciado', 'pendiente')`

**Índices:** `documents_pkey` (PK), `ix_documents_tenant_id` → `(tenant_id)`, `ix_documents_tenanttemplate_id` → `(tenanttemplate_id)`, `ix_documents_tenant_status` → `(tenant_id, status)`

**Multi-tenancy:** Tenant-scoped vía `tenant_id`.

**Triggers:**
- T11 (`trg_documents_validate_compliance`): BEFORE INSERT OR UPDATE OR DELETE → valida % cumplimiento 0–100 vía `fn_tenant_compliance_pct()`

---

### evaluations

> **AMBIGUA — Ver nota al final de esta sección.**

**Propósito:** Evaluaciones registradas por organización. La tabla existe físicamente pero su uso operativo no está identificado en las consultas, procedures, functions ni triggers implementados.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | tenant_id | integer | NO | | FK → tenants(id) |
| 3 | name | varchar(150) | NO | | Nombre de la evaluación |
| 4 | description | text | SI | | Descripción |
| 5 | created_at | timestamptz | NO | now() | Fecha de creación |

**PK:** `id`

**FK:**
- `fk_evaluations_tenant`: `tenant_id` → `tenants(id)` ON DELETE CASCADE ON UPDATE NO ACTION

**UNIQUE:** Ninguna

**CHECK:** Ninguno

**Índices:** `evaluations_pkey` (PK), `ix_evaluations_tenant_id` → `(tenant_id)`

**Multi-tenancy:** Tenant-scoped vía `tenant_id`.

**Nota sobre ambigüedad (A-01):**
- Su existencia física está confirmada por el DDL (`001_create_tables.sql`).
- La evidencia en `Examen.md` es principalmente descriptiva (§1, §2, §4, §5).
- No tiene uso operativo identificado en las 68 consultas, 15 procedures, 8 functions ni 15 triggers implementados.
- Fue clasificada como AMBIGUA en `docs/modelo_logico.md §4.7`.
- Se documenta porque forma parte del esquema físico, pero su necesidad funcional debe entenderse como una decisión/ambigüedad documentada, no como una entidad inequívocamente exigida por el examen.

---

### editing_locks

**Propósito:** Control de edición simultánea de recursos. Los locks vencidos se eliminan físicamente por T15.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | tenant_id | integer | NO | | FK → tenants(id) |
| 3 | resource_type | varchar(50) | NO | | Tipo de recurso bloqueado |
| 4 | resource_id | integer | NO | | ID del recurso bloqueado |
| 5 | locked_by | varchar(100) | NO | | Usuario que realizó el bloqueo |
| 6 | locked_at | timestamptz | NO | now() | Fecha/hora del bloqueo |
| 7 | expires_at | timestamptz | NO | | Fecha/hora de expiración |

**PK:** `id`

**FK:**
- `fk_editing_locks_tenant`: `tenant_id` → `tenants(id)` ON DELETE CASCADE ON UPDATE NO ACTION

**UNIQUE:** Ninguna

**CHECK:** Ninguno

**Índices:** `editing_locks_pkey` (PK), `ix_editing_locks_tenant_id` → `(tenant_id)`, `ix_editing_locks_tenant_resource` → `(tenant_id, resource_type, resource_id)`, `ix_editing_locks_expires_at` → `(expires_at)`

**Multi-tenancy:** Tenant-scoped vía `tenant_id`.

**Triggers:**
- T15 (`trg_editing_locks_cleanup_expired`): AFTER INSERT OR UPDATE → `DELETE FROM editing_locks WHERE expires_at < CURRENT_TIMESTAMP`

**Nota:** No existe columna `active`. La limpieza es por DELETE físico, no por marcado lógico.

---

### audit_log

**Propósito:** Registro de auditoría genérico. Registra modificaciones en tablas principales del sistema.

| # | Columna | Tipo | NULL | Default | Descripción |
|---|---|---|---|---|---|
| 1 | id | integer | NO | GENERATED ALWAYS AS IDENTITY | PK |
| 2 | tenant_id | integer | SI | | FK → tenants(id) — NULL si es cambio en tabla global |
| 3 | table_name | varchar(100) | NO | | Nombre de la tabla modificada |
| 4 | record_id | integer | NO | | ID del registro modificado |
| 5 | action | varchar(10) | NO | | Acción: INSERT, UPDATE, DELETE |
| 6 | old_values | jsonb | SI | | Valores anteriores del registro |
| 7 | new_values | jsonb | SI | | Valores nuevos del registro |
| 8 | changed_at | timestamptz | NO | now() | Fecha/hora del cambio |
| 9 | changed_by | varchar(100) | SI | | Usuario que realizó el cambio |

**PK:** `id`

**FK:**
- `fk_audit_log_tenant`: `tenant_id` → `tenants(id)` ON DELETE SET NULL ON UPDATE NO ACTION

**UNIQUE:** Ninguna

**CHECK:**
- `ck_audit_log_action`: `action IN ('INSERT', 'UPDATE', 'DELETE')`

**Índices:** `audit_log_pkey` (PK), `ix_audit_log_tenant_id` → `(tenant_id)`, `ix_audit_log_table_name` → `(table_name)`, `ix_audit_log_changed_at` → `(changed_at)`, `ix_audit_log_tenant_table_record` → `(tenant_id, table_name, record_id)`

**Multi-tenancy:** Tenant-scoped vía `tenant_id` (nullable). Los cambios en tablas globales tienen `tenant_id = NULL`.

**Triggers:**
- T12 (`trg_tenants_audit_general`): AFTER UPDATE on tenants → INSERT con `to_jsonb(OLD)`, `to_jsonb(NEW)`
- T13 (`trg_tenants_audit_status_change`): AFTER UPDATE OF is_active on tenants → INSERT con `jsonb_build_object(...)` cuando `OLD.is_active IS DISTINCT FROM NEW.is_active`

**Mecanismo `changed_by`:** `current_setting('app.current_user', true)`. No existe tabla `users` dentro del alcance (INC-01).

---

## Resumen de constraints

### FK (23)

| # | Constraint | Tabla origen | Columna | Tabla destino | Columna destino | ON DELETE |
|---|---|---|---|---|---|---|
| 1 | fk_audit_log_tenant | audit_log | tenant_id | tenants | id | SET NULL |
| 2 | fk_departments_country | departments | country_id | countries | id | RESTRICT |
| 3 | fk_documents_tenant | documents | tenant_id | tenants | id | CASCADE |
| 4 | fk_documents_tenanttemplate | documents | tenanttemplate_id | tenanttemplates | id | CASCADE |
| 5 | fk_editing_locks_tenant | editing_locks | tenant_id | tenants | id | CASCADE |
| 6 | fk_evaluations_tenant | evaluations | tenant_id | tenants | id | CASCADE |
| 7 | fk_formats_sst_module | formats_sst | module_id | modules | id | RESTRICT |
| 8 | fk_modules_system | modules | type_system_sst_id | type_system_sst | id | RESTRICT |
| 9 | fk_municipalities_department | municipalities | department_id | departments | id | RESTRICT |
| 10 | fk_persons_position | persons | position_id | positions | id | SET NULL |
| 11 | fk_persons_tenant | persons | tenant_id | tenants | id | RESTRICT |
| 12 | fk_positions_tenant | positions | tenant_id | tenants | id | CASCADE |
| 13 | fk_tenant_modules_module | tenant_modules | module_id | modules | id | RESTRICT |
| 14 | fk_tenant_modules_tenant | tenant_modules | tenant_id | tenants | id | CASCADE |
| 15 | fk_tenants_municipality | tenants | municipality_id | municipalities | id | SET NULL |
| 16 | fk_tenants_size | tenants | tenant_size_id | tenant_sizes | id | SET NULL |
| 17 | fk_tenantsystems_system | tenantsystems | type_system_sst_id | type_system_sst | id | RESTRICT |
| 18 | fk_tenantsystems_tenant | tenantsystems | tenant_id | tenants | id | CASCADE |
| 19 | fk_tenanttemplates_format | tenanttemplates | format_id | formats_sst | id | SET NULL |
| 20 | fk_tenanttemplates_phva | tenanttemplates | phva_stage_id | phva_stages | id | RESTRICT |
| 21 | fk_tenanttemplates_system | tenanttemplates | type_system_sst_id | type_system_sst | id | RESTRICT |
| 22 | fk_tenanttemplates_template | tenanttemplates | template_id | templates | id | RESTRICT |
| 23 | fk_tenanttemplates_tenant | tenanttemplates | tenant_id | tenants | id | CASCADE |

### UNIQUE (8)

| # | Constraint | Tabla | Columna(s) |
|---|---|---|---|
| 1 | uq_countries_name | countries | name |
| 2 | uq_phva_stages_code | phva_stages | code |
| 3 | uq_phva_stages_name | phva_stages | name |
| 4 | uq_tenant_modules_tenant_module | tenant_modules | tenant_id, module_id |
| 5 | uq_tenant_sizes_name | tenant_sizes | name |
| 6 | uq_tenantsystems_tenant_system | tenantsystems | tenant_id, type_system_sst_id |
| 7 | uq_tenanttemplates_assignment | tenanttemplates | tenant_id, template_id, type_system_sst_id, phva_stage_id |
| 8 | uq_type_system_sst_name | type_system_sst | name |

### CHECK (4 — definidos por usuario)

| # | Constraint | Tabla | Condición |
|---|---|---|---|
| 1 | ck_audit_log_action | audit_log | action IN ('INSERT', 'UPDATE', 'DELETE') |
| 2 | ck_documents_status | documents | status IN ('finalizado', 'borrador', 'no_iniciado', 'pendiente') |
| 3 | ck_modules_sort_order | modules | sort_order >= 0 |
| 4 | ck_phva_stages_code | phva_stages | code IN ('P', 'H', 'V', 'A') |

---

## Resumen de índices relevantes (excluyendo PK y UNIQUE automáticos)

> **Nota Sesión 4.1:** El análisis de PostgreSQL 16 confirmó que los 28 índices de `004_indexes.sql` existen íntegramente. Se detectó que `tenanttemplates.format_id` (única FK de las 23 sin índice) fue corregido mediante migración `006_add_missing_index.sql`. El índice `ix_tenanttemplates_format_id` no se cuenta entre los 28 originales.

| # | Tabla | Índice | Columna(s) | Tipo |
|---|---|---|---|---|
| 1 | audit_log | ix_audit_log_changed_at | changed_at | B-tree |
| 2 | audit_log | ix_audit_log_table_name | table_name | B-tree |
| 3 | audit_log | ix_audit_log_tenant_id | tenant_id | B-tree |
| 4 | audit_log | ix_audit_log_tenant_table_record | tenant_id, table_name, record_id | B-tree compuesto |
| 5 | departments | ix_departments_country_id | country_id | B-tree |
| 6 | documents | ix_documents_tenant_id | tenant_id | B-tree |
| 7 | documents | ix_documents_tenant_status | tenant_id, status | B-tree compuesto |
| 8 | documents | ix_documents_tenanttemplate_id | tenanttemplate_id | B-tree |
| 9 | editing_locks | ix_editing_locks_expires_at | expires_at | B-tree |
| 10 | editing_locks | ix_editing_locks_tenant_id | tenant_id | B-tree |
| 11 | editing_locks | ix_editing_locks_tenant_resource | tenant_id, resource_type, resource_id | B-tree compuesto |
| 12 | evaluations | ix_evaluations_tenant_id | tenant_id | B-tree |
| 13 | formats_sst | ix_formats_sst_module_id | module_id | B-tree |
| 14 | modules | ix_modules_system_id | type_system_sst_id | B-tree |
| 15 | municipalities | ix_municipalities_department_id | department_id | B-tree |
| 16 | persons | ix_persons_position_id | position_id | B-tree |
| 17 | persons | ix_persons_tenant_id | tenant_id | B-tree |
| 18 | positions | ix_positions_tenant_id | tenant_id | B-tree |
| 19 | tenant_modules | ix_tenant_modules_module_id | module_id | B-tree |
| 20 | tenant_modules | ix_tenant_modules_tenant_id | tenant_id | B-tree |
| 21 | tenants | ix_tenants_municipality_id | municipality_id | B-tree |
| 22 | tenants | ix_tenants_tenant_size_id | tenant_size_id | B-tree |
| 23 | tenantsystems | ix_tenantsystems_system_id | type_system_sst_id | B-tree |
| 24 | tenantsystems | ix_tenantsystems_tenant_id | tenant_id | B-tree |
| 25 | tenanttemplates | ix_tenanttemplates_phva_id | phva_stage_id | B-tree |
| 26 | tenanttemplates | ix_tenanttemplates_system_id | type_system_sst_id | B-tree |
| 27 | tenanttemplates | ix_tenanttemplates_template_id | template_id | B-tree |
| 28 | tenanttemplates | ix_tenanttemplates_tenant_id | tenant_id | B-tree |
| 29 | tenanttemplates | ix_tenanttemplates_format_id | format_id | B-tree | *(Sesión 4.1 — migración 006)* |

---

## Entidades fuera de alcance (INC-01)

Las siguientes entidades **NO existen** en el esquema actual y **NO deben** reintroducirse:

- `users`, `roles` — sistema de autenticación
- `riesgos`, `incidentes`, `capacitaciones`, `inspecciones` — SST operativo
- `vehiculos`, `conductores`, `rutas`, `controles` — PESV operativo

> Ver `docs/incidencias.md` INC-01.

---

## Discrepancias entre SQL y documentación

### Discrepancia 1: `models` —数量 de CHECK

- `information_schema.table_constraints` reporta 74 CHECK constraints.
- `pg_constraint` (contype = 'c') reporta 4 CHECK constraints definidos por usuario.
- **Causa:** PostgreSQL implementa NOT NULL como CHECK constraint internamente. Los 70 restantes son NOT NULL.
- **Resolución:** El diccionario usa el valor real de **4** CHECK definidos por usuario.

### Discrepancia 2: `formats_sst` — ausencia de columnas documentadas

- `docs/modelo_fisico.md §3.7` documenta `formats_sst` con columnas `id`, `module_id`, `name`.
- El SQL real (`001_create_tables.sql`) crea la tabla con las mismas 3 columnas.
- **Estado:** Sin discrepancia real. La documentación coincide con el SQL.

### Discrepancia 3: `evaluations` — tabla sin uso operativo

- La tabla existe físicamente en el esquema.
- No tiene uso identificado en consultas, procedures, functions ni triggers.
- Clasificada como AMBIGUA en `modelo_logico.md §4.7`.
- **Resolución:** Se documenta como parte del esquema físico con nota de ambigüedad (A-01).

### Discrepancia 4: `documents` ↔ `tenanttemplates` — cardinalidad no definida

- No existe UNIQUE en `documents(tenanttemplate_id)`.
- `modelo_fisico.md` clasifica esto como ambigüedad A-04.
- **Resolución:** Se preserva la cardinalidad abierta (1:1 o 1:N).

---

## Decisiones de diseño documentadas

| Decisión | Estado | Fuente |
|---|---|---|
| persons → tenants: N:1 | Cerrada | Examen.md Trigger 6, Procedimiento 8 |
| persons → positions: N:1 | Cerrada | Examen.md Trigger 6 |
| positions: tenant-scoped | Cerrada | Examen.md consulta 2.20 |
| P8: position_id = NULL al transferir | Cerrada | Sesión 3.3 |
| P3: invoca P9 via CALL | Cerrada | Sesión 3.3 |
| P10: FK chain via formats_sst.module_id | Cerrada | Sesión 3.3 |
| T14: modified_by via session setting | Cerrada | Sesión 3.4 |
| T13: WHEN IS DISTINCT FROM | Cerrada | Sesión 3.4 |
| T15: DELETE de locks vencidos | Cerrada | Sesión 3.4 |
| editing_locks: sin columna active | Cerrada | Sesión 3.4 |
| audit_log: estructura actual suficiente | Cerrada | Sesión 3.4 |
| evaluations: ambigüedad A-01 | Abierta | Examen.md §1, §2, §4, §5 |
| documents ↔ tenanttemplates: cardinalidad | Abierta | Examen.md consultas 3.10, 3.23 |

---

*Última actualización: Sesión 4.1 — Diccionario de datos + corrección de índice faltante*
