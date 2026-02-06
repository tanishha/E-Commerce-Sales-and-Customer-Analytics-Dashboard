-- Single Indexes --
CREATE INDEX idx_orders_customers ON orders (customer_id);

CREATE INDEX idx_order_items_orders ON order_items(order_id);

CREATE INDEX idx_order_items_product ON order_items(product_id);

CREATE INDEX idx_order_items_seller ON order_items(seller_id);

CREATE INDEX idx_orders_approved_at ON orders(order_approved_at);

CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Composite Indexes --
CREATE INDEX idx_orders_customer_approved ON orders(customer_id, order_approved_at);

CREATE INDEX idx_order_items_order_product ON order_items(order_id, product_id);

CREATE INDEX idx_products_product_id_cat ON products(product_id, product_category_name);

CREATE INDEX idx_sellers_id_city_state ON sellers(seller_id, seller_city, seller_state);

CREATE INDEX idx_oi_prod_seller ON order_items(product_id, seller_id, price);

CREATE INDEX idx_payments_type_install ON order_payments(
    payment_type,
    payment_installments,
    payment_value
);

CREATE INDEX idx_oi_order_price_freight ON order_items(order_id, price, freight_value);

CREATE INDEX idx_sellers_id_city ON sellers(seller_id, seller_city);

CREATE INDEX idx_customers_id_city ON customers(customer_id, customer_city);

CREATE INDEX idx_oi_seller_price ON order_items(seller_id, price);

CREATE INDEX idx_products_id_name ON products(product_id, product_name);

CREATE INDEX idx_orders_delivered_approved ON orders(order_delivered_customer_date, order_approved_at);

CREATE INDEX idx_sellers_city ON sellers(seller_city, seller_id);

-- Partial Indexes --
CREATE INDEX idx_oi_price_notnull ON order_items(order_id)
WHERE
    price IS NOT NULL;

CREATE INDEX idx_valid_products ON products(product_id)
WHERE
    product_name != '#N/A';

CREATE INDEX idx_orders_valid_approved ON orders(customer_id)
WHERE
    order_approved_at IS NOT NULL;

CREATE INDEX idx_payments_value_gt0 ON order_payments(payment_type)
WHERE
    payment_value > 0;

CREATE INDEX idx_orders_approved_not_null ON orders(order_id)
WHERE
    order_approved_at IS NOT NULL;