-- CAPSTONE (#50) — Top Customer Per Region + Revenue Concentration
-- (Self-authored · Hard · Capstone)   [solved BLIND / cold-start]
-- Phase 3 — CTEs & Set Logic   |   the 50th and final solve of the roadmap
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   From orders(order_id, region, customer_id, amount), for each region return its top-
--   spending customer, that customer's spend, the region's total revenue, and the top
--   customer's share of the region (%). One row per region; ties -> lower customer_id.
--
-- Approach / what I learned (SYNTHESIS — chain patterns already mastered):
--   The whole lesson of the capstone: AGGREGATE and WINDOW in SEPARATE LAYERS.
--   Trying to do both in one SELECT forces `amount` into the GROUP BY, which collapses a
--   customer's repeated same-value orders and silently loses revenue. So:
--     1. CTE 1 (aggregate only): GROUP BY region, customer_id -> SUM(amount) AS spend.
--        No window functions here at all.
--     2. CTE 2 (window only): ROW_NUMBER() OVER (PARTITION BY region ORDER BY spend DESC,
--        customer_id) to find #1 (deterministic tie-break), and SUM(spend) OVER
--        (PARTITION BY region) for the region total next to every row.
--     3. Filter rn = 1, then share = spend * 100.0 / region_total.
--   Patterns combined: aggregation (Phase 1) + top-N-per-group (Day 32) + deterministic
--   ranking / one-winner (Day 33) + window-as-denominator / percent-of-total (Day 35).
--   Snowflake note: compute the share in the FINAL select, don't reference a window alias
--   in the same SELECT that defines it (DuckDB allows it; Snowflake/Postgres don't).

WITH cust_spend AS (                                -- 1. aggregate ONLY: one row per (region, customer)
  SELECT region, customer_id, SUM(amount) AS spend
  FROM orders
  GROUP BY region, customer_id
),
ranked AS (                                         -- 2. window ONLY: rank + region total in one pass
  SELECT region, customer_id, spend,
         SUM(spend)   OVER (PARTITION BY region)                                  AS region_total,
         ROW_NUMBER() OVER (PARTITION BY region ORDER BY spend DESC, customer_id) AS rn
  FROM cust_spend
)
SELECT region,
       customer_id  AS top_customer,
       spend        AS customer_spend,
       region_total,
       ROUND(spend * 100.0 / region_total, 2) AS pct_of_region
FROM ranked
WHERE rn = 1
ORDER BY region;
