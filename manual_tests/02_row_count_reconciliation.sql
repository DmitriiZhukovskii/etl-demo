-- 1) Общее количество записей
SELECT
    (SELECT count(*) FROM raw_orders)     AS raw_count,
    (SELECT count(*) FROM stg_orders)     AS staging_count;

-- Ожидаемый результат: числа совпадают (при условии, что все записи проходят фильтрацию).
-- Если staging_count < raw_count — проверить фильтры в stg_orders.sql (quantity > 0, unit_price > 0).

-- 2) Количество записей в разрезе source_system
SELECT source_system, count(*) AS cnt
FROM raw_orders
GROUP BY source_system
ORDER BY source_system;

SELECT source_system, count(*) AS cnt
FROM stg_orders
GROUP BY source_system
ORDER BY source_system;

-- Тестировщик сравнивает результаты двух запросов.
-- Расхождения указывают на проблемы с конкретным источником.

-- 3) Количество уникальных клиентов
SELECT
    (SELECT count(DISTINCT customer_id) FROM raw_orders)    AS raw_customers,
    (SELECT count(DISTINCT customer_id) FROM stg_orders)    AS staging_customers,
    (SELECT count(DISTINCT customer_id) FROM stg_customers) AS ref_customers;

-- Ожидаемый результат: raw_customers <= ref_customers (все клиенты из заказов есть в справочнике).
