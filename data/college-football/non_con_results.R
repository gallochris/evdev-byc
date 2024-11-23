# Load the utilities 
# adjusts conference names 
source(here::here("data/college-football/utils.R"))

# Conference H2H records for FBS only 

# Home results
home_non_con_games <- cfbfastR::cfbd_game_info(year = 2024) |>
  dplyr::filter(!is.na(home_points)) |>
  dplyr::filter(home_division == "fbs" & away_division == "fbs") |>
  dplyr::mutate(result = dplyr::if_else(home_points > away_points, "W", "L")) |>
  dplyr::rename(
    team = home_team,
    opp = away_team,
    conf = home_conference,
    opp_conf = away_conference,
    team_points = home_points,
    opp_points = away_points
  ) |>
  dplyr::select(game_id, week, team, opp, conf, opp_conf, result)

# Away results
away_non_con_games <- cfbfastR::cfbd_game_info(year = 2024) |>
  dplyr::filter(!is.na(home_points)) |>
  dplyr::filter(home_division == "fbs" & away_division == "fbs") |>
  dplyr::mutate(result = dplyr::if_else(away_points > home_points, "W", "L")) |>
  dplyr::rename(
    team = away_team,
    opp = home_team,
    conf = away_conference,
    opp_conf = home_conference
  ) |>
  dplyr::select(game_id, week, team, opp, conf, opp_conf, result)

# Summary
non_con_game_summary <- home_non_con_games |>
  dplyr::bind_rows(away_non_con_games) |>
  dplyr::filter(conf != opp_conf) |>
  dplyr::group_by(conf, opp_conf) |>
  dplyr::summarise(
    games = dplyr::n(),
    wins = sum(result == "W"),
    losses = sum(result == "L")
  ) |>
  dplyr::mutate(result = paste0(wins, "-", losses)) |> 
  dplyr::mutate(conf = conf_name_lookup(conf)) |> 
  dplyr::mutate(opp_conf = conf_name_lookup(opp_conf))

# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))

table_name <- "non_con_results"

duckdb::dbWriteTable(con, table_name, non_con_game_summary, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)
