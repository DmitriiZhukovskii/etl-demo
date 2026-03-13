-- 1) Суммарная выручка по слоям
SELECT
    (SELECT sum(quantity * unit_price) FROM raw_orders)    AS raw_revenue,
    (SELECT sum(line_total)            FROM stg_orders)    AS staging_revenue,
    (SELECT sum(total_revenue)         FROM mart_customer_orders) AS mart_revenue;

-- Ожидаемый результат: все три значения совпадают.

-- 2) Выручка по клиентам: staging vs mart
SELECT
    s.customer_id,
    s.stg_revenue,
    m.total_revenue AS mart_revenue,
    s.stg_revenue - m.total_revenue AS diff
FROM (
    SELECT customer_id, sum(line_total) AS stg_revenue
    FROM stg_orders
    GROUP BY customer_id
) s
JOIN mart_customer_orders m ON s.customer_id = m.customer_id
ORDER BY customer_id;

-- Ожидаемый результат: столбец diff = 0 для каждого клиента.
-- Ненулевые значения указывают на ошибку агрегации.

-- 3) Количество заказов по клиентам: staging vs mart
SELECT
    s.customer_id,
    s.stg_orders,
    m.total_orders AS mart_orders,
    s.stg_orders - m.total_orders AS diff
FROM (
    SELECT customer_id, count(*) AS stg_orders
    FROM stg_orders
    GROUP BY customer_id
) s
JOIN mart_customer_orders m ON s.customer_id = m.customer_id
ORDER BY customer_id;

-- Ожидаемый результат: diff = 0 для каждого клиента.
