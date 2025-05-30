WITH cohort AS (
    -- Определяем когорту по месяцу регистрации (весь 2022 год)
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(entry_at)) AS cohort_month,
        MIN(entry_at) AS date_joined
    FROM userentry
    WHERE user_id >= 94
    GROUP BY user_id
    HAVING DATE_PART('year', MIN(entry_at)) = 2022  -- Фильтр на 2022 год),
problem_status AS (
    -- Определяем активность пользователя в решении задач за первые 7 дней
    SELECT 
        cs.user_id,
        COUNT(DISTINCT CASE WHEN cs.created_at <= c.date_joined + INTERVAL '7 days' THEN cs.problem_id END) AS total_attempts,
        COUNT(DISTINCT CASE WHEN cs.created_at <= c.date_joined + INTERVAL '7 days' AND cs.is_false = 0 THEN cs.problem_id END) AS total_solved
    FROM codesubmit cs
    JOIN cohort c ON cs.user_id = c.user_id
    GROUP BY cs.user_id
),
categorized_users AS (
    -- Группируем пользователей по вовлеченности в первые 7 дней
    SELECT 
        user_id,
        CASE 
            WHEN total_attempts = 0 THEN 'Не пробовал решать'
            WHEN total_attempts > 0 AND total_solved = 0 THEN 'Пробовал, но не решил'
            WHEN total_solved > 0 THEN 'Решил хотя бы 1 задачу'
        END AS activity_group
    FROM problem_status
),
activity AS (
    -- Определяем разницу в днях между входами пользователя и его регистрацией
    SELECT 
        u.user_id,
        c.cohort_month,
        cu.activity_group,
        c.date_joined,
        DATE(u.entry_at) AS entry_at,
        EXTRACT(DAY FROM u.entry_at - c.date_joined) AS diff
    FROM userentry u
    JOIN cohort c ON u.user_id = c.user_id
    LEFT JOIN categorized_users cu ON u.user_id = cu.user_id
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
    WHERE a.activity_group IS NOT NULL  -- Убираем пустые группы
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
