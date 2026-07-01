-- Ranking Most Active Guests   (StrataScratch #10159  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Rank guests by total messages; ties share a rank with no skipped numbers.
--
-- Approach / what I learned:
--   Aggregate then rank in one pass: DENSE_RANK() OVER (ORDER BY SUM(n_messages) DESC) with
--   GROUP BY guest. 'No skipped numbers' = DENSE_RANK. Do NOT partition by the guest being
--   ranked.

SELECT id_guest,
       SUM(n_messages) AS total_messages,
       DENSE_RANK() OVER (ORDER BY SUM(n_messages) DESC) AS rnk
FROM airbnb_contacts
GROUP BY 1;
