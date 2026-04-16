--Tablo kontrolü:
SELECT * FROM olist_project.olist_master LIMIT 5;

--En çok gelier getiren ilk 10 kategori
SELECT 
    product_category_name AS category,
    ROUND(SUM(price)::numeric, 2) AS total_revenue,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(price)::numeric, 2) AS avg_order_value
FROM olist_project.olist_master
WHERE product_category_name IS NOT NULL
GROUP BY 1
ORDER BY total_revenue DESC
LIMIT 10;

--Eyalet bazlı lojistik ve gecikme analizi
SELECT 
    customer_state,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_days,
    ROUND(AVG(estimated_delivery_days)::numeric, 2) AS avg_estimated_days,
    COUNT(CASE WHEN delay > 0 THEN 1 END) AS delayed_orders,
    ROUND(100.0 * COUNT(CASE WHEN delay > 0 THEN 1 END) / COUNT(order_id)::numeric, 2) AS delay_rate_percentage 
FROM olist_project.olist_master
GROUP BY customer_state
HAVING COUNT(order_id) > 100
ORDER BY delay_rate_percentage DESC;

--Müşteri memnuniyeti(Review score) vs Teslimat hızı
SELECT 
    review_score,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_time,
    COUNT(order_id) AS total_reviews
FROM olist_project.olist_master
WHERE delivery_time IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC;

--Aylık gelir trendi (Zaman Serisi)
SELECT 
    TO_CHAR(order_purchase_timestamp::TIMESTAMP, 'YYYY-MM') AS month_year, -- ::TIMESTAMP ekledik
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total_order_payment)::numeric, 2) AS monthly_revenue
FROM olist_project.olist_master
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY 1;
--Kargo ücreti segmentasyonu ve gecikme
SELECT 
    CASE 
        WHEN freight_value < 15 THEN '1. Düşük (0-15)'
        WHEN freight_value BETWEEN 15 AND 30 THEN '2. Orta (15-30)'
        WHEN freight_value BETWEEN 30 AND 60 THEN '3. Yüksek (30-60)'
        ELSE '4. Çok Yüksek (60+)'
    END AS freight_category,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_days,
    ROUND(AVG(review_score)::numeric, 2) AS avg_satisfaction,
    ROUND(100.0 * COUNT(CASE WHEN delay > 0 THEN 1 END) / COUNT(order_id)::numeric, 2) AS delay_rate_percent
FROM olist_project.olist_master
GROUP BY 1
ORDER BY 1;

-- Şehir Bazında "Değerli" Müşteri ve Harcama Yoğunluğu
SELECT 
    customer_city,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    ROUND(SUM(price)::numeric, 2) AS total_city_revenue,
    ROUND(AVG(price)::numeric, 2) AS average_order_value
FROM olist_project.olist_master
GROUP BY customer_city
HAVING COUNT(order_id) > 50
ORDER BY average_order_value DESC
LIMIT 10;

-- En Yüksek Ciro Getiren Ama En Çok Gecikilen Şehirler 
SELECT 
    customer_city,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(price)::numeric, 2) AS total_city_revenue,
    ROUND(AVG(delivery_time)::numeric, 2) AS avg_delivery_days,
    ROUND(
        (100.0 * COUNT(CASE WHEN delay > 0 THEN 1 END) 
        / COUNT(order_id))::numeric, 2
    ) AS delay_rate_percent
FROM 
    olist_project.olist_master
GROUP BY 
    customer_city
-- En az 50 sipariş almış şehirleri baz alalım
HAVING 
    COUNT(order_id) > 50
ORDER BY 
    delay_rate_percent DESC, total_city_revenue DESC;

--Teslimat performansı:"Eyalet ortalamsından daha yavaş olan şehirler"
SELECT 
    customer_city,
    customer_state,
    ROUND(AVG(delivery_time)::numeric, 2) AS city_avg_delivery,
    ROUND(AVG(AVG(delivery_time)) OVER (PARTITION BY customer_state)::numeric, 2) AS state_avg_delivery,
    ROUND((AVG(delivery_time) - AVG(AVG(delivery_time)) OVER (PARTITION BY customer_state))::numeric, 2) AS delivery_diff
FROM olist_project.olist_master
WHERE delivery_time IS NOT NULL
GROUP BY 1, 2
HAVING COUNT(order_id) > 20
ORDER BY delivery_diff DESC
LIMIT 15;

--Pareto Analizi:
WITH CategorySales AS (
    SELECT 
        product_category_name,
        SUM(price) AS category_revenue
    FROM olist_project.olist_master
    WHERE product_category_name IS NOT NULL
    GROUP BY 1
),
CumulativeSales AS (
    SELECT 
        product_category_name,
        category_revenue,
        SUM(category_revenue) OVER (ORDER BY category_revenue DESC) AS running_total,
        SUM(category_revenue) OVER () AS total_revenue
    FROM CategorySales
)
SELECT 
    product_category_name,
    ROUND(category_revenue::numeric, 2) AS revenue,
    ROUND((running_total / total_revenue * 100)::numeric, 2) AS cumulative_percentage
FROM CumulativeSales
WHERE (running_total - category_revenue) / total_revenue < 0.80
ORDER BY category_revenue DESC;

--Şehir İçi Rekabet: "Eyaletin En Çok Satan Şehri"
WITH CityStats AS (
    SELECT 
        customer_state,
        customer_city,
        SUM(price) AS city_revenue
    FROM olist_project.olist_master
    GROUP BY 1, 2
),
RankedCities AS (
    SELECT 
        customer_state,
        customer_city,
        city_revenue,
        RANK() OVER (PARTITION BY customer_state ORDER BY city_revenue DESC) as city_rank,
        ROUND((city_revenue / SUM(city_revenue) OVER (PARTITION BY customer_state) * 100)::numeric, 2) as state_share_percent
    FROM CityStats
)
SELECT * FROM RankedCities 
WHERE city_rank = 1
ORDER BY city_revenue DESC;







