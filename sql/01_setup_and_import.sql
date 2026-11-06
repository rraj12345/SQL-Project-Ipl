-- IPL project: table creation and CSV import
-- Run from the repository root:
-- psql -d your_database_name -f sql/01_setup_and_import.sql
--
-- The match table has one row per match. The deliveries table has many rows
-- per match, so match_id is intentionally not a primary key in deliveries.

SET datestyle TO 'ISO, DMY';

CREATE TABLE IF NOT EXISTS ipl_matches (
    id              BIGINT PRIMARY KEY,
    city            TEXT,
    match_date      DATE,
    player_of_match TEXT,
    venue           TEXT,
    neutral_venue   BOOLEAN,
    team1           TEXT,
    team2           TEXT,
    toss_winner     TEXT,
    toss_decision   TEXT,
    winner          TEXT,
    result          TEXT,
    result_margin   TEXT,
    eliminator      BOOLEAN,
    method          TEXT,
    umpire1         TEXT,
    umpire2         TEXT
);

CREATE TABLE IF NOT EXISTS deliveries (
    match_id       BIGINT,
    inning         SMALLINT,
    over_number    SMALLINT,
    ball_number    SMALLINT,
    batsman        TEXT,
    non_striker    TEXT,
    bowler         TEXT,
    batsman_runs   INTEGER,
    extra_runs     INTEGER,
    total_runs     INTEGER,
    is_wicket      BOOLEAN,
    dismissal_kind TEXT,
    player_dismissed TEXT,
    fielder        TEXT,
    extras_type    TEXT,
    batting_team   TEXT,
    bowling_team   TEXT
);

-- These are psql client-side import commands. Run from the repository root.
\copy ipl_matches FROM 'IPL_matches.csv' WITH (FORMAT csv, HEADER true, NULL 'NA');
\copy deliveries FROM 'IPL_Ball.csv' WITH (FORMAT csv, HEADER true, NULL 'NA');
