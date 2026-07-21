-- Matching Similar Hosts and Guests   (StrataScratch #10078  ·  Medium)
-- Phase 3 — CTEs & Set Logic   (join two tables on matching attributes)
--
-- Problem:
--   Find host-guest pairs of the same gender AND same nationality.
--   Output host_id and guest_id of each matched pair.
--
-- Approach / what I learned:
--   Two DIFFERENT tables, so a plain JOIN on the columns that must be equal
--   (gender AND nationality) -- no a.id < b.id / <> trick needed (that's only for a table
--   joined to itself, to kill self-pairs and mirror duplicates). Hosts and guests are
--   distinct people, so no self-pairs exist. Output hygiene: exactly the two requested
--   columns. DISTINCT here is a harmless guard against duplicate host/guest rows.
--   Rule: same table -> self-join (+ < / <> to dedupe); two tables -> plain join.

SELECT DISTINCT h.host_id, g.guest_id
FROM airbnb_hosts h
JOIN airbnb_guests g
  ON h.gender = g.gender
 AND h.nationality = g.nationality;
