--Create a table named ‘IPL_Matches’ with appropriate data types for columns
CREATE TABLE IPL_Matches (
    id INT PRIMARY KEY,
    city VARCHAR(100),
    date DATE,
    player_of_match VARCHAR(100),
    venue VARCHAR(100),
    neutral_venue BOOLEAN,
    team1 VARCHAR(100),
    team2 VARCHAR(100),
    toss_winner VARCHAR(100),
    toss_decision VARCHAR(20),
    winner VARCHAR(100),
    result VARCHAR(50),
    result_margin VARCHAR(50),
    eliminator BOOLEAN,
    method VARCHAR(50),
    umpire1 VARCHAR(100),
    umpire2 VARCHAR(100)
);

--Create a table named ‘deliveries’ with appropriate data types for columns

CREATE TABLE IPL_BALL (
    id INT PRIMARY KEY,
    inning INT,
    over INT,
    ball INT,
    batsman VARCHAR(100),
    non_striker VARCHAR(100),
    bowler VARCHAR(100),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    is_wicket BOOLEAN,
    dismissal_kind VARCHAR(50),
    player_dismissed VARCHAR(100),
    fielder VARCHAR(100),
    extras_type VARCHAR(50),
    batting_team VARCHAR(100),
    bowling_team VARCHAR(100)
);
ALTER TABLE IPL_BALL
DROP CONSTRAINT ipl_ball_pkey;
ALTER TABLE IPL_Matches
DROP CONSTRAINT ipl_matches_pkey;
ALTER TABLE IPL_BALL RENAME TO deliveries;



--Import data from csv file ’IPL_matches.csv’ attached in resources to the table ‘matches’ which was created in Q1
COPY IPL_BALL FROM 'C:\Program Files\PostgreSQL\Data\IPLMatches+IPLBall/IPL_Ball.csv' CSV HEADER;

--Import data from csv file ’IPL_Ball.csv’ attached in resources to the table ‘deliveries’ which was created in Q2
COPY IPL_Matches FROM 'C:\Program Files\PostgreSQL\Data\IPLMatches+IPLBall/IPL_matches.csv' CSV HEADER NULL 'NA';

--Select the top 20 rows of the deliveries table after ordering them by id, inning, over, ball in ascending order.
SELECT * FROM deliveries ORDER BY id, inning, over, ball LIMIT 20;

--Select the top 20 rows of the matches table.
Select * from IPL_Matches limit 20;

--Fetch data of all the matches played on 2nd May 2013 from the matches table
SELECT * FROM IPL_Matches  WHERE date = '2013-05-02';

--Fetch data of all the matches where the result mode is ‘runs’ and margin of victory is more than 100 runs.
SELECT *
FROM IPL_Matches
WHERE result = 'runs' AND CAST(result_margin AS INTEGER) > 100;

--Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date.
SELECT *
FROM IPL_Matches
WHERE result = 'tie'
ORDER BY date DESC;

--Get the count of cities that have hosted an IPL match.
Select count(distinct city) from IPL_Matches;

--Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional column ball_result containing values boundary, dot or other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number)
CREATE TABLE deliveries_v02 AS
SELECT *,
       CASE 
           WHEN total_runs >= 4 THEN 'boundary'
           WHEN total_runs = 0 THEN 'dot'
           ELSE 'other'
       END AS ball_result
FROM deliveries;

--Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table.
SELECT ball_result, COUNT(*) AS count
FROM deliveries_v02
WHERE ball_result IN ('boundary', 'dot')
GROUP BY ball_result;

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
AND dismissal_kind != 'NA'
GROUP BY dismissal_kind;


--Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table
SELECT bowler, SUM(extra_runs) AS total_extra_runs
FROM deliveries
GROUP BY bowler
ORDER BY total_extra_runs DESC
LIMIT 5;


--Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column (named venue and match_date) of venue and date from table matches
CREATE TABLE deliveries_v03 AS
SELECT d.*, m.venue, m.date
FROM deliveries_v02 d
JOIN IPL_Matches m ON d.id = m.id;

--Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.
SELECT venue, SUM(total_runs) AS total_runs_scored
FROM deliveries_v03
GROUP BY venue
ORDER BY total_runs_scored DESC;

--Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored.
SELECT EXTRACT(YEAR FROM date) AS year,
       SUM(total_runs) AS total_runs_scored
FROM deliveries_v03
WHERE venue = 'Eden Gardens'
GROUP BY year
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
FROM IPL_Matches;

--Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, over and ball separated by ‘-’ (For ex. 335982-1-0-1 match_id-inning-over-ball) and rest of the columns same as deliveries_v03)
CREATE TABLE deliveries_v04 AS
SELECT CONCAT(id, ',', inning, ',', over, ',', ball) AS ball_id, d.*
FROM deliveries_v03 d;

--Compare the total count of rows and total count of distinct ball_id in deliveries_v04;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT ball_id) AS distinct_ball_ids
FROM deliveries_v04;

--Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. (HINT : Syntax to add along with other columns,  row_number() over (partition by ball_id) as r_num)
CREATE TABLE deliveries_v05 AS
SELECT *, ROW_NUMBER() OVER (PARTITION BY ball_id) AS r_num
FROM deliveries_v04;

Select * from deliveries_v05;

--Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. (HINT : select * from deliveries_v05 WHERE r_num=2;)
SELECT *
FROM deliveries_v05
WHERE r_num > 1;

--Use subqueries to fetch data of all the ball_id which are repeating. (HINT: SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2);
SELECT *
FROM deliveries_v05
WHERE ball_id IN (SELECT ball_id FROM deliveries_v05 WHERE r_num > 1);


























