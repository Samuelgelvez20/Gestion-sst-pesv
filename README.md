# SST/PESV — Base de Datos Multi-tenant (PostgreSQL 16)

Base de datos relacional para gestión de **SST** (Salud y Seguridad en el Trabajo) y **PESV** (Plan Estratégico de Seguridad Vial) con arquitectura multi-tenant sobre PostgreSQL 16.

## Descripción

El sistema administra organizaciones (`tenants`), personas, cargos, módulos, sistemas SST, plantillas, formatos, etapas PHVA, evaluaciones, localización geográfica y control de concurrencia de edición. Incluye auditoría, validaciones, vistas materializadas de seguimiento y un conjunto de 60 consultas SQL de distintos niveles de complejidad.

## Alcance implementado

| Componente | Cantidad |
|---|---|
| Tablas | 19 |
| Claves foráneas (FK) | 23 |
| Restricciones UNIQUE | 8 |
| Restricciones CHECK | 4 |
| Índices explícitos (`004_indexes.sql`) | 28 |
| Índice corregido (`006_add_missing_index.sql`) | 1 |
| Funciones PL/pgSQL | 8 |
| Procedimientos almacenados | 15 |
| Triggers | 15 |
| Vistas | 6 |
| Vistas materializadas | 3 |
| Consultas SQL | 60 (15 básicas + 20 intermedias + 25 avanzadas) |

Detalle completo del modelo físico: [docs/diccionario_datos.md](docs/diccionario_datos.md)

## Requisitos

**Para ejecutar la base de datos:**

- Docker Engine 24.0+ y Docker Compose v2 (plugin `docker compose`)
- ~200 MB de disco para imágenes y volúmenes

**Herramientas opcionales para desarrollo:**

- VS Code con extensión [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- pgAdmin 4 (incluido en Docker Compose)
- Cliente `psql` local (PostgreSQL 16)

## Configuración

```bash
cp .env.example .env
```

Valores por defecto en `.env.example`:

| Variable | Valor por defecto |
|---|---|
| `POSTGRES_DB` | `sst_pesv` |
| `POSTGRES_USER` | `sst_pesv_user` |
| `POSTGRES_PASSWORD` | `change_me` |
| `POSTGRES_PORT` | `5433` |
| `PGADMIN_EMAIL` | `admin@example.com` |
| `PGADMIN_PASSWORD` | `change_me` |
| `PGADMIN_PORT` | `8081` |

> **No uses credenciales por defecto en entornos de producción.**

## Arranque

### 1. Levantar servicios

```bash
docker compose up -d
```

### 2. Verificar que PostgreSQL está listo

```bash
docker compose ps
```

El servicio `postgres` debe mostrar estado `Up (healthy)`.

### 3. Inicializar el esquema

Los scripts SQL **no se ejecutan automáticamente** al levantar el contenedor. Ejecuta en orden los archivos de esquema:

```bash
for f in \
  sql/01_schema/000_extensions.sql \
  sql/01_schema/001_create_tables.sql \
  sql/01_schema/002_foreign_keys.sql \
  sql/01_schema/003_constraints.sql \
  sql/01_schema/004_indexes.sql \
  sql/01_schema/005_alter_tenanttemplates.sql \
  sql/01_schema/006_add_missing_index.sql; do
  docker exec -i sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv < "$f"
done
```

> **Nota:** `init/00_init_schema.sql` contiene un script maestro que usa `\i` para incluir los archivos 000–004. Sin embargo, como los archivos SQL no están montados en el contenedor, `\i` no puede resolver las rutas al ejecutar con `docker exec`. Usa el bucle anterior para inicializar desde el host.

### 4. Cargar datos semilla

```bash
docker exec -i sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv < sql/02_seed/001_seed_data.sql
```

### 5. Crear vistas

```bash
docker exec -i sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv < sql/04_views/001_views.sql
docker exec -i sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv < sql/04_views/002_materialized_views.sql
```

### 6. Crear funciones, procedimientos y triggers

```bash
docker exec -i sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv < sql/05_functions/001_functions.sql
docker exec -i sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv < sql/06_procedures/001_procedures.sql
docker exec -i sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv < sql/07_triggers/001_triggers.sql
```

## Verificación de la instalación

Ejecuta esta consulta para confirmar que todo quedó correctamente inicializado:

```sql
SELECT 'tablas'      AS concepto, count(*) AS total FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'
UNION ALL SELECT 'FK',              count(*) FROM information_schema.table_constraints WHERE table_schema='public' AND constraint_type='FOREIGN KEY'
UNION ALL SELECT 'UNIQUE',          count(*) FROM information_schema.table_constraints WHERE table_schema='public' AND constraint_type='UNIQUE'
UNION ALL SELECT 'CHECK',           count(*) FROM pg_constraint WHERE connamespace = 'public'::regnamespace AND contype = 'c'
UNION ALL SELECT 'funciones',       count(*) FROM pg_proc WHERE pronamespace = 'public'::regnamespace AND prokind = 'f' AND proname LIKE 'fn_%' AND proname NOT LIKE 'fn_trg_%'
UNION ALL SELECT 'procedures',      count(*) FROM pg_proc WHERE pronamespace = 'public'::regnamespace AND prokind = 'p'
UNION ALL SELECT 'triggers',        count(*) FROM pg_trigger WHERE NOT tgisinternal
UNION ALL SELECT 'vistas',          count(*) FROM information_schema.views WHERE table_schema='public'
UNION ALL SELECT 'vistas_mat',      count(*) FROM pg_matviews WHERE schemaname='public'
UNION ALL SELECT 'ix_format_id',    CASE WHEN EXISTS(SELECT 1 FROM pg_indexes WHERE indexname='ix_tenanttemplates_format_id') THEN 1 ELSE 0 END
ORDER BY concepto;
```

Valores esperados:

| Concepto | Total |
|---|---|
| tablas | 19 |
| FK | 23 |
| UNIQUE | 8 |
| CHECK | 4 |
| funciones | 8 |
| procedures | 15 |
| triggers | 15 |
| vistas | 6 |
| vistas_mat | 3 |
| ix_format_id | 1 |

## Consultas SQL

Las 60 consultas del examen están distribuidas en tres archivos:

| Archivo | Nivel | Cantidad |
|---|---|---|
| `sql/03_queries/basicas.sql` | Básico (B01–B15) | 15 |
| `sql/03_queries/intermedias.sql` | Intermedio (I01–I20) | 20 |
| `sql/03_queries/avanzadas.sql` | Avanzado (C.3.1–C.3.25) | 25 |

> **Alcance total del examen (68 requisitos):** Las 60 consultas SQL anteriores más 8 tareas de diseño de vistas y vistas materializadas (Sección 4 del Examen.md: 5 vistas ordinarias + 3 vistas materializadas), implementadas en `sql/04_views/`.

Para ejecutar una consulta individual:

```bash
docker exec -i sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv < sql/03_queries/basicas.sql
```

O conectarte directamente:

```bash
docker exec -it sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv
```

Y ejecutar la consulta deseada desde la línea de comandos `psql`.

## Funciones, procedimientos y triggers

| Archivo | Contenido |
|---|---|
| `sql/05_functions/001_functions.sql` | 8 funciones PL/pgSQL (`fn_*`) |
| `sql/06_procedures/001_procedures.sql` | 15 procedimientos almacenados (`sp_*`) |
| `sql/07_triggers/001_triggers.sql` | 15 triggers y sus funciones asociadas (`fn_trg_*`) |

Para verificar que existen en PostgreSQL:

```sql
SELECT proname, prokind FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
  AND (proname LIKE 'fn_%' OR proname LIKE 'sp_%')
ORDER BY proname;
```

## Vistas

| Archivo | Contenido |
|---|---|
| `sql/04_views/001_views.sql` | 6 vistas: `vw_tenant_persons`, `vw_tenant_geography`, `vw_tenant_modules`, `vw_tenant_phva_templates`, `vw_tenant_persons_positions`, `vw_tenant_summary` |
| `sql/04_views/002_materialized_views.sql` | 3 vistas materializadas: `vm_compliance_summary`, `vm_template_sst_docs_summary`, `vm_template_pesv_docs_summary` |

Para consultar una vista:

```sql
SELECT * FROM vw_tenant_persons LIMIT 10;
```

Para refrescar una vista materializada:

```sql
REFRESH MATERIALIZED VIEW vm_compliance_summary;
```

## Credenciales y acceso

### PostgreSQL (psql)

```bash
docker exec -it sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv
```

### pgAdmin

Acceso web: `http://localhost:8081`

Credenciales: las definidas en `.env` (`PGADMIN_EMAIL` / `PGADMIN_PASSWORD`).

Para conectar desde pgAdmin a PostgreSQL:
- **Host:** `postgres` (nombre del servicio Docker)
- **Puerto:** `5432`
- **Base de datos:** `sst_pesv` (o el valor de `POSTGRES_DB`)
- **Usuario:** `sst_pesv_user` (o el valor de `POSTGRES_USER`)
- **Contraseña:** la definida en `.env`

## Dev Container

1. Abre el proyecto en VS Code
2. Presiona `F1` → "Dev Containers: Reopen in Container"
3. Espera a que se construya la imagen

El Dev Container incluye cliente `psql`, Git y herramientas básicas. PostgreSQL **no** se ejecuta dentro del contenedor; se conecta al servicio Docker Compose a través de la red `sst_pesv_network`.

## Comandos útiles

| Acción | Comando |
|---|---|
| Levantar servicios | `docker compose up -d` |
| Verificar estado | `docker compose ps` |
| Ver logs de PostgreSQL | `docker compose logs postgres` |
| Detener servicios | `docker compose down` |
| Reinicio limpio (borra datos) | `docker compose down -v` |
| Conexión interactiva psql | `docker exec -it sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv` |

## Estructura del repositorio

```
sst-pesv/
├── .devcontainer/              # Configuración Dev Container (VS Code)
│   ├── devcontainer.json
│   └── Dockerfile
├── .env.example                # Plantilla de variables de entorno
├── .gitignore
├── docker-compose.yml          # Orquestación: PostgreSQL 16 + pgAdmin 4
├── Examen.md                   # Enunciado original del examen
├── TASKS.md                    # Plan de trabajo por sesiones
├── README.md                   # Este archivo
├── init/
│   └── 00_init_schema.sql      # Script maestro de inicialización del esquema
├── sql/
│   ├── 01_schema/              # DDL: esquema completo
│   │   ├── 000_extensions.sql
│   │   ├── 001_create_tables.sql
│   │   ├── 002_foreign_keys.sql
│   │   ├── 003_constraints.sql
│   │   ├── 004_indexes.sql
│   │   ├── 005_alter_tenanttemplates.sql
│   │   └── 006_add_missing_index.sql
│   ├── 02_seed/
│   │   └── 001_seed_data.sql
│   ├── 03_queries/
│   │   ├── basicas.sql         # 15 consultas básicas (B01–B15)
│   │   ├── intermedias.sql     # 20 consultas intermedias (I01–I20)
│   │   └── avanzadas.sql       # 25 consultas avanzadas (C.3.1–C.3.25)
│   ├── 04_views/
│   │   ├── 001_views.sql
│   │   └── 002_materialized_views.sql
│   ├── 05_functions/
│   │   └── 001_functions.sql
│   ├── 06_procedures/
│   │   └── 001_procedures.sql
│   └── 07_triggers/
│       └── 001_triggers.sql
└── docs/
    ├── diccionario_datos.md    # Modelo físico completo (tablas, columnas, tipos, restricciones, relaciones, índices)
    ├── incidencias.md          # Registro de incidencias y decisiones durante el desarrollo
    ├── modelo_conceptual.md    # Modelo conceptual
    ├── modelo_fisico.md        # Modelo físico
    ├── modelo_logico.md        # Modelo lógico
    └── requerimientos.md       # Requerimientos extraídos del examen
```

## Documentación adicional

- **[docs/diccionario_datos.md](docs/diccionario_datos.md)** — Detalle completo del modelo físico: 19 tablas, 89 columnas, tipos, restricciones, relaciones e índices.
- **[docs/incidencias.md](docs/incidencias.md)** — Registro de incidencias y decisiones relevantes durante el desarrollo.

## Reinicio limpio completo

Para reconstruir el entorno desde cero:

```bash
docker compose down -v
docker compose up -d
for f in \
  sql/01_schema/000_extensions.sql \
  sql/01_schema/001_create_tables.sql \
  sql/01_schema/002_foreign_keys.sql \
  sql/01_schema/003_constraints.sql \
  sql/01_schema/004_indexes.sql \
  sql/01_schema/005_alter_tenanttemplates.sql \
  sql/01_schema/006_add_missing_index.sql \
  sql/02_seed/001_seed_data.sql \
  sql/04_views/001_views.sql \
  sql/04_views/002_materialized_views.sql \
  sql/05_functions/001_functions.sql \
  sql/06_procedures/001_procedures.sql \
  sql/07_triggers/001_triggers.sql; do
  docker exec -i sst_pesv_postgres psql -U sst_pesv_user -d sst_pesv < "$f"
done
```
