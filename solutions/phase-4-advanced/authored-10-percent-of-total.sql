-- Percent of Total   (Self-authored · Hard)   [solved BLIND / cold-start]
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   From sales (category, product, amount), roll each product to its revenue, then show
--   its share of its category, its share of the grand total, and a running cumulative
--   share within the category (biggest first, a Pareto view). 2 dp; order category, rev desc.
--
-- Approach / what I learned (percent-of-total = a window aggregate in the DENOMINATOR):
--   The whole trick: SUM(x) OVER (...) gives a total ALONGSIDE each row without collapsing
--   it, so you can divide the row by the group.
--     * pct_of_category = revenue * 100.0 / SUM(revenue) OVER (PARTITION BY category)
--     * pct_of_grand    = revenue * 100.0 / SUM(revenue) OVER ()            -- empty OVER() = whole table
--     * running_pct     = SUM(revenue) OVER (PARTITION BY category ORDER BY revenue DESC
--                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
--                         * 100.0 / SUM(revenue) OVER (PARTITION BY category)  -- climbs to 100%
--   * 100.0 (not 100) so integer division doesn't collapse to 0.
--   Two notes to self from the review:
--     - Aggregate the roll-up with GROUP BY (conventional) rather than SUM OVER + DISTINCT.
--     - Give the running total an explicit ROWS frame; the default RANGE frame lumps ties
--       together and would jump the cumulative % if two products tied on revenue.
--   Tableau bridge: "Percent of Total" quick table calc, Compute Using = category; the
--   running one is "Running Total" then "Percent of Total".

WITH product_rev AS (
  SELECT category, product, SUM(amount) AS revenue
  FROM sales
  GROUP BY 1, 2
)
SELECT category, product, revenue,
       ROUND(revenue * 100.0 / SUM(revenue) OVER (PARTITION BY category), 2) AS pct_of_category,
       ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2)                      AS pct_of_grand,
       ROUND(SUM(revenue) OVER (PARTITION BY category ORDER BY revenue DESC
                                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
             * 100.0 / SUM(revenue) OVER (PARTITION BY category), 2)         AS running_pct
FROM product_rev
ORDER BY category, revenue DESC;
