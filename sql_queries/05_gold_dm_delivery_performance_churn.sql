/*
 * PROJECT: Olist Delivery Performance & Customer Churn
 * DESCRIPTION: Analysis of delivery delays, their impact on review scores (1-star), 
 * customer retention (churn), and geographic distance.
 * * PROYECTO: Rendimiento de Entregas y Fuga de Clientes en Olist
 * DESCRIPCIÓN: Análisis de retrasos logísticos, su impacto en las reseñas (1 estrella), 
 * retención de clientes (fuga) y distancia geográfica.
 */
-- Drop table if exists to allow re-runs
-- Eliminar la tabla si existe para permitir ejecuciones repetidas
DROP TABLE IF EXISTS gold.dm_delivery_performance_churn;
CREATE TABLE gold.dm_delivery_performance_churn AS 
WITH geo_cleaned AS (
    -- Step 1: Clean geolocation data. We take the average lat/lng per zip code to avoid duplicates.
    -- Paso 1: Limpiar datos de geolocalización. Sacamos el promedio por código postal.
    SELECT 
        zip_code AS zip,
        AVG(latitude) AS lat,
        AVG(longitude) AS lng
    FROM staging.geolocation
    GROUP BY 1
),
sellers_coords AS (
    -- Step 2: Attach coordinates to Sellers.
    -- Paso 2: Asociar coordenadas a los Vendedores.
    SELECT 
        s.seller_id,
        s.state,
        g.lat AS seller_lat,
        g.lng AS seller_lng
    FROM staging.sellers s
    JOIN geo_cleaned g ON s.zip_code = g.zip
),
customers_coords AS (
    -- Step 3: Attach coordinates and the Unique ID to Customers. 
    -- Paso 3: Asociar coordenadas y el ID Único a los Clientes. 
    SELECT 
        c.customer_id,
        c.customer_unique_id, 
        c.state,
        g.lat AS cust_lat,
        g.lng AS cust_lng
    FROM staging.customers c
    JOIN geo_cleaned g ON c.zip_code = g.zip
),
reviews_cleaned AS (
    -- Step 4: Get the review score (the worst one if multiple exist).
    -- Paso 4: Obtener la puntuación de la reseña (la peor si hay varias).
    SELECT 
        order_id, 
        MIN(score) AS review_score
    FROM staging.order_reviews
    GROUP BY order_id
),
base_orders AS (
    -- Step 5: Join everything and filter for delivered atomic orders (1:1).
    -- Paso 5: Unir todo y filtrar por pedidos entregados de un solo ítem.
    SELECT 
        oi.order_id,
        oi.seller_id,
        o.customer_id,
        c.customer_unique_id,
        s.state AS seller_state,
        c.state AS customer_state,
        oi.price,
        oi.freight_value,
        o.purchase_at,
        o.delivered_customer_at,
        o.estimated_delivery_at,
        r.review_score,
        s.seller_lat,
        s.seller_lng,
        c.cust_lat,
        c.cust_lng
    FROM staging.order_items oi
    JOIN staging.orders o ON oi.order_id = o.order_id
    JOIN sellers_coords s ON oi.seller_id = s.seller_id
    JOIN customers_coords c ON o.customer_id = c.customer_id
    LEFT JOIN reviews_cleaned r ON o.order_id = r.order_id
    WHERE oi.order_item_id = 1 
      AND o.status = 'delivered' 
      AND o.delivered_customer_at IS NOT NULL
)
-- Final Calculation: Extract dates, calculate delays, and apply Haversine.
-- Cálculo Final: Extraer fechas, calcular retrasos y aplicar Haversine.
SELECT 
    order_id,
    customer_id,
    customer_unique_id,
    seller_id,
    seller_state,
    customer_state,
    price,
    freight_value,
    purchase_at,
    delivered_customer_at,
    estimated_delivery_at,
    review_score,  
    -- 1. Real shipping days
    -- 1. Días reales que tardó la entrega
    (CAST(delivered_customer_at AS DATE) - CAST(purchase_at AS DATE)) AS delivery_days_actual,       
    -- 2. Delivery Delay (Positive = Late, Negative = Early)
    -- 2. Retraso en entrega (Positivo = Tarde, Negativo = Llegó antes)
    (CAST(delivered_customer_at AS DATE) - CAST(estimated_delivery_at AS DATE)) AS delivery_delay_days,
    -- 3. Haversine Formula for distance in KM
    -- 3. Fórmula Haversine para la distancia en KM
    6371 * 2 * ASIN(SQRT(
        POWER(SIN((RADIANS(cust_lat) - RADIANS(seller_lat)) / 2), 2) +
        COS(RADIANS(seller_lat)) * COS(RADIANS(cust_lat)) *
        POWER(SIN((RADIANS(cust_lng) - RADIANS(seller_lng)) / 2), 2)
    )) AS distance_km
FROM base_orders;