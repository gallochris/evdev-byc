# # ----------------------------- Clean conference names
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


# ----------------------------- Update team names
team_name_update <- function(team_var) {
  team_var = dplyr::case_match(
    team_var,
    "Charleston" ~ "College of Charleston",
    "LIU" ~ "LIU Brooklyn",
    "Detroit Mercy" ~ "Detroit",
    "Purdue Fort Wayne" ~ "Fort Wayne",
    "Louisiana" ~ "Louisiana Lafayette",
    "N.C. State" ~ "North Carolina St.",
    "IU Indy" ~ "IUPUI",
    "Saint Francis" ~ "St. Francis PA",
    team_var ~ team_var
  )
}

# ----------------------------- Match conferences to those team names
conf_name_update <- function(team_var) {
  dplyr::case_match(
    team_var,
    "College of Charleston" ~ "Horz",
    "LIU Brooklyn" ~ "NEC",
    "Detroit" ~ "Horz",
    "Fort Wayne" ~ "Horz",
    "Louisiana Lafayette" ~ "SB",
    "North Carolina St." ~ "ACC",
    "IUPUI" ~ "Horz",
    "St. Francis PA" ~ "NEC",
    .default = team_var
  )
}

# ----------------------------- Reverse team name lookup
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

# ----------------------------- Clean quadrant names
quad_clean <- function(quad_var) {
    quad_var = dplyr::case_match(
      quad_var,
      "Quadrant 1" ~ "Q1",
      "Quadrant 2" ~ "Q2",
      "Quadrant 3" ~ "Q3",
      "Quadrant 4" ~ "Q4",
      quad_var ~ quad_var
    )
  }

# ----------------------------- Write to duckdb 
write_to_duckdb <- function(data, table_name, 
                            db_path = file.path(here::here(), "sources", 
                                                "cbb", "cbbdata.duckdb")) 
{
  # Ensure the directory exists
  dir.create(dirname(db_path), recursive = TRUE, showWarnings = FALSE)
  
  # Use tryCatch for more robust error handling
  con <- DBI::dbConnect(duckdb::duckdb(dbdir = db_path))
  tryCatch({
    duckdb::dbWriteTable(con, table_name, data, overwrite = TRUE)
  }, finally = {
    DBI::dbDisconnect(con, shutdown = TRUE)
  })
}

