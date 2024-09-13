# Determine conference standings 
conf_games <- cfbfastR::cfbd_game_info(year = 2024) |>
  dplyr::filter(home_conference == away_conference) |>
  dplyr::filter(game_id != "401636864") |>  # Arizona at Kansas St is not a conference game
  #dplyr::filter(!is.na(home_points)) |>
  dplyr::mutate(conf = home_conference) |>
  dplyr::select(season,
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
  dplyr::filter(!conf %in% c("FBS Independents", "Pac-12")) |>  # no conf champ game 
    dplyr::mutate(conf = dplyr::case_match(conf,
                                           "American Athletic" ~ "American",
                                           "Conference USA" ~ "CUSA",
                                           "Mid-American" ~ "MAC",
                                           conf ~ conf  )) # adjust conference names

# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))


# Write standings to a table 
table_name <- "conference_standings"

duckdb::dbWriteTable(con, table_name, conference_standings, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)

# test
# duckdb::dbListTables(con)


