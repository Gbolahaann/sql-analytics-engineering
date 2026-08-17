-- Order Status Breakdown   (Self-authored · Hard)   [solved BLIND / cold-start]
-- Phase 3 — CTEs & Set Logic
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   From orders(order_id, customer_id, status), one row per customer with a count column
--   per status (completed / pending / cancelled), total orders, and completion_rate =
--   completed / total * 100 (2 dp).
--
-- Approach / what I learned (CONDITIONAL AGGREGATION = the PIVOT):
--   Put a CASE INSIDE an aggregate to count only the rows meeting a condition. Two
--   equivalent idioms, both correct:
--     COUNT(CASE WHEN status='completed' THEN order_id END)   -- COUNT ignores the NULLs
--     SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END)     -- non-matches add 0
--   One expression per status = one column per status, from a single GROUP BY customer_id.
--   total_orders = COUNT(*). completion_rate = completed / total, and MUST force decimals
--   (* 1.0 or * 100.0) or integer division floors sub-100% rates to 0. ROUND(..,2) per spec.
--   Polish notes to self (from review):
--     - Alias with double quotes or none, NOT single quotes (single = string literal in
--       Postgres/Snowflake).
--     - ROUND(rate, 2) so an ugly rate like 66.666 matches 66.67.
--   Tableau bridge: SUM(IIF(status=...,1,0)) calculated fields, or Status on Columns.

SELECT customer_id,
       COUNT(CASE WHEN status = 'completed' THEN order_id END) AS completed_orders,
       COUNT(CASE WHEN status = 'pending'   THEN order_id END) AS pending_orders,
       COUNT(CASE WHEN status = 'cancelled' THEN order_id END) AS cancelled_orders,
       COUNT(*) AS total_orders,
       ROUND(COUNT(CASE WHEN status = 'completed' THEN order_id END) * 100.0 / COUNT(*), 2)
         AS completion_rate
FROM orders
GROUP BY customer_id
ORDER BY customer_id;
