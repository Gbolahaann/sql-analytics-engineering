-- Finding User Purchases   (StrataScratch #10322  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Users whose 2nd purchase was 1–7 days after their 1st (ignore same-day).
--
-- Approach / what I learned:
--   Two windows in one pass: LAG(date) for the previous purchase and ROW_NUMBER() to pin the
--   2nd. row=2 restricts the comparison to exactly the first→second transition.

SELECT DISTINCT user_id
FROM (
    SELECT user_id, created_at,
           LAG(created_at)  OVER (PARTITION BY user_id ORDER BY created_at) AS prev_date,
           ROW_NUMBER()     OVER (PARTITION BY user_id ORDER BY created_at) AS rn
    FROM amazon_transactions
) t
WHERE created_at - prev_date BETWEEN 1 AND 7
  AND rn = 2;
