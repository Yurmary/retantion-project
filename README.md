# Анализ метрики retention

## Цель проекта
Анализ метрики retention, выявление факторов, влияющих на удержание, и разработка продуктовых решений для его улучшения.

## Структура репозитория
- `sql_queries`: папка с SQL-запросами для анализа retention.
- `analysis`: папка с аналитическими заметками и выводами.
- `data_sources`: описание источников данных.
- `docs`: дополнительные документы и README-файл.

## Описание запросов
- `query_1_activity_impact_on_retention.sql`: проверка гипотезы о влиянии активности в первую неделю на retention.
- `query_2_task_solving_impact_on_retention.sql`: проверка гипотезы о влиянии количества решённых задач на retention.
- `query_3_monetization_impact_on_retention.sql`: проверка гипотезы о влиянии монетизации на retention.
- `query_4_churn_rate_analysis.sql`: анализ Churn Rate за 2022 год.

## Гипотезы и используемые метрики

### Гипотеза 1: Активность в первую неделю повышает retention
- **Метрика:** Rolling Retention (7, 30, 90 дней)
- **Связь:** Если пользователи, активно заходящие в первые 7 дней, показывают более высокий retention, значит, первые дни критически важны для вовлечения.

### Гипотеза 2: Чем больше задач решил пользователь, тем выше retention
- **Метрика:** Rolling Retention (7, 30, 90 дней)
- **Связь:** Если пользователи, решившие хотя бы одну задачу, показывают более высокий retention, то вовлечённость в решение задач влияет на удержание.

### Гипотеза 3: Монетизация влияет на retention
- **Метрика:** Rolling Retention (7, 30, 90 дней)
- **Связь:** Если retention выше у пользователей, которые тратят CodeCoins, значит, платежи создают дополнительную вовлечённость.

### Гипотеза 4: Churn Rate за 2022 год
- **Метрика:** Churn Rate (30, 60, 90 дней)
- **Связь:** Оценивает уровень оттока пользователей через 30, 60 и 90 дней после регистрации. Высокий Churn Rate говорит о проблемах с удержанием.

## Источники данных
- **UserEntry:** Лог заходов пользователей на платформу.
- **Users:** Данные о пользователях: регистрация, активность.
- **CodeSubmit:** Попытки пользователей решить задачи.
- **Transaction:** Транзакции пользователей, связанные с CodeCoins.

## Результаты анализа
Подробно описаны результаты проверки каждой гипотезы. Приведены ключевые тенденции и закономерности.

## Продуктовые решения для повышения retention
- Увеличение вовлечённости в первые 7 дней.
- Стимулирование пользователей решать задачи.
- Улучшение монетизации.
- Снижение Churn Rate.

## Ссылка на дашборд
[Ссылка на дашборд](https://metabase.simulative.ru/dashboard/477-retention-project?tab=154-tab-1)
