-- Income By Title and Gender   (StrataScratch #10077  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Average total compensation (salary + summed bonuses) by title and gender; exclude no-bonus employees.
--
-- Approach / what I learned:
--   The fan-out trap: an employee has many bonus rows, so summing bonuses per worker FIRST
--   (subquery), then joining, keeps salary from being double counted. Match grains before you
--   join.

SELECT e.employee_title, e.sex,
       AVG(e.salary + b.total_bonus) AS avg_compensation
FROM sf_employee e
JOIN (
    SELECT worker_ref_id, SUM(bonus) AS total_bonus
    FROM sf_bonus
    GROUP BY worker_ref_id
) b ON e.id = b.worker_ref_id
GROUP BY e.employee_title, e.sex;
