# The complete_r_script, updated to do all munging in one file, replaceing the data_update.R, updateOA.R, and get_wcann.R scripts.

# Workspace setup ####
# This script works best when the repository is downloaded from github, 
# especially when that repository is loaded as a project into RStudio.
# The working directory is assumed to be the OceanAdapt directory of this.

library(tidyverse)

# Functions ####
download_ak <- function(region, ak_files){
  # define the destination folder
  new_dir <- file.path(paste0("data_raw/", region, "/", Sys.Date()))
  # create the destination folder
  dir.create(new_dir)
  for (i in seq(ak_files$survey)){
    # define the destination file path
    file <- paste(new_dir, ak_files$survey[i], sep = "/")
    # define the source url
    url <- paste("https://www.afsc.noaa.gov/RACE/groundfish/survey_data/downloads", ak_files$survey[i], sep = "/")
    # download the file from the url to the destination file path
    download.file(url,file)
    # unzip the new file
    unzip(file, exdir = new_dir)
    # delete the downloaded zip file
    file.remove(file)
  }
}

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
  # add canada region here
))

# Download AI ####
# 1. Visit website and confirm that the following list of files is complete. (cmd-click)
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
ai_files <- tibble(survey = c(
  "ai1983_2000.zip", 
  "ai2002_2012.zip",
  "ai2014_2016.zip"
))

# 2. Download the raw data from the website
download_ak(region, ai_files)

# 3. Unzip the most recent zip and copy over the strata file.

