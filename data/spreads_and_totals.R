# ATS
# when point spread is less than 0 - it means the home team is favored
# when score margin is greater than 0, it means the home team won
# anything else is a push

ats_recs <- cfbfastR::cfbd_betting_lines(year = 2024) |>
  dplyr::filter(provider == "Bovada") |>
  dplyr::filter(!is.na(home_score)) |>
  dplyr::mutate(
    point_spread = as.numeric(spread),
    home_score = as.numeric(home_score),
    away_score = as.numeric(away_score),
    total = as.numeric(over_under),
    score_margin = home_score - away_score,
    combined_score = (home_score + away_score),
    over_or_under = dplyr::if_else(combined_score > total, "over", "under"),
    home_cover = dplyr::case_when(
      point_spread < 0 ~ score_margin >= abs(point_spread),
      # home team favored
      point_spread > 0 ~ score_margin > point_spread,
      # away team favored
      point_spread == 0 ~ score_margin > 0,
      # pick'em
      TRUE ~ NA
    ),
    away_cover = dplyr::if_else(home_cover == TRUE, FALSE, TRUE),
    result = dplyr::if_else(home_score > away_score, "W", "L"),
  ) |>
  dplyr::select(
    game_id,
    week,
    home_team,
    result,
    away_team,
    home_score,
    away_score,
    point_spread,
    score_margin,
    home_cover,
    away_cover,
    total,
    over_or_under,
    combined_score,
    formatted_spread,
    home_conference,
    away_conference,
    provider
  )


# Home point spreads
home_ats <- ats_recs |>
  dplyr::mutate(result = dplyr::if_else(home_score > away_score, "W", "L")) |>
  dplyr::rename(
    team = home_team,
    opp = away_team,
    conf = home_conference,
    opp_conf = away_conference,
    team_points = home_score,
    opp_points = away_score,
    team_cover = home_cover,
    opp_cover = away_cover
  ) |>
  dplyr::select(
    game_id,
    week,
    team,
    opp,
    conf,
    opp_conf,
    result,
    point_spread,
    score_margin,
    team_points,
    opp_points,
    team_cover,
    opp_cover,
    total,
    over_or_under,
    combined_score,
    formatted_spread
  )


# Away point spreads
away_ats <- ats_recs |>
  dplyr::mutate(
    result = dplyr::if_else(away_score > home_score, "W", "L"),
    point_spread = dplyr::if_else(point_spread < 0, abs(point_spread), point_spread)
  ) |>
  dplyr::rename(
    team = away_team,
    opp = home_team,
    conf = away_conference,
    opp_conf = home_conference,
    team_points = away_score,
    opp_points = home_score,
    team_cover = away_cover,
    opp_cover = home_cover
  ) |>
  dplyr::select(
    game_id,
    week,
    team,
    opp,
    conf,
    opp_conf,
    result,
    point_spread,
    score_margin,
    team_points,
    opp_points,
    team_cover,
    opp_cover,
    total,
    over_or_under,
    combined_score,
    formatted_spread
  )

# Filter by FBS vs FBS
fbs_only <-  cfbfastR::cfbd_game_info(year = 2024) |>
  dplyr::filter(!is.na(home_points)) |>
  dplyr::filter(home_division == "fbs" &
                  away_division == "fbs") |>
  dplyr::pull(game_id)

full_ats <- home_ats |>
  dplyr::bind_rows(away_ats) |>
  dplyr::filter(game_id %in% fbs_only) |>
  dplyr::mutate(is_favorite = dplyr::if_else(point_spread < 0, TRUE, FALSE),
                score_sentence = paste0(result, ", ", team_points, "-", opp_points)) |> 
  as.data.frame()


# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))

table_name <- "spreads_and_totals"

duckdb::dbWriteTable(con, table_name, full_ats, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)




### Summary notes 
full_ats |>
  dplyr::filter(is_favorite == FALSE) |>
  dplyr::summarise(
    total_covers = sum(team_cover),
    total_games = dplyr::n(),
    cover_percentage = mean(team_cover) * 100
  )


full_ats |>
  dplyr::filter(is_favorite == TRUE) |>
  dplyr::summarise(
    total_covers = sum(team_cover),
    total_games = dplyr::n(),
    cover_percentage = mean(team_cover) * 100
  )

### summary
home_summary <- ats_recs |>
  dplyr::group_by(home_team) |>
  dplyr::summarise(
    home_games = dplyr::n(),
    home_covers = sum(home_cover == TRUE, na.rm = TRUE),
    .groups = "drop"
  )

# Summarize away team performance
away_summary <- ats_recs |>
  dplyr::group_by(away_team) |>
  dplyr::summarise(
    away_games = dplyr::n(),
    away_covers = sum(away_cover == TRUE, na.rm = TRUE),
    .groups = "drop"
  )

# Combine home and away summaries
team_summary <- home_summary |>
  dplyr::full_join(away_summary, by = c("home_team" = "away_team")) |>
  dplyr::mutate(
    team = home_team,
    total_games = home_games + away_games,
    total_covers = home_covers + away_covers,
    cover_percentage = total_covers / total_games
  ) |>
  dplyr::select(
    team,
    home_games,
    away_games,
    total_games,
    home_covers,
    away_covers,
    total_covers,
    cover_percentage
  ) |>
  dplyr::arrange(dplyr::desc(cover_percentage))
