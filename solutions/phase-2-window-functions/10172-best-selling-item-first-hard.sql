-- Best Selling Item (first Hard)   (StrataScratch #10172  ·  Hard)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Best-selling item per month (ignore year) by total paid = unitprice*quantity; exclude returns (negative qty / invoice starting 'C').
--
-- Approach / what I learned:
--   Full count → rank → filter skeleton. Stage 1: drop returns, EXTRACT month,
--   SUM(unitprice*quantity) per month+item. Stage 2: ROW_NUMBER PARTITION BY month ORDER BY
--   total DESC. Stage 3: keep rank=1. Note: 'remove A or B' becomes WHERE NOT A AND NOT B (De
--   Morgan).

WITH sales AS (
    SELECT EXTRACT(MONTH FROM invoicedate) AS "month",
           description,
           SUM(unitprice * quantity) AS total_paid
    FROM online_retail
    WHERE quantity >= 0 AND invoiceno NOT LIKE 'C%'
    GROUP BY 1, 2
),
ranked AS (
    SELECT month, description, total_paid,
           ROW_NUMBER() OVER (PARTITION BY month ORDER BY total_paid DESC) AS month_rank
    FROM sales
)
SELECT month, description, total_paid
FROM ranked
WHERE month_rank = 1;
