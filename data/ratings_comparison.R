source(here::here("data/utils.R"))
source(here::here("data/cfb_ratings.R"))

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

ratings_sankey <- cfb_resume |> 
  dplyr::mutate(
   conf = conf_name_lookup(conf) 
  ) |> 
  dplyr::group_by(conf) |> 
  dplyr::summarise(
    Playoff = sum(cfp_rank < 13),
    `Top 25` = sum(cfp_rank > 12)
  ) |> 
  tidyr::pivot_longer(
    cols = c(Playoff, `Top 25`),
    names_to = "Tier",
    values_to = "Total"
  )

# Save this table to duckdb
con <- dbConnect(duckdb::duckdb(dbdir = "sources/cfb/cfbdata.duckdb"))

table_name <- "conf_ratings_comp"

duckdb::dbWriteTable(con, table_name, ratings_sankey, overwrite = TRUE)

dbDisconnect(con, shutdown = TRUE)
