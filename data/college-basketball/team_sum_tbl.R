# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))
source(here::here("data/college-basketball/base_query.R"))


# Goal is to create a Team page or pseduo-team sheet 
# Sore ratings
bart_url <- "https://barttorvik.com/teamsheets.php?sort=6&conlimit=All&year=2025"

webpage <- rvest::read_html(bart_url)

bart_table <- webpage |>
  rvest::html_nodes("table") |>
  lapply(rvest::html_table) |> 
  purrr::pluck(1) |>
  janitor::row_to_names(row = 1) |> 
  janitor::clean_names() |> 
  tidyr::separate(team, into = c("team", "seed"), sep = "(?<=\\D) (?=[0-9])") |> 
  dplyr::filter(team != "Team") |> 
  dplyr::mutate(
    team = stringr::str_remove(team, "F4O"),  # removes F4O
    team = stringr::str_remove(team, "N4O"),
    team = stringr::str_trim(team)  # removes extra whitespace
  ) |> 
  dplyr::mutate(team = team_name_update(team)) |> 
  dplyr::select(team, trk, kp, net, wab, q1, q2, q3, q4) |> 
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
  dplyr::select(team, record, trk, kp, net, wab) |> 
  dplyr::mutate(dplyr::across(c(3:6), as.numeric)) |> 
  dplyr::mutate(
    dplyr::across(
      c(trk, kp, net, wab),
      ~(1.0 - dplyr::percent_rank(.)),
      .names = "{.col}_percentile"
    )
  )

# pluck game scores for all gamelogs with ratings 
game_scores_with_conf <- games_with_ratings |> 
  dplyr::group_by(team, conf) |> 
  dplyr::summarise(
    avg_gs = mean(game_score)
  )

# series data for the sparkline table 
game_scores_series <- games_with_ratings |> 
  dplyr::select(team, date, game_score) |> 
  dplyr::arrange(team, date)


# join table
team_sum_tbl <- bart_table |> 
  dplyr::left_join(game_scores_with_conf, by = "team") |> 
  dplyr::select(team, record, conf, trk_percentile, kp_percentile, 
                net_percentile, wab_percentile, avg_gs)

# ----------------------------- Write to duckdb
write_to_duckdb(team_sum_tbl, "team_sum_tbl")
write_to_duckdb(game_scores_series, "game_scores_series")
