# Answer the following questions using all caps TRUE or FALSE to direct the actions of the script ====

# 1. Download the raw data from the source sites instead of OceanAdapt?
download <- FALSE

# 2. Some strata and years have very little data, should they be removed? #DEFAULT: TRUE. 
HQ_DATA_ONLY <- TRUE 

# 3. #DEFAULT: FALSE Remove ai,ebs,gmex,goa,neus,wcann,wctri. Keep `dat`
REMOVE_REGION_DATASETS <- FALSE 

# 4. #OPTIONAL, DEFAULT:FALSE, creates graphs based on the data like shown on the website and outputs them to pdf.
OPTIONAL_PLOT_CHARTS = FALSE 

# 5. #OPTIONAL, DEFAULT:FALSE, Outputs the dat into an rdata file
OPTIONAL_OUTPUT_DAT_MASTER_TABLE = FALSE 


## Workspace setup ====
# This script works best when the repository is downloaded from github, 
# especially when that repository is loaded as a project into RStudio.
# The working directory is assumed to be the OceanAdapt directory of this repository.

# what is the working date of the update (what is the date of the folders, downloads)
library(tidyverse)
library(lubridate)

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


if (download == TRUE){
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
    ai_strata <- read_csv(paste0("data_raw/", files[j]), col_types = cols(
      NPFMCArea = col_character(),
      SubareaDescription = col_character(),
      StratumCode = col_integer(),
      DepthIntervalm = col_character(),
      Areakm2 = col_integer()
    ))
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

# Create a unique haulid
ai <- ai %>% 
  mutate(haulid = paste(formatC(VESSEL, width=3, flag=0), formatC(CRUISE, width=3, flag=0), formatC(HAUL, width=3, flag=0), sep='-'))

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
    ebs_strata <- read_csv(paste0("data_raw/", files[j]), col_types = cols(
      SubareaDescription = col_character(),
      StratumCode = col_integer(),
      Areakm2 = col_integer()
    )) %>% 
      select(StratumCode, Areakm2) %>% 
      rename(STRATUM = StratumCode)
  }
}
ebs_data <- ebs_data %>% 
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE") %>% 
  mutate(STRATUM = as.integer(STRATUM))


ebs <- left_join(ebs_data, ebs_strata, by = "STRATUM")

# Create a unique haulid
ebs <- ebs %>% 
  mutate(
    haulid = paste(formatC(VESSEL, width=3, flag=0), formatC(CRUISE, width=3, flag=0), formatC(HAUL, width=3, flag=0), sep='-')    
  )


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
    goa_strata <- read_csv(paste0("data_raw/", files[j]), col_types = cols(
      SubareaDescription = col_character(),
      StratumCode = col_integer(),
      DepthIntervalm = col_character(),
      Areakm2 = col_integer()
    )) %>% 
      select(StratumCode, Areakm2) %>% 
      rename(STRATUM = StratumCode)
  }
}

goa_data <- goa_data %>% 
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE")%>% 
  mutate(STRATUM = as.integer(STRATUM))

goa <- left_join(goa_data, goa_strata, by = "STRATUM")

# Create a unique haulid
goa <- goa %>%
  mutate(
    haulid = paste(formatC(VESSEL, width=3, flag=0), formatC(CRUISE, width=3, flag=0), formatC(HAUL, width=3, flag=0), sep='-')    
  )
  


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
wcann <- wcann %>% 
  mutate(
    haulid = trawl_id,
    # Add "strata" (define by lat, lon and depth bands) where needed
    # no need to use lon grids on west coast (so narrow)
    stratum = paste(floor(latitude_dd)+0.5, floor(depth_m/100)*100 + 50, sep= "-")
    )

# cleanup
rm(wcann_catch, wcann_haul)

# Compile GMEX ====
gmex_bio <-read_csv("data_raw/gmex_BGSREC.csv", col_types = cols(.default = col_character())) %>% 
  select('CRUISEID', 'STATIONID', 'VESSEL', 'CRUISE_NO', 'P_STA_NO', 'GENUS_BGS', 'SPEC_BGS', 'BGSCODE', 'BIO_BGS', 'SELECT_BGS') %>% 
  # trim out young of year records (only useful for count data) and those with UNKNOWN species
  filter(BGSCODE != "T" & GENUS_BGS != "UNKNOWN") %>% 
  # remove the few rows that are still duplicates
  distinct()

# problems should be 0 obs
problems <- problems(gmex_bio) %>% 
  filter(!is.na(col))

gmex_bio <- type_convert(gmex_bio, cols(
  CRUISEID = col_integer(),
  STATIONID = col_integer(),
  VESSEL = col_integer(),
  CRUISE_NO = col_integer(),
  P_STA_NO = col_character(),
  GENUS_BGS = col_character(),
  SPEC_BGS = col_character(),
  BGSCODE = col_character(),
  BIO_BGS = col_integer(),
  SELECT_BGS = col_double()
))

gmex_cruise <-read_csv("data_raw/gmex_CRUISES.csv", col_types = cols(.default = col_character())) %>% 
  select(CRUISEID, VESSEL, TITLE)

# problems should be 0 obs
problems <- problems(gmex_cruise) %>% 
  filter(!is.na(col))

gmex_cruise <- type_convert(gmex_cruise, col_types = cols(CRUISEID = col_integer(), VESSEL = col_character(), TITLE = col_character()))

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
gmex_station <- read_csv("temporary.csv", col_types = cols(.default = col_character())) %>% 
  select('STATIONID', 'CRUISEID', 'CRUISE_NO', 'P_STA_NO', 'TIME_ZN', 'TIME_MIL', 'S_LATD', 'S_LATM', 'S_LOND', 'S_LONM', 'E_LATD', 'E_LATM', 'E_LOND', 'E_LONM', 'DEPTH_SSTA', 'MO_DAY_YR', 'VESSEL_SPD', 'COMSTAT')

problems <- problems(gmex_station) %>% 
  filter(!is.na(col))

gmex_station <- type_convert(gmex_station, col_types = cols(
  STATIONID = col_integer(),
  CRUISEID = col_integer(),
  CRUISE_NO = col_character(),
  P_STA_NO = col_character(),
  TIME_ZN = col_integer(),
  TIME_MIL = col_character(),
  S_LATD = col_integer(),
  S_LATM = col_double(),
  S_LOND = col_integer(),
  S_LONM = col_double(),
  E_LATD = col_integer(),
  E_LATM = col_double(),
  E_LOND = col_integer(),
  E_LONM = col_double(),
  DEPTH_SSTA = col_double(),
  MO_DAY_YR = col_date(format = ""),
  VESSEL_SPD = col_double(),
  COMSTAT = col_character()
))


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
           !grepl("[A-Z]", OP)) %>% 
  mutate(
    # Create a unique haulid
    haulid = paste(formatC(VESSEL, width=3, flag=0), formatC(CRUISE_NO, width=3, flag=0), formatC(P_STA_NO, width=5, flag=0, format='d'), sep='-'), 
    # Extract year where needed
    year = year(MO_DAY_YR),
    # Calculate decimal lat and lon, depth in m, where needed
    S_LATD = ifelse(S_LATD == 0, NA, S_LATD), 
    S_LOND = ifelse(S_LOND == 0, NA, S_LOND), 
    E_LATD = ifelse(E_LATD == 0, NA, E_LATD), 
    E_LOND = ifelse(E_LOND == 0, NA, E_LOND),
    lat = rowMeans(cbind(S_LATD + S_LATM/60, E_LATD + E_LATM/60), na.rm=T), 
    lon = -rowMeans(cbind(S_LOND + S_LONM/60, E_LOND + E_LONM/60), na.rm=T), 
    # convert fathoms to meters
    depth = DEPTH_SSTA * 1.8288, 
    # Add "strata" (define by lat, lon and depth bands) where needed
    # degree bins, # degree bins, # 100 m bins
    stratum = paste(floor(lat)+0.5,floor(lon)+0.5, floor(depth/100)*100 + 50, sep= "-")
  )

rm(gmex_bio, gmex_cruise, gmex_spp, gmex_station, gmex_tow, newspp, problems, gmex_station_raw, gmex_station_clean)

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
neus_strata <- read_csv("data_raw/neus_strata.csv", col_types = cols(
  StratumCode = col_integer(),
  OldStratumCode = col_integer(),
  DepthIntervalm = col_character(),
  Areanmi2 = col_integer()
)) %>% 
  select(StratumCode, Areanmi2) %>% 
  rename(STRATUM = StratumCode)

neus <- left_join(neus_survdat, spp, by = "SVSPP")
neus <- left_join(neus, neus_strata, by = "STRATUM")

neus <- neus %>%
  mutate(
    # Create a unique haulid
    haulid = paste(formatC(CRUISE6, width=6, flag=0), formatC(STATION, width=3, flag=0), formatC(STRATUM, width=4, flag=0), sep='-')  
  )

rm(neus_spp, neus_strata, neus_survdat, survdat, spp)

# Compile SEUS ====

seus_catch <- read_csv("data_raw/seus_catch.csv", col_types = cols(.default = col_character()))  %>% 
  # turns everything into a character so import as character anyway
  mutate_all(funs(str_replace(., "=", "")))

# convert the columns to their correct formats
seus_catch <- type_convert(seus_catch, col_types = cols(
  PROJECTNAME = col_character(),
  PROJECTAGENCY = col_character(),
  DATE = col_character(),
  EVENTNAME = col_character(),
  COLLECTIONNUMBER = col_character(),
  VESSELNAME = col_character(),
  GEARNAME = col_character(),
  GEARCODE = col_character(),
  SPECIESCODE = col_character(),
  MRRI_CODE = col_character(),
  SPECIESSCIENTIFICNAME = col_character(),
  SPECIESCOMMONNAME = col_character(),
  NUMBERTOTAL = col_integer(),
  SPECIESTOTALWEIGHT = col_double(),
  SPECIESSUBWEIGHT = col_double(),
  SPECIESWGTPROCESSED = col_character(),
  WEIGHTMETHODDESC = col_character(),
  ORGWTUNITS = col_character(),
  EFFORT = col_character(),
  CATCHSUBSAMPLED = col_logical(),
  CATCHWEIGHT = col_double(),
  CATCHSUBWEIGHT = col_double(),
  TIMESTART = col_character(),
  DURATION = col_integer(),
  TOWTYPETEXT = col_character(),
  LOCATION = col_character(),
  REGION = col_character(),
  DEPTHZONE = col_character(),
  ACCSPGRIDCODE = col_character(),
  STATIONCODE = col_character(),
  EVENTTYPEDESCRIPTION = col_character(),
  TEMPSURFACE = col_double(),
  TEMPBOTTOM = col_double(),
  SALINITYSURFACE = col_double(),
  SALINITYBOTTOM = col_double(),
  SDO = col_character(),
  BDO = col_character(),
  TEMPAIR = col_double(),
  LATITUDESTART = col_double(),
  LATITUDEEND = col_double(),
  LONGITUDESTART = col_double(),
  LONGITUDEEND = col_double(),
  SPECSTATUSDESCRIPTION = col_character(),
  LASTUPDATED = col_character()
))

seus_haul <- read_csv("data_raw/seus_haul.csv", col_types = cols(.default = col_character())) %>% 
  distinct(EVENTNAME, DEPTHSTART)  %>% 
  mutate_all(funs(str_replace(., "=", "")))

seus_haul <- type_convert(seus_haul, col_types = cols(
  EVENTNAME = col_character(),
  DEPTHSTART = col_integer()
))
   

# contains strata areas
seus_strata <- read_csv("data_raw/seus_strata.csv", col_types = cols(
  STRATA = col_integer(),
  STRATAHECTARE = col_double()
))
  
seus <- left_join(seus_catch, seus_haul, by = "EVENTNAME")  
#Create STRATA column
seus <- seus %>% 
  mutate(STRATA = as.numeric(str_sub(STATIONCODE, 1, 2))) %>% 
# Drop OUTER depth zone because it was only sampled for 10 years
  filter(DEPTHZONE != "OUTER")

#add STRATAHECTARE to main file 
seus <- left_join(seus, seus_strata, by = "STRATA") 
  
#Create a 'SEASON' column using 'MONTH' as a criteria
#Create a 'SEASON' column using 'MONTH' as a criteria
seus <- seus %>% 
  mutate(DATE = as.Date(DATE, "%m-%d-%Y"), 
         MONTH = month(DATE))

seus <- seus %>%
  # create season column
  mutate(SEASON = NA, 
         SEASON = ifelse(MONTH >= 1 & MONTH <= 3, "winter", SEASON), 
         SEASON = ifelse(MONTH >= 4 & MONTH <= 6, "spring", SEASON),
         SEASON = ifelse(MONTH >= 7 & MONTH <= 8, "summer", SEASON),
         #September EVENTS were grouped with summer, should be fall because all
         #hauls made in late-September during fall-survey
         SEASON = ifelse(MONTH >= 9 & MONTH <= 12, "fall", SEASON))  

# find rows where weight wasn't provided for a species
misswt <- seus %>% 
  filter(is.na(SPECIESTOTALWEIGHT)) %>% 
  select(SPECIESCODE, SPECIESSCIENTIFICNAME) %>% 
  distinct()

# calculate the mean weight for those species
meanwt <- seus %>% 
  filter(SPECIESCODE %in% misswt$SPECIESCODE) %>% 
  group_by(SPECIESCODE) %>% 
  summarise(meanwt = mean(SPECIESTOTALWEIGHT, na.rm = T))

# add the calculated mean weight into the main table with a for loop
for (i in seq(meanwt$SPECIESCODE)){
  seus <- seus %>% 
    mutate(SPECIESTOTALWEIGHT = ifelse(is.na(SPECIESTOTALWEIGHT) &
                                         SPECIESCODE == meanwt$SPECIESCODE[i], 
                                       meanwt$meanwt[i], 
                                       SPECIESTOTALWEIGHT))
}

#Data entry error fixes for lat/lon coordinates
seus <- seus %>%
  mutate(
    # longitudes of less than -360 (like -700), do not exist.  This is a missing decimal.
    LONGITUDESTART = ifelse(LONGITUDESTART < -360, LONGITUDESTART/10, LONGITUDESTART), 
    LONGITUDEEND = ifelse(LONGITUDEEND < -360, LONGITUDEEND/10, LONGITUDEEND), 
    # latitudes of more than 100 are outside the range of this survey.  This is a missing decimal.
    LATITUDESTART = ifelse(LATITUDESTART > 100, LATITUDESTART/10, LATITUDESTART), 
    LATITUDEEND = ifelse(LATITUDEEND  > 100, LATITUDEEND/10, LATITUDEEND)
  )

# calculate trawl distance in order to calculate effort
# create a matrix of starting positions
start <- matrix(seus$LONGITUDESTART, seus$LATITUDESTART, nrow = nrow(seus), ncol = 2)
# create a matrix of ending positions
end <- matrix(seus$LONGITUDEEND, seus$LATITUDEEND, nrow = nrow(seus), ncol = 2)
# add distance to seus table
seus <- seus %>%
  mutate(distance_m = geosphere::distHaversine(p1 = start, p2 = end),
         distance_km = distance_m / 1000.0, 
         distance_mi = distance_m / 1609.344
  )

# calculate effort = mean area swept
# EFFORT = 0 where the boat didn't move, distance_m = 0
seus <- seus %>% 
  mutate(EFFORT = (13.5 * distance_m)/10000, 
         # Create a unique haulid
         haulid = EVENTNAME, 
         # Extract year where needed
         year = substr(EVENTNAME, 1,4)
         )

rm(seus_catch, seus_haul, seus_strata, end, start, meanwt, misswt)

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
  filter(HAUL_TYPE == 3 & PERFORMANCE == 0) %>% 
  # Create a unique haulid
  mutate(
    haulid = paste(formatC(VESSEL, width=3, flag=0), formatC(CRUISE, width=3, flag=0), formatC(HAUL, width=3, flag=0), sep='-'), 
    # Extract year where needed
    year = substr(CRUISE, 1, 4), 
    # Add "strata" (define by lat, lon and depth bands) where needed
     # degree bins
     # 100 m bins
    # no need to use lon grids on west coast (so narrow)
    stratum = paste(floor(START_LATITUDE)+0.5, floor(BOTTOM_DEPTH/100)*100 + 50, sep= "-")
  )

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

# keep HQ data ====
if(HQ_DATA_ONLY == TRUE){
  
  # find high quality strata
#These items were hand chosen.
  
# Trim to high quality strata 
# UPDATE TO SET ALASKA STRATA TO POSITIVE CHOICES
ai <- ai %>% 
  # these stratum look like most of them have -9999 for NUMCPUE, but some have values.  What makes them low quality?  How were they chosen?
  # could this be replaced with 
  # filter(NUMCPUE != -9999)
  filter(!STRATUM %in% c(221, 411, 421, 521, 611))

ebs <- ebs %>% 
  filter(!STRATUM %in% c(82,90))

# there aren't any stratum in goa that match these numbers.
# test <- goa %>%
#   filter(STRATUM %in% c(50, 210, 410, 420, 430, 440, 450, 510, 520, 530, 540, 550))
  # filter(NUMCPUE == "-9999") this returns 90244 lines

# neus <- neus %>%
  # strata to keep (based on Nye et al. MEPS)
  # this encompasses all stratum in neus
  # filter(STRATUM %in% c("1010", "1020", "1030", "1040", "1050", "1060", "1070", "1080", "1090", "1100", "1110", "1130", "1140", "1150", "1160", "1170", "1190", "1200", "1210", "1220", "1230", "1240", "1250", "1260", "1270", "1280", "1290", "1300", "1340", "1360", "1370", "1380", "1400", "1650", "1660", "1670", "1680", "1690", "1700", "1710", "1730", "1740", "1750"))

# count the number of years each stratum occurs 
num_years <- neus %>% 
  # trim to 1967 and later, since more strata were sampled starting then
  filter(YEAR >= 1967) %>% 
  select(YEAR, STRATUM) %>%
  # remove duplicates
  distinct() %>% 
  # count the number of times each STRATUM occurs
  group_by(STRATUM) %>% 
  summarise(count = n())
# determine the most number of years
max_years <- num_years %>% 
  summarise(max = max(count))
# which stratums occur the max number of years
max_strat <- num_years %>% 
  filter(count == max_years$max)
# keep only those strata in neus
neus <- neus %>% 
  filter(STRATUM %in% max_strat$STRATUM)

# all of the rows cut out have a performance of 0, but so do those kept, can't see why one is kept and one isn't.
wctri <- wctri %>% 
  filter(stratum %in% c("36.5-50", "37.5-150", "37.5-50", "38.5-150", "38.5-250", "38.5-350", "38.5-50", "39.5-150", "39.5-50", "40.5-150", "40.5-250", "41.5-150", "41.5-250", "41.5-50", "42.5-150", "42.5-250", "42.5-50", "43.5-150", "43.5-250", "43.5-350", "43.5-50", "44.5-150", "44.5-250", "44.5-350", "44.5-50", "45.5-150", "45.5-350", "45.5-50", "46.5-150", "46.5-250", "46.5-50", "47.5-150", "47.5-50", "48.5-150", "48.5-250", "48.5-50"))

# trim wcann to same footprint as wctri  
wcann <- wcann %>% 
  filter(stratum %in% c("36.5-50", "37.5-150", "37.5-50", "38.5-150", "38.5-250", "38.5-350", "38.5-50", "39.5-150", "39.5-50", "40.5-150", "40.5-250", "41.5-150", "41.5-250", "41.5-50", "42.5-150", "42.5-250", "42.5-50", "43.5-150", "43.5-250", "43.5-350", "43.5-50", "44.5-150", "44.5-250", "44.5-350", "44.5-50", "45.5-150", "45.5-350", "45.5-50", "46.5-150", "46.5-250", "46.5-50", "47.5-150", "47.5-50", "48.5-150", "48.5-250", "48.5-50"))
  
gmex <- gmex %>% 
  filter(stratum %in% c("26.5--96.5-50", "26.5--97.5-50", "27.5--96.5-50", "27.5--97.5-50", "28.5--90.5-50", "28.5--91.5-50", "28.5--92.5-50", "28.5--93.5-50", "28.5--94.5-50", "28.5--95.5-50", "28.5--96.5-50", "29.5--88.5-50", "29.5--89.5-50", "29.5--92.5-50", "29.5--93.5-50", "29.5--94.5-50"))
  
  # all seus strata are retained 

# find high quality years  #These items were hand chosen.
  # Trim to high-quality years (sample all strata)  

# 2001 didn't sample many strata
goa <- goa %>% 
  filter(YEAR != 2001)
  
# many strata in the Mid-Atlantic Bight weren't sampled until 1967
neus <- neus %>% 
  filter(YEAR >= 1967)

# # 1982 and 1983 didn't sample many strata
gmex <- gmex %>% 
  filter(!year %in% c(1982, 1983))

# if we are looking for years where all strata were not sampled, a better code might be
# which strata are there?
num_strata <- seus %>% 
  select(STRATA) %>% 
  distinct()

# how many strata were sampled each year? 24 each year
yearly <- seus %>% 
  select(year, STRATA, SEASON) %>% 
  distinct() %>% 
  group_by(year, SEASON) %>% 
  summarise(count = n()) %>% 
  filter(count != nrow(num_strata))

for (i in seq(yearly$year)){
  seus <- seus %>% 
    filter(year != yearly$year[i] & SEASON != yearly$SEASON[i])
}
# 1989 was a year when sampling was inconsistent
seus <- filter(seus, year != 1989)

rm(yearly, num_strata)
}

# now that lines have been removed from the main data set, can split out seasons
# NEUS spring ====
neusS <- neus %>% 
  filter(SEASON == "SPRING")

# NEUS Fall ====
neusF <- neus %>% 
  filter(SEASON == "FALL")

# SEUS spring ====
#Separate the the spring season and convert to dataframe
seusSPRING <- seus %>% 
  filter(SEASON == "spring")

# SEUS summer ====
#Separate the summer season and convert to dataframe
seusSUMMER <- seus %>% 
  filter(SEASON == "summer")

# SEUS fall ====
seusFALL <- seus %>% 
  filter(SEASON == "fall")
