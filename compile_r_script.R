# The complete_r_script, updated to do all munging in one file, replaceing the data_update.R, updateOA.R, and get_wcann.R scripts.

# setup ####
library(tidyverse)

# Define Regions of Interest ####
raw_regions <- tibble(region = c(
    "ai", #(Aleutian Islands) 
  "ebs", #(Eastern Bering Sea)
  "gmex", #(Gulf of Mexico)
"goa", #(Gulf of Alaska)
  "neus", #(Northeast US)
  "seus", #(Southeast US)
  "taxonomy", #(not a region/ survey, but this folder should exist)
  "wcann", #(West Coast Annual)
  "wctri" #(West Coast Triennial)
))


  
