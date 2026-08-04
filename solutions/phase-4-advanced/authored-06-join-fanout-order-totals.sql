-- Order Totals Without Double-Counting   (Self-authored · Hard)
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   Per order, return total item revenue (SUM of quantity*unit_price from order_items)
--   and total shipping cost (SUM of cost from shipments). Orders have many items AND
--   many shipments; some have no shipments. One row per order, both totals correct.
--
-- Approach / what I learned (the JOIN FAN-OUT trap):
--   order_items and shipments are BOTH one-to-many off orders. Joining orders ->
--   order_items -> shipments in one query pairs every item row with every shipment row,
--   so an order with 2 items x 2 shipments becomes 4 rows. SUM(quantity*unit_price) then
--   counts each item twice and SUM(cost) counts each shipment twice -- both silently
--   inflate (order 1 shows 80 instead of 40). Nothing errors; the numbers are just wrong.
--   THE FIX: aggregate each child to the parent's grain FIRST (one row per order), THEN
--   join the summaries. Now the joins are one-to-one, so nothing can multiply.
--   How to KNOW a query fanned out:
--     * Predict it: two one-to-many joins onto the same parent ALWAYS fan out (spot the shape).
--     * Grain check: GROUP BY the key ... HAVING COUNT(*) > 1 after the join.
--     * Cross-check: SUM from the joined query vs SUM straight from the source table
--       (SELECT SUM(cost) FROM shipments). If they disagree, it fanned out.
--   Keep every order with LEFT JOIN + COALESCE(...,0) so the shipment-less order (3) stays,
--   with 0 shipping. Three words for the interview: grain, multiply, first.
--   Tableau bridge: same reason you aggregate each blended source to the view's grain first.

WITH rev_orders AS (                                -- collapse items to one row per order
  SELECT order_id, SUM(quantity * unit_price) AS item_revenue
  FROM order_items
  GROUP BY 1
),
shipment_orders AS (                                -- collapse shipments to one row per order
  SELECT order_id, SUM(cost) AS shipping_cost
  FROM shipments
  GROUP BY 1
)
SELECT o.order_id,
       COALESCE(r.item_revenue, 0)   AS item_revenue,
       COALESCE(s.shipping_cost, 0)  AS shipping_cost
FROM orders o
LEFT JOIN rev_orders r      ON o.order_id = r.order_id
LEFT JOIN shipment_orders s ON o.order_id = s.order_id
ORDER BY o.order_id;
