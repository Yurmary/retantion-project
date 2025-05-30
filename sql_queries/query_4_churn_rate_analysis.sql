WITH cohort AS (
    -- Определяем когорту по месяцу регистрации (фильтруем только 2022 год)
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(entry_at)) AS cohort_month
    FROM userentry
    GROUP BY user_id
    HAVING DATE_PART('year', MIN(entry_at)) = 2022  -- Фильтрация только для 2022 года
),
activity AS (
    -- Определяем разницу в днях между входами пользователя и его регистрацией
    SELECT 
        e.user_id,
        c.cohort_month,
        DATE(e.entry_at) AS entry_at,
        EXTRACT(DAY FROM e.entry_at - c.cohort_month) AS diff
    FROM userentry e
    JOIN cohort c ON e.user_id = c.user_id
),
churn_calc AS (
    -- Рассчитываем Retention Rate на 30, 60 и 90 дней
    SELECT 
        COUNT(DISTINCT user_id) AS total_users,
        COUNT(DISTINCT CASE WHEN diff >= 30 THEN user_id END) * 100.0 / COUNT(DISTINCT user_id) AS "30 дней Retention",
        COUNT(DISTINCT CASE WHEN diff >= 60 THEN user_id END) * 100.0 / COUNT(DISTINCT user_id) AS "60 дней Retention",
        COUNT(DISTINCT CASE WHEN diff >= 90 THEN user_id END) * 100.0 / COUNT(DISTINCT user_id) AS "90 дней Retention"
    FROM activity
)

SELECT 
    30 AS "days",
    ROUND(100 - "30 дней Retention", 2) AS "churn_rate"
FROM churn_calc

UNION ALL

SELECT 
    60 AS "days",
    ROUND(100 - "60 дней Retention", 2) AS "churn_rate"
FROM churn_calc

UNION ALL

SELECT 
    90 AS "days",
    ROUND(100 - "90 дней Retention", 2) AS "churn_rate"
FROM churn_calc;
