-- 1) Поиск дубликатов по order_id
SELECT order_id, count(*) AS cnt
FROM stg_orders
GROUP BY order_id
HAVING count(*) > 1;

-- Ожидаемый результат: пустая выборка (дубликатов нет).

-- 2) Аномальные значения quantity и unit_price
SELECT order_id, quantity, unit_price, line_total
FROM stg_orders
WHERE quantity > 10000
   OR quantity < 0
   OR unit_price > 1000000
   OR unit_price < 0;

-- Ожидаемый результат: пустая выборка.
-- При наличии строк — обсудить с предметным экспертом допустимые диапазоны.

-- 3) Даты вне допустимого диапазона
SELECT order_id, order_date
FROM stg_orders
WHERE order_date < '2020-01-01'
   OR order_date > current_date;

-- Ожидаемый результат: пустая выборка.
-- Даты в будущем или слишком старые указывают на ошибку в источнике.

-- 4) Неизвестные product_code (топ значений)
SELECT product_code, count(*) AS cnt
FROM stg_orders
GROUP BY product_code
ORDER BY cnt DESC;

-- Тестировщик сверяет список с эталонным справочником продуктов.
-- Незнакомые коды — потенциальная ошибка маппинга.

-- 5) Распределение заказов по source_system и дате
SELECT source_system, order_date, count(*) AS orders_count
FROM stg_orders
GROUP BY source_system, order_date
ORDER BY order_date, source_system;

-- Тестировщик проверяет: нет ли «пустых» дней, резких скачков,
-- непропорционального распределения между источниками.
