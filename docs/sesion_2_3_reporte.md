# Session 2.3 — Reporte: Consultas SQL Básicas e Intermedias

## Estado: COMPLETADO

## Archivos Creados

| Archivo | Descripción | Consultas |
|---------|-------------|-----------|
| `sql/03_queries/basicas.sql` | Consultas SQL básicas | 15 (B01–B15) |
| `sql/03_queries/intermedias.sql` | Consultas SQL intermedias | 20 (I01–I20) |

## Resumen de Validación

| Tipo | Total | Ejecutadas | Errores | Estado |
|------|-------|------------|---------|--------|
| Básicas | 15 | 15 | 0 | ✅ |
| Intermedias | 20 | 20 | 0 | ✅ |
| **Total** | **35** | **35** | **0** | **✅** |

## Detalle de Consultas Básicas (B01–B15)

| ID | Descripción | Filas | Estado |
|----|-------------|-------|--------|
| B01 | Consultar todos los registros de `tenants` | 4 | ✅ |
| B02 | Nombre, correo y teléfono de organizaciones | 4 | ✅ |
| B03 | Listar personas con nombres, apellidos y correo | 19 | ✅ |
| B04 | Personas con estado activo | 19 | ✅ |
| B05 | Organizaciones cuyo nombre contenga una palabra | 1 | ✅ |
| B06 | Países ordenados alfabéticamente | 5 | ✅ |
| B07 | Departamentos de un país determinado | 4 | ✅ |
| B08 | Municipios de un departamento determinado | 2 | ✅ |
| B09 | Cargos ordenados por descripción | 13 | ✅ |
| B10 | Personas de una organización por `tenant_id` | 7 | ✅ |
| B11 | Organizaciones habilitadas/activas | 3 | ✅ |
| B12 | Organizaciones registradas en un período | 3 | ✅ |
| B13 | Tamaños de empresa | 4 | ✅ |
| B14 | Tipos de sistemas SST | 4 | ✅ |
| B15 | Módulos con título, descripción y orden | 8 | ✅ |

## Detalle de Consultas Intermedias (I01–I20)

| ID | Descripción | Filas | Estado |
|----|-------------|-------|--------|
| I01 | Personas con nombre completo y organización (INNER JOIN) | 19 | ✅ |
| I02 | Personas con su cargo (INNER JOIN) | 19 | ✅ |
| I03 | Organizaciones con tamaño asignado (INNER JOIN) | 4 | ✅ |
| I04 | Organizaciones con ubicación geográfica (JOIN múltiple) | 4 | ✅ |
| I05 | Cantidad de personas por organización (GROUP BY) | 4 | ✅ |
| I06 | Organizaciones con más de 4 personas (HAVING) | 3 | ✅ |
| I07 | Módulos habilitados por organización | 19 | ✅ |
| I08 | Cantidad de módulos por organización | 4 | ✅ |
| I09 | Sistemas SST por organización | 9 | ✅ |
| I10 | Módulos con su sistema SST | 8 | ✅ |
| I11 | Formatos con su módulo | 10 | ✅ |
| I12 | Cantidad de formatos por módulo | 8 | ✅ |
| I13 | Plantillas asignadas por organización | 18 | ✅ |
| I14 | Plantillas con organización, sistema SST y etapa PHVA | 18 | ✅ |
| I15 | Cantidad de plantillas por organización | 4 | ✅ |
| I16 | Organizaciones sin personas (LEFT JOIN + IS NULL) | 1 | ✅ |
| I17 | Módulos no asignados a ninguna organización | 1 | ✅ |
| I18 | Plantillas por etapa PHVA | 4 | ✅ |
| I19 | Organizaciones por municipio | 4 | ✅ |
| I20 | Cargos por organización con cantidad de personas | 13 | ✅ |

## Técnicas SQL Utilizadas

### Básicas
- SELECT con columnas específicas
- WHERE con operadores de comparación
- ORDER BY ASC/DESC
- LIKE para búsquedas parciales
- BETWEEN para rangos de fechas

### Intermedias
- INNER JOIN (2, 3 y 4 tablas)
- LEFT JOIN + IS NULL (organizaciones sin personas, módulos no asignados)
- GROUP BY con funciones de agregación (COUNT)
- HAVING para filtros post-agregación
- ORDER BY con alias de columna

## Verificación de Cobertura

| Requisito del Examen | Estado |
|----------------------|--------|
| §1.1–§1.15 Consultas básicas | ✅ Completado |
| §2.1–§2.20 Consultas intermedias | ✅ Completado |
| 35 consultas totales (15 + 20) | ✅ Completado |
| Todas ejecutadas en PostgreSQL 16 | ✅ Verificado |

## Próximos Pasos

1. **NO commit** — esperar a completar sesiones 2.4, 2.5, 2.6
2. Implementar consultas avanzadas (25) — Sesión 2.4
3. Implementar vistas (8) — Sesión 2.5
4. Implementar procedimientos, funciones y triggers — Sesión 2.6
