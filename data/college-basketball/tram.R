# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))

# pull the teams for torvik to kenpom 
team_matcher <- cbbdata::cbd_teams() |> 
                dplyr::select(torvik_team, team = kp_team) |> 
                # add west ga, mercyhurst - new teams in 2025
                dplyr::add_row(torvik_team = "West Georgia",
                               team = "West Georgia") |> 
                dplyr::add_row(torvik_team = "Mercyhurst",
                               team = "Mercyhurst")


# grab the raw ratings from kenpom 
raw_ratings <- hoopR::kp_efficiency(min_year = 2025, max_year = 2025) |> 
  dplyr::select(team, raw_o, raw_d) |> 
  dplyr::mutate(raw_em = raw_o - raw_d)

# now grab the four factors from kenpom to compute tram 
tram_data <- hoopR::kp_fourfactors(min_year = 2025, max_year = 2025) |> 
  dplyr::mutate(
    to_pct = off_to_pct / 100,
    or_pct = off_or_pct / 100,
    d_to_pct = def_to_pct / 100,
    d_or_pct = def_or_pct / 100
  ) |> 
  dplyr::mutate(
    off_svi = ((100 - (100 * to_pct)) + (or_pct * (0.561 * (100 - (100 * to_pct))))),
    def_svi = ((100 - (100 * d_to_pct)) + (d_or_pct * (0.561 * (100 - (100 * d_to_pct))))),
    tram = off_svi - def_svi
  ) |> 
  dplyr::left_join(raw_ratings, by = c("team")) |> 
  dplyr::mutate(adj_em = adj_o - adj_d) |> 
  dplyr::select(team, conf, tram, raw_em, adj_em,
                off_svi, def_svi, 
                to_pct, or_pct, d_to_pct, d_or_pct,
                raw_o, raw_d, 
                adj_o, adj_d, off_e_fg_pct, off_ft_rate,
                def_e_fg_pct, def_ft_rate) |>
  # fix team names that don't match
  dplyr::mutate(team = dplyr::case_match(team,
                "McNeese" ~ "McNeese St.",
                "IU Indy" ~ "IUPUI", 
                "CSUN" ~ "Cal St. Northridge",
                "Nicholls" ~ "Nicholls St.",
                "Southeast Missouri" ~ "Southeast Missouri St.",
                "Kansas City" ~ "UMKC", 
                "SIUE" ~ "SIU Edwardsville",
                "East Texas A&M" ~ "Texas A&M Commerce",
                team ~ team)) |> 
  dplyr::left_join(team_matcher, by = "team") |> 
  dplyr::mutate(conf = conf_name_update(conf),
                conf = conf_name_lookup(conf)
  )
  


# ----------------------------- Write to duckdb
write_to_duckdb(tram_data, "tram_data")


