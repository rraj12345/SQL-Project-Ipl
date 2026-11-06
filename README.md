# IPL Match & Ball-by-Ball Analysis | PostgreSQL

A PostgreSQL project exploring Indian Premier League match results and delivery-level performance. The work combines match data with ball-by-ball records to examine team outcomes, scoring patterns, bowling contributions, venue performance, and data consistency.

## Project objective

The goal is to turn two related cricket datasets into a relational SQL analysis and demonstrate how match-level and delivery-level data can answer practical questions for team analysts, tournament operations, broadcasters, and cricket fans.

## Dataset overview

| File | Grain | Main fields |
|---|---|---|
| `IPL_matches.csv` | One row per match | Match ID, city, date, player of the match, venue, teams, toss decision, winner, result, result margin, umpires |
| `IPL_Ball.csv` | One row per delivery record | Match ID, innings, over, ball, batter, non-striker, bowler, batter runs, extra runs, total runs, wicket and dismissal details, batting and bowling teams |

The match identifier `id` connects delivery records to the corresponding match in `IPL_Matches`. The SQL script uses PostgreSQL table names `IPL_Matches` and `deliveries`.

## Analysis performed in the original SQL

### 1. Match results and tournament coverage

- Retrieve matches played on a specified date.
- Identify matches won by more than 100 runs.
- List tied matches, ordered by match date.
- Count distinct cities that have hosted matches.

**Business relevance:** These questions help describe tournament reach, identify one-sided contests, and review close or unusual match outcomes. A tournament or media team could use this information when preparing venue summaries and match retrospectives.

### 2. Batting and bowling performance

- Classify delivery records into `boundary`, `dot`, and `other` using `total_runs`.
- Count boundary-classified and dot-ball records.
- Rank batting teams by the number of boundary-classified deliveries.
- Rank bowling teams by dot-ball records.
- Summarize dismissals by dismissal type.
- Identify the five bowlers with the highest total extra runs conceded.

**Business relevance:** Boundary frequency can help compare attacking output, while dot-ball frequency can indicate how effectively a bowling side restricts scoring opportunities. Dismissal mix and extras can support bowling-performance reviews.

**Interpretation note:** The original `CASE` expression defines a boundary as `total_runs >= 4`. Because it uses total runs rather than batter runs, deliveries involving extras can also enter this category. Treat this as the project's original *boundary proxy*, not an exact count of batter-hit fours and sixes.

### 3. Venue and season analysis

- Join delivery data to match data to attach venue and match date.
- Calculate total runs by venue.
- Calculate year-wise runs at Eden Gardens.

**Business relevance:** Venue-level scoring summaries can support ground comparisons, broadcast context, and discussions about how scoring output differs across venues and seasons.

### 4. Data cleaning and quality checks

- Standardize the two spellings `Rising Pune Supergiants` and `Rising Pune Supergiant` into a consistent team label in a derived match table.
- Construct a delivery key from match ID, innings, over, and ball.
- Compare total rows with distinct delivery keys.
- Use `ROW_NUMBER()` partitioned by the constructed key to identify repeated keys.
- Use a subquery to return all records associated with repeated keys.

**Business relevance:** Consistent team labels improve grouping and reporting. Delivery-key checks help identify potential duplicate records before using ball-level data for performance metrics.

## Business takeaways this analysis can support

The SQL work provides a foundation for questions such as:

- Which teams appear strongest at generating boundary-classified scoring events?
- Which bowling teams are most effective at creating dot-ball pressure?
- Which bowlers may need to review their extras conceded?
- How does total scoring vary by venue and by year at a selected ground?
- Which dismissal types occur most frequently in the recorded delivery data?
- Are team labels and delivery identifiers reliable enough for repeatable reporting?

These are interpretation opportunities based on the queries in the repository. No numerical ranking or performance conclusion is claimed here because query outputs have not been attached or independently validated.

## SQL concepts demonstrated

| Concept | Application in the project |
|---|---|
| DDL and data types | Creating match and delivery tables |
| CSV loading | Importing the two source datasets |
| Filtering and sorting | Date, result, margin, and top-row queries |
| Aggregation | `COUNT`, `SUM`, `GROUP BY` |
| Conditional logic | Delivery classification and team-name standardization with `CASE` |
| Joins | Adding match venue and date to delivery records |
| Type conversion | Casting result margin for numeric comparison |
| Date functions | Extracting year from match date |
| Window functions | `ROW_NUMBER() OVER (PARTITION BY ...)` |
| Subqueries | Retrieving records associated with repeated delivery keys |
| Data quality checks | Comparing row counts and distinct constructed keys |

## Repository structure

```text
SQL-Project-Ipl/
├── IPL_matches.csv       # Match-level source data
├── IPL_Ball.csv          # Ball-by-ball source data
├── IPL_MATCHES.sql       # Table creation, loading, transformations and analysis
├── QUERY.txt             # Query notes / copy of the original SQL workflow
└── README.md             # Project documentation
```

## Technology

- PostgreSQL
- SQL
- CSV datasets

## How to run

1. Create a PostgreSQL database.
2. Open `IPL_MATCHES.sql` in pgAdmin or another PostgreSQL client.
3. Review the table definitions and update the CSV file locations in the `COPY` statements to match your machine.
4. Execute the script in stages: table creation, data loading, derived-table creation, and analysis queries.

**Important setup note:** The original script is preserved as the source of truth, but its import section needs local adjustment before a fresh run. It renames `IPL_BALL` to `deliveries` and then attempts to load data into `IPL_BALL`; that table name no longer exists after the rename. The `COPY` statements also contain machine-specific Windows paths. Correct the target table name and file paths in your local working copy before executing the import section.

## Data and methodology notes

- The project contains both match-level and delivery-level data; their relationship is based on match ID.
- The original SQL creates intermediate tables (`deliveries_v02` through `deliveries_v05`) to keep derived classifications, match context, and duplicate checks separate from the source table.
- The constructed `ball_id` in the SQL uses commas between its components, although the accompanying comment describes hyphens. The key is still intended to combine match ID, innings, over, and ball.
- The current boundary classification uses `total_runs >= 4`; use `batsman_runs` if the intended metric is batter-hit boundaries only.
- Duplicate-key checks identify repeated constructed identifiers; they do not by themselves establish why a repeated record exists.
- The repository does not currently document the dataset publisher or licence. Add source attribution and usage terms if you have them.

## Future enhancements

- Validate and fix the original import section so the project can be run from a clean database without manual troubleshooting.
- Add query output screenshots or exported result tables after executing the SQL.
- Add a data dictionary and document dataset provenance.
- Consider a more precise boundary definition based on batter runs and a deterministic ordering in duplicate inspection.
- Add validated season-wise team and player summaries if you extend the analysis.

## Author

**Raj Kishore Agrawal**

- [GitHub](https://github.com/rraj12345)
- [LinkedIn](https://www.linkedin.com/in/rajagrawal1/)
