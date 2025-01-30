# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))
source(here::here("data/college-basketball/base_query.R"))

# home court 
hcMultiplier <- 0.014

# Add the efficiency ratings
barts <- ratings |>
  dplyr::select(team, barthag, adj_o, adj_d) |>
  dplyr::add_row(
    team = "BubTeam",
    # define the bubble team - tune this over time
    barthag = .875,
    # this number goes down, wab should go up
    adj_o = 115.07,
    # this number goes up, wab should go up
    adj_d = 99.49
  ) |>
  dplyr::mutate(
    oHome = adj_o * (1 + hcMultiplier),
    dHome = adj_d * (1 - hcMultiplier),
    oAway = adj_o * (1 - hcMultiplier),
    dAway = adj_d * (1 + hcMultiplier)
  ) |>
  dplyr::mutate(
    H = (oHome ^ 11.5) / (oHome ^ 11.5 + dHome ^ 11.5),
    N = (adj_o ^ 11.5) / (adj_o ^ 11.5 + adj_d ^ 11.5),
    A = (oAway ^ 11.5) / (oAway ^ 11.5 + dAway ^ 11.5)
  ) |>
  tidyr::pivot_longer(cols = c(N, H, A),
                      names_to = "location",
                      values_to = "rtg")

# Now add entire played schedule for DI teams only
all_team_sched <- games_with_ratings |>
  dplyr::select(
    game_id,
    date,
    type,
    team,
    opp,
    conf,
    opp_conf,
    location,
    result,
    net,
    quad,
    pts_scored,
    pts_allowed,
    game_score
  ) |>
  dplyr::mutate(opp_location = dplyr::case_match(location, "H" ~ "A", "A" ~ "H", "N" ~ "N")) |>
  dplyr::arrange(date)

# Add in the location based on BubTeam
barts |>
  dplyr::filter(team == "BubTeam" & location == "H") |>
  dplyr::pull(rtg) -> bubbleHome

barts |>
  dplyr::filter(team == "BubTeam" & location == "N") |>
  dplyr::pull(rtg) -> bubbleNeut

barts |>
  dplyr::filter(team == "BubTeam" & location == "A") |>
  dplyr::pull(rtg) -> bubbleAway


# The idea here is to use bubble team's neutral barthag to reverse engineer an
# Offense = Defense Bubble Team
#bubbleNeut = (adj_o^11.5) / (adj_o^11.5 + adj_d^11.5)
#bubbleNeut * (adj_o^11.5 + adj_d^11.5) = (adj_o^11.5)
#bubbleNeut * adj_o^11.5 + bubbleNeut * adj_d^11.5 = adj_o^11.5
#bubbleNeut + bubbleNeut * (adj_d^11.5 / adj_o^11.5 ) = 1
#bubbleNeut * (adj_d^11.5 / adj_o^11.5 ) = -bubbleNeut


# Add played schedule with ratings, wab, and NET
# The cbbdata::cbd_add_net_quad function adds the opponent's NET
# and the Quadrant of the game
sched_with_rtg <- all_team_sched |>
  dplyr::left_join(barts, by = c("team" = "team", "location" = "location")) |>
  dplyr::left_join(barts, by = c("opp" = "team", "opp_location" = "location"))  |>
  dplyr::rename(team_rtg = rtg.x, opp_rtg = rtg.y)  |>
  dplyr::mutate(
    bub_rtg = dplyr::case_when(
      location == "H" ~ bubbleHome,
      location == "A" ~ bubbleAway,
      location == "N" ~ bubbleNeut
    )
  ) |>
  dplyr::mutate(
    #bub_win_prob = log(bub_rtg / (1 - opp_rtg), base = 5),
    bub_win_prob = (bub_rtg - bub_rtg * opp_rtg) / (bub_rtg + opp_rtg - 2 * bub_rtg * opp_rtg),
    # team A is bubble, team B is opponent
    wab = dplyr::case_when(result == "W" ~ (1 - bub_win_prob), result == "L" ~ (0 - bub_win_prob), ),
    wab_opp = 1 - bub_win_prob,
    score = paste0(pts_scored, "-", pts_allowed),
  ) |>
  dplyr::select(
    game_id,
    date,
    type,
    team,
    opp,
    conf,
    opp_conf,
    location,
    result,
    score,
    opp_location,
    team_rtg,
    opp_rtg,
    bub_rtg,
    bub_win_prob,
    wab,
    wab_opp,
    net,
    quad,
    game_score,
    conf,
    opp_conf
  )

# Now add in the future games
playedGames <- sched_with_rtg |>
  dplyr::distinct(game_id)


all_team_future <- cbbdata::cbd_torvik_season_schedule(year = 2025) |>
  dplyr::filter(!game_id %in% playedGames & type != "nond1") |>
  dplyr::mutate(team = home, opp = away)

all_team_future_visitors <- cbbdata::cbd_torvik_season_schedule(year = "2025") |>
  dplyr::filter(!game_id %in% playedGames & type != "nond1") |>
  dplyr::mutate(team = away, opp = home)

# add in conferences 
team_confs <- sched_with_rtg |> 
  dplyr::select(team, conf) |> 
  dplyr::distinct(team, .keep_all = TRUE)

opp_confs <- sched_with_rtg |> 
  dplyr::select(opp, opp_conf) |> 
  dplyr::distinct(opp, .keep_all = TRUE)

future_sched_with_ratings <-
  rbind.data.frame(all_team_future, all_team_future_visitors) |>
  dplyr::mutate(location = ifelse(neutral, "N", ifelse(team == home, "H", "A"))) |>
  dplyr::mutate(opp_location = ifelse(neutral, "N", ifelse(team == home, "A", "H"))) |>
  dplyr::arrange(date) |>
  dplyr::left_join(barts, by = c("team" = "team", "location" = "location")) |>
  dplyr::left_join(barts, by = c("opp" = "team", "opp_location" = "location"))  |>
  dplyr::rename(team_rtg = rtg.x, opp_rtg = rtg.y) |>
  dplyr::mutate(
    bub_rtg = dplyr::case_when(
      location == "H" ~ bubbleHome,
      location == "A" ~ bubbleAway,
      location == "N" ~ bubbleNeut
    )
  ) |>
  dplyr::mutate(#bub_win_prob = log(bub_rtg / (1 - opp_rtg), base = 5),
    bub_win_prob = (bub_rtg - bub_rtg * opp_rtg) / (bub_rtg + opp_rtg - 2 * bub_rtg * opp_rtg)) |>
  dplyr::mutate(wabW = (1 - bub_win_prob),
                wabL = -bub_win_prob,
  ) |>
  dplyr::left_join(team_confs, by = "team") |> 
  dplyr::left_join(opp_confs, by ="opp") |> 
  dplyr::select(
    game_id,
    date,
    team,
    opp,
    type,
    location,
    opp_location,
    team_rtg,
    opp_rtg,
    bub_rtg,
    bub_win_prob,
    wabW,
    wabL,
    conf,
    opp_conf
  ) |>
  dplyr::mutate(team = team_name_lookup(team)) |> # revert names to get quad
  dplyr::mutate(opp = team_name_lookup(opp)) |>  # data
  cbbdata::cbd_add_net_quad() |> # add quad data and net
  dplyr::mutate(team = team_name_update(team)) |> # now revert back
  dplyr::mutate(opp = team_name_update(opp)) # to match other data, wow

# -----------------------------
# Now combine the current results with the future schedule
# idea is to show a teams schedule with wab borken out

sched_to_join <- sched_with_rtg |>
  dplyr::select(game_id, type, team, opp, wab, wab_opp, result, score, game_score)

# First table is only going to include results or played games
team_sched_by_wab <- future_sched_with_ratings |>
  dplyr::left_join(sched_to_join,
                   by = c("game_id", "team", "opp", "type"),
                   relationship = "many-to-many") |>
  dplyr::mutate(
    quad = quad_clean(quad),
    wab_result = dplyr::if_else(result == "W", round(wabW, 2), round(wabL, 2)),
    score_sentence = paste0(result, ", ", score)
  ) |>
  dplyr::filter(!is.na(result)) |> 
  dplyr::arrange(desc(date))

# Second table only includes future games
team_future_by_wab <- future_sched_with_ratings |>
  dplyr::left_join(sched_to_join,
                   by = c("game_id", "team", "opp", "type"),
                   relationship = "many-to-many") |>
  dplyr::mutate(
    quad = quad_clean(quad),
    wabW = round(wabW, 2),
    wabL = round(wabL, 2)
  ) |>
  dplyr::select(-wab, -wab_opp, -result, -score) 

# ----------------------------- Wall of WAB

wall_of_wab <- team_sched_by_wab |> 
  dplyr::group_by(team, conf) |> 
  dplyr::summarise(
    total = sum(wab_result),
    non_con = sum(wab_result[type == "nc"], na.rm = TRUE),
    league = sum(wab_result[type == "conf"], na.rm = TRUE),
    home = sum(wab_result[location == "H"], na.rm = TRUE),
    away = sum(wab_result[location == "A"], na.rm = TRUE),
    neutral = sum(wab_result[location == "N"], na.rm = TRUE),
    quad_1 = sum(wab_result[quad == "Q1"], na.rm = TRUE),
    quad_2 = sum(wab_result[quad == "Q2"], na.rm = TRUE),
    quad_3 = sum(wab_result[quad == "Q3"], na.rm = TRUE),
    quad_4 = sum(wab_result[quad == "Q4"], na.rm = TRUE),
    
  ) |> 
  dplyr::arrange(-total)

# ----------------------------- Write to duckdb
write_to_duckdb(team_sched_by_wab, "wab_team_schedule")

write_to_duckdb(team_future_by_wab, "wab_team_future")

write_to_duckdb(wall_of_wab, "wall_of_wab")

