# Modelo Conceptual — Sesión 1.3-A

> Base conceptual para el modelo entidad-relación del sistema SST-PESV
>
> Solo análisis, inventario y trazabilidad. Sin DDL, sin diagramas definitivos.

---

## 1. Verificación grep — Entidades sospechosas

### Comando ejecutado

```bash
grep -n -i "riesgo\|incidente\|capacitacion\|inspeccion\|vehiculo\|conductor\|ruta\|control\|users\|roles" TASKS.md Examen.md README.md
```

### Salida literal

```
TASKS.md:26:- [ ] Tablas core: tenants, users, roles
TASKS.md:27:- [ ] Tablas SST: riesgos, incidentes, capacitaciones, inspecciones
TASKS.md:28:- [ ] Tablas PESV: vehiculos, conductores, rutas, controles
Examen.md:13:...localización geográfica y mecanismos de control de edición...
Examen.md:40:- Control de edición de documentos.
Examen.md:70:11. Implementar triggers que permitan controlar procesos automáticos...
Examen.md:98:| Bloqueos | Controlar la edición simultánea de recursos |
Examen.md:202:...estructuras de control, validaciones, manejo de excepciones...
Examen.md:215:...eliminar de manera controlada una asignación de módulo...
Examen.md:220:...manejo de excepciones dentro de un procedimiento...
```

### Análisis por término

| Término | TASKS.md | Examen.md | README.md | Coincidencia textual | ¿Representa entidad? |
|---|---|---|---|---|---|
| `users` | Línea 26 | NO | NO | Solo TASKS.md | Solo TASKS.md — sin definición en Examen.md |
| `roles` | Línea 26 | NO | NO | Solo TASKS.md | Solo TASKS.md — sin definición en Examen.md |
| `riesgos` | Línea 27 | NO | NO | Solo TASKS.md | Solo TASKS.md — sin definición en Examen.md |
| `incidentes` | Línea 27 | NO | NO | Solo TASKS.md | Solo TASKS.md — sin definición en Examen.md |
| `capacitaciones` | Línea 27 | NO | NO | Solo TASKS.md | Solo TASKS.md — sin definición en Examen.md |
| `inspecciones` | Línea 27 | NO | NO | Solo TASKS.md | Solo TASKS.md — sin definición en Examen.md |
| `vehiculos` | Línea 28 | NO | NO | Solo TASKS.md | Solo TASKS.md — sin definición en Examen.md |
| `conductores` | Línea 28 | NO | NO | Solo TASKS.md | Solo TASKS.md — sin definición en Examen.md |
| `rutas` | Línea 28 | NO | NO | Solo TASKS.md | Solo TASKS.md — sin definición en Examen.md |
| `controles` | Línea 28 | Líneas 13,40,70,98,202,215,220 | NO | Examen.md usa "control" como concepto genérico | NO es entidad — es "control de edición" (= `editing_locks`) |

### Conclusión del grep

- **`users`, `roles`**: Aparecen SOLO en TASKS.md línea 26. El Examen.md NO define estas entidades.
- **`riesgos`, `incidentes`, `capacitaciones`, `inspecciones`**: Aparecen SOLO en TASKS.md línea 27. El Examen.md NO define estas entidades.
- **`vehiculos`, `conductores`, `rutas`**: Aparecen SOLO en TASKS.md línea 28. El Examen.md NO define estas entidades.
- **`controles`**: En TASKS.md línea 28 aparece como entidad PESV. En Examen.md la palabra "control" aparece SOLO en contextos genéricos ("control de edición", "controlar procesos"). NO es la misma entidad.

---

## 2. Regla de alcance aplicada

Cada entidad fue clasificada según:

| Clase | Definición |
|---|---|
| EXPLÍCITA | Aparece directamente en Examen.md, TASKS.md o README.md como entidad o tabla |
| INFERIDA | No aparece como nombre de tabla, pero el requerimiento exige almacenar esa información |
| ESTRUCTURAL | Necesaria para representar correctamente una relación requerida |
| AMBIGUA | Evidencia parcial o contradictoria |

---

## 3. Inventario de entidades

### 3.1 Entidades EXPLÍCITAS en Examen.md

| Entidad | Tabla en Examen.md | Certeza | Fuente | Sección/Ejercicio | Evidencia literal | Propósito |
|---|---|---|---|---|---|---|
| Organización | `tenants` | EXPLÍCITA | Examen.md | Consultas 1.1, 1.2, 1.5, 1.11, 1.12; Trigger 1 | "tabla `tenants`" (línea 110) | Administrar organizaciones registradas |
| Persona | `persons` | EXPLÍCITA | Examen.md | Consultas 1.3, 1.4, 1.10; Trigger 2 | "tabla `persons`" (línea 112) | Gestionar trabajadores por empresa |
| Cargo | `positions` | EXPLÍCITA | Examen.md | Consulta 1.9 | "tabla `positions`" (línea 118) | Definir cargos en organizaciones |
| Tamaño empresa | `tenant_sizes` | EXPLÍCITA | Examen.md | Consulta 1.13 | "tabla `tenant_sizes`" (línea 122) | Clasificar tamaño de empresa |
| Tipo sistema SST | `type_system_sst` | EXPLÍCITA | Examen.md | Consulta 1.14 | "tabla `type_system_sst`" (línea 123) | Tipos de sistemas SST |
| País | `countries` | EXPLÍCITA | Examen.md | Consulta 1.6 | "tabla `countries`" (línea 115) | Ubicación geográfica |
| Bloqueo edición | `editing_locks` | EXPLÍCITA | Examen.md | §5 Alcance, Trigger 15 | "bloqueos de edición vencidos almacenados en `editing_locks`" (línea 257) | Control de edición simultánea |

### 3.2 Entidades INFERIDAS en Examen.md

| Entidad | Tabla inferida | Certeza | Fuente | Sección/Ejercicio | Evidencia | Propósito |
|---|---|---|---|---|---|---|
| Módulo | (nombre no especificado) | INFERIDA | Examen.md | Consulta 1.15 | "módulos registrados en el sistema mostrando su título, descripción y orden" (línea 124) | Componentes funcionales del sistema |
| Departamento/Región | (nombre no especificado) | INFERIDA | Examen.md | Consulta 1.7 | "departamentos o regiones pertenecientes a un país" (línea 116) | Ubicación geográfica |
| Municipio/Ciudad | (nombre no especificado) | INFERIDA | Examen.md | Consulta 1.8 | "municipios o ciudades correspondientes a un departamento" (línea 117) | Ubicación geográfica |
| Plantilla | (nombre no especificado) | INFERIDA | Examen.md | Consultas 2.13, 2.14; Procedimiento 6 | "plantillas asignadas a cada organización" (línea 144) | Documentos base |
| Etapa PHVA | (nombre no especificado) | INFERIDA | Examen.md | §2, §5, consultas 2.18, 3.5-3.9 | "etapas del ciclo PHVA" (línea 33), "Planear, Hacer, Verificar y Actuar" (línea 93) | Clasificar procesos PHVA |
| Formato | (nombre no especificado) | INFERIDA | Examen.md | Consultas 2.11, 2.12 | "formatos registrados en `formats_sst`" (línea 142) | Formatos asociados a módulos |
| Documento | (nombre no especificado) | INFERIDA | Examen.md | Consultas 3.10, 3.23 | "documentos finalizados", "documentos en borrador" (línea 181) | Documentos generados |
| Evaluación | (nombre no especificado) | INFERIDA | Examen.md | §2, §5 | "evaluaciones" (líneas 36, 96) | Instrumentos de evaluación |

### 3.3 Entidades ESTRUCTURALES (tablas puente)

| Entidad | Tabla | Certeza | Fuente primaria de la relación | Relación que representa | Justificación estructural |
|---|---|---|---|---|---|
| Tenant-Módulo | `tenant_modules` | ESTRUCTURAL | Examen.md — consultas 2.7, 2.8, 2.17 | tenants N:M modules | El Examen.md referencia explícitamente esta tabla en consulta 2.7: "mediante la relación existente en `tenant_modules`" |
| Tenant-Sistema SST | `tenantsystems` | ESTRUCTURAL | Examen.md — consulta 2.9 | tenants N:M type_system_sst | El Examen.md referencia explícitamente esta tabla en consulta 2.9: "utilizando las tablas `tenantsystems` y `type_system_sst`" |
| Tenant-Plantilla | `tenanttemplates` | ESTRUCTURAL | Examen.md — consultas 2.13, 2.14, 2.15 | tenants N:M templates (+ sistema SST, etapa PHVA, formato) | El Examen.md referencia explícitamente esta tabla en consulta 2.13: "mediante la tabla `tenanttemplates`" |

### 3.4 Entidades AMBIGUAS

| Entidad | Certeza | Fuente | Evidencia parcial | Por qué es ambigua |
|---|---|---|---|---|
| Tabla de auditoría | AMBIGUA | Examen.md — Trigger 12 | "registre en una tabla de auditoría cualquier modificación" (línea 254) | No especifica nombre, estructura ni si aplica solo a `tenants` o a otras entidades |

### 3.5 Entidades EXPLÍCITAS solo en TASKS.md (FUERA DE ALCANCE del Examen.md)

| Entidad | Archivo | Sección | Texto literal | Interpretación |
|---|---|---|---|---|
| `users` | TASKS.md | Sesión 1.4, línea 26 | "Tablas core: tenants, users, roles" | Nombre de tabla listado pero sin definición de atributos, relaciones ni reglas |
| `roles` | TASKS.md | Sesión 1.4, línea 26 | "Tablas core: tenants, users, roles" | Nombre de tabla listado pero sin definición de atributos, relaciones ni reglas |
| `riesgos` | TASKS.md | Sesión 1.4, línea 27 | "Tablas SST: riesgos, incidentes, capacitaciones, inspecciones" | Nombre de tabla listado pero sin definición |
| `incidentes` | TASKS.md | Sesión 1.4, línea 27 | "Tablas SST: riesgos, incidentes, capacitaciones, inspecciones" | Nombre de tabla listado pero sin definición |
| `capacitaciones` | TASKS.md | Sesión 1.4, línea 27 | "Tablas SST: riesgos, incidentes, capacitaciones, inspecciones" | Nombre de tabla listado pero sin definición |
| `inspecciones` | TASKS.md | Sesión 1.4, línea 27 | "Tablas SST: riesgos, incidentes, capacitaciones, inspecciones" | Nombre de tabla listado pero sin definición |
| `vehiculos` | TASKS.md | Sesión 1.4, línea 28 | "Tablas PESV: vehiculos, conductores, rutas, controles" | Nombre de tabla listado pero sin definición |
| `conductores` | TASKS.md | Sesión 1.4, línea 28 | "Tablas PESV: vehiculos, conductores, rutas, controles" | Nombre de tabla listado pero sin definición |
| `rutas` | TASKS.md | Sesión 1.4, línea 28 | "Tablas PESV: vehiculos, conductores, rutas, controles" | Nombre de tabla listado pero sin definición |
| `controles` | TASKS.md | Sesión 1.4, línea 28 | "Tablas PESV: vehiculos, conductores, rutas, controles" | Nombre de tabla listado pero sin definición |

### 3.6 Entidades descartadas

| Entidad | Razón del descarte |
|---|---|
| "Indicadores" (como entidad) | El Examen.md menciona "Indicadores" en §5 Alcance como función del sistema, pero no como tabla. Los indicadores se calculan via consultas, vistas y funciones. No es una entidad de almacenamiento. |
| "Vistas materializadas" (como entidad) | Son objetos de base de datos, no entidades de negocio. |

---

## 4. Trazabilidad individual

### Organización (`tenants`)

```
Entidad: tenants
Certeza: EXPLÍCITA
Fuente: Examen.md
Sección/ejercicio: Consultas 1.1, 1.2, 1.5, 1.10, 1.11, 1.12; Procedimientos 1, 3, 9, 14; Triggers 1, 8, 12, 13
Evidencia literal: "tabla `tenants`" (línea 110), "organizaciones registradas en la tabla `tenants`"
Justificación: Entidad central del modelo multi-tenant. Toda la información se organiza por organización.
```

### Persona (`persons`)

```
Entidad: persons
Certeza: EXPLÍCITA
Fuente: Examen.md
Sección/ejercicio: Consultas 1.3, 1.4, 1.10, 2.1, 2.2, 2.5, 2.16, 3.17, 3.18; Procedimientos 2, 7, 8; Triggers 2, 3, 6
Evidencia literal: "tabla `persons`" (línea 112), "personas registradas en la tabla `persons`"
Justificación: Gestión de trabajadores asociados a cada organización.
```

### Cargo (`positions`)

```
Entidad: positions
Certeza: EXPLÍCITA
Fuente: Examen.md
Sección/ejercicio: Consultas 1.9, 2.2, 2.20
Evidencia literal: "tabla `positions`" (línea 118), "cargos registrados en la tabla `positions`"
Justificación: Definición de cargos dentro de las organizaciones.
```

### Tamaño empresa (`tenant_sizes`)

```
Entidad: tenant_sizes
Certeza: EXPLÍCITA
Fuente: Examen.md
Sección/ejercicio: Consultas 1.13, 2.3
Evidencia literal: "tabla `tenant_sizes`" (línea 122), "diferentes tamaños de empresa almacenados en la tabla `tenant_sizes`"
Justificación: Clasificación de organizaciones por tamaño.
```

### Tipo sistema SST (`type_system_sst`)

```
Entidad: type_system_sst
Certeza: EXPLÍCITA
Fuente: Examen.md
Sección/ejercicio: Consultas 1.14, 2.9, 2.10; Trigger 9
Evidencia literal: "tabla `type_system_sst`" (línea 123), "diferentes tipos de sistemas SST registrados en la tabla `type_system_sst`"
Justificación: Catálogo de tipos de sistemas SST que cada organización puede habilitar.
```

### País (`countries`)

```
Entidad: countries
Certeza: EXPLÍCITA
Fuente: Examen.md
Sección/ejercicio: Consultas 1.6, 2.4
Evidencia literal: "tabla `countries`" (línea 115), "todos los países almacenados en la tabla `countries`"
Justificación: Nivel más alto de la jerarquía geográfica.
```

### Bloqueo edición (`editing_locks`)

```
Entidad: editing_locks
Certeza: EXPLÍCITA
Fuente: Examen.md
Sección/ejercicio: §5 Alcance, Trigger 15
Evidencia literal: "bloqueos de edición vencidos almacenados en `editing_locks`" (línea 257)
Justificación: Control de concurrencia para edición simultánea de recursos.
```

### Módulo

```
Entidad: módulo (nombre de tabla no especificado)
Certeza: INFERIDA
Fuente: Examen.md
Sección/ejercicio: Consultas 1.15, 2.7, 2.8, 2.10, 2.17, 3.3, 3.19; Procedimientos 4, 9, 10; Triggers 4, 10; Función 3, 6
Evidencia literal: "módulos registrados en el sistema mostrando su título, descripción y orden de presentación" (línea 124)
Justificación: El Examen.md requiere almacenar módulos con título, descripción y orden. Las consultas los referencian constantemente.
```

### Departamento/Región

```
Entidad: departamento/region (nombre de tabla no especificado)
Certeza: INFERIDA
Fuente: Examen.md
Sección/ejercicio: Consultas 1.7, 2.4
Evidencia literal: "departamentos o regiones pertenecientes a un país determinado" (línea 116)
Justificación: Jerarquía geográfica intermedia entre país y municipio.
```

### Municipio/Ciudad

```
Entidad: municipio/city (nombre de tabla no especificado)
Certeza: INFERIDA
Fuente: Examen.md
Sección/ejercicio: Consultas 1.8, 2.4, 2.19, 3.16
Evidencia literal: "municipios o ciudades correspondientes a un departamento o región específica" (línea 117)
Justificación: Nivel más bajo de la jerarquía geográfica. Las organizaciones se ubican en municipios.
```

### Plantilla

```
Entidad: plantilla (nombre de tabla no especificado)
Certeza: INFERIDA
Fuente: Examen.md
Sección/ejercicio: Consultas 2.13, 2.14, 2.15, 2.18, 3.4-3.9, 3.20, 3.21; Procedimientos 6, 11, 15; Triggers 5, 7, 14; Funciones 5, 8
Evidencia literal: "plantillas asignadas a cada organización mediante la tabla `tenanttemplates`" (línea 144)
Justificación: Las plantillas son el eje central del sistema documental. Cada plantilla se asocia a organización, sistema SST y etapa PHVA.
```

### Etapa PHVA

```
Entidad: etapa PHVA (nombre de tabla no especificado)
Certeza: INFERIDA
Fuente: Examen.md
Sección/ejercicio: §2, §5; consultas 2.18, 3.5-3.9, 3.20; consulta 4.4
Evidencia literal: "etapas del ciclo PHVA" (línea 33), "Planear, Hacer, Verificar y Actuar" (línea 93)
Justificación: Las 4 etapas PHVA son un eje transversal. Se requiere una tabla catálogo con los 4 registros fijos.
```

### Formato

```
Entidad: formato (nombre de tabla no especificado; formato SST = `formats_sst`)
Certeza: INFERIDA
Fuente: Examen.md
Sección/ejercicio: Consultas 2.11, 2.12; Procedimiento 6
Evidencia literal: "formatos registrados en `formats_sst`, mostrando el módulo al cual pertenece cada formato" (línea 142)
Justificación: Los formatos se asocian a módulos. El Examen.md los referencia en `formats_sst`.
```

### Documento

```
Entidad: documento (nombre de tabla no especificado)
Certeza: INFERIDA
Fuente: Examen.md
Sección/ejercicio: Consultas 3.10, 3.15, 3.22, 3.23; Procedimientos 12, 13; Función 2; Vistas materializadas
Evidencia literal: "documentos finalizados frente al total de documentos" (línea 168), "total de documentos, documentos finalizados, documentos en borrador, documentos no iniciados, documentos pendientes" (línea 181)
Justificación: El sistema calcula porcentajes de cumplimiento basados en documentos. Los estados (finalizado, borrador, no iniciado, pendiente) implican una entidad de almacenamiento.
```

### Evaluación

```
Entidad: evaluación (nombre de tabla no especificado)
Certeza: INFERIDA
Fuente: Examen.md
Sección/ejercicio: §2 (línea 36), §5 (línea 96)
Evidencia literal: "evaluaciones" (línea 36), "Evaluaciones — Registrar instrumentos o plantillas de evaluación" (línea 96)
Justificación: El Examen.md la lista como componente del sistema en §2 y §5. Sin embargo, NO aparece en ninguna consulta, procedimiento, función o trigger.
```

---

## 5. Relaciones

### 5.1 Relaciones documentadas

| Entidad A | Entidad B | Cardinalidad | Opcionalidad | Tipo | Evidencia/justificación |
|---|---|---|---|---|---|
| `tenants` | `persons` | 1:N | Obligatoria (persona debe pertenecer a un tenant) | FK `tenant_id` en `persons` | Consulta 1.10: "personas que pertenezcan a una organización determinada mediante su identificador `tenant_id`" |
| `tenants` | `positions` (indirecta vía persons) | 1:N | Indirecta | Relación transitiva: tenants → persons → positions | Consulta 2.20: "cargos existentes en cada organización" — la relación se resuelve a través de `persons.position_id`, no mediante FK directa `tenants` → `positions` |
| `tenants` | `tenant_sizes` | N:1 | Obligatoria | FK en `tenants` hacia `tenant_sizes` | Consulta 2.3: "organización junto con el tamaño de empresa que tiene asignado" |
| `tenants` → municipio | Municipio | N:1 | Obligatoria | FK en `tenants` hacia municipio | Consultas 2.4, 2.19: "ciudad, departamento o región y país" |
| `tenants` | `tenant_modules` | 1:N | Obligatoria | FK `tenant_id` en `tenant_modules` | Consultas 2.7, 2.8: "módulos habilitados para cada organización" |
| `modules` | `tenant_modules` | 1:N | Obligatoria | FK hacia `modules` | Consulta 2.17: "módulos que todavía no hayan sido asignados" |
| `tenants` | `tenantsystems` | 1:N | Obligatoria | FK `tenant_id` en `tenantsystems` | Consulta 2.9: "sistemas SST habilitados para cada organización" |
| `type_system_sst` | `tenantsystems` | 1:N | Obligatoria | FK hacia `type_system_sst` | Consulta 2.9: "utilizando las tablas `tenantsystems` y `type_system_sst`" |
| `tenants` | `tenanttemplates` | 1:N | Obligatoria | FK `tenant_id` en `tenanttemplates` | Consultas 2.13, 2.14, 2.15 |
| Plantilla | `tenanttemplates` | 1:N | Obligatoria | FK en `tenanttemplates` | Consulta 2.14: "plantilla asignada indicando la organización, el sistema SST y la etapa PHVA" |
| `type_system_sst` | `modules` | 1:N | Obligatoria | FK en `modules` hacia `type_system_sst` | Consulta 2.10: "módulos existentes junto con el sistema SST al cual pertenecen" |
| `modules` | Formato (`formats_sst`) | 1:N | Obligatoria | FK en `formats_sst` hacia `modules` | Consultas 2.11, 2.12: "formatos registrados en `formats_sst`, mostrando el módulo" |
| País | Departamento | 1:N | Obligatoria | FK en departamento hacia `countries` | Consulta 1.7: "departamentos o regiones pertenecientes a un país" |
| Departamento | Municipio | 1:N | Obligatoria | FK en municipio hacia departamento | Consulta 1.8: "municipios o ciudades correspondientes a un departamento" |
| `tenants` | `editing_locks` | 1:N | Obligatoria | FK en `editing_locks` hacia `tenants` | §5, Trigger 15: "bloqueos de edición vencidos" |
| `tenants` | Auditoría (tabla no definida) | 1:N | Obligatoria | Trigger 12 | "registre en una tabla de auditoría cualquier modificación" |

### 5.2 Relaciones N:M resueltas por tablas puente

| Relación N:M | Tabla puente | Entidades | Fuente |
|---|---|---|---|
| tenants ↔ modules | `tenant_modules` | tenants, modules | Examen.md — consulta 2.7 |
| tenants ↔ type_system_sst | `tenantsystems` | tenants, type_system_sst | Examen.md — consulta 2.9 |
| tenants ↔ plantilla (+ sistema SST, etapa PHVA, formato) | `tenanttemplates` | tenants, plantilla, type_system_sst, etapa PHVA, formato | Examen.md — consultas 2.13, 2.14 |

### 5.3 Relaciones con cardinalidad NO determinada

| Relación | Cardinidalidad declarada | Incertidumbre |
|---|---|---|
| persons ↔ positions | N:1 (una persona tiene un cargo) | Podría ser N:M si una persona tiene múltiples cargos. El Examen.md no lo especifica. Trigger 6 dice "asociada a un cargo" (singular). |
| persons ↔ tenants | N:1 (una persona pertenece a un tenant) | Podría ser N:M si una persona trabaja en múltiples organizaciones. Procedimiento 8 sugiere "trasladar" (mover, no copiar). |

---

## 6. Tablas puente detalladas

### `tenant_modules`

```
Tabla puente: tenant_modules
Relación que representa: tenants N:M modules
Entidad A: tenants
Entidad B: modules
Cardinalidad: N:M resuelta
Por qué es necesaria: Una organización tiene muchos módulos habilitados; un módulo puede estar habilitado en múltiples organizaciones. El Examen.md la referencia explícitamente.
Fuente: Examen.md — consultas 2.7 ("mediante la relación existente en `tenant_modules`"), 2.8, 2.17; Procedimientos 4, 9, 10; Triggers 4, 10
```

### `tenantsystems`

```
Tabla puente: tenantsystems
Relación que representa: tenants N:M type_system_sst
Entidad A: tenants
Entidad B: type_system_sst
Cardinalidad: N:M resuelta
Por qué es necesaria: Una organización habilita múltiples sistemas SST; un sistema SST puede estar habilitado en múltiples organizaciones. El Examen.md la referencia explícitamente.
Fuente: Examen.md — consulta 2.9 ("utilizando las tablas `tenantsystems` y `type_system_sst`"), 2.10; Procedimiento 5; Trigger 9
```

### `tenanttemplates`

```
Tabla puente: tenanttemplates
Relación que representa: tenants N:M plantilla (+ atributos: sistema SST, etapa PHVA, formato)
Entidad A: tenants
Entidad B: plantilla
Atributos de la relación: sistema SST, etapa PHVA, formato
Cardinalidad: N:M resuelta con atributos
Por qué es necesaria: Una organización tiene muchas plantillas; una plantilla puede estar asignada a múltiples organizaciones (con diferente configuración). El Examen.md la referencia explícitamente.
Fuente: Examen.md — consultas 2.13 ("mediante la tabla `tenanttemplates`"), 2.14, 2.15; Procedimientos 6, 11, 15; Triggers 5, 7, 14
```

---

## 7. Multi-tenancy — Análisis conceptual

### 7.1 Hipótesis de trabajo

```
shared database + shared schema + tenant_id
```

> NO es decisión definitiva. Solo hipótesis para análisis.

### 7.2 Entidades que necesitarían `tenant_id`

| Entidad | ¿Pertenece directamente a un tenant? | Justificación |
|---|---|---|
| `persons` | SÍ — FK `tenant_id` | Consulta 1.10: "personas que pertenezcan a una organización determinada mediante su identificador `tenant_id`" |
| `positions` | NO directamente | Los cargos son por organización, pero el Examen.md no especifica si `positions` es global o por tenant. Consulta 2.20 muestra "cargos existentes en cada organización" lo que sugiere que `positions` podría ser global y la relación sea via `persons`. |
| `tenant_modules` | SÍ — tiene `tenant_id` | Consultas 2.7, 2.8 |
| `tenantsystems` | SÍ — tiene `tenant_id` | Consulta 2.9 |
| `tenanttemplates` | SÍ — tiene `tenant_id` | Consultas 2.13, 2.14, 2.15 |
| `editing_locks` | SÍ — FK `tenant_id` | §5, Trigger 15 |
| `audit_log` (no definida) | SÍ — implícito | Trigger 12 |

### 7.3 Entidades que podrían ser GLOBALES

| Entidad | ¿Por qué podría ser global? | Incertidumbre |
|---|---|---|
| `countries` | Catálogo de países compartido | Alta certeza |
| Departamentos | Catálogo geográfico compartido | Alta certeza |
| Municipios | Catálogo geográfico compartido | Alta certeza |
| `tenant_sizes` | Catálogo de tamaños compartido | Alta certeza |
| `type_system_sst` | Catálogo de tipos de sistemas SST compartido | Alta certeza |
| Etapas PHVA | Catálogo fijo (4 registros: P, H, V, A) | Alta certeza |
| `modules` | Catálogo de módulos compartido | Alta certeza |
| Formatos | Catálogo de formatos (¿asociados a módulos globales?) | Media certeza |

### 7.4 Puntos pendientes para Sesión 1.3-B

- Confirmar si `positions` es global o por tenant
- Confirmar si los formatos son globales o por tenant
- Definir si `persons` puede pertenecer a múltiples tenants
- Definir mecanismo exacto de aislamiento (RLS, esquemas, etc.)

---

## 8. Normalización — Detección preliminar

### 8.1 Riesgos identificados

| Riesgo | Entidad | Descripción | Nivel |
|---|---|---|---|
| Dependencia transitive | `persons` → `tenants` → `municipio` | Si `persons` almacena la ubicación de la organización, podría haber redundancia. Solución: la ubicación es de `tenants`, no de `persons`. | Bajo |
| Grupo repetitivo | `tenanttemplates` | Si una plantilla tiene múltiples formatos, podría haber un grupo repetitivo. El Examen.md no especifica si es 1:1 o 1:N plantilla-formato. | Medio |
| Mezcla de conceptos | `tenanttemplates` | Esta tabla combina la relación N:M tenant-plantilla con los atributos de configuración (sistema SST, etapa PHVA, formato). Podría normalizarse más. | Bajo |

### 8.2 Normalización confirmada

- Las tablas puente `tenant_modules`, `tenantsystems`, `tenanttemplates` resuelven correctamente relaciones N:M
- Los catálogos (`countries`, `tenant_sizes`, `type_system_sst`, etapas PHVA) están separados de las entidades de negocio
- La jerarquía geográfica (país → departamento → municipio) está normalizada

---

## 9. Matriz de cobertura

### 9.1 Consultas (68 en Examen.md)

| Tabla/entidad requerida | Consultas que la utilizan | ¿Tiene representación conceptual? |
|---|---|---|
| `tenants` | 1.1, 1.2, 1.5, 1.10, 1.11, 1.12, 2.1-2.20, 3.1-3.25 | SÍ |
| `persons` | 1.3, 1.4, 1.10, 2.1, 2.2, 2.5, 2.16, 3.1, 3.2, 3.17, 3.18, 3.19 | SÍ |
| `positions` | 1.9, 2.2, 2.20, 3.17 | SÍ |
| `countries` | 1.6, 2.4 | SÍ |
| Departamento | 1.7, 2.4 | SÍ (inferida) |
| Municipio | 1.8, 2.4, 2.19, 3.16 | SÍ (inferida) |
| `tenant_sizes` | 1.13, 2.3, 3.16 | SÍ |
| `type_system_sst` | 1.14, 2.9, 2.10 | SÍ |
| Módulos | 1.15, 2.7, 2.8, 2.10, 2.17, 3.3, 3.19 | SÍ (inferida) |
| `tenant_modules` | 2.7, 2.8, 2.17, 3.3, 3.4, 3.19 | SÍ (estructural) |
| `tenantsystems` | 2.9, 2.10, 3.3 | SÍ (estructural) |
| Formatos (`formats_sst`) | 2.11, 2.12 | SÍ (inferida) |
| Plantillas | 2.13, 2.14, 2.15, 2.18, 3.4-3.9, 3.20, 3.21 | SÍ (inferida) |
| `tenanttemplates` | 2.13, 2.14, 2.15, 3.4, 3.19 | SÍ (estructural) |
| Etapa PHVA | 2.18, 3.5-3.9, 3.20 | SÍ (inferida) |
| Documentos | 3.10, 3.15, 3.22, 3.23 | SÍ (inferida) |
| `vm_template_pesv_docs_summary` | 3.22 | SÍ (vista materializada) |
| `vm_template_sst_docs_summary` | 3.22 | SÍ (vista materializada) |

### 9.2 Procedimientos (15 en Examen.md)

| Procedimiento | Entidades requeridas | ¿Tiene representación? |
|---|---|---|
| P.1 | `tenants` | SÍ |
| P.2 | `persons`, `tenants`, `positions` | SÍ |
| P.3 | `tenants` | SÍ |
| P.4 | `tenant_modules` | SÍ |
| P.5 | `tenantsystems` | SÍ |
| P.6 | `tenanttemplates` | SÍ |
| P.7 | `persons`, `positions` | SÍ |
| P.8 | `persons`, `tenants` | SÍ |
| P.9 | `tenants`, `tenant_modules` | SÍ |
| P.10 | `tenant_modules` | SÍ |
| P.11 | `tenanttemplates` | SÍ |
| P.12 | Documentos (entidad inferida) | SÍ |
| P.13 | Documentos, etapa PHVA | SÍ |
| P.14 | `tenants` | SÍ |
| P.15 | `tenanttemplates` | SÍ |

### 9.3 Funciones (8 en Examen.md)

| Función | Entidades requeridas | ¿Tiene representación? |
|---|---|---|
| F.1 | `persons`, `tenants` | SÍ |
| F.2 | Documentos, `tenants` | SÍ |
| F.3 | `tenant_modules` | SÍ |
| F.4 | `persons` | SÍ |
| F.5 | `tenanttemplates`, etapa PHVA | SÍ |
| F.6 | `tenant_modules`, módulos | SÍ |
| F.7 | `persons`, `positions`, `tenants` | SÍ |
| F.8 | Cálculo de cumplimiento | SÍ |

### 9.4 Triggers (15 en Examen.md)

| Trigger | Entidades requeridas | ¿Tiene representación? |
|---|---|---|
| T.1 | `tenants` | SÍ |
| T.2 | `persons` | SÍ |
| T.3 | `persons`, `tenants` | SÍ |
| T.4 | `tenant_modules` | SÍ |
| T.5 | `tenanttemplates`, `tenants` | SÍ |
| T.6 | `persons`, `positions`, `tenants` | SÍ |
| T.7 | `tenanttemplates` | SÍ |
| T.8 | `tenants`, `persons` | SÍ |
| T.9 | `type_system_sst`, `tenantsystems` | SÍ |
| T.10 | módulos, `tenant_modules` | SÍ |
| T.11 | Cálculo de cumplimiento | SÍ |
| T.12 | `tenants`, tabla auditoría | SÍ (auditoría ambigua) |
| T.13 | `tenants`, tabla auditoría | SÍ (auditoría ambigua) |
| T.14 | `tenanttemplates` | SÍ |
| T.15 | `editing_locks` | SÍ |

### 9.5 Vistas

| Vista | Entidades requeridas | ¿Tiene representación? |
|---|---|---|
| V.1 `vw_tenant_persons` | `tenants`, `persons`, `positions` | SÍ |
| V.2 Info geográfica | `tenants`, municipio, departamento, `countries` | SÍ |
| V.3 Módulos por org | `tenant_modules`, módulos, `tenantsystems`, `type_system_sst` | SÍ |
| V.4 Plantillas por PHVA | `tenanttemplates`, etapa PHVA | SÍ |
| V.5 Personas por cargo | `persons`, `positions`, `tenants` | SÍ |
| MV.1 `vm_template_pesv_docs_summary` | Documentos | SÍ |
| MV.2 `vm_template_sst_docs_summary` | Documentos | SÍ |
| MV.3 Cumplimiento | Documentos | SÍ |

### 9.6 Huecos detectados

Ninguna entidad requerida por las consultas, procedimientos, funciones, triggers o vistas carece de representación conceptual.

**Las entidades de TASKS.md (users, roles, riesgos, incidentes, capacitaciones, inspecciones, vehiculos, conductores, rutas, controles) NO son requeridas por ninguna consulta, procedimiento, función, trigger o vista del Examen.md.**

---

## 10. Comparación con docs/requerimientos.md

| Entidad | En requerimientos.md | En inventario conceptual | Clasificación |
|---|---|---|---|
| `tenants` | SÍ (§4.1) | EXPLÍCITA | CORRECTO |
| `persons` | SÍ (§4.1) | EXPLÍCITA | CORRECTO |
| `positions` | SÍ (§4.1) | EXPLÍCITA | CORRECTO |
| `tenant_sizes` | SÍ (§4.1) | EXPLÍCITA | CORRECTO |
| `type_system_sst` | SÍ (§4.1) | EXPLÍCITA | CORRECTO |
| `countries` | SÍ (§4.1) | EXPLÍCITA | CORRECTO |
| `editing_locks` | SÍ (§4.1) | EXPLÍCITA | CORRECTO |
| Módulos | SÍ (§4.1 como `modules`) | INFERIDA | CORRECTO |
| Departamento | SÍ (§4.1) | INFERIDA | CORRECTO |
| Municipio | SÍ (§4.1) | INFERIDA | CORRECTO |
| Plantilla | SÍ (§4.1) | INFERIDA | CORRECTO |
| Etapa PHVA | SÍ (§4.1) | INFERIDA | CORRECTO |
| Formato | SÍ (§4.1 como `formats_sst`) | INFERIDA | CORRECTO |
| Documento | SÍ (§4.1) | INFERIDA | CORRECTO |
| Evaluación | SÍ (§4.1) | INFERIDA | CORRECTO |
| `tenant_modules` | SÍ (§4.1) | ESTRUCTURAL | CORRECTO |
| `tenantsystems` | SÍ (§4.1) | ESTRUCTURAL | CORRECTO |
| `tenanttemplates` | SÍ (§4.1) | ESTRUCTURAL | CORRECTO |
| Tabla auditoría | SÍ (§13.2) | AMBIGUA | CORRECTO |
| `users` | SÍ (§4.2, §22 DP-03) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |
| `roles` | SÍ (§4.2, §22 DP-03) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |
| `riesgos` | SÍ (§4.2, §22 DP-02) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |
| `incidentes` | SÍ (§4.2, §22 DP-02) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |
| `capacitaciones` | SÍ (§4.2, §22 DP-02) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |
| `inspecciones` | SÍ (§4.2, §22 DP-02) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |
| `vehiculos` | SÍ (§4.2, §22 DP-02) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |
| `conductores` | SÍ (§4.2, §22 DP-02) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |
| `rutas` | SÍ (§4.2, §22 DP-02) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |
| `controles` | SÍ (§4.2, §22 DP-02) | FUERA DE ALCANCE | SOBRA EN REQUERIMIENTOS — pendiente de corrección |

---

## 11. Decisiones pendientes

| ID | Problema | Fuente | Qué está definido | Qué no está definido | Impacto | Decisión pendiente |
|---|---|---|---|---|---|---|
| M-01 | Discrepancia 68 vs 78 consultas | Instrucciones sesión vs Examen.md | 68 consultas en Examen.md | Por qué la instrucción dice 78 | Podría faltar una sección | Verificar número correcto |
| M-02 | Entidades SST/PESV operativas sin definición | TASKS.md vs Examen.md | Modelo documental en Examen.md | Atributos, relaciones de riesgos, incidentes, etc. | Alcance del proyecto | Definir si están en alcance y proporcionar especificación |
| M-03 | users/roles sin definición | TASKS.md vs Examen.md | `persons` como entidad de personas | Sistema de autenticación, roles, permisos | Seguridad | Definir si se requiere |
| M-04 | Nombres de tablas geográficas | Examen.md | `countries` para países | Nombres de departamento y municipio | Diseño esquema | Definir nombres |
| M-05 | Tabla de auditoría sin estructura | Examen.md — Trigger 12 | Se debe auditar `tenants` | Nombre, columnas, alcance | Diseño auditoría | Definir estructura |
| M-06 | Mecanismo de concurrencia | Examen.md — §5, Trigger 15 | `editing_locks` existe | Estructura, duración, nivel de bloqueo | Concurrencia | Definir mecanismo |
| M-07 | Nombre tabla plantillas | Examen.md | "plantillas" como concepto | Nombre físico exacto | Diseño esquema | Definir nombre |
| M-08 | Tabla documentos no definida | Examen.md | Estados de documento | Nombre, atributos, generación | Modelo central | Definir entidad |
| M-09 | `positions` ¿global o por tenant? | Examen.md | Consultas muestran cargos por organización | Si `positions` tiene `tenant_id` | Multi-tenancy | Decidir |
| M-10 | `persons` ¿puede pertenecer a múltiples tenants? | Examen.md | Procedimiento 8 "trasladar" | Si es moved o copied | Multi-tenancy | Decidir |
| M-11 | Evaluación: ¿tiene sentido sin uso en consultas/triggers? | Examen.md §2, §5 | Lista como componente | No aparece en ninguna operación SQL | Alcance | Decidir si se implementa |

---

## 12. Resumen ejecutivo

### Lo que quedó demostrado

- 17 entidades con respaldo en Examen.md (7 explícitas, 8 inferidas, 3 estructurales)
- 3 tablas puente confirmadas por referencias directas del Examen.md
- 16 relaciones entre entidades documentadas con evidencia
- Cobertura verificada: todas las consultas, procedimientos, funciones, triggers y vistas del Examen.md fueron contrastadas con el modelo conceptual

### Lo que quedó inferido

- Nombres de tablas para módulos, departamentos, municipios, plantillas, etapas PHVA, formatos, documentos, evaluaciones
- La entidad "documento" se infiere de los cálculos de cumplimiento y estados mencionados
- La entidad "evaluación" se infiere de §2 y §5 pero no tiene uso en operaciones SQL

### Lo que quedó ambiguo

- Tabla de auditoría (nombre, estructura, alcance)
- Mecanismo de concurrencia (estructura de `editing_locks`)
- Si `positions` es global o por tenant
- Si `persons` puede pertenecer a múltiples tenants

### Qué debe decidir el usuario

- Si las entidades de TASKS.md (users, roles, riesgos, incidentes, capacitaciones, inspecciones, vehiculos, conductores, rutas, controles) están dentro del alcance
- Si `users`/`roles` son necesarios o si `persons` es suficiente
- Si la entidad "evaluación" se implementa o se descarta
- Nombres físicos de las tablas inferidas
- Estructura de la tabla de auditoría
- Mecanismo de concurrencia

### Qué NO debe implementarse todavía

- DDL / CREATE TABLE
- Índices físicos
- Triggers
- Funciones
- Procedimientos
- Vistas
- Diagramas definitivos
- Migraciones
