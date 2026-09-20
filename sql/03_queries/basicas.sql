-- ============================================================================
-- SST-PESV: Consultas SQL Básicas (15)
-- Sesión 2.3 — Consultas básicas e intermedias
-- Archivo: sql/03_queries/basicas.sql
-- PostgreSQL 16
-- ============================================================================
-- Consultas B01–B15 según Examen.md §1
-- Cada consulta está numerada según el enunciado del examen.
-- ============================================================================

-- ============================================================================
-- B01 — Consultar todos los registros de `tenants`
-- Fuente: Examen.md §1.1
-- ============================================================================
SELECT id, name, contact_email, phone, tenant_size_id, municipality_id,
       is_active, created_at, updated_at
FROM tenants
ORDER BY id;

-- ============================================================================
-- B02 — Nombre, correo y teléfono de organizaciones en `tenants`
-- Fuente: Examen.md §1.2
-- ============================================================================
SELECT name, contact_email, phone
FROM tenants
ORDER BY name;

-- ============================================================================
-- B03 — Listar personas con nombres, apellidos y correo
-- Fuente: Examen.md §1.3
-- ============================================================================
SELECT first_name, last_name, email
FROM persons
ORDER BY last_name, first_name;

-- ============================================================================
-- B04 — Personas con estado activo
-- Fuente: Examen.md §1.4
-- ============================================================================
SELECT id, first_name, last_name, email, tenant_id
FROM persons
WHERE is_active = true
ORDER BY last_name, first_name;

-- ============================================================================
-- B05 — Organizaciones cuyo nombre contenga una palabra (búsqueda)
-- Fuente: Examen.md §1.5
-- Parámetro: 'Empresa' (criterio de búsqueda)
-- ============================================================================
SELECT id, name, contact_email, phone
FROM tenants
WHERE name LIKE '%Empresa%'
ORDER BY name;

-- ============================================================================
-- B06 — Países ordenados alfabéticamente
-- Fuente: Examen.md §1.6
-- ============================================================================
SELECT id, name
FROM countries
ORDER BY name ASC;

-- ============================================================================
-- B07 — Departamentos de un país determinado
-- Fuente: Examen.md §1.7
-- Parámetro: Colombia (country_id = 1)
-- ============================================================================
SELECT d.id, d.name, c.name AS country_name
FROM departments d
INNER JOIN countries c ON d.country_id = c.id
WHERE c.name = 'Colombia'
ORDER BY d.name;

-- ============================================================================
-- B08 — Municipios de un departamento determinado
-- Fuente: Examen.md §1.8
-- Parámetro: Cundinamarca (department_id = 1)
-- ============================================================================
SELECT m.id, m.name, d.name AS department_name
FROM municipalities m
INNER JOIN departments d ON m.department_id = d.id
WHERE d.name = 'Cundinamarca'
ORDER BY m.name;

-- ============================================================================
-- B09 — Cargos ordenados por descripción
-- Fuente: Examen.md §1.9
-- ============================================================================
SELECT id, description, tenant_id
FROM positions
ORDER BY description ASC;

-- ============================================================================
-- B10 — Personas de una organización por `tenant_id`
-- Fuente: Examen.md §1.10
-- Parámetro: tenant_id = 1 (Empresa ABC S.A.S.)
-- ============================================================================
SELECT id, first_name, last_name, email, position_id, is_active
FROM persons
WHERE tenant_id = 1
ORDER BY last_name, first_name;

-- ============================================================================
-- B11 — Organizaciones habilitadas/activas
-- Fuente: Examen.md §1.11
-- ============================================================================
SELECT id, name, contact_email, phone, is_active
FROM tenants
WHERE is_active = true
ORDER BY name;

-- ============================================================================
-- B12 — Organizaciones registradas en un período (fecha de creación)
-- Fuente: Examen.md §1.12
-- Parámetro: entre 2024-01-01 y 2024-06-30
-- ============================================================================
SELECT id, name, contact_email, created_at
FROM tenants
WHERE created_at BETWEEN '2024-01-01' AND '2024-06-30'
ORDER BY created_at;

-- ============================================================================
-- B13 — Tamaños de empresa
-- Fuente: Examen.md §1.13
-- ============================================================================
SELECT id, name
FROM tenant_sizes
ORDER BY id;

-- ============================================================================
-- B14 — Tipos de sistemas SST
-- Fuente: Examen.md §1.14
-- ============================================================================
SELECT id, name
FROM type_system_sst
ORDER BY id;

-- ============================================================================
-- B15 — Módulos con título, descripción y orden
-- Fuente: Examen.md §1.15
-- ============================================================================
SELECT title, description, sort_order
FROM modules
ORDER BY sort_order, title;
