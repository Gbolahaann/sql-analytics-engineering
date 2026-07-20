-- Employees With the Same Salary   (StrataScratch #9856  ·  Medium)
-- Phase 3 — CTEs & Set Logic   (window count as an existence test)
--
-- Problem:
--   Find employees who earn the same salary as at least one other employee.
--   Output worker_id, first_name, salary, ordered by salary descending.
--
-- Approach / what I learned:
--   COUNT(*) OVER (PARTITION BY salary) tags each row with how many people share its
--   salary; keep rows where that is > 1. Filter in an outer query (can't filter a window
--   in WHERE). Two habits reinforced by my iterations here:
--     1. Output hygiene: the logic was right on line 1; my failed tries were all about
--        matching the EXACT output columns (a name typo, an extra rnk column, then a
--        dropped salary). Before submitting, re-read the "Output ..." line and match it.
--     2. Only compute what the output needs: I carried a dense_rank() I never used, which
--        was the very column I then had to prune. Less machinery = fewer output mistakes.

WITH counts AS (
    SELECT worker_id, first_name, salary,
           COUNT(*) OVER (PARTITION BY salary) AS same_salary_count
    FROM worker
)
SELECT worker_id, first_name, salary
FROM counts
WHERE same_salary_count > 1
ORDER BY salary DESC;
