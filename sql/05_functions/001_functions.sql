-- ============================================================================
-- SST-PESV: Funciones almacenadas (8 funciones)
-- Sesión 3.2 — Programabilidad
-- Archivo: sql/05_functions/001_functions.sql
-- PostgreSQL 16
-- ============================================================================
-- Este archivo crea las 8 funciones exigidas por Examen.md §6.
-- No crear procedimientos, triggers ni tablas auxiliares.
-- ============================================================================

-- ============================================================================
-- F.1 — Contar personas de una organización
-- Examen.md §6 Función 1
-- Recibe tenant_id, retorna INTEGER con el total de personas
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_tenant_person_count(
    p_tenant_id integer
)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
    SELECT COUNT(p.id)::integer
    FROM persons p
    WHERE p.tenant_id = p_tenant_id;
$$;

-- ============================================================================
-- F.2 — Porcentaje de cumplimiento documental
-- Examen.md §6 Función 2
-- Calcula: documentos finalizados / total documentos * 100
-- Retorna NUMERIC. Retorna NULL cuando no existen documentos.
-- Coherente con vm_compliance_summary y C.3.10
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_tenant_compliance_pct(
    p_tenant_id integer
)
RETURNS numeric
LANGUAGE sql
STABLE
AS $$
    SELECT ROUND(
        COUNT(d.id) FILTER (WHERE d.status = 'finalizado') * 100.0 /
        NULLIF(COUNT(d.id), 0),
        2
    )
    FROM documents d
    WHERE d.tenant_id = p_tenant_id;
$$;

-- ============================================================================
-- F.3 — Verificar si una organización tiene un módulo habilitado
-- Examen.md §6 Función 3
-- Recibe tenant_id y module_id, retorna BOOLEAN
-- Usa EXISTS para eficiencia
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_tenant_has_module(
    p_tenant_id integer,
    p_module_id integer
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM tenant_modules tm
        WHERE tm.tenant_id = p_tenant_id
          AND tm.module_id = p_module_id
    );
$$;

-- ============================================================================
-- F.4 — Nombre completo de una persona
-- Examen.md §6 Función 4
-- Recibe person_id, retorna TEXT con first_name + ' ' + last_name
-- Si la persona no existe, retorna NULL
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_person_full_name(
    p_person_id integer
)
RETURNS text
LANGUAGE sql
STABLE
AS $$
    SELECT p.first_name || ' ' || p.last_name
    FROM persons p
    WHERE p.id = p_person_id;
$$;

-- ============================================================================
-- F.5 — Cantidad de plantillas por organización y etapa PHVA
-- Examen.md §6 Función 5
-- Recibe tenant_id y phva_stage_id, retorna INTEGER
-- Retorna 0 cuando no existen plantillas para la combinación
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_tenant_templates_by_phva(
    p_tenant_id integer,
    p_phva_stage_id integer
)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
    SELECT COUNT(tt.id)::integer
    FROM tenanttemplates tt
    WHERE tt.tenant_id = p_tenant_id
      AND tt.phva_stage_id = p_phva_stage_id;
$$;

-- ============================================================================
-- F.6 — Módulos habilitados para una organización (TABULAR)
-- Examen.md §6 Función 6
-- Retorna TABLE con columnas reales de modules
-- Filtra por tenant_id, ordena por sort_order
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_tenant_modules_list(
    p_tenant_id integer
)
RETURNS TABLE (
    id integer,
    title varchar(150),
    description text,
    sort_order integer,
    type_system_sst_id integer
)
LANGUAGE sql
STABLE
AS $$
    SELECT m.id, m.title, m.description, m.sort_order, m.type_system_sst_id
    FROM modules m
    JOIN tenant_modules tm ON m.id = tm.module_id
    WHERE tm.tenant_id = p_tenant_id
    ORDER BY m.sort_order;
$$;

-- ============================================================================
-- F.7 — Personas de una organización con cargos (TABULAR)
-- Examen.md §6 Función 7
-- Retorna TABLE con person_id, first_name, last_name, position_description
-- Filtra por persons.tenant_id
-- Si una persona no tiene cargo, position_description es NULL
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_tenant_persons_list(
    p_tenant_id integer
)
RETURNS TABLE (
    person_id integer,
    first_name varchar(100),
    last_name varchar(100),
    position_description varchar(150)
)
LANGUAGE sql
STABLE
AS $$
    SELECT p.id, p.first_name, p.last_name, pos.description
    FROM persons p
    LEFT JOIN positions pos ON p.position_id = pos.id
    WHERE p.tenant_id = p_tenant_id
    ORDER BY p.last_name, p.first_name;
$$;

-- ============================================================================
-- F.8 — Clasificar nivel de cumplimiento文档al
-- Examen.md §6 Función 8
-- Recibe tenant_id, calcula porcentaje internamente
-- Umbrales: < 30 → bajo, < 60 → medio, >= 60 → alto
-- Coherente con C.3.12 (avanzadas.sql)
-- Si no existen documentos, retorna 'bajo' (consistente con F.2 = 0)
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_tenant_compliance_class(
    p_tenant_id integer
)
RETURNS text
LANGUAGE sql
STABLE
AS $$
    SELECT CASE
        WHEN pct IS NULL THEN 'bajo'
        WHEN pct < 30 THEN 'bajo'
        WHEN pct < 60 THEN 'medio'
        ELSE 'alto'
    END
    FROM fn_tenant_compliance_pct(p_tenant_id) AS pct;
$$;
