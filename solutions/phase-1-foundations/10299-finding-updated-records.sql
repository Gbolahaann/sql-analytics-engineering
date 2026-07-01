-- Finding Updated Records   (StrataScratch #10299  ·  Easy)
-- Phase 1 — Foundations
--
-- Problem:
--   Current salary = highest salary per employee; return one row each.
--
-- Approach / what I learned:
--   Aggregate in a subquery (MAX salary per id), then JOIN back on id AND salary to pull the
--   matching row without fan-out. The second join condition is what drops the stale rows.

SELECT m.id, first_name, last_name, department_id, s.current_salary
FROM ms_employee_salary m
JOIN (
    SELECT id, MAX(salary) AS current_salary
    FROM ms_employee_salary
    GROUP BY 1
) s ON m.id = s.id AND m.salary = s.current_salary;
