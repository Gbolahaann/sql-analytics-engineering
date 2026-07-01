-- Share of Active Users   (StrataScratch #2005  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Percentage of users who are both from the US and have 'open' status.
--
-- Approach / what I learned:
--   Part-over-whole from the SAME rows = conditional aggregation, no join. SUM(CASE ...) as the
--   numerator over COUNT as the denominator; cast to FLOAT so integer division doesn't collapse
--   to 0.

SELECT CAST(SUM(CASE WHEN country = 'USA' AND status = 'open' THEN 1 ELSE 0 END) AS FLOAT)
       / COUNT(DISTINCT user_id) * 100 AS share_pct
FROM fb_active_users;
