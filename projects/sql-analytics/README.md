# Titanic Survival Analytics — SQL + DuckDB

Analysis of 714 passenger records answering 7 business questions about
survival patterns across class, gender, age, fare, and family size —
using window functions, CTEs, and conditional aggregation.

## Key Findings

**Gender outweighed money.** First-class women survived at 96.5% vs
15.0% for third-class men — a 6.4× gap. Notably, second-class men
(15.2%) fared no better than third-class men: lifeboat priority was
gender-first, class-second.

**Fare predicted survival almost linearly.** Survival climbed with
every fare band: Low 19.9% → Mid 43.3% → High 56.3% → Premium 75.0%.
A premium ticket made you ~3.8× more likely to survive than a low-fare
ticket.

**But money couldn't guarantee survival.** 132 casualties paid above
the average fare. Mr. Charles Fortune paid £263 — over 10× the average —
and died alongside another Fortune family member. The Allison family
shows the same pattern: premium tickets, no survival.

**Family size had a non-linear effect.** Small families (1–3 relatives)
survived best, solo travellers came second, and large families (4+)
did worst — small groups helped each other, while large families
waited to board together and often none made it.

**Children survived at 54%** — nearly 2.4× the senior rate (22.7%),
confirming "women and children first" in the data.

## Project Structure

```
sql-analytics/
├── schema/
│   └── create_tables.sql      # Silver layer: typed, enriched table
│                              # with derived columns (age_group,
│                              # fare_band, family_size, port names)
├── analysis/
│   ├── 01_survival_by_class_gender.sql
│   ├── 02_survival_by_age_group.sql
│   ├── 03_top_fare_payers_per_class.sql
│   ├── 04_revenue_share_per_passenger.sql
│   ├── 05_survival_by_fare_band.sql
│   ├── 06_paid_above_avg_not_survived.sql
│   └── 07_family_size_vs_survival.sql
└── README.md
```

## SQL Patterns Demonstrated

- **Conditional aggregation** — `SUM(CASE WHEN ...)` for pivot-style
  rates without PIVOT syntax (Q1, Q2, Q5, Q7)
- **Top N per group** — `ROW_NUMBER() OVER (PARTITION BY ...)` with
  tie-handling considerations vs DENSE_RANK (Q3)
- **Window grand totals** — `SUM(fare) OVER ()` for inline revenue
  share without joins (Q4)
- **Window functions with filtering** — computing `AVG() OVER ()` in a
  subquery because window functions can't appear in WHERE; filter
  placement defines the population the average covers (Q6)
- **Derived dimension buckets** — CASE-based age groups, fare bands,
  and family-size categories built in the schema layer (Medallion
  Silver pattern)
- **Rate vs ratio discipline** — survivors/total (rate), not
  survivors/casualties (ratio); `* 100.0` to avoid integer division;
  `NULLIF` on denominators

## Tools

- **DuckDB** — in-process analytical database, reads Parquet natively
- **DBeaver** — interactive query development
- **Source data** — Titanic dataset (891 rows → 714 after cleaning
  null ages/fares in the Bronze → Silver step)

## How to Run

```bash
# Requires DuckDB CLI (brew install duckdb)
duckdb titanic.duckdb

-- Build the Silver table from Parquet
.read schema/create_tables.sql

-- Run any analysis
.read analysis/01_survival_by_class_gender.sql
```