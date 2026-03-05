/*******************************************************************************
SCRIPT: 02_staging_dimensions.sql
PHASE: Staging - Dimensions / Capa de Limpieza - Dimensiones
OBJECTIVE: Transform raw data into cleaned, typed, and standardized dimensions.
           Transformar datos brutos en dimensiones limpias, tipadas y estandarizadas.
STANDARDS: ANSI SQL, Medallion Architecture (Silver Layer).
*******************************************************************************/

/*******************************************************************************
TABLE: staging.customers
DESCRIPTION: Cleaning and typing for the Customer Dimension.
             Limpieza y tipado para la Dimensión de Clientes.
*******************************************************************************/

-- 1. Preventive cleanup / Limpieza preventiva
DROP TABLE IF EXISTS staging.customers;

-- 2. Creation from RAW/ Creación desde el esquema RAW
CREATE TABLE staging.customers AS
SELECT 
    -- Primary Key for Joins / Llave primaria para uniones
    customer_id::TEXT, 
    
    -- Unique Identifier for the person / Identificador único de la persona
    customer_unique_id::TEXT, 
    
    -- Location data with length validation / Datos de ubicación con validación
    customer_zip_code_prefix::VARCHAR(10) AS zip_code,
    customer_city::TEXT AS city,
    customer_state::VARCHAR(10) AS state 
FROM raw.olist_customers_dataset;

-- 3. Database internal documentation / Documentación interna de la BD
COMMENT ON TABLE staging.customers IS 'Cleaned customer dimension with bilingual standardized names.';


/*******************************************************************************
TABLE: staging.sellers
TASK: Cleaning and typing for the Seller Dimension.
      Limpieza y tipado para la Dimensión de Vendedores.
*******************************************************************************/

-- 1. Preventive cleanup / Limpieza preventiva
DROP TABLE IF EXISTS staging.sellers;

-- 2. Creation from RAW/ Creación desde el esquema RAW
CREATE TABLE staging.sellers AS
SELECT 
    seller_id::TEXT,
    seller_zip_code_prefix::VARCHAR(10) AS zip_code,
    seller_city::TEXT AS city,
    seller_state::VARCHAR(10) AS state
FROM raw.olist_sellers_dataset;

-- 3. Database internal documentation / Documentación interna de la BD
COMMENT ON TABLE staging.sellers IS 'Cleaned seller dimension. Source: raw.olist_sellers_dataset';

/*******************************************************************************
TABLE: staging.products
TASK: Join with translations and fix physical dimension types.
*******************************************************************************/

-- 1. Preventive cleanup / Limpieza preventiva
DROP TABLE IF EXISTS staging.products;

-- 2. Creation from RAW/ Creación desde el esquema RAW
CREATE TABLE staging.products AS
SELECT 
    p.product_id::TEXT,
    -- Si no hay traducción, usamos el nombre original (COALESCE)
    COALESCE(t.product_category_name_english, p.product_category_name) AS category_name,
    p.product_name_lenght::INT AS name_length, -- Corrección errata
    p.product_description_lenght::INT AS desc_length, -- errata
    p.product_photos_qty::INT AS photos_qty,
    p.product_weight_g::NUMERIC AS weight_g,
    p.product_length_cm::NUMERIC AS length_cm, -- errata
    p.product_height_cm::NUMERIC AS height_cm,
    p.product_width_cm::NUMERIC AS width_cm
FROM raw.olist_products_dataset p
LEFT JOIN raw.product_category_name_translation t 
    ON p.product_category_name = t.product_category_name;

-- 3. Database internal documentation / Documentación interna de la BD
COMMENT ON TABLE staging.products IS 'Cleaned products with English categories. Source: raw.olist_products_dataset';


/*******************************************************************************
TABLE: staging.geolocation
TASK: Deduplication and geographic aggregation.
      Deduplicación y agregación geográfica.
DESCRIPTION: Minimizes the fan-out effect by grouping coordinates by zip code.
             Minimiza el efecto abanico agrupando coordenadas por código postal.
*******************************************************************************/

-- 1. Preventive cleanup / Limpieza preventiva
DROP TABLE IF EXISTS staging.geolocation;

-- 2. Creation with inner casting / Creación con casteo interno
CREATE TABLE staging.geolocation AS
SELECT 
    geolocation_zip_code_prefix::VARCHAR(10) AS zip_code,
    -- Cast to NUMERIC inside the AVG function / Casteo a NUMERIC dentro del AVG
    AVG(geolocation_lat::NUMERIC)::NUMERIC AS latitude,
    AVG(geolocation_lng::NUMERIC)::NUMERIC AS longitude,
    geolocation_city::TEXT AS city,
    geolocation_state::VARCHAR(10) AS state
FROM raw.olist_geolocation_dataset
GROUP BY 1, 4, 5;

-- 3. Database internal documentation / Documentación interna de la BD
COMMENT ON TABLE staging.geolocation IS 'Geolocation data aggregated by zip_code to ensure 1:1 joins. 
                                         Datos geográficos agregados por CP para asegurar uniones 1:1.';