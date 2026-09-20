# Incidencias del proyecto SST-PESV

> Registro de incidencias encontradas durante el desarrollo del proyecto.
> Fuente: Examen.md, TASKS.md, docs/requerimientos.md, docs/modelo_conceptual.md

---

## INC-01: TASKS.md fabricado por el agente sin respaldo en Examen.md

### Descripción

Durante la Sesión 1.1, el agente de codificación generó un `TASKS.md` alternativo que fue versionado en el commit `d3c0501`. Este archivo contenía entidades de tablas que **no tienen respaldo en el `Examen.md`** y que propagaron errores a `docs/requerimientos.md` y `docs/modelo_conceptual.md`.

### Entidades sin respaldo identificadas

| Entidad | Fuente erronea | Evidencia en Examen.md |
|---|---|---|
| `users` | TASKS.md fabricado, Sesión 1.4 | No definida |
| `roles` | TASKS.md fabricado, Sesión 1.4 | No definida |
| `riesgos` | TASKS.md fabricado, Sesión 1.4 | No definida |
| `incidentes` | TASKS.md fabricado, Sesión 1.4 | No definida |
| `capacitaciones` | TASKS.md fabricado, Sesión 1.4 | No definida |
| `inspecciones` | TASKS.md fabricado, Sesión 1.4 | No definida |
| `vehiculos` | TASKS.md fabricado, Sesión 1.4 | No definida |
| `conductores` | TASKS.md fabricado, Sesión 1.4 | No definida |
| `rutas` | TASKS.md fabricado, Sesión 1.4 | No definida |
| `controles` | TASKS.md fabricado, Sesión 1.4 | No definida |

### Impacto

1. **`docs/requerimientos.md`**: Las secciones DP-02 y DP-09 citan estas entidades como válidas,引用日期 al TASKS.md fabricado.
2. **`docs/modelo_conceptual.md`**: Incluye las 10 entidades en la tabla de verificación de entidades candidatas.

### Acción tomada

- El `TASKS.md` original fue restaurado manualmente (commit `4219d9b`).
- Se verificó que el `TASKS.md` actual contiene la nota de restauración (línea 11).
- El `docs/requerimientos.md` y `docs/modelo_conceptual.md` requieren corrección (fases 2 y 6 del plan de trabajo).

### Fuentes verificadas

- `Examen.md` (257 líneas): contiene 15 consultas básicas + 20 intermedias + 25 avanzadas + 8 vistas = **68 consultas**, 15 procedimientos, 8 funciones, 15 triggers.
- `TASKS.md` actual (restaurado): confirma que las 10 entidades listadas arriba están **fuera de alcance**.

### Estado

| Elemento | Estado |
|---|---|
| TASKS.md restaurado | ✅ Completado |
| docs/incidencias.md (este archivo) | ✅ Creado |
| docs/requerimientos.md — corrección DP-02/DP-09 | ⏳ Pendiente (Fase 2) |
| docs/modelo_conceptual.md — corrección entidades | ⏳ Pendiente (Fase 6) |

---

*Última actualización: Sesión 1.3 — Fase 0-1*
