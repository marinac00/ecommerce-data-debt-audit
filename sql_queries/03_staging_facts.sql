/*******************************************************************************
SCRIPT: 03_staging_facts.sql
PHASE: Staging - Facts / Capa de Limpieza - Hechos (Eventos)
OBJECTIVE: Process core business events, timestamps, and financial metrics.
           Procesar eventos principales, marcas de tiempo y métricas financieras.
STANDARDS: ANSI SQL, Medallion Architecture (Silver Layer).
*******************************************************************************/

/*******************************************************************************
TABLE: staging.orders
TASK: Status standardization and timestamp casting.
      Estandarización de estados y conversión de fechas.
DESCRIPTION: The core table of the model. Centralizes order life cycle.
             La tabla núcleo del modelo. Centraliza el ciclo de vida del pedido.
*******************************************************************************/

-- 1. Preventive cleanup / Limpieza preventiva
DROP TABLE IF EXISTS staging.orders;

-- 2. Creation with timestamp casting / Creación con conversión de fechas
CREATE TABLE staging.orders AS
SELECT 
    order_id::TEXT,
    customer_id::TEXT,
    order_status::TEXT AS status,
    -- Conversión masiva de texto a TIMESTAMP (Fecha y Hora)
    order_purchase_timestamp::TIMESTAMP AS purchase_at,
    order_approved_at::TIMESTAMP AS approved_at,
    order_delivered_carrier_date::TIMESTAMP AS delivered_carrier_at,
    order_delivered_customer_date::TIMESTAMP AS delivered_customer_at,
    order_estimated_delivery_date::TIMESTAMP AS estimated_delivery_at
FROM raw.olist_orders_dataset;

-- 3. Database internal documentation / Documentación interna de la BD
COMMENT ON TABLE staging.orders IS 'Core orders table with standardized timestamps.
                                   Tabla principal de pedidos con fechas estandarizadas.';


/*******************************************************************************
TABLE: staging.order_items
TASK: Numerical casting and timestamp standardization.
      Casteo numérico y estandarización de fechas.
DESCRIPTION: Details of products per order, including prices and shipping.
             Detalle de productos por pedido, incluyendo precios y fletes.
*******************************************************************************/

-- 1. Preventive cleanup / Limpieza preventiva
DROP TABLE IF EXISTS staging.order_items;

-- 2. Creation / Creación
CREATE TABLE staging.order_items AS
SELECT 
    order_id::TEXT,
    order_item_id::INT, -- El número de artículo dentro del pedido (picks)
    product_id::TEXT,
    seller_id::TEXT,
    shipping_limit_date::TIMESTAMP AS shipping_limit_at, -- Fecha límite de envío
    price::NUMERIC,
    freight_value::NUMERIC AS freight_value
FROM raw.olist_order_items_dataset;

-- 3. Database internal documentation / Documentación interna de la BD
COMMENT ON TABLE staging.order_items IS 'Detailed items per order with prices and freight values. 
                                         Detalle de artículos por pedido con precios y fletes.';

/*******************************************************************************
TABLE: staging.order_payments
TASK: Numerical and categorical standardization.
      Estandarización numérica y categórica.
DESCRIPTION: Payment details per order, including installments and sequences.
             Detalle de pagos por pedido, incluyendo cuotas y secuencias.
*******************************************************************************/

-- 1. Preventive cleanup / Limpieza preventiva
DROP TABLE IF EXISTS staging.order_payments;

-- 2. Creation / Creación
CREATE TABLE staging.order_payments AS
SELECT 
    order_id::TEXT,
    payment_sequential::INT AS payment_seq, -- Orden en el que se aplicaron los pagos
    payment_type::TEXT AS payment_type,
    payment_installments::INT AS installments, -- Número de plazos/cuotas
    payment_value::NUMERIC AS amount -- El valor monetario del pago
FROM raw.olist_order_payments_dataset;

-- 3. Database internal documentation / Documentación interna de la BD
COMMENT ON TABLE staging.order_payments IS 'Payment methods and installments per order.
                                           Métodos de pago y cuotas por pedido.';

/*******************************************************************************
TABLE: staging.order_reviews
TASK: Score standardization and timestamp casting.
      Estandarización de puntuaciones y conversión de fechas.
DESCRIPTION: Customer satisfaction levels and feedback per order.
             Niveles de satisfacción y comentarios por pedido.
*******************************************************************************/

-- 1. Preventive cleanup / Limpieza preventiva
DROP TABLE IF EXISTS staging.order_reviews;

-- 2. Creation / Creación
CREATE TABLE staging.order_reviews AS
SELECT 
    review_id::TEXT,
    order_id::TEXT,
    review_score::INT AS score,
    review_comment_title::TEXT AS title,
    review_comment_message::TEXT AS message,
    review_creation_date::TIMESTAMP AS created_at,
    review_answer_timestamp::TIMESTAMP AS answered_at
FROM raw.olist_order_reviews_dataset;

-- 3. Database internal documentation / Documentación interna de la BD
COMMENT ON TABLE staging.order_reviews IS 'Customer reviews and satisfaction scores per order.
                                            Reseñas y puntuaciones de satisfacción por pedido.';

SELECT score, message FROM staging.order_reviews LIMIT 30;
										 

								   