library(tidyverse)
library(httr)
library(data.table)
library(hoopR)

source("Utlis/Realgm_data_pull.R")

pull_shooting <- function(season_type = "Regular+Season", season_year = "2023-24", league_id = "20"){
  url <- paste('https://stats.gleague.nba.com/stats/leaguedashteamshotlocations?Conference=&DateFrom=&DateTo=&DistanceRange=By+Zone&Division=&GameScope=&GameSegment=&LastNGames=0&LeagueID=',league_id,
               '&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=Totals&Period=0&PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season=',
               season_year,'&SeasonSegment=&SeasonType=',season_type,
               '&ShotClockRange=&StarterBench=&TeamID=0&TwoWay=0&VsConference=&VsDivision=', sep ="")
  return(url)
}

pull_scoring <- function(season_type = "Regular+Season", season_year = "2023-24", league_id = "20"){
  url <- paste('https://stats.gleague.nba.com/stats/leaguedashteamstatscombined?Conference=&DateFrom=&DateTo=&Division=&GameScope=&GameSegment=&LastNGames=0&LeagueID=',
       league_id, '&Location=&MeasureType=Scoring&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=Totals&Period=0&PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season=',
       season_year,'&SeasonSegment=&SeasonType=',
       season_type ,'&ShotClockRange=&StarterBench=&TeamID=0&TwoWay=0&VsConference=&VsDivision=',sep='')
  return(url)
}

pull_boxscore <- function(season_type = "Regular+Season", season_year = "2023-24", league_id = "20"){
  url <- paste('https://stats.gleague.nba.com/stats/leaguedashteamstatscombined?Conference=&DateFrom=&DateTo=&Division=&GameScope=&GameSegment=&LastNGames=0&LeagueID=',league_id,
               '&Location=&MeasureType=Advanced&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=PerGame&Period=0&PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season=',
               season_year,'&SeasonSegment=&SeasonType=',season_type,
               '&ShotClockRange=&StarterBench=&TeamID=0&TwoWay=0&VsConference=&VsDivision=', sep ="")
  return(url)
}

getDatafromWebsite <- function(url_link){
  res <- httr::GET(url = url_link)
  data <- httr::content(res) %>% .[['resultSets']] %>% .[[1]]
  column_names <- data$headers %>% as.character()
  dt <- rbindlist(data$rowSet) %>% setnames(column_names)

  return(dt)
}

getDatafromWebsiteShooting <- function(url_link){
  res <- httr::GET(url = url_link)
  data <- httr::content(res) %>% .[['resultSets']] %>% .[[3]]
  column_names <- httr::content(res) %>% .[['resultSets']] %>% .[[2]]

  header_names <- column_names[[1]][["columnNames"]] %>% as.character()
  column_names <- column_names[[2]][["columnNames"]] %>% as.character()
  dt <- data.frame(t(sapply(data,c)))
  #This may need to be updated because of the list of the header names may be in different order
  dt <- dt %>%
    rename(TEAM_ID = X1, TEAM_NAME = X2,
           RA_FGM = X3, RA_FGA = X4, RA_FG_PCT = X5,
           PAINT_FGM = X6, PAINT_FGA = X7, PAINT_FG_PCT = X8,
           MIDRANGE_FGM = X9, MIDRANGE_FGA = X10, MIDRANGE_FG_PCT = X11,
           LC3_FGM = X12, LC3_FGA = X13, LC3_FG_PCT = X14,
           RC3_FGM = X15, RC3_FGA = X16, RC3_FG_PCT = X17,
           ATB3_FGM = X18, ATB3_FGA = X19, ATB3_FG_PCT = X20,
           BACK_FGM = X21, BACK_FGA = X22, BACK_FG_PCT = X23,
           CORNER3_FGM = X24, CORNER3_FGA = X25, CORNER3_FG_PCT = X26)

  return(dt)
}

cleanScoringData <- function(dframe, team_name){
  tmp <- dframe %>%
    filter(TEAM_NAME == team_name) %>%
    select(TEAM_NAME, `2PT Attempt` = PCT_FGA_2PT, `3PT Attempt` = PCT_FGA_3PT,
           `Paint PTS Made` = PCT_PTS_2PT,`Midrange PTS Made` = PCT_PTS_2PT_MR,`3PTS Made` = PCT_PTS_3PT,
           `Fast Break` = PCT_PTS_FB, `Free Throw` = PCT_PTS_FT,`Off TOV` = PCT_PTS_OFF_TOV,
           `In Paint` = PCT_PTS_PAINT,`Assisted 2PT` = PCT_AST_2PM, `Unassisted 2PT` = PCT_UAST_2PM,
           `Assisted 3PT` = PCT_AST_3PM, `Unassisted 3PT` = PCT_UAST_3PM
    ) %>%
    pivot_longer(!c(TEAM_NAME), names_to = "Scoring (% of Points)", values_to = "Value") %>%
    select(-TEAM_NAME)

  return(tmp)
}

player_profile_url <- 'https://stats.gleague.nba.com/stats/leaguedashplayerbiostats?College=&Conference=&Country=&DateFrom=&DateTo=&Division=&DraftPick=&DraftYear=&GameScope=&GameSegment=&Height=&LastNGames=0&LeagueID=20&Location=&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PerMode=PerGame&Period=0&PlayerExperience=&PlayerPosition=&Season=2023-24&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&StarterBench=&TeamID=0&VsConference=&VsDivision=&Weight='

gleague_teams <- getDatafromWebsite(player_profile_url) %>%
  select(TEAM_ID, TEAM_ABBREVIATION) %>%
  unique()

nba_teams <- nba_teams() %>%
  select(team_id, team_abbreviation)

nba_g_map <- read.csv("ManualMapping/GLeague_to_NBA_map.csv", header = TRUE)
nba_g_map_winners <- read.csv("ManualMapping/GLeague_to_NBA_map_winners.csv", header = TRUE)


# Create the season boxscores into one table
list_of_seasons <- c('2013-14','2014-15','2015-16','2016-17','2017-18', '2018-19','2020-21','2021-22', '2022-23', '2023-24')


final_data <- c()

for (i in list_of_seasons){
  tmp <- getDatafromWebsite(pull_boxscore(season_year = i)) %>%
    select(TEAM_ID, `W%` = W_PCT, ORTG = E_OFF_RATING, DRTG = E_DEF_RATING, NRTG = E_NET_RATING, AST_TO,
           `OREB%` = OREB_PCT, Pace = E_PACE, `TOV%` = TM_TOV_PCT, `eFG%` = EFG_PCT, `TS%` = TS_PCT) %>%
    #select(TEAM_ID, W_PCT:PTS) %>%
    mutate(season_year = i)

  tmp2 <- getDatafromWebsite(pull_scoring(season_year = i)) %>%
    select(TEAM_ID, `FGA_2PT%` = PCT_FGA_2PT, `FGA_3PT%` = PCT_FGA_3PT, `MR_PTS%` = PCT_PTS_2PT_MR,
           `FB_PTS%` = PCT_PTS_FB, `FT_PTS%` = PCT_PTS_FT, `OFF_TOV_PTS%` = PCT_PTS_OFF_TOV,
           `PAINT_PTS%` = PCT_PTS_PAINT, `AST_2PM%` = PCT_AST_2PM, `AST_3PM%` =  PCT_AST_3PM)

  tmp <- tmp %>%
    left_join(tmp2, by = "TEAM_ID")

  final_data <- final_data %>%
    bind_rows(tmp)
}

season_data <- final_data %>%
  mutate(league_type = "G-League") %>%
  filter(season_year == "2023-24") %>%
  left_join(nba_g_map %>% select(-nba_team_id), by = c("TEAM_ID" = "gleague_team_id")) %>%
  filter(!is.na(gleague_team_abbreviation))

season_data_assign <- season_data %>%
  left_join(gleague_team_assign_count, by = c("TEAM_ID", "gleague_team_abbreviation"= "TEAM_ABBREVIATION")) %>%
  mutate(assign_avg_mins = ifelse(is.na(avg_mins), 0.0, avg_mins ),
         assign_avg_pts = ifelse(is.na(avg_pts), 0.0, avg_pts ),
         assign_avg_gp = ifelse(is.na(avg_gp), 0.0, avg_gp ),
         num_assign_players = ifelse(is.na(num_assign_players), 0, num_assign_players)
  ) %>%
  select(-c(avg_mins, avg_pts, avg_gp))

nba_final_data <- c()

for (i in list_of_seasons){
  tmp1 <- getDatafromWebsite(pull_boxscore(season_year = i, league_id = "00")) %>%
    select(TEAM_ID, `W%` = W_PCT, ORTG = E_OFF_RATING, DRTG = E_DEF_RATING, NRTG = E_NET_RATING, AST_TO,
           `OREB%` = OREB_PCT, Pace = E_PACE, `TOV%` = TM_TOV_PCT, `eFG%` = EFG_PCT, `TS%` = TS_PCT) %>%
    #select(TEAM_ID, W_PCT:PTS) %>%
    mutate(season_year = i)

  tmp2 <- getDatafromWebsite(pull_scoring(season_year = i, league_id = "00")) %>%
    select(TEAM_ID, `FGA_2PT%` = PCT_FGA_2PT, `FGA_3PT%` = PCT_FGA_3PT, `MR_PTS%` = PCT_PTS_2PT_MR,
           `FB_PTS%` = PCT_PTS_FB, `FT_PTS%` = PCT_PTS_FT, `OFF_TOV_PTS%` = PCT_PTS_OFF_TOV,
           `PAINT_PTS%` = PCT_PTS_PAINT, `AST_2PM%` = PCT_AST_2PM, `AST_3PM%` =  PCT_AST_3PM)

  tmp <- tmp1 %>%
    left_join(tmp2, by = "TEAM_ID")


  nba_final_data <- nba_final_data %>%
    bind_rows(tmp)
}

nba_season_data <- nba_final_data %>%
  mutate(league_type = "NBA") %>%
  filter(season_year == "2023-24") %>%
  left_join(nba_g_map %>% select(-gleague_team_id), by = c("TEAM_ID" = "nba_team_id")) %>%
  filter(!is.na(gleague_team_abbreviation))


