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

catch_file_name <- "data_raw/wcann_catch.csv"
haul_file_name <- "data_raw/wcann_haul.csv"

url_catch <- "https://www.nwfsc.noaa.gov/data/api/v1/source/trawl.catch_fact/selection.json?filters=project=Groundfish%20Slope%20and%20Shelf%20Combination%20Survey,date_dim$year>=2003"
data_catch <- jsonlite::fromJSON( url_catch )

download.file(url_catch, catch_file_name)

url_haul <- "https://www.nwfsc.noaa.gov/data/api/v1/source/trawl.operation_haul_fact/selection.json?filters=project=Groundfish%20Slope%20and%20Shelf%20Combination%20Survey,date_dim$year>=2003"
data_haul <- jsonlite::fromJSON( url_haul )

if(!dir.exists(file.path(wcann_save_loc, save_date))){
  dir.create(file.path(wcann_save_loc, save_date))
}

write.csv(data_catch, file=file.path(wcann_save_loc, save_date, catch_file_name), row.names=FALSE)
write.csv(data_haul, file=file.path(wcann_save_loc, save_date, haul_file_name), row.names=FALSE)

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

# Download GMEX ====
# Have to go to the website (cmd+click) http://seamap.gsmfc.org/

# copy the file from the downloads folder into the current day's directory
file.copy(from = "~/Downloads/public_seamap_csvs/BGSREC.csv", to = "data_raw")
file.copy(from = "~/Downloads/public_seamap_csvs/CRUISES.csv", to = "data_raw")
file.copy(from = "~/Downloads/public_seamap_csvs/NEWBIOCODESBIG.csv", to = "data_raw")
file.copy(from = "~/Downloads/public_seamap_csvs/STAREC.csv", to = "data_raw")
file.copy(from = "~/Downloads/public_seamap_csvs/INVREC.csv", to = "data_raw")

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

# Download NEUS ====
# Email Sean Lucey,  sean.lucey@noaa.gov , to get the latest survdata.RData file - Sean responded within an hour of emailing.

file.copy(from = "~/Downloads/Survdat.RData", to = "data_raw")

#Unzip the most recent zip and copy over the strata file.

# list all of the zip files for this region
zipFiles <- file.info(list.files(paste0("data_raw/neus"), full=TRUE, patt=".zip"))

# define the most recent zip file
recentZip <- row.names(zipFiles[order(zipFiles$mtime, zipFiles$ctime, zipFiles$atime, decreasing=TRUE)[1], ])

# define a temporary space to unzip the file
zipdir <- tempfile()# Create a name for the dir where we'll unzip

# create the temporary space
dir.create(zipdir)# Create the dir using that name

# unzip the file into that temp space
unzip(recentZip, exdir=zipdir)# Unzip the file into the dir

# list any files that contain strata in the name
strat<- list.files(zipdir, recursive = T, pattern = "strata", full = T)

# get the other data files
lower <- list.files(zipdir, recursive = T, pattern = "svspp", full = T)
upper <- list.files(zipdir, recursive = T, pattern = "SVSPP", full = T)

# copy over the strat file
file.copy(from=strat, to="data_raw")
# copy over spp files
file.copy(from=lower, to="data_raw")
file.copy(from=upper, to="data_raw")


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

# Download SEUS ====
# The whack-a-mole site
# Download the data from the website (cmd+click):
# (https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports)
# In the "Type of Data" menu, you need 2 things: 
#   1. Event Information 
#   2. Abundance and Biomass
#         For the list of data values, click the |<- button on the right and it will move all of the values over to the left.
# * Note: It'll play whack-a-mole with you (meaning once you have moved fields to the left, they will pop back over to the right) … have fun! (If you don't encounter this annoyance, don't worry)



# Update Alaska ====
# munge the regional Alaska data into one table per region and save to the Data_Updated directory
dirs <- c("ai", "goa", "ebs")


# create the destination folder
dir.create(file.path("data_updates/Data_Updated/"))

for (i in seq(dirs)){
  # define file path
  target <- paste0("data_raw/", dirs[i], "/", work_date)
  # list the directory at that file path
  dir <- list.dirs(target)
  # list the files within that directory
  files <- list.files(dir)
  # files <- list.files(dir, full = T) # don't need full names?
  
  # create blank table
  dat <- tibble()
  for (j in seq(files)){
    # if the file is not the strata file (which is assumed to not need correction)
    if(!grepl("strata", files[j])){
      # read the csv
      temp2 <- read.csv(paste0(dir,"/", files[j]), stringsAsFactors = F)
      # remove any data rows that have the value "LATITUDE" as data
      temp2 <- filter(temp2, LATITUDE != "LATITUDE", 
        # remove any data rows that are blank for LONGITUDE (blank data row)
        !is.na(LONGITUDE))
      dat <- rbind(dat, temp2)
    }else{
      file.copy(from=paste0(dir,"/", files[j]), to=file.path("data_updates/Data_Updated/"), overwrite=TRUE)
      
    }
  }
  readr::write_csv(dat, path = paste0("data_updates/Data_Updated/", dirs[i], "_data.csv"))
  
  
  print(paste0("completed ", dirs[i]))
}

# clean up
rm(ai_files, dat, ebs_files, goa_files, temp2, dir, dirs, files, i, j, "data_raw", target)

