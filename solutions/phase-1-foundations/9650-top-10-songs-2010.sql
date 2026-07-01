-- Top 10 Songs 2010   (StrataScratch #9650  ·  Medium)
-- Phase 1 — Foundations
--
-- Problem:
--   Return the top 10 ranked songs of 2010.
--
-- Approach / what I learned:
--   DISTINCT matters: without it, duplicate chart rows inflate the list beyond 10.

SELECT DISTINCT year_rank, group_name, song_name
FROM billboard_top_100_year_end
WHERE year = 2010
ORDER BY 1 ASC
LIMIT 10;
