# Load the utilities 
# loads fbs power conferences with championship game
# adjusts conference names 
source(here::here("data/college-football/utils.R"))

# ATS data requires lots of fetching from other sources 
# First grab the the location of games played
games_location <- cfbfastR::cfbd_game_info(
  year = 2024,
  season_type = "regular") |> 
  dplyr::filter(!is.na(home_points)) |> 
  dplyr::select(game_id, neutral_site)

# Next grab the point spreads and totals 
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
      # Home team is underdog
      point_spread > 0 & score_margin > -point_spread ~ "Yes",
      point_spread > 0 & score_margin < -point_spread ~ "No",
      point_spread > 0 & score_margin == -point_spread ~ "Push",
      
      # Home team is favorite
      point_spread < 0 & score_margin > abs(point_spread) ~ "Yes",
      point_spread < 0 & score_margin < abs(point_spread) ~ "No",
      point_spread < 0 & score_margin == abs(point_spread) ~ "Push",
      
      # Pick'em
      point_spread == 0 & score_margin > 0 ~ "Yes",
      point_spread == 0 & score_margin < 0 ~ "No",
      point_spread == 0 & score_margin == 0 ~ "Push",
      
      TRUE ~ NA_character_  # Handle any unexpected cases
    ),
    away_cover = dplyr::case_match(home_cover,
                  "Yes" ~ "No",
                  "No" ~ "Yes", 
                  "Push" ~ "Push"),
    result = dplyr::if_else(home_score > away_score, "W", "L"),
    week = dplyr::if_else(start_date < "2024-08-28", 0, week) 
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
  dplyr::left_join(games_location, by = "game_id") |> 
  dplyr::mutate(result = dplyr::if_else(home_score > away_score, "W", "L"),
                location = dplyr::if_else(neutral_site == TRUE, "Neutral", "Home")) |>
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
    formatted_spread,
    location
  )


# Away point spreads
away_ats <- ats_recs |>
  dplyr::left_join(games_location, by = "game_id") |> 
  dplyr::mutate(
    result = dplyr::if_else(away_score > home_score, "W", "L"),
    point_spread = dplyr::if_else(point_spread > 0, -point_spread, abs(point_spread)),
    location = dplyr::if_else(neutral_site == TRUE, "Neutral", "Away")) |> 
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
    formatted_spread,
    location
  )

full_ats <- home_ats |>
  dplyr::bind_rows(away_ats) |>
  dplyr::filter(game_id %in% fbs_only) |>
  dplyr::mutate(is_favorite = dplyr::if_else(point_spread < 0, TRUE, FALSE),
                is_underdog = dplyr::if_else(is_favorite == TRUE, FALSE, TRUE), 
                score_sentence = paste0(result, ", ", team_points, "-", opp_points),
                is_home_favorite = dplyr::if_else(
                  is_favorite == TRUE & location == "Home", 
                  TRUE,
                  FALSE),
                spread_category = dplyr::case_when(
                  abs(point_spread) < 3.5 ~ '3.5 or less',
                  abs(point_spread) > 9.5 ~ 'Double-digits',
                  .default = "All spreads"
                )) |> 
  as.data.frame()


# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))

table_name <- "spreads_and_totals"

duckdb::dbWriteTable(con, table_name, full_ats, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)




