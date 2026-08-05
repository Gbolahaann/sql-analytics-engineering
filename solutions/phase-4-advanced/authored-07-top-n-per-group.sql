-- Top 2 Products Per Category   (Self-authored · Hard)
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   From sales (sale_id, category, product, amount), return the top 2 products by total
--   revenue within each category. Ties share a spot (a category can return >2 rows). A
--   category with one product returns just that one. Output: category, product,
--   total_revenue, revenue_rank.
--
-- Approach / what I learned (top-N-per-group, the classic interview shape):
--   Three moves:
--     1. AGGREGATE to the thing being ranked: one row per (category, product) with
--        SUM(amount). Rank the summary, never the raw sales rows.
--     2. RANK within each group: window PARTITION BY category ORDER BY total_revenue DESC.
--        The partition restarts the ranking per category.
--     3. FILTER to <= 2 in a LATER step: a window function can't sit in WHERE (computed
--        after WHERE), so rank in one CTE, filter in the next.
--   THE CRUX -> which ranking function:
--     * ROW_NUMBER() gives unique numbers, so on a tie it drops one product arbitrarily
--       (would return only 5 rows here, losing Phone or Tablet). WRONG for "ties included".
--     * DENSE_RANK() (or RANK()) give tied rows the SAME number, so <= 2 keeps them all.
--     They diverge ONLY when a tie lands on the cutoff; with all-distinct values every
--     ranking function returns the same rows.
--   Portability note (bit me-proofing for Snowflake/Postgres): those engines often won't
--   let a window ORDER BY reference a SELECT-list alias (total_revenue) at the same level.
--   Safer: ORDER BY SUM(amount) directly, or split aggregate + rank into two CTEs (done here).
--   Tableau bridge: RANK() table calc along Product, partitioned by Category, filtered to top 2.

WITH product_rev AS (                               -- one row per (category, product)
  SELECT category, product, SUM(amount) AS total_revenue
  FROM sales
  GROUP BY 1, 2
),
ranked AS (                                         -- rank within each category, ties share a rank
  SELECT category, product, total_revenue,
         DENSE_RANK() OVER (PARTITION BY category
                            ORDER BY total_revenue DESC) AS revenue_rank
  FROM product_rev
)
SELECT category, product, total_revenue, revenue_rank
FROM ranked
WHERE revenue_rank <= 2
ORDER BY category, revenue_rank, product;
