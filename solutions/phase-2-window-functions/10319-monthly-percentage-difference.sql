-- Monthly Percentage Difference   (StrataScratch #10319  ·  Hard)
-- Phase 2 — Window Functions & Advanced Joins   (Phase 2 capstone)
--
-- Problem:
--   Month-over-month % change in revenue. Output YYYY-MM and the % change,
--   rounded to 2 dp, sorted chronologically. Populated from the 2nd month on.
--
-- Approach / what I learned:
--   The time-series pattern (distinct from a CASE pivot): CTE1 GROUP BY month with
--   SUM -> one row per month; CTE2 LAG(revenue) OVER (ORDER BY month) walks down the
--   chronological rows to pull the previous month onto the current row; final computes
--   the % change. Algebra shortcut: (revenue/prev - 1)*100 == ((revenue-prev)/prev)*100.
--   TO_CHAR(date,'YYYY-MM') is zero-padded so it sorts chronologically. The first month
--   has no previous, so LAG returns NULL and its % is NULL -- correct and expected.
--   Note to self: ROUND(...,2) and an explicit final ORDER BY are what the spec asked
--   for -- add them even when a lenient grader would pass without.

WITH monthly_rev AS (
    SELECT TO_CHAR(created_at, 'YYYY-MM') AS year_month,
           SUM(value) AS revenue
    FROM sf_transactions
    GROUP BY 1
),
rev_change AS (
    SELECT year_month,
           revenue,
           LAG(revenue) OVER (ORDER BY year_month) AS prev_revenue
    FROM monthly_rev
)
SELECT year_month,
       ROUND(((revenue * 1.0 / prev_revenue) - 1) * 100, 2) AS perct_mom
FROM rev_change
ORDER BY year_month;
