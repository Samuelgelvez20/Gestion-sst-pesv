-- ============================================================================
-- SST-PESV: Migración — agregar modified_by a tenanttemplates
-- Sesión 3.4 — Triggers (T14)
-- Archivo: sql/01_schema/005_alter_tenanttemplates.sql
-- PostgreSQL 16
-- ============================================================================
-- Esta migración agrega la columna modified_by a tenanttemplates para
-- soportar el Trigger 14 (registro de usuario responsable en modificación).
-- No modifica 001_create_tables.sql para preservar el historial de migraciones.
-- ============================================================================

ALTER TABLE tenanttemplates
    ADD COLUMN modified_by varchar(100);
