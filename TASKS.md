# Plan de Trabajo - SST/PESV PostgreSQL Database

## Sesión 1.1 — Entorno y repositorio ✅
- [x] Estructura de carpetas
- [x] .gitignore profesional
- [x] .env.example
- [x] docker-compose.yml (PostgreSQL 16 + pgAdmin 8.13)
- [x] Dev Container (psql, Git, herramientas)
- [x] README inicial
- [x] Validación docker compose config
- [x] Verificación real de Docker, PostgreSQL, pgAdmin, Dev Container
- [x] Commit inicial

## Sesión 1.2 — Análisis de requerimientos
- [ ] Análisis de TASKS.md y Examen.md
- [ ] Identificación de entidades y relaciones
- [ ] Definición de alcance multi-tenant
- [ ] Documentación de decisiones de diseño

## Sesión 1.3 — Modelo Entidad-Relación
- [ ] Diagrama ER conceptual
- [ ] Normalización a 3FN
- [ ] Diccionario de datos preliminar

## Sesión 1.4 — DDL: Esquema base (sql/01_schema)
- [ ] Tablas core: tenants, users, roles
- [ ] Tablas SST: riesgos, incidentes, capacitaciones, inspecciones
- [ ] Tablas PESV: vehiculos, conductores, rutas, controles
- [ ] Índices y constraints
- [ ] Migración inicial

## Sesión 1.5 — Datos semilla (sql/02_seed)
- [ ] Datos de referencia (catálogos, tipos, estados)
- [ ] Tenant de prueba
- [ ] Usuarios de prueba

## Sesión 1.6 — Consultas del examen (sql/03_queries)
- [ ] Consultas requeridas por el enunciado
- [ ] Índices de soporte
- [ ] EXPLAIN ANALYZE

## Sesión 1.7 — Vistas (sql/04_views)
- [ ] Vistas de reporting
- [ ] Vistas de seguridad (RLS)

## Sesión 1.8 — Funciones (sql/05_functions)
- [ ] Funciones de negocio
- [ ] Funciones de utilidad

## Sesión 1.9 — Procedimientos (sql/06_procedures)
- [ ] Procedimientos de carga/mantenimiento
- [ ] Procedimientos de reporting

## Sesión 1.10 — Triggers (sql/07_triggers)
- [ ] Auditoria
- [ ] Validaciones complejas
- [ ] Sincronización

## Sesión 1.11 — Validación y documentación final
- [ ] Pruebas de integración
- [ ] Documentación técnica
- [ ] README final
- [ ] Entrega