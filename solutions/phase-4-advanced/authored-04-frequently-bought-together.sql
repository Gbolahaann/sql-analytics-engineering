-- Frequently Bought Together   (Self-authored · Hard)
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   From order_items (order_id, product), one row per product per order, find for
--   EVERY product the single other product most often bought in the same order with
--   it, plus how many distinct orders the pair shared. One row per product; ties on
--   the count broken by partner name A->Z.
--
-- Approach / what I learned:
--   The engine is a SELF-JOIN: join the table to itself on order_id to bring two
--   products from the same basket onto one row.
--     1. PAIR   -> order_items a JOIN order_items b ON a.order_id = b.order_id
--                  AND a.product <> b.product.
--                  Use <> (not >): the task is DIRECTED, every product must see all its
--                  partners so it can pick a favourite. Using a.product > b.product would
--                  drop the alphabetically-first product (Bread) entirely.
--     2. COUNT  -> COUNT(DISTINCT a.order_id), NOT COUNT(*). A product on two lines of one
--                  order produces multiple join rows for the SAME basket; the basket is the
--                  unit, so count distinct orders. (Order 2 has Bread twice: COUNT(*) would
--                  score Bread-Butter as 5, the true answer is 4 baskets.)
--     3. RANK   -> ROW_NUMBER() OVER (PARTITION BY product
--                  ORDER BY times_together DESC, partner ASC), keep rn = 1.
--                  The partner ASC tie-break is what makes Jam -> Bread (Bread & Butter both
--                  tie at 2; deterministic alphabetical rule picks Bread).
--   Neat sanity check in the output: Bread and Butter are each other's top partner (both 4),
--   the mirror-image pair a real "bought together" recommender would surface.
--   Tableau bridge: self-join == blending a source against itself on Order ID; the
--   a.product <> b.product filter is the calc that hides the diagonal.

WITH pairs AS (                                     -- co-locate two products from one basket
  SELECT a.product AS product,
         b.product AS partner,
         COUNT(DISTINCT a.order_id) AS times_together
  FROM order_items a
  JOIN order_items b
    ON a.order_id = b.order_id
   AND a.product <> b.product
  GROUP BY 1, 2
),
ranked AS (                                         -- rank partners within each product
  SELECT product, partner, times_together,
         ROW_NUMBER() OVER (PARTITION BY product
                            ORDER BY times_together DESC, partner ASC) AS rn
  FROM pairs
)
SELECT product,
       partner AS top_partner,
       times_together
FROM ranked
WHERE rn = 1
ORDER BY product;
