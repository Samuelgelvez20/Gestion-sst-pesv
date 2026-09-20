-- ============================================================================
-- SST-PESV: Procedimientos almacenados (15 procedimientos)
-- Sesión 3.3 — Programabilidad
-- Archivo: sql/05_programabilidad/002_procedures.sql
-- PostgreSQL 16
-- ============================================================================
-- Este archivo crea los 15 procedimientos exigidos por Examen.md §5.
-- No modificar funciones de Sesión 3.2 (001_functions.sql).
-- No modificar tablas, constraints, seed, vistas, MVs ni consultas.
-- ============================================================================

-- ============================================================================
-- P.1 — Registrar nueva organización
-- Examen.md §5 Procedimiento 1
-- Valida que no exista otra organización con los mismos datos de identificación
-- definidos por el sistema (nombre, email, teléfono).
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_create_tenant(
    p_name               varchar(200),
    p_contact_email      varchar(200),
    p_phone              varchar(30),
    p_tenant_size_id     integer,
    p_municipality_id    integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que no exista otra organización con los mismos datos de identificación
    IF EXISTS (
        SELECT 1
        FROM tenants t
        WHERE t.name = p_name
          AND t.contact_email = p_contact_email
          AND t.phone = p_phone
    ) THEN
        RAISE EXCEPTION 'Ya existe una organización con los mismos datos de identificación: name=%, email=%, phone=%',
            p_name, p_contact_email, p_phone;
    END IF;

    INSERT INTO tenants (name, contact_email, phone, tenant_size_id, municipality_id)
    VALUES (p_name, p_contact_email, p_phone, p_tenant_size_id, p_municipality_id);
END;
$$;

-- ============================================================================
-- P.2 — Registrar nueva persona y asociar a organización y cargo
-- Examen.md §5 Procedimiento 2
-- Valida que la organización exista y esté activa.
-- Valida que el cargo pertenezca a la misma organización.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_create_person(
    p_tenant_id      integer,
    p_first_name     varchar(100),
    p_last_name      varchar(100),
    p_email          varchar(200),
    p_position_id    integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tenant_active boolean;
    v_pos_tenant    integer;
BEGIN
    -- Verificar que la organización exista y esté activa
    SELECT t.is_active INTO v_tenant_active
    FROM tenants t WHERE t.id = p_tenant_id;

    IF v_tenant_active IS NULL THEN
        RAISE EXCEPTION 'La organización con id=% no existe', p_tenant_id;
    END IF;

    IF v_tenant_active = false THEN
        RAISE EXCEPTION 'No se puede registrar una persona en una organización inactiva (tenant_id=%)', p_tenant_id;
    END IF;

    -- Verificar que el cargo pertenezca a la misma organización
    SELECT pos.tenant_id INTO v_pos_tenant
    FROM positions pos WHERE pos.id = p_position_id;

    IF v_pos_tenant IS NULL THEN
        RAISE EXCEPTION 'El cargo con id=% no existe', p_position_id;
    END IF;

    IF v_pos_tenant != p_tenant_id THEN
        RAISE EXCEPTION 'El cargo id=% pertenece a la organización id=%, no a la organización id=%',
            p_position_id, v_pos_tenant, p_tenant_id;
    END IF;

    INSERT INTO persons (tenant_id, first_name, last_name, email, position_id)
    VALUES (p_tenant_id, p_first_name, p_last_name, p_email, p_position_id);
END;
$$;

-- ============================================================================
-- P.3 — Cambiar estado de organización (activo/inactivo)
-- Examen.md §5 Procedimiento 3
-- Cambia el estado de una organización entre activa e inactiva.
-- Cuando p_is_active = false, invoca la lógica de P.9 para deshabilitar
-- los módulos del tenant (RB-13: al deshabilitar organización, se
-- deshabilitan todos sus módulos).
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_toggle_tenant_status(
    p_tenant_id  integer,
    p_is_active  boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tenants
    SET is_active = p_is_active
    WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La organización con id=% no existe', p_tenant_id;
    END IF;

    -- RB-13: Al desactivar organización, invocar P.9 para eliminar módulos
    IF p_is_active = false THEN
        CALL sp_disable_tenant_modules(p_tenant_id);
    END IF;
END;
$$;

-- ============================================================================
-- P.4 — Asignar módulo a organización
-- Examen.md §5 Procedimiento 4
-- Evita asignaciones duplicadas (validación + constraint UNIQUE).
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_assign_module(
    p_tenant_id  integer,
    p_module_id  integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar que no esté ya asignado (capa de aplicación)
    IF EXISTS (
        SELECT 1
        FROM tenant_modules tm
        WHERE tm.tenant_id = p_tenant_id
          AND tm.module_id = p_module_id
    ) THEN
        RAISE EXCEPTION 'El módulo id=% ya está asignado a la organización id=%',
            p_module_id, p_tenant_id;
    END IF;

    INSERT INTO tenant_modules (tenant_id, module_id)
    VALUES (p_tenant_id, p_module_id);
END;
$$;

-- ============================================================================
-- P.5 — Habilitar sistema SST para organización
-- Examen.md §5 Procedimiento 5
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_enable_system(
    p_tenant_id           integer,
    p_type_system_sst_id  integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar que no esté ya habilitado (capa de aplicación)
    IF EXISTS (
        SELECT 1
        FROM tenantsystems ts
        WHERE ts.tenant_id = p_tenant_id
          AND ts.type_system_sst_id = p_type_system_sst_id
    ) THEN
        RAISE EXCEPTION 'El sistema SST id=% ya está habilitado para la organización id=%',
            p_type_system_sst_id, p_tenant_id;
    END IF;

    INSERT INTO tenantsystems (tenant_id, type_system_sst_id)
    VALUES (p_tenant_id, p_type_system_sst_id);
END;
$$;

-- ============================================================================
-- P.6 — Asignar plantilla a organización (versión simple)
-- Examen.md §5 Procedimiento 6
-- Versión mínima de la operación de asignación de plantilla.
-- P.15 contiene la versión robusta con manejo de excepciones.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_assign_template(
    p_tenant_id           integer,
    p_template_id         integer,
    p_type_system_sst_id  integer,
    p_phva_stage_id       integer,
    p_format_id           integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tenanttemplates
        (tenant_id, template_id, type_system_sst_id, phva_stage_id, format_id)
    VALUES
        (p_tenant_id, p_template_id, p_type_system_sst_id, p_phva_stage_id, p_format_id);
END;
$$;

-- ============================================================================
-- P.7 — Cambiar cargo de persona dentro de organización
-- Examen.md §5 Procedimiento 7
-- Valida que el nuevo cargo pertenezca a la misma organización de la persona.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_change_position(
    p_person_id       integer,
    p_new_position_id integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_person_tenant  integer;
    v_pos_tenant     integer;
BEGIN
    -- Obtener tenant de la persona
    SELECT p.tenant_id INTO v_person_tenant
    FROM persons p WHERE p.id = p_person_id;

    IF v_person_tenant IS NULL THEN
        RAISE EXCEPTION 'La persona con id=% no existe', p_person_id;
    END IF;

    -- Verificar que el cargo pertenezca a la misma organización
    SELECT pos.tenant_id INTO v_pos_tenant
    FROM positions pos WHERE pos.id = p_new_position_id;

    IF v_pos_tenant IS NULL THEN
        RAISE EXCEPTION 'El cargo con id=% no existe', p_new_position_id;
    END IF;

    IF v_pos_tenant != v_person_tenant THEN
        RAISE EXCEPTION 'El cargo id=% pertenece a la organización id=%, pero la persona id=% pertenece a la organización id=%',
            p_new_position_id, v_pos_tenant, p_person_id, v_person_tenant;
    END IF;

    UPDATE persons
    SET position_id = p_new_position_id
    WHERE id = p_person_id;
END;
$$;

-- ============================================================================
-- P.8 — Trasladar persona de una organización a otra
-- Examen.md §5 Procedimiento 8
-- Actualiza tenant_id al tenant destino.
-- Establece position_id = NULL porque el cargo pertenece al tenant origen
-- y no debe conservarse.
-- DECISIÓN CERRADA (Sesión 3.1): position_id = NULL al trasladar.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_transfer_person(
    p_person_id       integer,
    p_new_tenant_id   integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_tenant integer;
BEGIN
    -- Verificar que la persona exista
    SELECT p.tenant_id INTO v_current_tenant
    FROM persons p WHERE p.id = p_person_id;

    IF v_current_tenant IS NULL THEN
        RAISE EXCEPTION 'La persona con id=% no existe', p_person_id;
    END IF;

    -- Verificar que el tenant destino exista
    IF NOT EXISTS (SELECT 1 FROM tenants t WHERE t.id = p_new_tenant_id) THEN
        RAISE EXCEPTION 'La organización destino con id=% no existe', p_new_tenant_id;
    END IF;

    -- Trasladar: cambiar tenant_id y establecer position_id = NULL
    UPDATE persons
    SET tenant_id   = p_new_tenant_id,
        position_id = NULL
    WHERE id = p_person_id;
END;
$$;

-- ============================================================================
-- P.9 — Deshabilitar todos los módulos de organización inactiva
-- Examen.md §5 Procedimiento 9
-- Elimina DEFINITIVAMENTE las asignaciones de módulos de la tabla
-- tenant_modules (no existe columna is_active en esta tabla).
-- Consecuencias:
--   - La operación es destructiva: los registros se eliminan permanentemente.
--   - Reactivar el tenant (P.3 con p_is_active = true) NO restaura módulos.
--   - Para volver a asignar módulos se debe utilizar P.4 (sp_assign_module).
-- Esta lógica también es invocada por P.3 al desactivar una organización.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_disable_tenant_modules(
    p_tenant_id integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM tenant_modules
    WHERE tenant_id = p_tenant_id;
END;
$$;

-- ============================================================================
-- P.10 — Eliminar asignación de módulo de manera controlada
-- Examen.md §5 Procedimiento 10
-- Valida que no existan registros dependientes antes de eliminar.
--
-- DECISIÓN DE DISEÑO: La dependencia entre tenanttemplates y modules se
-- verifica a través de la cadena de FK real:
--   tenanttemplates.format_id → formats_sst.id → formats_sst.module_id → modules.id
-- Una plantilla con format_id IS NULL no tiene dependencia de módulo por
-- esta ruta y no bloquea la eliminación.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_remove_module(
    p_tenant_id  integer,
    p_module_id  integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar que la asignación exista
    IF NOT EXISTS (
        SELECT 1
        FROM tenant_modules tm
        WHERE tm.tenant_id = p_tenant_id
          AND tm.module_id = p_module_id
    ) THEN
        RAISE EXCEPTION 'El módulo id=% no está asignado a la organización id=%',
            p_module_id, p_tenant_id;
    END IF;

    -- DECISIÓN DE DISEÑO: Validar dependencias reales a través de format_id.
    -- Solo bloquea si existe una tenanttemplate cuyo format_id referencia un
    -- formats_sst cuyo module_id coincide con el módulo a eliminar.
    IF EXISTS (
        SELECT 1
        FROM tenanttemplates tt
        JOIN formats_sst fs ON fs.id = tt.format_id
        WHERE tt.tenant_id = p_tenant_id
          AND fs.module_id = p_module_id
    ) THEN
        RAISE EXCEPTION 'No se puede eliminar el módulo id=%: existen plantillas con formatos dependientes de este módulo en la organización id=%',
            p_module_id, p_tenant_id;
    END IF;

    DELETE FROM tenant_modules
    WHERE tenant_id = p_tenant_id
      AND module_id = p_module_id;
END;
$$;

-- ============================================================================
-- P.11 — Contar plantillas de organización (RAISE NOTICE)
-- Examen.md §5 Procedimiento 11
-- Muestra el total mediante RAISE NOTICE.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_count_templates(
    p_tenant_id integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total integer;
BEGIN
    SELECT COUNT(*)::integer INTO v_total
    FROM tenanttemplates tt
    WHERE tt.tenant_id = p_tenant_id;

    RAISE NOTICE 'Organización id=%: total de plantillas = %', p_tenant_id, v_total;
END;
$$;

-- ============================================================================
-- P.12 — Calcular porcentaje de cumplimiento documental
-- Examen.md §5 Procedimiento 12
-- Reutiliza fn_tenant_compliance_pct de Sesión 3.2.
-- Muestra el resultado mediante RAISE NOTICE.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_compliance_pct(
    p_tenant_id integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_pct numeric;
BEGIN
    v_pct := fn_tenant_compliance_pct(p_tenant_id);

    IF v_pct IS NULL THEN
        RAISE NOTICE 'Organización id=%: no tiene documentos registrados', p_tenant_id;
    ELSE
        RAISE NOTICE 'Organización id=%: porcentaje de cumplimiento = %', p_tenant_id, v_pct || '%';
    END IF;
END;
$$;

-- ============================================================================
-- P.13 — Contar documentos de organización por etapa PHVA
-- Examen.md §5 Procedimiento 13
-- Recibe una organización y una etapa PHVA, determina la cantidad de
-- documentos correspondientes a dicha etapa.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_count_documents_by_phva(
    p_tenant_id       integer,
    p_phva_stage_id   integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total integer;
BEGIN
    SELECT COUNT(*)::integer INTO v_total
    FROM documents d
    JOIN tenanttemplates tt ON d.tenanttemplate_id = tt.id
    WHERE d.tenant_id = p_tenant_id
      AND tt.phva_stage_id = p_phva_stage_id;

    RAISE NOTICE 'Organización id=%, etapa PHVA id=%: total de documentos = %',
        p_tenant_id, p_phva_stage_id, v_total;
END;
$$;

-- ============================================================================
-- P.14 — Modificar datos de contacto de organización
-- Examen.md §5 Procedimiento 14
-- Modifica simultáneamente los datos de contacto y registra la fecha
-- de actualización (updated_at).
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_update_tenant_contact(
    p_tenant_id       integer,
    p_contact_email   varchar(200),
    p_phone           varchar(30)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tenants
    SET contact_email = p_contact_email,
        phone         = p_phone,
        updated_at    = now()
    WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La organización con id=% no existe', p_tenant_id;
    END IF;
END;
$$;

-- ============================================================================
-- P.15 — Asignar plantilla con manejo de excepciones (versión robusta)
-- Examen.md §5 Procedimiento 15
-- Versión robusta de P.6, incorporando manejo explícito de excepciones
-- BEGIN/EXCEPTION/END para controlar cualquier error durante la operación.
-- No duplica la lógica de P.6; encapsula la misma operación con EXCEPTION.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_assign_template_safe(
    p_tenant_id           integer,
    p_template_id         integer,
    p_type_system_sst_id  integer,
    p_phva_stage_id       integer,
    p_format_id           integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tenanttemplates
        (tenant_id, template_id, type_system_sst_id, phva_stage_id, format_id)
    VALUES
        (p_tenant_id, p_template_id, p_type_system_sst_id, p_phva_stage_id, p_format_id);

    RAISE NOTICE 'Plantilla asignada exitosamente: tenant=%, template=%, sistema=%, phva=%',
        p_tenant_id, p_template_id, p_type_system_sst_id, p_phva_stage_id;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Error al asignar plantilla: ya existe una asignación idéntica para la organización id=%, plantilla id=%, sistema id=%, etapa PHVA id=%',
            p_tenant_id, p_template_id, p_type_system_sst_id, p_phva_stage_id;
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Error al asignar plantilla: uno de los IDs proporcionados no existe (tenant=%, template=%, sistema=%, phva=%, formato=%)',
            p_tenant_id, p_template_id, p_type_system_sst_id, p_phva_stage_id, p_format_id;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inesperado al asignar plantilla: %', SQLERRM;
END;
$$;
