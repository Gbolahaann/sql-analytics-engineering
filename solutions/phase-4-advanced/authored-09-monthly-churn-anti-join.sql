-- Monthly Churn   (Self-authored · Hard)
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   activity (user_id, activity_month) records the months each user was active. A user
--   churns in month M if active in M-1 but NOT in M. For each month, count churned users;
--   return only months with at least one churn. Output: churn_month, churned_users.
--
-- Approach / what I learned (churn = the ANTI-JOIN):
--   Churn is set subtraction: users active LAST month who are NOT in THIS month.
--     1. DISTINCT user_id, activity_month  (raw table can repeat) -> monthly_active.
--     2. For each active (user, month), the churn month is month + 1.
--     3. ANTI-JOIN: keep rows where the user does NOT appear the next month. Three
--        equivalent idioms: NOT EXISTS (reads like the sentence), LEFT JOIN ... WHERE
--        right IS NULL, or EXCEPT.
--   THE TRAP (analytics nuance): you cannot measure churn for the LAST month in the data,
--   because the month after it is not loaded yet -- everyone active in the final month
--   would look churned next month for no real reason. Guard with:
--       churn_month <= (SELECT MAX(activity_month) FROM ...)   -- <= not < !
--   (The boundary bit me: churn for the max month IS measurable; only the month AFTER the
--   data is not. So it's <=, keeping April, not < which drops it.)
--   Off-by-one to watch: the churn month is the month they FAILED to return = last active
--   month + 1, not the last active month itself.
--   Tableau bridge: no clean "not in the other set" natively, so churn/cohort logic is
--   modelled in SQL first, then visualised.

WITH monthly_active AS (
  SELECT DISTINCT user_id, activity_month AS m
  FROM activity
)
SELECT prev.m + INTERVAL 1 MONTH        AS churn_month,
       COUNT(DISTINCT prev.user_id)     AS churned_users
FROM monthly_active prev
WHERE NOT EXISTS (                       -- user did NOT return the following month
        SELECT 1 FROM monthly_active cur
        WHERE cur.user_id = prev.user_id
          AND cur.m = prev.m + INTERVAL 1 MONTH
      )
  AND prev.m + INTERVAL 1 MONTH <= (SELECT MAX(m) FROM monthly_active)  -- measurable only
GROUP BY 1
ORDER BY 1;
