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

# Compile AI ====
files <- list.files(path = "data_raw/", pattern = "ai")
# create blank table
ai_data <- tibble()
for (j in seq(files)){
  # if the file is not the strata file (which is assumed to not need correction)
  if(files[j] == "ai2014_2016.csv"){
    temp <- read_lines("data_raw/ai2014_2016.csv")
    temp_fixed <- stringr::str_replace_all(temp, "Stone et al., 2011", "Stone et al. 2011")
    write_lines(temp_fixed, "temporary.csv")
    temp <- read_csv("temporary.csv", col_types = cols)
    ai_data <- rbind(ai_data, temp)
  }
  if(!grepl("strata", files[j]) & !grepl("ai2014", files[j])){
    # read the csv
    temp <- read_csv(paste0("data_raw/", files[j]), col_types = cols)
    ai_data <- rbind(ai_data, temp)
  }
  if(files[j] == "ai_strata.csv"){
    ai_strata <- read_csv(paste0("data_raw/", files[j]))
    ai_strata <- ai_strata %>% 
      select(StratumCode, Areakm2) %>% 
      rename(STRATUM = StratumCode)
  }
}

ai_data <- ai_data %>% 
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE") %>% 
  mutate(STRATUM = as.integer(STRATUM))

ai <- left_join(ai_data, ai_strata, by = "STRATUM")


# clean up
rm(files, temp, j, temp_fixed, ai_data, ai_strata)

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
rm(files, temp, j, cols)

# Update WCANN ====
wcann_catch <- read_csv("data_raw/wcann_catch.csv", col_types = cols(
  catch_id = col_integer(),
  common_name = col_character(),
  cpue_kg_per_ha_der = col_double(),
  cpue_numbers_per_ha_der = col_double(),
  date_yyyymmdd = col_integer(),
  depth_m = col_double(),
  latitude_dd = col_double(),
  longitude_dd = col_double(),
  pacfin_spid = col_character(),
  partition = col_character(),
  performance = col_character(),
  program = col_character(),
  project = col_character(),
  sampling_end_hhmmss = col_character(),
  sampling_start_hhmmss = col_character(),
  scientific_name = col_character(),
  station_code = col_double(),
  subsample_count = col_integer(),
  subsample_wt_kg = col_double(),
  total_catch_numbers = col_integer(),
  total_catch_wt_kg = col_double(),
  tow_end_timestamp = col_datetime(format = ""),
  tow_start_timestamp = col_datetime(format = ""),
  trawl_id = col_double(),
  vessel = col_character(),
  vessel_id = col_integer(),
  year = col_integer(),
  year_stn_invalid = col_integer()
)) %>% 
  select("trawl_id","year","longitude_dd","latitude_dd","depth_m","scientific_name","total_catch_wt_kg","cpue_kg_per_ha_der")

wcann_haul <- read_csv("data_raw/wcann_haul.csv", col_types = cols(
  area_swept_ha_der = col_double(),
  date_yyyymmdd = col_integer(),
  depth_hi_prec_m = col_double(),
  invertebrate_weight_kg = col_double(),
  latitude_hi_prec_dd = col_double(),
  longitude_hi_prec_dd = col_double(),
  mean_seafloor_dep_position_type = col_character(),
  midtow_position_type = col_character(),
  nonspecific_organics_weight_kg = col_double(),
  performance = col_character(),
  program = col_character(),
  project = col_character(),
  sample_duration_hr_der = col_double(),
  sampling_end_hhmmss = col_character(),
  sampling_start_hhmmss = col_character(),
  station_code = col_double(),
  tow_end_timestamp = col_datetime(format = ""),
  tow_start_timestamp = col_datetime(format = ""),
  trawl_id = col_double(),
  vertebrate_weight_kg = col_double(),
  vessel = col_character(),
  vessel_id = col_integer(),
  year = col_integer(),
  year_stn_invalid = col_integer()
)) %>% 
  select("trawl_id","year","longitude_hi_prec_dd","latitude_hi_prec_dd","depth_hi_prec_m","area_swept_ha_der")

# this merge needs to be successful for complete_r_script to have a chance at working  
test <- merge(wcann_catch, wcann_haul, by=c("trawl_id","year"), all.x=TRUE, all.y=FALSE, allow.cartesian=TRUE) 

# clean up
rm(test)

# Update GMEX ====
gmex_bio <-read_csv("data_raw/gmex_BGSREC.csv", col_types = cols(
  BGSID = col_integer(),
  CRUISEID = col_integer(),
  STATIONID = col_integer(),
  VESSEL = col_integer(),
  CRUISE_NO = col_integer(),
  P_STA_NO = col_character(),
  CATEGORY = col_integer(),
  GENUS_BGS = col_character(),
  SPEC_BGS = col_character(),
  BGSCODE = col_character(),
  CNT = col_integer(),
  CNTEXP = col_integer(),
  SAMPLE_BGS = col_double(),
  SELECT_BGS = col_double(),
  BIO_BGS = col_integer(),
  NODC_BGS = col_integer(),
  IS_SAMPLE = col_character(),
  TAXONID = col_character(),
  INVRECID = col_character(),
  X20 = col_character()
)) %>% 
  select(-INVRECID, -X20)

# problems should be 0 obs
problems <- problems(gmex_bio) %>% 
  filter(!is.na(col))

gmex_cruise <-read_csv("data_raw/gmex_CRUISES.csv", col_types = cols(
  CRUISEID = col_integer(),
  YR = col_integer(),
  SOURCE = col_character(),
  VESSEL = col_character(),
  CRUISE_NO = col_character(),
  STARTCRU = col_date(format = ""),
  ENDCRU = col_date(format = ""),
  TITLE = col_character(),
  NOTE = col_integer(),
  INGEST_SOURCE = col_character(),
  INGEST_PROGRAM_VER = col_character(),
  X12 = col_character()
)) %>% 
  select(-X12)

# problems should be 0 obs
problems <- problems(gmex_cruise) %>% 
  filter(!is.na(col))


gmex_spp <-read_csv("data_raw/gmex_NEWBIOCODESBIG.csv", col_types = cols(
  Key1 = col_integer(),
  TAXONOMIC = col_character(),
  CODE = col_integer(),
  TAXONSIZECODE = col_character(),
  isactive = col_integer(),
  common_name = col_character(),
  tsn = col_integer(),
  tsn_accepted = col_integer(),
  X9 = col_character()
)) %>% 
  select(-X9, -tsn_accepted)

# problems should be 0 obs
problems <- problems(gmex_cruise) %>% 
  filter(!is.na(col))

gmex_station_raw <- read_lines("data_raw/gmex_STAREC.csv")
gmex_station_clean <- str_replace_all(gmex_station_raw, "\\\\\\\"", "\\\"\\\"")
write_lines(gmex_station_clean, "temporary.csv")
gmex_station <- read_csv("temporary.csv", col_types = cols(
  STATIONID = col_integer(),
  CRUISEID = col_integer(),
  VESSEL = col_character(),
  CRUISE_NO = col_integer(),
  P_STA_NO = col_character(),
  TIME_ZN = col_integer(),
  TIME_MIL = col_character(),
  S_LATD = col_integer(),
  S_LATM = col_double(),
  S_LATH = col_character(),
  S_LOND = col_integer(),
  S_LONM = col_double(),
  S_LONH = col_character(),
  DEPTH_SSTA = col_double(),
  S_STA_NO = col_character(),
  MO_DAY_YR = col_date(format = ""),
  TIME_EMIL = col_character(),
  E_LATD = col_integer(),
  E_LATM = col_double(),
  E_LATH = col_character(),
  E_LOND = col_integer(),
  E_LONM = col_double(),
  E_LONH = col_character(),
  DEPTH_ESTA = col_double(),
  GEARS = col_character(),
  TEMP_SSURF = col_double(),
  TEMP_BOT = col_double(),
  TEMP_SAIR = col_double(),
  B_PRSSR = col_double(),
  WIND_SPD = col_double(),
  WIND_DIR = col_double(),
  WAVE_HT = col_double(),
  SEA_COND = col_integer(),
  DBTYPE = col_character(),
  DATA_CODE = col_character(),
  VESSEL_SPD = col_double(),
  FAUN_ZONE = col_integer(),
  STAT_ZONE = col_integer(),
  TOW_NO = col_integer(),
  NET_NO = col_integer(),
  COMSTAT = col_character(),
  DECSLAT = col_double(),
  DECSLON = col_double(),
  DECELAT = col_double(),
  DECELON = col_double(),
  START_DATE = col_datetime(format = ""),
  END_DATE = col_datetime(format = ""),
  HAULVALUE = col_character(),
  X49 = col_character()
))

problems <- problems(gmex_station) %>% 
  filter(!is.na(col))

gmex_tow <-read_csv("data_raw/gmex_INVREC.csv", col_types = cols(
  INVRECID = col_integer(),
  STATIONID = col_integer(),
  CRUISEID = col_integer(),
  VESSEL = col_integer(),
  CRUISE_NO = col_integer(),
  P_STA_NO = col_character(),
  GEAR_SIZE = col_integer(),
  GEAR_TYPE = col_character(),
  MESH_SIZE = col_double(),
  OP = col_character(),
  MIN_FISH = col_integer(),
  WBCOLOR = col_character(),
  BOT_TYPE = col_character(),
  BOT_REG = col_character(),
  TOT_LIVE = col_double(),
  FIN_CATCH = col_double(),
  CRUS_CATCH = col_double(),
  OTHR_CATCH = col_double(),
  T_SAMPLEWT = col_double(),
  T_SELECTWT = col_double(),
  FIN_SMP_WT = col_double(),
  FIN_SEL_WT = col_double(),
  CRU_SMP_WT = col_double(),
  CRU_SEL_WT = col_double(),
  OTH_SMP_WT = col_double(),
  OTH_SEL_WT = col_double(),
  COMBIO = col_character(),
  X28 = col_character()
)) %>% 
  select(-X28)

problems <- problems(gmex_tow) %>% 
  filter(!is.na(col)) # 2 problems are that there are weird delimiters in the note column COMBIO, ignoring for now.


# Update NEUS ====
load("data_raw/neus_Survdat.RData")
load("data_raw/neus_SVSPP.RData")

# Need to add a leading column named ""
survdat <- survdat %>% 
  mutate(X = NA) %>% 
  select(X, CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX, SVVESSEL, YEAR, SEASON, LAT, LON, DEPTH, SURFTEMP, SURFSALIN, BOTTEMP, BOTSALIN, ABUNDANCE, BIOMASS, LENGTH, NUMLEN)


# repeat for spp file 
spp <- spp %>%
  # add a leading column 
  mutate(X = NA) %>% 
  select(X, everything())

# compile TAX ====
tax <- read_csv("data_raw/spptaxonomy.csv", col_types = cols(
  taxon = col_character(),
  species = col_character(),
  genus = col_character(),
  family = col_character(),
  order = col_character(),
  class = col_character(),
  superclass = col_character(),
  subphylum = col_character(),
  phylum = col_character(),
  kingdom = col_character(),
  name = col_character(),
  common = col_character()
))

