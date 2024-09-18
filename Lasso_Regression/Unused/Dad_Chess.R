#https://hollina.github.io/scul/articles/scul-tutorial.html
#https://github.com/hollina/scul 
#Install scul from github
if (!require("devtools")) install.packages("devtools")
devtools::install_github("hollina/scul")
devtools::install_local("C:/Users/rossadr0/Downloads/scul-master.zip")

# Load the libraries

library(scul)
library(foreign) # for reading in stata datasets
library(readxl)
library(dplyr)
library(ggplot2)


main_path<-"C:/Users/rossadr0/Downloads/pgn_work/my csv files"
results_path<-paste(main_path,"/my csv files/",sep="")

############################################################
# Create a imaginary player that has played G games
G=400
game_id<-seq(1,G,1)

# generate a list of 100 random integers between -100 and +100
random_integers<-sample(-8:8,G,replace=TRUE)
y <- 800+random_integers+2*game_id

# Define this imaginary player as the player you want to predict
AllYData<- data.frame(game_id, y)

#################################################################

##############################################################
# Get the data on existing chess players
###########################################################

# Import all csv files in the folder path "data"
files<-list.files(main_path,pattern="*.csv",full.names=TRUE)
print(files)

for (i in 1:length(files)){
  assign(gsub(".csv","",basename(files[i])),read.csv(files[i]))
}

# create a running count of games played in every dataframe that begins with the word "ratings"
for (i in ls(pattern="ratings")){
  assign(i,mutate(get(i),game_id=1:nrow(get(i))))
}

# drop the variable date from all dataframes that begin with the word "ratings"
for (i in ls(pattern="ratings")){
  assign(i,select(get(i),-date))
}

# merge all dataframes that begin with the word "ratings" by the variable "game_id"
ratings<-Reduce(function(...) merge(...,by="game_id",all=TRUE),mget(ls(pattern="ratings")))
ratings<-ratings[order(ratings$game_id),]

# Define which ones you want to keep or drop to be the donor pool of players
# keep only the first G rows of ratings
AllXData<-ratings[1:length(AllYData),]

####################################
#Preprocess the data
####################################
processed.AllYData <- Preprocess(AllYData)
processed.AllXData <- Preprocess(AllXData)

TreatmentBeginsAt <- 350 # for our experiment here, we will look at how the model does after fitting the first 350 games
PostPeriodLength <- nrow(processed.AllYData) - TreatmentBeginsAt + 1
PrePeriodLength <- TreatmentBeginsAt-1
NumberInitialTimePeriods <- (G/2) #Somewhat arbitrary, but make sure is a whole number
processed.AllYData <- PreprocessSubset(processed.AllYData,
                                       TreatmentBeginsAt ,
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
# RUn The SCUL Model
#################################################################
SCUL.output <- SCUL(plotCV==TRUE)
PlotActualvSCUL()
PlotShareTable()