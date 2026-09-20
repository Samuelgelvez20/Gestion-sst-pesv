# SST/PESV PostgreSQL Database

## Descripción

Proyecto académico para diseñar e implementar una base de datos multi-tenant para gestión de SST (Salud y Seguridad en el Trabajo) y PESV (Plan Estratégico de Seguridad Vial) utilizando PostgreSQL 16.

## Stack

- PostgreSQL 16
- Docker
- Docker Compose
- Dev Container
- VS Code
- pgAdmin 4

## Requisitos

- Docker Engine 24.0+
- Docker Compose 2.20+ (o `docker compose` plugin)
- VS Code con extensión "Dev Containers" (opcional, para desarrollo en contenedor)
- Git

## Configuración

1. Copia el archivo de ejemplo de variables de entorno:

```bash
cp .env.example .env
```

2. Revisa y modifica `.env` según tus necesidades. **No uses las contraseñas por defecto en entornos reales.**

## Levantar entorno

```bash
docker compose up -d
```

## Verificar servicios

```bash
docker compose ps
```

## Detener entorno

```bash
docker compose down
```

## Reinicio limpio (elimina volúmenes y datos)

```bash
docker compose down -v
```

> **Importante:** La opción `-v` elimina los volúmenes asociados y, por tanto, **todos los datos persistidos** de PostgreSQL y pgAdmin. Úsalo cuando quieras reconstruir el entorno desde cero.

## pgAdmin

Accede a pgAdmin en:

```
http://localhost:8081
```

Credenciales: las definidas en `.env` (variables `PGADMIN_EMAIL` y `PGADMIN_PASSWORD`).

Para conectar a PostgreSQL desde pgAdmin:
- Host: `postgres` (nombre del servicio en Docker Compose)
- Puerto: `5432`
- Base de datos: valor de `POSTGRES_DB`
- Usuario: valor de `POSTGRES_USER`
- Contraseña: valor de `POSTGRES_PASSWORD`

## Dev Container

Para desarrollar dentro del contenedor:

1. Abre el proyecto en VS Code
2. Presiona `F1` → "Dev Containers: Reopen in Container"
3. Espera a que se construya la imagen

El Dev Container incluye:
- Cliente `psql` (PostgreSQL 16)
- Git
- Herramientas básicas de desarrollo (vim, curl, wget, less)
- Extensiones recomendadas para PostgreSQL y YAML

**Nota:** PostgreSQL NO se ejecuta dentro del Dev Container. Se conecta al servicio PostgreSQL proporcionado por Docker Compose a través de la red interna `sst_pesv_network`.

## Arquitectura de inicialización

> **Nota:** La estrategia definitiva entre `init/` y `sql/` se definirá durante las sesiones de modelado e implementación.

Por ahora:
- `init/` = reservado para scripts de inicialización automática de infraestructura/entorno (si se decide usarlos)
- `sql/` = scripts SQL versionados del proyecto que serán ejecutados por fases

## Estructura del repositorio

```
.devcontainer/     # Configuración del Dev Container (VS Code)
init/              # Scripts de inicialización de infraestructura (pendiente de definir)
sql/               # Scripts SQL versionados del proyecto
├── 01_schema/     # DDL: tablas, índices, constraints
├── 02_seed/       # Datos semilla / referencia
├── 03_queries/    # Consultas del examen / reportes
├── 04_views/      # Vistas
├── 05_functions/  # Funciones SQL
├── 06_procedures/ # Procedimientos almacenados
└── 07_triggers/   # Triggers
docs/              # Documentación del proyecto
docker-compose.yml # Orquestación de servicios
.env.example       # Plantilla de variables de entorno
.gitignore         # Archivos ignorados por Git
README.md          # Este archivo
TASKS.md           # Plan de trabajo por sesiones
```

## Próximos pasos

Ver `TASKS.md` para el plan detallado de sesiones.