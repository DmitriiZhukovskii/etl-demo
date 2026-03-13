# Интеграционный хаб + ETL — Практическая часть

Проект, реализующий процессы автоматизированного тестирования ETL-конвейера на базе **dbt + PostgreSQL + Docker Compose + GitHub Actions**.

## Описание тестов

### Встроенные dbt-тесты (schema.yml)

| Модель              | Столбец        | Тест               | Что проверяет                            |
|---------------------|----------------|--------------------|------------------------------------------|
| stg_orders          | order_id                          | unique, not_null        | Уникальность и заполненность PK            |
| stg_orders          | customer_id                       | not_null, relationships | FK -> stg_customers                        |
| stg_orders          | source_system                     | accepted_values         | Только допустимые источники (ERP_A, CRM_B) |
| stg_orders          | quantity, unit_price, line_total  | not_null                | Заполненность числовых полей               |
| stg_customers       | customer_id                       | unique, not_null        | Уникальность и заполненность PK            |
| stg_customers       | customer_name                     | not_null                | Заполненность имени                        |
| mart_customer_orders| customer_id                       | unique, not_null        | Уникальность клиента в витрине             |
| mart_customer_orders| total_orders, total_revenue       | not_null                | Заполненность агрегатов                    |

### Кастомные data-тесты (tests/)

| Файл                          | Что проверяет                                                |
|-------------------------------|--------------------------------------------------------------|
| assert_line_total_correct.sql | `line_total == quantity * unit_price` для каждой строки       |
| assert_no_revenue_loss.sql    | Суммарная выручка в staging совпадает с витриной (без потерь) |

## Локальный запуск

### 1. Поднять PostgreSQL

```bash
docker compose up -d
```

### 2. Установить dbt

```bash
pip install dbt-postgres~=1.7
```

### 3. Запустить конвейер

```bash
cd dbt_project

# Проверка подключения
dbt debug --profiles-dir .

# Загрузка данных
dbt seed --profiles-dir .

# Сборка моделей
dbt run --profiles-dir .

# Запуск всех тестов
dbt test --profiles-dir .
```

## CI/CD — GitHub Actions

При каждом `push` или `pull request` в ветку `main` автоматически выполняется пайплайн (`.github/workflows/dbt-ci.yml`):

1. Поднимается PostgreSQL как service container.
2. Устанавливается Python 3.11 и dbt-postgres.
3. Выполняется `dbt debug` -> `dbt seed` -> `dbt run` -> `dbt test`.
4. При падении любого теста - merge блокируется.

## Процесс ручного тестирования

Каталог `manual_tests/` содержит SQL-скрипты и чек-лист, реализующие все виды ручного тестирования из теоретической части:

1. **Проверка маппинга** (`01_field_mapping.sql`) — тестировщик сравнивает структуру и выборочные данные источника и staging-модели.
2. **Сверка итогов** (`02_row_count_reconciliation.sql`, `03_revenue_reconciliation.sql`) — сравнение количества записей и сумм между слоями raw -> staging -> mart.
3. **Исследовательское тестирование** (`04_data_quality_exploration.sql`) — поиск дубликатов, аномальных значений, дат вне диапазона, неизвестных кодов.
4. **Приёмочное тестирование / UAT** (`05_uat_mart_review.sql`) — бизнес-пользователь просматривает витрину и выборочно сверяет с источником.

### Порядок проведения

```bash
# 1. Подготовить окружение
docker compose up -d
cd dbt_project && dbt seed --profiles-dir . && dbt run --profiles-dir .

# 2. Подключиться к БД
psql -h localhost -U dbt_user -d etl_hub

# 3. Выполнить скрипты из manual_tests/ по порядку, заполняя CHECKLIST.md

# 4. При обнаружении дефекта — создать Issue по шаблону
```
