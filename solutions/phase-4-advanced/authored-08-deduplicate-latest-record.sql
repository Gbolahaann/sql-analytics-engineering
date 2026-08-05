-- Deduplicate to the Latest Record   (Self-authored · Hard)
-- Phase 4 — Advanced
-- Graded locally on DuckDB (custom dataset), not a StrataScratch question.
--
-- Problem:
--   customers_raw (id, customer_id, name, email, updated_at) has duplicate rows per
--   customer from repeated loads. Return exactly ONE row per customer_id: the most
--   recent by updated_at, breaking ties on updated_at by the higher id.
--   Output: customer_id, name, email, updated_at.
--
-- Approach / what I learned (dedup = staging-model bread-and-butter):
--   Three moves, and it is the MIRROR IMAGE of top-N-per-group:
--     1. NUMBER rows within each key, keeper first:
--        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC, id DESC).
--        Partition by the BUSINESS key (customer_id), not the surrogate id.
--     2. KEEP rn = 1 in a later CTE (window function can't sit in WHERE).
--   WHY ROW_NUMBER, not DENSE_RANK (the interview crux):
--     dedup needs EXACTLY ONE survivor per key. ROW_NUMBER gives unique numbers -> one
--     winner. DENSE_RANK gives tied rows the SAME rank, so rn=1 would keep ALL tied rows
--     and re-introduce the duplicate. Rule that flips with the goal:
--        keep ties -> DENSE_RANK   |   force one winner -> ROW_NUMBER.
--   THE TRAP: make the tie-break DETERMINISTIC. Two rows with the same updated_at ordered
--   only by updated_at -> the winner is random and the model returns different rows on
--   different runs. Adding id DESC guarantees one stable answer.
--   Warehouse shortcut (Snowflake/BigQuery/DuckDB): QUALIFY ROW_NUMBER() OVER (...) = 1
--   removes the CTE entirely. CTE form used here works everywhere.

WITH ranked AS (
  SELECT id, customer_id, name, email, updated_at,
         ROW_NUMBER() OVER (PARTITION BY customer_id
                            ORDER BY updated_at DESC, id DESC) AS rn
  FROM customers_raw
)
SELECT customer_id, name, email, updated_at
FROM ranked
WHERE rn = 1
ORDER BY customer_id;

-- Warehouse one-liner equivalent (Snowflake / BigQuery / DuckDB):
-- SELECT customer_id, name, email, updated_at
-- FROM customers_raw
-- QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id
--                            ORDER BY updated_at DESC, id DESC) = 1
-- ORDER BY customer_id;
