# -----------------------------
# Load the utilities
source(here::here("data/college-basketball/utils.R"))

# now grab the four factors from torvik to compute tram
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
  dplyr::left_join(raw_ratings, by = c("team")) |> 
  dplyr::mutate(adj_em = adj_o - adj_d) |> 
  dplyr::select(team, conf, tram, adj_em,
                off_svi, def_svi, 
                to_pct, or_pct, d_to_pct, d_or_pct,
                adj_o, adj_d, off_e_fg_pct = efg, off_ft_rate = ftr,
                def_e_fg_pct = def_efg, def_ft_rate = def_ftr) |>
  # fix team names and conferences
  dplyr::mutate(conf = conf_name_update(conf),
                conf = conf_name_lookup(conf)
  )
  

# ----------------------------- Write to duckdb
write_to_duckdb(tram_data, "tram_data")


