-- Make the Friends Network Symmetric   (StrataScratch #9813  ·  Medium)
-- Phase 3 — CTEs & Set Logic   (UNION vs UNION ALL)
--
-- Problem:
--   Friendships are stored one-directionally. Make the network symmetric: if 0 is
--   friends with 1, output must contain both (0,1) and (1,0). Output user_id, friend_id.
--
-- Approach / what I learned:
--   Set operators STACK rows (same columns), unlike JOIN which widens. To flip a
--   relationship bidirectional: UNION the original with a copy that swaps the two
--   columns. Use UNION, not UNION ALL: the source already had one friendship stored
--   both ways, so UNION ALL returned 44 rows (2 duplicates) while UNION gives the
--   correct 42. Rule: stacking sets that MIGHT overlap -> UNION (dedupes); UNION ALL
--   only when the halves are provably disjoint or you want to keep counts.

SELECT user_id, friend_id
FROM google_friends_network
UNION
SELECT friend_id, user_id
FROM google_friends_network;
