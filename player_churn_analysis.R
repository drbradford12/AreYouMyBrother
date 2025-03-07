# Load libraries
library(tidyverse)
library(ggplot2)
library(rvest)

source(here::here('Utlis', 'player_pull_data.R'))

# Clean G-League player data
g_league_players_clean <- g_league_player_data %>%
  mutate(draft_status = ifelse(DRAFT_YEAR == "Undrafted", 0, 1)) %>%
  dplyr::select(PLAYER_ID, PLAYER_NAME, AGE, GP, PTS, TS_PCT, draft_status, season) %>%
  mutate(League = "G-League")

# Create the lag years for the seasons

g_league_players_with_lags <- g_league_players_clean %>%
  group_by(PLAYER_ID, PLAYER_NAME) %>%
  arrange(season) %>%
  rename(age = AGE, gp = GP, pts = PTS, ts_pct = TS_PCT) %>%
  mutate(across(c(age, gp, pts, ts_pct, season),
                list(glg_yr_lag1 = ~lag(., 1),
                     glg_yr_lag2 = ~lag(., 2)), .names = "{.col}_{.fn}")) %>%
  ungroup() %>%
  filter(!is.na(PLAYER_NAME), !is.na(PLAYER_ID))

# Clean NBA player data
nba_players_clean <- nba_league_player_data %>%
  mutate(draft_status = ifelse(DRAFT_YEAR == "Undrafted", 0, 1)) %>%
  dplyr::select(PLAYER_ID, PLAYER_NAME, AGE, GP, PTS, TS_PCT, draft_status, season) %>%
  mutate(League = "NBA")

# Combine both datasets
combined_players <- g_league_players_clean %>%
  bind_rows(nba_players_clean)

combined_players_churn <- nba_players_clean %>% dplyr::select(-League) %>%
  rename(nba_gp = GP, nba_pts = PTS, nba_age = AGE, nba_ts_pct = TS_PCT, nba_season = season) %>%
  left_join(g_league_players_with_lags %>% dplyr::select(-League, -draft_status),
            by = c("nba_season" = "season", "PLAYER_ID", "PLAYER_NAME")) %>%
  rename(glg_gp = gp, glg_pts = pts, glg_age = age, glg_ts_pct = ts_pct)


# Extract the year from the Season column (assuming format "YYYY-YY")
combined_players <- combined_players %>%
  mutate(Year = as.numeric(substr(season, 1, 4)))

# Find the first year each player appeared in the NBA
nba_debut_year <- combined_players %>%
  filter(League == "NBA") %>%
  group_by(PLAYER_ID, PLAYER_NAME) %>%
  summarise(NBA_Debut_Year = min(Year))

# Find the years each player spent in the G-League
g_league_years <- combined_players %>%
  filter(League == "G-League") %>%
  group_by(PLAYER_ID, PLAYER_NAME) %>%
  summarise(G_League_Years = list(Year))

# Merge NBA debut year with G-League years
player_transitions <- nba_debut_year %>%
  left_join(g_league_years) %>%
  filter(!is.na(G_League_Years))

# Calculate the number of years played in G-League before NBA debut
player_transitions <- player_transitions %>%
  rowwise() %>%
  mutate(Years_in_G_League = sum(G_League_Years < NBA_Debut_Year)) %>%
  ungroup()

# Filter players who transitioned from G-League to NBA
transitioned_players <- player_transitions %>%
  filter(Years_in_G_League > 0)


# Set seed for reproducibility
set.seed(123)

# Simulate churn based on performance metrics
combined_players_churn <- combined_players_churn %>%
  mutate(
    # Players with poor performance are more likely to churn
    churn = ifelse(nba_pts < 5 & nba_gp < 10 & glg_age < 30, 1, 0)
  )


# Split data into training and testing sets
set.seed(123)

combined_players_churn <- combined_players_churn %>%
  left_join(transitioned_players %>% dplyr::select(PLAYER_ID, Years_in_G_League))

combined_players_churn <- combined_players_churn %>%
  na.omit()

# I think I want to change how this is partition based on the number of games. Maybe look into the number of starts?
train_index <- createDataPartition(combined_players_churn$churn, p = 0.8, list = FALSE)
train_data <- combined_players_churn[train_index, ]
test_data <- combined_players_churn[-train_index, ]

# Train a logistic regression model
churn_model <- glm(churn ~ Years_in_G_League + nba_pts + nba_gp + nba_ts_pct,
                   data = train_data, family = binomial)

# Summarize the model
summary(churn_model)

# Predict churn probabilities on the test set
test_data$predicted_churn_prob <- predict(churn_model, test_data, type = "response")

# Convert probabilities to binary predictions (using a threshold of 0.5)
test_data$predicted_churn <- ifelse(test_data$predicted_churn_prob > 0.5, 1, 0)

# Create a confusion matrix
confusion_matrix <- confusionMatrix(as.factor(test_data$predicted_churn), as.factor(test_data$churn))
print(confusion_matrix)

# Plot ROC curve
#install.packages("pROC")  # Install if not already installed
library(pROC)
roc_curve <- roc(test_data$churn, test_data$predicted_churn_prob)
plot(roc_curve, main = "ROC Curve", col = "blue")
auc(roc_curve)  # Print AUC value

# Plot the relationship between NBA_PTS and churn
ggplot(combined_players_churn, aes(x = nba_pts, fill = as.factor(churn))) +
  geom_density(alpha = 0.5) +
  labs(title = "Distribution of NBA Points by Churn Status",
       x = "NBA Points Per Game",
       y = "Density") +
  theme_minimal()

# Plot the relationship between Years_in_G_League and churn
ggplot(combined_players_churn, aes(x = as.factor(Years_in_G_League), fill = as.factor(churn))) +
  geom_bar(position = "fill") +
  labs(title = "Churn Rate by Years in G-League",
       x = "Years in G-League",
       y = "Proportion") +
  theme_minimal()
