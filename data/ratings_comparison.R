# Ratings comparison
# this is experimental right now 
# commenting out the other code 
# ```sql ratings_sankey_power
# select 
# conf,
# tier,
# tier_count
# from conf_ratings_comp
# where conf in ('SEC', 'ACC', 'Big 12', 'Big Ten')
# order by tier_count desc
# ```


# <SankeyDiagram 
# data={ratings_sankey_power} 
# title="Sankey" 
# subtitle="A simple sankey chart" 
# sourceCol=conf
# targetCol=tier 
# valueCol=tier_count />

ratings_sankey <- cfb_ratings |> 
  dplyr::group_by(conf) |> 
  dplyr::mutate(rk_sum = f_plus_rk + fpi_rk,
                rk_avg = rk_sum /2) |> 
  dplyr::summarise(
    tier_one = sum(rk_avg < 46),
    tier_two = sum(rk_avg > 45 & rk_avg < 91),
    tier_three = sum(rk_avg > 90)
  ) |> 
  tidyr::pivot_longer(
    cols = starts_with("tier_"),
    names_to = "tier",
    values_to = "tier_count"
  )

# Save this table to duckdb
con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))

table_name <- "conf_ratings_comp"

duckdb::dbWriteTable(con, table_name, ratings_sankey, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)