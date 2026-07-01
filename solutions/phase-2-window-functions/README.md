# Phase 2 — Window Functions & Advanced Joins

| # | Question | Difficulty | Key technique |
|---|----------|-----------|---------------|
| 9892 | [Second Highest Salary](9892-second-highest-salary.sql) | Medium | Compute the rank in a subquery, then filter rank=2 outside — you cannot filter a window function in WHERE. |
| 9897 | [Highest Salary In Department](9897-highest-salary-in-department.sql) | Medium | Top-1-per-group: RANK() OVER (PARTITION BY department ORDER BY salary DESC), then keep rank=1. |
| 10322 | [Finding User Purchases](10322-finding-user-purchases.sql) | Medium | Two windows in one pass: LAG(date) for the previous purchase and ROW_NUMBER() to pin the 2nd. |
| 10048 | [Top Businesses With Most Reviews](10048-top-businesses-with-most-reviews.sql) | Medium | 'Ties share a rank and skip' names RANK() (not DENSE_RANK). |
| 10077 | [Income By Title and Gender](10077-income-by-title-and-gender.sql) | Medium | The fan-out trap: an employee has many bonus rows, so summing bonuses per worker FIRST (subquery), then joining, keeps salary from being double counted. |
| 2005 | [Share of Active Users](2005-share-of-active-users.sql) | Medium | Part-over-whole from the SAME rows = conditional aggregation, no join. |
| 10352 | [Users By Average Session Time](10352-users-by-average-session-time.sql) | Medium | Grain is user + day: GROUP BY user_id, timestamp::date so MAX/MIN stay inside a single day. |
| 9894 | [Employee and Manager Salaries](9894-employee-and-manager-salaries.sql) | Medium | Self-join: alias the table twice, match e. |
| 10285 | [Acceptance Rate By Date](10285-acceptance-rate-by-date.sql) | Medium | 'Sent' and 'accepted' are different rows on different dates. |
| 10159 | [Ranking Most Active Guests](10159-ranking-most-active-guests.sql) | Medium | Aggregate then rank in one pass: DENSE_RANK() OVER (ORDER BY SUM(n_messages) DESC) with GROUP BY guest. |
| 2102 | [Flags Per Video](2102-flags-per-video.sql) | Medium | A 'unique user' spans two columns, so build the key with CONCAT and COUNT(DISTINCT . |
| 10172 | [Best Selling Item (first Hard)](10172-best-selling-item-first-hard.sql) | Hard | Full count → rank → filter skeleton. |
