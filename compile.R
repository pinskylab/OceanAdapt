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

# Compile EBS ====
files <- list.files(path = "data_raw/", pattern = "ebs")
# create blank table
ebs_data <- tibble()
for (j in seq(files)){
  if(!grepl("strata", files[j])){
    # read the csv
    temp <- read_csv(paste0("data_raw/", files[j]), col_types = cols)
    ebs_data <- rbind(ebs_data, temp)
  }else{
    ebs_strata <- read_csv(paste0("data_raw/", files[j])) %>% 
      select(StratumCode, Areakm2) %>% 
      rename(STRATUM = StratumCode)
  }
}
ebs_data <- ebs_data %>% 
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE") %>% 
  mutate(STRATUM = as.integer(STRATUM))


ebs <- left_join(ebs_data, ebs_strata, by = "STRATUM")

# clean up
rm(files, temp, j, ebs_data, ebs_strata, temp)


# Compile GOA ====
files <- list.files(path = "data_raw/", pattern = "goa")
# create blank table
goa_data <- tibble()
for (j in seq(files)){
  if(!grepl("strata", files[j])){
    # read the csv
    temp <- read_csv(paste0("data_raw/", files[j]), col_types = cols)
    goa_data <- rbind(goa_data, temp)
  }else{
    goa_strata <- read_csv(paste0("data_raw/", files[j])) %>% 
      select(StratumCode, Areakm2) %>% 
      rename(STRATUM = StratumCode)
  }
}

goa_data <- goa_data %>% 
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE")%>% 
  mutate(STRATUM = as.integer(STRATUM))

goa <- left_join(goa_data, goa_strata, by = "STRATUM")

# clean up
rm(files, temp, j, cols, goa_data, goa_strata)

# Compile WCANN ====
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

wcann <- left_join(wcann_haul, wcann_catch, by = c("trawl_id", "year"))
  
# Compile GMEX ====
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
  select('CRUISEID', 'STATIONID', 'VESSEL', 'CRUISE_NO', 'P_STA_NO', 'GENUS_BGS', 'SPEC_BGS', 'BGSCODE', 'BIO_BGS', 'SELECT_BGS') %>% 
  # trim out young of year records (only useful for count data) and those with UNKNOWN species
  filter(BGSCODE != "T" & GENUS_BGS != "UNKNOWN") %>% 
  # remove the few rows that are still duplicates
  distinct()


# problems should be 0 obs
problems <- problems(gmex_bio) %>% 
  filter(!is.na(col))

gmex_cruise <-read_csv("data_raw/gmex_CRUISES.csv", col_types = cols(
  CRUISEID = col_integer(),
  YR = col_integer(),
  SOURCE = col_character(),
  VESSEL = col_integer(),
  CRUISE_NO = col_character(),
  STARTCRU = col_date(format = ""),
  ENDCRU = col_date(format = ""),
  TITLE = col_character(),
  NOTE = col_integer(),
  INGEST_SOURCE = col_character(),
  INGEST_PROGRAM_VER = col_character(),
  X12 = col_character()
)) %>% 
  select(CRUISEID, VESSEL, TITLE)

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
)) %>% 
  select('STATIONID', 'CRUISEID', 'CRUISE_NO', 'P_STA_NO', 'TIME_ZN', 'TIME_MIL', 'S_LATD', 'S_LATM', 'S_LOND', 'S_LONM', 'E_LATD', 'E_LATM', 'E_LOND', 'E_LONM', 'DEPTH_SSTA', 'MO_DAY_YR', 'VESSEL_SPD', 'COMSTAT')

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
  select('STATIONID', 'CRUISE_NO', 'P_STA_NO', 'INVRECID', 'GEAR_SIZE', 'GEAR_TYPE', 'MESH_SIZE', 'MIN_FISH', 'OP') %>% 
  filter(GEAR_TYPE=='ST')

problems <- problems(gmex_tow) %>% 
  filter(!is.na(col)) 
# 2 problems are that there are weird delimiters in the note column COMBIO, ignoring for now.

# make two combined records where multiple species records share the same species code
newspp <- tibble(
  Key1 = c(503,5770), 
  TAXONOMIC = c('ANTHIAS TENUIS AND WOODSI', 'MOLLUSCA AND UNID.OTHER #01'), 
  CODE = c(170026003, 300000000), 
  TAXONSIZECODE = NA, 
  isactive = -1, 
  common_name = c('threadnose and swallowtail bass', 'molluscs or unknown'), 
  tsn = NA) 

# remove the duplicates that were just combined  
gmex_spp <- gmex_spp %>% 
  distinct(CODE, .keep_all = T)
# add the combined records on to the end. trim out extra columns from gmexspp
gmex_spp <- rbind(gmex_spp, newspp) %>% 
  select(CODE, TAXONOMIC) %>% 
  rename(BIO_BGS = CODE)
  
# merge tow information with catch data, but only for shrimp trawl tows (ST)
gmex <- left_join(gmex_bio, gmex_tow, by = c("STATIONID", "CRUISE_NO", "P_STA_NO"))
# add station location and related data
gmex <- left_join(gmex, gmex_station, by = c("CRUISEID", "STATIONID", "CRUISE_NO", "P_STA_NO"))
# add scientific name
gmex <- left_join(gmex, gmex_spp, by = "BIO_BGS")
# add cruise title
gmex <- left_join(gmex, gmex_cruise, by = c("CRUISEID", "VESSEL"))

# Trim to high quality SEAMAP summer trawls, based off the subset used by Jeff Rester's GS_TRAWL_05232011.sas
gmex <- gmex %>% 
  filter(grepl("Summer", TITLE) & 
           GEAR_SIZE == 40 & 
           MESH_SIZE == 1.63 &
           # OP has no letter value
           !grepl("[A-Z]", OP))


# Compile NEUS ====
load("data_raw/neus_Survdat.RData")
load("data_raw/neus_SVSPP.RData")

neus_survdat <- survdat %>% 
  # select specific columns
  select(CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX, SVVESSEL, YEAR, SEASON, LAT, LON, DEPTH, SURFTEMP, SURFSALIN, BOTTEMP, BOTSALIN, ABUNDANCE, BIOMASS) %>% 
  # remove duplicates
  distinct() 
  
# sum different sexes of same spp together
neus_bio <- neus_survdat %>% 
  group_by(YEAR, SEASON, LAT, LON, DEPTH, CRUISE6, STATION, STRATUM, SVSPP) %>% 
  summarise(BIOMASS = sum(BIOMASS)) 
neus_survdat <- left_join(select(neus_survdat, -BIOMASS), neus_bio, by = c("CRUISE6", "STATION", "STRATUM", "SVSPP", "YEAR", "SEASON", "LAT", "LON", "DEPTH"))
rm(neus_bio)

# repeat for spp file 
neus_spp <- spp %>%
  select(-ITISSPP, -COMNAME, -AUTHOR)

# remove some columns from spp data.table
neus_strata <- read_csv("data_raw/neus_strata.csv") %>% 
  select(StratumCode, Areanmi2) %>% 
  rename(STRATUM = StratumCode)

neus <- left_join(neus_survdat, spp, by = "SVSPP")
neus <- left_join(neus, neus_strata, by = "STRATUM")

neusS <- neus %>% 
  filter(SEASON == "SPRING")

neusF <- neus %>% 
  filter(SEASON == "FALL")

# Compile WCTRI ====
wctri_catch <- read_csv("data_raw/wctri_catch.csv", col_types = cols(
  CRUISEJOIN = col_integer(),
  HAULJOIN = col_integer(),
  CATCHJOIN = col_integer(),
  REGION = col_character(),
  VESSEL = col_integer(),
  CRUISE = col_integer(),
  HAUL = col_integer(),
  SPECIES_CODE = col_integer(),
  WEIGHT = col_double(),
  NUMBER_FISH = col_integer(),
  SUBSAMPLE_CODE = col_character(),
  VOUCHER = col_character(),
  AUDITJOIN = col_integer()
)) %>% 
  select('CRUISEJOIN', 'HAULJOIN', 'VESSEL', 'CRUISE', 'HAUL', 'SPECIES_CODE', 'WEIGHT')
  
wctri_haul <- read_csv("data_raw/wctri_haul.csv", col_types = 
                         cols(
                           CRUISEJOIN = col_integer(),
                           HAULJOIN = col_integer(),
                           REGION = col_character(),
                           VESSEL = col_integer(),
                           CRUISE = col_integer(),
                           HAUL = col_integer(),
                           HAUL_TYPE = col_integer(),
                           PERFORMANCE = col_double(),
                           START_TIME = col_character(),
                           DURATION = col_double(),
                           DISTANCE_FISHED = col_double(),
                           NET_WIDTH = col_double(),
                           NET_MEASURED = col_character(),
                           NET_HEIGHT = col_double(),
                           STRATUM = col_integer(),
                           START_LATITUDE = col_double(),
                           END_LATITUDE = col_double(),
                           START_LONGITUDE = col_double(),
                           END_LONGITUDE = col_double(),
                           STATIONID = col_character(),
                           GEAR_DEPTH = col_integer(),
                           BOTTOM_DEPTH = col_integer(),
                           BOTTOM_TYPE = col_integer(),
                           SURFACE_TEMPERATURE = col_double(),
                           GEAR_TEMPERATURE = col_double(),
                           WIRE_LENGTH = col_integer(),
                           GEAR = col_integer(),
                           ACCESSORIES = col_integer(),
                           SUBSAMPLE = col_integer(),
                           AUDITJOIN = col_integer()
                         )) %>% 
  select('CRUISEJOIN', 'HAULJOIN', 'VESSEL', 'CRUISE', 'HAUL', 'HAUL_TYPE', 'PERFORMANCE', 'START_TIME', 'DURATION', 'DISTANCE_FISHED', 'NET_WIDTH', 'STRATUM', 'START_LATITUDE', 'END_LATITUDE', 'START_LONGITUDE', 'END_LONGITUDE', 'STATIONID', 'BOTTOM_DEPTH')

wctri_species <- read_csv("data_raw/wctri_species.csv", col_types = cols(
  SPECIES_CODE = col_integer(),
  SPECIES_NAME = col_character(),
  COMMON_NAME = col_character(),
  REVISION = col_character(),
  BS = col_character(),
  GOA = col_character(),
  WC = col_character(),
  AUDITJOIN = col_integer()
)) %>% 
  select('SPECIES_CODE', 'SPECIES_NAME', 'COMMON_NAME')
  
# Add haul info to catch data
wctri <- left_join(wctri_catch, wctri_haul, by = c("CRUISEJOIN", "HAULJOIN", "VESSEL", "CRUISE", "HAUL"))
#  add species names
wctri <- left_join(wctri, wctri_species, by = "SPECIES_CODE")

# trim to standard hauls and good performance
wctri <- wctri %>% 
  filter(HAUL_TYPE == 3 & PERFORMANCE == 0)

rm(wctri_catch, wctri_haul, wctri_species)

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

