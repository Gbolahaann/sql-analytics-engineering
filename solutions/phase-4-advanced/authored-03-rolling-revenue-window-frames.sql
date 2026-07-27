-- Rolling Revenue Dashboard   (Self-authored · Hard)
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   From monthly_sales (region, sales_month, revenue) with one row per region per
--   month, enrich every row with three time-series measures computed WITHIN each
--   region in date order: a running cumulative total, a 3-month rolling average, and
--   the month-over-month % change vs the previous month.
--
-- Approach / what I learned:
--   The whole question is about the THIRD layer of a window function: the FRAME.
--   A window has three dials -> PARTITION BY (the group), ORDER BY (the direction),
--   and ROWS BETWEEN ... (which rows around the current one to aggregate).
--     * running_total    -> ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--                           anchored start, window grows one row at a time (cumulative).
--     * rolling_3mo_avg  -> ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--                           fixed-width 3-row window that SLIDES; early months average
--                           the fewer rows that exist (month 1 -> 1 value, month 2 -> 2).
--     * mom_pct          -> no frame; LAG(revenue) grabs the previous row, then
--                           (rev - prev)/prev * 100. First month of a region is NULL.
--   Cumulative vs sliding is entirely down to the frame; partition and order are identical.
--   Production instincts applied:
--     * NULLIF(prev, 0) guards divide-by-zero if a prior month were ever 0.
--     * * 100.0 (not * 100) so the % is not silently integer-divided to 0.
--     * The frame RESETS at each region boundary because of PARTITION BY, so North's
--       window never bleeds into South.
--   Tableau bridge: Running Total, Moving Average (previous 2 values), and Percent
--   Difference quick table calcs; PARTITION BY region == "Compute Using region".

SELECT region,
       sales_month,
       revenue,
       SUM(revenue) OVER (PARTITION BY region ORDER BY sales_month
                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
       ROUND(AVG(revenue) OVER (PARTITION BY region ORDER BY sales_month
                                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3mo_avg,
       ROUND( (revenue - LAG(revenue) OVER (PARTITION BY region ORDER BY sales_month))
              * 100.0 / NULLIF(LAG(revenue) OVER (PARTITION BY region ORDER BY sales_month), 0), 1)
         AS mom_pct
FROM monthly_sales
ORDER BY region, sales_month;
