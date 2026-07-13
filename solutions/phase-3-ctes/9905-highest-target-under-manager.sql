-- Highest Target Under Manager   (StrataScratch #9905  ·  Medium)
-- Phase 3 — CTEs & Set Logic   (top-with-ties)
--
-- Problem:
--   Find the employee(s) under manager_id = 13 with the highest target (return all
--   ties). Output first_name and target.
--
-- Approach / what I learned:
--   Top-with-ties = DENSE_RANK() (ROW_NUMBER would keep only one of the tied top
--   scorers). Rank in a CTE, filter rnk = 1 outside (can't filter a window in WHERE).
--   Simplification lesson: my first pass self-joined the table to itself just to filter
--   the manager, and summed target per employee. Neither was needed -- manager_id is
--   already on the employee row (WHERE manager_id = 13), and each employee is one row
--   (no SUM). Only self-join when you actually need COLUMNS from the other copy.

WITH ranked AS (
    SELECT first_name,
           target,
           DENSE_RANK() OVER (ORDER BY target DESC) AS rnk
    FROM salesforce_employees
    WHERE manager_id = 13
)
SELECT first_name, target
FROM ranked
WHERE rnk = 1;
