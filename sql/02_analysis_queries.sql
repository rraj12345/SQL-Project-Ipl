-- IPL Match & Ball-by-Ball Analysis
-- Run after sql/01_setup_and_import.sql.

-- 1. Matches hosted by city.
SELECT city, COUNT(*) AS matches_hosted
FROM ipl_matches
WHERE city IS NOT NULL
GROUP BY city
ORDER BY matches_hosted DESC, city;

-- 2. Matches decided by more than 100 runs.
SELECT id, match_date, team1, team2, winner, result_margin
FROM ipl_matches
WHERE result = 'runs'
  AND NULLIF(result_margin, 'NA')::INTEGER > 100
ORDER BY match_date;

-- 3. Tied matches, newest first.
SELECT id, match_date, city, team1, team2, venue
FROM ipl_matches
WHERE LOWER(result) = 'tie'
ORDER BY match_date DESC;

-- 4. Team wins.
SELECT winner AS team, COUNT(*) AS wins
FROM ipl_matches
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY wins DESC, team;

-- 5. Batter boundaries (four or six runs off the bat) by team.
SELECT batting_team,
       COUNT(*) FILTER (WHERE batsman_runs = 4) AS fours,
       COUNT(*) FILTER (WHERE batsman_runs = 6) AS sixes,
       COUNT(*) FILTER (WHERE batsman_runs IN (4, 6)) AS total_boundaries
FROM deliveries
GROUP BY batting_team
ORDER BY total_boundaries DESC;

-- 6. Dot balls by bowling team.
SELECT bowling_team, COUNT(*) AS dot_balls
FROM deliveries
WHERE total_runs = 0
GROUP BY bowling_team
ORDER BY dot_balls DESC;

-- 7. Dismissal types.
SELECT dismissal_kind, COUNT(*) AS dismissals
FROM deliveries
WHERE dismissal_kind IS NOT NULL
  AND UPPER(dismissal_kind) <> 'NA'
GROUP BY dismissal_kind
ORDER BY dismissals DESC;

-- 8. Bowlers who conceded the most extra runs.
SELECT bowler, SUM(extra_runs) AS extra_runs_conceded
FROM deliveries
GROUP BY bowler
ORDER BY extra_runs_conceded DESC
LIMIT 10;

-- 9. Runs scored at each venue.
SELECT m.venue, SUM(d.total_runs) AS total_runs
FROM deliveries AS d
JOIN ipl_matches AS m
  ON m.id = d.match_id
GROUP BY m.venue
ORDER BY total_runs DESC;

-- 10. Year-wise runs at Eden Gardens.
SELECT EXTRACT(YEAR FROM m.match_date)::INTEGER AS match_year,
       SUM(d.total_runs) AS total_runs
FROM deliveries AS d
JOIN ipl_matches AS m
  ON m.id = d.match_id
WHERE m.venue = 'Eden Gardens'
GROUP BY match_year
ORDER BY match_year;

-- 11. Standardize a known team-name spelling variation for analysis.
SELECT DISTINCT
       CASE
           WHEN team1 = 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
           ELSE team1
       END AS standardized_team_name
FROM ipl_matches
ORDER BY standardized_team_name;

-- 12. Find repeated delivery keys using ROW_NUMBER().
WITH numbered_deliveries AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY match_id, inning, over_number, ball_number
               ORDER BY batsman, bowler, total_runs
           ) AS row_num
    FROM deliveries
)
SELECT *
FROM numbered_deliveries
WHERE row_num > 1
ORDER BY match_id, inning, over_number, ball_number;
