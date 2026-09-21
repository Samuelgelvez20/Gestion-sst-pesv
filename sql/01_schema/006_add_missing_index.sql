-- ============================================================================
-- SST-PESV: Índice faltante — Corrección Sesión 4.1
-- Archivo: 006_add_missing_index.sql
-- PostgreSQL 16
-- ============================================================================
-- Ejecutar después de 005_alter_tenanttemplates.sql.
-- Corrige la ausencia de índice en tenanttemplates.format_id,
-- la única FK de las 23 que no tenía índice de respaldo.
-- ============================================================================

CREATE INDEX IF NOT EXISTS ix_tenanttemplates_format_id
    ON tenanttemplates(format_id);
