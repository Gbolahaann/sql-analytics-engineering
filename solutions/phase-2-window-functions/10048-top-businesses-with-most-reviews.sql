-- Top Businesses With Most Reviews   (StrataScratch #10048  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Top 5 businesses by review count; ties share a rank and skip.
--
-- Approach / what I learned:
--   'Ties share a rank and skip' names RANK() (not DENSE_RANK). Output the columns the prompt
--   asks for, in the order it asks, and keep the required ORDER BY.

SELECT name, review_count
FROM (
    SELECT name, review_count,
           RANK() OVER (ORDER BY review_count DESC) AS rnk
    FROM yelp_business
) t
WHERE rnk <= 5
ORDER BY review_count DESC;
