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

team_name_lookup <- function(team_var) {
  team_var = dplyr::case_match(
    team_var,
    "College of Charleston" ~ "Charleston",
    "LIU Brooklyn" ~ "LIU",
    "Detroit" ~ "Detroit Mercy",
    "Fort Wayne" ~ "Purdue Fort Wayne",
    "Louisiana Lafayette" ~ "Louisiana",
    "North Carolina St." ~ "N.C. State",
    "IUPUI" ~ "IU Indy",
    "St. Francis PA" ~ "Saint Francis",
    team_var ~ team_var
  )
}

# today's date
today_date <- format(Sys.Date(), "%Y-%m-%d")

# load schedule to get proper locations 
game_results <- cbbdata::cbd_torvik_game_stats(year = 2025) |> 
  dplyr::select(game_id, team, result, pts_scored, pts_allowed, tempo) |> 
  dplyr::filter(!is.na(result))

