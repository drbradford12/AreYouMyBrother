# Load necessary libraries
library(tidyverse)
library(cluster)  # For clustering analysis
library(factoextra)  # For PCA visualization
library(corrplot)  # For correlation analysis

# Step 1: Load Data
source(here::here('Utlis', 'data_pull.R'))

# Step 2: Preprocess Data
# Combine data, normalize metrics for fair comparison
combined_data <- bind_rows(
  nba_season_data_assign,
  season_data_assign
)

# Normalize metrics for clustering
normalized_data <- combined_data %>%
  select(-nba_team_abbreviation, -gleague_team_abbreviation, -league_type, -season_year, -TEAM_ID, -TEAM_ID.x, -TEAM_ID.y) %>%
  scale()

# Step 3: Perform Clustering
set.seed(123)
kmeans_result <- kmeans(normalized_data, centers = 10)  # Assuming 10 playing styles
combined_data$Cluster <- kmeans_result$cluster

# Step 4: Compare Playing Styles Between NBA and G-League
# Assign NBA and G-League clusters for comparison
nba_clusters <- combined_data %>%
  filter(league_type == "NBA") %>%
  select(nba_team_abbreviation, gleague_team_abbreviation, Cluster)

gleague_clusters <- combined_data %>%
  filter(league_type == "G-League") %>%
  select(nba_team_abbreviation, gleague_team_abbreviation, Cluster)


cluster_summary <- combined_data %>%
  group_by(Cluster) %>%
  summarise(
    Count = n(),
    Avg_Pace = mean(Pace, na.rm = TRUE),
    Avg_Off_Rating = mean(ORTG, na.rm = TRUE),
    Avg_Def_Rating = mean(DRTG, na.rm = TRUE),
    Avg_3P_Arate = mean(`FGA_3PT%`, na.rm = TRUE),
    Avg_AST_TO_Rate = mean(AST_TO, na.rm = TRUE),
    Avg_Rebound_Rate = mean(`REB%`, na.rm = TRUE)
  )

# Merge to align NBA teams with their affiliates
aligned_data <- nba_clusters %>%
  rename(NBA_Cluster = Cluster) %>%
  inner_join(gleague_clusters %>%
               rename(GLeague_Cluster = Cluster))

# Compare Distribution by League (NBA vs. G-League)
league_cluster_distribution <- combined_data %>%
  group_by(league_type, Cluster) %>%
  summarise(Team_Count = n()) %>%
  pivot_wider(names_from = Cluster, values_from = Team_Count, values_fill = 0)

# Display the distribution of clusters by league
print(league_cluster_distribution)

# Step 5: Measure Alignment
aligned_data <- aligned_data %>%
  mutate(Aligned = ifelse(NBA_Cluster == GLeague_Cluster, 1, 0))

# Calculate alignment percentage
alignment_percentage <- mean(aligned_data$Aligned) * 100
print(paste("Alignment Percentage:", round(alignment_percentage, 3), "%"))

# Step 6: Statistical Testing
# Hypothesis Test: Compare NBA vs. G-League styles
t_test_result <- t.test(aligned_data$NBA_Cluster, aligned_data$GLeague_Cluster)
print(t_test_result)

# Step 7: Visualize Results
# PCA for visualization of playing styles
pca_result <- prcomp(normalized_data, scale = TRUE)
fviz_pca_biplot(pca_result, label = "var", habillage = combined_data$Cluster)

# Correlation Heatmap
cor_matrix <- cor(normalized_data)
corrplot(cor_matrix, method = "circle")
