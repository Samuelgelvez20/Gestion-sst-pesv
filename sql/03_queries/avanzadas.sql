-- ============================================================================
-- SST-PESV: Consultas SQL Avanzadas (25)
-- Sesion 2.4-2.5 - Consultas avanzadas (completadas en sesion 2.5)
-- Archivo: sql/03_queries/avanzadas.sql
-- PostgreSQL 16
-- ============================================================================
-- Consultas C.3.1-C.3.25 segun Examen.md §3
-- Cada consulta conserva su identificador real del examen.
-- Todas las 25 consultas estan implementadas y verificadas.
-- ============================================================================

-- ============================================================================
-- C.3.1 - Organizacion con mayor cantidad de personas (subquery)
-- Fuente: Examen.md §3.1
-- Tecnicas: Subquery, COUNT, MAX
-- ============================================================================
SELECT t.name AS organizacion,
       COUNT(p.id) AS total_personas
FROM tenants t
INNER JOIN persons p ON t.id = p.tenant_id
GROUP BY t.id, t.name
HAVING COUNT(p.id) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(p2.id) AS cnt
        FROM persons p2
        GROUP BY p2.tenant_id
    ) AS sub
)
ORDER BY t.name;

-- ============================================================================
-- C.3.2 - Organizaciones con personas superior al promedio (subquery)
-- Fuente: Examen.md §3.2
-- Tecnicas: Subquery con AVG
-- ============================================================================
SELECT t.name AS organizacion,
       COUNT(p.id) AS total_personas
FROM tenants t
INNER JOIN persons p ON t.id = p.tenant_id
GROUP BY t.id, t.name
HAVING COUNT(p.id) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(p2.id) AS cnt
        FROM persons p2
        GROUP BY p2.tenant_id
    ) AS sub
)
ORDER BY total_personas DESC;

-- ============================================================================
-- C.3.3 - Organizaciones con todos los modulos de un sistema SST (relacional)
-- Fuente: Examen.md §3.3
-- Tecnicas: NOT EXISTS / COUNT = total
-- ============================================================================
SELECT t.name AS organizacion,
       tss.name AS sistema_sst
FROM tenants t
INNER JOIN tenantsystems ts ON t.id = ts.tenant_id
INNER JOIN type_system_sst tss ON ts.type_system_sst_id = tss.id
WHERE NOT EXISTS (
    SELECT m.id
    FROM modules m
    WHERE m.type_system_sst_id = tss.id
    AND NOT EXISTS (
        SELECT tm.id
        FROM tenant_modules tm
        WHERE tm.tenant_id = t.id
        AND tm.module_id = m.id
    )
)
ORDER BY t.name, tss.name;

-- ============================================================================
-- C.3.4 - Organizaciones con modulos pero sin plantillas (subquery)
-- Fuente: Examen.md §3.4
-- Tecnicas: EXISTS + NOT EXISTS
-- ============================================================================
SELECT t.id, t.name AS organizacion
FROM tenants t
WHERE EXISTS (
    SELECT 1 FROM tenant_modules tm WHERE tm.tenant_id = t.id
)
AND NOT EXISTS (
    SELECT 1 FROM tenanttemplates tt WHERE tt.tenant_id = t.id
)
ORDER BY t.name;

-- ============================================================================
-- C.3.5 - Organizaciones con plantillas en todas las etapas PHVA (relacional)
-- Fuente: Examen.md §3.5
-- Tecnicas: GROUP BY HAVING COUNT = 4
-- ============================================================================
SELECT t.id, t.name AS organizacion
FROM tenants t
INNER JOIN tenanttemplates tt ON t.id = tt.tenant_id
GROUP BY t.id, t.name
HAVING COUNT(DISTINCT tt.phva_stage_id) = (
    SELECT COUNT(*) FROM phva_stages
)
ORDER BY t.name;

-- ============================================================================
-- C.3.6 - Plantillas por organizacion discriminadas por etapa PHVA
-- Fuente: Examen.md §3.6
-- Tecnicas: COUNT, GROUP BY
-- ============================================================================
SELECT t.name AS organizacion,
       ps.code AS etapa_codigo,
       ps.name AS etapa_phva,
       COUNT(tt.id) AS total_plantillas
FROM tenants t
INNER JOIN tenanttemplates tt ON t.id = tt.tenant_id
INNER JOIN phva_stages ps ON tt.phva_stage_id = ps.id
GROUP BY t.id, t.name, ps.id, ps.code, ps.name
ORDER BY t.name, ps.code;

-- ============================================================================
-- C.3.7 - Plantillas en columnas Planear/Hacer/Verificar/Actuar (PIVOT)
-- Fuente: Examen.md §3.7
-- Tecnicas: CASE WHEN + SUM condicional
-- ============================================================================
SELECT t.name AS organizacion,
       SUM(CASE WHEN ps.code = 'P' THEN 1 ELSE 0 END) AS planear,
       SUM(CASE WHEN ps.code = 'H' THEN 1 ELSE 0 END) AS hacer,
       SUM(CASE WHEN ps.code = 'V' THEN 1 ELSE 0 END) AS verificar,
       SUM(CASE WHEN ps.code = 'A' THEN 1 ELSE 0 END) AS actuar,
       COUNT(tt.id) AS total
FROM tenants t
INNER JOIN tenanttemplates tt ON t.id = tt.tenant_id
INNER JOIN phva_stages ps ON tt.phva_stage_id = ps.id
GROUP BY t.id, t.name
ORDER BY t.name;

-- ============================================================================
-- C.3.8 - Porcentaje de cada etapa PHVA sobre total de plantillas
-- Fuente: Examen.md §3.8
-- Tecnicas: Porcentaje con CASE/SUM
-- ============================================================================
SELECT t.name AS organizacion,
       ps.code AS etapa_codigo,
       ps.name AS etapa_phva,
       COUNT(tt.id) AS cantidad,
       ROUND(
           COUNT(tt.id) * 100.0 / SUM(COUNT(tt.id)) OVER (PARTITION BY t.id),
           2
       ) AS porcentaje
FROM tenants t
INNER JOIN tenanttemplates tt ON t.id = tt.tenant_id
INNER JOIN phva_stages ps ON tt.phva_stage_id = ps.id
GROUP BY t.id, t.name, ps.id, ps.code, ps.name
ORDER BY t.name, ps.code;

-- ============================================================================
-- C.3.9 - Etapa PHVA con mas plantillas por organizacion (window function)
-- Fuente: Examen.md §3.9
-- Tecnicas: ROW_NUMBER() OVER (PARTITION BY)
-- ============================================================================
SELECT organizacion, etapa_codigo, etapa_phva, total_plantillas
FROM (
    SELECT t.name AS organizacion,
           ps.code AS etapa_codigo,
           ps.name AS etapa_phva,
           COUNT(tt.id) AS total_plantillas,
           ROW_NUMBER() OVER (
               PARTITION BY t.id
               ORDER BY COUNT(tt.id) DESC, ps.code
           ) AS rn
    FROM tenants t
    INNER JOIN tenanttemplates tt ON t.id = tt.tenant_id
    INNER JOIN phva_stages ps ON tt.phva_stage_id = ps.id
    GROUP BY t.id, t.name, ps.id, ps.code, ps.name
) ranked
WHERE rn = 1
ORDER BY organizacion;

-- ============================================================================
-- C.3.10 - Porcentaje de documentos finalizados vs total
--           (usando vista materializada de resumen)
-- Fuente: Examen.md §3.10
-- Tecnicas: Consulta sobre vista materializada
-- Requiere: vm_compliance_summary (sesion 2.5)
-- ============================================================================
SELECT organizacion,
       total_documentos,
       documentos_finalizados,
       porcentaje_cumplimiento
FROM vm_compliance_summary
ORDER BY porcentaje_cumplimiento DESC NULLS LAST;

-- ============================================================================
-- C.3.11 - Organizaciones con cumplimiento bajo el promedio
-- Fuente: Examen.md §3.11
-- Tecnicas: Subquery con AVG
-- Cumplimiento = documentos finalizados / total documentos * 100
-- ============================================================================
WITH cumplimiento AS (
    SELECT t.id,
           t.name AS organizacion,
           COUNT(d.id) AS total_docs,
           COUNT(d.id) FILTER (WHERE d.status = 'finalizado') AS docs_finalizados,
           ROUND(
               COUNT(d.id) FILTER (WHERE d.status = 'finalizado') * 100.0 /
               NULLIF(COUNT(d.id), 0),
               2
           ) AS porcentaje_cumplimiento
    FROM tenants t
    INNER JOIN documents d ON t.id = d.tenant_id
    GROUP BY t.id, t.name
)
SELECT organizacion, total_docs, docs_finalizados, porcentaje_cumplimiento
FROM cumplimiento
WHERE porcentaje_cumplimiento < (
    SELECT AVG(porcentaje_cumplimiento) FROM cumplimiento
)
ORDER BY porcentaje_cumplimiento;

-- ============================================================================
-- C.3.12 - Clasificacion bajo/medio/alto con CASE
-- Fuente: Examen.md §3.12
-- Tecnicas: CASE WHEN
-- Cumplimiento = documentos finalizados / total documentos * 100
-- ============================================================================
WITH cumplimiento AS (
    SELECT t.id,
           t.name AS organizacion,
           COUNT(d.id) AS total_docs,
           COUNT(d.id) FILTER (WHERE d.status = 'finalizado') AS docs_finalizados,
           ROUND(
               COUNT(d.id) FILTER (WHERE d.status = 'finalizado') * 100.0 /
               NULLIF(COUNT(d.id), 0),
               2
           ) AS porcentaje_cumplimiento
    FROM tenants t
    INNER JOIN documents d ON t.id = d.tenant_id
    GROUP BY t.id, t.name
)
SELECT organizacion,
       porcentaje_cumplimiento,
       CASE
           WHEN porcentaje_cumplimiento < 30 THEN 'Bajo'
           WHEN porcentaje_cumplimiento < 60 THEN 'Medio'
           ELSE 'Alto'
       END AS clasificacion
FROM cumplimiento
ORDER BY porcentaje_cumplimiento;

-- ============================================================================
-- C.3.13 - Ranking de organizaciones por cumplimiento (window function)
-- Fuente: Examen.md §3.13
-- Tecnicas: RANK()
-- Cumplimiento = documentos finalizados / total documentos * 100
-- ============================================================================
WITH cumplimiento AS (
    SELECT t.id,
           t.name AS organizacion,
           COUNT(d.id) AS total_docs,
           COUNT(d.id) FILTER (WHERE d.status = 'finalizado') AS docs_finalizados,
           ROUND(
               COUNT(d.id) FILTER (WHERE d.status = 'finalizado') * 100.0 /
               NULLIF(COUNT(d.id), 0),
               2
           ) AS porcentaje_cumplimiento
    FROM tenants t
    INNER JOIN documents d ON t.id = d.tenant_id
    GROUP BY t.id, t.name
)
SELECT RANK() OVER (ORDER BY porcentaje_cumplimiento DESC) AS ranking,
       organizacion,
       porcentaje_cumplimiento
FROM cumplimiento
ORDER BY ranking;

-- ============================================================================
-- C.3.14 - Porcentaje de cumplimiento y diferencia al promedio (window function)
-- Fuente: Examen.md §3.14
-- Tecnicas: AVG() OVER ()
-- Cumplimiento = documentos finalizados / total documentos * 100
-- ============================================================================
WITH cumplimiento AS (
    SELECT t.id,
           t.name AS organizacion,
           COUNT(d.id) AS total_docs,
           COUNT(d.id) FILTER (WHERE d.status = 'finalizado') AS docs_finalizados,
           ROUND(
               COUNT(d.id) FILTER (WHERE d.status = 'finalizado') * 100.0 /
               NULLIF(COUNT(d.id), 0),
               2
           ) AS porcentaje_cumplimiento
    FROM tenants t
    INNER JOIN documents d ON t.id = d.tenant_id
    GROUP BY t.id, t.name
)
SELECT organizacion,
       porcentaje_cumplimiento,
       ROUND(AVG(porcentaje_cumplimiento) OVER (), 2) AS promedio_general,
       ROUND(porcentaje_cumplimiento - AVG(porcentaje_cumplimiento) OVER (), 2) AS diferencia_al_promedio
FROM cumplimiento
ORDER BY porcentaje_cumplimiento DESC;

-- ============================================================================
-- C.3.15 - Cantidad acumulada de documentos finalizados por organizacion
-- Fuente: Examen.md §3.15
-- Tecnicas: SUM() OVER (ORDER BY)
-- ============================================================================
SELECT t.name AS organizacion,
       d.id AS documento_id,
       d.status,
       d.created_at,
       SUM(CASE WHEN d.status = 'finalizado' THEN 1 ELSE 0 END) OVER (
           PARTITION BY t.id
           ORDER BY d.created_at
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS acumulado_finalizados
FROM tenants t
INNER JOIN documents d ON t.id = d.tenant_id
ORDER BY t.name, d.created_at;

-- ============================================================================
-- C.3.16 - Organizaciones mismo municipio, diferente tamano
-- Fuente: Examen.md §3.16
-- Tecnicas: Self JOIN
-- ============================================================================
SELECT t1.name AS organizacion_1,
       t2.name AS organizacion_2,
       m.name AS municipio,
       ts1.name AS tamano_1,
       ts2.name AS tamano_2
FROM tenants t1
INNER JOIN tenants t2 ON t1.municipality_id = t2.municipality_id
    AND t1.id < t2.id
INNER JOIN municipalities m ON t1.municipality_id = m.id
INNER JOIN tenant_sizes ts1 ON t1.tenant_size_id = ts1.id
INNER JOIN tenant_sizes ts2 ON t2.tenant_size_id = ts2.id
WHERE t1.tenant_size_id != t2.tenant_size_id
ORDER BY m.name, t1.name;

-- ============================================================================
-- C.3.17 - Personas con cargo mas ocupado que el promedio
-- Fuente: Examen.md §3.17
-- Tecnicas: Subquery con AVG + GROUP BY
-- ============================================================================
SELECT p.first_name || ' ' || p.last_name AS nombre_completo,
       pos.description AS cargo,
       t.name AS organizacion
FROM persons p
INNER JOIN positions pos ON p.position_id = pos.id
INNER JOIN tenants t ON p.tenant_id = t.id
WHERE pos.id IN (
    SELECT pos2.id
    FROM positions pos2
    INNER JOIN persons p2 ON pos2.id = p2.position_id
    WHERE pos2.tenant_id = p.tenant_id
    GROUP BY pos2.id
    HAVING COUNT(p2.id) > (
        SELECT AVG(cnt)
        FROM (
            SELECT COUNT(p3.id) AS cnt
            FROM positions pos3
            INNER JOIN persons p3 ON pos3.id = p3.position_id
            WHERE pos3.tenant_id = p.tenant_id
            GROUP BY pos3.id
        ) AS sub
    )
)
ORDER BY t.name, pos.description, p.last_name;

-- ============================================================================
-- C.3.18 - CTE: personas por organizacion, filtrar superiores al promedio
-- Fuente: Examen.md §3.18
-- Tecnicas: WITH (CTE)
-- ============================================================================
WITH personas_por_tenant AS (
    SELECT t.id AS tenant_id,
           t.name AS organizacion,
           COUNT(p.id) AS total_personas
    FROM tenants t
    LEFT JOIN persons p ON t.id = p.tenant_id
    GROUP BY t.id, t.name
)
SELECT organizacion, total_personas
FROM personas_por_tenant
WHERE total_personas > (SELECT AVG(total_personas) FROM personas_por_tenant)
ORDER BY total_personas DESC;

-- ============================================================================
-- C.3.19 - CTE: consolidar modulos, plantillas y personas por organizacion
-- Fuente: Examen.md §3.19
-- Tecnicas: WITH (CTE) multiple
-- ============================================================================
WITH modulos AS (
    SELECT t.id AS tenant_id,
           COUNT(tm.id) AS total_modulos
    FROM tenants t
    LEFT JOIN tenant_modules tm ON t.id = tm.tenant_id
    GROUP BY t.id
),
plantillas AS (
    SELECT t.id AS tenant_id,
           COUNT(tt.id) AS total_plantillas
    FROM tenants t
    LEFT JOIN tenanttemplates tt ON t.id = tt.tenant_id
    GROUP BY t.id
),
personas AS (
    SELECT t.id AS tenant_id,
           COUNT(p.id) AS total_personas
    FROM tenants t
    LEFT JOIN persons p ON t.id = p.tenant_id
    GROUP BY t.id
)
SELECT t.name AS organizacion,
       COALESCE(m.total_modulos, 0) AS total_modulos,
       COALESCE(pl.total_plantillas, 0) AS total_plantillas,
       COALESCE(pe.total_personas, 0) AS total_personas
FROM tenants t
LEFT JOIN modulos m ON t.id = m.tenant_id
LEFT JOIN plantillas pl ON t.id = pl.tenant_id
LEFT JOIN personas pe ON t.id = pe.tenant_id
ORDER BY t.name;

-- ============================================================================
-- C.3.20 - Organizaciones sin etapa PHVA requerida en plantillas
-- Fuente: Examen.md §3.20
-- Tecnicas: EXCEPT o NOT EXISTS
-- ============================================================================
SELECT t.id, t.name AS organizacion
FROM tenants t
WHERE EXISTS (
    SELECT ps.id
    FROM phva_stages ps
    WHERE NOT EXISTS (
        SELECT tt.id
        FROM tenanttemplates tt
        WHERE tt.tenant_id = t.id
        AND tt.phva_stage_id = ps.id
    )
)
ORDER BY t.name;

-- ============================================================================
-- C.3.21 - Ultima fecha de actualizacion por organizacion (plantillas)
-- Fuente: Examen.md §3.21
-- Tecnicas: MAX(fecha)
-- ============================================================================
SELECT t.name AS organizacion,
       MAX(tt.updated_at) AS ultima_actualizacion_plantillas,
       MAX(tt.created_at) AS ultima_creacion_plantilla
FROM tenants t
INNER JOIN tenanttemplates tt ON t.id = tt.tenant_id
GROUP BY t.id, t.name
ORDER BY ultima_actualizacion_plantillas DESC NULLS LAST;

-- ============================================================================
-- C.3.22 - Organizaciones con registros documentales pendientes
--           (usando vistas materializadas)
-- Fuente: Examen.md §3.22
-- Tecnicas: Consulta sobre vistas materializadas
-- Requiere: vm_template_pesv_docs_summary, vm_template_sst_docs_summary
-- ============================================================================
SELECT COALESCE(sst.organizacion, pesv.organizacion) AS organizacion,
       sst.documentos_pendientes AS pendientes_sst,
       pesv.documentos_pendientes AS pendientes_pesv,
       COALESCE(sst.documentos_pendientes, 0) + COALESCE(pesv.documentos_pendientes, 0) AS total_pendientes
FROM vm_template_sst_docs_summary sst
FULL OUTER JOIN vm_template_pesv_docs_summary pesv
    ON sst.tenant_id = pesv.tenant_id
WHERE COALESCE(sst.documentos_pendientes, 0) > 0
   OR COALESCE(pesv.documentos_pendientes, 0) > 0
ORDER BY total_pendientes DESC, organizacion;

-- ============================================================================
-- C.3.23 - Informe consolidado: total, finalizados, borrador, no iniciados,
--           pendientes, % cumplimiento
-- Fuente: Examen.md §3.23
-- Tecnicas: CASE WHEN condicional + COUNT
-- ============================================================================
SELECT t.name AS organizacion,
       COUNT(d.id) AS total_documentos,
       COUNT(d.id) FILTER (WHERE d.status = 'finalizado') AS finalizados,
       COUNT(d.id) FILTER (WHERE d.status = 'borrador') AS borradores,
       COUNT(d.id) FILTER (WHERE d.status = 'no_iniciado') AS no_iniciados,
       COUNT(d.id) FILTER (WHERE d.status = 'pendiente') AS pendientes,
       ROUND(
           COUNT(d.id) FILTER (WHERE d.status = 'finalizado') * 100.0 /
           NULLIF(COUNT(d.id), 0),
           2
       ) AS porcentaje_cumplimiento
FROM tenants t
LEFT JOIN documents d ON t.id = d.tenant_id
GROUP BY t.id, t.name
ORDER BY t.name;

-- ============================================================================
-- C.3.24 - Comparar % cumplimiento SST vs PESV, diferencia > valor
-- Fuente: Examen.md §3.24
-- Tecnicas: Diferencia absoluta entre vistas materializadas
-- Requiere: vm_template_sst_docs_summary, vm_template_pesv_docs_summary
-- ============================================================================
SELECT COALESCE(sst.organizacion, pesv.organizacion) AS organizacion,
       sst.porcentaje_cumplimiento AS cumplimiento_sst,
       pesv.porcentaje_cumplimiento AS cumplimiento_pesv,
       ROUND(ABS(
           COALESCE(sst.porcentaje_cumplimiento, 0) -
           COALESCE(pesv.porcentaje_cumplimiento, 0)
       ), 2) AS diferencia_absoluta
FROM vm_template_sst_docs_summary sst
FULL OUTER JOIN vm_template_pesv_docs_summary pesv
    ON sst.tenant_id = pesv.tenant_id
WHERE ABS(
    COALESCE(sst.porcentaje_cumplimiento, 0) -
    COALESCE(pesv.porcentaje_cumplimiento, 0)
) > 0
ORDER BY diferencia_absoluta DESC, organizacion;

-- ============================================================================
-- C.3.25 - Vista que consolide personas, modulos, plantillas y sistemas
--           por organizacion
-- Fuente: Examen.md §3.25
-- Tecnicas: Multiples COUNT + GROUP BY
-- Definicion de la vista: sql/04_views/001_views.sql
-- ============================================================================
SELECT * FROM vw_tenant_summary ORDER BY organizacion;
