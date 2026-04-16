--Tabloların kontrolü,
SELECT * FROM olist_project.dim_customers_orders LIMIT 5;

--En çok gelir getiren ilk 10 ürün 
WITH CategoryRevenue AS (
    SELECT 
        p.top_category,
        SUM(p.total_price) AS total_revenue,
        COUNT(p.order_id) AS total_orders
    FROM olist_project.fact_order_performance p
    GROUP BY p.top_category
)
SELECT 
    top_category,
    ROUND(CAST(total_revenue AS NUMERIC), 2) AS revenue,
    total_orders,
    ROUND(CAST(total_revenue / total_orders AS NUMERIC), 2) AS avg_order_value
FROM CategoryRevenue
ORDER BY total_revenue DESC
LIMIT 10;

--Eyalet Bazlı Lojistik Performans ve Gecikme Analizi
SELECT 
    c.customer_state,
    ROUND(AVG(p.actual_delivery_days)::numeric, 2) AS avg_actual_days,
    ROUND(AVG(p.estimated_delivery_days), 2) AS avg_estimated_days,
    COUNT(CASE WHEN p.actual_delivery_days > p.estimated_delivery_days THEN 1 END) AS delayed_orders,
    ROUND(100.0 * COUNT(CASE WHEN p.actual_delivery_days > p.estimated_delivery_days THEN 1 END) / COUNT(p.order_id)::numeric, 2) 
	AS delay_rate_percentage 
FROM olist_project.dim_customers_orders c
JOIN olist_project.fact_order_performance p ON c.order_id = p.order_id
GROUP BY c.customer_state
HAVING COUNT(p.order_id) > 100 -- Anlamlı sonuç için yeterli sipariş olan eyaletler
ORDER BY delay_rate_percentage DESC;

--Müşteri Memnuniyeti (Review Score) ile Teslimat Hızı İlişkisi
SELECT 
    p.review_score,
    ROUND(AVG(p.actual_delivery_days)::numeric, 2) AS avg_delivery_time,
    COUNT(p.order_id) AS total_reviews
FROM olist_project.fact_order_performance p
WHERE p.actual_delivery_days IS NOT NULL
GROUP BY p.review_score
ORDER BY p.review_score DESC;

--En çok hangi ürünler geç kalıyor?
SELECT 
    p.top_category,
    COUNT(p.order_id) AS total_orders,
    ROUND(AVG(p.actual_delivery_days)::numeric, 2) AS avg_delivery_days,
    ROUND(AVG(p.review_score)::numeric, 2) AS avg_satisfaction,
    -- Gecikme oranı yüzdesi
    ROUND(
        (100.0 * COUNT(CASE WHEN p.actual_delivery_days > p.estimated_delivery_days THEN 1 END) 
        / COUNT(p.order_id))::numeric, 2
    ) AS delay_rate_percent
FROM 
    order_performance p
GROUP BY 
    p.top_category
HAVING 
    COUNT(p.order_id) > 10  -- Verinin anlamlı olması için az satışı olanları eliyoruz
ORDER BY 
    avg_delivery_days DESC;

--Şehir Bazında "Değerli" Müşteri ve Harcama Yoğunluğu
SELECT 
    c.customer_city,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(p.total_price)::numeric, 2) AS total_city_revenue,
    ROUND(AVG(p.total_price)::numeric, 2) AS average_order_value
FROM olist_project.dim_customers_orders c
JOIN olist_project.fact_order_performance p ON c.order_id = p.order_id
GROUP BY c.customer_city
HAVING COUNT(c.order_id) > 50
ORDER BY average_order_value DESC
LIMIT 10;

--En Yüksek Ciro Getiren Ama En Çok Gecikilen Şehirler

SELECT 
    c.customer_city,
    COUNT(p.order_id) AS total_orders,
    SUM(p.total_price) AS total_city_revenue,
    ROUND(AVG(p.actual_delivery_days)::numeric, 2) AS avg_delivery_days,
    -- Gecikme oranı yüzdesi
    ROUND(
        (100.0 * COUNT(CASE WHEN p.actual_delivery_days > p.estimated_delivery_days THEN 1 END) 
        / COUNT(p.order_id))::numeric, 2
    ) AS delay_rate_percent
FROM 
    order_performance p
JOIN 
    customers_orders c ON p.order_id = c.order_id
GROUP BY 
    c.customer_city
-- En az 50 sipariş almış şehirleri baz alalım (istatistiksel anlamlılık için)
HAVING 
    COUNT(p.order_id) > 50
ORDER BY 
    delay_rate_percent DESC, total_city_revenue DESC;

--Aylık Gelir Trendi ve Büyüme Analizi,zaman içindeki satış trendi

WITH MonthlySales AS (
    SELECT 
        EXTRACT(YEAR FROM CAST(c.order_purchase_timestamp AS TIMESTAMP)) AS sale_year,
        EXTRACT(MONTH FROM CAST(c.order_purchase_timestamp AS TIMESTAMP)) AS sale_month,
        SUM(p.total_price) AS monthly_revenue
    FROM olist_project.dim_customers_orders c
    JOIN olist_project.fact_order_performance p ON c.order_id = p.order_id
    GROUP BY sale_year, sale_month
)
SELECT 
    sale_year,
    sale_month,
    ROUND(CAST(monthly_revenue AS NUMERIC), 2) AS revenue
FROM MonthlySales
ORDER BY sale_year, sale_month;

--Satışların tavan yaptığı Kasım 2017 döneminde teslimat süreleri ne durumdaydı?
SELECT 
    EXTRACT(YEAR FROM CAST(c.order_purchase_timestamp AS TIMESTAMP)) AS sale_year,
    EXTRACT(MONTH FROM CAST(c.order_purchase_timestamp AS TIMESTAMP)) AS sale_month,
    COUNT(c.order_id) AS total_orders,
    ROUND(AVG(p.actual_delivery_days)::numeric, 2) AS avg_delivery_days,
    ROUND(
        (100.0 * COUNT(CASE WHEN p.actual_delivery_days > p.estimated_delivery_days THEN 1 END) 
        / COUNT(c.order_id))::numeric, 2
    ) AS delay_rate_percent
FROM olist_project.dim_customers_orders c
JOIN olist_project.fact_order_performance p ON c.order_id = p.order_id
GROUP BY sale_year, sale_month
ORDER BY sale_year, sale_month;

--Kargo ücretlerinin teslimat sürelerine etkisi var mı ?

SELECT 
    CASE 
        WHEN p.total_freight < 15 THEN '1. Düşük (0-15)'
        WHEN p.total_freight BETWEEN 15 AND 30 THEN '2. Orta (15-30)'
        WHEN p.total_freight BETWEEN 30 AND 60 THEN '3. Yüksek (30-60)'
        ELSE '4. Çok Yüksek (60+)'
    END AS freight_category,
    COUNT(p.order_id) AS total_orders,
    ROUND(AVG(p.actual_delivery_days)::numeric, 2) AS avg_delivery_days,
    ROUND(AVG(p.review_score)::numeric, 2) AS avg_satisfaction,
    ROUND(
        (100.0 * COUNT(CASE WHEN p.actual_delivery_days > p.estimated_delivery_days THEN 1 END) 
        / COUNT(p.order_id))::numeric, 2
    ) AS delay_rate_percent
FROM 
    order_performance p
GROUP BY 1
ORDER BY 1;












































