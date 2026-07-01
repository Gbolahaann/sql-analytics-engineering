# Phase 1 — Foundations

| # | Question | Difficulty | Key technique |
|---|----------|-----------|---------------|
| 9653 | [MacBookPro User Event Count](9653-macbookpro-user-event-count.sql) | Easy | Plain COUNT + GROUP BY. |
| 9663 | [Most Profitable Financial Company](9663-most-profitable-financial-company.sql) | Easy | No aggregation needed — one row per company already. |
| 2170 | [Department Workforce Analysis](2170-department-workforce-analysis.sql) | Medium | HAVING filters AFTER grouping (on the COUNT); WHERE filters before. |
| 9728 | [Number of Violations](9728-number-of-violations.sql) | Easy | EXTRACT(YEAR FROM date) to bucket by year; COUNT(DISTINCT . |
| 9650 | [Top 10 Songs 2010](9650-top-10-songs-2010.sql) | Medium | DISTINCT matters: without it, duplicate chart rows inflate the list beyond 10. |
| 10183 | [Total Cost of Orders](10183-total-cost-of-orders.sql) | Easy | Join customers to orders on id = cust_id, then SUM per customer. |
| 2024 | [Unique Users Per Client Per Month](2024-unique-users-per-client-per-month.sql) | Easy | EXTRACT(MONTH FROM . |
| 10299 | [Finding Updated Records](10299-finding-updated-records.sql) | Easy | Aggregate in a subquery (MAX salary per id), then JOIN back on id AND salary to pull the matching row without fan-out. |
| 10353 | [Workers With The Highest Salaries](10353-workers-with-the-highest-salaries.sql) | Easy | The MAX must be scoped to titled workers, so the title join goes INSIDE the subquery that computes the max — otherwise the untitled top earner wins and returns an empty title. |
