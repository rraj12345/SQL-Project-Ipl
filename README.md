# IPL Match & Ball-by-Ball Performance Analysis

**SQL portfolio project | PostgreSQL | Match analytics | Bowling & batting metrics | Data quality**

## 1. Project at a glance

This project analyses Indian Premier League (IPL) match results and ball-by-ball delivery data using PostgreSQL. It connects match-level information with delivery-level records to examine tournament outcomes, scoring patterns, team performance, bowling discipline, venue scoring, and data consistency.

The work is based on the two supplied IPL CSV datasets and the original SQL exercises in `IPL_MATCHES.sql`. `QUERY.txt` is a text copy of the same SQL workflow.

| Project measure | Dataset coverage |
|---|---:|
| Matches | **816** |
| Ball-by-ball records | **193,468** |
| Match dates | **18 Apr 2008 – 10 Nov 2020** |
| Cities represented | **33** |
| Venues represented | **36** |
| Raw team-name labels | **15** |
| Total runs in delivery data | **252,794** |

*Counts and summary measures in this README were calculated from the repository CSV files. They describe this historical dataset, not the current IPL.*

## 2. Business context and questions

A cricket analytics team needs to understand more than just who won a match. Match-level data explains outcomes and tournament coverage; delivery-level data helps explain how runs, wickets, and pressure were created.

This project explores questions relevant to team performance reviews, tournament reporting, venue comparisons, and data preparation:

- Which teams have the highest recorded match-win counts?
- How often did matches end in a tie or in a win by more than 100 runs?
- Which batting teams recorded the most boundary-classified deliveries?
- Which bowling teams created the most dot balls?
- Which bowlers conceded the most extras?
- Which dismissal types occur most often?
- Which venues recorded the highest aggregate run totals?
- How did scoring at Eden Gardens vary by year?
- Are team labels consistent, and are delivery identifiers unique?

## 3. Data sources and model

### Source files

| File | Record grain | Main columns |
|---|---|---|
| `IPL_matches.csv` | One row per match | `id`, `city`, `date`, `venue`, `team1`, `team2`, `toss_winner`, `winner`, `result`, `result_margin`, player of the match, umpires |
| `IPL_Ball.csv` | One row per delivery record | `id`, `inning`, `over`, `ball`, `batsman`, `bowler`, `batsman_runs`, `extra_runs`, `total_runs`, wicket and dismissal fields, batting and bowling teams |

### Relationship

The two files are linked by `id`:

- `IPL_Matches.id` identifies a match.
- `deliveries.id` repeats for each delivery in that match.
- The SQL joins these tables to bring match date and venue onto each delivery record.

This is a simple match-to-deliveries one-to-many relationship. The original script removes the primary-key constraint from the delivery table because match ID is not unique at delivery grain.

## 4. Analysis workflow

### A. Match and tournament analysis

The original SQL filters matches by date, identifies wins by more than 100 runs, lists tied matches, and counts distinct host cities.

**Dataset findings**

| Measure | Result |
|---|---:|
| Matches decided by more than 100 runs (result = runs) | **9** |
| Tied matches | **13** |
| Distinct host cities | **33** |

The match data contains 816 records from 2008 through 2020. The highest match-win counts in the supplied data are:

| Team label in source data | Recorded wins |
|---|---:|
| Mumbai Indians | **120** |
| Chennai Super Kings | **106** |
| Kolkata Knight Riders | **99** |
| Royal Challengers Bangalore | **91** |
| Kings XI Punjab | **88** |

*These are raw counts in the supplied extract. They are not adjusted for seasons played, franchise changes, or matches with no result.*

### B. Batting and bowling performance

The SQL creates `deliveries_v02` and assigns each delivery a `ball_result` using a `CASE` expression:

- `boundary`: `total_runs >= 4`
- `dot`: `total_runs = 0`
- `other`: all remaining records

It then aggregates these labels by batting team and bowling team, counts dismissal types, and ranks bowlers by extra runs conceded.

**Delivery-level measures**

| Measure | Result |
|---|---:|
| Total runs across delivery records | **252,794** |
| Extra runs | **12,849** |
| Dot-ball records (`total_runs = 0`) | **67,841** |
| Boundary-classified records (`total_runs >= 4`) | **31,468** |
| Dismissal records with a non-NA dismissal type | **9,495** |

**Teams with the most boundary-classified records**

| Batting team | Records |
|---|---:|
| Mumbai Indians | **4,118** |
| Royal Challengers Bangalore | **3,800** |
| Kings XI Punjab | **3,780** |
| Kolkata Knight Riders | **3,739** |
| Chennai Super Kings | **3,496** |

**Bowling teams with the most dot-ball records**

| Bowling team | Dot balls |
|---|---:|
| Mumbai Indians | **8,714** |
| Royal Challengers Bangalore | **7,955** |
| Kolkata Knight Riders | **7,894** |
| Kings XI Punjab | **7,679** |
| Chennai Super Kings | **7,593** |

**Bowlers with the most extra runs conceded**

| Bowler | Extra runs |
|---|---:|
| SL Malinga | **293** |
| P Kumar | **236** |
| UT Yadav | **226** |
| DJ Bravo | **210** |
| B Kumar | **201** |

**Most frequent dismissal types**

| Dismissal type | Records |
|---|---:|
| Caught | **5,743** |
| Bowled | **1,700** |
| Run out | **893** |
| LBW | **571** |
| Stumped | **294** |

**Business interpretation:** These measures help compare scoring output and bowling pressure, identify where extras are accumulating, and understand the main ways wickets are being taken. The counts are cumulative across the supplied period; they should not be treated as per-match or per-over efficiency rates.

### C. Venue and season analysis

The SQL joins delivery records to match details, then aggregates total runs by venue and year at Eden Gardens.

**Highest aggregate run totals by venue**

| Venue | Runs |
|---|---:|
| Eden Gardens | **23,658** |
| Wankhede Stadium | **23,390** |
| Feroz Shah Kotla | **22,947** |
| M Chinnaswamy Stadium | **20,237** |
| Rajiv Gandhi International Stadium, Uppal | **19,484** |

**Eden Gardens: highest-scoring years in the supplied data**

| Year | Runs |
|---|---:|
| 2018 | **2,885** |
| 2019 | **2,651** |
| 2015 | **2,386** |
| 2013 | **2,304** |
| 2017 | **2,194** |

**Business interpretation:** Venue totals can support ground-level scoring comparisons and broadcast context. They are influenced by the number of matches played at each venue, so they do not by themselves establish that one venue is easier for batting.

### D. Data cleaning and quality checks

The original SQL also creates derived tables to standardize team names and inspect repeated delivery keys.

- It standardizes `Rising Pune Supergiants` to `Rising Pune Supergiant` in derived team columns.
- It creates a composite delivery identifier from match ID, innings, over, and ball.
- It compares the total number of delivery rows with the number of distinct identifiers.
- It uses `ROW_NUMBER()` and a subquery to retrieve repeated identifiers.

**Data-quality result**

| Check | Result |
|---|---:|
| Delivery rows | **193,468** |
| Distinct composite delivery IDs | **193,458** |
| Composite IDs appearing more than once | **10** |
| Rows belonging to those repeated-ID groups | **20** |

This check identifies 10 repeated composite keys in the supplied delivery data. It is a useful validation step before building delivery-level metrics; it does not, on its own, explain why those records repeat.

## 5. Important metric definition

The project's original boundary logic uses `total_runs >= 4`. That is not the same as counting deliveries where the batter scored four or more runs.

When the same source data is checked using `batsman_runs >= 4`, there are **30,870** such delivery records, compared with **31,468** under the project's original `total_runs >= 4` rule. The difference is **598 records**.

For an exact batter-boundary KPI, use `batsman_runs >= 4`. The README reports the original project's 31,468 figure as *boundary-classified records* so the measure is not misrepresented.

## 6. SQL skills demonstrated

- Relational table design and data types
- CSV loading with PostgreSQL `COPY`
- Filtering, sorting, and limiting
- Aggregations with `COUNT` and `SUM`
- Conditional logic with `CASE`
- Joins between match and delivery data
- Type conversion with `CAST`
- Date extraction with `EXTRACT`
- Window functions with `ROW_NUMBER()`
- Subqueries and composite-key data-quality checks

## 7. Repository structure

```text
SQL-Project-Ipl/
├── IPL_matches.csv       # Match-level source data
├── IPL_Ball.csv          # Ball-by-ball source data
├── IPL_MATCHES.sql       # Original PostgreSQL workflow and analysis
├── QUERY.txt             # Text copy of the same SQL workflow
└── README.md             # Project overview, findings and instructions
```

## 8. How to reproduce the analysis

1. Install PostgreSQL and create a database.
2. Download or clone this repository.
3. Open `IPL_MATCHES.sql` in pgAdmin or a PostgreSQL SQL client.
4. Review the table creation statements and update the CSV paths to locations on your computer.
5. Execute the setup and import statements after correcting the import issues noted below.
6. Run the analysis and derived-table queries in sequence.

### Setup issues to resolve before running

The original SQL is preserved as the project submission, but it should not be executed unchanged on a fresh database:

- The script renames `IPL_BALL` to `deliveries`, then later attempts to `COPY` into `IPL_BALL`. That table name no longer exists after the rename.
- The two `COPY` targets do not match the comments describing which CSV belongs in which table. Load `IPL_matches.csv` into `IPL_Matches` and `IPL_Ball.csv` into `deliveries`.
- The `COPY` statements contain machine-specific Windows file paths. Replace them with valid local paths or use PostgreSQL's client-side `\\copy` command.
- Check the date format in `IPL_matches.csv` (DD-MM-YYYY) against the PostgreSQL session's date settings before loading.

## 9. Limitations and next steps

- The supplied data ends on 10 November 2020; it is not a current IPL dataset.
- Team names and franchise identities changed over the period. The original script corrects one known spelling variation, but a full franchise mapping would be needed for longitudinal team comparisons.
- Several performance measures are raw totals. Per-match, per-innings, or per-over rates would make comparisons fairer across teams with different numbers of matches.
- The original boundary proxy uses total runs; use batter runs for exact batter-boundary counts.
- The source repository does not currently document the dataset publisher or licence. Add attribution if you have the original source details.

Possible extensions include team win percentage by season, batting and bowling rates per match, player-level strike rate and economy rate, toss-decision outcomes, and a more complete franchise-name mapping.

## Author

**Raj Kishore Agrawal**

- [GitHub](https://github.com/rraj12345)
- [LinkedIn](https://www.linkedin.com/in/rajagrawal1/)
