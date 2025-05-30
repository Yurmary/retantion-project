WITH cohort AS (
    -- Определяем когорту пользователей по месяцу регистрации (только 2022 год)
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(entry_at)) AS cohort_month,
        MIN(entry_at) AS date_joined
    FROM userentry
    WHERE user_id >= 94
    GROUP BY user_id
    HAVING DATE_PART('year', MIN(entry_at)) = 2022 -- Фильтр на 2022 год
),
activity_status AS (
    -- Определяем активных и неактивных пользователей по заходам в первые 7 дней
    SELECT 
        ue.user_id,
        COUNT(DISTINCT CASE WHEN ue.entry_at <= c.date_joined + INTERVAL '7 days' THEN ue.entry_at END) AS visits_7d,
        CASE 
            WHEN COUNT(DISTINCT CASE WHEN ue.entry_at <= c.date_joined + INTERVAL '7 days' THEN ue.entry_at END) >= 3 THEN 'Активные'
            ELSE 'Неактивные'
        END AS activity_group
    FROM userentry ue
    JOIN cohort c ON ue.user_id = c.user_id
    GROUP BY ue.user_id
),
activity AS (
    -- Определяем разницу в днях между входами пользователя и его регистрацией
    SELECT 
        ue.user_id,
        c.cohort_month,
        a.activity_group,
        c.date_joined,
        DATE(ue.entry_at) AS entry_at,
        EXTRACT(DAY FROM ue.entry_at - c.date_joined) AS diff
    FROM userentry ue
    JOIN cohort c ON ue.user_id = c.user_id
    LEFT JOIN activity_status a ON ue.user_id = a.user_id
),
retention_calc AS (
    -- Считаем Rolling Retention только для 2022 года
    SELECT 
        a.cohort_month,
        a.activity_group,
        COUNT(DISTINCT a.user_id) AS total_users,
        COUNT(DISTINCT CASE WHEN a.diff >= 7 THEN a.user_id END) * 100.0 / COUNT(DISTINCT a.user_id) AS "7 дней (%)",
        COUNT(DISTINCT CASE WHEN a.diff >= 30 THEN a.user_id END) * 100.0 / COUNT(DISTINCT a.user_id) AS "30 дней (%)",
        COUNT(DISTINCT CASE WHEN a.diff >= 90 THEN a.user_id END) * 100.0 / COUNT(DISTINCT a.user_id) AS "90 дней (%)"
    FROM activity a
    WHERE a.activity_group IS NOT NULL  -- Исключаем пустые группы
    GROUP BY a.cohort_month, a.activity_group
)
SELECT 
    TO_CHAR(cohort_month, 'YYYY-MM') AS "Месяц",
    activity_group AS "Группа активности",
    ROUND("7 дней (%)", 2) AS "7 дней (%)",
    ROUND("30 дней (%)", 2) AS "30 дней (%)",
    ROUND("90 дней (%)", 2) AS "90 дней (%)"
FROM retention_calc
ORDER BY cohort_month, activity_group;
