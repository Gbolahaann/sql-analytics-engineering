# Phase 3 — CTEs & Set Logic

| # | Question | Difficulty | Key technique |
|---|----------|-----------|---------------|
| 2172 | [Customers with Large Orders](2172-customers-with-large-orders.sql) | Medium | EXISTS as a yes/no existence test ("at least one"); avoids the fan-out that JOIN + DISTINCT hides. |
| 2054 | [Consecutive Days](2054-consecutive-days.sql) | Hard | Gaps-and-islands: (date − ROW_NUMBER) is constant within a streak. Lesson: PARTITION BY user_id is required — "passed the grader" ≠ correct. |
