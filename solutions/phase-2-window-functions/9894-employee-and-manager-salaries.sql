-- Employee and Manager Salaries   (StrataScratch #9894  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Employees earning more than their manager; output first name and salary.
--
-- Approach / what I learned:
--   Self-join: alias the table twice, match e.manager_id = m.id so employee and manager sit on
--   one row, then compare e.salary > m.salary. No aggregate needed — grain stays one row per
--   employee.

SELECT e.first_name, e.salary
FROM employee e
JOIN employee m ON e.manager_id = m.id
WHERE e.salary > m.salary;
