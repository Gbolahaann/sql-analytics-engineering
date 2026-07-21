# Phase 3 — CTEs & Set Logic

| # | Question | Difficulty | Key technique |
|---|----------|-----------|---------------|
| 2172 | [Customers with Large Orders](2172-customers-with-large-orders.sql) | Medium | EXISTS as a yes/no existence test ("at least one"); avoids the fan-out that JOIN + DISTINCT hides. |
| 2054 | [Consecutive Days](2054-consecutive-days.sql) | Hard | Gaps-and-islands: (date − ROW_NUMBER) is constant within a streak. Lesson: PARTITION BY user_id is required — "passed the grader" ≠ correct. |
| 9813 | [Make the Friends Network Symmetric](9813-make-friends-network-symmetric.sql) | Medium | Set ops stack rows: UNION original with column-swapped copy. UNION (not UNION ALL) because the halves overlap — dedupes existing bidirectional pairs. |
| 10090 | [Percentage of Shipable Orders](10090-percentage-of-shipable-orders.sql) | Medium | Conditional COUNT over total, floated + scaled; NULL = unknown address (IS NOT NULL); LEFT JOIN keeps all orders in the denominator. |
| 9905 | [Highest Target Under Manager](9905-highest-target-under-manager.sql) | Medium | Top-with-ties = DENSE_RANK, filter rnk=1 in a CTE. Simplification: no self-join needed to filter by manager_id, no SUM when each row is unique. |
| 10130 | [Inspections by Risk Category per Type](10130-inspections-by-risk-category-per-type.sql) | Medium | Pivot with COUNT(CASE WHEN category THEN id END) — one column per category. Catch: plain COUNT not COUNT(DISTINCT), since one inspection spans many rows. |
| 9814 | [Counting Instances in Text](9814-counting-instances-in-text.sql) | Hard | Explode text into word-rows with regexp_split_to_table, then GROUP BY + COUNT. Harden with lower() (case) and split on `[^a-z]+` (punctuation). |
| 10049 | [Reviews of Categories](10049-reviews-of-categories.sql) | Medium | Semicolon-separated list in a column → explode with regexp_split_to_table('\s*;\s*'), carry review_count along, GROUP BY + SUM. |
| 10085 | [Matching Users Pairs](10085-matching-users-pairs.sql) | Medium | Self-join to compare rows: = for "same", <> for "different". Pair-direction wrinkle: this grader wants both (a,b) and (b,a), so a.id <> b.id (not <). |
| 9856 | [Employees With the Same Salary](9856-employees-with-the-same-salary.sql) | Medium | COUNT(*) OVER (PARTITION BY salary) > 1 as an existence test. Reinforced: match output columns exactly, and only compute what the output needs. |
| 10078 | [Matching Similar Hosts and Guests](10078-matching-hosts-and-guests.sql) | Medium | Two tables joined on matching attributes (gender AND nationality). No </<> trick — that's only for self-joins. |
