library(tidyverse)
library(hoopR)
library(data.table)

getDatafromWebsite <- function(url_link){
  res <- httr::GET(url = url_link)
  data <- httr::content(res) %>% .[['resultSets']] %>% .[[1]]
  column_names <- data$headers %>% as.character()
  dt <- rbindlist(data$rowSet) %>% setnames(column_names)

  return(dt)
}

combine_data <- nba_draftcombineplayeranthro(
  league_id = "00",
  season_year = most_recent_nba_season() - 1
)$Results %>%
  mutate(eff_height = (as.numeric(HEIGHT_WO_SHOES) + as.numeric(WINGSPAN))/2 )

player_profile_url <- 'https://stats.gleague.nba.com/stats/leaguedashplayerbiostats?College=&Conference=&Country=&DateFrom=&DateTo=&Division=&DraftPick=&DraftYear=&GameScope=&GameSegment=&Height=&LastNGames=0&LeagueID=00&Location=&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PerMode=PerGame&Period=0&PlayerExperience=&PlayerPosition=&Season=2023-24&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&StarterBench=&TeamID=0&VsConference=&VsDivision=&Weight='
getDatafromWebsite(player_profile_url)



player_profile_data <- function(season = "2023-24", season_type = "Regular+Season", league_id = "20"){
  url <- paste('https://stats.gleague.nba.com/stats/leaguedashplayerbiostats?College=&Conference=&Country=&DateFrom=&DateTo=&Division=&DraftPick=&DraftYear=&GameScope=&GameSegment=&Height=&LastNGames=0&LeagueID=',
                league_id, '&Location=&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PerMode=PerGame&Period=0&PlayerExperience=&PlayerPosition=&Season=',
                season,'&SeasonSegment=&SeasonType=',
                season_type, '&ShotClockRange=&StarterBench=&TeamID=0&VsConference=&VsDivision=&Weight=',sep='')

  return(getDatafromWebsite(url))

}


list_of_seasons <- c('2013-14','2014-15','2015-16','2016-17','2017-18', '2018-19',
                     '2019-20', '2020-21','2021-22', '2022-23', '2023-24', '2024-25')

# G-League Player Data
g_league_player_data <- c()

#g_league_player_data <- player_profile_data()

for(i in list_of_seasons){
  tmp <- player_profile_data(season = i) %>%
    mutate(season = i)

  g_league_player_data <- g_league_player_data %>%
    bind_rows(tmp)

  Sys.sleep(2)
}

# NBA Player Data
nba_league_player_data <- c()

for(i in list_of_seasons){
  tmp <- player_profile_data(season = i, league_id = "00") %>%
    mutate(season = i)

  nba_league_player_data <- nba_league_player_data %>%
    bind_rows(tmp)

  Sys.sleep(2)
}

#nba_league_player_data <- player_profile_data(league_id = "00")



