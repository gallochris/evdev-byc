# Load the utilities 
# loads fbs power conferences with championship game
# adjusts conference names 
source(here::here("data/college-football/utils.R"))

# Determine conference standings 
conf_games <- cfbfastR::cfbd_game_info(year = 2024) |>
  dplyr::filter(home_conference == away_conference) |>
  dplyr::filter(!game_id %in% c("401636618", "401636864")) |>  
  # Arizona at Kansas St is not a conference game
  # Baylor and Utah also not a conference game *shakes fist at Big 12*
  # dplyr::filter(!is.na(home_points)) |>
  dplyr::mutate(conf = home_conference) |>
  dplyr::select(game_id, 
                season,
                week,
                conf,
                home_team,
                home_points,
                away_team,
                away_points)

# Home results
home_results <- conf_games |>
  dplyr::mutate(h_result = dplyr::if_else(home_points > away_points, "W", "L")) |>
  dplyr::group_by(home_team, h_result, conf) |>
  dplyr::count() |>
  tidyr::pivot_wider(names_from = h_result, values_from = n) |>
  dplyr::rename(team = home_team, h_w = W, h_l = L) |>
  dplyr::mutate_at(dplyr::vars(h_w, h_l), ( ~ replace(., is.na(.), 0)))

# Away results
away_results <- conf_games |>
  dplyr::mutate(a_result = dplyr::if_else(away_points > home_points, "W", "L")) |>
  dplyr::group_by(away_team, a_result, conf) |>
  dplyr::count() |>
  tidyr::pivot_wider(names_from = a_result, values_from = n) |>
  dplyr::rename(team = away_team, a_w = W, a_l = L) |>
  dplyr::mutate_at(dplyr::vars(a_w, a_l), ( ~ replace(., is.na(.), 0))) |>
  dplyr::ungroup()

# Full recsults
full_recs <- merge(home_results, away_results, by = c("team", "conf")) |>
  dplyr::mutate_all(list( ~ ifelse(is.na(.), 0, .))) |>
  dplyr::mutate(W = (h_w + a_w), L = (h_l + a_l)) |>
  dplyr::select(team, conf, W, L, h_w, h_l, a_w, a_l)

# Home differentials
home_diffs <- conf_games |>
  dplyr::mutate_at(dplyr::vars(home_points, away_points), ( ~ replace(., is.na(.), 0))) |>
  dplyr::mutate(h_diff = home_points - away_points) |>
  dplyr::group_by(home_team, conf) |>
  dplyr::summarize(home_diff = sum(h_diff)) |>
  dplyr::rename(team = home_team)

# Away differentials 
away_diffs <- conf_games |>
  dplyr::mutate_at(dplyr::vars(home_points, away_points), ( ~ replace(., is.na(.), 0))) |>
  dplyr::mutate(a_diff = away_points - home_points) |>
  dplyr::group_by(away_team, conf) |>
  dplyr::summarize(away_diff = sum(a_diff)) |>
  dplyr::rename(team = away_team)

# Full differentials
full_diffs <- merge(home_diffs, away_diffs, by = c("team", "conf")) |>
  dplyr::mutate(full_diff = (home_diff + away_diff)) |>
  dplyr::select(team, conf, full_diff, home_diff, away_diff)

# Overall records
overall_records <- cfbfastR::cfbd_game_records(year = 2024) |>
  dplyr::select(team, division, conf = conference, total_wins, total_losses)

# Conference standings
conference_standings <- merge(full_diffs, full_recs, by = c("team", "conf")) |>
  dplyr::full_join(overall_records, by = c("team", "conf")) |> 
  dplyr::select(
    team,
    conf,
    division,
    conf_win = W,
    conf_loss = L,
    full_diff,
    h_w,
    h_l,
    home_diff,
    a_w,
    a_l,
    away_diff
  ) |> 
  dplyr::mutate_at(dplyr::vars(conf_win, 
                               conf_loss, full_diff,
                               h_w, 
                               h_l, 
                               home_diff, 
                               a_w, 
                               a_l,
                               away_diff), ( ~ replace(., is.na(.), 0))) |> 
  dplyr::filter(conf %in% fbs_leagues) |>  # only leagues with conf champ game 
  dplyr::mutate(conf =conf_name_lookup(conf)) # adjust conference names

# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))


# Write standings to a table 
table_name <- "conference_standings"

duckdb::dbWriteTable(con, table_name, conference_standings, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)

# Create summary table, but home win percentage needs to take out
# neutral site games 

home_win_pct <- conf_games |>
  dplyr::filter(!is.na(home_points)) |>
  dplyr::filter(!game_id %in% c(
    "401635525", # fsu gt in ireland
    "401628373" # arkansas tamu jerry world
  )) |> 
  dplyr::group_by(conf) |>
  dplyr::reframe(
    games = dplyr::n(),
    home_win_pct = sum(home_points > away_points) / dplyr::n(),
  ) |>
  dplyr::distinct(conf, .keep_all = TRUE) |> 
  dplyr::select(-games)
  
  
conf_sum_data <- conf_games |>
  dplyr::filter(!is.na(home_points)) |>
  dplyr::group_by(conf) |>
  dplyr::reframe(
    games = dplyr::n(),
    avg_diff = sum(abs(home_points - away_points)) / dplyr::n(),
    close_pct = sum(abs(home_points - away_points) <= 7.5) / dplyr::n(),
    blowout_pct = sum(abs(home_points - away_points) >= 17.5) / dplyr::n()
  ) |>
  dplyr::distinct(conf, .keep_all = TRUE) |> 
  dplyr::left_join(home_win_pct, by = c("conf")) |> 
  dplyr::mutate(conf =conf_name_lookup(conf)) 

# Save table  
con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))

table_name <- "conf_sum_tbl"

duckdb::dbWriteTable(con, table_name, conf_sum_data, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)

