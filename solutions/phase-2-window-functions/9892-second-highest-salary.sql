-- Second Highest Salary   (StrataScratch #9892  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Find the second highest salary of employees.
--
-- Approach / what I learned:
--   Compute the rank in a subquery, then filter rank=2 outside — you cannot filter a window
--   function in WHERE. RANK vs DENSE_RANK matters when the top salary ties.

SELECT salary
FROM (
    SELECT salary, RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employee
) t
WHERE rnk = 2;
