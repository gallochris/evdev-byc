# Load the utilities 
# adjusts conference names 
source(here::here("data/college-football/utils.R"))

# Load team ratings to grab fei resume 

# Load teams from cfbfastR for matching 
teams <- cfbfastR::cfbd_team_info(year = 2024) |> 
  dplyr::select(school, mascot) |> 
  dplyr::mutate(team = paste0(school, " ", mascot))

# Sore ratings
sor_url <- "https://www.espn.com/college-football/fpi/_/view/resume"

webpage <- rvest::read_html(sor_url)

sor_tables <- webpage |>
  rvest::html_nodes("table") |>
  lapply(rvest::html_table)

sor <- sor_tables[[1]] |>
  dplyr::bind_cols(sor_tables[[2]]) |> 
  janitor::row_to_names(row_number = 1) |>
  janitor::clean_names() |> 
  dplyr::left_join(teams, by = "team") |> 
  dplyr::rename(team_name = school) |> 
  dplyr::mutate(sor = as.numeric(sor),
                fpi_rk = as.numeric(fpi)) |>
  dplyr::mutate(
    team_name = dplyr::case_match(
      team_name,
      "Kansas St" ~ "Kansas State",
      "Oklahoma St" ~ "Oklahoma State",
      "Florida St" ~ "Florida State",
      "Washington St" ~ "Washington State",
      "Boise St" ~ "Boise State",
      "Arizona St" ~ "Arizona State",
      "Mississippi St" ~ "Mississippi State",
      "Fresno St" ~ "Fresno State",
      "Michigan St" ~ "Michigan State",
      "Texas St" ~ "Texas State",
      "San José St" ~ "San Jose State",
      "App State" ~ "Appalachian State",
      "San Diego St" ~ "San Diego State",
      "Arkansas St" ~ "Arkansas State",
      "New Mexico St" ~ "New Mexico State",
      "Georgia St" ~ "Georgia State",
      "Sam Houston" ~ "Sam Houston State",
      "Colorado St" ~ "Colorado State",
      "Jax State" ~ "Jacksonville State",
      "Kennesaw St" ~ "Kennesaw State",
      "E Michigan" ~ "Eastern Michigan",
      "C Michigan" ~ "Central Michigan",
      "W Michigan" ~ "Western Michigan",
      "Oregon St" ~ "Oregon State",
      "FIU" ~ "Florida International",
      "Southern Miss" ~ "Southern Mississippi",
      "MTSU" ~ "Middle Tennessee",
      "UL Monroe" ~ "Louisiana Monroe",
      "GA Southern" ~ "Georgia Southern",
      "Hawai'i" ~ "Hawaii",
      "FAU" ~ "Florida Atlantic",
      "Massachusetts" ~ "UMass",
      "N Illinois" ~ "Northern Illinois",
      "Western KY" ~ "Western Kentucky",
      "Miami OH" ~ "Miami (OH)",
      "Pitt" ~ "Pittsburgh",
      "Coastal Car" ~ "Coastal Carolina",
      team_name ~ team_name
    )
  ) |> 
  dplyr::select(team_name, conf, sor, fpi_rk)

fpi <- cfbfastR::espn_ratings_fpi(year = 2024) |>
  dplyr::select(team_name, fpi) |>
  dplyr::mutate(fpi = as.numeric(fpi)) |>
  dplyr::arrange(dplyr::desc(fpi)) |>
  dplyr::mutate(
    fpi_rk = dplyr::row_number(),
    fpi_ptile = dplyr::percent_rank(fpi)
  ) |> 
  dplyr::mutate(
    team_name = dplyr::case_match(
      team_name,
      "Kansas St" ~ "Kansas State",
      "Oklahoma St" ~ "Oklahoma State",
      "Florida St" ~ "Florida State",
      "Washington St" ~ "Washington State",
      "Boise St" ~ "Boise State",
      "Arizona St" ~ "Arizona State",
      "Mississippi St" ~ "Mississippi State",
      "Fresno St" ~ "Fresno State",
      "Michigan St" ~ "Michigan State",
      "Texas St" ~ "Texas State",
      "San José St" ~ "San Jose State",
      "App State" ~ "Appalachian State",
      "San Diego St" ~ "San Diego State",
      "Arkansas St" ~ "Arkansas State",
      "New Mexico St" ~ "New Mexico State",
      "Georgia St" ~ "Georgia State",
      "Sam Houston" ~ "Sam Houston State",
      "Colorado St" ~ "Colorado State",
      "Jax State" ~ "Jacksonville State",
      "Kennesaw St" ~ "Kennesaw State",
      "E Michigan" ~ "Eastern Michigan",
      "C Michigan" ~ "Central Michigan",
      "W Michigan" ~ "Western Michigan",
      "Oregon St" ~ "Oregon State",
      "FIU" ~ "Florida International",
      "Southern Miss" ~ "Southern Mississippi",
      "MTSU" ~ "Middle Tennessee",
      "UL Monroe" ~ "Louisiana Monroe",
      "GA Southern" ~ "Georgia Southern",
      "Hawai'i" ~ "Hawaii",
      "FAU" ~ "Florida Atlantic",
      "Massachusetts" ~ "UMass",
      "N Illinois" ~ "Northern Illinois",
      "Western KY" ~ "Western Kentucky",
      "Miami OH" ~ "Miami (OH)",
      "Pitt" ~ "Pittsburgh",
      "Coastal Car" ~ "Coastal Carolina",
      team_name ~ team_name
    )
  )

sor_full <- sor |> 
  dplyr::left_join(fpi, by = c("team_name", "fpi_rk")) |> 
  dplyr::mutate_at(dplyr::vars(-team_name, -conf), as.numeric) |>
  dplyr::mutate(
    team_name = dplyr::case_match(
      team_name,
      "Connecticut" ~ "UConn",
      "UL Monroe" ~ "Louisiana Monroe",
      "Sam Houston" ~ "Sam Houston State",
      "Massachusetts" ~ "UMass",
      team_name ~ team_name
    ),
    sor_ptile = dplyr::percent_rank(-sor)
  )

# CFP + FEI Resume Ratings
fei_url <- "https://www.bcftoys.com/2024-cfp/"

webpage <- rvest::read_html(fei_url)

# organize table
fei <- webpage |>
  rvest::html_node("table") |>
  rvest::html_table() |>
  dplyr::slice(-1) |>
  dplyr::select(
    record = X3,
    cfp_rank = X1,
    team_name = X2,
    fei_resume_rank = X11,
    fei_resume = X10
  ) |>
  dplyr::slice(-1) |>
  dplyr::filter(fei_resume_rank != "Rk") |>
  na.omit() |>
  dplyr::mutate_at(dplyr::vars(-team_name, -record), as.numeric) |>
  dplyr::mutate(fei_resume_ptile = dplyr::percent_rank(fei_resume)) |> 
  dplyr::mutate(
    team_name = dplyr::case_match(
      team_name,
      "Connecticut" ~ "UConn",
      "UL Monroe" ~ "Louisiana Monroe",
      "Sam Houston" ~ "Sam Houston State",
      "Massachusetts" ~ "UMass",
      team_name ~ team_name
    )
  ) |> 
  dplyr::mutate(fei_resume_ptile = dplyr::percent_rank(fei_resume))

# combine tables 
cfb_resume <- sor_full |> 
  dplyr::left_join(fei, by ="team_name") |> 
  dplyr::mutate(conf = conf_name_lookup(conf)) |>  
  dplyr::mutate(team_name = paste0(team_name, " (", record, ")")) |>
  dplyr::select(team_name,
                conf,
                cfp_rank,
                sor,
                sor_ptile,
                fei_resume_rank,
                fei_resume_ptile,
  ) |> 
  dplyr::filter(!is.na(cfp_rank)) |> 
  dplyr::arrange(cfp_rank) 

# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))

table_name <- "cfp_rankings"

duckdb::dbWriteTable(con, table_name, cfb_resume, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)



