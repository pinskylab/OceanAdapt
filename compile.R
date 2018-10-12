# Answer the following questions to direct the actions of the script ====

# 1. Download the raw data from the source sites instead of OceanAdapt?
download <- "NO"

## Workspace setup ====
# This script works best when the repository is downloaded from github, 
# especially when that repository is loaded as a project into RStudio.
# The working directory is assumed to be the OceanAdapt directory of this repository.

# what is the working date of the update (what is the date of the folders, downloads)
library(tidyverse)

# Functions ====
download_ak <- function(region, ak_files){
  # define the destination folder
  for (i in seq(ak_files$survey)){
    # define the destination file path
    file <- paste("data_raw", ak_files$survey[i], sep = "/")
    # define the source url
    url <- paste("https://www.afsc.noaa.gov/RACE/groundfish/survey_data/downloads", ak_files$survey[i], sep = "/")
    # download the file from the url to the destination file path
    download.file(url,file)
    # unzip the new file - this will overwrite an existing file of the same name
    unzip(file, exdir = "data_raw")
    # delete the downloaded zip file
    file.remove(file)
  }
}


if (download == "YES"){
  

## Acquire new data ====
# We want the full dataset every single time, from the start of the survey through the most recent year. This helps catch any updates the surveys have made to past years (they sometimes catch and fix old errors). 

# Download AI ====
# 1. Visit website and confirm that the following list of files is complete. (cmd-click)
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
ai_files <- tibble(survey = c(
  "ai1983_2000.zip", 
  "ai2002_2012.zip",
  "ai2014_2016.zip"
))

# 2. Download the raw data from the website and copy over the strata file
download_ak("ai", ai_files)

# Download EBS ====
# 1. Visit website and confirm that the following list of files is complete. (cmd-click)
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
ebs_files <- tibble(survey = c(
  "ebs1982_1984.zip", 
  "ebs1985_1989.zip", 
  "ebs1990_1994.zip",
  "ebs1995_1999.zip",
  "ebs2000_2004.zip",
  "ebs2005_2008.zip",
  "ebs2009_2012.zip",
  "ebs2013_2016.zip",
  "ebs2017.zip" )
)

# 2. Download the raw data from the website and copy over the strata file
download_ak("ebs", ebs_files)

# Download GOA ====
# 1. Visit website and confirm that the following list of files is complete. (cmd-click)
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
goa_files <- tibble(survey = c(
  "goa1984_1987.zip",
  "goa1990_1999.zip",
  "goa2001_2005.zip",
  "goa2007_2013.zip",
  "goa2015_2017.zip"
)
)

# 2. Download the raw data from the website and copy over the strata file
download_ak("goa", goa_files)

# cleanup
rm(ai_files, ebs_files, goa_files, file, i)

# Download WCANN ====

haul_file_name <- "data_raw/wcann_haul.csv"

url_catch <- "https://www.nwfsc.noaa.gov/data/api/v1/source/trawl.catch_fact/selection.json?filters=project=Groundfish%20Slope%20and%20Shelf%20Combination%20Survey,date_dim$year>=2003"
data_catch <- jsonlite::fromJSON(url_catch)

###TAKES ~13 MINUTES ###

url_haul <- "https://www.nwfsc.noaa.gov/data/api/v1/source/trawl.operation_haul_fact/selection.json?filters=project=Groundfish%20Slope%20and%20Shelf%20Combination%20Survey,date_dim$year>=2003"
data_haul <- jsonlite::fromJSON(url_haul)

write_csv(data_catch, "data_raw/wcann_catch.csv")

write.csv(data_haul,  "data_raw/wcann_haul.csv")


# Download GMEX ====
# Have to go to the website (cmd+click) http://seamap.gsmfc.org/

# copy the file from the downloads folder into the current day's directory
file.copy(from = "~/Downloads/public_seamap_csvs/BGSREC.csv", to = "data_raw/gmex_BGSREC.csv", overwrite = T)
file.copy(from = "~/Downloads/public_seamap_csvs/CRUISES.csv", to = "data_raw/gmex_CRUISES.csv", overwrite = T)
file.copy(from = "~/Downloads/public_seamap_csvs/NEWBIOCODESBIG.csv", to = "data_raw/gmex_NEWBIOCODESBIG.csv", overwrite = T)
file.copy(from = "~/Downloads/public_seamap_csvs/STAREC.csv", to = "data_raw/gmex_STAREC.csv", overwrite = T)
file.copy(from = "~/Downloads/public_seamap_csvs/INVREC.csv", to = "data_raw/gmex_INVREC.csv", overwrite = T)



# Download NEUS ====
# Email Sean Lucey,  sean.lucey_at_noaa.gov , to get the latest survdata.RData file - Sean responded within an hour of emailing.

file.copy(from = "~/Downloads/Survdat.RData", to = "data_raw/neus_Survdat.Rdata", overwrite = T)


# Download SEUS ====
# The whack-a-mole site
# Download the data from the website (cmd+click):
# (https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports)
# In the "Type of Data" menu, you need 2 things: 
#   1. Event Information 
#   2. Abundance and Biomass
#         For the list of data values, click the |<- button on the right and it will move all of the values over to the left.
# * Note: It'll play whack-a-mole with you (meaning once you have moved fields to the left, they will pop back over to the right) … have fun! (If you don't encounter this annoyance, don't worry)

file.copy(from = "~/Downloads/pinsky", to = "data_raw/seus_catch.csv", overwrite = T)
file.copy(from = "~/Downloads/pinsky", to = "data_raw/seus_haul.csv", overwrite = T)
}

# Update Alaska ====
cols <- cols(
  LATITUDE = col_character(),
  LONGITUDE = col_character(),
  STATION = col_character(),
  STRATUM = col_character(),
  YEAR = col_character(),
  DATETIME = col_character(),
  WTCPUE = col_character(),
  NUMCPUE = col_character(),
  COMMON = col_character(),
  SCIENTIFIC = col_character(),
  SID = col_character(),
  BOT_DEPTH = col_character(),
  BOT_TEMP = col_character(),
  SURF_TEMP = col_character(),
  VESSEL = col_character(),
  CRUISE = col_character(),
  HAUL = col_character()
)
# Update AI ====
files <- list.files(path = "data_raw/", pattern = "ai")
# create blank table
ai_data <- tibble()
for (j in seq(files)){
  # if the file is not the strata file (which is assumed to not need correction)
  if(files[j] == "ai2014_2016.csv"){
    temp <- read_lines("data_raw/ai2014_2016.csv")
    temp_fixed <- stringr::str_replace_all(temp, "Stone et al., 2011", "Stone et al. 2011")
    write_lines(temp_fixed, "data_raw/ai2014_2016.csv")
  }
  if(!grepl("strata", files[j])){
    # read the csv
    temp <- read_csv(paste0("data_raw/", files[j]), col_types = cols)
    ai_data <- rbind(ai_data, temp)
  }else{
    ai_strata <- read_csv(paste0("data_raw/", files[j]))
  }
}
# it is ok if ai2014_2016.csv returns warnings for 4 rows where columns were not the number expected.  Those will be fixed below.  This is caused because there is a note for Stone et al, 2011 and the comma causes the line to parse strangely.

ai_data <- ai_data %>% 
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE")


# clean up
rm(files, temp, j, temp_fixed)

# Update EBS ====
files <- list.files(path = "data_raw/", pattern = "ebs")
# create blank table
ebs_data <- tibble()
for (j in seq(files)){
  if(!grepl("strata", files[j])){
    # read the csv
    temp <- read_csv(paste0("data_raw/", files[j]), col_types = cols)
    ebs_data <- rbind(ebs_data, temp)
  }else{
    ebs_strata <- read_csv(paste0("data_raw/", files[j]))
  }
}
ebs_data <- ebs_data %>% 
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE")


# clean up
rm(files, temp, j)


# Update GOA ====
files <- list.files(path = "data_raw/", pattern = "goa")
# create blank table
goa_data <- tibble()
for (j in seq(files)){
  if(!grepl("strata", files[j])){
    # read the csv
    temp <- read_csv(paste0("data_raw/", files[j]), col_types = cols)
    goa_data <- rbind(goa_data, temp)
  }else{
    goa_strata <- read_csv(paste0("data_raw/", files[j]))
  }
}

goa_data <- goa_data %>% 
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE")

# clean up
rm(files, temp, j)

# Update WCANN ====
# define the file we are looking for
target <- paste0("data_raw/wcann/", work_date)
# get the directory
dir <- list.dirs(target)
# list the files in that directory
files <- list.files(dir)
full_files <- list.files(dir, full.names = T)

catch <- read.csv(paste0(dir, "/wcann_catch.csv"), stringsAsFactors = F)
catch <- catch %>% 
  select("trawl_id","year","longitude_dd","latitude_dd","depth_m","scientific_name","total_catch_wt_kg","cpue_kg_per_ha_der")

haul <- read.csv(paste0(dir, "/wcann_haul.csv"), stringsAsFactors = F)
haul <- haul %>% 
  select("trawl_id","year","longitude_hi_prec_dd","latitude_hi_prec_dd","depth_hi_prec_m","area_swept_ha_der")

# this merge needs to be successful for complete_r_script to have a chance at working  
test <- merge(catch, haul, by=c("trawl_id","year"), all.x=TRUE, all.y=FALSE, allow.cartesian=TRUE) 

# Write files as .csv's
readr::write_csv(catch, path = "data_updates/Data_Updated/wcann_catch.csv")
readr::write_csv(haul, path = "data_updates/Data_Updated/wcann_haul.csv")  

print(paste0("completed WCANN"))

#clean up
rm(catch, data_catch, data_haul, haul, test, catch_file_name, dir, files, full_files, haul_file_name, old_names, save_date, target, url_catch, url_haul, wcann_save_loc)

# Update GMEX ====

# list the directory at that file path
dir <- list.dirs("data_raw")
# list the files within that directory
files <- list.files(dir)

bio <-read.csv(paste0(dir,"/BGSREC.csv"), stringsAsFactors = F) %>% 
  select(-INVRECID, -X)
readr::write_csv(bio, path = "data_updates/Data_Updated/gmex_bio.csv")

cruise <-read.csv(paste0(dir,"/CRUISES.csv"), stringsAsFactors = F) %>% 
  select(-X)
readr::write_csv(cruise, path = "data_updates/Data_Updated/gmex_cruise.csv")

spp <-read.csv(paste0(dir,"/NEWBIOCODESBIG.csv"), stringsAsFactors = F) %>% 
  select(-X, -tsn_accepted)
readr::write_csv(spp, path = "data_updates/Data_Updated/gmex_spp.csv")

gmexStation_raw <- readLines(paste0(dir,"/STAREC.csv"))
esc_patt <- "\\\\\\\""
esc_replace <- "\\\"\\\""
gmexStation_noEsc <- gsub(esc_patt, esc_replace, gmexStation_raw)
cat(gmexStation_noEsc, file="data_updates/Data_Updated/gmex_station.csv", sep="\n")

tow <-read.csv(paste0(dir,"/INVREC.csv"), stringsAsFactors = F) %>% 
  select(-X)
readr::write_csv(tow, path = "data_updates/Data_Updated/gmex_tow.csv")


print(paste0("completed gmex"))

# Update NEUS ====
target <- "data_raw"
# list the directory at that file path
dir <- list.dirs(target)
# list the files within that directory
files <- list.files(dir, full.names = T)

for (i in seq(files)){
  if (grepl("Survdat", files[i])){
    load(files[i])
  }
  if (grepl("SVSPP", files[i])){
    load(files[i])
  }
  if (grepl("strata", files[i])){
    file.copy(from=files[i], to=file.path("data_updates/Data_Updated/"), overwrite=TRUE)
  }
  if (grepl("svspp", files[i])){
    file.copy(from=files[i], to=file.path("data_updates/Data_Updated/"), overwrite=TRUE)
  }
}

# process or copy survey and spp files 

# Need to add a leading column named ""
survdat <- survdat %>% 
  mutate(X = NA) %>% 
  select(X, CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX, SVVESSEL, YEAR, SEASON, LAT, LON, DEPTH, SURFTEMP, SURFSALIN, BOTTEMP, BOTSALIN, ABUNDANCE, BIOMASS, LENGTH, NUMLEN)

# # rename the X-NA column as ""
# setnames(survdat, "X", "\"\"") 
# # wrap all column names in quotes
# setnames(survdat, names(survdat)[-1], wrap.quotes(names(survdat))[-1])

readr::write_csv(survdat, path = "data_updates/Data_Updated/neus_data.csv")


# repeat for spp file 
spp <- spp %>%
  # add a leading column 
  mutate(X = NA) %>% 
  select(X, everything())

# # rename the X-NA column as ""
# setnames(spp, "X", "\"\"") 
# # wrap all column names in quotes
# setnames(spp, names(spp), wrap.quotes(names(spp)))

readr::write_csv(spp, path = paste0("data_updates/Data_Updated/neus_svspp.csv"))


print(paste0("completed neus"))

#clean up
rm(spp, survdat, zipFiles, dir, files, i, lower, "data_raw", recentZip, strat, target, upper, zipdir)


