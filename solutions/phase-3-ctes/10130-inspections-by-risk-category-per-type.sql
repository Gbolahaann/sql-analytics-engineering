-- Inspections by Risk Category per Type   (StrataScratch #10130  ·  Medium)
-- Phase 3 — CTEs & Set Logic   (pivoting with conditional aggregation)
--
-- Problem:
--   For each inspection_type, count inspections in each risk_category, PIVOTED so each
--   risk category is its own column, plus a total column. Records with no risk category
--   (NULL) form their own column. Order by total inspections per type, descending.
--
-- Approach / what I learned:
--   Pivot = conditional aggregation: one COUNT(CASE WHEN category = 'X' THEN inspection_id
--   END) per category becomes one column; GROUP BY the row dimension (inspection_type).
--   The blank category is NULL, so its CASE uses IS NULL (never = NULL).
--   Key catch: use plain COUNT, NOT COUNT(DISTINCT). Each violation row is a record to
--   count, and one inspection_id spans many rows, so DISTINCT undercounts. Ask every
--   time: am I counting rows, or counting distinct things?

SELECT inspection_type,
       COUNT(CASE WHEN risk_category = 'High Risk'     THEN inspection_id END) AS high_risk,
       COUNT(CASE WHEN risk_category = 'Moderate Risk' THEN inspection_id END) AS moderate_risk,
       COUNT(CASE WHEN risk_category = 'Low Risk'      THEN inspection_id END) AS low_risk,
       COUNT(CASE WHEN risk_category IS NULL           THEN inspection_id END) AS no_risk,
       COUNT(inspection_id) AS total
FROM sf_restaurant_health_violations
GROUP BY inspection_type
ORDER BY total DESC;
