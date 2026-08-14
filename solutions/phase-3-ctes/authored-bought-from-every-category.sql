-- Bought From Every Category   (Self-authored · Hard)   [solved BLIND / cold-start]
-- Phase 3 — CTEs & Set Logic
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   purchases(customer_id, product) + products(product, category). Return the customers
--   who have bought at least one product from EVERY category that exists.
--
-- Approach / what I learned (RELATIONAL DIVISION = "X related to ALL of Y"):
--   Don't loop over categories. COUNT instead: a customer covers every category when the
--   number of DISTINCT categories they've touched equals the total number of categories
--   that exist. Match those two counts.
--     - Join purchases -> products to attach a category to each purchase.
--     - GROUP BY customer_id
--       HAVING COUNT(DISTINCT category) = (SELECT COUNT(DISTINCT category) FROM products)
--   THE TRAP: COUNT(DISTINCT category), NOT COUNT(*). A customer with 5 Food purchases has
--   5 rows but only 1 category; COUNT(*) would wrongly push them over the threshold.
--   Note: no CTE needed -- the COUNT(DISTINCT) in HAVING already dedups, so the single-query
--   form is actually cleaner than a DISTINCT staging CTE.
--   Same shape as "users active in ALL N months". Relational division shows up a lot.

SELECT pu.customer_id
FROM purchases pu
JOIN products pr ON pu.product = pr.product
GROUP BY pu.customer_id
HAVING COUNT(DISTINCT pr.category) = (SELECT COUNT(DISTINCT category) FROM products)
ORDER BY pu.customer_id;
