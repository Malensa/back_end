###################################################################################################
# Author: Matija Zver, Sarah Ion  
# Project: Food project
# File: init__.R
# Description: project initialisation
###################################################################################################
# Input: config.R
# Output: front end running logic
###################################################################################################

# sourcing necessary files ----
source("src/config.R")
source("src/score.R")

# install necessary packages --- it would be better to create a function
library(plumber)

# running the back-end (APIs) ---
r <- plumb("src/score.R")
# Where 'plumber.R' is the location of the file shown above

# Run r on port 8000
r$run(host = "0.0.0.0",  port = 8080)
