# -------------------------------------------------------------
# This is the start of fetching college football data for the 2025 season
# It uses the collegefootballdata.com API, so a lot of the functions to fetch data
# are not yet surfaced
# Plan to add more details soon, below is the data cleaning script 
# -------------------------------------------------------------

# get games for 2025
games_2025 <- get_games(year = 2025) |> 
  # some coordinates for these two venues are not present in the data
  # so updating to the original or older venues to verify 
    dplyr::mutate(venue = dplyr::case_match(
      venue,
      "Lanny and Sharon Martin Stadium" ~ "Ryan Field",
      "Pitbull Stadium" ~ "FIU Stadium",
      .default = venue
    ), 
    venueId = dplyr::case_match(
      venueId,
      5960 ~ 3911,
      2031 ~ 218,
      .default = venueId
    ),
   neutralSite = dplyr::case_when(
      homeTeam == "Northwestern" & venue == "Ryan Field" ~ FALSE,
      homeTeam == "Florida International" & venue == "FIU Stadium" ~ FALSE,
      TRUE ~ neutralSite
  ))
  

# get sp ratings
sp_2025 <- get_sp_ratings(year = 2025)

# get venue data
venues <- get_venues()

# only fbs teams
fbs_teams <- get_teams() |>
  dplyr::filter(classification == "fbs") |>
  dplyr::rename(team = school) |>
  dplyr::pull(team)

# team venues
team_home_venues <- games_2025 |>
  dplyr::filter(!neutralSite) |> 
  dplyr::count(homeTeam, venueId, venue, sort = TRUE) |>
  dplyr::group_by(homeTeam) |>
  dplyr::slice_head(n = 1) |>
  dplyr::ungroup() |>
  dplyr::select(
    team = homeTeam,
    homeVenueId = venueId,
    homeVenueName = venue
  ) |>
  dplyr::left_join(
    venues |>
      dplyr::select(
        id,
        homeCity = city,
        homeState = state,
        homeLatitude = latitude,
        homeLongitude = longitude,
        homeCapacity = capacity,
        homeGrass = grass,
        homeDome = dome
      ),
    by = c("homeVenueId" = "id")
  )

# add games with one row per team per game
games_fbs_teams <- dplyr::bind_rows(
    # home team
    games_2025 |>
      dplyr::filter(homeTeam %in% fbs_teams) |>
      dplyr::select(
        id, season, week, seasonType, startDate, startTimeTBD,
        venueId, venue, conferenceGame, neutralSite,
        teamId = homeId,
        team = homeTeam,
        conference = homeConference,
        opponentId = awayId,
        opponent = awayTeam,
        opponentClassification = awayClassification,
        opponentConference = awayConference
      ) |>
      dplyr::mutate(homeAway = "home"),
    # away team
    games_2025 |>
      dplyr::filter(awayTeam %in% fbs_teams) |>
      dplyr::select(
        id, season, week, seasonType, startDate, startTimeTBD,
        venueId, venue, conferenceGame, neutralSite,
        teamId = awayId,
        team = awayTeam,
        conference = awayConference,
        opponentId = homeId,
        opponent = homeTeam,
        opponentClassification = homeClassification,
        opponentConference = homeConference
      ) |>
      dplyr::mutate(homeAway = "away")
  )

# add percentiles for SP rating for all fbs teams
opponent_percentiles <- sp_2025 |>
  dplyr::filter(!is.na(rating)) |> # filter out non fbs teams if it's not there
  dplyr::mutate(
    opponentSpPercentile = dplyr::percent_rank(rating)
  ) |>
  dplyr::select(team, opponentSpPercentile)

# add SP ratings for opponents
games_with_sp_ratings <- games_fbs_teams |>
  dplyr::left_join(
    sp_2025 |>
      dplyr::select(
        opponent = team,
        opponentSpRating = rating,
        opponentSpRanking = ranking
      ),
    by = "opponent"
  ) |> 
    dplyr::left_join(
    opponent_percentiles |>
      dplyr::rename(opponent = team),
    by = "opponent"
  )

# add traveling flag
games_with_travel_flag <- games_with_sp_ratings |>
  dplyr::mutate(
    isTraveling = homeAway == "away" | neutralSite
  )

# add home venue coordinates
games_with_home_coords <- games_with_travel_flag |>
  dplyr::left_join(
    team_home_venues |>
      dplyr::select(team, homeLatitude, homeLongitude),
    by = "team"
  )

# add game venue coordinates
games_with_game_venue <- games_with_home_coords |>
  dplyr::left_join(
    venues |>
      dplyr::select(
        venueId = id,
        gameLatitude = latitude,
        gameLongitude = longitude
      ),
    by = "venueId"
  )

# calculate miles traveled and convert dates
games_with_travel_dates <- games_with_game_venue |>
  dplyr::mutate(
    milesTraveled = dplyr::case_when(
      homeAway == "home" & !neutralSite ~ 0,
      isTraveling ~ geosphere::distHaversine(
        cbind(homeLongitude, homeLatitude),
        cbind(gameLongitude, gameLatitude)
      ) * 0.000621371,  # convert meters to miles
      TRUE ~ 0
    ),
    
    # assume earliest time zone provides the right date? 
    gameDate = lubridate::as_date(
      lubridate::with_tz(
        lubridate::ymd_hms(startDate, tz = "UTC"), 
        "America/New_York"
      )
    ),
     # update week to 0 if before 8/28
    week = dplyr::if_else(gameDate < as.Date("2025-08-28"), 0L, week),
    # update homeAway to "Neutral" if neutralSite is TRUE
    homeAway = dplyr::if_else(neutralSite == TRUE, "neutral", homeAway)
  )

# sort by team and date for rest calculation
games_sorted <- games_with_travel_dates |>
  dplyr::arrange(team, gameDate)

# calculate days rest between games
games_with_rest <- games_sorted |>
  dplyr::group_by(team) |>
  dplyr::mutate(
    daysSincePrevious = as.numeric(gameDate - dplyr::lag(gameDate)),
    daysRest = dplyr::case_when(
      dplyr::row_number() == 1 ~ 0,  # first game means 0 rest
      TRUE ~ pmax(0, daysSincePrevious - 1) 
    )
  ) |>
  dplyr::ungroup()

# final data set cleaned
games_fbs_teams_final <- games_with_rest |>
  dplyr::select(
    -homeLatitude, -homeLongitude, -gameLatitude, -gameLongitude,
    -daysSincePrevious, -startTimeTBD, -venueId, -venue
  ) |>
  dplyr::select(
    id,
    season,
    week,
    seasonType,
    startDate,
    gameDate,
    teamId,
    team,
    conference,
    opponentId,
    opponent,
    opponentClassification,
    opponentConference,
    homeAway,
    conferenceGame,
    neutralSite,
    isTraveling,
    opponentSpRating,
    opponentSpRanking,
    opponentSpPercentile,
    milesTraveled,
    daysRest
  ) 

# add table to BigQuery source
con <- bigrquery::dbConnect(
  bigrquery::bigquery(),
  project = "bycdata",
  dataset = "cfb_2025"
)

DBI::dbWriteTable(con, "fbs_schedule", games_fbs_teams_final, overwrite = TRUE)

DBI::dbDisconnect(con)
