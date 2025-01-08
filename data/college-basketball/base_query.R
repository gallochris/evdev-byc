# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))


# ----------------------------- Schedule data 
schedule <- cbbdata::cbd_torvik_team_schedule(year = 2025) |>
  dplyr::filter(type != "nond1") |> # filer out nond1 games
  dplyr::mutate(team = team_name_lookup(team)) |> # revert names to get quad
  dplyr::mutate(opp = team_name_lookup(opp)) |>  # data
  cbbdata::cbd_add_net_quad() |> # add quad data and net
  dplyr::mutate(team = team_name_update(team)) |> # now revert back
  dplyr::mutate(opp = team_name_update(opp)) # to match other data, wow

# ----------------------------- Dates
today_date <- format(Sys.Date(), "%Y-%m-%d")

yesterday_date <- format(Sys.Date() - lubridate::days(1), "%Y-%m-%d")

sched_data <- schedule |>
  dplyr::mutate(opp_conf = conf_name_lookup(opp_conf)) |>
  dplyr::mutate(conf = conf_name_lookup(conf))


# ----------------------------- Games results, name matching is a pain 
results <- cbbdata::cbd_torvik_game_stats(year = 2025) |>
  dplyr::mutate(opp = team_name_update(opp)) |>
  dplyr::mutate(team = team_name_update(team)) |>
  dplyr::mutate(conf = dplyr::coalesce(conf, conf_name_update(team))) |>
  dplyr::mutate(opp_conf = dplyr::coalesce(opp_conf, conf_name_update(opp))) |>
  dplyr::mutate(opp_conf = conf_name_lookup(opp_conf)) |>
  dplyr::mutate(conf = conf_name_lookup(conf)) |>
  dplyr::select(-location, -conf, -opp_conf) # get these from schedule

# ----------------------------- Ratings and current ratings
ratings <- cbbdata::cbd_torvik_ratings(year = 2025) 

current_ratings <- ratings |>
  dplyr::mutate(conf = conf_name_lookup(conf)) |>
  dplyr::select(team, conf, barthag, barthag_rk)

# Join the ratings with the game results
games_with_ratings <- sched_data |>
  dplyr::left_join(
    current_ratings |>
      dplyr::select(team, barthag, barthag_rk) |>
      dplyr::rename(team_barthag = barthag, team_rk = barthag_rk),
    by = "team"
  ) |>
  dplyr::left_join(
    current_ratings |>
      dplyr::select(team, barthag, barthag_rk) |>
      dplyr::rename(opp_barthag = barthag, opp_rk = barthag_rk),
    by = c("opp" = "team")
  ) |>
  dplyr::inner_join(results, by = c("game_id", "team", "opp", "type", "date", "year"))


# Write a csv of clean games to use for random scripts 
logs_for_csv <- games_with_ratings 

# Write the CSV
write.csv(logs_for_csv, "data/cbb_daily_gamelog.csv") 
