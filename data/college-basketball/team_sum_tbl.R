# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))
source(here::here("data/college-basketball/base_query.R"))


# Goal is to create a Team page or pseduo-team sheet 
# Sore ratings
bart_url <- "https://barttorvik.com/teamsheets.php?sort=6&conlimit=All&year=2025"

webpage <- rvest::read_html(bart_url)

raw_table <- webpage |>
  rvest::html_nodes("table") |>
  lapply(rvest::html_table) |>
  purrr::pluck(1) |>
  janitor::row_to_names(row = 1)

# Ensure unique column names
raw_table <- setNames(raw_table, make.names(names(raw_table), unique = TRUE))

# Clean the names
bart_table <- raw_table |>
  janitor::clean_names() |> 
  tidyr::separate(team, into = c("team", "seed"), sep = "(?<=\\D) (?=[0-9])") |> 
  dplyr::filter(team != "Team") |> 
  dplyr::mutate(
    team = stringr::str_remove(team, "F4O"),  # removes F4O
    team = stringr::str_remove(team, "N4O"),
    team = stringr::str_trim(team)  # removes extra whitespace
  ) |> 
  dplyr::mutate(team = team_name_update(team)) |> 
  dplyr::select(team, trk, kp, wab, q1, q2, q3, q4) |> 
  dplyr::mutate(dplyr::across(dplyr::starts_with("q"), 
                              list(
                                wins = ~as.numeric(stringr::str_extract(., "^\\d+")),
                                losses = ~as.numeric(stringr::str_extract(., "\\d+$"))
                              ))) |>
  dplyr::mutate(
    total_wins = rowSums(dplyr::across(ends_with("_wins"))),
    total_losses = rowSums(dplyr::across(ends_with("_losses"))),
    record = paste0(total_wins, "-", total_losses)
  ) |> 
  dplyr::select(team, record, trk, kp, wab) |> 
  dplyr::mutate(dplyr::across(c(3:5), as.numeric)) |> 
  dplyr::mutate(
    dplyr::across(
      c(trk, kp, wab),
      ~(1.0 - dplyr::percent_rank(.)),
      .names = "{.col}_percentile"
    )
  )

# pluck game scores for all gamelogs with ratings 
game_scores_with_conf <- games_with_ratings |> 
  dplyr::group_by(team, conf) |> 
  dplyr::mutate(
    avg_gs = mean(game_score) 
  ) |> 
  dplyr::arrange(team, desc(date)) |> 
  dplyr::slice_head(n = 5) |> 
  dplyr::summarise(
    last_five_avg = mean(game_score),
    season_avg = dplyr::first(avg_gs) 
  ) |> 
  dplyr::select(team, conf, last_five_avg, season_avg)

# series data for the sparkline table 
game_scores_series <- games_with_ratings |> 
  dplyr::select(team, date, game_score) |> 
  dplyr::arrange(team, date)

# load net data for yesterday. 
yesterday_date <- Sys.Date() - 1

net_data <- readr::read_csv(here::here("data/net_archive.csv")) |> 
  dplyr::filter(date == yesterday_date) |> 
  dplyr::select(team, net, net_percentile) |> 
  dplyr::distinct(team, .keep_all = TRUE)

# join table
team_sum_tbl <- bart_table |> 
  dplyr::left_join(game_scores_with_conf, by = "team") |> 
  dplyr::left_join(net_data, by = "team") |> 
  dplyr::select(team, record, conf, net, trk, kp, wab,
                net_percentile, trk_percentile, kp_percentile, 
                wab_percentile, season_avg, last_five_avg)

# ----------------------------- Write to duckdb
write_to_duckdb(team_sum_tbl, "team_sum_tbl")
write_to_duckdb(game_scores_series, "game_scores_series")
