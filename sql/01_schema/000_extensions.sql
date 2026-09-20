-- ============================================================================
-- SST-PESV: Extensiones requeridas
-- Sesión 2.1 — Modelo físico / DDL
-- ============================================================================
-- PostgreSQL 16

-- pgcrypto: para funciones de hashing si se necesitan
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- uuid-ossp: para generación de UUIDs (por si se necesita en el futuro)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
