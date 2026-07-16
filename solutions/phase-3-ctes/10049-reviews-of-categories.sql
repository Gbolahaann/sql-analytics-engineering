-- Reviews of Categories   (StrataScratch #10049  ·  Medium)
-- Phase 3 — CTEs & Set Logic   (delimiter-separated lists -> rows)
--
-- Problem:
--   Number of reviews per business category. Categories live as a semicolon-separated
--   list in one column; a business's review_count counts toward EACH of its categories.
--   Output category + total reviews, descending.
--
-- Approach / what I learned:
--   The "comma-separated list in a column" smell: explode it with regexp_split_to_table,
--   carrying review_count along on every exploded row, then GROUP BY category + SUM.
--   Pattern '\s*;\s*' = a semicolon with any surrounding whitespace -- eating the spaces
--   during the split keeps tokens clean (' Delivery' vs 'Delivery' would create phantom
--   duplicate categories). Regex is a reference skill: know ~10 symbols cold
--   (. * + ? \s \d \w [] [^] |), look the rest up.

WITH split AS (
    SELECT review_count,
           regexp_split_to_table(categories, '\s*;\s*') AS category
    FROM yelp_business
)
SELECT category,
       SUM(review_count) AS total_reviews
FROM split
GROUP BY 1
ORDER BY 2 DESC;
