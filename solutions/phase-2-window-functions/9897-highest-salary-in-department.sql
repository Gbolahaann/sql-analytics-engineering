-- Highest Salary In Department   (StrataScratch #9897  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Employee with the highest salary per department; output department, first name, salary.
--
-- Approach / what I learned:
--   Top-1-per-group: RANK() OVER (PARTITION BY department ORDER BY salary DESC), then keep
--   rank=1. Partition by the GROUP you rank within, never by the thing you rank.

SELECT department, first_name, salary
FROM (
    SELECT department, first_name, salary,
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rnk
    FROM employee
) t
WHERE rnk = 1;
