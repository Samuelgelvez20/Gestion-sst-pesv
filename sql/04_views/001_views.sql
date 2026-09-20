-- ============================================================================
-- SST-PESV: Vistas ordinarias (5 + vw_tenant_summary)
-- Sesión 2.5 — Vistas y vistas materializadas
-- Archivo: sql/04_views/001_views.sql
-- PostgreSQL 16
-- ============================================================================
-- Vistas §4.1–§4.5 del Examen.md + vw_tenant_summary (C.3.25, §3)
-- ============================================================================

-- ============================================================================
-- §4.1 — vw_tenant_persons
-- "Consultar las organizaciones junto con sus personas y cargos asociados"
-- Tablas: tenants, persons, positions
-- ============================================================================
CREATE OR REPLACE VIEW vw_tenant_persons AS
SELECT t.id AS tenant_id,
       t.name AS organizacion,
       p.first_name || ' ' || p.last_name AS nombre_completo,
       p.email AS correo,
       pos.description AS cargo,
       p.is_active AS persona_activa
FROM tenants t
INNER JOIN persons p ON t.id = p.tenant_id
INNER JOIN positions pos ON p.position_id = pos.id
ORDER BY t.name, p.last_name, p.first_name;

-- ============================================================================
-- §4.2 — vw_tenant_geography
-- "Consolidar la información geográfica de las organizaciones incluyendo
--  municipio, departamento o región y país"
-- Tablas: tenants, municipalities, departments, countries
-- ============================================================================
CREATE OR REPLACE VIEW vw_tenant_geography AS
SELECT t.id AS tenant_id,
       t.name AS organizacion,
       m.name AS municipio,
       d.name AS departamento,
       c.name AS pais
FROM tenants t
INNER JOIN municipalities m ON t.municipality_id = m.id
INNER JOIN departments d ON m.department_id = d.id
INNER JOIN countries c ON d.country_id = c.id
ORDER BY c.name, d.name, m.name, t.name;

-- ============================================================================
-- §4.3 — vw_tenant_modules
-- "Mostrar los módulos habilitados para cada organización y el sistema SST
--  al cual pertenecen"
-- Tablas: tenant_modules, modules, tenantsystems, type_system_sst
-- Nota: se JOINa tenantsystems para obtener el sistema SST del módulo,
--       pero la relación real es modules → type_system_sst.
--       Se incluye tenantsystems para filtrar solo sistemas habilitados.
-- ============================================================================
CREATE OR REPLACE VIEW vw_tenant_modules AS
SELECT t.id AS tenant_id,
       t.name AS organizacion,
       m.title AS modulo,
       m.description AS descripcion_modulo,
       tss.name AS sistema_sst,
       m.sort_order AS orden
FROM tenants t
INNER JOIN tenant_modules tm ON t.id = tm.tenant_id
INNER JOIN modules m ON tm.module_id = m.id
INNER JOIN type_system_sst tss ON m.type_system_sst_id = tss.id
ORDER BY t.name, m.sort_order;

-- ============================================================================
-- §4.4 — vw_tenant_phva_templates
-- "Presentar la cantidad total de plantillas asociadas a cada organización
--  y etapa PHVA"
-- Tablas: tenanttemplates, tenants, phva_stages
-- ============================================================================
CREATE OR REPLACE VIEW vw_tenant_phva_templates AS
SELECT t.id AS tenant_id,
       t.name AS organizacion,
       ps.code AS codigo_phva,
       ps.name AS etapa_phva,
       COUNT(tt.id) AS total_plantillas
FROM tenants t
INNER JOIN tenanttemplates tt ON t.id = tt.tenant_id
INNER JOIN phva_stages ps ON tt.phva_stage_id = ps.id
GROUP BY t.id, t.name, ps.id, ps.code, ps.name
ORDER BY t.name, ps.code;

-- ============================================================================
-- §4.5 — vw_tenant_persons_positions
-- "Consultar el total de personas existentes por organización y cargo"
-- Tablas: persons, positions, tenants
-- ============================================================================
CREATE OR REPLACE VIEW vw_tenant_persons_positions AS
SELECT t.id AS tenant_id,
       t.name AS organizacion,
       pos.description AS cargo,
       COUNT(p.id) AS total_personas
FROM tenants t
INNER JOIN positions pos ON t.id = pos.tenant_id
LEFT JOIN persons p ON pos.id = p.position_id AND p.is_active = true
GROUP BY t.id, t.name, pos.id, pos.description
ORDER BY t.name, total_personas DESC;

-- ============================================================================
-- C.3.25 / §3.25 — vw_tenant_summary (ya existente en avanzadas.sql)
-- "Vista que consolide personas, módulos, plantillas y sistemas por org"
-- Se recrea aquí para mantener la sesión 2.5 como fuente de vistas.
-- ============================================================================
CREATE OR REPLACE VIEW vw_tenant_summary AS
SELECT t.id AS tenant_id,
       t.name AS organizacion,
       COUNT(DISTINCT p.id) AS total_personas,
       COUNT(DISTINCT tm.id) AS total_modulos,
       COUNT(DISTINCT tt.id) AS total_plantillas,
       COUNT(DISTINCT ts.id) AS total_sistemas
FROM tenants t
LEFT JOIN persons p ON t.id = p.tenant_id
LEFT JOIN tenant_modules tm ON t.id = tm.tenant_id
LEFT JOIN tenanttemplates tt ON t.id = tt.tenant_id
LEFT JOIN tenantsystems ts ON t.id = ts.tenant_id
GROUP BY t.id, t.name;
