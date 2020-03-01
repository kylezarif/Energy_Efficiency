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


head(eefm)