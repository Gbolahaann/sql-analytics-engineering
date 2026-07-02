-- Rank Variance Per Country   (StrataScratch #2007  ·  Hard)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Rank countries by total comments in Dec 2019 and Jan 2020 (ties share a rank,
--   no skips). Return the countries whose rank improved (rank number got smaller).
--
-- Approach / what I learned:
--   Six stages across three CTEs: join -> totals per country per month (GROUP BY) ->
--   DENSE_RANK within each month -> CASE-pivot both months onto one row per country ->
--   filter jan_rank < dec_rank. Key insight: do NOT COALESCE a missing month's rank to 0.
--   Leaving it NULL means a country present in only one month yields NULL in the
--   comparison, which evaluates to NULL (not true) and is silently excluded -- exactly
--   the "must exist in both months" rule, for free. (COALESCE to '0' also forced a
--   string comparison, breaking ranks >= 10.)

WITH month_total AS (
    SELECT CONCAT(EXTRACT(YEAR FROM c.created_at), '-', EXTRACT(MONTH FROM c.created_at)) AS year_month,
           u.country,
           SUM(number_of_comments) AS total_comments
    FROM fb_comments_count c
    JOIN fb_active_users u ON c.user_id = u.user_id
    GROUP BY 1, 2
),
month_rank AS (
    SELECT year_month, country, total_comments,
           DENSE_RANK() OVER (PARTITION BY year_month ORDER BY total_comments DESC) AS rnk
    FROM month_total
    WHERE year_month IN ('2019-12', '2020-1')
),
country_rank AS (
    SELECT country,
           MAX(CASE WHEN year_month = '2019-12' THEN rnk END) AS dec_rank,
           MAX(CASE WHEN year_month = '2020-1'  THEN rnk END) AS jan_rank
    FROM month_rank
    GROUP BY 1
)
SELECT country
FROM country_rank
WHERE jan_rank < dec_rank;
