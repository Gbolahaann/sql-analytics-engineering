-- Workers With The Highest Salaries   (StrataScratch #10353  ·  Easy)
-- Phase 1 — Foundations
--
-- Problem:
--   Job title(s) of the employee(s) with the highest salary, among titled employees only.
--
-- Approach / what I learned:
--   The MAX must be scoped to titled workers, so the title join goes INSIDE the subquery that
--   computes the max — otherwise the untitled top earner wins and returns an empty title.

SELECT t.worker_title
FROM worker w
JOIN (
    SELECT MAX(w.salary) AS highest_salary
    FROM worker w
    JOIN title t ON w.worker_id = t.worker_ref_id
) w2 ON w.salary = w2.highest_salary
JOIN title t ON w.worker_id = t.worker_ref_id;
