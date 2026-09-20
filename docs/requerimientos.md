# Requerimientos del sistema SST-PESV

> **Documento de especificación funcional y técnica derivado del Examen.md**
>
> Fuente principal: `Examen.md` | Fuentes complementarias: `TASKS.md` (restaurado), `README.md`
>
> Sesión 1.2 — Análisis de requerimientos | Correcciones: Sesión 1.3 (INC-01)

---

## 1. Alcance

### 1.1 Propósito

Diseñar e implementar una base de datos relacional en **PostgreSQL** para soportar una plataforma **multi-tenant** de gestión de **Seguridad y Salud en el Trabajo (SST)** y **Plan Estratégico de Seguridad Vial (PESV)**, aplicando técnicas de modelado, normalización, integridad referencial, programación SQL y optimización de consultas.

> Fuente: Examen.md — §1 Introducción, §3 Objetivo general

### 1.2 Problema principal

> ¿Cómo diseñar e implementar una base de datos relacional en PostgreSQL que permita gestionar de forma centralizada, segura, normalizada y escalable la información asociada a los procesos SST y PESV de múltiples organizaciones?

> Fuente: Examen.md — §2 Planteamiento del problema

### 1.3 Componentes del sistema

| Componente | Función | Fuente |
|---|---|---|
| Empresas | Administrar las organizaciones registradas | Examen.md — §5 Alcance |
| Personas | Gestionar usuarios o trabajadores asociados a cada empresa | Examen.md — §5 Alcance |
| Cargos | Definir cargos dentro de las organizaciones | Examen.md — §5 Alcance |
| Sistemas SST | Configurar sistemas habilitados para cada organización | Examen.md — §5 Alcance |
| Módulos | Organizar los componentes funcionales del sistema | Examen.md — §5 Alcance |
| Etapas PHVA | Clasificar procesos según Planear, Hacer, Verificar y Actuar | Examen.md — §5 Alcance |
| Plantillas | Gestionar documentos base | Examen.md — §5 Alcance |
| Formatos | Definir formatos asociados a módulos | Examen.md — §5 Alcance |
| Evaluaciones | Registrar instrumentos o plantillas de evaluación | Examen.md — §5 Alcance |
| Ubicación geográfica | Administrar países, departamentos y municipios | Examen.md — §5 Alcance |
| Bloqueos | Controlar la edición simultánea de recursos | Examen.md — §5 Alcance |
| Indicadores | Determinar nivel de avance y cumplimiento | Examen.md — §5 Alcance |
| Vistas materializadas | Facilitar consultas consolidadas | Examen.md — §5 Alcance |

### 1.4 Configuración por empresa

Cada empresa debe poder configurar de manera independiente (Examen.md — §2):

- Datos generales de la organización
- Tamaño de la empresa
- Personas vinculadas
- Cargos y responsabilidades
- Sistemas de gestión habilitados
- Módulos asociados al SST y PESV
- Etapas del ciclo PHVA
- Plantillas documentales
- Formatos
- Evaluaciones
- Documentos generados
- Seguimiento del avance
- Ubicación geográfica
- Control de edición de documentos

### 1.5 Restricciones técnicas

- Base de datos: PostgreSQL 16
- Modelo: multi-tenant (aislamiento lógico)
- Debe soportar indicadores de cumplimiento documental
- Debe permitir consultar grado de avance por etapa PHVA
- Debe aplicar mecanismos básicos de concurrencia (bloqueo de edición)

> Fuente: Examen.md — §1, §2, §4 Objetivos específicos (objetivos 3, 14, 15, 16)

---

## 2. Actores

| Actor | Descripción | Fuente |
|---|---|---|
| Organización/Empresa (`tenants`) | Entidad que utiliza la plataforma; posee datos independientes | Examen.md — §2, §5 |
| Persona/Trabajador (`persons`) | Usuarios o trabajadores asociados a cada empresa | Examen.md — §5 |

> **Nota:** El Examen.md no define roles de usuario (admin, editor, visor, etc.) ni un sistema de autenticación. `users` y `roles` están **fuera de alcance** (ver INC-01).

---

## 3. Módulos y funcionalidades

### 3.1 SST (Seguridad y Salud en el Trabajo)

El Examen.md menciona SST como dominio principal pero no detalla entidades operativas específicas como riesgos, incidentes, capacitaciones o inspecciones.

**Mencionado explícitamente:**
- Sistemas SST (`type_system_sst`, `tenantsystems`)
- Módulos asociados al SST
- Formatos SST (`formats_sst`)
- Plantillas con etapa PHVA y sistema SST
- Vista materializada `vm_template_sst_docs_summary`

> Fuente: Examen.md — §§2-5, consultas 2.9, 2.10, 2.11, 3.22, 3.24, 4.6

> **Nota:** Entidades SST operativas (riesgos, incidentes, capacitaciones, inspecciones) **no están definidas en el Examen.md** y están **fuera de alcance**. Ver `docs/incidencias.md` INC-01.

### 3.2 PESV (Plan Estratégico de Seguridad Vial)

**Mencionado explícitamente:**
- Módulos asociados al PESV
- Plantillas con etapa PHVA y sistema PESV
- Vista materializada `vm_template_pesv_docs_summary`

> Fuente: Examen.md — §§1-2, consultas 3.22, 3.24

> **Nota:** Entidades PESV operativas (vehículos, conductores, rutas, controles) **no están definidas en el Examen.md** y están **fuera de alcance**. Ver `docs/incidencias.md` INC-01.

### 3.3 PHVA (Planear, Hacer, Verificar, Actuar)

Las etapas del ciclo PHVA son un eje transversal del sistema:

- Cada plantilla se asocia a una etapa PHVA
- Las organizaciones tienen plantillas distribuidas en las 4 etapas
- Se requiere calcular el porcentaje de cumplimiento por etapa
- Se debe identificar la etapa con más plantillas por organización
- Las vistas de resumen discriminan por etapa PHVA

> Fuente: Examen.md — §2, §4 (objetivo 14), consultas 2.18, 3.5-3.9, 3.20, 4.4

### 3.4 Documentos y cumplimiento

- Se generan documentos a partir de plantillas
- Los documentos tienen estados (implícito: finalizado, borrador, no iniciado, pendiente)
- Se calcula porcentaje de cumplimiento documental
- Se requieren vistas de resumen consolidado
- Las vistas materializadas consolidan documentos por organización

> Fuente: Examen.md — §2, consultas 3.10-3.15, 3.22-3.24, 4.6

---

## 4. Entidades

### 4.1 Entidades identificadas en el Examen.md

Las siguientes entidades se deducen de las tablas mencionadas explícitamente en las consultas y secciones del Examen.md:

| Entidad | Tabla inferida | Atributos mencionados | Fuente |
|---|---|---|---|
| Organización | `tenants` | identificador, nombre, correo de contacto, teléfono, fecha de creación, estado (activo/inactivo), datos de contacto, `updated_at` | Examen.md — consultas 1.1, 1.2, 1.5, 1.11, 1.12; triggers 1, 12, 13, 14 |
| Persona | `persons` | nombres, apellidos, correo electrónico, estado (activo), `tenant_id` | Examen.md — consultas 1.3, 1.4, 1.10; trigger 2 |
| Cargo | `positions` | descripción | Examen.md — consulta 1.9 |
| Tamaño de empresa | `tenant_sizes` | (descripción implícita) | Examen.md — consulta 1.13 |
| Tipo sistema SST | `type_system_sst` | (descripción implícita) | Examen.md — consulta 1.14 |
| Módulo | `modules` (inferida) | título, descripción, orden de presentación | Examen.md — consulta 1.15 |
| Relación tenant-módulo | `tenant_modules` | `tenant_id`, módulo | Examen.md — consultas 2.7, 2.8, 2.17 |
| Relación tenant-sistema SST | `tenantsystems` | `tenant_id`, sistema SST | Examen.md — consulta 2.9 |
| Relación tenant-plantilla | `tenanttemplates` | `tenant_id`, plantilla, sistema SST, etapa PHVA | Examen.md — consultas 2.13, 2.14, 2.15 |
| Formato SST | `formats_sst` | módulo asociado | Examen.md — consultas 2.11, 2.12 |
| País | `countries` | nombre | Examen.md — consulta 1.6 |
| Departamento/Región | (nombre no especificado) | país asociado | Examen.md — consulta 1.7 |
| Municipio/Ciudad | (nombre no especificado) | departamento/region asociado | Examen.md — consulta 1.8 |
| Plantilla | (nombre no especificado) | sistema SST, etapa PHVA, formato | Examen.md — consultas 2.13, 2.14, procedimientos 6, 11, 15 |
| Bloqueo de edición | `editing_locks` | (campos no especificados) | Examen.md — §5 Alcance, trigger 15 |
| Etapa PHVA | (nombre no especificado) | Planear, Hacer, Verificar, Actuar | Examen.md — §2, §5, consultas 2.18, 3.5-3.9 |
| Documento | (nombre no especificado) | estados: finalizado, borrador, no iniciado, pendiente | Examen.md — consultas 3.10, 3.23 |
| Evaluación | (nombre no especificado) | (atributos no especificados) | Examen.md — §2, §5 |

### 4.2 Entidades fuera de alcance (INC-01)

Las siguientes entidades fueron incluidas erróneamente por un agente de codificación en un `TASKS.md` fabricado. **No tienen respaldo en el Examen.md** y quedan **fuera de alcance** del proyecto:

| Entidad | Fuente errónea | Estado |
|---|---|---|
| `users` | TASKS.md fabricado | Fuera de alcance |
| `roles` | TASKS.md fabricado | Fuera de alcance |
| `riesgos` | TASKS.md fabricado | Fuera de alcance |
| `incidentes` | TASKS.md fabricado | Fuera de alcance |
| `capacitaciones` | TASKS.md fabricado | Fuera de alcance |
| `inspecciones` | TASKS.md fabricado | Fuera de alcance |
| `vehiculos` | TASKS.md fabricado | Fuera de alcance |
| `conductores` | TASKS.md fabricado | Fuera de alcance |
| `rutas` | TASKS.md fabricado | Fuera de alcance |
| `controles` | TASKS.md fabricado | Fuera de alcance |

> Ver `docs/incidencias.md` INC-01 para el reporte completo.

---

## 5. Relaciones

Las relaciones se infieren de las consultas que realizan JOIN entre tablas. **No se especifican cardinalidades exactas en el Examen.md.**

| Origen | Destino | Tipo de relación | Evidencia | Fuente |
|---|---|---|---|---|
| `tenants` → `persons` | Una organización tiene muchas personas | Consulta 2.1, 2.5, 2.16 | Examen.md — consultas 2.1, 2.5 |
| `tenants` → `positions` (via persons) | Una organización tiene muchos cargos | Consulta 2.20 | Examen.md — consulta 2.20 |
| `tenants` → `tenant_modules` → `modules` | Una organización tiene muchos módulos habilitados | Consultas 2.7, 2.8 | Examen.md — consultas 2.7, 2.8 |
| `tenants` → `tenantsystems` → `type_system_sst` | Una organización tiene muchos sistemas SST habilitados | Consulta 2.9 | Examen.md — consulta 2.9 |
| `tenants` → `tenanttemplates` → plantilla | Una organización tiene muchas plantillas | Consultas 2.13, 2.14, 2.15 | Examen.md — consultas 2.13-2.15 |
| `modules` → `formats_sst` | Un módulo tiene muchos formatos | Consultas 2.11, 2.12 | Examen.md — consultas 2.11, 2.12 |
| `modules` → `tenantsystems` | Un módulo pertenece a un sistema SST | Consulta 2.10 | Examen.md — consulta 2.10 |
| `countries` → departamentos | Un país tiene muchos departamentos | Consulta 1.7 | Examen.md — consulta 1.7 |
| Departamentos → municipios | Un departamento tiene muchos municipios | Consulta 1.8 | Examen.md — consulta 1.8 |
| `tenants` → municipio | Una organización se ubica en un municipio | Consultas 1.19, 2.4 | Examen.md — consultas 1.19, 2.4 |
| `persons` → `positions` | Una persona tiene un cargo | Consulta 2.2 | Examen.md — consulta 2.2 |
| `persons` → `tenants` | Una persona pertenece a una organización (`tenant_id`) | Consulta 1.10 | Examen.md — consulta 1.10 |
| `tenants` → `tenant_sizes` | Una organización tiene un tamaño | Consulta 2.3 | Examen.md — consulta 2.3 |
| Etapa PHVA → plantillas | Una etapa PHVA tiene muchas plantillas | Consultas 2.18, 3.5-3.9 | Examen.md — consultas 2.18, 3.5-3.9 |
| `tenants` → `editing_locks` | Una organización tiene muchos bloqueos | §5, trigger 15 | Examen.md — §5, trigger 15 |

> **Nota:** Las cardinalidades exactas (1:N, N:M) no están especificadas explícitamente en el Examen.md. Se infieren del contexto de las consultas. Ver §22 Decisiones pendientes.

---

## 6. Multi-tenancy

### 6.1 Requisito explícito

> "Es necesario garantizar el aislamiento lógico de la información mediante una arquitectura de datos multiempresa o multi-tenant."

> Fuente: Examen.md — §2 Planteamiento del problema

### 6.2 Características documentadas

- Múltiples organizaciones utilizan el mismo sistema
- Cada empresa configura su información de manera independiente
- El campo `tenant_id` en `persons` indica pertenencia a organización
- Las relaciones `tenant_modules`, `tenantsystems`, `tenanttemplates` vinculan configuraciones a organizaciones
- Las vistas de resumen se generan por organización

> Fuente: Examen.md — §§1-2, consultas 1.10, 2.7, 2.9, 2.13

### 6.3 No especificado

- Mecanismo exacto de aislamiento (esquemas por tenant, columna `tenant_id`, RLS, etc.)
- Roles de usuario por tenant
- Permisos de acceso por tenant
- Si un usuario puede pertenecer a múltiples tenants
- Si existe un tenant "superadmin" o administrador del sistema

> Fuente: No especificado en Examen.md. Ver §22 Decisiones pendientes.

---

## 7. Reglas de negocio

### 7.1 Reglas extraídas del Examen.md

| ID | Regla | Entidades afectadas | Fuente |
|---|---|---|---|
| RB-01 | No se puede registrar una persona en una organización inactiva | `persons`, `tenants` | Examen.md — Trigger 3 |
| RB-02 | No se puede asignar un módulo duplicado a una organización | `tenant_modules` | Examen.md — Trigger 4 |
| RB-03 | No se puede asignar plantillas a organizaciones inactivas | `tenanttemplates`, `tenants` | Examen.md — Trigger 5 |
| RB-04 | Una persona solo puede asociarse a un cargo de su misma organización | `persons`, `positions`, `tenants` | Examen.md — Trigger 6 |
| RB-05 | No se puede eliminar una organización si tiene personas asociadas | `tenants`, `persons` | Examen.md — Trigger 8 |
| RB-06 | No se puede eliminar un sistema SST si alguna organización lo usa | `type_system_sst`, `tenantsystems` | Examen.md — Trigger 9 |
| RB-07 | No se puede eliminar un módulo si está asignado a organizaciones | `modules`, `tenant_modules` | Examen.md — Trigger 10 |
| RB-08 | El porcentaje de cumplimiento debe estar entre 0 y 100 | `tenants` (cálculo) | Examen.md — Trigger 11 |
| RB-09 | Al registrar una organización, se valida que no exista otra con los mismos datos de identificación | `tenants` | Examen.md — Procedimiento 1 |
| RB-10 | Al asignar un módulo, se evita duplicidad | `tenant_modules` | Examen.md — Procedimiento 4 |
| RB-11 | Al eliminar una asignación de módulo, se validan registros dependientes | `tenant_modules` | Examen.md — Procedimiento 10 |
| RB-12 | Al trasladar persona, se actualizan las relaciones necesarias | `persons`, `tenants` | Examen.md — Procedimiento 8 |
| RB-13 | Al deshabilitar organización, se deshabilitan todos sus módulos | `tenants`, `tenant_modules` | Examen.md — Procedimiento 9 |
| RB-14 | Los bloqueos de edición vencidos deben eliminarse o marcarse como inactivos | `editing_locks` | Examen.md — Trigger 15 |

---

## 8. Estados y transiciones

### 8.1 Estados identificados

| Entidad | Estados | Transiciones | Fuente |
|---|---|---|---|
| `tenants` | Activo, Inactivo | Cambio de estado vía procedimiento 3 | Examen.md — Procedimiento 3, Trigger 3, 5 |
| `persons` | Activo | Filtrado en consulta 1.4 | Examen.md — Consulta 1.4 |
| `documents` (implícito) | Finalizado, Borrador, No iniciado, Pendiente | No especificado | Examen.md — Consultas 3.23 |
| `editing_locks` (implícito) | Activo, Vencido | Eliminación/marcado como inactivo | Examen.md — Trigger 15 |

### 8.2 Detalle de transiciones

**Organización (tenants):**
- Activo → Inactivo: Procedimiento 3 (cambiar estado)
- Inactivo → Activo: Procedimiento 3 (cambiar estado)
- Al pasar a Inactivo: se deshabilitan módulos (Procedimiento 9)

**Documentos:**
- No especificado en el Examen.md cuáles son las transiciones exactas

> Fuente: Examen.md — Procedimientos 3, 9; Trigger 15; Consulta 3.23

---

## 9. SST

### 9.1 Requisitos explícitos en Examen.md

El Examen.md aborda SST como dominio del sistema pero se centra en la **gestión documental y de configuración** SST, no en entidades operativas detalladas:

- Cada organización configura sus **sistemas SST habilitados** (`tenantsystems`, `type_system_sst`)
- Los **módulos** se asocian a sistemas SST
- Los **formatos** (`formats_sst`) se asocian a módulos
- Las **plantillas** se asocian a sistema SST y etapa PHVA
- Se generan **vistas de resumen** de documentos SST

> Fuente: Examen.md — §§1-5, consultas 2.9, 2.10, 2.11, 3.22, 3.24, 4.6

### 9.2 Entidades SST fuera de alcance

Entidades SST operativas (`riesgos`, `incidentes`, `capacitaciones`, `inspecciones`) **no están definidas en el Examen.md** y están **fuera de alcance**. Ver `docs/incidencias.md` INC-01.

---

## 10. PESV

### 10.1 Requisitos explícitos en Examen.md

El Examen.md aborda PESV como dominio del sistema pero同样 se centra en la **gestión documental**:

- Los **módulos** se asocian al PESV
- Las **plantillas** se asocian a etapa PHVA y pueden ser PESV
- Se genera una **vista materializada** `vm_template_pesv_docs_summary`

> Fuente: Examen.md — §§1-2, consultas 3.22, 3.24, 4.6

### 10.2 Entidades PESV fuera de alcance

Entidades PESV operativas (`vehiculos`, `conductores`, `rutas`, `controles`) **no están definidas en el Examen.md** y están **fuera de alcance**. Ver `docs/incidencias.md` INC-01.

---

## 11. PHVA

### 11.1 Ciclo Planear, Hacer, Verificar, Actuar

Las 4 etapas son un eje transversal del sistema:

| Etapa | Nombre | Fuente |
|---|---|---|
| P | Planear | Examen.md — §2, §5, consultas 3.7 |
| H | Hacer | Examen.md — §2, §5, consultas 3.7 |
| V | Verificar | Examen.md — §2, §5, consultas 3.7 |
| A | Actuar | Examen.md — §2, §5, consultas 3.7 |

### 11.2 Uso del PHVA en el sistema

- Cada plantilla se asocia a una etapa PHVA
- Se calcula la cantidad de plantillas por etapa por organización
- Se presenta en columnas independientes (PIVOT): Planear, Hacer, Verificar, Actuar
- Se calcula el porcentaje que representa cada etapa sobre el total
- Se identifica la etapa con más plantillas por organización
- Se determina si falta alguna etapa PHVA en las plantillas de una organización
- Las vistas de resumen discriminan por etapa PHVA

> Fuente: Examen.md — consultas 2.18, 3.5-3.9, 3.20, 4.4; Objetivos específicos 14, 15

---

## 12. Documentos y cumplimiento

### 12.1 Estados de documentos

El Examen.md menciona (consulta 3.23):
- Documentos finalizados
- Documentos en borrador
- Documentos no iniciados
- Documentos pendientes

> **Nota:** No se especifica si estos son estados de una tabla `documents` o si se derivan del cruce plantilla-organización.

### 12.2 Cálculo de cumplimiento

- Porcentaje de cumplimiento = documentos finalizados / total de documentos
- Se calcula por organización
- Se compara entre SST y PESV
- Se clasifica en categorías: bajo, medio, alto
- Se genera ranking de organizaciones
- Se calcula diferencia respecto al promedio general

> Fuente: Examen.md — consultas 3.8, 3.10-3.15, 3.23-3.24; Funciones 2, 8

### 12.3 Vistas de resumen

- `vm_template_pesv_docs_summary` — resumen documentos PESV
- `vm_template_sst_docs_summary` — resumen documentos SST
- Vista materializada de cumplimiento por organización

> Fuente: Examen.md — consultas 3.22, 3.23, 4.6

---

## 13. Auditoría y trazabilidad

### 13.1 Requisitos de auditoría

| Requisito | Descripción | Fuente |
|---|---|---|
| Actualización automática `updated_at` en `tenants` | Trigger que actualice el campo al modificar un registro | Examen.md — Trigger 1 |
| Actualización automática `updated_at` en `persons` | Trigger que actualice el campo al modificar una persona | Examen.md — Trigger 2 |
| Registro de modificación en `tenanttemplates` | Trigger que registre fecha de actualización al modificar plantilla asignada | Examen.md — Trigger 7 |
| Tabla de auditoría de `tenants` | Trigger que registre cualquier modificación de datos principales de organización | Examen.md — Trigger 12 |
| Auditoría de estado de `tenants` | Trigger que almacene valor anterior y nuevo al cambiar estado | Examen.md — Trigger 13 |
| Registro de usuario en plantillas | Trigger que registre fecha y usuario responsable al modificar plantilla | Examen.md — Trigger 14 |

### 13.2 Tabla de auditoría

El Examen.md menciona explícitamente una **tabla de auditoría** para `tenants` (Trigger 12) pero no especifica:
- Nombre de la tabla
- Estructura exacta
- Si aplica a otras entidades

> Fuente: Examen.md — Trigger 12. Ver §22 Decisiones pendientes.

---

## 14. Concurrencia

### 14.1 Requisito explícito

> "Aplicar mecanismos básicos de concurrencia, analizando el uso de estructuras de bloqueo para evitar la edición simultánea de determinados recursos."

> Fuente: Examen.md — §4 Objetivo específico 16

### 14.2 Mecanismo identificado

- Tabla `editing_locks` para controlar edición simultánea
- Trigger que elimina o marca como inactivos los bloqueos vencidos

> Fuente: Examen.md — §5 Alcance, Trigger 15

### 14.3 No especificado

- Duración de los bloqueos
- Qué recursos se bloquean
- Si es bloqueo a nivel de fila o tabla
- Si usa `SELECT ... FOR UPDATE`
- Política de expiración

> Ver §22 Decisiones pendientes.

---

## 15. Consultas

### 15.1 Resumen de cobertura

| Sección | Cantidad | Fuente |
|---|---|---|
| Consultas SQL básicas | 15 | Examen.md — §Consultas 1 |
| Consultas SQL intermedias | 20 | Examen.md — §Consultas 2 |
| Consultas SQL avanzadas | 25 | Examen.md — §Consultas 3 |
| Consultas orientadas a vistas | 8 | Examen.md — §Consultas 4 |
| **Total en Examen.md** | **68** | |

> **Nota:** Las instrucciones de la sesión indican 78 consultas, pero el Examen.md contiene **68**. Ver §22 Decisiones pendientes.

### 15.2 Consultas básicas (15)

**C.1.1** — Consultar todos los registros de `tenants`
- Tablas: `tenants`
- Técnicas: SELECT, WHERE, ORDER BY
- Fuente: Examen.md — §1.1

**C.1.2** — Nombre, correo y teléfono de organizaciones en `tenants`
- Tablas: `tenants`
- Técnicas: SELECT con columnas específicas
- Fuente: Examen.md — §1.2

**C.1.3** — Listar personas con nombres, apellidos y correo
- Tablas: `persons`
- Técnicas: SELECT, WHERE
- Fuente: Examen.md — §1.3

**C.1.4** — Personas con estado activo
- Tablas: `persons`
- Técnicas: WHERE con condición de estado
- Fuente: Examen.md — §1.4

**C.1.5** — Organizaciones cuyo nombre contenga una palabra (búsqueda)
- Tablas: `tenants`
- Técnicas: LIKE
- Fuente: Examen.md — §1.5

**C.1.6** — Países ordenados alfabéticamente
- Tablas: `countries`
- Técnicas: ORDER BY
- Fuente: Examen.md — §1.6

**C.1.7** — Departamentos de un país determinado
- Tablas: departamento/region, `countries`
- Técnicas: WHERE con FK
- Fuente: Examen.md — §1.7

**C.1.8** — Municipios de un departamento determinado
- Tablas: municipio, departamento
- Técnicas: WHERE con FK
- Fuente: Examen.md — §1.8

**C.1.9** — Cargos ordenados por descripción
- Tablas: `positions`
- Técnicas: ORDER BY
- Fuente: Examen.md — §1.9

**C.1.10** — Personas de una organización por `tenant_id`
- Tablas: `persons`
- Técnicas: WHERE con parámetro
- Fuente: Examen.md — §1.10

**C.1.11** — Organizaciones habilitadas/activas
- Tablas: `tenants`
- Técnicas: WHERE con estado
- Fuente: Examen.md — §1.11

**C.1.12** — Organizaciones registradas en un período (fecha de creación)
- Tablas: `tenants`
- Técnicas: BETWEEN o comparación de fechas
- Fuente: Examen.md — §1.12

**C.1.13** — Tamaños de empresa
- Tablas: `tenant_sizes`
- Técnicas: SELECT simple
- Fuente: Examen.md — §1.13

**C.1.14** — Tipos de sistemas SST
- Tablas: `type_system_sst`
- Técnicas: SELECT simple
- Fuente: Examen.md — §1.14

**C.1.15** — Módulos con título, descripción y orden
- Tablas: módulos (nombre no especificado)
- Técnicas: SELECT con columnas específicas
- Fuente: Examen.md — §1.15

### 15.3 Consultas intermedias (20)

**C.2.1** — Personas con nombre completo y organización (INNER JOIN)
- Tablas: `persons`, `tenants`
- Técnicas: INNER JOIN, concatenación
- Fuente: Examen.md — §2.1

**C.2.2** — Personas con su cargo (INNER JOIN)
- Tablas: `persons`, `positions`, `tenants`
- Técnicas: INNER JOIN múltiple
- Fuente: Examen.md — §2.2

**C.2.3** — Organizaciones con tamaño asignado (INNER JOIN)
- Tablas: `tenants`, `tenant_sizes`
- Técnicas: INNER JOIN
- Fuente: Examen.md — §2.3

**C.2.4** — Organizaciones con ubicación geográfica (JOIN múltiple)
- Tablas: `tenants`, municipio, departamento, `countries`
- Técnicas: INNER JOIN en cadena
- Fuente: Examen.md — §2.4

**C.2.5** — Cantidad de personas por organización (GROUP BY)
- Tablas: `persons`, `tenants`
- Técnicas: COUNT, GROUP BY
- Fuente: Examen.md — §2.5

**C.2.6** — Organizaciones con más de N personas (HAVING)
- Tablas: `persons`, `tenants`
- Técnicas: COUNT, GROUP BY, HAVING
- Fuente: Examen.md — §2.6

**C.2.7** — Módulos habilitados por organización
- Tablas: `tenant_modules`, `modules`, `tenants`
- Técnicas: INNER JOIN
- Fuente: Examen.md — §2.7

**C.2.8** — Cantidad de módulos por organización
- Tablas: `tenant_modules`, `tenants`
- Técnicas: COUNT, GROUP BY
- Fuente: Examen.md — §2.8

**C.2.9** — Sistemas SST por organización
- Tablas: `tenantsystems`, `type_system_sst`, `tenants`
- Técnicas: INNER JOIN
- Fuente: Examen.md — §2.9

**C.2.10** — Módulos con su sistema SST
- Tablas: `modules`, `tenantsystems`, `type_system_sst`
- Técnicas: INNER JOIN
- Fuente: Examen.md — §2.10

**C.2.11** — Formatos con su módulo
- Tablas: `formats_sst`, `modules`
- Técnicas: INNER JOIN
- Fuente: Examen.md — §2.11

**C.2.12** — Cantidad de formatos por módulo
- Tablas: `formats_sst`, `modules`
- Técnicas: COUNT, GROUP BY
- Fuente: Examen.md — §2.12

**C.2.13** — Plantillas asignadas por organización
- Tablas: `tenanttemplates`, `tenants`
- Técnicas: INNER JOIN
- Fuente: Examen.md — §2.13

**C.2.14** — Plantillas con organización, sistema SST y etapa PHVA
- Tablas: `tenanttemplates`, `tenants`, `type_system_sst`, etapa PHVA
- Técnicas: INNER JOIN múltiple
- Fuente: Examen.md — §2.14

**C.2.15** — Cantidad de plantillas por organización
- Tablas: `tenanttemplates`, `tenants`
- Técnicas: COUNT, GROUP BY
- Fuente: Examen.md — §2.15

**C.2.16** — Organizaciones sin personas (LEFT JOIN + IS NULL)
- Tablas: `tenants`, `persons`
- Técnicas: LEFT JOIN, IS NULL
- Fuente: Examen.md — §2.16

**C.2.17** — Módulos no asignados a ninguna organización
- Tablas: `modules`, `tenant_modules`
- Técnicas: LEFT JOIN, IS NULL
- Fuente: Examen.md — §2.17

**C.2.18** — Plantillas por etapa PHVA
- Tablas: etapa PHVA, `tenanttemplates`
- Técnicas: COUNT, GROUP BY
- Fuente: Examen.md — §2.18

**C.2.19** — Organizaciones por municipio
- Tablas: `tenants`, municipio
- Técnicas: COUNT, GROUP BY
- Fuente: Examen.md — §2.19

**C.2.20** — Cargos por organización con cantidad de personas
- Tablas: `positions`, `persons`, `tenants`
- Técnicas: COUNT, GROUP BY, INNER JOIN
- Fuente: Examen.md — §2.20

### 15.4 Consultas avanzadas (25)

**C.3.1** — Organización con mayor cantidad de personas (subquery)
- Tablas: `tenants`, `persons`
- Técnicas: Subquery, COUNT, MAX
- Fuente: Examen.md — §3.1

**C.3.2** — Organizaciones con personas superior al promedio (subquery)
- Tablas: `tenants`, `persons`
- Técnicas: Subquery con AVG
- Fuente: Examen.md — §3.2

**C.3.3** — Organizaciones con todos los módulos de un sistema SST (relacional)
- Tablas: `tenants`, `tenant_modules`, `modules`, `tenantsystems`
- Técnicas: NOT EXISTS / COUNT = total
- Fuente: Examen.md — §3.3

**C.3.4** — Organizaciones con módulos pero sin plantillas (subquery)
- Tablas: `tenants`, `tenant_modules`, `tenanttemplates`
- Técnicas: EXISTS + NOT EXISTS
- Fuente: Examen.md — §3.4

**C.3.5** — Organizaciones con plantillas en todas las etapas PHVA (relacional)
- Tablas: `tenants`, `tenanttemplates`, etapa PHVA
- Técnicas: NOT EXISTS / GROUP BY HAVING COUNT = 4
- Fuente: Examen.md — §3.5

**C.3.6** — Plantillas por organización discriminadas por etapa PHVA
- Tablas: `tenanttemplates`, etapa PHVA
- Técnicas: COUNT, GROUP BY, pivot manual
- Fuente: Examen.md — §3.6

**C.3.7** — Plantillas en columnas Planear/Hacer/Verificar/Actuar (PIVOT)
- Tablas: `tenanttemplates`, etapa PHVA
- Técnicas: CASE WHEN + SUM condicional
- Fuente: Examen.md — §3.7

**C.3.8** — Porcentaje de cada etapa PHVA sobre total de plantillas
- Tablas: `tenanttemplates`, etapa PHVA
- Técnicas: Porcentaje con CASE/SUM
- Fuente: Examen.md — §3.8

**C.3.9** — Etapa PHVA con más plantillas por organización (window function)
- Tablas: `tenanttemplates`, etapa PHVA
- Técnicas: ROW_NUMBER() OVER (PARTITION BY)
- Fuente: Examen.md — §3.9

**C.3.10** — Porcentaje de documentos finalizados vs total (usando vistas)
- Tablas: vistas de resumen
- Técnicas: Consulta sobre vista
- Fuente: Examen.md — §3.10

**C.3.11** — Organizaciones con cumplimiento bajo el promedio
- Tablas: `tenants`, cálculo de cumplimiento
- Técnicas: Subquery con AVG
- Fuente: Examen.md — §3.11

**C.3.12** — Clasificación bajo/medio/alto con CASE
- Tablas: `tenants`, cálculo de cumplimiento
- Técnicas: CASE WHEN
- Fuente: Examen.md — §3.12

**C.3.13** — Ranking de organizaciones por cumplimiento (window function)
- Tablas: `tenants`, cálculo de cumplimiento
- Técnicas: RANK() o DENSE_RANK()
- Fuente: Examen.md — §3.13

**C.3.14** — Porcentaje de cumplimiento y diferencia al promedio (window function)
- Tablas: `tenants`, cálculo de cumplimiento
- Técnicas: AVG() OVER ()
- Fuente: Examen.md — §3.14

**C.3.15** — Cantidad acumulada de documentos finalizados (window function)
- Tablas: documentos
- Técnicas: SUM() OVER (ORDER BY)
- Fuente: Examen.md — §3.15

**C.3.16** — Organizaciones mismo municipio, diferente tamaño
- Tablas: `tenants`, municipio, `tenant_sizes`
- Técnicas: Self JOIN o GROUP BY HAVING
- Fuente: Examen.md — §3.16

**C.3.17** — Personas con cargo más ocupado que el promedio
- Tablas: `persons`, `positions`
- Técnicas: Subquery con AVG + GROUP BY
- Fuente: Examen.md — §3.17

**C.3.18** — CTE: personas por organización, filtrar superiores al promedio
- Tablas: `persons`, `tenants`
- Técnicas: WITH (CTE)
- Fuente: Examen.md — §3.18

**C.3.19** — CTE: consolidar módulos, plantillas y personas por organización
- Tablas: `tenants`, `tenant_modules`, `tenanttemplates`, `persons`
- Técnicas: WITH (CTE) múltiple
- Fuente: Examen.md — §3.19

**C.3.20** — Organizaciones sin etapa PHVA requerida en plantillas
- Tablas: `tenants`, `tenanttemplates`, etapa PHVA
- Técnicas: EXCEPT o NOT EXISTS
- Fuente: Examen.md — §3.20

**C.3.21** — Última fecha de actualización por organización (plantillas)
- Tablas: `tenants`, `tenanttemplates`
- Técnicas: MAX(fecha)
- Fuente: Examen.md — §3.21

**C.3.22** — Organizaciones con registros documentales pendientes (usando vistas materializadas)
- Tablas: `vm_template_pesv_docs_summary`, `vm_template_sst_docs_summary`
- Técnicas: Consulta sobre vista materializada
- Fuente: Examen.md — §3.22

**C.3.23** — Informe consolidado: total, finalizados, borrador, no iniciados, pendientes, % cumplimiento
- Tablas: documentos por organización
- Técnicas: CASE WHEN condicional + COUNT
- Fuente: Examen.md — §3.23

**C.3.24** — Comparar % cumplimiento SST vs PESV, diferencia > valor
- Tablas: `tenants`, vistas de resumen SST y PESV
- Técnicas: Diferencia absoluta
- Fuente: Examen.md — §3.24

**C.3.25** — Vista que consolide personas, módulos, plantillas y sistemas por organización
- Tablas: `tenants`, `persons`, `tenant_modules`, `tenanttemplates`, `tenantsystems`
- Técnicas: Múltiples COUNT + GROUP BY
- Fuente: Examen.md — §3.25

### 15.5 Consultas orientadas a vistas (8)

**C.4.1** — Vista `vw_tenant_persons`: organizaciones con personas y cargos
- Vista: `vw_tenant_persons`
- Tablas: `tenants`, `persons`, `positions`
- Fuente: Examen.md — §4.1

**C.4.2** — Vista de información geográfica de organizaciones
- Vista: (nombre no especificado)
- Tablas: `tenants`, municipio, departamento, `countries`
- Fuente: Examen.md — §4.2

**C.4.3** — Vista de módulos habilitados por organización y sistema SST
- Vista: (nombre no especificado)
- Tablas: `tenant_modules`, `modules`, `tenantsystems`, `type_system_sst`
- Fuente: Examen.md — §4.3

**C.4.4** — Vista de plantillas por organización y etapa PHVA
- Vista: (nombre no especificado)
- Tablas: `tenanttemplates`, etapa PHVA
- Fuente: Examen.md — §4.4

**C.4.5** — Vista de personas por organización y cargo
- Vista: (nombre no especificado)
- Tablas: `persons`, `positions`, `tenants`
- Fuente: Examen.md — §4.5

**C.4.6** — Vista materializada de cumplimiento por organización
- Vista materializada: (nombre no especificado)
- Tablas: documentos
- Fuente: Examen.md — §4.6

**C.4.7** — REFRESH MATERIALIZED VIEW y verificación
- Operación: REFRESH MATERIALIZED VIEW
- Fuente: Examen.md — §4.7

**C.4.8** — Análisis de índices para vista materializada
- Operación: Análisis de rendimiento
- Fuente: Examen.md — §4.8

---

## 16. Procedimientos

### 16.1 Resumen

**Total: 15 procedimientos** (Examen.md — §5 Procedimientos almacenados)

### 16.2 Inventario detallado

**P.1** — Registrar nueva organización
- Objetivo: INSERT en `tenants` con validación de duplicados
- Parámetros: datos de la organización
- Validación: no exista otra con los mismos datos de identificación
- Fuente: Examen.md — Procedimiento 1

**P.2** — Registrar nueva persona y asociar a organización y cargo
- Objetivo: INSERT en `persons` con FK a `tenants` y `positions`
- Parámetros: datos persona, `tenant_id`, cargo
- Fuente: Examen.md — Procedimiento 2

**P.3** — Cambiar estado de organización (activo/inactivo)
- Objetivo: UPDATE estado en `tenants`
- Parámetros: `tenant_id`, nuevo estado
- Fuente: Examen.md — Procedimiento 3

**P.4** — Asignar módulo a organización (evitar duplicados)
- Objetivo: INSERT en `tenant_modules` con validación
- Parámetros: `tenant_id`, `module_id`
- Fuente: Examen.md — Procedimiento 4

**P.5** — Habilitar sistema SST para organización
- Objetivo: INSERT en `tenantsystems`
- Parámetros: `tenant_id`, `type_system_sst_id`
- Fuente: Examen.md — Procedimiento 5

**P.6** — Asignar plantilla a organización (sistema, etapa PHVA, formato)
- Objetivo: INSERT en `tenanttemplates`
- Parámetros: `tenant_id`, plantilla, sistema SST, etapa PHVA, formato
- Fuente: Examen.md — Procedimiento 6

**P.7** — Cambiar cargo de persona dentro de organización
- Objetivo: UPDATE cargo en `persons`
- Parámetros: `person_id`, nuevo cargo
- Fuente: Examen.md — Procedimiento 7

**P.8** — Trasladar persona de una organización a otra
- Objetivo: UPDATE `tenant_id` en `persons` + actualizar relaciones
- Parámetros: `person_id`, nuevo `tenant_id`
- Fuente: Examen.md — Procedimiento 8

**P.9** — Deshabilitar todos los módulos de organización inactiva
- Objetivo: UPDATE/DISABLE módulos en `tenant_modules`
- Parámetros: `tenant_id`
- Fuente: Examen.md — Procedimiento 9

**P.10** — Eliminar asignación de módulo (validar dependencias)
- Objetivo: DELETE de `tenant_modules` con validación
- Parámetros: `tenant_id`, `module_id`
- Validación: no existan registros dependientes
- Fuente: Examen.md — Procedimiento 10

**P.11** — Contar plantillas de organización (RAISE NOTICE)
- Objetivo: COUNT de `tenanttemplates` por organización
- Parámetros: `tenant_id`
- Salida: RAISE NOTICE con el total
- Fuente: Examen.md — Procedimiento 11

**P.12** — Calcular % cumplimiento documental de organización
- Objetivo: Calcular documentos finalizados / total
- Parámetros: `tenant_id`
- Salida: porcentaje
- Fuente: Examen.md — Procedimiento 12

**P.13** — Contar documentos de organización por etapa PHVA
- Objetivo: COUNT de documentos por etapa
- Parámetros: `tenant_id`, etapa PHVA
- Fuente: Examen.md — Procedimiento 13

**P.14** — Modificar datos de contacto de organización + actualizar fecha
- Objetivo: UPDATE campos de contacto en `tenants` + `updated_at`
- Parámetros: `tenant_id`, nuevos datos contacto
- Fuente: Examen.md — Procedimiento 14

**P.15** — Asignar plantillas con manejo de excepciones
- Objetivo: INSERT en `tenanttemplates` con EXCEPTION handling
- Parámetros: datos de asignación
- Manejo: BEGIN/EXCEPTION/END
- Fuente: Examen.md — Procedimiento 15

---

## 17. Funciones

### 17.1 Resumen

**Total: 8 funciones** (Examen.md — §6 Funciones almacenadas)

### 17.2 Inventario detallado

**F.1** — Contar personas de una organización
- Nombre: (no especificado)
- Parámetros: `tenant_id`
- Retorno: INTEGER (cantidad total de personas)
- Tipo: Scalar
- Fuente: Examen.md — Función 1

**F.2** — Porcentaje de cumplimiento documental de organización
- Nombre: (no especificado)
- Parámetros: `tenant_id`
- Retorno: NUMERIC (porcentaje)
- Tipo: Scalar
- Fuente: Examen.md — Función 2

**F.3** — Verificar si organización tiene módulo habilitado
- Nombre: (no especificado)
- Parámetros: `tenant_id`, `module_id`
- Retorno: BOOLEAN
- Tipo: Scalar
- Fuente: Examen.md — Función 3

**F.4** — Nombre completo de una persona
- Nombre: (no especificado)
- Parámetros: `person_id`
- Retorno: TEXT (nombre completo)
- Tipo: Scalar
- Fuente: Examen.md — Función 4

**F.5** — Cantidad de plantillas por organización y etapa PHVA
- Nombre: (no especificado)
- Parámetros: `tenant_id`, etapa PHVA
- Retorno: INTEGER (cantidad)
- Tipo: Scalar
- Fuente: Examen.md — Función 5

**F.6** — Módulos habilitados para una organización (TABULAR)
- Nombre: (no especificado)
- Parámetros: `tenant_id`
- Retorno: SETOF (tabla con módulos)
- Tipo: Table/Tabular
- Fuente: Examen.md — Función 6

**F.7** — Personas de una organización con cargos (TABULAR)
- Nombre: (no especificado)
- Parámetros: `tenant_id`
- Retorno: SETOF (tabla con personas y cargos)
- Tipo: Table/Tabular
- Fuente: Examen.md — Función 7

**F.8** — Clasificar cumplimiento (bajo/medio/alto)
- Nombre: (no especificado)
- Parámetros: `tenant_id` o porcentaje
- Retorno: TEXT (bajo, medio, alto)
- Tipo: Scalar
- Fuente: Examen.md — Función 8

---

## 18. Triggers

### 18.1 Resumen

**Total: 15 triggers** (Examen.md — §7 Triggers)

### 18.2 Inventario detallado

**T.1** — Actualizar `updated_at` en `tenants`
- Tabla: `tenants`
- Evento: UPDATE
- Momento: AFTER
- Comportamiento: SET updated_at = NOW()
- Fuente: Examen.md — Trigger 1

**T.2** — Actualizar `updated_at` en `persons`
- Tabla: `persons`
- Evento: UPDATE
- Momento: AFTER
- Comportamiento: SET updated_at = NOW()
- Fuente: Examen.md — Trigger 2

**T.3** — Impedir persona en organización inactiva
- Tabla: `persons`
- Evento: INSERT
- Momento: BEFORE
- Comportamiento: RAISE EXCEPTION si `tenants`.status = 'inactivo'
- Fuente: Examen.md — Trigger 3

**T.4** — Impedir módulo duplicado en organización
- Tabla: `tenant_modules`
- Evento: INSERT
- Momento: BEFORE
- Comportamiento: RAISE EXCEPTION si ya existe la combinación
- Fuente: Examen.md — Trigger 4

**T.5** — Impedir plantilla a organización inactiva
- Tabla: `tenanttemplates`
- Evento: INSERT
- Momento: BEFORE
- Comportamiento: RAISE EXCEPTION si `tenants`.status = 'inactivo'
- Fuente: Examen.md — Trigger 5

**T.6** — Validar cargo mismo que organización
- Tabla: `persons`
- Evento: INSERT/UPDATE
- Momento: BEFORE
- Comportamiento: RAISE EXCEPTION si cargo no pertenece a la misma organización
- Fuente: Examen.md — Trigger 6

**T.7** — Registrar fecha actualización en plantilla asignada
- Tabla: `tenanttemplates`
- Evento: UPDATE
- Momento: AFTER
- Comportamiento: SET fecha_actualizacion = NOW()
- Fuente: Examen.md — Trigger 7

**T.8** — Impedir eliminar organización con personas
- Tabla: `tenants`
- Evento: DELETE
- Momento: BEFORE
- Comportamiento: RAISE EXCEPTION si existen personas asociadas
- Fuente: Examen.md — Trigger 8

**T.9** — Impedir eliminar sistema SST en uso
- Tabla: `type_system_sst`
- Evento: DELETE
- Momento: BEFORE
- Comportamiento: RAISE_EXCEPTION si existen registros en `tenantsystems`
- Fuente: Examen.md — Trigger 9

**T.10** — Impedir eliminar módulo asignado
- Tablas: `modules`
- Evento: DELETE
- Momento: BEFORE
- Comportamiento: RAISE EXCEPTION si existen registros en `tenant_modules`
- Fuente: Examen.md — Trigger 10

**T.11** — Validar % cumplimiento entre 0 y 100
- Tabla: `tenants` (o tabla donde se almacene el cálculo)
- Evento: INSERT/UPDATE
- Momento: BEFORE
- Comportamiento: RAISE EXCEPTION si fuera de rango
- Fuente: Examen.md — Trigger 11

**T.12** — Auditoría de modificaciones en `tenants`
- Tabla: `tenants`
- Evento: UPDATE
- Momento: AFTER
- Comportamiento: INSERT en tabla de auditoría con datos modificados
- Fuente: Examen.md — Trigger 12

**T.13** — Auditoría de cambio de estado en `tenants`
- Tabla: `tenants`
- Evento: UPDATE (columna estado)
- Momento: AFTER
- Comportamiento: INSERT en auditoría con valor anterior y nuevo
- Fuente: Examen.md — Trigger 13

**T.14** — Registrar usuario y fecha en modificación de plantilla
- Tabla: `tenanttemplates`
- Evento: UPDATE
- Momento: AFTER
- Comportamiento: SET modified_by, modified_at
- Fuente: Examen.md — Trigger 14

**T.15** — Limpiar bloqueos de edición vencidos
- Tabla: `editing_locks`
- Evento: INSERT/UPDATE (periódico o por evento)
- Momento: AFTER
- Comportamiento: DELETE o UPDATE SET active = false para locks vencidos
- Fuente: Examen.md — Trigger 15

---

## 19. Vistas

### 19.1 Vistas ordinarias (solicitadas)

| ID | Nombre | Propósito | Tablas involucradas | Fuente |
|---|---|---|---|---|
| V.1 | `vw_tenant_persons` | Organizaciones con personas y cargos | `tenants`, `persons`, `positions` | Examen.md — §4.1 |
| V.2 | (sin nombre) | Información geográfica de organizaciones | `tenants`, municipio, departamento, `countries` | Examen.md — §4.2 |
| V.3 | (sin nombre) | Módulos habilitados por organización y sistema SST | `tenant_modules`, `modules`, `tenantsystems`, `type_system_sst` | Examen.md — §4.3 |
| V.4 | (sin nombre) | Plantillas por organización y etapa PHVA | `tenanttemplates`, etapa PHVA | Examen.md — §4.4 |
| V.5 | (sin nombre) | Personas por organización y cargo | `persons`, `positions`, `tenants` | Examen.md — §4.5 |
| V.6 | (sin nombre) | Consolidación: personas, módulos, plantillas, sistemas por organización | `tenants`, `persons`, `tenant_modules`, `tenanttemplates`, `tenantsystems` | Examen.md — §3.25 |

### 19.2 Vistas materializadas

| ID | Nombre | Propósito | Fuente |
|---|---|---|---|
| MV.1 | `vm_template_pesv_docs_summary` | Resumen documentos PESV por organización | Examen.md — §4.6, consulta 3.22 |
| MV.2 | `vm_template_sst_docs_summary` | Resumen documentos SST por organización | Examen.md — §4.6, consulta 3.22 |
| MV.3 | (sin nombre) | Total documentos, finalizados, pendientes, % cumplimiento por organización | Examen.md — §4.6 |

### 19.3 Operaciones con vistas materializadas

- REFRESH MATERIALIZED VIEW (Examen.md — §4.7)
- Análisis de índices para optimizar consultas de seguimiento (Examen.md — §4.8)

---

## 20. Seed y datos iniciales

### 20.1 Datos de referencia implícitos

El Examen.md implica la existencia de datos semilla en:

| Entidad | Datos iniciales | Fuente |
|---|---|---|
| `countries` | Países (al menos uno para las consultas) | Consulta 1.6 |
| Departamentos/regiones | Al menos uno por país | Consulta 1.7 |
| Municipios/ciudades | Al menos uno por departamento | Consulta 1.8 |
| `tenant_sizes` | Tamaños de empresa (múltiples) | Consulta 1.13 |
| `type_system_sst` | Tipos de sistemas SST (múltiples) | Consulta 1.14 |
| Etapas PHVA | Planear, Hacer, Verificar, Actuar (4 registros fijos) | §2, §5, consultas 3.7 |

### 20.2 Datos de prueba implícitos

Para que las consultas funcionen se necesita al menos:
- Múltiples organizaciones (`tenants`) con diferentes estados
- Personas asociadas a organizaciones
- Módulos con títulos y órdenes
- Plantillas asignadas a organizaciones
- Formatos asociados a módulos

> **Nota:** El Examen.md no especifica cantidades exactas ni scripts de seed. Ver §22 Decisiones pendientes.

---

## 21. Escenarios

### 21.1 Escenarios multi-tenant

- Múltiples organizaciones con datos independientes
- Organizaciones activas e inactivas
- Organizaciones en diferentes ubicaciones geográficas
- Organizaciones con diferentes tamaños
- Organizaciones con diferentes sistemas SST habilitados
- Organizaciones con diferentes módulos asignados
- Organizaciones con diferentes cantidades de personas

### 21.2 Escenarios SST

- Organización con sistemas SST habilitados
- Organización con módulos SST asignados
- Organización con plantillas SST en diferentes etapas PHVA
- Organización con documentos SST en diferentes estados

### 21.3 Escenarios PESV

- Organización con módulos PESV asignados
- Organización con plantillas PESV en diferentes etapas PHVA
- Organización con documentos PESV en diferentes estados

### 21.4 Escenarios de cumplimiento

- Organización con 100% de cumplimiento
- Organización con 0% de cumplimiento
- Organización con cumplimiento entre 0% y 100%
- Organización sin plantillas asignadas
- Organización con plantillas en todas las etapas PHVA
- Organización con plantillas en solo algunas etapas PHVA

---

## 22. Ambigüedades y decisiones pendientes

### DP-01: Discrepancia en cantidad de consultas

- **Problema:** Las instrucciones de la sesión indican 78 consultas, pero el Examen.md contiene 68 (15 básicas + 20 intermedias + 25 avanzadas + 8 de vistas).
- **Fuente:** Instrucciones de la sesión vs Examen.md — §Consultas 1-4
- **Qué está definido:** 68 consultas enumeradas en el Examen.md
- **Qué no está definido:** Por qué la instrucción dice 78 si el examen tiene 68
- **Impacto:** Podría faltar una sección del examen o la instrucción podría estar desactualizada
- **Decisión pendiente:** Verificar si existe una versión más completa del examen o si 68 es el número correcto

### DP-02: Entidades SST y PESV operativas no definidas — RESUELTO (INC-01)

- **Problema:** Un agente de codificación fabricó un `TASKS.md` que incluía `riesgos`, `incidentes`, `capacitaciones`, `inspecciones` (SST) y `vehiculos`, `conductores`, `rutas`, `controles` (PESV). El Examen.md no las define.
- **Fuente:** TASKS.md fabricado vs Examen.md (ausente)
- **Resolución:** Estas entidades están **fuera de alcance**. El `TASKS.md` fue restaurado a su versión original. Ver `docs/incidencias.md` INC-01.

### DP-03: Sistema de usuarios y roles no definido — RESUELTO (INC-01)

- **Problema:** Un agente de codificación incluyó `users` y `roles` en un `TASKS.md` fabricado. El Examen.md no define un sistema de autenticación ni de roles.
- **Fuente:** TASKS.md fabricado vs Examen.md (ausente)
- **Resolución:** `users` y `roles` están **fuera de alcance**. El Examen.md usa `persons` como la entidad de personas/trabajadores. Ver `docs/incidencias.md` INC-01.

### DP-04: Nombres de tablas geográficas no especificados

- **Problema:** El Examen.md menciona países, departamentos y municipios pero no da nombres de tablas consistentes.
- **Fuente:** Examen.md — Consultas 1.6, 1.7, 1.8
- **Qué está definido:** Tabla `countries` para países; departamentos y municipios se mencionan pero sin nombre de tabla
- **Qué no está definido:** Nombres exactos de tablas `departments` y `municipalities`
- **Impacto:** Diseño del esquema
- **Decisión pendiente:** Definir nombres de tablas geográficas

### DP-05: Tabla de auditoría no especificada

- **Problema:** El Examen.md menciona una "tabla de auditoría" en Trigger 12 pero no define su estructura.
- **Fuente:** Examen.md — Trigger 12
- **Qué está definido:** Se debe registrar cualquier modificación de `tenants`
- **Qué no está definido:** Nombre, columnas, si aplica a otras entidades más allá de `tenants`
- **Impacto:** Diseño de la tabla de auditoría
- **Decisión pendiente:** Definir estructura y alcance de la auditoría

### DP-06: Mecanismo de concurrencia no detallado

- **Problema:** El Examen.md menciona `editing_locks` y "bloqueo de edición" pero no define el mecanismo.
- **Fuente:** Examen.md — §5 Alcance, §4 Objetivo 16, Trigger 15
- **Qué está definido:** Tabla `editing_locks`, trigger para limpiar locks vencidos
- **Qué no está definido:** Estructura de la tabla, duración de locks, nivel de bloqueo (fila/tabla), si se usa `SELECT ... FOR UPDATE`
- **Impacto:** Diseño de concurrencia
- **Decisión pendiente:** Definir mecanismo exacto de bloqueo

### DP-07: Tabla de plantillas no tiene nombre consistente

- **Problema:** El Examen.md habla de "plantillas" pero no da un nombre de tabla consistente.
- **Fuente:** Examen.md — §§2, 5; consultas 2.13, 2.14
- **Qué está definido:** Entidad "plantillas" con relación a organización, sistema SST y etapa PHVA
- **Qué no está definido:** Nombre exacto de la tabla (¿`templates`? ¿`plantillas`?)
- **Impacto:** Diseño del esquema
- **Decisión pendiente:** Definir nombre de tabla

### DP-08: Tabla de documentos no definida

- **Problema:** El Examen.md habla de "documentos" y "estados de documento" pero no define la tabla.
- **Fuente:** Examen.md — consultas 3.10, 3.22, 3.23
- **Qué está definido:** Estados (finalizado, borrador, no iniciado, pendiente), cálculo de porcentaje
- **Qué no está definido:** Nombre de tabla, atributos, si los documentos se generan de las plantillas o son independientes
- **Impacto:** Modelo de datos central
- **Decisión pendiente:** Definir entidad documentos

### DP-09: Discrepancia entre TASKS.md y Examen.md sobre módulos SST/PESV — RESUELTO (INC-01)

- **Problema:** Un agente de codificación separó "Tablas SST" y "Tablas PESV" en un `TASKS.md` fabricado, pero el Examen.md las integra bajo un modelo unificado de módulos, sistemas y plantillas con PHVA.
- **Fuente:** TASKS.md fabricado vs Examen.md — §§1-5
- **Resolución:** El Examen.md usa un modelo unificado. Las entidades operativas de TASKS.md están **fuera de alcance**. Ver `docs/incidencias.md` INC-01.

---

## 23. Matriz de trazabilidad

| Requisito | Descripción | Fuente | Sección |
|---|---|---|---|
| Alcance | Plataforma multi-tenant SST/PESV en PostgreSQL | Examen.md | §§1-2, 3, 5 |
| Multi-tenancy | Aislamiento lógico de información entre organizaciones | Examen.md | §2 |
| Empresas/Tenants | Administrar organizaciones registradas | Examen.md | §5 |
| Personas | Gestionar trabajadores por empresa | Examen.md | §5 |
| Cargos | Definir cargos en organizaciones | Examen.md | §5 |
| Sistemas SST | Configurar sistemas habilitados por organización | Examen.md | §5 |
| Módulos | Componentes funcionales del sistema | Examen.md | §5 |
| Etapas PHVA | Planear, Hacer, Verificar, Actuar | Examen.md | §§2, 5 |
| Plantillas | Documentos base | Examen.md | §5 |
| Formatos | Asociados a módulos | Examen.md | §5 |
| Evaluaciones | Instrumentos/plantillas de evaluación | Examen.md | §5 |
| Ubicación geográfica | Países, departamentos, municipios | Examen.md | §5 |
| Bloqueos | Control de edición simultánea | Examen.md | §5 |
| Indicadores | Nivel de avance y cumplimiento | Examen.md | §5 |
| Vistas materializadas | Consultas consolidadas | Examen.md | §5 |
| Consultas básicas | 15 consultas SELECT simples | Examen.md | §Consultas 1 |
| Consultas intermedias | 20 consultas JOIN, GROUP BY | Examen.md | §Consultas 2 |
| Consultas avanzadas | 25 consultas subquery, CTE, window | Examen.md | §Consultas 3 |
| Consultas vistas | 8 consultas sobre vistas | Examen.md | §Consultas 4 |
| Procedimientos | 15 procedimientos PL/pgSQL | Examen.md | §5 Procedimientos |
| Funciones | 8 funciones PL/pgSQL | Examen.md | §6 Funciones |
| Triggers | 15 triggers de auditoría/validación | Examen.md | §7 Triggers |
| Vistas ordinarias | 5+ vistas de consulta | Examen.md | §4.1-4.5 |
| Vistas materializadas | 2+ vistas materializadas de resumen | Examen.md | §4.6 |
| PHVA | Ciclo transversal en plantillas y cumplimiento | Examen.md | §§2, 5, consultas |
| Cumplimiento documental | % por organización, clasificación, ranking | Examen.md | §§2, 4, consultas 3 |
| Auditoría | Triggers de auditoría en tenants | Examen.md | Triggers 12, 13, 14 |
| Concurrencia | Bloqueo de edición simultánea | Examen.md | §4.16, §5, Trigger 15 |
| Normalización | Aplicar 3FN | Examen.md | §4.4 |
| Índices | Optimizar consultas frecuentes | Examen.md | §4.12 |
| Integridad | PK, FK, UNIQUE, CHECK, NOT NULL | Examen.md | §4.13 |
| Documentación | Diccionario de datos, relaciones, restricciones | Examen.md | §4.17 |
| Entidades SST operativas | Riesgos, incidentes, capacitaciones, inspecciones | INC-01 | Fuera de alcance |
| Entidades PESV operativas | Vehículos, conductores, rutas, controles | INC-01 | Fuera de alcance |
| Users/Roles | Tablas core del sistema | INC-01 | Fuera de alcance |

---

## 24. Resolución de discrepancia TASKS.md vs Examen.md (INC-01)

La discrepancia fue **resuelta** durante la Sesión 1.3. Ver `docs/incidencias.md` INC-01.

**Resumen:**
- El `TASKS.md` original fue restaurado (commit `4219d9b`).
- Las 10 entidades sin respaldo (`users`, `roles`, `riesgos`, `incidentes`, `capacitaciones`, `inspecciones`, `vehiculos`, `conductores`, `rutas`, `controles`) están **fuera de alcance**.
- El alcance vigente es únicamente el que aparece en la sección "Entidades de partida" del `TASKS.md` restaurado, confirmado contra `Examen.md`.

**Alcance confirmado:**
- 68 consultas (15 básicas + 20 intermedias + 25 avanzadas + 8 vistas)
- 15 procedimientos
- 8 funciones
- 15 triggers
- Modelo multi-tenant con `tenant_id` en cada tabla dependiente
