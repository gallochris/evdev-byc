# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))


# The idea here is load these base queries


# schedule
schedule <- cbbdata::cbd_torvik_team_schedule(year = 2025) |>
  dplyr::filter(type != "nond1") # filer out nond1 games

# game results
# name matching is sketchy, so need to fill in some team names
results <- cbbdata::cbd_torvik_game_stats(year = 2025) |>
  dplyr::mutate(opp = team_name_update(opp)) |>
  dplyr::mutate(team = team_name_update(team)) |>
  dplyr::mutate(conf = dplyr::coalesce(conf, conf_name_update(team))) |>
  dplyr::mutate(opp_conf = dplyr::coalesce(opp_conf, conf_name_update(opp))) |>
  dplyr::mutate(opp_conf = conf_name_lookup(opp_conf)) |>
  dplyr::mutate(conf = conf_name_lookup(conf)) |>
  dplyr::select(-location, -conf, -opp_conf) # get these from schedule

# ratings
ratings <- cbbdata::cbd_torvik_ratings(year = 2025) 