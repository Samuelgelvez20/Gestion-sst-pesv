-- ============================================================================
-- SST-PESV: Vistas materializadas (3)
-- Sesión 2.5 — Vistas y vistas materializadas
-- Archivo: sql/04_views/002_materialized_views.sql
-- PostgreSQL 16
-- ============================================================================
-- MV §4.6 + MVs dependencias de C.3.22
-- ============================================================================

-- ============================================================================
-- §4.6 — vm_compliance_summary
-- "Consolidar el número total de documentos, documentos finalizados,
--  documentos pendientes y porcentaje de cumplimiento por organización"
-- Tablas: documents, tenants
-- ============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS vm_compliance_summary AS
SELECT t.id AS tenant_id,
       t.name AS organizacion,
       COUNT(d.id) AS total_documentos,
       COUNT(d.id) FILTER (WHERE d.status = 'finalizado') AS documentos_finalizados,
       COUNT(d.id) FILTER (WHERE d.status = 'borrador') AS documentos_borrador,
       COUNT(d.id) FILTER (WHERE d.status = 'no_iniciado') AS documentos_no_iniciados,
       COUNT(d.id) FILTER (WHERE d.status = 'pendiente') AS documentos_pendientes,
       ROUND(
           COUNT(d.id) FILTER (WHERE d.status = 'finalizado') * 100.0 /
           NULLIF(COUNT(d.id), 0),
           2
       ) AS porcentaje_cumplimiento
FROM tenants t
LEFT JOIN documents d ON t.id = d.tenant_id
GROUP BY t.id, t.name
WITH DATA;

-- ============================================================================
-- vm_template_sst_docs_summary
-- Resumen de documentos SST por organización
-- Filtra por sistemas SST: "Sistema de Gestión de Seguridad y Salud en el
-- Trabajo" y "Sistema Integrado de Gestión" (ambos son SST)
-- Usado por C.3.22
-- ============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS vm_template_sst_docs_summary AS
SELECT t.id AS tenant_id,
       t.name AS organizacion,
       tss.name AS sistema_sst,
       COUNT(d.id) AS total_documentos,
       COUNT(d.id) FILTER (WHERE d.status = 'finalizado') AS documentos_finalizados,
       COUNT(d.id) FILTER (WHERE d.status = 'pendiente') AS documentos_pendientes,
       COUNT(d.id) FILTER (WHERE d.status = 'borrador') AS documentos_borrador,
       COUNT(d.id) FILTER (WHERE d.status = 'no_iniciado') AS documentos_no_iniciados,
       ROUND(
           COUNT(d.id) FILTER (WHERE d.status = 'finalizado') * 100.0 /
           NULLIF(COUNT(d.id), 0),
           2
       ) AS porcentaje_cumplimiento
FROM tenants t
INNER JOIN documents d ON t.id = d.tenant_id
INNER JOIN tenanttemplates tt ON d.tenanttemplate_id = tt.id
INNER JOIN type_system_sst tss ON tt.type_system_sst_id = tss.id
WHERE tss.name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'
GROUP BY t.id, t.name, tss.name
WITH DATA;

-- ============================================================================
-- vm_template_pesv_docs_summary
-- Resumen de documentos PESV por organización
-- Filtra por sistema PESV: "Sistema de Gestión de Seguridad Vial"
-- Usado por C.3.22
-- ============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS vm_template_pesv_docs_summary AS
SELECT t.id AS tenant_id,
       t.name AS organizacion,
       tss.name AS sistema_sst,
       COUNT(d.id) AS total_documentos,
       COUNT(d.id) FILTER (WHERE d.status = 'finalizado') AS documentos_finalizados,
       COUNT(d.id) FILTER (WHERE d.status = 'pendiente') AS documentos_pendientes,
       COUNT(d.id) FILTER (WHERE d.status = 'borrador') AS documentos_borrador,
       COUNT(d.id) FILTER (WHERE d.status = 'no_iniciado') AS documentos_no_iniciados,
       ROUND(
           COUNT(d.id) FILTER (WHERE d.status = 'finalizado') * 100.0 /
           NULLIF(COUNT(d.id), 0),
           2
       ) AS porcentaje_cumplimiento
FROM tenants t
INNER JOIN documents d ON t.id = d.tenant_id
INNER JOIN tenanttemplates tt ON d.tenanttemplate_id = tt.id
INNER JOIN type_system_sst tss ON tt.type_system_sst_id = tss.id
WHERE tss.name = 'Sistema de Gestión de Seguridad Vial'
GROUP BY t.id, t.name, tss.name
WITH DATA;

-- ============================================================================
-- §4.8 — Índices para optimizar consultas de seguimiento por organización
-- Solo sobre vm_compliance_summary (la MV principal de seguimiento)
-- ============================================================================

-- Índice para filtrar/buscar por tenant_id (consultas de seguimiento)
CREATE UNIQUE INDEX IF NOT EXISTS ix_vm_compliance_tenant
    ON vm_compliance_summary (tenant_id);

-- Índice para ordenar por porcentaje de cumplimiento (rankings)
CREATE INDEX IF NOT EXISTS ix_vm_compliance_pct
    ON vm_compliance_summary (porcentaje_cumplimiento DESC NULLS LAST);
