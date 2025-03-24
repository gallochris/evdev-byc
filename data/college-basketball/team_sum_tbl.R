# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))
source(here::here("data/college-basketball/base_query.R"))

# Add NCAA team sheets 
bart_ncaa <- "https://barttorvik.com/tourneytime.php"

webpage <- rvest::read_html(bart_ncaa)

raw_table <- webpage |>
  rvest::html_nodes("table") |>
  lapply(rvest::html_table) |>
  purrr::pluck(1) 

bart_ncaa <- raw_table |>
  janitor::clean_names() |> 
  dplyr::mutate(across(c(r64, r32, s16, e8, 
                         f4, f2, champ),
                       ~ dplyr::case_when(
    . == "✓" ~ 100,
    TRUE ~ suppressWarnings(as.numeric(.))
  ))) |> 
  dplyr::mutate(across(c(r64, r32, s16, e8, f4, f2, champ), ~ . / 100)) |> 
  dplyr::select(seed, region, team, r64, 
                r32, s16, e8, f4, f2, champ)


# Goal is to create a Team page or pseduo-team sheet 
# Sort ratings
bart_url <- "https://barttorvik.com/teamsheets.php?sort=6&conlimit=All&year=2025"

webpage <- rvest::read_html(bart_url)

raw_table <- webpage |>
  rvest::html_nodes("table") |>
  lapply(rvest::html_table) |>
  purrr::pluck(1) |>
  janitor::row_to_names(row = 1) |> 
  janitor::clean_names()

# Ensure unique column names
raw_table <- setNames(raw_table, make.names(names(raw_table), unique = TRUE))

# Clean the names
bart_table <- raw_table |>
  janitor::clean_names() |> 
  tidyr::separate(team, into = c("team", "seed"), sep = "(?<=\\D) (?=[0-9])", 
                  fill = "right") |> 
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
  dplyr::mutate(score_sentence = paste0(
    result, ", ", pts, "-", opp_pts,
    ", ", opp
  )) |> 
  dplyr::select(team, date, score_sentence, game_score) |> 
  dplyr::arrange(team, date)

# load net data for yesterday. 
# yesterday_date <- Sys.Date() - 1
# NET rankings are paused on 3-16-2025

net_data <- readr::read_csv(here::here("data/net_archive.csv")) |> 
  dplyr::filter(date == "2025-03-16") |> 
  dplyr::select(team, net, net_percentile) |> 
  dplyr::distinct(team, .keep_all = TRUE)


# add TRAM 
tram_data <- cbbdata::cbd_torvik_team_factors(year = 2025) |> 
  dplyr::mutate(
    to_pct = tov_rate / 100,
    or_pct = oreb_rate / 100,
    d_to_pct = def_tov_rate / 100,
    d_or_pct = dreb_rate / 100
  ) |> 
  dplyr::mutate(
    off_svi = ((100 - (100 * to_pct)) + (or_pct * (0.561 * (100 - (100 * to_pct))))),
    def_svi = ((100 - (100 * d_to_pct)) + (d_or_pct * (0.561 * (100 - (100 * d_to_pct))))),
    tram = off_svi - def_svi
  ) |> 
  dplyr::mutate(adj_em = adj_o - adj_d) |> 
  dplyr::select(team, tram)

# join tables
team_sum_tbl <- bart_table |> 
  dplyr::left_join(bart_ncaa, by = "team") |> 
  dplyr::left_join(game_scores_with_conf, by = "team") |> 
  dplyr::left_join(net_data, by = "team") |> 
  dplyr::left_join(tram_data, by = "team") |> 
  dplyr::select(seed, region, team, record, conf, tram, net, trk, kp, wab,
                net_percentile, trk_percentile, kp_percentile, 
                wab_percentile, season_avg, last_five_avg, 
                r64, r32, s16, e8, f4, f2, champ) |> 
  dplyr::filter(!is.na(region)) # filter out ncaa teams 

# ----------------------------- four factor accounting 
lgeff <- 1.062
lgor <- 29.8 /100

ncaat_teams <- team_sum_tbl |> 
  dplyr::pull(team)

deano <- games_with_ratings |> 
  dplyr::filter(type == "post" & team %in% ncaat_teams) |> 
  dplyr::mutate(
    fg_pts = (pts - ftm),
    opp_fg_pts = (opp_pts - opp_ftm),
    fgx = fga - fgm,
    opp_fgx = opp_fga - opp_fgm
  ) |> 
  dplyr::mutate(
    off_shooting = fg_pts - fgm * lgeff - (1 - lgor) * fgx * lgeff,
    def_shooting = opp_fg_pts - opp_fgm * lgeff - (1 - lgor) * opp_fgx * lgeff,
    off_turnovers = -lgeff*to,
    def_turnovers = -lgeff*opp_to,
    off_reb = (
      (1-lgor)*oreb - lgor*opp_dreb) *lgeff,
    def_reb = (
      (1-lgor)*opp_oreb- lgor*dreb)*lgeff,
    off_ft = ftm - 0.4*fta*lgeff+0.6*(fta-ftm)*lgeff,
    def_ft = opp_ftm - 0.4*opp_fta*lgeff+0.6*(opp_fta-opp_ftm)*lgeff,
    off_factors = (off_shooting + off_turnovers + off_reb + off_ft),
    def_factors = (def_shooting + def_turnovers + def_reb + def_ft),
    delta = off_factors - def_factors,
    pts_diff = pts - opp_pts
  ) |> 
  dplyr::relocate(date, delta, pts_diff, off_ppp, def_ppp, team, opp, off_factors,
                  def_factors, off_shooting, def_shooting, off_turnovers,
                  def_turnovers, off_reb, def_reb, off_ft, def_ft,
                  off_efg, def_efg, off_to, def_to,
                  off_or, def_or, off_ftr, def_ftr)

ncaat_log <- deano |> 
  dplyr::filter(type == "post" & team %in% ncaat_teams) |> 
  dplyr::mutate(off_ppp = round(off_ppp / 100, 2), 
                def_ppp = round(def_ppp / 100, 2),
                score_sentence = paste0(
                  result, ", ", pts_scored, "-",
                  pts_allowed),
                shooting = round(off_shooting - def_shooting, 1),
                turnovers = round(off_turnovers - def_turnovers, 1),
                rebounds = round(off_reb - def_reb, 1),
                freethrows = round(off_ft - def_ft, 1),
                shooting_3 = (tpm +opp_tpm) / (tpa + opp_tpa),
                off_3 = tp_pct,
                off_2 = (fgm - tpm) / (fga - tpa),
                def_3 = opp_tp_pct,
                def_2 = (opp_fgm - opp_tpm) / (opp_fga - opp_tpa)
  ) |> 
  # add dates 
  dplyr::mutate(
    round = dplyr::case_when(
      date %in% c("2025-03-18",
                  "2025-03-19") ~ "First 4", 
      date %in% c("2025-03-20",
                  "2025-03-21") ~ "R64", 
      date %in% c("2025-03-22",
                  "2025-03-23") ~ "R32", 
      date %in% c("2025-03-27",
                  "2025-03-28") ~ "S16", 
      date %in% c("2025-03-29",
                  "2025-03-30") ~ "E8",
      date %in% c("2025-04-05") ~ "F4",
      date %in% c("2025-04-07") ~ "F2"
                              )
  ) |> 
  dplyr::select(round, team, opp, score_sentence, 
                off_ppp, def_ppp, 
                shooting, turnovers,
                rebounds, freethrows,
                shooting_3, off_efg, off_3, off_2,
                def_efg, def_3, def_2
  )


# ----------------------------- Write to duckdb
write_to_duckdb(team_sum_tbl, "team_sum_tbl")
write_to_duckdb(game_scores_series, "game_scores_series")
write_to_duckdb(ncaat_log, "ncaat_log")
