# SQL for Analytics Engineering — Learning in Public

A structured, daily journey from **expert BI developer** (Tableau, SQL-fluent Senior Data Analyst) toward **Analytics Engineering** — building the deep SQL fluency needed to write production-grade, multi-CTE warehouse queries.

I practise on [StrataScratch](https://www.stratascratch.com/) real interview questions, but I do it inside a **local SQL practice app I built myself** (see [`/app`](#the-practice-tool-i-built) below) so I own the whole loop: fetch the question, write the query, run it against real data, and log what I learned.

This repo is my proof of work — every solved question, and just as importantly, the **thinking** behind it.

---

## Why a BI expert is doing this

I already build dashboards and write analyst SQL day to day. Analytics Engineering asks for more: modelling data cleanly, reasoning about **grain**, avoiding silent correctness bugs (fan-out, integer division), and expressing intent in layered, readable SQL. This repo is me closing that gap deliberately, one question a day, and writing down the mental models so they stick.

## How I'm learning — with AI, deliberately

I run this practice with an **AI mentor**, but on purpose and on my terms. The rule I set: it gives me *hints, not answers* — one nudge per attempt, and it only reveals a full solution after I've genuinely tried. It pressure-tests my reasoning ("what does one row represent here?"), makes me explain concepts back before moving on, and ends each day with a scenario I have to break down into the right SQL constructs myself.

The point isn't to let AI write my SQL. It's to build **two** durable skills at once: deep SQL fluency, and the judgement to use AI as a thinking partner rather than a crutch — which is exactly how modern senior data and analytics-engineering work actually gets done.

---

## Progress

A 50-question roadmap across four phases.

```
Phase 1 — Foundations        [████████████████████]  10/10 ✅
Phase 2 — Window Functions   [████████████████████]  15/15 ✅
Phase 3 — CTEs               [█▎░░░░░░░░░░░░░░░░░░]   1/15
Phase 4 — Advanced           [░░░░░░░░░░░░░░░░░░░░]   0/10
─────────────────────────────────────────────────────────
Overall                      [██████████▍░░░░░░░░░]  26/50
```

Solutions captured so far live in [`/solutions`](solutions), organised by phase. Each `.sql` file carries the problem, my final query, and a short **"what I learned"** note.

- [Phase 1 — Foundations](solutions/phase-1-foundations) — filtering, aggregation, `GROUP BY`, joins
- [Phase 2 — Window Functions & Advanced Joins](solutions/phase-2-window-functions) — `RANK`/`DENSE_RANK`/`ROW_NUMBER`, `LAG`, `PARTITION BY`, self-joins, conditional aggregation
- [Phase 3 — CTEs & Set Logic](solutions/phase-3-ctes) — layered `WITH` CTEs, `EXISTS`/`NOT EXISTS`, set operations

---

## The mental models I keep returning to

These are the ideas that separate "the query ran" from "the query is correct." Each was learned the hard way on a specific question:

- **Grain first.** Before writing anything, name what *one row of the answer* represents. `GROUP BY` only when the output is coarser than the table. *(→ Highest Salary In Department, Users By Average Session Time)*
- **Fan-out corrupts aggregates.** If a join multiplies rows on one side, any `SUM`/`AVG` after it lies. Pre-aggregate the "many" side to matching grain **before** joining. *(→ Income By Title and Gender)*
- **Compare across rows = join or window, not `GROUP BY`.** When the two values you compare live on different rows (a send and its later acceptance), join them onto one line first. *(→ Acceptance Rate By Date)*
- **Partition by the group, never the thing you rank.** Top-N-per-group ranks *within* a group; partitioning by the ranked column puts everything at rank 1. *(→ Ranking Most Active Guests, Best Selling Item)*
- **Part-of-whole from the same rows = conditional aggregation, not a join.** `SUM(CASE WHEN … THEN 1 ELSE 0 END)` over `COUNT(*)`. *(→ Share of Active Users)*
- **The subquery-wall.** A window result can't be filtered in `WHERE` — wrap it and filter outside. *(→ Second Highest Salary)*
- **Two gotchas that bite every time:** integer division (`* 1.0`) and De Morgan on filters ("remove A or B" → `WHERE NOT A AND NOT B`).

The full reference: [`SQL_CHEATSHEET.md`](SQL_CHEATSHEET.md) — an intent → function map ("what am I trying to do?" → which construct).

---

## The practice tool I built

Rather than click through a website, I built a small local app so the whole practice loop is mine:

- **`app.py`** — Flask backend exposing run / submit / question endpoints.
- **`mcp_client.py`** — a from-scratch client that talks **directly** to StrataScratch's Model Context Protocol server over OAuth2 + PKCE, so queries run in ~2s instead of ~20s.
- **`static/`** — a CodeMirror SQL editor (Dracula theme) with run-the-highlighted-selection, live results, and attempt tracking.

It's intentionally simple, but building it taught me OAuth flows, MCP, and async job handling — engineering muscle that complements the SQL.

> Note: the app authenticates to my personal StrataScratch account. Credentials live only in a local, git-ignored `.oauth.json` and are never committed.

---

## Tech

PostgreSQL (StrataScratch's engine) · Python / Flask · CodeMirror · MCP · OAuth2 (PKCE)

I build in **Snowflake** day to day, so I also note dialect differences as they surface (e.g. `EXTRACT` vs `YEAR()`, aliases in `HAVING`, `||` vs `CONCAT`).

---

*Updated as I go. One question a day — depth over speed.*
