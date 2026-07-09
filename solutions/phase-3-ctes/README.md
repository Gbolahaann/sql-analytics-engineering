# Phase 3 — CTEs & Set Logic

| # | Question | Difficulty | Key technique |
|---|----------|-----------|---------------|
| 2172 | [Customers with Large Orders](2172-customers-with-large-orders.sql) | Medium | EXISTS as a yes/no existence test ("at least one"); avoids the fan-out that JOIN + DISTINCT hides. |
| 2054 | [Consecutive Days](2054-consecutive-days.sql) | Hard | Gaps-and-islands: (date − ROW_NUMBER) is constant within a streak. Lesson: PARTITION BY user_id is required — "passed the grader" ≠ correct. |
| 9813 | [Make the Friends Network Symmetric](9813-make-friends-network-symmetric.sql) | Medium | Set ops stack rows: UNION original with column-swapped copy. UNION (not UNION ALL) because the halves overlap — dedupes existing bidirectional pairs. |
| 10090 | [Percentage of Shipable Orders](10090-percentage-of-shipable-orders.sql) | Medium | Conditional COUNT over total, floated + scaled; NULL = unknown address (IS NOT NULL); LEFT JOIN keeps all orders in the denominator. |
