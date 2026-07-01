-- Flags Per Video   (StrataScratch #2102  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Unique users who flagged each video; a user = firstname + lastname; ignore rows with no flag.
--
-- Approach / what I learned:
--   A 'unique user' spans two columns, so build the key with CONCAT and COUNT(DISTINCT ...).
--   Filter out no-flag rows in WHERE before counting. Real-world tip: add a separator in CONCAT
--   to avoid name collisions.

SELECT video_id,
       COUNT(DISTINCT CONCAT(user_firstname, ' ', user_lastname)) AS unique_users
FROM user_flags
WHERE flag_id IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;
