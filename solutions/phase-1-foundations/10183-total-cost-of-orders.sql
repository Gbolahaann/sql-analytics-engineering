-- Total Cost of Orders   (StrataScratch #10183  ·  Easy)
-- Phase 1 — Foundations
--
-- Problem:
--   Total order cost per customer; output id, first name, total; alphabetical by name.
--
-- Approach / what I learned:
--   Join customers to orders on id = cust_id, then SUM per customer. Qualify ambiguous columns
--   (both tables have id) and put the aggregate's column inside SUM(), not on the alias.

SELECT c.id, c.first_name, SUM(total_order_cost)
FROM customers c
JOIN orders o ON c.id = o.cust_id
GROUP BY 1, 2
ORDER BY 2 ASC;
