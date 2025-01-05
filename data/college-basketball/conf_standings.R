# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))
source(here::here("data/college-basketball/base_query.R"))

# ----------------------------- Load in game ratings
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

# ----------------------------- Write to duckdb
write_to_duckdb(conf_margin, "conf_standings")

# ----------------------------- Create summary table
conf_summary <- games_with_ratings |>
  dplyr::filter(type == "conf") |>
  dplyr::group_by(conf) |>
  dplyr::summarise(
    teams = dplyr::n_distinct(team),
    total_games = dplyr::n(), 
    avg_point_diff = mean(abs(pts - opp_pts)),
    home_wins = sum(location == "H" & result == "W"),
    home_games = sum(location == "H"),
    home_win_pct = sum(location == "H" & result == "W") / sum(location == "H"),
    close_games_pct = sum(abs(pts - opp_pts) <= 5.5)/2 / (total_games/2), # Divide by 2 since 
    blowout_games_pct = sum(abs(pts - opp_pts) >= 15.5)/2 / (total_games/2) # each game appears twice
  ) |>
  dplyr::arrange(desc(home_win_pct)) |>
  dplyr::distinct(conf, .keep_all = TRUE)

# ----------------------------- Write to duckdb
write_to_duckdb(conf_summary, "conf_summary")
