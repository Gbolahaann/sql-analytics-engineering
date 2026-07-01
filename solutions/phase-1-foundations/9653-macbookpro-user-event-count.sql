-- MacBookPro User Event Count   (StrataScratch #9653  ·  Easy)
-- Phase 1 — Foundations
--
-- Problem:
--   Count the number of events performed by MacBook Pro users, per event type.
--
-- Approach / what I learned:
--   Plain COUNT + GROUP BY. First rule internalised: filter raw rows in WHERE, then group.

SELECT event_name, COUNT(*) AS cnt
FROM playbook_events
WHERE device = 'macbook pro'
GROUP BY event_name
ORDER BY cnt DESC;
