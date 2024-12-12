# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))
source(here::here("data/college-basketball/base_query.R"))

# load in games with ratings
# this needs to be cleaned up
conf_data <- games_with_ratings

# Determine the margin for conference only games
conf_margin <- games_with_ratings |>
  dplyr::filter(type == "conf") |>
  dplyr::group_by(team, conf) |>
  dplyr::summarise(
    wins = sum(result == "W"),
    loss = sum(result == "L"),
    delta = sum(pts - opp_pts),
    home_wins = sum(result == "W" & location == "H"),
    home_loss = sum(result == "L" & location == "H"),
    home_delta = sum((pts - opp_pts) * (location == "H")),
    away_wins = sum(result == "W" & location == "A"),
    away_loss = sum(result == "L" & location == "A"),
    away_delta = sum((pts - opp_pts) * (location == "A"))
  ) |>
  dplyr::arrange(-wins, -delta)

# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cbb/cbbdata.duckdb"))

table_name <- "conf_standings"

duckdb::dbWriteTable(con, table_name, conf_margin, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)

# Create summary table,
conf_summary <- conf_margin |>
  dplyr::group_by(conf) |>
  dplyr::summarise(
    teams = dplyr::n_distinct(team),
    total_games = sum(wins + loss),
    avg_point_diff = mean(abs(delta)),
    home_wins = sum(home_wins),
    home_win_pct = home_wins / (total_games / 2),
    close_games_pct = sum(abs(delta) <= 5.5) / total_games,
    blowout_games_pct = sum(abs(delta) >= 14.5) / total_games
  ) |>
  dplyr::arrange(desc(home_win_pct)) |>
  dplyr::distinct(conf, .keep_all = TRUE)

# Save table
con <- dbConnect(duckdb::duckdb(dbdir = "sources/cbb/cbbdata.duckdb"))

table_name <- "conf_summary"

duckdb::dbWriteTable(con, table_name, conf_summary, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)