#=============================================================================#
# Britney Sipkema
# DATA 342 - FALL 2025
# Week 14: Advanced Data Mining
# 12/05/2025
#=============================================================================#

# --------------------------------------------------------------------------- #
# SETUP: loads packages and imports Phone Records.csv
# --------------------------------------------------------------------------- #

## loads libraries
library(tidyverse)  # data handling / analysis
library(rpart)      # decision tree
library(rpart.plot) # nice decision tree plots
library(party)      # ctree (conditional inference tree)

# -------- Read the CSV file -------- #
phone <- read.csv('Phone Records.csv')

## looks at the data
head(phone)
str(phone)
names(phone)

# --------------------------------------------------------------------------- #
# 1. BASIC DESCRIPTIVE STATISTICS 
# --------------------------------------------------------------------------- #

## Summary of dataset
summary(phone)

# stores only the numeric variables for further analysis
phone_numeric <- phone %>% select(
  Fixed.Calls, Duration, Mobile, International, Broadband)

## Summary of numeric variables
summary(phone_numeric)

# Means
sapply(phone_numeric, mean)

# Medians
sapply(phone_numeric, median)

# Standard deviations
sapply(phone_numeric, sd)

# Correlation matrix
cor(phone_numeric)

# --------------------------------------------------------------------------- #
# 2. DECISION TREES
#    - creates target variable (Duration: High / Low)
#    - creates a traditional decision tree using rpart
#    - creates a conditional inference tree using party::ctree
# --------------------------------------------------------------------------- # 

# ----- Creates target variable: Duration (High / Low) ----- #
#
#     - converts Duration (numeric) into two categories:
#     - values ABOVE the median are labeled 'high'
#     - values BELOW the median are labeled 'low'
#     - allows for a classification tree (categorical outcome) 
#       instead of a regression tree (numerical outcome)
# ---------------------------------------------------------- #
phone$DurationHL <- ifelse(phone$Duration > median(phone$Duration),
                           'High', 'Low')

# turns the new variable into a factor - (important for classification)
# - if the target is numeric = regression tree
# - if the target is categorical = classification tree
phone$DurationHL <- as.factor(phone$DurationHL)

# ----- CART DECISION TREE (rpart) ----- #
tree_cart <- rpart(DurationHL ~ Fixed.Calls + Mobile + International + Broadband,
                   data = phone,
                   method = 'class')  # classification model

# plots the CART tree
rpart.plot(tree_cart,
           main = 'CART Decision Tree',
           type = 3,                  # clean layout (separates node labels from splits)
           extra = 104)               # controls the information shown at each leaf node

# ----- Conditional Inference Tree (ctree) ----- #
tree_ctree <- ctree(DurationHL ~ Fixed.Calls + Mobile + International + Broadband,
                    data = phone)

# plots the conditional inference tree
plot(tree_ctree,
     main = 'Conditional Inference Tree')


# simple version of ctree
plot(tree_ctree, type = 'simple')

# --------------------------------------------------------------------------- #
# 3. OUTLIER DETECTION
#    - uses Z-scores to detect extreme values
#    - uses boxplot rule (IQR method)
# --------------------------------------------------------------------------- #

# ----- Z-score method (values > |3| are typically considered outliers) ----- #

z_scores   <- scale(phone_numeric)               # scale calculates z-score

outliers_z <- as.data.frame(abs(z_scores) > 3)   # (+/- 3) is considered an outlier 

# Count number of outliers per variable
colSums(outliers_z)

## Interpretation:
#  Higher numbers = variables with extreme values compared to others.
###############################################################################

# ------- Boxplot / IQR method ------- #

# IQR = interquartile range (Q3 - Q1)

detect_outliers_iqr <- function(x) {
  Q1 <- quantile(x, 0.25)
  Q3 <- quantile(x, 0.75)
  IQR_value <- IQR(x)
  
  # TRUE = outlier (below Q1 - 1.5 * IQR OR above Q3 + 1.5 * IQR)
  (x < (Q1 - 1.5 * IQR_value)) | (x > (Q3 + 1.5 * IQR_value))
}

## applies IQR function to each numeric column
outliers_iqr <- sapply(phone_numeric, detect_outliers_iqr)

## counts outliers per variable
colSums(outliers_iqr)

## Individual boxplots
par(mfrow = c(2,3))  # layout: 2 rows, 3 columns
for(i in 1:ncol(phone_numeric)) {
  boxplot(phone_numeric[, i],
          main = colnames(phone_numeric)[i],
          col = 'turquoise2')
}
par(mfrow = c(1, 1))

# --------------------------------------------------------------------------- #
# 4. K-MEANS CLUSTERING
#    - scales numeric variables (important for distance-based algorithms)
#    - applies k-means clustering with k = 5     
#    - identifies behavioral segments based on usage patterns
# --------------------------------------------------------------------------- #

# ----- SCALE (standardize) numeric variables for clustering ----- #
#
#    - K-means uses Euclidean distance between points
#      * if variables are on different scales (EX: 1-100 vs 1-10000),
#        the variable with the larger scale dominates the distance
#      * scaling puts all numeric variables on the same standardized scale
#        (mean = 0, sd = 1) so each contributes equally to clustering
# 
# --------------------------------------------------------------------------- #
cluster_data <- scale(phone_numeric)

# using 5 clusters to create a simple segmentation
set.seed(123)  # so results are reproducible
k <- 5

# -------------------- RUN K-MEANS -------------------- #
#   * n start = 25 performs multiple random starts
#     and chooses the best solution (lower within-cluster variation)
# ------------------------------------------------------------------ #
kmeans_model <- kmeans(cluster_data,
                       centers = k,
                       nstart  = 25)

## View cluster results

# number of records in each cluster
kmeans_model$size

# centroids (cluster centers)
kmeans_model$centers

# add cluster labels back to the main dataset
phone$Cluster <- factor(kmeans_model$cluster)

# frequency table to see how many customers fall into each segment
table(phone$Cluster)

# ----- VISUALIZE K-MEANS CLUSTER USING PCA ----- #
#
#  * Five numeric variables is too many to view in a 2D plot
#  * PCA creates new summary variables (PC1, PC2) that capture most of the 
#    variation in the data
#  * This plots PC1 vs PC2 and color each point by its cluster membership
# --------------------------------------------------------------------------- #

# runs PCA on the numeric variables
pca_result <- prcomp(cluster_data)

# extracts PCA scores (coordinates of each point in PC space)
pca_scores <- as.data.frame(pca_result$x)

# adds cluster labels so clusters can be assigned a color
pca_scores$Cluster <- phone$Cluster

# scatterplot of PC1 vs PC2 colored by cluster
plot(pca_scores$PC1, pca_scores$PC2,
     col  = pca_scores$Cluster,
     pch  = 16,
     xlab = 'Principal Component 1',
     ylab = 'Principal Component 2',
     main = 'K-means Clusters (PCA projection)')

legend('topright',
       legend = levels(pca_scores$Cluster),
       col    = 1:length(levels(pca_scores$Cluster)),
       pch    = 16,
       title  = 'Cluster')

# --------------------------------------------------------------------------- #
# 5. OUTPUT RESULTS TO TEXT FILE(S)
#    - saves full dataset with cluster labels
#    - saves separate text files for each cluster
# --------------------------------------------------------------------------- #

# ----- SAVE FULL DATASET WITH CLUSTERS ----- #
#
#    - includes original variables
#    - DurationHL (High/Low duration class)
#    - Cluster (k-means segment)
#    - outlier flags are implicit in analysis above (not added as columns)
# -------------------------------------------------------------------------#

write.table(phone,
            file      = 'phone_results_all.txt',
            sep       = '\t',
            row.names = FALSE,
            quote     = FALSE)

# ----- SAVE SEPARATE FILES FOR EACH CLUSTER ----- #
#
#    - loops over each cluster label
#    - filters the rows for that cluster
#    - writes them to 'phone_cluster_<cluster>.txt'
# ------------------------------------------------ #

for (cluster in levels(phone$Cluster)) {
  
  # filter rows that belong to the current cluster
  cluster_subset <- phone[phone$Cluster == cluster, ]
  
  # builds file name
  filename <- paste0('phone_cluster_', cluster, '.txt')
  
  # writes this cluster to its own text file
  write.table(cluster_subset,
              file      = filename,
              sep       = '\t',
              row.names = FALSE,
              quote     = FALSE)
}































