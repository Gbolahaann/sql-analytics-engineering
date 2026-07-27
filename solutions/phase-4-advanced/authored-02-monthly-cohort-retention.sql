-- Monthly Cohort Retention   (Self-authored · Hard)
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   From an orders table (customer_id, order_date, amount), put every customer in a
--   cohort by the month of their FIRST ever order. For each cohort, count how many of
--   those customers ordered again at month offsets 0-3, and express it as a percentage
--   of the cohort's original size. One row per cohort per offset.
--
-- Approach / what I learned:
--   Retention decomposes into three parts, each its own CTE:
--     1. ANCHOR    — cohort_month = date_trunc('month', MIN(order_date)) per customer.
--                    This CTE is at CUSTOMER grain: exactly one row per customer.
--     2. OFFSET    — for each active month, (year*12+month) of the active month minus
--                    (year*12+month) of the cohort month. Same monotonic-month trick as
--                    the streak question, doing a completely different job.
--     3. DENOMINATOR — cohort size is COUNT per cohort_month taken from ANCHOR, not
--                    from orders (orders has many rows per customer and would inflate it).
--   Key lessons:
--     * GRAIN is the whole problem. active_customers is per cohort+offset; cohort_size
--       is per cohort only. One GROUP BY cannot produce two grains, so the denominator
--       must be built separately and joined back. Tableau equivalent: a FIXED LOD.
--       Tell-tale sign: a column whose value repeats down the rows came from a coarser grain.
--     * Retention is NOT a streak. Gaps do not break it. A customer active at offset 0,
--       absent at 1, back at 2 is still retained at offset 2. That is why the January
--       cohort here holds flat at 50% instead of decaying monotonically.
--     * Offset 0 is always 100% by definition. Free correctness check on the anchor logic.
--     * Use COUNT(DISTINCT customer_id) so multiple orders in one month cannot double-count.
--     * 100.0 not 100 — integer division silently returns 0, so multiply by 100.0.
--   Debugging habit learned: to preview one CTE mid-build, highlight the chain and run the
--   selection. Never wedge a SELECT into the middle of a WITH chain (parser error).

WITH anchor AS (                                    -- CUSTOMER grain: one row per customer
  SELECT customer_id,
         date_trunc('month', MIN(order_date)) AS cohort_month
  FROM orders
  GROUP BY 1
),
offset_cte AS (                                     -- each active month, distance from cohort
  SELECT DISTINCT o.customer_id,
         a.cohort_month,
         date_trunc('month', o.order_date) AS active_month,
         EXTRACT(year FROM o.order_date) * 12 + EXTRACT(month FROM o.order_date)
           - (EXTRACT(year FROM a.cohort_month) * 12 + EXTRACT(month FROM a.cohort_month))
           AS month_offset
  FROM orders o
  JOIN anchor a ON o.customer_id = a.customer_id
),
customer_cohort AS (                                -- COHORT+OFFSET grain: the numerator
  SELECT cohort_month, month_offset,
         COUNT(DISTINCT customer_id) AS active_customers
  FROM offset_cte
  WHERE month_offset BETWEEN 0 AND 3
  GROUP BY 1, 2
),
cohort_size AS (                                    -- COHORT grain: the denominator
  SELECT cohort_month,
         COUNT(DISTINCT customer_id) AS cohort_size
  FROM anchor
  GROUP BY 1
)
SELECT cc.cohort_month,
       cc.month_offset,
       cc.active_customers,
       cs.cohort_size,
       ROUND(cc.active_customers * 100.0 / cs.cohort_size, 1) AS retention_pct
FROM customer_cohort cc
JOIN cohort_size cs ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.month_offset;
