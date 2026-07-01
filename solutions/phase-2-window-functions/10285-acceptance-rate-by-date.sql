-- Acceptance Rate By Date   (StrataScratch #10285  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Friend-request acceptance rate per send-date; only dates with >=1 acceptance.
--
-- Approach / what I learned:
--   'Sent' and 'accepted' are different rows on different dates. LEFT JOIN them on
--   sender+receiver so the acceptance is carried back to its SEND date. COUNT(accepted col)
--   skips NULLs (numerator); COUNT(sent col) is the denominator.

SELECT s.date,
       COUNT(a.user_id_sender) * 1.0 / COUNT(s.user_id_sender) AS acceptance_rate
FROM fb_friend_requests s
LEFT JOIN fb_friend_requests a
    ON s.user_id_sender   = a.user_id_sender
   AND s.user_id_receiver = a.user_id_receiver
   AND a.action = 'accepted'
WHERE s.action = 'sent'
GROUP BY s.date
HAVING COUNT(a.user_id_sender) >= 1;
