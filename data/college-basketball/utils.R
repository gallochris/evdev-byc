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

# ------------------------------ NCAA team match for the NET 
ncaa_team_name_match <- function(team_var) {
  team_var = dplyr::case_match(
      team_var,
      "Queens (NC)" ~ "Queens",
      "Purdue Fort Wayne" ~ "Fort Wayne",
      "Lamar University" ~ "Lamar",
      "LIU" ~ "LIU Brooklyn",
      "Gardner-Webb" ~ "Gardner Webb",
      "Seattle U" ~ "Seattle",
      "Ark.-Pine Bluff" ~ "Arkansas Pine Bluff",
      "IU Indy" ~ "IUPUI",
      "Kansas City" ~ "UMKC",
      "UIW" ~ "Incarnate Word",
      "A&M-Corpus Christi" ~ "Texas A&M Corpus Chris",
      "FGCU" ~ "Florida Gulf Coast",
      "North Ala." ~ "North Alabama",
      "UAlbany" ~ "Albany",
      "Alcorn" ~ "Alcorn St.",
      "App State" ~ "Appalachian St.",
      "Charleston So." ~ "Charleston Southern",
      "Bethune-Cookman" ~ "Bethune Cookman",
      "Boston U." ~ "Boston University",
      "CSU Bakersfield" ~ "Cal St. Bakersfield",
      "CSUN" ~ "Cal St. Northridge",
      "Loyola Maryland" ~ "Loyola MD",
      "LMU (CA)" ~ "Loyola Marymount",
      "UMES" ~ "Maryland Eastern Shore",
      "Miami (OH)" ~ "Miami OH",
      "Miami (FL)" ~ "Miami FL",
      "Middle Tenn." ~ "Middle Tennessee",
      "Mississippi Val." ~ "Mississippi Valley St.",
      "Ole Miss" ~ "Mississippi",
      "UNCW" ~ "UNC Wilmington",
      "Omaha" ~ "Nebraska Omaha",
      "Central Conn. St." ~ "Central Connecticut",
      "Central Mich." ~ "Central Michigan",
      "Detroit Mercy" ~ "Detroit",
      "ETSU" ~ "East Tennessee St.",
      "Eastern Ill." ~ "Eastern Illinois",
      "Eastern Ky." ~ "Eastern Kentucky",
      "Eastern Mich." ~ "Eastern Michigan",
      "Eastern Wash." ~ "Eastern Washington",
      "FDU" ~ "Fairleigh Dickinson",
      "Fla. Atlantic" ~ "Florida Atlantic",
      "Ga. Southern" ~ "Georgia Southern",
      "UIC" ~ "Illinois Chicago",
      "Nicholls" ~ "Nicholls St.",
      "N.C. A&T" ~ "North Carolina A&T",
      "N.C. Central" ~ "North Carolina Central",
      "ULM" ~ "Louisiana Monroe",
      "Northern Ariz." ~ "Northern Arizona",
      "Northern Colo." ~ "Northern Colorado",
      "NIU" ~ "Northern Illinois",
      "UNI" ~ "Northern Iowa",
      "Northern Ky." ~ "Northern Kentucky",
      "UTRGV" ~ "UT Rio Grande Valley",
      "Prairie View" ~ "Prairie View A&M",
      "Saint Francis" ~ "St. Francis PA",
      "St. John's (NY)" ~ "St. John's",
      "Sam Houston" ~ "Sam Houston St.",
      "California Baptist" ~ "Cal Baptist",
      "St. Thomas (MN)" ~ "St. Thomas",
      "South Fla." ~ "South Florida",
      "Southeast Mo. St." ~ "Southeast Missouri St.",
      "Southeastern La." ~ "Southeastern Louisiana",
      "Southern California" ~ "USC",
      "Southern Ill." ~ "Southern Illinois",
      "SIUE" ~ "SIU Edwardsville",
      "Southern Miss." ~ "Southern Miss",
      "Southern U." ~ "Southern",
      "Louisiana" ~ "Louisiana Lafayette",
      "SFA" ~ "Stephen F. Austin",
      "UT Martin" ~ "Tennessee Martin",
      "Army West Point" ~ "Army",
      "Western Caro." ~ "Western Carolina",
      "Western Ill." ~ "Western Illinois",
      "Western Mich." ~ "Western Michigan",
      "Central Ark." ~ "Central Arkansas",
      "East Texas A&M" ~ "Texas A&M Commerce",
      "Southern Ind." ~ "Southern Indiana",
      "Col. of Charleston" ~ "College of Charleston",
      "McNeese" ~ "McNeese St.",
      "UConn" ~ "Connecticut",
      "Grambling" ~ "Grambling St.",
      "NC State" ~ "North Carolina St.",
      "Saint Mary's (CA)" ~ "Saint Mary's",
      "Western Ky." ~ "Western Kentucky",
      "West Ga." ~ "West Georgia",
      team_var ~ team_var
    )
}

# ----------------------------- NCAA conference match 
ncaa_conf_name_match <- function(conf_var) {
      conf_var = dplyr::case_match(
      conf_var,
      "NEC" ~ "Northeast",
      "ASUN" ~ "Atlantic Sun",
      "OVC" ~ "Ohio Valley",
      "MVC" ~ "Missouri Valley",
      "MAAC" ~ "Metro Atlantic",
      "MAC" ~ "Mid-American",
      "Atlantic 10" ~ "Atlantic 10",
      "Patriot" ~ "Patriot",
      "America East" ~ "America East",
      "CAA" ~ "CAA",
      "Big South" ~ "Big South",
      "WAC" ~ "WAC",
      "Summit League" ~ "Summit",
      "SoCon" ~ "Southern",
      "Ivy League" ~ "Ivy",
      "The American" ~ "American",
      conf_var ~ conf_var
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

