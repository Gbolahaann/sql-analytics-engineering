-- Number of Violations   (StrataScratch #9728  ·  Easy)
-- Phase 1 — Foundations
--
-- Problem:
--   For one restaurant, count distinct violations per year.
--
-- Approach / what I learned:
--   EXTRACT(YEAR FROM date) to bucket by year; COUNT(DISTINCT ...) to avoid double counting.

SELECT EXTRACT(YEAR FROM inspection_date) AS year,
       COUNT(DISTINCT violation_id)
FROM sf_restaurant_health_violations
WHERE business_name = 'Roxanne Cafe'
GROUP BY 1
ORDER BY 1 ASC;
