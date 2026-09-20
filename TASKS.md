# TASKS — Base de Datos SST/PESV Multi-tenant (PostgreSQL)

**Proyecto:** Diseño e implementación de una base de datos multi-tenant para gestión de SST y PESV
**Modalidad:** Individual
**Tiempo disponible:** 3 días × 4 horas = 12 horas
**Entorno:** Docker + Dev Container (VS Code) + PostgreSQL 16 + pgAdmin
**Repositorio:** GitHub

> ⚠️ **Nota de alcance:** el examen pide 68 consultas SQL (15 básicas + 20 intermedias + 25 avanzadas + 8 de vistas, según el conteo confirmado en `docs/requerimientos.md`), 15 procedimientos, 8 funciones, 15 triggers, vistas y vistas materializadas, además de todo el modelado y la documentación. En 12 horas esto exige trabajar por lotes (generar varios objetos SQL de una sola vez, revisar y probar) en lugar de uno por uno. El orden de este documento está pensado para que, si el tiempo aprieta, lo ya construido sea siempre una base funcional y evaluable (nunca quedamos a medias en algo crítico).

> 🔁 **Nota de restauración (ver `docs/incidencias.md`):** este archivo reemplaza una versión de `TASKS.md` generada automáticamente por el agente de codificación durante la Sesión 1.1, que introdujo entidades (`users`, `roles`, `riesgos`, `incidentes`, `capacitaciones`, `inspecciones`, `vehiculos`, `conductores`, `rutas`, `controles`) sin respaldo en `Examen.md`. Esa versión fue descartada. El alcance vigente es únicamente el que aparece en la sección "Entidades de partida" más abajo, confirmado contra `Examen.md`.

---

## Leyenda de estado

- `[ ]` Pendiente `[~]` En progreso `[x]` Hecho `[!]` Bloqueado / requiere decisión

---

## DÍA 1 (4h) — Análisis, modelado y entorno

### Sesión 1.1 — Entorno y repositorio (≈45 min) ✅ COMPLETADA

- [x] Repositorio creado en GitHub y clonado localmente — nombre real: `sst-pesv`
- [x] Estructura de carpetas base creada (`.devcontainer/`, `sql/01_schema..07_triggers/`, `docs/`, `init/`, con `.gitkeep` en las vacías)
- [x] `docker-compose.yml` adaptado del entorno del profesor: nombres propios del proyecto (`sst_pesv_postgres`, `sst_pesv_pgadmin`, red `sst_pesv_network`) para evitar choque con el entorno del profesor en su equipo
- [x] PostgreSQL 16 (imagen `postgres:16`) + pgAdmin 4 fijado en versión `8.13` (no `latest`, por reproducibilidad)
- [x] `.env.example` con placeholders, `.env` real excluido de git
- [x] `.gitignore` profesional (`.env`, dumps, backups, cachés de dev container, override de compose, etc.)
- [x] `.devcontainer/devcontainer.json` + `Dockerfile` (cliente `psql`, git, herramientas — sin duplicar el servidor PostgreSQL, que vive solo en `docker-compose`)
- [x] `docker compose config` validado sin warnings (se retiró el atributo `version:` obsoleto)
- [x] Verificado con Docker real: ambos servicios `Up (healthy)`, conexión `psql` exitosa vía `docker exec`, pgAdmin accesible en `localhost:8081` (HTTP 302 a login confirmado con `curl`)
- [x] `.env` confirmado como ignorado (`git ls-files` vacío + `git check-ignore -v .env` apuntando a la regla correcta)
- [x] Commit `d3c0501` — "chore: entorno docker + devcontainer base"
- [x] Commit `4219d9b` — "chore: limpieza menor post-verificación entorno" (retiro de `version:`)
- [x] Ambos commits subidos a `origin/main`

> **Pendiente detectado durante la Sesión 1.2 (ver `docs/incidencias.md`):** el `TASKS.md` que quedó versionado en el commit `d3c0501` no era este documento, sino uno generado por el agente sin partir del original. Se restaura en este archivo.

### Sesión 1.2 — Análisis de requerimientos (≈45 min) ✅ COMPLETADA (con correcciones pendientes)

- [x] `Examen.md` releído y entidades extraídas → `docs/requerimientos.md`
- [x] Reglas de negocio extraídas (triggers 1-15, procedimientos 1-15) → `docs/requerimientos.md` §7
- [x] Inventario completo de las 68 consultas, 15 procedimientos, 8 funciones, 15 triggers y 9 vistas, cada una con tabla/técnica/fuente citada
- [!] **Corrección pendiente en `docs/requerimientos.md`:** las secciones DP-02 y DP-09 citan "TASKS.md — Sesión 1.4" como fuente de `users`, `roles`, `riesgos`, `incidentes`, `capacitaciones`, `inspecciones`, `vehiculos`, `conductores`, `rutas`, `controles`. Esa cita corresponde al `TASKS.md` fabricado por el agente (ver nota de restauración arriba), no a un documento válido. Debe corregirse antes de la Sesión 1.3: esas entidades no tienen evidencia en ninguna fuente real del proyecto y quedan **fuera de alcance** salvo decisión explícita de ampliar el proyecto.

**Entidades de partida identificadas en el enunciado (a validar y completar):**

| Entidad candidata | Fuente en el examen |
|---|---|
| `tenants` (organizaciones) | Consultas básicas 1, 2, 12 |
| `tenant_sizes` (tamaños de empresa) | Consulta básica 13 |
| `persons` (personas/trabajadores) | Consulta básica 3, 4 |
| `positions` (cargos) | Consulta básica 9 |
| `countries` (países) | Consulta básica 6 |
| Departamentos/regiones | Consulta básica 7 |
| Municipios/ciudades | Consulta básica 8 |
| `type_system_sst` (sistemas SST) | Consulta básica 14 |
| `tenantsystems` (sistemas habilitados por tenant) | Consulta intermedia 9 |
| Módulos + `tenant_modules` | Consulta básica 15, intermedia 7 |
| `formats_sst` (formatos) | Consulta intermedia 11 |
| Etapas PHVA | Consulta intermedia 18 |
| Plantillas + `tenanttemplates` | Consulta intermedia 13, 14 |
| Evaluaciones | Objetivo específico 6, alcance |
| Documentos (finalizados/borrador/no iniciado) | Consulta avanzada 23 |
| `editing_locks` (bloqueos de edición) | Trigger 15, alcance |
| `vm_template_pesv_docs_summary`, `vm_template_sst_docs_summary` | Consulta avanzada 22 |
| Auditoría (tabla de auditoría genérica) | Trigger 12, 13 |

### Sesión 1.3 — Modelado conceptual y lógico (≈90 min)

- [ ] Construir el **modelo conceptual** (entidades + relaciones, sin tipos de datos) en dbdiagram.io
- [ ] Definir cardinalidades de cada relación (1:1, 1:N, N:M) y las tablas puente necesarias (`tenant_modules`, `tenantsystems`, `tenanttemplates`, etc.)
- [ ] Resolver el diseño multi-tenant: decisión de **aislamiento lógico** vía `tenant_id` en cada tabla dependiente (enfoque *shared schema, shared database*) — documentar por qué (es el estándar para este alcance, frente a schema-per-tenant o database-per-tenant)
- [ ] Aplicar y **documentar normalización** (`docs/normalizacion.md`): justificar 1FN, 2FN, 3FN y FN de Boyce-Codd tabla por tabla, señalando qué dependencias parciales/transitivas se eliminaron
- [ ] Construir el **modelo lógico** (tipos de datos, PK, FK, nombres definitivos de columnas) en dbdiagram.io
- [ ] Exportar el DDL generado por dbdiagram.io como punto de partida (se ajustará a mano en Día 2)
- [ ] Guardar imagen/enlace del diagrama en `docs/`

### Sesión 1.4 — Modelo físico: decisiones técnicas (≈20 min)

- [ ] Definir convenciones de nombres (snake_case, singular/plural, sufijos `_id`, `_at`)
- [ ] Definir tipos de datos PostgreSQL por campo (ver `PostgreSQL.md`): `serial`/`bigserial` para PK, `varchar(n)` vs `text`, `numeric` para porcentajes, `timestamptz` para auditoría, `boolean` para flags de estado
- [ ] Definir estrategia de `CHECK` constraints (ej: estado de organización, rango 0-100 de cumplimiento, estado de documentos)
- [ ] Commit: "docs: modelo conceptual, lógico y decisiones de diseño"

**Entregable del Día 1:** entorno funcionando + repo con estructura + diagrama ER + documento de normalización y decisiones de diseño.

---

## DÍA 2 (4h) — Implementación física, datos de prueba y consultas SQL

### Sesión 2.1 — DDL (≈70 min)

- [ ] Script `sql/01_schema/001_create_tables.sql`: creación de todas las tablas con PK
- [ ] Script `sql/01_schema/002_foreign_keys.sql` (o FKs inline): todas las relaciones con `ON DELETE`/`ON UPDATE` explícitos y justificados
- [ ] Script `sql/01_schema/003_constraints.sql`: `UNIQUE`, `CHECK`, `NOT NULL` faltantes
- [ ] Script `sql/01_schema/004_indexes.sql`: índices iniciales sobre FKs y columnas de búsqueda frecuente (`tenant_id`, `email`, `status`)
- [ ] Ejecutar todo dentro del contenedor y verificar con `\d` y `\di`
- [ ] Commit: "feat: modelo físico completo (tablas, FKs, constraints, índices base)"

### Sesión 2.2 — Datos de prueba (≈40 min)

- [ ] Script `sql/02_seed/001_seed_data.sql`: datos realistas para **todas** las tablas (mínimo 4-5 organizaciones/tenants, con datos suficientes para que las consultas de agregación, HAVING, promedios y comparaciones tengan sentido — no sirven datos triviales de 1 fila)
- [ ] Verificar integridad referencial al insertar (orden correcto: catálogos → tenants → dependientes)
- [ ] Commit: "feat: datos de prueba (seed)"

### Sesión 2.3 — Consultas SQL básicas + intermedias (≈80 min)

- [ ] `sql/03_queries/basicas.sql` — las 15 consultas básicas, cada una numerada y con comentario del enunciado
- [ ] `sql/03_queries/intermedias.sql` — las 20 consultas intermedias
- [ ] Probar cada consulta contra los datos seed y ajustar donde el resultado no tenga sentido de negocio
- [ ] Commit: "feat: consultas SQL básicas e intermedias (35)"

### Sesión 2.4 — Avance de consultas avanzadas (≈30 min, lo que alcance)

- [ ] `sql/03_queries/avanzadas.sql` — comenzar por las que ya tienen soporte directo del modelo (CTE, window functions, subconsultas) sin depender de vistas materializadas aún

**Entregable del Día 2:** base de datos poblada y funcional + 35+ consultas verificadas.

---

## DÍA 3 (4h) — Vistas, programabilidad, integridad avanzada y cierre

### Sesión 3.1 — Vistas y vistas materializadas (≈50 min)

- [ ] `sql/04_views/vistas.sql`: `vw_tenant_persons` y las demás vistas normales pedidas (5 en total)
- [ ] `sql/04_views/vistas_materializadas.sql`: `vm_template_pesv_docs_summary`, `vm_template_sst_docs_summary` y la vista materializada de cumplimiento consolidado
- [ ] Índices sobre las vistas materializadas + prueba de `REFRESH MATERIALIZED VIEW`
- [ ] Terminar las consultas avanzadas que dependían de estas vistas (22 en adelante)
- [ ] Commit: "feat: vistas, vistas materializadas y consultas avanzadas completas"

### Sesión 3.2 — Funciones y procedimientos PL/pgSQL (≈90 min)

- [ ] `sql/05_functions/funciones.sql`: las 8 funciones (escalares + tabulares)
- [ ] `sql/06_procedures/procedimientos.sql`: los 15 procedimientos, con manejo de excepciones (`EXCEPTION`, `RAISE`) donde el enunciado lo pide explícitamente
- [ ] Probar cada uno con `CALL` / `SELECT` y casos borde (duplicados, inactivos, dependientes)
- [ ] Commit: "feat: funciones y procedimientos almacenados"

### Sesión 3.3 — Triggers, auditoría y concurrencia (≈50 min)

- [ ] `sql/07_triggers/triggers.sql`: los 15 triggers (updated_at, validaciones de negocio, prevención de eliminación, auditoría)
- [ ] Tabla de auditoría genérica + trigger que registra antes/después en cambios de estado
- [ ] Documentar en `docs/concurrencia.md` el mecanismo de bloqueo usado en `editing_locks` (uso de `SELECT ... FOR UPDATE` o expiración por tiempo) y probarlo con dos sesiones simultáneas
- [ ] Commit: "feat: triggers, auditoría y control de concurrencia"

### Sesión 3.4 — Documentación técnica y cierre (≈30 min)

- [ ] `docs/diccionario_datos.md`: tabla por tabla, columna, tipo, restricciones, descripción
- [ ] `README.md` final: descripción del proyecto, cómo levantar el entorno (`docker compose up`, dev container), estructura del repo, cómo ejecutar los scripts en orden
- [ ] Revisión general: ejecutar TODO el script desde cero en un contenedor limpio para verificar que no falla nada (simulacro de "el profesor lo clona y lo corre")
- [ ] Commit y push final: "docs: documentación técnica y README final"

**Entregable del Día 3:** proyecto completo, probado de punta a punta, documentado y publicado en GitHub.

---

## Estructura del repositorio (propuesta)

```
sst-pesv-postgres-db/
├── .devcontainer/
│   ├── devcontainer.json
│   └── Dockerfile
├── docker-compose.yml
├── .env.example
├── .gitignore
├── init/                     # scripts que se auto-ejecutan al primer arranque del contenedor
├── sql/
│   ├── 01_schema/            # DDL: tablas, FKs, constraints, índices
│   ├── 02_seed/              # datos de prueba
│   ├── 03_queries/           # básicas.sql, intermedias.sql, avanzadas.sql
│   ├── 04_views/             # vistas.sql, vistas_materializadas.sql
│   ├── 05_functions/
│   ├── 06_procedures/
│   └── 07_triggers/
├── docs/
│   ├── requerimientos.md
│   ├── normalizacion.md
│   ├── diccionario_datos.md
│   ├── concurrencia.md
│   └── modelo_er.png (o enlace a dbdiagram.io)
├── TASKS.md                  # este documento
└── README.md
```

---

## Pendientes / decisiones abiertas

- [!] Nombre y visibilidad definitiva del repositorio (público/privado)
- [!] Confirmar si el profesor evaluará clonando el repo en su equipo o si se hace demo en vivo desde tu portátil (afecta qué tan crítico es el "simulacro de contenedor limpio" del Día 3)