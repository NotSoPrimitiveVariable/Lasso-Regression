# Clear the environment
rm(list = ls())

# Install and load required packages
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::install_github("hollina/scul")

library(scul)
library(foreign)  # for reading in Stata datasets
library(readxl)
library(dplyr)
library(ggplot2)
library(readr)  

# Define paths
main_path <- "C:/Users/rossadr0/Downloads/pgn_work/my csv files"
results_path <- file.path(main_path, "results")

##############################################################
# Get the data on existing chess players
##############################################################

# Import all csv files in the folder path "data"
files <- list.files(main_path, pattern = "*.csv", full.names = TRUE)

for (file in files) {
  assign(gsub(".csv", "", basename(file)), read.csv(file))
}

# Create a running count of games played in every dataframe that begins with the word "ratings"
for (df_name in ls(pattern = "ratings")) {
  assign(df_name, mutate(get(df_name), game_id = 1:nrow(get(df_name))))
}

# Merge all dataframes that begin with the word "ratings" by the variable "game_id"
ratings_list <- mget(ls(pattern = "ratings"))
ratings <- Reduce(function(...) merge(..., by = "game_id", all = TRUE), ratings_list)
ratings <- ratings[order(ratings$game_id), ]

# Clean the data
# For every row after the 15th game:
# If the growth in rating is over 24 points, make the value equal to the previous number plus 8
# If the rating drops by greater than 24 points, make it equal to the previous value minus 8

# Ensure G is defined
G <- 30  # or another appropriate value

if (exists("ratings")) {
  for (i in 16:nrow(ratings)) {
    if (ratings$rating[i] > (ratings$rating[i - 1] + 24)) {
      ratings$rating[i] <- ratings$rating[i - 1] + 8
    } else if (ratings$rating[i] < (ratings$rating[i - 1] - 24)) {
      ratings$rating[i] <- ratings$rating[i - 1] - 8
    }
  }
}

# Define which ones you want to keep or drop to be the donor pool of players
# Keep only the first G rows of ratings
AllXData <- ratings[1:min(G, nrow(ratings)), , drop = FALSE]
