# Fetch F+ ratings from bcftoys.com
url <- "https://www.bcftoys.com/2024-fplus/"

webpage <- rvest::read_html(url)

# organize table
f_plus <- webpage |>
  rvest::html_node("table") |>
  rvest::html_table() |>
  dplyr::slice(-1) |>
  dplyr::select(
    f_plus_rk = X1,
    team_name = X2,
    f_plus = X3,
    record = X11
  ) |>
  dplyr::slice(-1) |>
  dplyr::filter(f_plus_rk != "Rk") |>
  na.omit() |>
  dplyr::mutate_at(dplyr::vars(-team_name, -record), as.numeric) |>
  dplyr::mutate(
    team_name = dplyr::case_match(
      team_name,
      "Connecticut" ~ "UConn",
      "UL Monroe" ~ "Louisiana Monroe",
      "Sam Houston" ~ "Sam Houston State",
      "Massachusetts" ~ "UMass",
      team_name ~ team_name
    ),
    f_plus_ptile = dplyr::percent_rank(f_plus)
  )

# Fetch FPI ratings from cfbfastR
fpi <- cfbfastR::espn_ratings_fpi(year = 2024) |>
  dplyr::select(team_name, fpi) |>
  dplyr::mutate(fpi = as.numeric(fpi)) |>
  dplyr::mutate(
    fpi_rk = dplyr::dense_rank(dplyr::desc(fpi)),
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

# Pull in conferences 
confs_only <- cfbfastR::cfbd_team_info(year = 2024) |>
  dplyr::select(team_name = school, conf = conference) |> 
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
      "San José State" ~ "San Jose State", # super inconsistent
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
  dplyr::mutate(conf = dplyr::case_match(conf,
                                       "American Athletic" ~ "American",
                                       "Pac-12" ~ "Pac-2",
                                       "Conference USA" ~ "CUSA",
                                       "FBS Independents" ~ "Independents",
                                       "Mid-American" ~ "MAC",
                                       conf ~ conf  )) 

# Combine the tables and add in the conferences
cfb_ratings <- f_plus |>
  dplyr::left_join(fpi, by = c("team_name")) |>
  dplyr::left_join(confs_only, by = "team_name") |>
  dplyr::mutate(team_name = paste0(team_name, " (", record, ")")) |>
  dplyr::select(team_name,
                conf,
                f_plus_rk,
                f_plus,
                f_plus_ptile,
                fpi_rk,
                fpi,
                fpi_ptile
                )

# Save the table to duckdb
library(duckdb)
library(DBI)

con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))

table_name <- "team_ratings"

duckdb::dbWriteTable(con, table_name, cfb_ratings, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)


# Make a boxplot by conference 
ratings_comp <- cfb_ratings|>
  dplyr::filter(!conf %in% c("Independents", "Pac-2"))|>  # no conf champ game
  dplyr::mutate(rk_sum = f_plus_rk + fpi_rk,
                rk_avg = rk_sum /2) |> 
  dplyr::group_by(conf)|>
  dplyr::summarise(
    min = min(rk_avg),
    first_quartile = quantile(rk_avg, 0.25),
    median = median(rk_avg),
    third_quartile = quantile(rk_avg, 0.75),
    max = max(rk_avg),
    total_teams = dplyr::n()
  )|>
  dplyr::mutate(conf_name = paste0(conf, ": ", total_teams, " teams")) |> 
  dplyr::arrange(median)

# Save this table to duckdb
con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))

table_name <- "conf_ratings_comp"

duckdb::dbWriteTable(con, table_name, ratings_comp, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)
