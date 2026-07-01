# SQL Function Cheat Sheet — "What am I trying to do?"

You don't pick functions from memory. You name your **intent**, and the intent points to the tool.
Read every question, translate it into intents FIRST, then the SQL almost writes itself.

---

## 1. Summarize many rows into fewer
**→ Aggregate + `GROUP BY`** (`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`)
Tell: fewer rows out than in. One row per customer / day / department.
Rule: if you write an aggregate, every non-aggregated SELECT column goes in `GROUP BY`.
> "Total revenue per customer" → `SUM(revenue) ... GROUP BY customer`

## 2. Summarize but KEEP every row
**→ Window function** `func() OVER (PARTITION BY ... ORDER BY ...)`
Tell: same number of rows out as in, just an extra column beside each row.
> "Each employee's salary AND their dept average" → `AVG(salary) OVER (PARTITION BY department)`

**THE #1 DECISION:** collapse rows → GROUP BY. Keep rows, add a column → window.

## 3. Rank or number things
**→ Ranking windows**
- `ROW_NUMBER()` → unique 1,2,3, no ties. ("latest record per user", "2nd purchase")
- `RANK()` → ties share, then SKIP (1,1,3). (prompt says "skip ranks")
- `DENSE_RANK()` → ties share, NO skip (1,1,2). ("2nd highest distinct value")
The wording about ties tells you which.

## 4. Look at a DIFFERENT row from the current one
**→ `LAG()` (previous) / `LEAD()` (next)**, within a partition.
> "Days between each purchase and the previous one" → `LAG(date) OVER (PARTITION BY user ORDER BY date)`

## 5. Two things to compare live in DIFFERENT rows / tables
**→ `JOIN`** (staple facts onto one line)
- Different tables → regular join (employee + bonus)
- Different rows of the SAME table → self-join (employee vs manager, sent vs accepted)

Pick the type:
- `INNER JOIN` → keep only rows matched on both sides
- `LEFT JOIN` → keep all of the left, attach right when it exists, NULL when not
  (use when "rows with no match still count" — e.g. a request never accepted)

## 6. A value that depends on a condition, row by row
**→ `CASE WHEN ... THEN ... ELSE ... END`**
Powerful inside an aggregate ("conditional counting"):
> "Count only accepted rows" → `SUM(CASE WHEN action='accepted' THEN 1 ELSE 0 END)`
> Or `COUNT(CASE WHEN action='accepted' THEN 1 END)` (NULL is skipped by COUNT)

## 7. Filter
**→ `WHERE` vs `HAVING`** (timing)
- `WHERE` → raw rows, BEFORE grouping. Can't see aggregates.
- `HAVING` → AFTER grouping. Use to filter on a COUNT/SUM.
> "Only departments with >5 people" → `HAVING COUNT(*) > 5`

## 8. Computed something but can't use it where I need it
**→ Subquery / CTE (the "wall")**
A rank/aggregate computed too late to filter? Wrap it, refer from outside.
> "Keep only rank = 2" → compute rank in a subquery, then `WHERE rnk = 2` outside.
`WITH temp AS (...)` = same idea, named and readable. Use once a query goes >2 layers deep.

---

## The meta-trick: SQL's logical running order
```
FROM/JOIN  →  WHERE  →  GROUP BY  →  HAVING  →  window functions  →  SELECT  →  ORDER BY  →  LIMIT
```
Almost every "must appear in GROUP BY" or "column does not exist" error is a STAGE-TIMING problem.
When stuck, ask: *"has this thing been computed yet, at the stage where I'm trying to use it?"*

Why you can't filter a window function in WHERE: windows run AFTER where. Wrap in a subquery.
Why bare `salary` errors with an aggregate: after GROUP BY, raw columns are gone.

---

## Two gotchas that bite every time
- **Integer division**: `3 / 4 = 0` in PostgreSQL. Multiply by `1.0` or cast to FLOAT to get `0.75`.
- **Fan-out / grain**: if a JOIN multiplies rows on one side, any aggregate after it LIES.
  Pre-aggregate the "many" side down to one-row-per-key BEFORE joining.

---

## How to read a question (the actual skill)
Translate the sentence into intents before writing any SQL:
- "rate PER date"            → one row per date  → GROUP BY + aggregate
- "sent vs accepted are different rows" → JOIN them first
- "requests with no acceptance still count" → LEFT JOIN
- "count only the accepted ones" → conditional COUNT / CASE
- "second highest"           → ranking window + subquery-wall
- "compared to the previous"  → LAG

The functions are just vocabulary. Breaking the sentence into intents is the real work.
