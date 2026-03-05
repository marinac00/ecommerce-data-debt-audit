/*******************************************************************************
SCRIPT: 01_staging_setup.sql
PHASE: Staging Infrastructure / Infraestructura de Staging
*******************************************************************************/

/* STANDARD RESET OPTION:
   If you need to wipe the entire staging area to start over, uncomment the line below.
   Si necesitas borrar todo el área de staging para empezar de cero, desenta la línea de abajo.
*/
-- DROP SCHEMA IF EXISTS staging CASCADE;

-- 1. Create the schema / Creación del esquema
CREATE SCHEMA IF NOT EXISTS staging;

-- 2. Internal Documentation / Documentación interna
COMMENT ON SCHEMA staging IS 'Intermediate layer for data cleaning and typing (Silver Layer). 
                                Capa intermedia para limpieza y tipado de datos (Capa Silver).';

/*******************************************************************************/