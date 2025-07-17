# -------------------------------------------------------------
# This leverages cfbfastR to scrape the 247Sports transfer portal data
# Found some limitations are if a player transfers twice, it's only in the data once
# For example, a player who transfers into a school in one window and out the next
# -------------------------------------------------------------


# pull in only the fbs teams for 2025 for filtering later 
cfb_info <- cfbfastR::cfbd_team_info(year = 2025) 

cfb_teams <- as.data.frame(cfb_info) |> 
  dplyr::select(team = school) |> 
  dplyr::pull(team)

# define positions for offense and defense
off_positions <- c("WR", "RB", "IOL", "OT", "QB", "TE")
def_positions <- c("S", "CB", "EDGE", "DL", "LB")

# base query to fetch portal stats 
portal <- cfbfastR::cfbd_recruiting_transfer_portal(year = 2025) |> 
  dplyr::mutate(
    transferDate = as.Date(transfer_date),
    transferMonth = lubridate::month(transferDate, label = TRUE),
    transferYear = lubridate::year(transferDate),
    rating = as.numeric(rating),
    window = ifelse(transferMonth != "Apr", "Winter", "Spring"),
    type = dplyr::case_when(
      position %in% off_positions ~ "Offense",
      position %in% def_positions ~ "Defense",
      TRUE ~ "Specialists" 
    )
  ) |> 
  dplyr::filter(!is.na(origin), !is.na(destination)) |>
  dplyr::select(-transfer_date)  # Remove the original column

# counts by position 
position_counts <- portal |>
  dplyr::filter(!is.na(origin), !is.na(destination)) |>
  dplyr::group_by(origin, destination, season, position) |>
  dplyr::summarise(n = dplyr::n(), .groups = "drop")

# counts with labels - used for a visualization 
position_labels <- position_counts |>
  dplyr::mutate(label = paste0(n, " ", position)) |>
  dplyr::group_by(origin, destination, season) |>
  dplyr::summarise(
    n = sum(n),
    positions = paste(label, collapse = ", "),
    .groups = "drop"
  ) |>
  dplyr::arrange(-n)

# summary table of incoming transfers with offense/defense breakdown
incoming <- portal |>
  dplyr::group_by(destination) |>
  dplyr::summarise(
    incomingCount = dplyr::n(),
    incomingAvgRating = mean(rating, na.rm = TRUE),
    incomingOffense = sum(type == "Offense", na.rm = TRUE),
    incomingDefense = sum(type == "Defense", na.rm = TRUE),
    incomingSpecialists = sum(type == "Specialists", na.rm = TRUE),
    .groups = "drop"
  )

# outgoing transfers with offense/defense breakdown
outgoing <- portal |>
  dplyr::group_by(origin) |>
  dplyr::summarise(
    outgoingCount = dplyr::n(),
    outgoingAvgRating = mean(rating, na.rm = TRUE),
    outgoingOffense = sum(type == "Offense", na.rm = TRUE),
    outgoingDefense = sum(type == "Defense", na.rm = TRUE),
    outgoingSpecialists = sum(type == "Specialists", na.rm = TRUE),
    .groups = "drop"
  )

# Combine both into one summary
portal_summary <- dplyr::full_join(incoming, outgoing,
                                   by = c("destination" = "origin")) |>
  dplyr::rename(school = destination) |>
  dplyr::filter(school %in% cfb_teams) |>  # only fbs teams 
  tidyr::replace_na(list(
    incomingCount = 0,
    incomingAvgRating = 0,
    incomingOffense = 0,
    incomingDefense = 0,
    incomingSpecialists = 0,
    outgoingCount = 0,
    outgoingAvgRating = 0,
    outgoingOffense = 0,
    outgoingDefense = 0,
    outgoingSpecialists = 0
  )) |>
  dplyr::mutate(
    delta = incomingCount - outgoingCount,
    deltaOffense = incomingOffense - outgoingOffense,
    deltaDefense = incomingDefense - outgoingDefense,
    deltaSpecialists = incomingSpecialists - outgoingSpecialists
  ) |> 
  dplyr::arrange(-incomingAvgRating)


# pivot data by position 
transfer_summary <- dplyr::bind_rows(
  # outgoing 
  portal |>
    dplyr::count(team = origin, position, name = "count") |>
    dplyr::mutate(type = "Outgoing"),
  
  # incoming 
  portal |>
    dplyr::count(team = destination, position, name = "count") |>
    dplyr::mutate(type = "Incoming")
) |>
  # pivot wider to get counts
  tidyr::pivot_wider(
    names_from = type,
    values_from = count,
    values_fill = 0
  ) |>
  dplyr::mutate(Delta = Incoming - Outgoing) |>
  # pivot longer for heatmap in evidence.dev
  tidyr::pivot_longer(
    cols = c(Outgoing, Incoming, Delta),
    names_to = "type",
    values_to = "count"
  ) |>
  # order by team, position, type, and count 
  dplyr::mutate(type = factor(type, levels = c("Incoming", "Outgoing", "Delta"))) |>
  dplyr::arrange(team, position, type) |>
  dplyr::select(team, position, type, count)

# -------------------------------------------------------------
# save this transfer data as CSVs 
# not yet ready to add this data to a warehouse, expect it to remain static 
# or remove this data at the start of the season 

# add player list 
portal_players <- portal 

write.csv(portal_players, "portal_players.csv")

# add team summry 
write.csv(portal_summary, "team_portal_summary.csv")

# add transfer summary as a CSV for visualization 
write.csv(transfer_summary, "team_transfer_heatmap.csv")

# -------------------------------------------------------------