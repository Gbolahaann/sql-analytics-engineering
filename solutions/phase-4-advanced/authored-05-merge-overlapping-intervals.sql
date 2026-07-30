-- Merge Overlapping Subscriptions   (Self-authored · Hard)
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   A customer holds several overlapping / back-to-back subscription periods. From
--   subscriptions (customer_id, start_date, end_date), merge every set of periods that
--   overlap or touch with no gap into one continuous coverage window, per customer.
--   Return one row per merged period: its start and end.
--
-- Approach / what I learned (gaps-and-islands on DATE RANGES):
--   Built and verified ONE CTE at a time (the real lesson: a scary query is just small,
--   testable steps stacked up). Four steps:
--     1. ordered  -> for each row, the furthest end reached by ALL earlier rows:
--                    MAX(end_date) OVER (... ORDER BY start_date
--                                        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING).
--                    THE TRAP: it must be the running MAX of all prior ends, NOT the
--                    previous row's end. A long period followed by a tiny contained one
--                    would otherwise wrongly split a band that is still open (customer 3).
--                    "1 PRECEDING" excludes the current row: we ask about the past, and a
--                    period can't be part of its own history (include self -> nothing ever
--                    looks like a gap and everything collapses to one band).
--     2. flagged  -> is_new_band = 1 when prev_max_end IS NULL (first period) OR
--                    start_date > prev_max_end + 1 (a real uncovered day). "+ 1" makes
--                    back-to-back periods (end, next day starts) MERGE; only a genuine
--                    blank day splits.
--     3. grouped  -> running SUM(is_new_band) turns the 0/1 flags into a band id (the
--                    "new chapter -> chapter number" trick). Frame ends at CURRENT ROW here
--                    (unlike step 1) so a row's own "1" counts toward its own band.
--     4. collapse -> GROUP BY customer_id, band_id; MIN(start_date), MAX(end_date).
--   band_id is uncapped: it equals how many gap-separated bands the customer has (1,2,3,...).
--   Career note: Tableau has no clean native interval-merge, which is why this gets pushed
--   down into SQL / the warehouse -- an analytics-engineering job so BI doesn't have to.

WITH ordered AS (                                   -- furthest end reached by all earlier rows
  SELECT customer_id, start_date, end_date,
         MAX(end_date) OVER (PARTITION BY customer_id ORDER BY start_date
                             ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS prev_max_end
  FROM subscriptions
),
flagged AS (                                        -- 1 = a new coverage band starts here
  SELECT customer_id, start_date, end_date,
         CASE WHEN prev_max_end IS NULL          THEN 1
              WHEN start_date > prev_max_end + 1 THEN 1
              ELSE 0 END AS is_new_band
  FROM ordered
),
grouped AS (                                        -- running sum of flags = band id
  SELECT customer_id, start_date, end_date,
         SUM(is_new_band) OVER (PARTITION BY customer_id ORDER BY start_date
                                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS band_id
  FROM flagged
)
SELECT customer_id,
       MIN(start_date) AS period_start,
       MAX(end_date)   AS period_end
FROM grouped
GROUP BY customer_id, band_id
ORDER BY customer_id, period_start;
