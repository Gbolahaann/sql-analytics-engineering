-- Counting Instances in Text   (StrataScratch #9814  ·  Hard)
-- Phase 3 — CTEs & Set Logic   (string tokenization)
--
-- Problem:
--   Count how many times the exact words 'bull' and 'bear' appear in the contents
--   column. Count every occurrence (even multiple per row), case-insensitive, whole
--   words only (exclude bullish / bearing). Output the word and its count.
--
-- Approach / what I learned:
--   Explode text into one-word-per-row with a set-returning split function, then it's a
--   plain GROUP BY + COUNT. Splitting into whole tokens is what excludes 'bullish' -- it
--   becomes its own token, never equal to 'bull' (a substring LIKE '%bull%' would wrongly
--   match). Robustness lesson (my first pass passed the grader but was fragile):
--     - lower(contents) for case-insensitivity (the spec requires it; data was all
--       lowercase so a raw compare passed by luck).
--     - split on '[^a-z]+' (any non-letter), NOT just ' ', so trailing punctuation like
--       'bear.' or 'bull,' doesn't stick to the word and get missed.
--   Same theme as Consecutive Days: "passed the grader" != "correct for the spec".

WITH words AS (
    SELECT regexp_split_to_table(lower(contents), '[^a-z]+') AS word
    FROM google_file_store
)
SELECT word, COUNT(*)
FROM words
WHERE word IN ('bull', 'bear')
GROUP BY word;
