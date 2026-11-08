-- ============================================================
-- IPL MATCH & BALL-BY-BALL ANALYSIS
-- Corrected companion script: add_IPL_MATCHES.sql
-- Database: PostgreSQL
--
-- Run from the repository root with psql in a fresh database:
--   psql -d your_database_name -f add_IPL_MATCHES.sql
--
-- The source CSVs use DD-MM-YYYY dates and NA as a null marker.
-- The deliveries table intentionally has no primary key: id is the
-- match id and therefore repeats across delivery rows. The source
-- data also contains 10 repeated (id, inning, over, ball) keys.
-- ============================================================

SET datestyle TO 'ISO, DMY';

CREATE TABLE ipl_matches (
    id              BIGINT PRIMARY KEY,
    city            VARCHAR(100),
    match_date      DATE,
    player_of_match VARCHAR(100),
    venue           VARCHAR(150),
    neutral_venue   SMALLINT,
    team1           VARCHAR(100),
    team2           VARCHAR(100),
    toss_winner     VARCHAR(100),
    toss_decision   VARCHAR(20),
    winner          VARCHAR(100),
    result          VARCHAR(50),
    result_margin   INTEGER,
    eliminator      VARCHAR(10),
    method          VARCHAR(50),
    umpire1         VARCHAR(100),
    umpire2         VARCHAR(100)
);

CREATE TABLE deliveries (
    id              BIGINT NOT NULL,
    inning          SMALLINT,
    over_no         SMALLINT,
    ball            SMALLINT,
    batsman         VARCHAR(100),
    non_striker     VARCHAR(100),
    bowler          VARCHAR(100),
    batsman_runs    INTEGER,
    extra_runs      INTEGER,
    total_runs      INTEGER,
    is_wicket       SMALLINT,
    dismissal_kind  VARCHAR(50),
    player_dismissed VARCHAR(100),
    fielder         VARCHAR(100),
    extras_type     VARCHAR(50),
    batting_team    VARCHAR(100),
    bowling_team    VARCHAR(100)
);

-- Import the match-level and delivery-level CSVs.
-- Run psql from the directory containing both CSV files.
\copy ipl_matches (id, city, match_date, player_of_match, venue, neutral_venue, team1, team2, toss_winner, toss_decision, winner, result, result_margin, eliminator, method, umpire1, umpire2) FROM 'IPL_matches.csv' WITH (FORMAT csv, HEADER true, NULL 'NA')
\copy deliveries (id, inning, over_no, ball, batsman, non_striker, bowler, batsman_runs, extra_runs, total_runs, is_wicket, dismissal_kind, player_dismissed, fielder, extras_type, batting_team, bowling_team) FROM 'IPL_Ball.csv' WITH (FORMAT csv, HEADER true, NULL 'NA')

-- Remove only derived tables so the analysis section can be rerun.
DROP TABLE IF EXISTS deliveries_v05;
DROP TABLE IF EXISTS deliveries_v04;
DROP TABLE IF EXISTS deliveries_v03;
DROP TABLE IF EXISTS deliveries_v02;
DROP TABLE IF EXISTS matches_corrected;

--Select the top 20 rows of the deliveries table after ordering them by id, inning, over, ball in ascending order.
SELECT *
FROM deliveries
ORDER BY id, inning, over_no, ball
LIMIT 20;

--Select the top 20 rows of the matches table.
SELECT *
FROM ipl_matches
LIMIT 20;

--Fetch data of all the matches played on 2nd May 2013 from the matches table
SELECT *
FROM ipl_matches
WHERE match_date = DATE '2013-05-02';

--Fetch data of all the matches where the result mode is ‘runs’ and margin of victory is more than 100 runs.
SELECT *
FROM ipl_matches
WHERE result = 'runs'
  AND result_margin > 100;

--Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date.
SELECT *
FROM ipl_matches
WHERE result = 'tie'
ORDER BY match_date DESC;

--Get the count of cities that have hosted an IPL match.
SELECT COUNT(DISTINCT city) AS cities_hosting_ipl
FROM ipl_matches;

--Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional column ball_result containing values boundary, dot or other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number)
-- Note: this preserves the original total_runs >= 4 definition. It is a boundary proxy,
-- not an exact batter-hit four/six count; use batsman_runs for that stricter metric.
CREATE TABLE deliveries_v02 AS
SELECT *,
       CASE
           WHEN total_runs >= 4 THEN 'boundary'
           WHEN total_runs = 0 THEN 'dot'
           ELSE 'other'
       END AS ball_result
FROM deliveries;

--Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table.
SELECT ball_result, COUNT(*) AS delivery_count
FROM deliveries_v02
WHERE ball_result IN ('boundary', 'dot')
GROUP BY ball_result
ORDER BY ball_result;

--Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table and order it in descending order of the number of boundaries scored.
SELECT batting_team, COUNT(*) AS boundary_count
FROM deliveries_v02
WHERE ball_result = 'boundary'
GROUP BY batting_team
ORDER BY boundary_count DESC;

--Write a query to fetch the total number of dot balls bowled by each team and order it in descending order of the total number of dot balls bowled.
SELECT bowling_team, COUNT(*) AS dot_count
FROM deliveries_v02
WHERE ball_result = 'dot'
GROUP BY bowling_team
ORDER BY dot_count DESC;

--Write a query to fetch the total number of dismissals by dismissal kinds where dismissal kind is not NA
SELECT dismissal_kind, COUNT(*) AS dismissal_count
FROM deliveries_v02
WHERE dismissal_kind IS NOT NULL
  AND dismissal_kind <> 'NA'
GROUP BY dismissal_kind
ORDER BY dismissal_count DESC;

--Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table
SELECT bowler, SUM(extra_runs) AS total_extra_runs
FROM deliveries
GROUP BY bowler
ORDER BY total_extra_runs DESC
LIMIT 5;

--Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column (named venue and match_date) of venue and date from table matches
CREATE TABLE deliveries_v03 AS
SELECT d.*, m.venue, m.match_date
FROM deliveries_v02 AS d
INNER JOIN ipl_matches AS m
    ON d.id = m.id;

--Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.
SELECT venue, SUM(total_runs) AS total_runs_scored
FROM deliveries_v03
GROUP BY venue
ORDER BY total_runs_scored DESC;

--Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored.
SELECT EXTRACT(YEAR FROM match_date)::INTEGER AS year,
       SUM(total_runs) AS total_runs_scored
FROM deliveries_v03
WHERE venue = 'Eden Gardens'
GROUP BY EXTRACT(YEAR FROM match_date)
ORDER BY total_runs_scored DESC;

--Get unique team1 names from the matches table, you will notice that there are two entries for Rising Pune Supergiant one with Rising Pune Supergiant and another one with Rising Pune Supergiants.  Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. Now analyse these newly created columns.
CREATE TABLE matches_corrected AS
SELECT *,
       CASE
           WHEN team1 = 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
           ELSE team1
       END AS team1_corr,
       CASE
           WHEN team2 = 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
           ELSE team2
       END AS team2_corr
FROM ipl_matches;

SELECT DISTINCT team1_corr FROM matches_corrected ORDER BY team1_corr;
SELECT DISTINCT team2_corr FROM matches_corrected ORDER BY team2_corr;

--Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, over and ball separated by ‘-’ (For ex. 335982-1-0-1 match_id-inning-over-ball) and rest of the columns same as deliveries_v03)
-- The delimiter is now '-' as specified in the original question.
CREATE TABLE deliveries_v04 AS
SELECT CONCAT_WS('-', id, inning, over_no, ball) AS ball_id,
       d.*
FROM deliveries_v03 AS d;

--Compare the total count of rows and total count of distinct ball_id in deliveries_v04;
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT ball_id) AS distinct_ball_ids,
       COUNT(*) - COUNT(DISTINCT ball_id) AS repeated_key_rows
FROM deliveries_v04;

--Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. (HINT : Syntax to add along with other columns,  row_number() over (partition by ball_id) as r_num)
CREATE TABLE deliveries_v05 AS
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY ball_id ORDER BY ball_id) AS r_num
FROM deliveries_v04;

SELECT * FROM deliveries_v05;

--Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. (HINT : select * from deliveries_v05 WHERE r_num=2;)
SELECT *
FROM deliveries_v05
WHERE r_num > 1;

--Use subqueries to fetch data of all the ball_id which are repeating. (HINT: SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2);
SELECT *
FROM deliveries_v05
WHERE ball_id IN (
    SELECT ball_id
    FROM deliveries_v05
    WHERE r_num > 1
);
