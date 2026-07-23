-- Longest Active Streak, and Its Revenue   (Self-authored · Hard)
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   From a transactions table (customer_id, txn_date, amount), a customer is "active"
--   in any month they transacted. A streak is a run of consecutive active months.
--   For every customer whose LONGEST streak is >= 3 months, return that streak's
--   length, its total revenue, and its start month (as a real date). One row per
--   customer; ties for longest broken by higher revenue.
--
-- Approach / what I learned:
--   Gaps-and-islands on a MONTH sequence. Collapse to one row per customer-month,
--   then label each island with (monotonic month number) - row_number(): the
--   difference is frozen inside a consecutive run and jumps at a gap.
--   Key lessons:
--     * The month index must be monotonic: year*12 + month. A raw 1-12 month number
--       resets at year end, so Dec -> Jan would look like a gap and break a streak
--       that crosses the year boundary.
--     * row_number() MUST have ORDER BY the month timeline. Without it the numbering
--       is non-deterministic: it can LOOK right yet be silently wrong.
--     * PARTITION BY = restart the counter (per customer); ORDER BY = the sequence to
--       count along (the month). Getting these two swapped was the main bug.
--     * date_trunc('month', txn_date) in the first CTE gives both the value to order
--       by and the "1st of month" date the output needs.
--     * row_number() pulls double duty: building island labels in `seq`, then picking
--       each customer's winning streak in `ranked`.
--   Snowflake note: this orders the window by the raw expression rather than a SELECT
--   alias, and never reuses an alias in the same SELECT level, both of which Snowflake
--   (unlike DuckDB) rejects.

WITH monthly AS (                                    -- one row per customer per active month
  SELECT customer_id,
         date_trunc('month', txn_date) AS month_start,
         SUM(amount)                    AS monthly_rev
  FROM transactions
  GROUP BY 1, 2
),
seq AS (                                             -- label each consecutive-month island
  SELECT customer_id, month_start, monthly_rev,
         (EXTRACT(year FROM month_start) * 12 + EXTRACT(month FROM month_start))
           - ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month_start) AS streak_grp
  FROM monthly
),
streaks AS (                                         -- collapse each island to one row
  SELECT customer_id, streak_grp,
         COUNT(*)         AS streak_len,
         SUM(monthly_rev) AS streak_rev,
         MIN(month_start) AS streak_start
  FROM seq
  GROUP BY customer_id, streak_grp
),
ranked AS (                                          -- pick each customer's longest streak
  SELECT customer_id, streak_len, streak_rev, streak_start,
         ROW_NUMBER() OVER (PARTITION BY customer_id
                            ORDER BY streak_len DESC, streak_rev DESC) AS rn
  FROM streaks
  WHERE streak_len >= 3
)
SELECT customer_id, streak_len, streak_rev, streak_start
FROM ranked
WHERE rn = 1
ORDER BY customer_id;
