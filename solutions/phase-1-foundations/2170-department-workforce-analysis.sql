-- Department Workforce Analysis   (StrataScratch #2170  ·  Medium)
-- Phase 1 — Foundations
--
-- Problem:
--   Per department (employees who joined after 2020), headcount, total payroll and average salary; only departments with >=5 employees.
--
-- Approach / what I learned:
--   HAVING filters AFTER grouping (on the COUNT); WHERE filters before. Multi-word aliases need
--   double quotes in Postgres; use EXTRACT(YEAR FROM date), not YEAR().

SELECT department,
       COUNT(DISTINCT id) AS "headcount",
       SUM(salary)        AS "total payroll",
       AVG(salary)        AS "average salary"
FROM techcorp_workforce
WHERE EXTRACT(YEAR FROM joining_date) > 2020
GROUP BY 1
HAVING COUNT(DISTINCT id) >= 5
ORDER BY 2 DESC;
