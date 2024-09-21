conf_name_lookup <- function(conf_var) {
  conf_var = dplyr::case_match(
    conf_var,
    "American Athletic" ~ "American",
    "Pac-12" ~ "Pac-2",
    "Conference USA" ~ "CUSA",
    "FBS Independents" ~ "Independents",
    "Mid-American" ~ "MAC",
    conf_var ~ conf_var
  )
}

fbs_leagues <- c("SEC", "ACC", "Big 12", 
                 "Big Ten", "American Athletic",
                 "Conference USA", "Mid-American",
                 "Sun Belt", "Mountain West")


fbs_only <-  cfbfastR::cfbd_game_info(year = 2024) |>
  dplyr::filter(!is.na(home_points)) |>
  dplyr::filter(home_division == "fbs" &
                  away_division == "fbs") |>
  dplyr::pull(game_id)