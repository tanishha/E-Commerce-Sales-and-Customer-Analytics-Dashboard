--Total revenue by customer--
EXPLAIN FORMAT = JSON WITH order_revenue AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_revenue
    FROM
        order_items
    WHERE
        price IS NOT NULL
    GROUP BY
        order_id
)
SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    SUM(orv.order_revenue) AS total_revenue
FROM
    customers c
    INNER JOIN orders o ON o.customer_id = c.customer_id
    INNER JOIN order_revenue orv ON orv.order_id = o.order_id
GROUP BY
    c.customer_id,
    c.customer_city,
    c.customer_state
ORDER BY
    total_revenue DESC;

--Co - Purchased Product Pairs--
EXPLAIN FORMAT = JSON WITH valid_items AS (
    SELECT
        oi.order_id,
        oi.product_id,
        p.product_name
    FROM
        order_items oi
        JOIN products p ON oi.product_id = p.product_id
    WHERE
        p.product_name <> '#N/A'
)
SELECT
    LEAST(v1.product_name, v2.product_name) AS product_1,
    GREATEST(v1.product_name, v2.product_name) AS product_2,
    COUNT(*) AS times_bought_together
FROM
    valid_items v1
    JOIN valid_items v2 ON v1.order_id = v2.order_id
    AND v1.product_id < v2.product_id
GROUP BY
    product_1,
    product_2
ORDER BY
    times_bought_together DESC;

--Identify Customers by Days Since Last Order--
EXPLAIN FORMAT = JSON WITH last_order AS (
    SELECT
        customer_id,
        MAX(order_approved_at) AS last_order_date
    FROM
        orders
    WHERE
        order_approved_at IS NOT NULL
    GROUP BY
        customer_id
)
SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    lo.last_order_date,
    DATEDIFF(CURRENT_DATE, lo.last_order_date) AS days_since_last_order
FROM
    customers c
    JOIN last_order lo USING (customer_id)
ORDER BY
    days_since_last_order DESC;

--Rank Sellers by Revenue and Sales within Product Categories and Regions--
EXPLAIN FORMAT = JSON WITH seller_revenue AS (
    SELECT
        oi.seller_id,
        p.product_category_name,
        SUM(oi.price) AS total_revenue,
        COUNT(*) AS total_sales
    FROM
        order_items oi
        JOIN products p ON oi.product_id = p.product_id
    GROUP BY
        oi.seller_id,
        p.product_category_name
)
SELECT
    sr.seller_id,
    s.seller_state,
    s.seller_city,
    sr.product_category_name,
    sr.total_revenue,
    sr.total_sales,
    RANK() OVER (
        PARTITION BY sr.product_category_name,
        s.seller_state,
        s.seller_city
        ORDER BY
            sr.total_revenue DESC
    ) AS seller_rank
FROM
    seller_revenue sr
    JOIN sellers s ON sr.seller_id = s.seller_id
ORDER BY
    sr.product_category_name,
    s.seller_state,
    s.seller_city,
    seller_rank;

-- Average Order Value by Payment Method and Number of Installments--
EXPLAIN FORMAT = JSON WITH filtered AS (
    SELECT
        payment_type,
        payment_installments,
        payment_value
    FROM
        order_payments
    WHERE
        payment_value IS NOT NULL
)
SELECT
    payment_type,
    payment_installments,
    COUNT(*) AS total_transactions,
    SUM(payment_value) AS total_payment_value,
    ROUND(SUM(payment_value) / COUNT(*), 2) AS avg_order_value
FROM
    filtered
GROUP BY
    payment_type,
    payment_installments
ORDER BY
    payment_type,
    payment_installments;

-- Annual Breakdown of Orders, Revenue, Customers, Products, and Sellers--
EXPLAIN FORMAT = JSON WITH orders_valid AS (
    SELECT
        order_id,
        YEAR(order_approved_at) AS yr,
        customer_id
    FROM
        orders
    WHERE
        order_approved_at IS NOT NULL
)
SELECT
    ov.yr AS year,
    COUNT(oi.order_id) AS total_orders,
    SUM(oi.price + oi.freight_value) AS total_revenue,
    COUNT(DISTINCT ov.customer_id) AS unique_customers,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    COUNT(DISTINCT oi.seller_id) AS unique_sellers
FROM
    orders_valid ov
    JOIN order_items oi ON oi.order_id = ov.order_id
GROUP BY
    ov.yr
ORDER BY
    ov.yr;

--Top Customer and Seller Cities by Order Volume--
EXPLAIN FORMAT = JSON WITH seller_ct AS (
    SELECT
        s.seller_city,
        COUNT(*) AS cnt
    FROM
        order_items oi
        JOIN sellers s ON oi.seller_id = s.seller_id
    GROUP BY
        s.seller_city
),
cust_ct AS (
    SELECT
        c.customer_city,
        COUNT(*) AS cnt
    FROM
        orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY
        c.customer_city
)
SELECT
    (
        SELECT
            seller_city
        FROM
            seller_ct
        ORDER BY
            cnt DESC
        LIMIT
            1
    ) AS popular_seller_city,
    (
        SELECT
            customer_city
        FROM
            cust_ct
        ORDER BY
            cnt DESC
        LIMIT
            1
    ) AS popular_customer_city;

--Compare Seller Revenue Against Average Revenue in the Same City--
EXPLAIN FORMAT = JSON WITH city_avg AS (
    SELECT
        seller_city,
        AVG(total_revenue) AS avg_rev
    FROM
        (
            SELECT
                s2.seller_city,
                s2.seller_id,
                SUM(oi2.price) AS total_revenue
            FROM
                sellers s2
                JOIN order_items oi2 ON s2.seller_id = oi2.seller_id
            GROUP BY
                s2.seller_city,
                s2.seller_id
        ) t
    GROUP BY
        seller_city
)
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    sr.seller_revenue
FROM
    (
        SELECT
            seller_id,
            SUM(price) AS seller_revenue
        FROM
            order_items
        GROUP BY
            seller_id
    ) sr
    JOIN sellers s ON sr.seller_id = s.seller_id
    JOIN city_avg ca ON s.seller_city = ca.seller_city
WHERE
    sr.seller_revenue > ca.avg_rev
ORDER BY
    sr.seller_revenue DESC
LIMIT
    10;

--Average, Max, and Min Delivery Time per Individual Product--
EXPLAIN FORMAT = JSON WITH order_date AS (
    SELECT
        oi.product_id,
        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_approved_at
        ) AS diff_days
    FROM
        orders o
        JOIN order_items oi ON o.order_id = oi.order_id
    WHERE
        o.order_delivered_customer_date > o.order_approved_at
)
SELECT
    p.product_id,
    p.product_name,
    ROUND(AVG(d.diff_days), 2) AS avg_delivery_days,
    MAX(d.diff_days) AS max_delivery_days,
    MIN(d.diff_days) AS min_delivery_days,
    COUNT(*) AS total_orders
FROM
    order_date d
    JOIN products p ON d.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    avg_delivery_days DESC;

--Customer Segmentation Based on Order Count, Spending, and Recency
--
EXPLAIN FORMAT = JSON WITH customer_metrics AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.price + oi.freight_value) AS total_spent,
        DATEDIFF(CURRENT_DATE, MAX(o.order_approved_at)) AS days_since_last_order
    FROM
        orders o
        JOIN order_items oi ON o.order_id = oi.order_id
    WHERE
        o.order_approved_at IS NOT NULL
    GROUP BY
        o.customer_id
)
SELECT
    customer_id,
    order_count,
    total_spent,
    days_since_last_order,
    CASE
        WHEN order_count = 1 THEN 'One-time Buyer'
        WHEN total_spent >= 1000 THEN 'High-Value Buyer'
        WHEN order_count >= 5
        AND days_since_last_order <= 30 THEN 'Frequent & Recent Buyer'
        WHEN days_since_last_order > 90 THEN 'Inactive Buyer'
        ELSE 'Regular Buyer'
    END AS customer_segment
FROM
    customer_metrics
ORDER BY
    total_spent DESC;