# Load necessary libraries
library(tidyverse)
library(cluster)  # For clustering analysis
library(factoextra)  # For PCA visualization
library(corrplot)  # For correlation analysis

# Step 1: Load Data
source("Utils/data_pull.R")

# Step 2: Preprocess Data
# Combine data, normalize metrics for fair comparison
combined_data <- bind_rows(
  nba_season_data,
  season_data
)

# Normalize metrics for clustering
normalized_data <- combined_data %>%
  select(-nba_team_abbreviation, -gleague_team_abbreviation, -league_type, -season_year, -TEAM_ID) %>%
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

# Merge to align NBA teams with their affiliates
aligned_data <- nba_clusters %>%
  rename(NBA_Cluster = Cluster) %>%
  inner_join(gleague_clusters %>%
               rename(GLeague_Cluster = Cluster))

# Step 5: Measure Alignment
aligned_data <- aligned_data %>%
  mutate(Aligned = ifelse(NBA_Cluster == GLeague_Cluster, 1, 0))

# Calculate alignment percentage
alignment_percentage <- mean(aligned_data$Aligned) * 100
print(paste("Alignment Percentage:", alignment_percentage, "%"))

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
