WITH cohort AS (  -- Определяем когорту по месяцу регистрации
    SELECT 
        u.user_id,
        DATE_TRUNC('month', MIN(u.entry_at)) AS cohort_month,
        MIN(u.entry_at) AS date_joined
    FROM userentry u
    GROUP BY u.user_id
    HAVING DATE_PART('year', MIN(u.entry_at)) = 2022  -- Только 2022 год
),
monetization AS (
    -- Определяем, тратил ли пользователь CodeCoins
    SELECT 
        t.user_id,
        CASE 
            WHEN SUM(CASE WHEN tt.type IN (1, 23, 24, 25, 26, 27, 28) THEN 1 ELSE 0 END) > 0 
            THEN 'Платящий'
            ELSE 'Бесплатный'
        END AS payment_group
    FROM transaction t
    JOIN transactiontype tt ON t.type_id = tt.type
    GROUP BY t.user_id
),
activity AS (
    -- Определяем разницу в днях между входами пользователя и его регистрацией
    SELECT 
        u.user_id,
        c.cohort_month,
        m.payment_group,
        c.date_joined,
        DATE(u.entry_at) AS entry_at,
        EXTRACT(DAY FROM u.entry_at - c.date_joined) AS diff
    FROM userentry u
    JOIN cohort c ON u.user_id = c.user_id
    LEFT JOIN monetization m ON u.user_id = m.user_id
),
retention_calc AS (
    -- Считаем Rolling Retention по группам пользователей
    SELECT 
        a.cohort_month,
        a.payment_group,
        COUNT(DISTINCT a.user_id) AS total_users,
        COUNT(DISTINCT CASE WHEN a.diff >= 7 THEN a.user_id END) * 100.0 / COUNT(DISTINCT a.user_id) AS "7 дней (%)",
        COUNT(DISTINCT CASE WHEN a.diff >= 30 THEN a.user_id END) * 100.0 / COUNT(DISTINCT a.user_id) AS "30 дней (%)",
        COUNT(DISTINCT CASE WHEN a.diff >= 90 THEN a.user_id END) * 100.0 / COUNT(DISTINCT a.user_id) AS "90 дней (%)"
    FROM activity a
    WHERE a.payment_group IS NOT NULL -- Убираем пустые значения
    GROUP BY a.cohort_month, a.payment_group
)
SELECT 
    TO_CHAR(cohort_month, 'YYYY-MM') AS "Месяц",
    payment_group AS "Группа пользователей",
    ROUND("7 дней (%)", 2) AS "7 дней (%)",
    ROUND("30 дней (%)", 2) AS "30 дней (%)",
    ROUND("90 дней (%)", 2) AS "90 дней (%)"
FROM retention_calc
ORDER BY cohort_month, payment_group;
