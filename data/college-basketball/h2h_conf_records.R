# -----------------------------
# clean conference names - this should be a utility file probably 
conf_name_lookup <- function(conf_var) {
  conf_var = dplyr::case_match(
    conf_var,
    "B12" ~ "Big 12",
    "BE" ~ "Big East",
    "P12" ~ "Pac-12",
    "B10" ~ "Big Ten",
    "Amer" ~ "American",
    "SB" ~ "Sun Belt",
    "Slnd" ~ "Southland",
    "BW" ~ "Big West",
    "SC" ~ "Southern",
    "AE" ~ "America East",
    "BSth" ~ "Big South",
    "ASun" ~ "Atlantic Sun",
    "Pat" ~ "Patriot",
    "Horz" ~ "Horizon",
    "BSky" ~ "Big Sky",
    "OVC" ~ "Ohio Valley",
    "Sum" ~ "Summit",
    "A10" ~ "Atlantic 10",
    "MWC" ~ "Mountain West",
    "MVC" ~ "Missouri Valley",
    "NEC" ~ "Northeast",
    "MAC" ~ "Mid-American",
    "MAAC" ~ "Metro Atlantic",
    "ind" ~ "Independent",
    conf_var ~ conf_var
  )
}

# Fetch all non-conference games 
# missing some conference mappings unfortunately right now 
# see long case statement 
non_con_data <-
  cbbdata::cbd_torvik_game_stats(year = 2025, type = "nc") |> 
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
  dplyr::mutate(conf = conf_name_lookup(conf)) 
 
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
non_con_ratings <- non_con_data |>
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
  dplyr::mutate(score_sentence = paste0(result, ", ", pts_scored, "-", 
                                        pts_allowed),
                team_with_rk = paste0(team_rk, " ", team),
                opp_with_rk = paste0(opp_rk, " ", opp),
                tempo = round(tempo, 0)
  ) |> 
  dplyr::select(date, team_with_rk, conf, opp_with_rk,
                opp_conf, location, result, 
                score_sentence, tempo, team_rk, opp_rk 
                ) 
  
    
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
                                          na.rm = TRUE))
  ) |> 
  dplyr::mutate(overall_rec = paste0(wins, "-", losses)
) |> 
  dplyr::select(conf, opp_conf, games, overall_rec, win_pct, avg_win_rtg, 
                avg_loss_rtg) 


# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cbb/cbbdata.duckdb"))

table_name <- "hth_recs"

duckdb::dbWriteTable(con, table_name, hth_recs, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)
