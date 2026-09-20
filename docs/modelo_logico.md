# Modelo Lógico — SST-PESV

> Definición de tablas, columnas, tipos de datos, PK, FK y restricciones.
> Sin DDL. Solo diseño lógico del esquema multi-tenant.

---

## 1. Convenciones

| Convención | Valor |
|---|---|
| Case de tablas | snake_case, plural (`tenants`, `persons`) |
| Case de columnas | snake_case (`tenant_id`, `created_at`) |
| PK | `id` (serial/bigserial) |
| FK sufijo | `_id` (`tenant_id`, `module_id`) |
| Timestamps | `created_at`, `updated_at` (timestamptz) |
| Soft delete | `is_active` (boolean, default true) donde aplique |
| Multi-tenancy | `tenant_id` en cada tabla dependiente |

---

## 2. Catálogos globales (sin tenant_id)

### 2.1 `countries`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del país |
| `name` | varchar(100) | NOT NULL, UNIQUE | Nombre del país |

> Fuente: Examen.md — consulta 1.6

### 2.2 `departments`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del departamento |
| `country_id` | integer | FK → countries(id), NOT NULL | País al que pertenece |
| `name` | varchar(100) | NOT NULL | Nombre del departamento |

> Fuente: Examen.md — consulta 1.7

### 2.3 `municipalities`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del municipio |
| `department_id` | integer | FK → departments(id), NOT NULL | Departamento al que pertenece |
| `name` | varchar(100) | NOT NULL | Nombre del municipio |

> Fuente: Examen.md — consulta 1.8

### 2.4 `tenant_sizes`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del tamaño |
| `name` | varchar(50) | NOT NULL, UNIQUE | Nombre del tamaño (Micro, Pequeña, Mediana, Grande) |

> Fuente: Examen.md — consulta 1.13

### 2.5 `type_system_sst`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del tipo de sistema SST |
| `name` | varchar(100) | NOT NULL, UNIQUE | Nombre del tipo de sistema SST |

> Fuente: Examen.md — consulta 1.14

### 2.6 `phva_stages`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador de la etapa |
| `code` | char(1) | NOT NULL, UNIQUE | Código: P, H, V, A |
| `name` | varchar(50) | NOT NULL | Nombre: Planear, Hacer, Verificar, Actuar |

> Fuente: Examen.md — §2, §5, consultas 2.18, 3.5-3.9

### 2.7 `modules`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del módulo |
| `title` | varchar(150) | NOT NULL | Título del módulo |
| `description` | text | | Descripción del módulo |
| `sort_order` | integer | NOT NULL, DEFAULT 0 | Orden de presentación |
| `type_system_sst_id` | integer | FK → type_system_sst(id), NOT NULL | Sistema SST al que pertenece |

> Fuente: Examen.md — consulta 1.15, 2.10

### 2.8 `formats_sst`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del formato |
| `module_id` | integer | FK → modules(id), NOT NULL | Módulo al que pertenece |
| `name` | varchar(150) | NOT NULL | Nombre del formato |

> Fuente: Examen.md — consultas 2.11, 2.12

### 2.9 `templates`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador de la plantilla |
| `name` | varchar(150) | NOT NULL | Nombre de la plantilla |
| `description` | text | | Descripción de la plantilla |

> Fuente: Examen.md — consultas 2.13, 2.14; Procedimiento 6

---

## 3. Entidad central multi-tenant

### 3.1 `tenants`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador de la organización |
| `name` | varchar(200) | NOT NULL | Nombre de la organización |
| `contact_email` | varchar(200) | | Correo de contacto |
| `phone` | varchar(30) | | Teléfono de contacto |
| `tenant_size_id` | integer | FK → tenant_sizes(id) | Tamaño de empresa |
| `municipality_id` | integer | FK → municipalities(id) | Ubicación (municipio) |
| `is_active` | boolean | NOT NULL, DEFAULT true | Estado (activo/inactivo) |
| `created_at` | timestamptz | NOT NULL, DEFAULT now() | Fecha de creación |
| `updated_at` | timestamptz | | Fecha de última actualización |

> Fuente: Examen.md — consultas 1.1, 1.2, 1.5, 1.11, 1.12; Triggers 1, 8, 12, 13

---

## 4. Entidades dependientes de tenant

### 4.1 `persons`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador de la persona |
| `tenant_id` | integer | FK → tenants(id), NOT NULL | Organización a la que pertenece |
| `first_name` | varchar(100) | NOT NULL | Nombres |
| `last_name` | varchar(100) | NOT NULL | Apellidos |
| `email` | varchar(200) | | Correo electrónico |
| `position_id` | integer | FK → positions(id) | Cargo que desempeña |
| `is_active` | boolean | NOT NULL, DEFAULT true | Estado (activo/inactivo) |
| `created_at` | timestamptz | NOT NULL, DEFAULT now() | Fecha de creación |
| `updated_at` | timestamptz | | Fecha de última actualización |

> Fuente: Examen.md — consultas 1.3, 1.4, 1.10, 2.1, 2.2; Triggers 2, 3, 6

### 4.2 `positions`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del cargo |
| `tenant_id` | integer | FK → tenants(id), NOT NULL | Organización a la que pertenece |
| `description` | varchar(150) | NOT NULL | Descripción del cargo |

> Fuente: Examen.md — consulta 1.9, 2.20
> **Nota:** `positions` es por tenant (cada organización define sus propios cargos).

### 4.3 `tenant_modules`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador de la relación |
| `tenant_id` | integer | FK → tenants(id), NOT NULL | Organización |
| `module_id` | integer | FK → modules(id), NOT NULL | Módulo habilitado |

> UNIQUE (tenant_id, module_id)
> Fuente: Examen.md — consultas 2.7, 2.8, 2.17; Procedimientos 4, 9, 10; Triggers 4, 10

### 4.4 `tenantsystems`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador de la relación |
| `tenant_id` | integer | FK → tenants(id), NOT NULL | Organización |
| `type_system_sst_id` | integer | FK → type_system_sst(id), NOT NULL | Sistema SST habilitado |

> UNIQUE (tenant_id, type_system_sst_id)
> Fuente: Examen.md — consulta 2.9; Procedimiento 5; Trigger 9

### 4.5 `tenanttemplates`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador de la asignación |
| `tenant_id` | integer | FK → tenants(id), NOT NULL | Organización |
| `template_id` | integer | FK → templates(id), NOT NULL | Plantilla asignada |
| `type_system_sst_id` | integer | FK → type_system_sst(id), NOT NULL | Sistema SST asociado |
| `phva_stage_id` | integer | FK → phva_stages(id), NOT NULL | Etapa PHVA asociada |
| `format_id` | integer | FK → formats_sst(id) | Formato asociado (opcional) |
| `updated_at` | timestamptz | | Fecha de última actualización |
| `created_at` | timestamptz | NOT NULL, DEFAULT now() | Fecha de asignación |

> UNIQUE (tenant_id, template_id, type_system_sst_id, phva_stage_id)
> Fuente: Examen.md — consultas 2.13, 2.14, 2.15; Procedimientos 6, 11, 15; Triggers 5, 7, 14

### 4.6 `documents`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del documento |
| `tenant_id` | integer | FK → tenants(id), NOT NULL | Organización |
| `tenanttemplate_id` | integer | FK → tenanttemplates(id), NOT NULL | Plantilla asignada |
| `status` | varchar(20) | NOT NULL, DEFAULT 'no_iniciado' | Estado: finalizado, borrador, no_iniciado, pendiente |
| `created_at` | timestamptz | NOT NULL, DEFAULT now() | Fecha de creación |
| `updated_at` | timestamptz | | Fecha de última actualización |

> CHECK (status IN ('finalizado', 'borrador', 'no_iniciado', 'pendiente'))
> Fuente: Examen.md — consultas 3.10, 3.15, 3.22, 3.23; Procedimientos 12, 13; Función 2

### 4.7 `evaluations` — AMBIGUA (pendiente de decisión)

| Columna | Tipo | Restricciones | Descripción | Estado |
|---|---|---|---|---|
| `id` | serial | PK | Identificador de la evaluación | Propuesta |
| `tenant_id` | integer | FK → tenants(id), NOT NULL | Organización | Propuesta |
| `name` | varchar(150) | NOT NULL | Nombre de la evaluación | Propuesta |
| `description` | text | | Descripción | Propuesta |
| `created_at` | timestamptz | NOT NULL, DEFAULT now() | Fecha de creación | Propuesta |

> **AMBIGUA — pendiente de decisión.**
> Aparece en §1 (intro), §2 (problema), §4 (objetivo 6), §5 (alcance) de Examen.md.
> **NO aparece** en las 68 consultas, 15 procedimientos, 8 funciones, 15 triggers, 5 vistas ni 3 vistas materializadas.
> Evidencia descriptiva únicamente. No existe suficiente evidencia para comprometer una estructura lógica definitiva.
> TASKS.md restaurado no la respalda. README.md no la respalda.

### 4.8 `editing_locks`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del bloqueo |
| `tenant_id` | integer | FK → tenants(id), NOT NULL | Organización |
| `resource_type` | varchar(50) | NOT NULL | Tipo de recurso bloqueado |
| `resource_id` | integer | NOT NULL | ID del recurso bloqueado |
| `locked_by` | varchar(100) | NOT NULL | Usuario que realizó el bloqueo |
| `locked_at` | timestamptz | NOT NULL, DEFAULT now() | Fecha/hora del bloqueo |
| `expires_at` | timestamptz | NOT NULL | Fecha/hora de expiración |

> Fuente: Examen.md — §5 Alcance, Trigger 15
> **Nota:** Estructura inferida. El Examen.md no especifica columnas exactas.

### 4.9 `audit_log`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | serial | PK | Identificador del registro |
| `tenant_id` | integer | FK → tenants(id) | Organización (NULL si es global) |
| `table_name` | varchar(100) | NOT NULL | Tabla modificada |
| `record_id` | integer | NOT NULL | ID del registro modificado |
| `action` | varchar(10) | NOT NULL | Acción: INSERT, UPDATE, DELETE |
| `old_values` | jsonb | | Valores anteriores |
| `new_values` | jsonb | | Valores nuevos |
| `changed_at` | timestamptz | NOT NULL, DEFAULT now() | Fecha/hora del cambio |
| `changed_by` | varchar(100) | | Usuario que realizó el cambio |

> CHECK (action IN ('INSERT', 'UPDATE', 'DELETE'))
> Fuente: Examen.md — Triggers 12, 13, 14
> **Nota:** Estructura inferida. El Examen.md solo dice "tabla de auditoría".

---

## 5. Diagrama de relaciones

```
countries ──1:N── departments ──1:N── municipalities ──N:1── tenants
                                                              │
tenant_sizes ──N:1────────────────────────────────────────────┤
                                                              │
                    ┌─────────────────────────────────────────┤
                    │                                         │
                    ├──1:N── persons ──N:1── positions        │
                    │                                         │
                    ├──1:N── tenant_modules ──N:1── modules   │
                    │                                  │      │
                    │                                  N:1    │
                    │                                  │      │
                    │                           formats_sst   │
                    │                                         │
                    ├──1:N── tenantsystems ──N:1── type_system_sst
                    │                                         │
                    ├──1:N── tenanttemplates ──N:1── templates │
                    │           │                             │
                    │           N:1                           │
                    │           │                             │
                    │      phva_stages                        │
                    │                                         │
                    ├──1:N── documents                        │
                    │                                         │
                    ├──1:N── evaluations                      │
                    │                                         │
                    ├──1:N── editing_locks                    │
                    │                                         │
                    └──1:N── audit_log
```

---

## 6. Tablas resumen

| # | Tabla | Tipo | Tenant-scoped | FKs principales | Evidencia |
|---|---|---|---|---|---|
| 1 | `countries` | Catálogo global | No | — | EXPLÍCITA |
| 2 | `departments` | Catálogo global | No | country_id | INFERIDA |
| 3 | `municipalities` | Catálogo global | No | department_id | INFERIDA |
| 4 | `tenant_sizes` | Catálogo global | No | — | EXPLÍCITA |
| 5 | `type_system_sst` | Catálogo global | No | — | EXPLÍCITA |
| 6 | `phva_stages` | Catálogo global | No | — | INFERIDA |
| 7 | `modules` | Catálogo global | No | type_system_sst_id | INFERIDA |
| 8 | `formats_sst` | Catálogo global | No | module_id | EXPLÍCITA |
| 9 | `templates` | Catálogo global | No | — | INFERIDA |
| 10 | `tenants` | Entidad central | Sí (es el tenant) | tenant_size_id, municipality_id | EXPLÍCITA |
| 11 | `persons` | Dependiente | Sí | tenant_id, position_id | EXPLÍCITA |
| 12 | `positions` | Dependiente | Sí | tenant_id | EXPLÍCITA |
| 13 | `tenant_modules` | Puente N:M | Sí | tenant_id, module_id | EXPLÍCITA |
| 14 | `tenantsystems` | Puente N:M | Sí | tenant_id, type_system_sst_id | EXPLÍCITA |
| 15 | `tenanttemplates` | Puente N:M | Sí | tenant_id, template_id, type_system_sst_id, phva_stage_id, format_id | EXPLÍCITA |
| 16 | `documents` | Dependiente | Sí | tenant_id, tenanttemplate_id | INFERIDA |
| 17 | `evaluations` | Dependiente | Sí | tenant_id | **AMBIGUA** |
| 18 | `editing_locks` | Dependiente | Sí | tenant_id | EXPLÍCITA |
| 19 | `audit_log` | Auditoría | Sí (opcional) | tenant_id | AMBIGUA |

**Total: 19 tablas** (9 catálogos globales + 10 dependientes de tenant)

> **Leyenda de evidencia:** EXPLÍCITA = nombre de tabla aparece en Examen.md; INFERIDA = entidad inferida de consultas/requerimientos sin nombre de tabla explícito; AMBIGUA = evidencia descriptiva sin uso operativo en consultas/procedimientos/funciones/triggers.

---

## 7. Vistas

| # | Vista | Propósito | Tablas involucradas |
|---|---|---|---|
| V1 | `vw_tenant_persons` | Organizaciones con personas y cargos | tenants, persons, positions |
| V2 | `vw_tenant_geography` | Información geográfica de organizaciones | tenants, municipalities, departments, countries |
| V3 | `vw_tenant_modules` | Módulos habilitados por organización con sistema SST | tenant_modules, modules, tenantsystems, type_system_sst |
| V4 | `vw_tenant_phva_templates` | Plantillas por organización y etapa PHVA | tenanttemplates, phva_stages |
| V5 | `vw_tenant_persons_positions` | Personas por organización y cargo | persons, positions, tenants |

---

## 8. Vistas materializadas

| # | Vista materializada | Propósito | Tablas involucradas |
|---|---|---|---|
| MV1 | `vm_template_pesv_docs_summary` | Resumen documentos PESV por organización | documents, tenanttemplates, tenants |
| MV2 | `vm_template_sst_docs_summary` | Resumen documentos SST por organización | documents, tenanttemplates, tenants |
| MV3 | `vm_compliance_summary` | Cumplimiento consolidado por organización | documents, tenants |

---

## 9. Índices recomendados

| Tabla | Columna(s) | Tipo | Justificación |
|---|---|---|---|
| `persons` | `tenant_id` | B-tree | Filtro frecuente por organización |
| `persons` | `position_id` | B-tree | JOIN con positions |
| `positions` | `tenant_id` | B-tree | Filtro por organización |
| `tenant_modules` | `tenant_id` | B-tree | Filtro por organización |
| `tenant_modules` | `module_id` | B-tree | JOIN con modules |
| `tenantsystems` | `tenant_id` | B-tree | Filtro por organización |
| `tenanttemplates` | `tenant_id` | B-tree | Filtro por organización |
| `tenanttemplates` | `template_id` | B-tree | JOIN con templates |
| `documents` | `tenant_id` | B-tree | Filtro por organización |
| `documents` | `status` | B-tree | Filtro por estado |
| `editing_locks` | `tenant_id, resource_type, resource_id` | B-tree (compuesto) | Búsqueda de locks |
| `editing_locks` | `expires_at` | B-tree | Limpieza de locks vencidos |
| `audit_log` | `tenant_id` | B-tree | Filtro por organización |
| `audit_log` | `table_name, record_id` | B-tree (compuesto) | Búsqueda de auditoría |

---

## 10. Decisiones de diseño

| Decisión | Elección | Justificación |
|---|---|---|
| Multi-tenancy | Shared database, shared schema, `tenant_id` | Estándar para este alcance; más simple que schema-per-tenant |
| `positions` | Por tenant (tiene `tenant_id`) | Consulta 2.20 muestra "cargos existentes en cada organización" |
| `persons` → `positions` | N:1 (una persona tiene un cargo) | Trigger 6: "asociada a un cargo" (singular) |
| `persons` → `tenants` | N:1 (una persona pertenece a un tenant) | Procedimiento 8: "trasladar" (mover, no copiar) |
| `templates` | Tabla global (catálogo) | Las plantillas son documentos base reutilizables |
| `formats_sst` | Por módulo (FK a `modules`) | Consultas 2.11, 2.12 muestran formatos por módulo |
| `documents` | Generados de `tenanttemplates` | El cálculo de cumplimiento se basa en documentos por plantilla |
| `evaluations` | **AMBIGUA** — pendiente de decisión | Evidencia descriptiva en §2 y §5; sin uso en consultas, procedimientos, funciones ni triggers |
| `editing_locks` | Con expiración temporal | Trigger 15: "elimine o marque como inactivos los bloqueos vencidos" |
| `audit_log` | Genérico (table_name, old/new values) | Triggers 12, 13: "cualquier modificación", "valor anterior y nuevo" |

---

## 11. Entidades fuera de alcance (INC-01)

Las siguientes entidades **no están definidas en el Examen.md** y quedan **fuera de alcance**:

- `users`, `roles` (sistema de autenticación)
- `riesgos`, `incidentes`, `capacitaciones`, `inspecciones` (SST operativo)
- `vehiculos`, `conductores`, `rutas`, `controles` (PESV operativo)

> Ver `docs/incidencias.md` INC-01

---

*Última actualización: Sesión 1.3 — Modelo lógico*
