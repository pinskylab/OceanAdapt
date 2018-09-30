# This script is intended to take unzipped raw files from download sites and produce website ready files



## Make sure that all files have been downloaded from icloud ####




# Setup ----
library(dplyr)
library(data.table)
library(rbLib) # library(devtools); install_github("rBatt/rbLib")
library(bit64)
library(stringr)

#### in testing ####
# What is the date of the downloaded raw data files ----
params <- tibble(date = "2018-09-19")

# MAKE SURE YOU HAVE MANUALLY CREATED THE DATA_UPDATED FOLDER

# The working directory throughout this process is OceanAdapt so that anyone who clones the repository can use the code regardless of higher level file structure.

# Fix & Update alaska ----
source("R/update_alaska.R")

# Update gmex ----
source("R/update_gmex.R")

# Update neus ----
source("R/update_neus.R")

# Update seus ----
source("R/update_seus.R")


# Update wcann ----
source("R/update_wcann.R")


# Update wctri ----
source("R/update_wctri.R")

# = Copy Taxonomy =====
file.copy(from="data_raw/taxonomy/spptaxonomy.csv", to="data_updates/Data_Updated", overwrite=TRUE)
