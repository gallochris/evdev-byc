# -----------------------------
# Load the utilities 
# adjusts conference names 
source(here::here("data/college-basketball/utils.R"))

# -----------------------------
# Fetch all 
# missing some conference mappings unfortunately right now 
# see long case statement 
sched_data <-
  cbbdata::cbd_torvik_team_schedule(year = 2025) |> 
  dplyr::mutate(opp = team_name_lookup(opp)) |>
  dplyr::mutate(team = team_name_lookup(team)) |> 
  dplyr::mutate(conf = dplyr::case_match(team, # fix team naming for leagues
    "Charleston" ~ "Horz",
    "LIU" ~ "NEC",
    "Detroit Mercy" ~ "Horz",
    "Purdue Fort Wayne" ~ "Horz",
    "Louisiana" ~ "SB",
    "N.C. State" ~ "ACC",
    "IU Indy" ~ "Horz",
    "Saint Francis" ~ "NEC",
    .default = conf)
  ) |> 
  dplyr::mutate(opp_conf = dplyr::case_match(opp,
    "Charleston" ~ "Horz",
    "LIU" ~ "NEC",
    "Detroit Mercy" ~ "Horz",
    "Purdue Fort Wayne" ~ "Horz",
    "Louisiana" ~ "SB",
    "N.C. State" ~ "ACC",
    "IU Indy" ~ "Horz",
    "Saint Francis" ~ "NEC",
    .default = opp_conf)
  ) |> 
  dplyr::mutate(opp_conf = conf_name_lookup(opp_conf)) |>
  dplyr::mutate(conf = conf_name_lookup(conf)) |> 
  cbbdata::cbd_add_net_quad() |> 
  dplyr::filter(date < today_date)
 
# Now add in torvik ratings
current_ratings <- cbbdata::cbd_torvik_ratings(year = 2025) |> 
  dplyr::mutate(team = dplyr::case_match(team,
                 "North Carolina St." ~ "N.C. State",
                 "College of Charleston" ~ "Charleston",
                 "LIU Brooklyn" ~ "LIU",
                 "Detroit" ~ "Detroit Mercy",
                 "Fort Wayne" ~ "Purdue Fort Wayne",
                 "Louisiana Lafayette" ~ "Louisiana",
                 "IUPUI" ~ "IU Indy",
                 "St. Francis PA" ~ "Saint Francis",
                 .default = team
                 )) |> 
  dplyr::mutate(conf = conf_name_lookup(conf)) |> 
  dplyr::select(team, conf, barthag, barthag_rk)


# Join the ratings with the teams 
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
  dplyr::left_join(
    game_results,
    by = c("game_id", "team")
  )



# -----------------------------
non_con_ratings <- games_with_ratings |> 
  dplyr::filter(type == "nc") |> 
  dplyr::mutate(score_sentence = paste0(result, ", ", pts_scored, "-", 
                                        pts_allowed),
                team_with_rk = paste0(team_rk, " ", team),
                opp_with_rk = paste0(opp_rk, " ", opp),
                tempo = round(tempo, 0),
                delta = pts_scored - pts_allowed
  ) |> 
  dplyr::select(game_id, date, team_with_rk, conf, opp_with_rk,
                opp_conf, location, result, delta, 
                score_sentence, tempo, team_rk, opp_rk, net, quad
                ) |> 
  dplyr::arrange(desc(date))

# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cbb/cbbdata.duckdb"))

table_name <- "non_con_games"

duckdb::dbWriteTable(con, table_name, non_con_ratings, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)

# -----------------------------
# Create summary table of conference against conference 


# Find the head to head conference records 
hth_recs <- non_con_ratings |> 
  dplyr::group_by(conf, opp_conf) |>
  dplyr::summarise(
    games = dplyr::n(),
    wins = sum(result == "W"),
    losses = sum(result == "L"),
    win_pct = wins / (wins + losses),
    avg_win_rtg = dplyr::if_else(wins == 0, 
                                 0, mean(opp_rk[result == "W"], 
                                         na.rm = TRUE)),
    avg_loss_rtg = dplyr::if_else(losses == 0, 
                                  0, mean(opp_rk[result == "L"], 
                                          na.rm = TRUE)),
    q1_wins = dplyr::coalesce(sum(result == "W" & quad == "Quadrant 1"), 0),
    q1_losses = dplyr::coalesce(sum(result == "L" & quad == "Quadrant 1"), 0),
    q2_wins = dplyr::coalesce(sum(result == "W" & quad == "Quadrant 2"), 0),
    q2_losses = dplyr::coalesce(sum(result == "L" & quad == "Quadrant 2"), 0),
    q3_wins = dplyr::coalesce(sum(result == "W" & quad == "Quadrant 3"), 0),
    q3_losses = dplyr::coalesce(sum(result == "L" & quad == "Quadrant 3"), 0),
    q4_wins = dplyr::coalesce(sum(result == "W" & quad == "Quadrant 4"), 0),
    q4_losses = dplyr::coalesce(sum(result == "L" & quad == "Quadrant 4"), 0)
  ) |> 
  dplyr::select(conf, opp_conf, games, wins, losses, win_pct, avg_win_rtg, 
                avg_loss_rtg, q1_wins, q1_losses, q2_wins, q2_losses, 
                q3_wins, q3_losses, q4_wins, q4_losses) 


# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cbb/cbbdata.duckdb"))

table_name <- "hth_recs"

duckdb::dbWriteTable(con, table_name, hth_recs, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)


# Group by conference and summarize 
quad_summary <- games_with_ratings |> 
  dplyr::filter(type != "nond1") |> 
  dplyr::group_by(conf) |> 
  dplyr::summarise(
    q1_games = dplyr::coalesce(sum(quad == "Quadrant 1"), 0),
    q1_wins = dplyr::coalesce(sum(result == "W" & quad == "Quadrant 1"), 0),
    q1_losses = dplyr::coalesce(sum(result == "L" & quad == "Quadrant 1"), 0),
    q1_win_pct = q1_wins / q1_games,
    q2_games = dplyr::coalesce(sum(quad == "Quadrant 2"), 0),
    q2_wins = dplyr::coalesce(sum(result == "W" & quad == "Quadrant 2"), 0),
    q2_losses = dplyr::coalesce(sum(result == "L" & quad == "Quadrant 2"), 0),
    q2_win_pct = q2_wins / q2_games,
    q3_games = dplyr::coalesce(sum(quad == "Quadrant 3"), 0),
    q3_wins = dplyr::coalesce(sum(result == "W" & quad == "Quadrant 3"), 0),
    q3_losses = dplyr::coalesce(sum(result == "L" & quad == "Quadrant 3"), 0),
    q3_win_pct = q3_wins / q3_games,
    q4_games = dplyr::coalesce(sum(quad == "Quadrant 4"), 0),
    q4_wins = dplyr::coalesce(sum(result == "W" & quad == "Quadrant 4"), 0),
    q4_losses = dplyr::coalesce(sum(result == "L" & quad == "Quadrant 4"), 0),
    q4_win_pct = q4_wins / q4_games
  ) |> 
  dplyr::select(conf, q1_games, q1_wins, q1_losses, q1_win_pct, q2_games, q2_wins, 
                q2_losses, q2_win_pct, q3_games, q3_wins, q3_losses, q3_win_pct, 
                q4_games, q4_wins, q4_losses, q4_win_pct) 


# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cbb/cbbdata.duckdb"))

table_name <- "quad_summary"

duckdb::dbWriteTable(con, table_name, quad_summary, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)
