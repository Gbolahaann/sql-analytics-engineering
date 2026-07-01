-- Most Profitable Financial Company   (StrataScratch #9663  ·  Easy)
-- Phase 1 — Foundations
--
-- Problem:
--   Find the most profitable company in the Financials sector, with its continent.
--
-- Approach / what I learned:
--   No aggregation needed — one row per company already. ORDER BY + LIMIT 1 beats an unnecessary
--   GROUP BY/MAX.

SELECT company, continent
FROM forbes_global_2010_2014
WHERE sector = 'Financials'
ORDER BY profits DESC
LIMIT 1;
