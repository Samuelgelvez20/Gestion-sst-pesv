-- ============================================================================
-- SST-PESV: Datos de prueba (Seed)
-- Sesión 2.2 — Datos de prueba
-- Archivo: sql/02_seed/001_seed_data.sql
-- PostgreSQL 16
-- ============================================================================
-- Este archivo inserta datos de prueba suficientes para probar:
-- - 68 consultas (15 básicas + 20 intermedias + 25 avanzadas + 8 vistas)
-- - 15 procedimientos
-- - 8 funciones
-- - 15 triggers
-- - 5 vistas + 3 vistas materializadas
--
-- Orden de inserción: catálogos → tenants → dependientes
-- Usa RETURNING para obtener IDs y mantener consistencia.
-- ============================================================================

-- ============================================================================
-- 1. CATÁLOGOS GLOBALES
-- ============================================================================

-- 1.1 countries (5)
INSERT INTO countries (name) VALUES
    ('Colombia'),
    ('México'),
    ('Argentina'),
    ('Chile'),
    ('Perú');

-- 1.2 departments (Colombia: 4, México: 3, Argentina: 2, Chile: 1, Perú: 1)
INSERT INTO departments (country_id, name) VALUES
    -- Colombia
    ((SELECT id FROM countries WHERE name = 'Colombia'), 'Cundinamarca'),
    ((SELECT id FROM countries WHERE name = 'Colombia'), 'Antioquia'),
    ((SELECT id FROM countries WHERE name = 'Colombia'), 'Valle del Cauca'),
    ((SELECT id FROM countries WHERE name = 'Colombia'), 'Atlántico'),
    -- México
    ((SELECT id FROM countries WHERE name = 'México'), 'Ciudad de México'),
    ((SELECT id FROM countries WHERE name = 'México'), 'Jalisco'),
    ((SELECT id FROM countries WHERE name = 'México'), 'Nuevo León'),
    -- Argentina
    ((SELECT id FROM countries WHERE name = 'Argentina'), 'Buenos Aires'),
    ((SELECT id FROM countries WHERE name = 'Argentina'), 'Córdoba'),
    -- Chile
    ((SELECT id FROM countries WHERE name = 'Chile'), 'Región Metropolitana'),
    -- Perú
    ((SELECT id FROM countries WHERE name = 'Perú'), 'Lima');

-- 1.3 municipalities (18)
INSERT INTO municipalities (department_id, name) VALUES
    -- Cundinamarca
    ((SELECT id FROM departments WHERE name = 'Cundinamarca'), 'Bogotá'),
    ((SELECT id FROM departments WHERE name = 'Cundinamarca'), 'Soacha'),
    -- Antioquia
    ((SELECT id FROM departments WHERE name = 'Antioquia'), 'Medellín'),
    ((SELECT id FROM departments WHERE name = 'Antioquia'), 'Envigado'),
    -- Valle del Cauca
    ((SELECT id FROM departments WHERE name = 'Valle del Cauca'), 'Cali'),
    ((SELECT id FROM departments WHERE name = 'Valle del Cauca'), 'Palmira'),
    -- Atlántico
    ((SELECT id FROM departments WHERE name = 'Atlántico'), 'Barranquilla'),
    -- Ciudad de México
    ((SELECT id FROM departments WHERE name = 'Ciudad de México'), 'Ciudad de México'),
    -- Jalisco
    ((SELECT id FROM departments WHERE name = 'Jalisco'), 'Guadalajara'),
    ((SELECT id FROM departments WHERE name = 'Jalisco'), 'Zapopan'),
    -- Nuevo León
    ((SELECT id FROM departments WHERE name = 'Nuevo León'), 'Monterrey'),
    ((SELECT id FROM departments WHERE name = 'Nuevo León'), 'San Pedro Garza García'),
    -- Buenos Aires
    ((SELECT id FROM departments WHERE name = 'Buenos Aires'), 'Ciudad Autónoma de Buenos Aires'),
    ((SELECT id FROM departments WHERE name = 'Buenos Aires'), 'La Plata'),
    -- Córdoba
    ((SELECT id FROM departments WHERE name = 'Córdoba'), 'Córdoba Capital'),
    -- Región Metropolitana
    ((SELECT id FROM departments WHERE name = 'Región Metropolitana'), 'Santiago'),
    -- Lima
    ((SELECT id FROM departments WHERE name = 'Lima'), 'Lima Metropolitana'),
    ((SELECT id FROM departments WHERE name = 'Lima'), 'Miraflores');

-- 1.4 tenant_sizes (4)
INSERT INTO tenant_sizes (name) VALUES
    ('Micro'),
    ('Pequeña'),
    ('Mediana'),
    ('Grande');

-- 1.5 type_system_sst (4)
INSERT INTO type_system_sst (name) VALUES
    ('Sistema de Gestión de Seguridad y Salud en el Trabajo'),
    ('Sistema de Gestión de Seguridad Vial'),
    ('Sistema Integrado de Gestión'),
    ('Sistema de Gestión Ambiental');

-- 1.6 phva_stages (4) — siempre las mismas 4
INSERT INTO phva_stages (code, name) VALUES
    ('P', 'Planear'),
    ('H', 'Hacer'),
    ('V', 'Verificar'),
    ('A', 'Actuar');

-- 1.7 modules (8)
INSERT INTO modules (title, description, sort_order, type_system_sst_id) VALUES
    ('Identificación de peligros', 'Proceso de identificación de peligros y evaluación de riesgos', 1,
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo')),
    ('Evaluación de riesgos', 'Evaluación y jerarquización de riesgos laborales', 2,
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo')),
    ('Medidas de control', 'Implementación de medidas de control para riesgos identificados', 3,
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo')),
    ('Plan de seguridad vial', 'Desarrollo del plan estratégico de seguridad vial', 1,
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial')),
    ('Gestión del tránsito', 'Control y monitoreo del tránsito terrestre', 2,
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial')),
    ('Indicadores de gestión', 'Seguimiento de indicadores clave de desempeño', 1,
        (SELECT id FROM type_system_sst WHERE name = 'Sistema Integrado de Gestión')),
    ('Auditorías internas', 'Planeación y ejecución de auditorías internas', 2,
        (SELECT id FROM type_system_sst WHERE name = 'Sistema Integrado de Gestión')),
    ('Gestión ambiental', 'Control de impactos ambientales', 1,
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión Ambiental'));

-- 1.8 formats_sst (10)
INSERT INTO formats_sst (module_id, name) VALUES
    ((SELECT id FROM modules WHERE title = 'Identificación de peligros'), 'Formato Matriz de Identificación de Peligros'),
    ((SELECT id FROM modules WHERE title = 'Identificación de peligros'), 'Formato Lista de Verificación de Peligros'),
    ((SELECT id FROM modules WHERE title = 'Evaluación de riesgos'), 'Formato Matriz de Evaluación de Riesgos'),
    ((SELECT id FROM modules WHERE title = 'Medidas de control'), 'Formato Plan de Acción'),
    ((SELECT id FROM modules WHERE title = 'Plan de seguridad vial'), 'Formato Plan Estratégico PESV'),
    ((SELECT id FROM modules WHERE title = 'Plan de seguridad vial'), 'Formato Cronograma de Actividades'),
    ((SELECT id FROM modules WHERE title = 'Gestión del tránsito'), 'Formato Registro de Vehículos'),
    ((SELECT id FROM modules WHERE title = 'Indicadores de gestión'), 'Formato Tablero de Indicadores'),
    ((SELECT id FROM modules WHERE title = 'Auditorías internas'), 'Formato Checklist de Auditoría'),
    ((SELECT id FROM modules WHERE title = 'Gestión ambiental'), 'Formato Estudio de Impacto Ambiental');

-- 1.9 templates (8)
INSERT INTO templates (name, description) VALUES
    ('Política de SST', 'Documento de política de seguridad y salud en el trabajo'),
    ('Procedimiento de Emergencias', 'Procedimiento para respuesta a emergencias'),
    ('Manual de seguridad vial', 'Manual de procedimientos de seguridad vial'),
    ('Formato de capacitación', 'Registro de capacitaciones realizadas'),
    ('Plan de contingencia', 'Plan de contingencia ante emergencias'),
    ('Informe de auditoría', 'Formato para informes de auditoría interna'),
    ('Registro de incidentes', 'Formato para registro de incidentes'),
    ('Indicadores de cumplimiento', 'Formato para seguimiento de indicadores');

-- ============================================================================
-- 2. TENANTS (4 organizaciones)
-- ============================================================================

INSERT INTO tenants (name, contact_email, phone, tenant_size_id, municipality_id, is_active, created_at) VALUES
    ('Empresa ABC S.A.S.', 'contacto@empresaabc.com', '+57 1 234 5678',
        (SELECT id FROM tenant_sizes WHERE name = 'Grande'),
        (SELECT id FROM municipalities WHERE name = 'Bogotá'),
        true, '2024-01-15 10:00:00-05'),

    ('Constructora Delta Ltda.', 'info@constructoradelta.com', '+57 2 345 6789',
        (SELECT id FROM tenant_sizes WHERE name = 'Mediana'),
        (SELECT id FROM municipalities WHERE name = 'Medellín'),
        true, '2024-03-20 14:30:00-05'),

    ('Transportes Rápidos S.A.', 'admin@transportesrapidos.com', '+52 55 1234 5678',
        (SELECT id FROM tenant_sizes WHERE name = 'Pequeña'),
        (SELECT id FROM municipalities WHERE name = 'Ciudad de México'),
        false, '2024-06-10 09:15:00-06'),

    ('Minera Sur SpA.', 'seguridad@minerasur.cl', '+56 2 2345 6789',
        (SELECT id FROM tenant_sizes WHERE name = 'Grande'),
        (SELECT id FROM municipalities WHERE name = 'Santiago'),
        true, '2024-09-01 11:00:00-04');

-- ============================================================================
-- 3. POSITIONS (por tenant)
-- ============================================================================

-- Tenant 1: Empresa ABC
INSERT INTO positions (tenant_id, description) VALUES
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Gerente de SST'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Coordinador de Seguridad'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Trabajador Operativo'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Auxiliar Administrativo');

-- Tenant 2: Constructora Delta
INSERT INTO positions (tenant_id, description) VALUES
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Jefe de Seguridad'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Operario de Construcción'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Ingeniero de Proyectos');

-- Tenant 3: Transportes Rápidos
INSERT INTO positions (tenant_id, description) VALUES
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'), 'Director de Operaciones'),
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'), 'Conductor'),
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'), 'Mecánico');

-- Tenant 4: Minera Sur
INSERT INTO positions (tenant_id, description) VALUES
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Superintendente de Seguridad'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Técnico de Seguridad'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Operario de Mina');

-- ============================================================================
-- 4. PERSONS (24 personas distribuidas)
-- ============================================================================

-- Tenant 1: Empresa ABC (7 personas)
INSERT INTO persons (tenant_id, first_name, last_name, email, position_id, is_active, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Carlos', 'Ramírez', 'carlos.ramirez@empresaabc.com',
        (SELECT id FROM positions WHERE description = 'Gerente de SST' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')),
        true, '2024-01-20 08:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'María', 'López', 'maria.lopez@empresaabc.com',
        (SELECT id FROM positions WHERE description = 'Coordinador de Seguridad' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')),
        true, '2024-02-10 09:30:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Juan', 'García', 'juan.garcia@empresaabc.com',
        (SELECT id FROM positions WHERE description = 'Trabajador Operativo' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')),
        true, '2024-03-05 07:45:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Ana', 'Martínez', 'ana.martinez@empresaabc.com',
        (SELECT id FROM positions WHERE description = 'Auxiliar Administrativo' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')),
        true, '2024-04-12 10:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Pedro', 'Sánchez', 'pedro.sanchez@empresaabc.com',
        (SELECT id FROM positions WHERE description = 'Trabajador Operativo' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')),
        true, '2024-05-18 08:15:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Laura', 'Hernández', 'laura.hernandez@empresaabc.com',
        (SELECT id FROM positions WHERE description = 'Coordinador de Seguridad' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')),
        true, '2024-06-22 14:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Roberto', 'Díaz', 'roberto.diaz@empresaabc.com',
        (SELECT id FROM positions WHERE description = 'Trabajador Operativo' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')),
        true, '2024-07-30 09:00:00-05');

-- Tenant 2: Constructora Delta (6 personas)
INSERT INTO persons (tenant_id, first_name, last_name, email, position_id, is_active, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Sandra', 'Ospina', 'sandra.ospina@constructoradelta.com',
        (SELECT id FROM positions WHERE description = 'Jefe de Seguridad' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')),
        true, '2024-03-25 08:30:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Andrés', 'Moreno', 'andres.moreno@constructoradelta.com',
        (SELECT id FROM positions WHERE description = 'Operario de Construcción' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')),
        true, '2024-04-05 07:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Diana', 'Castro', 'diana.castro@constructoradelta.com',
        (SELECT id FROM positions WHERE description = 'Ingeniero de Proyectos' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')),
        true, '2024-05-10 09:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Luis', 'Gómez', 'luis.gomez@constructoradelta.com',
        (SELECT id FROM positions WHERE description = 'Operario de Construcción' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')),
        true, '2024-06-15 07:30:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Camila', 'Restrepo', 'camila.restrepo@constructoradelta.com',
        (SELECT id FROM positions WHERE description = 'Jefe de Seguridad' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')),
        true, '2024-07-20 10:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Fernando', 'Vásquez', 'fernando.vasquez@constructoradelta.com',
        (SELECT id FROM positions WHERE description = 'Operario de Construcción' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')),
        true, '2024-08-25 08:00:00-05');

-- Tenant 3: Transportes Rápidos (0 personas — tenant inactivo sin personas)
-- intentionally empty: tenant inactive, no persons

-- Tenant 4: Minera Sur (6 personas)
INSERT INTO persons (tenant_id, first_name, last_name, email, position_id, is_active, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Roberto', 'Fernández', 'roberto.fernandez@minerasur.cl',
        (SELECT id FROM positions WHERE description = 'Superintendente de Seguridad' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')),
        true, '2024-09-05 08:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Claudia', 'Muñoz', 'claudia.munoz@minerasur.cl',
        (SELECT id FROM positions WHERE description = 'Técnico de Seguridad' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')),
        true, '2024-09-15 07:30:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Francisco', 'Rodríguez', 'francisco.rodriguez@minerasur.cl',
        (SELECT id FROM positions WHERE description = 'Operario de Mina' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')),
        true, '2024-10-01 06:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Isabel', 'Vargas', 'isabel.vargas@minerasur.cl',
        (SELECT id FROM positions WHERE description = 'Técnico de Seguridad' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')),
        true, '2024-10-15 08:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Mauricio', 'Silva', 'mauricio.silva@minerasur.cl',
        (SELECT id FROM positions WHERE description = 'Operario de Mina' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')),
        true, '2024-11-01 06:30:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Valentina', 'Torres', 'valentina.torres@minerasur.cl',
        (SELECT id FROM positions WHERE description = 'Superintendente de Seguridad' AND tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')),
        true, '2024-11-15 09:00:00-04');

-- ============================================================================
-- 5. TENANT_MODULES
-- ============================================================================

-- Tenant 1: Empresa ABC — módulos 1,2,3,6,7 (SST + Integrado)
INSERT INTO tenant_modules (tenant_id, module_id) VALUES
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM modules WHERE title = 'Identificación de peligros')),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM modules WHERE title = 'Evaluación de riesgos')),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM modules WHERE title = 'Medidas de control')),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM modules WHERE title = 'Indicadores de gestión')),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM modules WHERE title = 'Auditorías internas'));

-- Tenant 2: Constructora Delta — módulos 1,2,3,4,5 (SST + PESV)
INSERT INTO tenant_modules (tenant_id, module_id) VALUES
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM modules WHERE title = 'Identificación de peligros')),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM modules WHERE title = 'Evaluación de riesgos')),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM modules WHERE title = 'Medidas de control')),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM modules WHERE title = 'Plan de seguridad vial')),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM modules WHERE title = 'Gestión del tránsito'));

-- Tenant 3: Transportes Rápidos — módulos 4,5 (solo PESV)
INSERT INTO tenant_modules (tenant_id, module_id) VALUES
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT id FROM modules WHERE title = 'Plan de seguridad vial')),
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT id FROM modules WHERE title = 'Gestión del tránsito'));

-- Tenant 4: Minera Sur — módulos 1,2,3,4,5,6,7 (sin "Gestión ambiental" para dejar módulo sin asignar)
INSERT INTO tenant_modules (tenant_id, module_id) VALUES
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM modules WHERE title = 'Identificación de peligros')),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM modules WHERE title = 'Evaluación de riesgos')),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM modules WHERE title = 'Medidas de control')),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM modules WHERE title = 'Plan de seguridad vial')),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM modules WHERE title = 'Gestión del tránsito')),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM modules WHERE title = 'Indicadores de gestión')),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM modules WHERE title = 'Auditorías internas'));

-- ============================================================================
-- 6. TENANTSYSTEMS
-- ============================================================================

-- Tenant 1: Empresa ABC — SG-SST y SIG
INSERT INTO tenantsystems (tenant_id, type_system_sst_id) VALUES
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo')),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema Integrado de Gestión'));

-- Tenant 2: Constructora Delta — SG-SST y SG-SV
INSERT INTO tenantsystems (tenant_id, type_system_sst_id) VALUES
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo')),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial'));

-- Tenant 3: Transportes Rápidos — solo SG-SV
INSERT INTO tenantsystems (tenant_id, type_system_sst_id) VALUES
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial'));

-- Tenant 4: Minera Sur — todos los sistemas
INSERT INTO tenantsystems (tenant_id, type_system_sst_id) VALUES
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo')),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial')),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema Integrado de Gestión')),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión Ambiental'));

-- ============================================================================
-- 7. TEMPLATETEMPLATES
-- ============================================================================

-- Tenant 1: Empresa ABC — 4 plantillas
INSERT INTO tenanttemplates (tenant_id, template_id, type_system_sst_id, phva_stage_id, format_id, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM templates WHERE name = 'Política de SST'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'),
        (SELECT id FROM phva_stages WHERE code = 'P'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Matriz de Identificación de Peligros'),
        '2024-02-01 10:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM templates WHERE name = 'Procedimiento de Emergencias'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'),
        (SELECT id FROM phva_stages WHERE code = 'H'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Plan de Acción'),
        '2024-03-15 11:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM templates WHERE name = 'Indicadores de cumplimiento'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema Integrado de Gestión'),
        (SELECT id FROM phva_stages WHERE code = 'V'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Tablero de Indicadores'),
        '2024-04-20 09:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT id FROM templates WHERE name = 'Informe de auditoría'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema Integrado de Gestión'),
        (SELECT id FROM phva_stages WHERE code = 'A'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Checklist de Auditoría'),
        '2024-05-25 14:00:00-05');

-- Tenant 2: Constructora Delta — 5 plantillas (diferentes etapas PHVA)
INSERT INTO tenanttemplates (tenant_id, template_id, type_system_sst_id, phva_stage_id, format_id, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM templates WHERE name = 'Política de SST'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'),
        (SELECT id FROM phva_stages WHERE code = 'P'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Lista de Verificación de Peligros'),
        '2024-04-01 08:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM templates WHERE name = 'Procedimiento de Emergencias'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'),
        (SELECT id FROM phva_stages WHERE code = 'H'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Plan de Acción'),
        '2024-05-10 10:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM templates WHERE name = 'Manual de seguridad vial'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial'),
        (SELECT id FROM phva_stages WHERE code = 'P'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Plan Estratégico PESV'),
        '2024-06-15 09:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM templates WHERE name = 'Formato de capacitación'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial'),
        (SELECT id FROM phva_stages WHERE code = 'V'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Cronograma de Actividades'),
        '2024-07-20 11:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT id FROM templates WHERE name = 'Plan de contingencia'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'),
        (SELECT id FROM phva_stages WHERE code = 'A'),
        NULL,
        '2024-08-25 14:00:00-05');

-- Tenant 3: Transportes Rápidos — 3 plantillas
INSERT INTO tenanttemplates (tenant_id, template_id, type_system_sst_id, phva_stage_id, format_id, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT id FROM templates WHERE name = 'Manual de seguridad vial'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial'),
        (SELECT id FROM phva_stages WHERE code = 'P'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Plan Estratégico PESV'),
        '2024-07-01 08:00:00-06'),
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT id FROM templates WHERE name = 'Registro de incidentes'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial'),
        (SELECT id FROM phva_stages WHERE code = 'V'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Registro de Vehículos'),
        '2024-08-15 09:00:00-06'),
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT id FROM templates WHERE name = 'Indicadores de cumplimiento'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial'),
        (SELECT id FROM phva_stages WHERE code = 'H'),
        NULL,
        '2024-09-01 10:00:00-06');

-- Tenant 4: Minera Sur — 6 plantillas (todas las etapas PHVA para SST)
INSERT INTO tenanttemplates (tenant_id, template_id, type_system_sst_id, phva_stage_id, format_id, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM templates WHERE name = 'Política de SST'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'),
        (SELECT id FROM phva_stages WHERE code = 'P'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Matriz de Identificación de Peligros'),
        '2024-09-10 08:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM templates WHERE name = 'Procedimiento de Emergencias'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'),
        (SELECT id FROM phva_stages WHERE code = 'H'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Plan de Acción'),
        '2024-10-01 09:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM templates WHERE name = 'Indicadores de cumplimiento'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'),
        (SELECT id FROM phva_stages WHERE code = 'V'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Tablero de Indicadores'),
        '2024-10-15 10:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM templates WHERE name = 'Informe de auditoría'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad y Salud en el Trabajo'),
        (SELECT id FROM phva_stages WHERE code = 'A'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Checklist de Auditoría'),
        '2024-11-01 11:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM templates WHERE name = 'Manual de seguridad vial'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión de Seguridad Vial'),
        (SELECT id FROM phva_stages WHERE code = 'P'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Plan Estratégico PESV'),
        '2024-11-15 08:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT id FROM templates WHERE name = 'Plan de contingencia'),
        (SELECT id FROM type_system_sst WHERE name = 'Sistema de Gestión Ambiental'),
        (SELECT id FROM phva_stages WHERE code = 'P'),
        (SELECT id FROM formats_sst WHERE name = 'Formato Estudio de Impacto Ambiental'),
        '2024-12-01 09:00:00-04');

-- ============================================================================
-- 8. DOCUMENTS (18 documentos con diferentes estados)
-- ============================================================================

-- Tenant 1: Empresa ABC (4 documentos)
INSERT INTO documents (tenant_id, tenanttemplate_id, status, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')
         AND t.name = 'Política de SST'),
        'finalizado', '2024-02-15 10:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')
         AND t.name = 'Procedimiento de Emergencias'),
        'borrador', '2024-03-20 11:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')
         AND t.name = 'Indicadores de cumplimiento'),
        'pendiente', '2024-04-25 09:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')
         AND t.name = 'Informe de auditoría'),
        'no_iniciado', '2024-05-30 14:00:00-05');

-- Tenant 2: Constructora Delta (5 documentos)
INSERT INTO documents (tenant_id, tenanttemplate_id, status, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')
         AND t.name = 'Política de SST' AND tt.phva_stage_id = (SELECT id FROM phva_stages WHERE code = 'P')),
        'finalizado', '2024-04-10 08:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')
         AND t.name = 'Procedimiento de Emergencias'),
        'finalizado', '2024-05-15 10:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')
         AND t.name = 'Manual de seguridad vial'),
        'borrador', '2024-06-20 09:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')
         AND t.name = 'Formato de capacitación'),
        'pendiente', '2024-07-25 11:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')
         AND t.name = 'Plan de contingencia'),
        'no_iniciado', '2024-08-30 14:00:00-05');

-- Tenant 3: Transportes Rápidos (4 documentos)
INSERT INTO documents (tenant_id, tenanttemplate_id, status, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.')
         AND t.name = 'Manual de seguridad vial'),
        'finalizado', '2024-07-10 08:00:00-06'),
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.')
         AND t.name = 'Registro de incidentes'),
        'borrador', '2024-08-20 09:00:00-06'),
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.')
         AND t.name = 'Indicadores de cumplimiento'),
        'pendiente', '2024-09-05 10:00:00-06'),
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.')
         AND t.name = 'Manual de seguridad vial'),
        'no_iniciado', '2024-09-15 11:00:00-06');

-- Tenant 4: Minera Sur (5 documentos)
INSERT INTO documents (tenant_id, tenanttemplate_id, status, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')
         AND t.name = 'Política de SST'),
        'finalizado', '2024-09-15 08:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')
         AND t.name = 'Procedimiento de Emergencias'),
        'finalizado', '2024-10-05 09:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')
         AND t.name = 'Indicadores de cumplimiento'),
        'borrador', '2024-10-20 10:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')
         AND t.name = 'Informe de auditoría'),
        'pendiente', '2024-11-05 11:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'),
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')
         AND t.name = 'Manual de seguridad vial'),
        'no_iniciado', '2024-12-05 08:00:00-04');

-- ============================================================================
-- 9. EVALUATIONS (según estructura propuesta en modelo físico)
-- ============================================================================

INSERT INTO evaluations (tenant_id, name, description, created_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Evaluación de riesgos laborales 2024', 'Evaluación anual de riesgos laborales', '2024-02-01 10:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'Auditoría interna SG-SST', 'Auditoría interna del sistema de gestión', '2024-06-15 09:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Evaluación de riesgos en obra', 'Evaluación específica para obras de construcción', '2024-05-01 08:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'Inspección de seguridad vial', 'Inspección de señales y vialidad', '2024-08-10 10:00:00-05'),
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'), 'Evaluación de conductor', 'Evaluación periódica de conductores', '2024-08-01 06:00:00-06'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Evaluación de riesgos mineros', 'Evaluación integral de riesgos en mina', '2024-10-01 08:00:00-04'),
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'Auditoría ambiental', 'Auditoría de cumplimiento ambiental', '2024-11-15 09:00:00-04');

-- ============================================================================
-- 10. EDITING_LOCKS (5 casos representativos)
-- ============================================================================

INSERT INTO editing_locks (tenant_id, resource_type, resource_id, locked_by, locked_at, expires_at) VALUES
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'tenanttemplate',
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')
         AND t.name = 'Procedimiento de Emergencias'),
        'carlos.ramirez@empresaabc.com', '2024-03-20 11:00:00-05', '2024-03-20 11:30:00-05'),

    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'document',
        (SELECT d.id FROM documents d
         JOIN tenanttemplates tt ON d.tenanttemplate_id = tt.id
         JOIN templates t ON tt.template_id = t.id
         WHERE d.tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')
         AND t.name = 'Manual de seguridad vial' LIMIT 1),
        'sandra.ospina@constructoradelta.com', '2024-06-20 09:00:00-05', '2024-06-20 09:30:00-05'),

    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'), 'tenanttemplate',
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.')
         AND t.name = 'Registro de incidentes'),
        'miguel.torres@transportesrapidos.com', '2024-08-20 09:00:00-06', '2024-08-20 09:30:00-06'),

    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'document',
        (SELECT d.id FROM documents d
         JOIN tenanttemplates tt ON d.tenanttemplate_id = tt.id
         JOIN templates t ON tt.template_id = t.id
         WHERE d.tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')
         AND t.name = 'Indicadores de cumplimiento' LIMIT 1),
        'roberto.fernandez@minerasur.cl', '2024-10-20 10:00:00-04', '2024-10-20 10:30:00-04'),

    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'tenanttemplate',
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')
         AND t.name = 'Informe de auditoría'),
        'claudia.munoz@minerasur.cl', '2024-11-05 11:00:00-04', '2024-11-05 11:30:00-04');

-- ============================================================================
-- 11. AUDIT_LOG (10 registros representativos)
-- ============================================================================

INSERT INTO audit_log (tenant_id, table_name, record_id, action, old_values, new_values, changed_at, changed_by) VALUES
    -- Tenant 1: Empresa ABC
    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'tenants',
        (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'UPDATE',
        '{"name": "Empresa ABC S.A.S."}'::jsonb,
        '{"contact_email": "nuevo@empresaabc.com"}'::jsonb,
        '2024-02-20 10:00:00-05', 'carlos.ramirez@empresaabc.com'),

    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'persons',
        (SELECT id FROM persons WHERE email = 'juan.garcia@empresaabc.com'), 'UPDATE',
        '{"is_active": true}'::jsonb,
        '{"is_active": false}'::jsonb,
        '2024-05-20 09:00:00-05', 'maria.lopez@empresaabc.com'),

    -- Tenant 2: Constructora Delta
    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'tenants',
        (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'UPDATE',
        '{"phone": "+57 2 345 6789"}'::jsonb,
        '{"phone": "+57 2 345 9999"}'::jsonb,
        '2024-05-10 10:00:00-05', 'sandra.ospina@constructoradelta.com'),

    ((SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.'), 'documents',
        (SELECT d.id FROM documents d
         JOIN tenanttemplates tt ON d.tenanttemplate_id = tt.id
         JOIN templates t ON tt.template_id = t.id
         WHERE d.tenant_id = (SELECT id FROM tenants WHERE name = 'Constructora Delta Ltda.')
         AND t.name = 'Política de SST' AND d.status = 'finalizado' LIMIT 1), 'UPDATE',
        '{"status": "borrador"}'::jsonb,
        '{"status": "finalizado"}'::jsonb,
        '2024-04-15 11:00:00-05', 'sandra.ospina@constructoradelta.com'),

    -- Tenant 3: Transportes Rápidos
    ((SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'), 'tenants',
        (SELECT id FROM tenants WHERE name = 'Transportes Rápidos S.A.'), 'UPDATE',
        '{"contact_email": "admin@transportesrapidos.com"}'::jsonb,
        '{"contact_email": "info@transportesrapidos.com"}'::jsonb,
        '2024-07-15 09:00:00-06', 'miguel.torres@transportesrapidos.com'),

    -- Tenant 4: Minera Sur
    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'tenants',
        (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'UPDATE',
        '{"name": "Minera Sur SpA."}'::jsonb,
        '{"name": "Minera Sur SpA.", "phone": "+56 2 2345 0000"}'::jsonb,
        '2024-11-10 08:00:00-04', 'roberto.fernandez@minerasur.cl'),

    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'persons',
        (SELECT id FROM persons WHERE email = 'francisco.rodriguez@minerasur.cl'), 'UPDATE',
        '{"is_active": true}'::jsonb,
        '{"is_active": false}'::jsonb,
        '2024-11-20 09:00:00-04', 'claudia.munoz@minerasur.cl'),

    -- Auditoría global (sin tenant)
    (NULL, 'countries',
        (SELECT id FROM countries WHERE name = 'Colombia'), 'UPDATE',
        '{"name": "Colombia"}'::jsonb,
        '{"name": "Colombia"}'::jsonb,
        '2024-01-10 08:00:00-05', 'admin'),

    ((SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.'), 'tenant_modules',
        (SELECT tm.id FROM tenant_modules tm
         WHERE tm.tenant_id = (SELECT id FROM tenants WHERE name = 'Empresa ABC S.A.S.')
         AND tm.module_id = (SELECT id FROM modules WHERE title = 'Auditorías internas')), 'INSERT',
        NULL,
        '{"tenant_id": 1, "module_id": 7}'::jsonb,
        '2024-06-01 10:00:00-05', 'carlos.ramirez@empresaabc.com'),

    ((SELECT id FROM tenants WHERE name = 'Minera Sur SpA.'), 'tenanttemplates',
        (SELECT tt.id FROM tenanttemplates tt
         JOIN templates t ON tt.template_id = t.id
         WHERE tt.tenant_id = (SELECT id FROM tenants WHERE name = 'Minera Sur SpA.')
         AND t.name = 'Plan de contingencia'), 'INSERT',
        NULL,
        '{"template_id": 5, "type_system_sst_id": 4, "phva_stage_id": 1}'::jsonb,
        '2024-12-01 09:00:00-04', 'roberto.fernandez@minerasur.cl');
