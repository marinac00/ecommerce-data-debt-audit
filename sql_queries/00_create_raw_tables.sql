/*******************************************************************************
PROYECTO / PROJECT: E-commerce Olist Data Pipeline (Brazilian Marketplace)
ARCHIVO / FILE: 01_create_raw_tables.sql
DESCRIPCIÓN / DESCRIPTION: 
    Creación del esquema 'raw' y tablas de aterrizaje (Landing Zone).
    Creation of the 'raw' schema and landing tables (Landing Zone).
    
    Nota: Se utiliza TEXT en campos de fecha y coordenadas para asegurar la 
    ingesta y evitar errores de formato durante la carga inicial.
    Note: TEXT is used for date and coordinate fields to ensure ingestion 
    and avoid formatting errors during initial load.
*******************************************************************************/

-- 1. Limpieza y preparación del entorno / Environment cleanup and setup
DROP SCHEMA IF EXISTS raw CASCADE;
CREATE SCHEMA raw;

-- 2. Creación de tablas / Table creation

-- Tabla de Clientes / Customers Table
CREATE TABLE raw.olist_customers_dataset (
	customer_id VARCHAR(50) NULL,
	customer_unique_id VARCHAR(50) NULL,
	customer_zip_code_prefix VARCHAR(10) NULL,
	customer_city VARCHAR(50) NULL,
	customer_state VARCHAR(50) NULL
);
-- COPY raw.olist_customers_dataset FROM '/path/to/olist_customers_dataset.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',', ENCODING 'ISO-8859-1', QUOTE '"');

-- Tabla de Geolocalización / Geolocation Table
CREATE TABLE raw.olist_geolocation_dataset (
	geolocation_zip_code_prefix INT4 NULL,
	geolocation_lat TEXT NULL, -- TEXT used for precision/format safety
	geolocation_lng TEXT NULL, -- TEXT used for precision/format safety
	geolocation_city VARCHAR(50) NULL,
	geolocation_state VARCHAR(50) NULL
);
-- COPY raw.olist_geolocation_dataset FROM '/path/to/olist_geolocation_dataset.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',', ENCODING 'ISO-8859-1', QUOTE '"');

-- Tabla de Items de Pedidos / Order Items Table
CREATE TABLE raw.olist_order_items_dataset (
	order_id VARCHAR(50) NULL,
	order_item_id INT4 NULL,
	product_id VARCHAR(50) NULL,
	seller_id VARCHAR(50) NULL,
	shipping_limit_date VARCHAR(50) NULL,
	price FLOAT4 NULL,
	freight_value FLOAT4 NULL
);
-- COPY raw.olist_order_items_dataset FROM '/path/to/olist_order_items_dataset.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',', ENCODING 'ISO-8859-1', QUOTE '"');

-- Tabla de Pagos / Payments Table
CREATE TABLE raw.olist_order_payments_dataset (
	order_id VARCHAR(50) NULL,
	payment_sequential INT4 NULL,
	payment_type VARCHAR(50) NULL,
	payment_installments INT4 NULL,
	payment_value FLOAT4 NULL
);
-- COPY raw.olist_order_payments_dataset FROM '/path/to/olist_order_payments_dataset.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',', ENCODING 'ISO-8859-1', QUOTE '"');

-- Tabla de Reseñas (Crítica) / Reviews Table (Critical)
CREATE TABLE raw.olist_order_reviews_dataset (
	review_id TEXT NULL,
	order_id TEXT NULL,
	review_score TEXT NULL,
	review_comment_title TEXT NULL,
	review_comment_message TEXT NULL,
	review_creation_date TEXT NULL,
	review_answer_timestamp TEXT NULL
);
-- COPY raw.olist_order_reviews_dataset FROM '/path/to/olist_order_reviews_dataset.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',', ENCODING 'ISO-8859-1', QUOTE '"');

-- Tabla de Pedidos / Orders Table
CREATE TABLE raw.olist_orders_dataset (
	order_id VARCHAR(50) NULL,
	customer_id VARCHAR(50) NULL,
	order_status VARCHAR(50) NULL,
	order_purchase_timestamp TEXT NULL,
	order_approved_at TEXT NULL,
	order_delivered_carrier_date TEXT NULL,
	order_delivered_customer_date TEXT NULL,
	order_estimated_delivery_date TEXT NULL
);
-- COPY raw.olist_orders_dataset FROM '/path/to/olist_orders_dataset.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',', ENCODING 'ISO-8859-1', QUOTE '"');

-- Tabla de Productos / Products Table
CREATE TABLE raw.olist_products_dataset (
	product_id VARCHAR(50) NULL,
	product_category_name VARCHAR(50) NULL,
	product_name_lenght INT4 NULL,
	product_description_lenght INT4 NULL,
	product_photos_qty INT4 NULL,
	product_weight_g INT4 NULL,
	product_length_cm INT4 NULL,
	product_height_cm INT4 NULL,
	product_width_cm INT4 NULL
);
-- COPY raw.olist_products_dataset FROM '/path/to/olist_products_dataset.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',', ENCODING 'ISO-8859-1', QUOTE '"');

-- Tabla de Vendedores / Sellers Table
CREATE TABLE raw.olist_sellers_dataset (
	seller_id VARCHAR(50) NULL,
	seller_zip_code_prefix INT4 NULL,
	seller_city VARCHAR(50) NULL,
	seller_state VARCHAR(50) NULL
);
-- COPY raw.olist_sellers_dataset FROM '/path/to/olist_sellers_dataset.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',', ENCODING 'ISO-8859-1', QUOTE '"');

-- Tabla de Traducción de Categorías / Category Translation Table
CREATE TABLE raw.product_category_name_translation (
	product_category_name VARCHAR(50) NULL,
	product_category_name_english VARCHAR(50) NULL
);
-- COPY raw.product_category_name_translation FROM '/path/to/product_category_name_translation.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',', ENCODING 'ISO-8859-1', QUOTE '"');