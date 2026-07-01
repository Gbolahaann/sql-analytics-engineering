-- Users By Average Session Time   (StrataScratch #10352  ·  Medium)
-- Phase 2 — Window Functions & Advanced Joins
--
-- Problem:
--   Average session time per user; session = earliest page_exit minus latest page_load, per day.
--
-- Approach / what I learned:
--   Grain is user + day: GROUP BY user_id, timestamp::date so MAX/MIN stay inside a single day.
--   Without the day, the max load and min exit leak across days and the session is meaningless.

WITH temp AS (
    SELECT user_id,
           MAX(CASE WHEN action = 'page_load' THEN timestamp END) AS load_time,
           MIN(CASE WHEN action = 'page_exit' THEN timestamp END) AS exit_time
    FROM facebook_web_log
    GROUP BY user_id, timestamp::date
    HAVING MAX(CASE WHEN action = 'page_exit' THEN timestamp END)
         > MIN(CASE WHEN action = 'page_load' THEN timestamp END)
)
SELECT user_id, AVG(exit_time - load_time) AS avg_session
FROM temp
GROUP BY 1;
