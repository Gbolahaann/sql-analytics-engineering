-- Customers with Large Orders   (StrataScratch #2172  ·  Medium)
-- Phase 3 — CTEs & Set Logic   (EXISTS vs JOIN)
--
-- Problem:
--   Find all customers who placed at least one order over $100.
--   Return customer_id and name; count all orders regardless of status.
--
-- Approach / what I learned:
--   "At least one" is the phrase that signals EXISTS -- a yes/no existence test in the
--   WHERE, not a value fetch. EXISTS never multiplies rows and short-circuits at the
--   first match, so a customer with several qualifying orders still appears once.
--   The JOIN + DISTINCT version (below) returns the SAME rows, but only because DISTINCT
--   undoes the fan-out the join created; EXISTS avoids that fan-out entirely and is
--   correct by default. Rule: need VALUES from the other table -> JOIN; need only
--   "is there a match?" -> EXISTS (and NOT EXISTS for anti-joins).

SELECT customer_id, customer_name
FROM online_store_customers c
WHERE EXISTS (
    SELECT 1
    FROM online_store_orders o
    WHERE o.customer_id = c.customer_id
      AND o.amount > 100
);

-- Equivalent JOIN + DISTINCT (same result, but the DISTINCT is hiding a fan-out):
-- SELECT DISTINCT c.customer_id, c.customer_name
-- FROM online_store_customers c
-- JOIN online_store_orders o USING (customer_id)
-- WHERE o.amount > 100
-- ORDER BY 2;
