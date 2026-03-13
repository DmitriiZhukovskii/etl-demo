-- 1) Структура исходной таблицы (seed)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'raw_orders'
ORDER BY ordinal_position;

-- Ожидаемый результат:
-- Все поля источника присутствуют и имеют корректные типы

-- 2) Структура staging-модели
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'stg_orders'
ORDER BY ordinal_position;

-- Ожидаемый результат:
-- raw_orders содержит: order_id, customer_id, product_code, quantity, unit_price, order_date, source_system
-- stg_orders содержит те же поля + вычисляемое поле line_total
-- Типы данных: order_date -> date, числовые поля -> numeric
-- Тестировщик сравнивает два результата и убеждается в полноте маппинга.

-- 3) Выборочная проверка: 5 записей источника vs staging
SELECT 'raw' AS layer, order_id, product_code, quantity, unit_price, order_date
FROM raw_orders
ORDER BY order_id LIMIT 5;

SELECT 'stg' AS layer, order_id, product_code, quantity, unit_price, order_date
FROM stg_orders
ORDER BY order_id LIMIT 5;

-- Ожидаемый результат: product_code в staging приведён к верхнему регистру,
-- order_date имеет тип date, остальные значения совпадают.
