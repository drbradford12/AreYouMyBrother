library(tidyverse)

# Step 1: Load Data
source(here::here('Utlis', 'data_pull.R'))

gl_playing_styles <- final_data %>%
  mutate(
    play_style = case_when(
      Pace > 100 & `FB_PTS%` > .15 ~ "Fast-Paced",
      DRTG < 105 & `DREB%` > .75 ~ "Defensive-Oriented",
      `FGA_3PT%` > 0.4 ~ "Three-Point Heavy",
      `UAST_FGM%` > .10 & `AST%` < .50 ~ "Iso-Heavy", # Unassisted 2PM% as an iso proxy?
      `PAINT_PTS%` > .50 & `OREB%` > .30 ~ "Big-Man Centric",
      `AST%` > .60 ~ "Motion Offense",
      DRTG < 110 & `OREB%` > .30 ~ "Grit-and-Grind",
      TRUE ~ "Balanced/Adaptive"  # Default
    )
  )

create_lag_3_years(gl_playing_styles, 'play_style') %>%
  filter(season_year == '2023-24')

# Visualize distribution of styles
gl_playing_styles %>%
  group_by(play_style, season_year) %>%
  summarise(Count = n()) %>%
  ggplot( aes(x=season_year, y=Count, colour = play_style, fill = play_style, group = play_style)) +
  geom_line() +
  geom_point(shape=21, size=6) +
  theme_minimal() +
  ggtitle("Evolution of play style in G-League") +
  theme(axis.text.x = element_text(angle=45))

nba_playing_styles <- nba_final_data %>%
  mutate(
    play_style = case_when(
      Pace > 100 & `FB_PTS%` > .20 ~ "Fast-Paced",
      DRTG < 105 & `DREB%` > .75 ~ "Defensive-Oriented",
      `FGA_3PT%` > 0.4 ~ "Three-Point Heavy",
      `UAST_FGM%` > .10 & `AST%` < .50 ~ "Iso-Heavy", # Unassisted 2PM% as an iso proxy?
      `PAINT_PTS%` > .50 & `OREB%` > .30 ~ "Big-Man Centric",
      `AST%` > .60 ~ "Motion Offense",
      DRTG < 110 & `OREB%` > .30 ~ "Grit-and-Grind",
      TRUE ~ "Balanced/Adaptive"  # Default
    )
  )


create_lag_3_years(nba_playing_styles, 'play_style') %>%
  filter(season_year == '2023-24')

# Visualize distribution of styles
nba_playing_styles %>%
  group_by(play_style, season_year) %>%
  summarise(Count = n()) %>%
  ggplot( aes(x=season_year, y=Count, colour = play_style, fill = play_style, group = play_style)) +
  geom_line() +
  geom_point(shape=21, size=6, position=position_jitter()) +
  theme_minimal() +
  ggtitle("Evolution of play style in NBA") +
  theme(axis.text.x = element_text(angle=45))


