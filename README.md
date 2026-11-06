# IPL Match & Ball-by-Ball Analysis | PostgreSQL

A SQL portfolio project exploring Indian Premier League (IPL) match results and ball-by-ball delivery data. The project demonstrates relational data preparation, data quality checks, aggregations, joins, conditional logic, and window functions using PostgreSQL.

## Project overview

The repository contains two related datasets:

- **Match-level data** — match date, city, venue, teams, toss decision, winner, result, and player of the match.
- **Delivery-level data** — innings, over, ball, batter, bowler, runs, extras, wickets, dismissal type, and batting/bowling teams.

The analysis moves from match-level questions to delivery-level performance patterns and data-quality checks.

## Business questions explored

### Match analysis
- How many distinct cities have hosted IPL matches?
- Which matches were decided by a margin of more than 100 runs?
- Which matches ended in a tie?
- How are match wins distributed across teams and venues?
- How did scoring at Eden Gardens vary by year?

### Ball-by-ball analysis
- Which teams scored the most batter boundaries (4s and 6s)?
- Which bowling teams delivered the most dot balls?
- What are the most common dismissal types?
- Which bowlers conceded the most extra runs?
- How many runs were scored at each venue?

### Data quality
- How can inconsistent team labels be standardized?
- Are delivery identifiers unique when built from match, innings, over, and ball?
- How can repeated delivery keys be isolated with `ROW_NUMBER()`?

## SQL skills demonstrated

| Skill | Where it is used |
|---|---|
| DDL and table design | Creating match and delivery tables |
| Filtering and sorting | Date, result, and margin analysis |
| Aggregations | `COUNT`, `SUM`, `GROUP BY` |
| Conditional logic | `CASE`-based delivery classification and label standardization |
| Joins | Enriching deliveries with match venue and date |
| Type conversion | Converting result margins for numeric comparisons |
| Date functions | Extracting match year |
| Window functions | `ROW_NUMBER()` for duplicate-key inspection |
| Subqueries | Retrieving repeated delivery records |

## Repository structure

```text
SQL-Project-Ipl/
├── IPL_matches.csv
├── IPL_Ball.csv
├── IPL_MATCHES.sql                 # Original project SQL
├── QUERY.txt                      # Original query notes
├── README.md
└── sql/
    ├── 01_setup_and_import.sql     # Reproducible PostgreSQL setup and CSV import
    └── 02_analysis_queries.sql     # Clean, grouped analysis queries
```

## Tech stack

- PostgreSQL
- SQL
- CSV datasets

## Run the project

### 1. Create a PostgreSQL database

Create a database in PostgreSQL, then open a terminal in the repository root.

### 2. Create tables and import the datasets

Run the setup script with `psql`:

```bash
psql -d your_database_name -f sql/01_setup_and_import.sql
```

The script uses PostgreSQL's `\\copy` command and expects the two CSV files to be in the repository root. Run it from the repository root so the relative file paths resolve.

### 3. Run the analysis queries

```bash
psql -d your_database_name -f sql/02_analysis_queries.sql
```

You can also open the SQL files in pgAdmin or another PostgreSQL client. The import commands in the setup script are `psql` meta-commands; if you use pgAdmin, create the tables first and import each CSV with its Import/Export feature.

## Data notes and limitations

- The original `IPL_MATCHES.sql` is retained as submitted. It contains machine-specific Windows file paths and table-constraint changes, so use the new `sql/` scripts for a clean setup on another machine.
- The original project classifies deliveries with `total_runs >= 4` as boundaries. The new analysis query uses `batsman_runs IN (4, 6)` for batter boundaries and `total_runs = 0` for dot balls, making the definitions explicit.
- The repository does not currently document the original dataset publisher or its licence. Add the source and permitted-use details if you have them.
- No dashboard or numerical findings are claimed in this README. Run the queries against the supplied data to reproduce results.

## Possible next improvements

- Add query result screenshots or a short findings summary after validating the outputs.
- Add indexes on frequently joined or filtered columns if query performance becomes a focus.
- Add a data dictionary and document the dataset source and licence.

## Author

**Raj Kishore Agrawal**

- [LinkedIn](https://www.linkedin.com/in/rajagrawal1/)
- [GitHub](https://github.com/rraj12345)
