-- Matching Users Pairs   (StrataScratch #10085  ·  Medium)
-- Phase 3 — CTEs & Set Logic   (self-join pair matching)
--
-- Problem:
--   Find pairs of employees with same location, same gender, different age, and
--   different seniority level. Output the ids of each paired employee.
--
-- Approach / what I learned:
--   Self-join the table to compare every row against every other, translate each
--   requirement into a condition: same location/gender (=), different age/seniority (<>).
--   The pair-direction wrinkle: normally a.id < b.id dedupes to one row per pair, BUT
--   this grader wants BOTH directions ((5,55) and (55,5)), so use a.id <> b.id instead
--   (still excludes self-pairs, keeps the mirror). Lesson: when a "pairs" question is
--   ambiguous about direction, run it and compare the row count to expected — half means
--   swap < to <>, double means the reverse.

SELECT f.id, e.id
FROM facebook_employees f
JOIN facebook_employees e ON f.id <> e.id
WHERE f.location = e.location
  AND f.gender = e.gender
  AND f.age <> e.age
  AND f.is_senior <> e.is_senior;
