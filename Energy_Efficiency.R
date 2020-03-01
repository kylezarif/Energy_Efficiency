#################################
# Create eef set, validation set
#################################

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(data.table)) install.packages("data.table", repos = "http://cran.us.r-project.org")

# Energy Efficiency dataset:
# https://archive.ics.uci.edu/ml/machine-learning-databases/00242/
# https://archive.ics.uci.edu/ml/datasets/Energy+efficiency
# https://raw.githubusercontent.com/kylezarif/Energy_Efficiency/master/ENB2012_data.xlsx

url <- "https://raw.githubusercontent.com/kylezarif/Energy_Efficiency/master/ENB2012_data.xlsx"
eefm <- read.delim(url)

colnames(eefm) <- c("Relative_Compactness","Surface_Area","Wall_Area",
                    "Roof_Area", "Overall_Height", "Orientation", "Glazing_Area",
                    " Glazing_Area_Distribution", "Heating_Load", "Cooling_Load")

# Validation set will be 10% of dpp data
set.seed(1, sample.kind="Rounding")
# if using R 3.5 or earlier, use `set.seed(1)` instead
test_index <- createDataPartition(y = eefm$Heating_Load, times = 1, p = 0.1, list = FALSE)
ee <- eefm[-test_index,]
validation <- eefm[test_index,]


########################
#Load Required Libraries
########################
library(dslabs)
library(tidyverse)
library(caret)
library(lubridate)
library(purrr)
library(knitr)
library(dplyr)

##################
# Data Exploration
##################

# Dimensions of the dp set and test set and checking the variables
dim(ee)
dim(validation)
head(ee)
head(validation)

###################################################
# Dividing the dp data into training and test set
###################################################

set.seed(1, sample.kind="Rounding")
test_index <- createDataPartition(y = ee$Heating_Load, times = 1, p = 0.2, list = FALSE)
train_set <- ee[-test_index,]
test_set <- ee[test_index,]

dim(train_set)
dim(test_set)
