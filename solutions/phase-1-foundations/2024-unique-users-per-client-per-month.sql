-- Unique Users Per Client Per Month   (StrataScratch #2024  ·  Easy)
-- Phase 1 — Foundations
--
-- Problem:
--   Number of unique users per client for each month.
--
-- Approach / what I learned:
--   EXTRACT(MONTH FROM ...) to get the month number; 'month' is reserved, so quote the alias.
--   Group by client + month.

SELECT client_id,
       EXTRACT(MONTH FROM time_id) AS "month",
       COUNT(DISTINCT user_id)
FROM fact_events
GROUP BY 1, 2;
