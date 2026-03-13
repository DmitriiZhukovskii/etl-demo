-- 1) Полный обзор витрины — бизнес-пользователь проверяет корректность данных
SELECT
    customer_id,
    customer_name,
    region,
    total_orders,
    total_revenue,
    first_order_date,
    last_order_date
FROM mart_customer_orders
ORDER BY total_revenue DESC;

-- Бизнес-пользователь проверяет:
--   • Все ли клиенты присутствуют?
--   • Корректны ли имена и регионы?
--   • Правдоподобны ли суммы?

-- 2) Выборочная детальная проверка для конкретного клиента
-- (подставить customer_id интересующего клиента)
SELECT
    o.order_id,
    o.product_code,
    o.quantity,
    o.unit_price,
    o.line_total,
    o.order_date,
    o.source_system
FROM stg_orders o
WHERE o.customer_id = 101
ORDER BY o.order_date;

-- Бизнес-пользователь сверяет с данными в системе-источнике (ERP/CRM)
-- и подтверждает корректность каждой строки.

-- 3) Клиенты без заказов (если такие не ожидаются — это дефект)
SELECT customer_id, customer_name, region
FROM mart_customer_orders
WHERE total_orders = 0;

-- Ожидаемый результат зависит от бизнес-требований:
-- если все клиенты в справочнике должны иметь хотя бы один заказ — выборка пустая.
