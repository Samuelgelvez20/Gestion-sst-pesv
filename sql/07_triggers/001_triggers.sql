-- ============================================================================
-- SST-PESV: Triggers (15 triggers)
-- Sesión 3.4 — Programabilidad
-- Archivo: sql/07_triggers/001_triggers.sql
-- PostgreSQL 16
-- ============================================================================
-- Este archivo crea las 15 funciones trigger y sus vínculos (TRIGGER ON)
-- exigidos por Examen.md §7.
-- Ejecutar después de:
--   001_create_tables.sql, 002_foreign_keys.sql, 003_constraints.sql,
--   004_indexes.sql, sql/05_functions/001_functions.sql, sql/06_procedures/001_procedures.sql,
--   005_alter_tenanttemplates.sql
-- ============================================================================

-- ============================================================================
-- T1 — Actualizar updated_at en tenants
-- Examen.md §7 Trigger 1
-- BEFORE UPDATE para evitar UPDATE recursivo
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_tenants_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tenants_updated_at
    BEFORE UPDATE ON tenants
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_tenants_updated_at();

-- ============================================================================
-- T2 — Actualizar updated_at en persons
-- Examen.md §7 Trigger 2
-- BEFORE UPDATE para evitar UPDATE recursivo
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_persons_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_persons_updated_at
    BEFORE UPDATE ON persons
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_persons_updated_at();

-- ============================================================================
-- T3 — Impedir persona en tenant inactivo
-- Examen.md §7 Trigger 3
-- BEFORE INSERT: valida que tenants.is_active = true
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_persons_tenant_active()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active boolean;
BEGIN
    SELECT t.is_active INTO v_is_active
    FROM tenants t
    WHERE t.id = NEW.tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La organización id=% no existe', NEW.tenant_id;
    END IF;

    IF NOT v_is_active THEN
        RAISE EXCEPTION 'No se puede registrar personas en una organización inactiva (organización id=%)', NEW.tenant_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_persons_tenant_active
    BEFORE INSERT ON persons
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_persons_tenant_active();

-- ============================================================================
-- T4 — Impedir módulo duplicado en tenant
-- Examen.md §7 Trigger 4
-- BEFORE INSERT: valida que no exista la combinación (tenant_id, module_id)
-- Coexiste con UNIQUE (tenant_id, module_id) como capa complementaria.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_tenant_modules_no_duplicate()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM tenant_modules tm
        WHERE tm.tenant_id = NEW.tenant_id
          AND tm.module_id = NEW.module_id
    ) THEN
        RAISE EXCEPTION 'El módulo id=% ya está asignado a la organización id=%',
            NEW.module_id, NEW.tenant_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tenant_modules_no_duplicate
    BEFORE INSERT ON tenant_modules
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_tenant_modules_no_duplicate();

-- ============================================================================
-- T5 — Impedir template en tenant inactivo
-- Examen.md §7 Trigger 5
-- BEFORE INSERT: valida que tenants.is_active = true
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_tenanttemplates_tenant_active()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active boolean;
BEGIN
    SELECT t.is_active INTO v_is_active
    FROM tenants t
    WHERE t.id = NEW.tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La organización id=% no existe', NEW.tenant_id;
    END IF;

    IF NOT v_is_active THEN
        RAISE EXCEPTION 'No se pueden asignar plantillas a una organización inactiva (organización id=%)', NEW.tenant_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tenanttemplates_tenant_active
    BEFORE INSERT ON tenanttemplates
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_tenanttemplates_tenant_active();

-- ============================================================================
-- T6 — Validar que la posición pertenezca al mismo tenant
-- Examen.md §7 Trigger 6
-- BEFORE INSERT OR UPDATE: si position_id IS NOT NULL, valida que
-- positions.tenant_id = NEW.tenant_id
-- Si position_id IS NULL, permite la operación.
-- Compatible con P.8 (sp_transfer_person) que deja position_id = NULL.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_persons_position_same_tenant()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_position_tenant integer;
BEGIN
    IF NEW.position_id IS NOT NULL THEN
        SELECT p.tenant_id INTO v_position_tenant
        FROM positions p
        WHERE p.id = NEW.position_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'El cargo id=% no existe', NEW.position_id;
        END IF;

        IF v_position_tenant != NEW.tenant_id THEN
            RAISE EXCEPTION 'El cargo id=% pertenece a la organización id=%, no a la organización id=%',
                NEW.position_id, v_position_tenant, NEW.tenant_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_persons_position_same_tenant
    BEFORE INSERT OR UPDATE ON persons
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_persons_position_same_tenant();

-- ============================================================================
-- T7 — Actualizar updated_at en tenanttemplates
-- Examen.md §7 Trigger 7
-- BEFORE UPDATE para evitar UPDATE recursivo
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_tenanttemplates_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tenanttemplates_updated_at
    BEFORE UPDATE ON tenanttemplates
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_tenanttemplates_updated_at();

-- ============================================================================
-- T8 — Impedir eliminar tenant con personas
-- Examen.md §7 Trigger 8
-- BEFORE DELETE: valida que no existan personas asociadas
-- Coexiste con FK persons.tenant_id RESTRICT como capa complementaria.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_tenants_no_delete_with_persons()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM persons p
    WHERE p.tenant_id = OLD.id;

    IF v_count > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar la organización id=%: tiene % persona(s) asociada(s)',
            OLD.id, v_count;
    END IF;

    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_tenants_no_delete_with_persons
    BEFORE DELETE ON tenants
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_tenants_no_delete_with_persons();

-- ============================================================================
-- T9 — Impedir eliminar sistema SST en uso
-- Examen.md §7 Trigger 9
-- BEFORE DELETE: valida que no existan tenantsystems que lo referencien
-- Coexiste con FK tenantsystems.type_system_sst_id RESTRICT.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_type_system_sst_no_delete_in_use()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM tenantsystems ts
    WHERE ts.type_system_sst_id = OLD.id;

    IF v_count > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar el sistema SST id=%: está sendo utilizado por % organización(es)',
            OLD.id, v_count;
    END IF;

    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_type_system_sst_no_delete_in_use
    BEFORE DELETE ON type_system_sst
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_type_system_sst_no_delete_in_use();

-- ============================================================================
-- T10 — Impedir eliminar módulo asignado
-- Examen.md §7 Trigger 10
-- BEFORE DELETE: valida que no existan tenant_modules que lo referencien
-- Coexiste con FK tenant_modules.module_id RESTRICT.
-- Distinto de P.10: T10 protege la eliminación del módulo GLOBAL;
-- P.10 elimina la asignación de un módulo a un tenant específico.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_modules_no_delete_assigned()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM tenant_modules tm
    WHERE tm.module_id = OLD.id;

    IF v_count > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar el módulo id=%: está asignado a % organización(es)',
            OLD.id, v_count;
    END IF;

    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_modules_no_delete_assigned
    BEFORE DELETE ON modules
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_modules_no_delete_assigned();

-- ============================================================================
-- T11 — Validar % cumplimiento entre 0 y 100
-- Examen.md §7 Trigger 11
-- BEFORE INSERT OR UPDATE OR DELETE ON documents
-- Utiliza fn_tenant_compliance_pct() para calcular el porcentaje.
-- Si la función retorna NULL (sin documentos), permite la operación.
--
-- NOTA: La fórmula finalizados * 100.0 / total matemáticamente produce
-- siempre un valor entre 0 y 100, porque los finalizados son un subconjunto
-- del total. Con el modelo y fórmula actuales, este trigger funciona como
-- salvaguarda/documentación de la regla del examen y no tiene un escenario
-- normal en el que falle por superar los límites.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_documents_validate_compliance()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_tenant_id integer;
    v_pct numeric;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_tenant_id := OLD.tenant_id;
    ELSE
        v_tenant_id := NEW.tenant_id;
    END IF;

    v_pct := fn_tenant_compliance_pct(v_tenant_id);

    IF v_pct IS NOT NULL AND (v_pct < 0 OR v_pct > 100) THEN
        RAISE EXCEPTION 'El porcentaje de cumplimiento (%) de la organización id=% está fuera del rango 0-100',
            v_pct, v_tenant_id;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

CREATE TRIGGER trg_documents_validate_compliance
    BEFORE INSERT OR UPDATE OR DELETE ON documents
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_documents_validate_compliance();

-- ============================================================================
-- T12 — Auditoría de modificaciones en tenants
-- Examen.md §7 Trigger 12
-- AFTER UPDATE: registra cualquier modificación en audit_log
-- Utiliza current_setting('app.current_user', true) para changed_by.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_tenants_audit_general()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO audit_log (
        tenant_id, table_name, record_id, action,
        old_values, new_values, changed_by
    ) VALUES (
        OLD.id, 'tenants', OLD.id, 'UPDATE',
        to_jsonb(OLD), to_jsonb(NEW),
        current_setting('app.current_user', true)
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tenants_audit_general
    AFTER UPDATE ON tenants
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_tenants_audit_general();

-- ============================================================================
-- T13 — Auditoría específica de cambio de estado en tenants
-- Examen.md §7 Trigger 13
-- AFTER UPDATE OF is_active: solo se dispara cuando is_active realmente cambia
-- Genera una entrada independiente en audit_log (separada de T12).
-- WHEN (OLD.is_active IS DISTINCT FROM NEW.is_active) evita auditorías falsas.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_tenants_audit_status_change()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO audit_log (
        tenant_id, table_name, record_id, action,
        old_values, new_values, changed_by
    ) VALUES (
        OLD.id, 'tenants', OLD.id, 'UPDATE',
        jsonb_build_object('is_active', OLD.is_active),
        jsonb_build_object('is_active', NEW.is_active),
        current_setting('app.current_user', true)
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tenants_audit_status_change
    AFTER UPDATE OF is_active ON tenants
    FOR EACH ROW
    WHEN (OLD.is_active IS DISTINCT FROM NEW.is_active)
    EXECUTE FUNCTION fn_trg_tenants_audit_status_change();

-- ============================================================================
-- T14 — Registrar modified_by en tenanttemplates
-- Examen.md §7 Trigger 14
-- BEFORE UPDATE: establece modified_by con el usuario de sesión
-- Utiliza current_setting('app.current_user', true).
-- Si el setting no está configurado, modified_by queda NULL.
-- Mantenido separado de T7 (que actualiza updated_at).
-- Requiere columna tenanttemplates.modified_by (005_alter_tenanttemplates.sql).
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_tenanttemplates_modified_by()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.modified_by := current_setting('app.current_user', true);
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tenanttemplates_modified_by
    BEFORE UPDATE ON tenanttemplates
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_tenanttemplates_modified_by();

-- ============================================================================
-- T15 — Limpiar editing_locks expirados
-- Examen.md §7 Trigger 15
-- AFTER INSERT OR UPDATE: elimina locks con expires_at < CURRENT_TIMESTAMP
-- No elimina locks con expires_at IS NULL (no se consideran expirados).
-- La limpieza global (todos los tenants) es intencional.
-- No se agrega columna active; se usa DELETE físico.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_trg_editing_locks_cleanup_expired()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM editing_locks
    WHERE expires_at < CURRENT_TIMESTAMP;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_editing_locks_cleanup_expired
    AFTER INSERT OR UPDATE ON editing_locks
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_editing_locks_cleanup_expired();
