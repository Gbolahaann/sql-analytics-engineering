-- Consecutive Days   (StrataScratch #2054  ·  Hard)
-- Phase 3 — CTEs & Set Logic   (gaps and islands)
--
-- Problem:
--   Find all users who were active for 3 consecutive days or more.
--
-- Approach / what I learned:
--   Gaps-and-islands: number each user's active days in date order, then
--   (record_date - row_number) is CONSTANT across a run of consecutive days (both climb
--   by 1, so the difference cancels). A gap resets it -> a new "island". Group by
--   user_id + island, HAVING COUNT(*) >= 3, then DISTINCT user_id.
--
--   BIG lesson (learned the hard way): PARTITION BY user_id in the ROW_NUMBER is NOT
--   optional. My first pass used ROW_NUMBER() OVER (ORDER BY record_date) with no
--   partition; it PASSED the grader by luck on the small dataset but is wrong in general
--   -- with users interleaved by date, one user's consecutive days get non-consecutive
--   global row numbers, so the islands differ and a real streak is missed. "Passed the
--   grader" != "correct." Always re-read the window clause against the per-entity intent.

WITH numbered AS (
    SELECT user_id,
           record_date,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY record_date) AS rn
    FROM sf_events
),
islands AS (
    SELECT user_id,
           record_date - rn::int AS island   -- date minus integer -> date; constant within a streak
    FROM numbered
)
SELECT DISTINCT user_id
FROM islands
GROUP BY user_id, island
HAVING COUNT(*) >= 3;
