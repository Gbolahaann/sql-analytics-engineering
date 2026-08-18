-- Earns More Than Their Manager   (Self-authored · Hard)   [solved BLIND / cold-start]
-- Phase 3 — CTEs & Set Logic
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   employees(emp_id, name, salary, manager_id), where manager_id references another
--   employee's emp_id. Return every employee who earns STRICTLY MORE than their manager:
--   employee name + salary, manager name + salary.
--
-- Approach / what I learned (HIERARCHICAL SELF-JOIN):
--   The manager's salary lives in a DIFFERENT ROW of the SAME table, so join the table to
--   a second copy of itself and put employee next to manager on one line.
--     FROM employees e JOIN employees m ON e.manager_id = m.emp_id
--   KEY POINT: the join key is child.manager_id = parent.emp_id -- NOT emp_id = emp_id
--   (that would pair everyone with themselves). Then the filter is plain: e.salary > m.salary.
--   The CEO has manager_id = NULL and drops out automatically under an INNER JOIN (NULL
--   matches no emp_id), so an explicit "WHERE manager_id IS NOT NULL" is redundant here.
--   (If the ask were "all employees", switch to LEFT JOIN to keep the CEO.)
--   Contrast with the earlier market-basket self-join: that joined on the SAME key
--   (order_id = order_id); this joins on a DIFFERENT key (manager_id -> emp_id).
--   Note: return the spec's column names (employee, manager, ...) for downstream consumers.

SELECT e.name   AS employee,
       e.salary AS employee_salary,
       m.name   AS manager,
       m.salary AS manager_salary
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id   -- child.manager_id = parent.emp_id
WHERE e.salary > m.salary
ORDER BY e.name;
