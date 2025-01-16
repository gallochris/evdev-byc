# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))
source(here::here("data/college-basketball/base_query.R"))

# ----------------------------- Build gamelog
gamelog <- games_with_ratings |>
  dplyr::mutate(
    score_sentence = paste0(result, ", ", pts_scored, "-", pts_allowed),
    team_with_rk = paste0(team_rk, " ", team),
    opp_with_rk = paste0(opp_rk, " ", opp),
    tempo = round(tempo, 0),
    delta = pts_scored - pts_allowed
  ) |>
  dplyr::mutate(quad = quad_clean(quad)) |> 
  dplyr::select(
    game_id,
    date,
    type,
    team,
    team_with_rk,
    conf,
    opp_with_rk,
    opp_conf,
    location,
    result,
    delta,
    score_sentence,
    tempo,
    team_rk,
    opp_rk,
    net,
    quad,
    game_score
  ) |>
  dplyr::arrange(desc(date))


# ----------------------------- Write to duckdb
write_to_duckdb(gamelog, "gamelog")

# ----------------------------- Summary table of conference against conference
hth_recs <- gamelog |>
  dplyr::filter(type == "nc") |> 
  dplyr::group_by(conf, opp_conf) |>
  dplyr::summarise(
    games = dplyr::n(),
    wins = sum(result == "W"),
    losses = sum(result == "L"),
    win_pct = wins / (wins + losses),
    avg_win_rtg = dplyr::if_else(wins == 0, 0, mean(opp_rk[result == "W"], na.rm = TRUE)),
    avg_loss_rtg = dplyr::if_else(losses == 0, 0, mean(opp_rk[result == "L"], na.rm = TRUE)),
    q1_wins = dplyr::coalesce(sum(result == "W" &
                                    quad == "Q1"), 0),
    q1_losses = dplyr::coalesce(sum(result == "L" &
                                      quad == "Q1"), 0),
    q2_wins = dplyr::coalesce(sum(result == "W" &
                                    quad == "Q2"), 0),
    q2_losses = dplyr::coalesce(sum(result == "L" &
                                      quad == "Q2"), 0),
    q3_wins = dplyr::coalesce(sum(result == "W" &
                                    quad == "Q3"), 0),
    q3_losses = dplyr::coalesce(sum(result == "L" &
                                      quad == "Q3"), 0),
    q4_wins = dplyr::coalesce(sum(result == "W" &
                                    quad == "Q4"), 0),
    q4_losses = dplyr::coalesce(sum(result == "L" &
                                      quad == "Q4"), 0)
  ) |>
  dplyr::select(
    conf,
    opp_conf,
    games,
    wins,
    losses,
    win_pct,
    avg_win_rtg,
    avg_loss_rtg,
    q1_wins,
    q1_losses,
    q2_wins,
    q2_losses,
    q3_wins,
    q3_losses,
    q4_wins,
    q4_losses
  )

# ----------------------------- Write to duckdb
write_to_duckdb(hth_recs, "hth_recs")


# # ----------------------------- Summarize by quads
quad_summary <- games_with_ratings |>
  dplyr::group_by(conf) |>
  dplyr::summarise(
    q1_games = dplyr::coalesce(sum(quad == "Quadrant 1"), 0),
    q1_wins = dplyr::coalesce(sum(result == "W" &
                                    quad == "Quadrant 1"), 0),
    q1_losses = dplyr::coalesce(sum(result == "L" &
                                      quad == "Quadrant 1"), 0),
    q1_win_pct = q1_wins / q1_games,
    q2_games = dplyr::coalesce(sum(quad == "Quadrant 2"), 0),
    q2_wins = dplyr::coalesce(sum(result == "W" &
                                    quad == "Quadrant 2"), 0),
    q2_losses = dplyr::coalesce(sum(result == "L" &
                                      quad == "Quadrant 2"), 0),
    q2_win_pct = q2_wins / q2_games,
    q3_games = dplyr::coalesce(sum(quad == "Quadrant 3"), 0),
    q3_wins = dplyr::coalesce(sum(result == "W" &
                                    quad == "Quadrant 3"), 0),
    q3_losses = dplyr::coalesce(sum(result == "L" &
                                      quad == "Quadrant 3"), 0),
    q3_win_pct = q3_wins / q3_games,
    q4_games = dplyr::coalesce(sum(quad == "Quadrant 4"), 0),
    q4_wins = dplyr::coalesce(sum(result == "W" &
                                    quad == "Quadrant 4"), 0),
    q4_losses = dplyr::coalesce(sum(result == "L" &
                                      quad == "Quadrant 4"), 0),
    q4_win_pct = q4_wins / q4_games
  ) |>
  dplyr::select(
    conf,
    q1_games,
    q1_wins,
    q1_losses,
    q1_win_pct,
    q2_games,
    q2_wins,
    q2_losses,
    q2_win_pct,
    q3_games,
    q3_wins,
    q3_losses,
    q3_win_pct,
    q4_games,
    q4_wins,
    q4_losses,
    q4_win_pct
  )

# ----------------------------- Write to duckdb
write_to_duckdb(quad_summary, "quad_summary")
