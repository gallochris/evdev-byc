# -----------------------------
# Load the utilities
# adjusts conference names
source(here::here("data/college-basketball/utils.R"))


# ----------------------- function to get the strings for each date from the archive
url <- "https://stats.ncaa.org/selection_rankings/season_divisions/18403/nitty_gritties"
page <- rvest::read_html(
  httr::GET(url, httr::add_headers(`User-Agent` = "Mozilla/5.0"))
)

links <- page |> 
  rvest::html_nodes("a") |>   
  rvest::html_attr("href") |>     
  na.omit()

# grab the string used for each date
numeric_strings <- links |> 
  as.data.frame() |> 
  dplyr::rename(link = 1) |>      
  dplyr::filter(grepl("selection_rankings/nitty_gritties/\\d+", link)) |> 
  dplyr::mutate(
    numeric_string = sub(".*/(\\d+)$", "\\1", link) 
  ) |> 
  dplyr::pull(numeric_string) |> 
  dplyr::first()

# ----------- function to scrape the rankings 
net_ranks <- function(base_url, id) {
  url <- paste0(base_url, id)  # Combine base URL with the specific ID
  
  net_page <- rvest::read_html(url)
  
  net_rk <- net_page |>
    rvest::html_nodes("table") |>
    rvest::html_table(fill = TRUE)
  
  net_table <- as.data.frame(net_rk[[1]])  # Assume the relevant table is the first one
  
  # Ensure unique column names
  colnames(net_table) <- make.names(colnames(net_table), unique = TRUE)
  
  net_table <- net_table |>   
    dplyr::mutate(
      date = gsub("[^0-9.-]", "", colnames(net_table[3])),
      # replace periods with slashes for better date formate
      date = gsub("\\.", "/", date),
      date = lubridate::mdy(date)
    ) |> 
    dplyr::mutate(
      record = stringr::str_split(WL, "-", simplify = TRUE),
      wins = record[,1],
      losses = record[,2],
      conf_record = stringr::str_split(ConfWL, "-", simplify = TRUE),
      wins_conf = conf_record[,1],
      losses_conf = conf_record[,2],
      non_conf_record = stringr::str_split(NCWL, "-", simplify = TRUE),
      wins_non_conf = non_conf_record[,1],
      losses_non_conf = non_conf_record[,2],
      road_record = stringr::str_split(RoadWL, "-", simplify = TRUE),
      road_wins = road_record[,1],
      road_losses = road_record[,2],
      first_q = stringr::str_split(Q1, "-", simplify = TRUE),
      q1_win = first_q[,1],
      q1_loss = first_q[,2],
      second_q = stringr::str_split(Q2, "-", simplify = TRUE),
      q2_win = second_q[,1],
      q2_loss = second_q[,2],
      third_q = stringr::str_split(Q3, "-", simplify = TRUE),
      q3_win = third_q[,1],
      q3_loss = third_q[,2],
      fourth_q = stringr::str_split(Q4, "-", simplify = TRUE),
      q4_win = fourth_q[,1],
      q4_loss = fourth_q[,2]
    ) |> 
    dplyr::rename(team = Team, conf = Conference, net = NET.Rank, prev_net = PrevNET, 
                  sos = NETSOS, non_conf_sos = NETNCSOS,
                  wab = WAB, non_conf_wab = NCWAB) |> 
    dplyr::select(team, conf, net, prev_net, sos, non_conf_sos, wab, non_conf_wab, 
                  wins, losses, wins_non_conf, losses_non_conf, road_wins, road_losses,
                  q1_win, q1_loss, 
                  q2_win, q2_loss, q3_win, q3_loss, q4_win, q4_loss, date) |> 
    dplyr::mutate_at(dplyr::vars(-team, -conf, -date), as.numeric)
  
  return(net_table)
}

# base URL should not change
base_url <- "https://stats.ncaa.org/selection_rankings/nitty_gritties/"

# go through the array of numeric strings and fetch data
new_net_data <- purrr::map_dfr(numeric_strings, ~ net_ranks(base_url, .x)) |> 
  dplyr::mutate(team = ncaa_team_name_match(team),  # fix team names
                conf = ncaa_conf_name_match(conf), # fix conf names
                net_percentile = (1 - dplyr::percent_rank(net)))

# add data for missing dates on Dec 24 and Dec 26 
# all_net_data <- all_net_data |>
#  dplyr::bind_rows(
#    dplyr::filter(all_net_data, date == "2024-12-23") |>
#      dplyr::mutate(date = as.Date("2024-12-24")),
#    dplyr::filter(all_net_data, date == "2024-12-25") |>
#      dplyr::mutate(date = as.Date("2024-12-26"))
#  )

# load previous net archive data and add new net data 
archive_net_data <- readr::read_csv(here::here("data/net_archive.csv")) |> 
  dplyr::select(-1) |> 
  dplyr::bind_rows(new_net_data)

# write csv to preserve net ratings 
write.csv(archive_net_data, here::here("data/net_archive.csv"))

# now only grab net for today's date, which is actually yesterday!
yesterday_date <- Sys.Date() - 1

net_for_today <- all_net_data |> 
  dplyr::filter(date == yesterday_date) |> 
  dplyr::distinct(team, .keep_all = TRUE)

# ----------------------------- Write to duckdb
write_to_duckdb(all_net_data, "net_archive")
write_to_duckdb(net_for_today, "net_for_today")


