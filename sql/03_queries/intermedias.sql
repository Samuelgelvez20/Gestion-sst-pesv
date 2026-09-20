-- ============================================================================
-- SST-PESV: Consultas SQL Intermedias (20)
-- Sesión 2.3 — Consultas básicas e intermedias
-- Archivo: sql/03_queries/intermedias.sql
-- PostgreSQL 16
-- ============================================================================
-- Consultas I01–I20 según Examen.md §2
-- Cada consulta está numerada según el enunciado del examen.
-- ============================================================================

-- ============================================================================
-- I01 — Personas con nombre completo y organización (INNER JOIN)
-- Fuente: Examen.md §2.1
-- ============================================================================
SELECT p.first_name || ' ' || p.last_name AS nombre_completo,
       t.name AS organizacion
FROM persons p
INNER JOIN tenants t ON p.tenant_id = t.id
ORDER BY t.name, p.last_name, p.first_name;

-- ============================================================================
-- I02 — Personas con su cargo (INNER JOIN)
-- Fuente: Examen.md §2.2
-- ============================================================================
SELECT p.first_name || ' ' || p.last_name AS nombre_completo,
       pos.description AS cargo,
       t.name AS organizacion
FROM persons p
INNER JOIN positions pos ON p.position_id = pos.id
INNER JOIN tenants t ON p.tenant_id = t.id
ORDER BY t.name, pos.description, p.last_name;

-- ============================================================================
-- I03 — Organizaciones con tamaño asignado (INNER JOIN)
-- Fuente: Examen.md §2.3
-- ============================================================================
SELECT t.name AS organizacion,
       ts.name AS tamano_empresa
FROM tenants t
INNER JOIN tenant_sizes ts ON t.tenant_size_id = ts.id
ORDER BY t.name;

-- ============================================================================
-- I04 — Organizaciones con ubicación geográfica (JOIN múltiple)
-- Fuente: Examen.md §2.4
-- ============================================================================
SELECT t.name AS organizacion,
       m.name AS municipio,
       d.name AS departamento,
       c.name AS pais
FROM tenants t
INNER JOIN municipalities m ON t.municipality_id = m.id
INNER JOIN departments d ON m.department_id = d.id
INNER JOIN countries c ON d.country_id = c.id
ORDER BY c.name, d.name, m.name, t.name;

-- ============================================================================
-- I05 — Cantidad de personas por organización (GROUP BY)
-- Fuente: Examen.md §2.5
-- ============================================================================
SELECT t.name AS organizacion,
       COUNT(p.id) AS total_personas
FROM tenants t
LEFT JOIN persons p ON t.id = p.tenant_id
GROUP BY t.id, t.name
ORDER BY total_personas DESC, t.name;

-- ============================================================================
-- I06 — Organizaciones con más de N personas (HAVING)
-- Fuente: Examen.md §2.6
-- Parámetro: N = 4 personas
-- ============================================================================
SELECT t.name AS organizacion,
       COUNT(p.id) AS total_personas
FROM tenants t
INNER JOIN persons p ON t.id = p.tenant_id
GROUP BY t.id, t.name
HAVING COUNT(p.id) > 4
ORDER BY total_personas DESC;

-- ============================================================================
-- I07 — Módulos habilitados por organización
-- Fuente: Examen.md §2.7
-- ============================================================================
SELECT t.name AS organizacion,
       m.title AS modulo,
       m.description AS descripcion_modulo
FROM tenants t
INNER JOIN tenant_modules tm ON t.id = tm.tenant_id
INNER JOIN modules m ON tm.module_id = m.id
ORDER BY t.name, m.sort_order;

-- ============================================================================
-- I08 — Cantidad de módulos por organización
-- Fuente: Examen.md §2.8
-- ============================================================================
SELECT t.name AS organizacion,
       COUNT(tm.id) AS total_modulos
FROM tenants t
LEFT JOIN tenant_modules tm ON t.id = tm.tenant_id
GROUP BY t.id, t.name
ORDER BY total_modulos DESC, t.name;

-- ============================================================================
-- I09 — Sistemas SST por organización
-- Fuente: Examen.md §2.9
-- ============================================================================
SELECT t.name AS organizacion,
       tss.name AS sistema_sst
FROM tenants t
INNER JOIN tenantsystems ts ON t.id = ts.tenant_id
INNER JOIN type_system_sst tss ON ts.type_system_sst_id = tss.id
ORDER BY t.name, tss.name;

-- ============================================================================
-- I10 — Módulos con su sistema SST
-- Fuente: Examen.md §2.10
-- ============================================================================
SELECT m.title AS modulo,
       m.description AS descripcion_modulo,
       tss.name AS sistema_sst
FROM modules m
INNER JOIN type_system_sst tss ON m.type_system_sst_id = tss.id
ORDER BY tss.name, m.sort_order;

-- ============================================================================
-- I11 — Formatos con su módulo
-- Fuente: Examen.md §2.11
-- ============================================================================
SELECT f.name AS formato,
       m.title AS modulo
FROM formats_sst f
INNER JOIN modules m ON f.module_id = m.id
ORDER BY m.sort_order, f.name;

-- ============================================================================
-- I12 — Cantidad de formatos por módulo
-- Fuente: Examen.md §2.12
-- ============================================================================
SELECT m.title AS modulo,
       COUNT(f.id) AS total_formatos
FROM modules m
LEFT JOIN formats_sst f ON m.id = f.module_id
GROUP BY m.id, m.title, m.sort_order
ORDER BY m.sort_order;

-- ============================================================================
-- I13 — Plantillas asignadas por organización
-- Fuente: Examen.md §2.13
-- ============================================================================
SELECT t.name AS organizacion,
       tpl.name AS plantilla
FROM tenants t
INNER JOIN tenanttemplates tt ON t.id = tt.tenant_id
INNER JOIN templates tpl ON tt.template_id = tpl.id
ORDER BY t.name, tpl.name;

-- ============================================================================
-- I14 — Plantillas con organización, sistema SST y etapa PHVA
-- Fuente: Examen.md §2.14
-- ============================================================================
SELECT t.name AS organizacion,
       tpl.name AS plantilla,
       tss.name AS sistema_sst,
       ps.name AS etapa_phva
FROM tenanttemplates tt
INNER JOIN tenants t ON tt.tenant_id = t.id
INNER JOIN templates tpl ON tt.template_id = tpl.id
INNER JOIN type_system_sst tss ON tt.type_system_sst_id = tss.id
INNER JOIN phva_stages ps ON tt.phva_stage_id = ps.id
ORDER BY t.name, ps.code, tpl.name;

-- ============================================================================
-- I15 — Cantidad de plantillas por organización
-- Fuente: Examen.md §2.15
-- ============================================================================
SELECT t.name AS organizacion,
       COUNT(tt.id) AS total_plantillas
FROM tenants t
LEFT JOIN tenanttemplates tt ON t.id = tt.tenant_id
GROUP BY t.id, t.name
ORDER BY total_plantillas DESC, t.name;

-- ============================================================================
-- I16 — Organizaciones sin personas (LEFT JOIN + IS NULL)
-- Fuente: Examen.md §2.16
-- ============================================================================
SELECT t.id, t.name AS organizacion
FROM tenants t
LEFT JOIN persons p ON t.id = p.tenant_id
WHERE p.id IS NULL
ORDER BY t.name;

-- ============================================================================
-- I17 — Módulos no asignados a ninguna organización
-- Fuente: Examen.md §2.17
-- ============================================================================
SELECT m.id, m.title AS modulo
FROM modules m
LEFT JOIN tenant_modules tm ON m.id = tm.module_id
WHERE tm.id IS NULL
ORDER BY m.sort_order;

-- ============================================================================
-- I18 — Plantillas por etapa PHVA
-- Fuente: Examen.md §2.18
-- ============================================================================
SELECT ps.code AS codigo_phva,
       ps.name AS etapa_phva,
       COUNT(tt.id) AS total_plantillas
FROM phva_stages ps
LEFT JOIN tenanttemplates tt ON ps.id = tt.phva_stage_id
GROUP BY ps.id, ps.code, ps.name
ORDER BY ps.code;

-- ============================================================================
-- I19 — Organizaciones por municipio
-- Fuente: Examen.md §2.19
-- ============================================================================
SELECT m.name AS municipio,
       COUNT(t.id) AS total_organizaciones
FROM municipalities m
LEFT JOIN tenants t ON m.id = t.municipality_id
GROUP BY m.id, m.name
HAVING COUNT(t.id) > 0
ORDER BY total_organizaciones DESC, m.name;

-- ============================================================================
-- I20 — Cargos por organización con cantidad de personas
-- Fuente: Examen.md §2.20
-- ============================================================================
SELECT t.name AS organizacion,
       pos.description AS cargo,
       COUNT(p.id) AS total_personas
FROM tenants t
INNER JOIN positions pos ON t.id = pos.tenant_id
LEFT JOIN persons p ON pos.id = p.position_id
GROUP BY t.name, pos.id, pos.description
ORDER BY t.name, total_personas DESC;
