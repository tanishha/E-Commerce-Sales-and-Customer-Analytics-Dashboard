--Total revenue by customer---
SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM
    customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
WHERE
    oi.price IS NOT NULL
GROUP BY
    c.customer_id,
    c.customer_city,
    c.customer_state
ORDER BY
    total_revenue DESC;

--Co - Purchased Product Pairs---
SELECT
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(*) AS times_bought_together
FROM
    order_items o1
    JOIN order_items o2 ON o1.order_id = o2.order_id
    AND o1.product_id < o2.product_id
    JOIN products p1 ON o1.product_id = p1.product_id
    JOIN products p2 ON o2.product_id = p2.product_id
WHERE
    p1.product_name != p2.product_name
    AND p1.product_name != '#N/A'
    AND p2.product_name != '#N/A'
GROUP BY
    p1.product_name,
    p2.product_name
ORDER BY
    times_bought_together DESC;

--Customers by Days Since Last Order---
SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    MAX(o.order_approved_at) AS last_order_date,
    DATEDIFF(CURRENT_DATE, MAX(o.order_approved_at)) AS days_since_last_order
FROM
    customers c
    JOIN orders o ON c.customer_id = o.customer_id
WHERE
    o.order_approved_at IS NOT NULL
GROUP BY
    c.customer_id,
    c.customer_city,
    c.customer_state
ORDER BY
    days_since_last_order DESC;



--Rank Sellers by Revenue and Sales within Product Categories and Regions---
SELECT
    s.seller_id,
    s.seller_state,
    s.seller_city,
    p.product_category_name,
    SUM(oi.price) AS total_revenue,
    COUNT(*) AS total_sales,
    RANK() OVER (
        PARTITION BY p.product_category_name,
        s.seller_state,
        s.seller_city
        ORDER BY
            SUM(oi.price) DESC
    ) AS seller_rank
FROM
    order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY
    s.seller_id,
    s.seller_state,
    s.seller_city,
    p.product_category_name
ORDER BY
    p.product_category_name,
    s.seller_state,
    s.seller_city,
    seller_rank;

-- Average Order Value by Payment Method and Number of Installments---
SELECT
    payment_type,
    payment_installments,
    COUNT(*) AS total_transactions,
    SUM(payment_value) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_order_value
FROM
    order_payments
GROUP BY
    payment_type,
    payment_installments
ORDER BY
    payment_type,
    payment_installments;

-- Annual Breakdown of Orders, Revenue, Customers, Products, and Sellers---
SELECT
    year(o.order_approved_at) AS year,
    count(oi.order_id) AS total_orders,
    (sum(price) + sum(freight_value)) AS total_revenue,
    count(DISTINCT o.customer_id) AS unique_customers,
    count(DISTINCT oi.product_id) AS unique_products,
    count(DISTINCT oi.seller_id) AS unique_sellers
FROM
    orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
where
    order_approved_at is not null
group by
    year;

--Top Customer and Seller Cities by Order Volume---
SELECT
    (
        SELECT
            s.seller_city
        FROM
            order_items oi
            JOIN sellers s ON oi.seller_id = s.seller_id
        GROUP BY
            s.seller_city
        HAVING
            COUNT(*) = (
                SELECT
                    MAX(city_count)
                FROM (
                    SELECT
                        s2.seller_city,
                        COUNT(*) AS city_count
                    FROM
                        order_items oi2
                        JOIN sellers s2 ON oi2.seller_id = s2.seller_id
                    GROUP BY
                        s2.seller_city
                ) AS seller_counts
            )
        LIMIT 1
    ) AS popular_seller_city,
    (
        SELECT
            c.customer_city
        FROM
            orders o
            JOIN order_items oi ON o.order_id = oi.order_id
            JOIN customers c ON o.customer_id = c.customer_id
        GROUP BY
            c.customer_city
        HAVING
            COUNT(*) = (
                SELECT
                    MAX(city_count)
                FROM (
                    SELECT
                        c2.customer_city,
                        COUNT(*) AS city_count
                    FROM
                        orders o2
                        JOIN order_items oi2 ON o2.order_id = oi2.order_id
                        JOIN customers c2 ON o2.customer_id = c2.customer_id
                    GROUP BY
                        c2.customer_city
                ) AS customer_counts
            )
        LIMIT 1
    ) AS popular_customer_city;

--Compare Seller Revenue Against Average Revenue in the Same City---
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    SUM(oi.price) AS seller_revenue
FROM
    sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
HAVING
    SUM(oi.price) > (
        SELECT
            AVG(city_totals.total_revenue)
        FROM
            (
                SELECT
                    s2.seller_id,
                    SUM(oi2.price) AS total_revenue
                FROM
                    sellers s2
                    JOIN order_items oi2 ON s2.seller_id = oi2.seller_id
                WHERE
                    s2.seller_city = s.seller_city
                    AND s2.seller_id != s.seller_id
                GROUP BY
                    s2.seller_id
            ) AS city_totals
    )
ORDER BY
    seller_revenue DESC
LIMIT
    10;

--Average, Max, and Min Delivery Time per Individual Product---
SELECT
    p.product_id,
    p.product_name,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_approved_at
            )
        ),
        2
    ) AS avg_delivery_days,
    MAX(
        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_approved_at
        )
    ) AS max_delivery_days,
    MIN(
        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_approved_at
        )
    ) AS min_delivery_days,
    COUNT(*) AS total_orders
FROM
    orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
WHERE
    o.order_delivered_customer_date IS NOT NULL
    AND o.order_approved_at IS NOT NULL
    AND o.order_delivered_customer_date > o.order_approved_at
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    avg_delivery_days DESC;

--Customer Segmentation Based on Order Count, Spending, and Recency
---
SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.price + oi.freight_value) AS total_spent,
    DATEDIFF(CURRENT_DATE, MAX(o.order_approved_at)) AS days_since_last_order,
    CASE
        WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-time Buyer'
        WHEN SUM(oi.price + oi.freight_value) >= 1000 THEN 'High-Value Buyer'
        WHEN COUNT(DISTINCT o.order_id) >= 5
        AND DATEDIFF(CURRENT_DATE, MAX(o.order_approved_at)) <= 30 THEN 'Frequent & Recent Buyer'
        WHEN DATEDIFF(CURRENT_DATE, MAX(o.order_approved_at)) > 90 THEN 'Inactive Buyer'
        ELSE 'Regular Buyer'
    END AS customer_segment
FROM
    orders o
    JOIN order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_approved_at IS NOT NULL
GROUP BY
    o.customer_id
ORDER BY
    total_spent DESC;