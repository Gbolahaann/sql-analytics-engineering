-- Percentage of Shipable Orders   (StrataScratch #10090  ·  Medium)
-- Phase 3 — CTEs & Set Logic   (NULL handling + conditional aggregation)
--
-- Problem:
--   Find the percentage of orders that are shipable. An order is shipable if the
--   customer's address is known (address IS NOT NULL).
--
-- Approach / what I learned:
--   "What fraction of X meets a condition" = conditional COUNT over total COUNT, floated
--   and scaled to 100. NULL rules that matter here: test with IS NOT NULL (never = NULL);
--   COUNT(CASE WHEN ... THEN o.id END) skips the NULL misses, giving the shipable count;
--   COUNT(o.id) is the denominator. LEFT JOIN from orders keeps every order in the
--   denominator even if a customer row is missing (that order is just not shipable).
--   Staged with a CTE: compute the fraction first, then ROUND(... * 100, 2) outside.

WITH ship_orders AS (
    SELECT COUNT(CASE WHEN c.address IS NOT NULL THEN o.id END) * 1.0
           / COUNT(o.id) AS perc_ship_orders
    FROM orders o
    LEFT JOIN customers c ON o.cust_id = c.id
)
SELECT ROUND(perc_ship_orders * 100.0, 2) AS percentage_shipable
FROM ship_orders;
