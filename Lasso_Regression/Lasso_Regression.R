rm(list=ls())

# Install and load required packages
#if (!require("devtools")) install.packages("devtools")
#devtools::install_github("hollina/scul")


library(scul)
library(foreign) # for reading in Stata datasets
library(readxl)
library(dplyr)
library(ggplot2)
library(readr)  

# Define paths
main_path <- "C:/Users/rossadr0/Downloads/pgn_work/my csv files"
results_path <- paste(main_path, "/results/", sep="")


############################################################
# Import player data
player_path <- "C:/Users/rossadr0/Downloads/pgn_work/my_player/ratings_user.csv"

# Grab the data from the CSV file in player_path
player_data <- read_csv(player_path)

# G is the number of games
G <- nrow(player_data)

# Check if the number of games is greater than 2000
if (G > 2000) {
  # Keep only the most recent 2000 games
  player_data <- tail(player_data, 2000)
  
  # Update G to reflect the new number of games
  G <- nrow(player_data)
}

# Add in the game id column
game_id <- seq(1, G, 1)

# Define 'y' as the 'rating' column from the player_data
y <- player_data$rating

# Combine game_id and y into a data frame
AllYData <- data.frame(game_id, y)

# Clean the data
# For every row after the 15th game:
# If the growth in rating is over 24 points, make the value equal to the previous number plus 8
# If the rating drops by greater than 24 points, make it equal to the previous value minus 8
for (i in 16:G) {
  if (AllYData$y[i] > (AllYData$y[i-1] + 24)) {
    AllYData$y[i] <- AllYData$y[i-1] + 8
  } else if (AllYData$y[i] < (AllYData$y[i-1] - 24)) {
    AllYData$y[i] <- AllYData$y[i-1] - 8
  }
}

# Print the cleaned data frame to check the result
print(AllYData)

##############################################################
# Get the data on existing chess players
###########################################################

# Import all csv files in the folder path "data"

files<-list.files(main_path,pattern="*.csv",full.names=TRUE)
#print(files)

for (i in 1:length(files)){
  assign(gsub(".csv","",basename(files[i])),read.csv(files[i]))
}

# create a running count of games played in every dataframe that begins with the word "ratings"
for (i in ls(pattern="ratings")){
  assign(i,mutate(get(i),game_id=1:nrow(get(i))))
}

# merge all dataframes that begin with the word "ratings" by the variable "game_id"
ratings<-Reduce(function(...) merge(...,by="game_id",all=TRUE),mget(ls(pattern="ratings")))
ratings<-ratings[order(ratings$game_id),]


# Define which ones you want to keep or drop to be the donor pool of players
# Keep only the first G rows of ratings
AllXData <- ratings[1:min(G, nrow(ratings)), , drop = FALSE]

####################################
# Preprocess the data
####################################
# Ensure Preprocess and PreprocessSubset handle the data correctly
processed.AllYData <- Preprocess(AllYData)
processed.AllXData <- Preprocess(AllXData)

TreatmentBeginsAt <- G-(G/8) # for our experiment here, we will look at how the model does after fitting the first 350 games
PostPeriodLength <- G - TreatmentBeginsAt + 1
PrePeriodLength <- TreatmentBeginsAt - 1
NumberInitialTimePeriods <- round((G / 2)) # Somewhat arbitrary, but make sure is a whole number and do not end up with negative number games anywhere
processed.AllYData <- PreprocessSubset(processed.AllYData,
                                       TreatmentBeginsAt,
                                       NumberInitialTimePeriods,
                                       PostPeriodLength,
                                       PrePeriodLength)


SCUL.input <- OrganizeDataAndSetup (
  time =  AllYData %>% select(game_id),
  y = AllYData %>% select(y),
  TreatmentBeginsAt = TreatmentBeginsAt,
  x.DonorPool = AllXData,
  CohensDThreshold = 0.25,
  NumberInitialTimePeriods = NumberInitialTimePeriods,
  TrainingPostPeriodLength = 25,
  x.PlaceboPool = AllXData,
  OutputFilePath=results_path
)

################################################################
# Run The SCUL Model
#################################################################
SCUL.output <- SCUL(plotCV==TRUE)
PlotActualvSCUL()
PlotShareTable()