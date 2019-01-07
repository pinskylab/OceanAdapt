# Answer the following questions using all caps TRUE or FALSE to direct the actions of the script ====

# a note on species name adjustment #### 
# at some point in time during certain surveys it was realized that what was believed to be one speices was actually a different species or more than one species.  Because of this, species have been lumped together as a genus in those instances.

# 1. Some strata and years have very little data, should they be removed? #DEFAULT: TRUE. 
HQ_DATA_ONLY <- TRUE 

# 2. #DEFAULT: FALSE Remove ai,ebs,gmex,goa,neus,seus,wcann,wctri. Keep `dat`
REMOVE_REGION_DATASETS <- TRUE 

# 3. #DEFAULT:FALSE, creates graphs based on the data like shown on the website and outputs them to pdf.
OPTIONAL_PLOT_CHARTS <- TRUE 

# 4. #OPTIONAL, DEFAULT:FALSE, Outputs the dat into an rdata file
OPTIONAL_OUTPUT_DAT_MASTER_TABLE <- TRUE 

# 5. #OPTIONAL, DEFAULT:FALSE, generate raw data from Rdata file
RAW_DATA_R_DATA <- TRUE

## Workspace setup ====
# This script works best when the repository is downloaded from github, 
# especially when that repository is loaded as a project into RStudio.

# The working directory is assumed to be the OceanAdapt directory of this repository.

library(tidyverse)
library(lubridate)
library(PBSmapping) # for calculating stratum areas
library(ggplot2)
library(data.table)

# Functions ====
# function to calculate convex hull area in km2
#developed from http://www.nceas.ucsb.edu/files/scicomp/GISSeminar/UseCases/CalculateConvexHull/CalculateConvexHullR.html
calcarea <- function(lon,lat){
  hullpts = chull(x=lon, y=lat) # find indices of vertices
  hullpts = c(hullpts,hullpts[1]) # close the loop
  lonlat <- data.frame(cbind(lon, lat))
  ps = appendPolys(NULL,mat=as.matrix(lonlat[hullpts,]),1,1,FALSE) # create a Polyset object
  attr(ps,"projection") = "LL" # set projection to lat/lon
  psUTM = convUL(ps, km=TRUE) # convert to UTM in km
  polygonArea = calcArea(psUTM,rollup=1)
  return(polygonArea$area)
}

sumna <- function(x){
  #acts like sum(na.rm=T) but returns NA if all are NA
  if(!all(is.na(x))) return(sum(x, na.rm=T))
  if(all(is.na(x))) return(NA)
}

meanna = function(x){
  if(!all(is.na(x))) return(mean(x, na.rm=T))
  if(all(is.na(x))) return(NA)
}

# weighted mean for use with summarize(). values in col 1, weights in col 2
wgtmean = function(x, na.rm=FALSE) {questionr::wtd.mean(x=x[,1], weights=x[,2], na.rm=na.rm)}

wgtse = function(x, na.rm=TRUE){ 
  if(sum(!is.na(x[,1]) & !is.na(x[,2]))>1){
    if(na.rm){
      return(sqrt(wtd.var(x=x[,1], weights=x[,2], na.rm=TRUE, normwt=TRUE))/sqrt(sum(!is.na(x[,1] & !is.na(x[,2])))))
    } else {
      return(sqrt(wtd.var(x=x[,1], weights=x[,2], na.rm=FALSE, normwt=TRUE))/sqrt(length(x))) # may choke on wtd.var without removing NAs
    }
  } else {
    return(NA) # NA if vector doesn't have at least 2 values
  }
}

se <- function(x) sd(x)/sqrt(length(x)) # assumes no NAs

# Update Alaska ====

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
    temp <- read_csv("temporary.csv", col_types = cols(
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
    ))
    ai_data <- rbind(ai_data, temp)
  }
  if(!grepl("strata", files[j]) & !grepl("ai2014", files[j])){
    # read the csv
    temp <- read_csv(paste0("data_raw/", files[j]), col_types = cols(
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
    ))
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

# are there any strata in the data that are not in the strata file?
test <- ai %>% 
  filter(is.na(Areakm2))
stopifnot(nrow(test) == 0)

# Create a unique haulid
ai <- ai %>% 
  mutate(haulid = paste(formatC(VESSEL, width=3, flag=0), formatC(CRUISE, width=3, flag=0), formatC(HAUL, width=3, flag=0), sep='-'), 
         WTCPUE = ifelse(WTCPUE == "-9999", NA, WTCPUE)) %>% 
  rename(stratum = STRATUM,
         year = YEAR, 
         lat = LATITUDE, 
         lon = LONGITUDE, 
         depth = BOT_DEPTH, 
         spp = SCIENTIFIC, 
         wtcpue = WTCPUE,
         stratumarea = Areakm2) %>% 
  # remove rows that aren't fish
  filter(spp != "" &
           # remove all spp that contain the word "egg"
           !grepl("egg", spp)) %>% 
  # adjust spp names
  mutate(
    # catch A. stomias and A. evermanii (as of 2018 both spp appear as "valid" so not sure why they are being changed)
    spp = ifelse(grepl("Atheresthes", spp), "Atheresthes sp.", spp), 
    # catch L. polystryxa (valid in 2018), and L. bilineata (valid in 2018)
    spp = ifelse(grepl("Lepidopsetta", spp), "Lepidopsetta sp.", spp),
    # catch M. jaok (valid in 2018), M. niger (valid in 2018), M. polyacanthocephalus (valid in 2018), M. quadricornis (valid in 2018), M. verrucosus (changed to scorpius), M. scorpioides (valid in 2018), M. scorpius (valid in 2018) (M. scorpius is in the data set but not on the list so it is excluded from the change)
    spp = ifelse(grepl("Myoxocephalus", spp ) & !grepl("scorpius", spp), "Myoxocephalus sp.", spp),
    # catch B. maculata (valid in 2018), abyssicola (valid in 2018), aleutica (valid in 2018), interrupta (valid in 2018), lindbergi (valid in 2018), mariposa (valid in 2018), minispinosa (valid in 2018), parmifera (valid in 2018), smirnovi (valid in 2018), cf parmifera (Orretal), spinosissima (valid in 2018), taranetzi (valid in 2018), trachura (valid in 2018), violacea (valid in 2018)
    # B. panthera is not on the list of spp to change
    spp = ifelse(grepl("Bathyraja", spp) & !grepl("panthera", spp), 'Bathyraja sp.', spp)
  ) %>% 
  type_convert() %>% 
  group_by(haulid, stratum, stratumarea, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # Calculate a corrected longitude for Aleutians (all in western hemisphere coordinates)
  # had to add this ungroup line because I was getting an error that lon was a grouping variable, if you aren't getting that error you don't need the ungroup line
  ungroup() %>% 
  mutate(lon = ifelse(lon > 0, lon - 360, lon), 
         region = "Aleutian Islands") %>% 
  select(region, haulid, year, lat, lon, stratum, stratumarea, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  # plot the strata by year
  ai %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  test <- ai %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>% 
    filter(count >= 13)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- ai %>% 
    filter(stratum %in% test$stratum)
  nrow(ai) - nrow(test2)
  # percent that will be lost
  print((nrow(ai) - nrow(test2))/nrow(ai))
  # 5% seems reasonable 
  ai <- ai %>% 
    filter(stratum %in% test$stratum)
  ai %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
}
# clean up
rm(files, temp, j, temp_fixed, ai_data, ai_strata, test, test2)

# Compile EBS ====
files <- list.files(path = "data_raw/", pattern = "ebs")
# create blank table
ebs_data <- tibble()
for (j in seq(files)){
  if(!grepl("strata", files[j])){
    # read the csv
    temp <- read_csv(paste0("data_raw/", files[j]), col_types = cols(
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
    ))
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

# are there any strata in the data that are not in the strata file?
test <- ebs %>% 
  filter(is.na(Areakm2))
stopifnot(nrow(test) == 0)

ebs <- ebs %>% 
  mutate(
    # Create a unique haulid
    haulid = paste(formatC(VESSEL, width=3, flag=0), formatC(CRUISE, width=3, flag=0), formatC(HAUL, width=3, flag=0), sep='-'), 
    # convert -9999 to NA 
    WTCPUE = ifelse(WTCPUE == "-9999", NA, WTCPUE)) %>%  
  # rename columns
  rename(stratum = STRATUM,
         year = YEAR, 
         lat = LATITUDE, 
         lon = LONGITUDE, 
         depth = BOT_DEPTH, 
         spp = SCIENTIFIC, 
         wtcpue = WTCPUE,
         stratumarea = Areakm2) %>% 
  # remove non-fish
  filter(spp != '' &
           !grepl("egg", spp)) %>% 
  # adjust spp names
  mutate(spp = ifelse(grepl("Atheresthes", spp), "Atheresthes sp.", spp), 
         spp = ifelse(grepl("Lepidopsetta", spp), "Lepidopsetta sp.", spp),
         spp = ifelse(grepl("Myoxocephalus", spp), "Myoxocephalus sp.", spp),
         spp = ifelse(grepl("Bathyraja", spp), 'Bathyraja sp.', spp), 
         spp = ifelse(grepl("Hippoglossoides", spp), "Hippoglossoides sp.", spp)) %>% 
  # change from all character to fitting column types
  type_convert()  %>%  
  group_by(haulid, stratum, stratumarea, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add region column
  mutate(region = "Eastern Bering Sea") %>% 
  select(region, haulid, year, lat, lon, stratum, stratumarea, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  ebs %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  test <- ebs %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n())  %>% 
    filter(count >= 36)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- ebs %>% 
    filter(stratum %in% test$stratum)
  nrow(ebs) - nrow(test2)
  # percent that will be lost
  print((nrow(ebs) - nrow(test2))/nrow(ebs))
  # 4% seems reasonable 
  ebs <- ebs %>% 
    filter(stratum %in% test$stratum)
  ebs %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
} 
# clean up
rm(files, temp, j, ebs_data, ebs_strata, test2, test)


# Compile GOA ====
files <- list.files(path = "data_raw/", pattern = "goa")
# create blank table
goa_data <- tibble()
for (j in seq(files)){
  if(!grepl("strata", files[j])){
    # read the csv
    temp <- read_csv(paste0("data_raw/", files[j]), col_types = cols(
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
    ))
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

# are there any strata in the data that are not in the strata file?
test <- goa %>% 
  filter(is.na(Areakm2))
stopifnot(nrow(test) == 0)
if(nrow(test)>0){
  # find all strata that are missing area
  missing <- goa %>% 
    filter(is.na(Areakm2)) %>% 
    select(STRATUM, LONGITUDE, LATITUDE) %>% 
    distinct()
  # for every missing area, calculate the area based on observed lat lons
  for(i in seq(missing$STRATUM)){
    temp <- missing %>% 
      filter(STRATUM == missing$STRATUM[i]) %>% 
      mutate(area = calcarea(as.numeric(LONGITUDE), as.numeric(LATITUDE)))
    goa <- goa %>% 
      mutate(Areakm2 = ifelse(STRATUM == missing$STRATUM[i], temp$area[1], Areakm2))
  }
}

# Create a unique haulid
goa <- goa %>%
  mutate(
    haulid = paste(formatC(VESSEL, width=3, flag=0), formatC(CRUISE, width=3, flag=0), formatC(HAUL, width=3, flag=0), sep='-'),    
    WTCPUE = ifelse(WTCPUE == "-9999", NA, WTCPUE)) %>% 
  rename(stratum = STRATUM,
         year = YEAR, 
         lat = LATITUDE, 
         lon = LONGITUDE, 
         depth = BOT_DEPTH, 
         spp = SCIENTIFIC, 
         wtcpue = WTCPUE,
         stratumarea = Areakm2) %>% 
  # remove non-fish
  filter(
    spp != '' & 
      !grepl("egg", spp)) %>% 
  # adjust spp names
  mutate(
    spp = ifelse(grepl("Lepidopsetta", spp), "Lepidopsetta sp.", spp),
    spp = ifelse(grepl("Myoxocephalus", spp ) & !grepl("scorpius", spp), "Myoxocephalus sp.", spp),
    spp = ifelse(grepl("Bathyraja", spp) & !grepl("panthera", spp), 'Bathyraja sp.', spp)
  ) %>% 
  type_convert()  %>% 
  group_by(haulid, stratum, stratumarea, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  mutate(region = "Gulf of Alaska") %>% 
  select(region, haulid, year, lat, lon, stratum, stratumarea, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  goa %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  # for GOA in 2018, 2001 missed 27 strata and will be removed, stratum 50 is
  # missing from 3 years but will be kept, 410, 420, 430, 440, 450 are missing 
  #from 3 years but will be kept, 510 and higher are missing from 7 or more years
  # of data and will be removed
  test <- goa %>%
    filter(year != 2001) %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n())  %>%
    filter(count >= 14)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- goa %>% 
    filter(stratum %in% test$stratum)
  nrow(goa) - nrow(test2)
  # percent that will be lost
  print ((nrow(goa) - nrow(test2))/nrow(goa))
  # 4% seems reasonable 
  goa <- goa %>% 
    filter(stratum %in% test$stratum) %>%
    filter(year != 2001)
  
  goa %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
}
# clean up
rm(files, temp, j, goa_data, goa_strata, missing, test, test2)

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
    # Add "strata" (define by lat, lon and depth bands) where needed # degree bins # 100 m bins # no need to use lon grids on west coast (so narrow)
    stratum = paste(floor(START_LATITUDE)+0.5, floor(BOTTOM_DEPTH/100)*100 + 50, sep= "-"), 
    # adjust for tow area # weight per hectare (10,000 m2)	
    wtcpue = WEIGHT*10000/DISTANCE_FISHED*1000*NET_WIDTH
  )

# Calculate stratum area where needed (use convex hull approach)
wctri_strats <- wctri %>% 
  group_by(stratum) %>% 
  summarise(stratumarea = calcarea(START_LONGITUDE, START_LATITUDE))

wctri <- left_join(wctri, wctri_strats, by = "stratum")

wctri <- wctri %>% 
  rename(
    svvessel = VESSEL,
    lat = START_LATITUDE, 
    lon = START_LONGITUDE,
    depth = BOTTOM_DEPTH, 
    spp = SPECIES_NAME
  ) %>% 
  filter(
    spp != "" & 
      !grepl("egg", spp)
  ) %>% 
  # adjust spp names
  mutate(spp = ifelse(grepl("Lepidopsetta", spp), "Lepidopsetta sp.", spp),
         spp = ifelse(grepl("Bathyraja", spp), 'Bathyraja sp.', spp)) %>%
  group_by(haulid, stratum, stratumarea, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add region column
  mutate(region = "West Coast Triennial") %>% 
  select(region, haulid, year, lat, lon, stratum, stratumarea, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  # I used this section by creating the graph, adjusting the parameters of the
  # test group, filtering out of the main data set, and then recreating the
  # graph to see if I had removed enough bad data
  
  wctri %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  test <- wctri %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>%
    filter(count >= 10)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- wctri %>% 
    filter(stratum %in% test$stratum)
  nrow(wctri) - nrow(test2)
  # percent that will be lost
  print((nrow(wctri) - nrow(test2))/nrow(wctri))
  # 23% seems like a lot
  wctri <- wctri %>% 
    filter(stratum %in% test$stratum)
  
  wctri %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
}

rm(wctri_catch, wctri_haul, wctri_species, wctri_strats, test, test2)

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
    # create haulid
    haulid = trawl_id,
    # Add "strata" (define by lat, lon and depth bands) where needed # no need to use lon grids on west coast (so narrow)
    stratum = paste(floor(latitude_dd)+0.5, floor(depth_m/100)*100 + 50, sep= "-"), 
    # adjust for tow area # kg per hectare (10,000 m2)	
    wtcpue = total_catch_wt_kg/area_swept_ha_der 
  )

wcann_strats <- wcann %>% 
  filter(!is.na(longitude_dd)) %>% 
  group_by(stratum) %>% 
  summarise(stratumarea = calcarea(longitude_dd, latitude_dd), na.rm = T)

wcann <- left_join(wcann, wcann_strats, by = "stratum")

wcann <- wcann %>% 
  rename(lat = latitude_dd, 
         lon = longitude_dd, 
         depth = depth_m, 
         spp = scientific_name) %>% 
  # remove non-fish
  filter(
    spp != '' & 
      !grepl("egg", spp)
  ) %>% 
  # adjust spp names
  mutate(
    spp = ifelse(grepl("Lepidopsetta", spp), "Lepidopsetta sp.", spp),
    spp = ifelse(grepl("Bathyraja", spp), 'Bathyraja sp.', spp)
  ) %>%
  group_by(haulid, stratum, stratumarea, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add region column
  mutate(region = "West Coast Annual") %>% 
  select(region, haulid, year, lat, lon, stratum, stratumarea, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  # keep the same footprint as wctri
  # how many rows of data will be lost?
  nrow(wcann) - nrow(filter(wcann, stratum %in% wctri$stratum))
  # percent that will be lost - 61% !
  (nrow(wcann) - nrow(filter(wcann, stratum %in% wctri$stratum)))/nrow(wcann)
  
  wcann <- wcann %>% 
    filter(stratum %in% wctri$stratum)
  
  # see what these data look like - pretty solid
  wcann %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
}

# cleanup
rm(wcann_catch, wcann_haul, wcann_strats)

# Compile GMEX ====
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
  CRUISE_NO = col_integer(),
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
))

gmex_tow <- gmex_tow %>%
  select('STATIONID', 'CRUISE_NO', 'P_STA_NO', 'INVRECID', 'GEAR_SIZE', 'GEAR_TYPE', 'MESH_SIZE', 'MIN_FISH', 'OP') %>%
  filter(GEAR_TYPE=='ST')

problems <- problems(gmex_tow) %>% 
  filter(!is.na(col)) 
# 2 problems are that there are weird delimiters in the note column COMBIO, ignoring for now.

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
problems <- problems(gmex_spp) %>% 
  filter(!is.na(col))

gmex_cruise <-read_csv("data_raw/gmex_CRUISES.csv", col_types = cols(.default = col_character())) %>% 
  select(CRUISEID, VESSEL, TITLE)

# problems should be 0 obs
problems <- problems(gmex_cruise) %>% 
  filter(!is.na(col))

gmex_cruise <- type_convert(gmex_cruise, col_types = cols(CRUISEID = col_integer(), VESSEL = col_integer(), TITLE = col_character()))

gmex_bio <-read_csv("data_raw/gmex_BGSREC.csv", col_types = cols(.default = col_character())) %>% 
  select('CRUISEID', 'STATIONID', 'VESSEL', 'CRUISE_NO', 'P_STA_NO', 'GENUS_BGS', 'SPEC_BGS', 'BGSCODE', 'BIO_BGS', 'SELECT_BGS') %>%
  # trim out young of year records (only useful for count data) and those with UNKNOWN species
  filter(BGSCODE != "T" | is.na(BGSCODE),
         GENUS_BGS != "UNKNOWN" | is.na(GENUS_BGS))  %>%
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

# make two combined records where 2 different species share the same species code
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


gmex <- gmex %>% 
  # Trim to high quality SEAMAP summer trawls, based off the subset used by Jeff Rester's GS_TRAWL_05232011.sas
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
    stratum = paste(floor(lat)+0.5, floor(lon)+0.5, floor(depth/100)*100 + 50, sep= "-")
  )

# fix speed
# Trim out or fix speed and duration records
# trim out tows of 0, >60, or unknown minutes
gmex <- gmex %>% 
  filter(MIN_FISH <= 60 & MIN_FISH > 0 & !is.na(MIN_FISH)) %>% 
  # fix typo according to Jeff Rester: 30 = 3	
  mutate(VESSEL_SPD = ifelse(VESSEL_SPD == 30, 3, VESSEL_SPD)) %>% 
  # trim out vessel speeds 0, unknown, or >5 (need vessel speed to calculate area trawled)
  filter(VESSEL_SPD <= 5 & VESSEL_SPD > 0  & !is.na(VESSEL_SPD))

gmex_strats <- gmex %>%
  group_by(stratum) %>% 
  summarise(stratumarea = calcarea(lon, lat))
gmex <- left_join(gmex, gmex_strats, by = "stratum")

# while comsat is still present
# Remove a tow when paired tows exist (same lat/lon/year but different haulid, only Gulf of Mexico)
# identify duplicate tows at same year/lat/lon
dups <- gmex %>%
  group_by(year, lat, lon) %>%
  filter(n() > 1) %>%
  group_by(haulid) %>%
  filter(n() == 1)

# remove the identified tows from the dataset
gmex <- gmex %>%
  filter(!haulid %in% dups$haulid & !grepl("PORT", COMSTAT))

gmex <- gmex %>% 
  rename(spp = TAXONOMIC) %>% 
  # adjust for area towed
  mutate(
    # kg per 10000m2. calc area trawled in m2: knots * 1.8 km/hr/knot * 1000 m/km * minutes * 1 hr/60 min * width of gear in feet * 0.3 m/ft # biomass per standard tow
    wtcpue = 10000*SELECT_BGS/(VESSEL_SPD * 1.85200 * 1000 * MIN_FISH / 60 * GEAR_SIZE * 0.3048) 
  ) %>% 
  # remove non-fish
  filter(
    spp != '' | !is.na(spp),
    # remove unidentified spp
    !spp %in% c('UNID CRUSTA', 'UNID OTHER', 'UNID.FISH', 'CRUSTACEA(INFRAORDER) BRACHYURA', 'MOLLUSCA AND UNID.OTHER #01', 'ALGAE', 'MISCELLANEOUS INVERTEBR', 'OTHER INVERTEBRATES')
  ) %>% 
  # adjust spp names
  mutate(
    spp = ifelse(GENUS_BGS == 'PELAGIA' & SPEC_BGS == 'NOCTUL', 'PELAGIA NOCTILUCA', spp), 
    BIO_BGS = ifelse(spp == "PELAGIA NOCTILUCA", 618030201, BIO_BGS), 
    spp = ifelse(GENUS_BGS == 'MURICAN' & SPEC_BGS == 'FULVEN', 'MURICANTHUS FULVESCENS', spp), 
    BIO_BGS = ifelse(spp == "MURICANTHUS FULVESCENS", 308011501, BIO_BGS), 
    spp = ifelse(grepl("APLYSIA", spp), "APLYSIA", spp), 
    spp = ifelse(grepl("AURELIA", spp), "AURELIA", spp), 
    spp = ifelse(grepl("BOTHUS", spp), "BOTHUS", spp), 
    spp = ifelse(grepl("CLYPEASTER", spp), "CLYPEASTER", spp), 
    spp = ifelse(grepl("CONUS", spp), "CONUS", spp), 
    spp = ifelse(grepl("CYNOSCION", spp), "CYNOSCION", spp), 
    spp = ifelse(grepl("ECHINASTER", spp), "ECHINASTER", spp),
    spp = ifelse(grepl("OPISTOGNATHUS", spp), "OPISTOGNATHUS", spp), 
    spp = ifelse(grepl("OPSANUS", spp), "OPSANUS", spp), 
    spp = ifelse(grepl("ROSSIA", spp), "ROSSIA", spp), 
    spp = ifelse(grepl("SOLENOCERA", spp), "SOLENOCERA", spp), 
    spp = ifelse(grepl("TRACHYPENEUS", spp), "TRACHYPENEUS", spp)
  ) %>% 
  group_by(haulid, stratum, stratumarea, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add region column
  mutate(region = "Gulf of Mexico") %>% 
  select(region, haulid, year, lat, lon, stratum, stratumarea, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  # I used this section by creating the graph, adjusting the parameters of the
  # test group, filtering out of the main data set, and then recreating the
  # graph to see if I had removed enough bad data
  gmex %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  test <- gmex %>% 
    filter(year >= 2008, year != 2018) %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n())  %>%
    filter(count >= 10)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- gmex %>% 
    filter(stratum %in% test$stratum)
  nrow(gmex) - nrow(test2)
  # percent that will be lost
  print((nrow(gmex) - nrow(test2))/nrow(gmex))
  # by removing only bad years we loose only 0.2%, adding in strata that 
  # aren't in all years, we lose 33% more
  gmex <- gmex %>%
    filter(stratum %in% test$stratum) %>% 
    filter(year >= 2008, year != 2018) 
  
  gmex %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
}

rm(gmex_bio, gmex_cruise, gmex_spp, gmex_station, gmex_tow, newspp, problems, gmex_station_raw, gmex_station_clean, gmex_strats, test, test2, dups)

# Compile NEUS ====
load("data_raw/neus_Survdat.RData")
load("data_raw/neus_SVSPP.RData")

neus_survdat <- survdat %>% 
  # select specific columns
  select(CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX, SVVESSEL, YEAR, SEASON, LAT, LON, DEPTH, SURFTEMP, SURFSALIN, BOTTEMP, BOTSALIN, ABUNDANCE, BIOMASS) %>% 
  # remove duplicates
  distinct() 

# sum different sexes of same spp together
neus_survdat <- neus_survdat %>% 
  group_by(YEAR, SEASON, LAT, LON, DEPTH, CRUISE6, STATION, STRATUM, SVSPP) %>% 
  summarise(wtcpue = sum(BIOMASS)) 


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

# are there any strata in the data that are not in the strata file?
test <- neus %>% 
  filter(is.na(Areanmi2))
stopifnot(nrow(test) == 0)
if(nrow(test)>0){
  # find all strata that are missing area
  missing <- neus %>% 
    ungroup() %>% 
    filter(is.na(Areanmi2)) %>% 
    select(STRATUM) %>% 
    distinct()
  # for every missing area, calculate the area based on observed lat lons
  for(i in seq(missing$STRATUM)){
    temp <- neus %>% 
      ungroup() %>% 
      select(STRATUM, LAT, LON) %>% 
      filter(STRATUM == missing$STRATUM[i]) %>% 
      mutate(area = calcarea(as.numeric(LON), as.numeric(LAT)))
    neus <- neus %>% 
      mutate(Areanmi2 = ifelse(STRATUM == missing$STRATUM[i], temp$area[1], Areanmi2))
    # write new stratum areas to the stratum file?
    # strat <- neus %>% 
    #   ungroup() %>% 
    #   select(STRATUM, Areanmi2)
    # write_csv(strat, "data_raw/new_neus_strata.csv")
  }
}


neus <- neus %>%
  mutate(
    # Create a unique haulid
    haulid = paste(formatC(CRUISE6, width=6, flag=0), formatC(STATION, width=3, flag=0), formatC(STRATUM, width=4, flag=0), sep='-'),  
    # Calculate stratum area where needed (use convex hull approach)
    # convert square nautical miles to square kilometers
    stratumarea = Areanmi2 * 3.429904) %>% 
  rename(year = YEAR,
         spp = SCINAME,
         lat = LAT, 
         lon = LON, 
         depth = DEPTH,
         stratum = STRATUM) %>% 
  filter(
    # remove unidentified spp and non-species
    spp != '' | !is.na(spp), 
    !grepl("EGG", spp), 
    !grepl("UNIDENTIFIED", spp)) %>%
  group_by(haulid, stratum, stratumarea, year, lat, lon, depth, spp, SEASON) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add temporary region column (this will be replaced with seasonal name)
  mutate(region = "Northeast US") %>% 
  select(region, haulid, year, lat, lon, stratum, stratumarea, depth, spp, wtcpue, SEASON) %>% 
  ungroup()

# now that lines have been removed from the main data set, can split out seasons
# NEUS spring ====
neusS <- neus %>% 
  ungroup() %>% 
  filter(SEASON == "SPRING") %>% 
  select(-SEASON) %>% 
  mutate(region = "Northeast US Spring")

if (HQ_DATA_ONLY == TRUE){
  # I used this section by creating the graph, adjusting the parameters of the
  # test group, filtering out of the main data set, and then recreating the
  # graph to see if I had removed enough bad data
  
  neusS %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  # for neus Spring, right away it is apparent that 1972 and earlier be eliminated
  neusS <- neusS %>% 
    filter(year > 1972)
  
  # it's hard to read the strata labels so I'm finding them here
  test <- neusS %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>%
    filter(count < 40)
  
  neusS <- neusS %>%
    filter(!stratum %in% test$stratum)
  
  # check by year
  test <- neusS %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(year) %>% 
    summarise(count = n()) %>%
    filter(count > 67)
  
  neusS <- neusS %>%
    filter(year %in% test$year)
  
  neusS %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
}

# NEUS Fall ====
neusF <- neus %>% 
  ungroup() %>% 
  filter(SEASON == "FALL") %>% 
  select(-SEASON) %>% 
  mutate(region = "Northeast US Fall")

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  # I used this section by creating the graph, adjusting the parameters of the
  # test group, filtering out of the main data set, and then recreating the
  # graph to see if I had removed enough bad data
  
  neusF %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year))) +
    geom_jitter()
  
  test <- neusF %>% 
    filter(year != 2017, year >= 1972) %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>%
    filter(count >= 45)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- neusF %>% 
    filter(year != 2017, year >= 1972) %>% 
    filter(stratum %in% test$stratum)
  nrow(neusF) - nrow(test2)
  # percent that will be lost
  (nrow(neusF) - nrow(test2))/nrow(neusF)
  # 60% is too much, by removing bad years we get rid of 9%, which is not so bad.
  # When bad strata are removed after bad years we only lose 37%
  
  neusF <- neusF %>%
    filter(year != 2017, year >= 1972) %>% 
    filter(stratum %in% test$stratum) 
  
  neusF %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
}
rm(neus_spp, neus_strata, neus_survdat, survdat, spp, test, test2, missing, temp)

# Compile SEUS ====
# turns everything into a character so import as character anyway
seus_catch <- read_csv("data_raw/seus_catch.csv", col_types = cols(.default = col_character()), quoted_na = T, quote = '"') %>% 
  # remove symbols
  mutate_all(funs(str_replace(., "=", ""))) %>% 
  mutate_all(funs(str_replace(., '"', ''))) %>% 
  mutate_all(funs(str_replace(., '"', '')))

# problems should have 0 obs
problems <- problems(seus_catch) %>% 
  filter(!is.na(col))


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
  # remove symbols
  mutate_all(funs(str_replace(., "=", ""))) %>% 
  mutate_all(funs(str_replace(., '"', ''))) %>% 
  mutate_all(funs(str_replace(., '"', '')))

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
seus <- seus %>% 
  mutate(DATE = as.Date(DATE, "%m-%d-%Y"), 
         MONTH = month(DATE)) %>%
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
         distance_mi = distance_m / 1609.344) %>% 
  # calculate effort = mean area swept
  # EFFORT = 0 where the boat didn't move, distance_m = 0
  mutate(EFFORT = (13.5 * distance_m)/10000, 
         # Create a unique haulid
         haulid = EVENTNAME, 
         # Extract year where needed
         year = substr(EVENTNAME, 1,4)
  ) %>% 
  rename(
    stratum = STRATA, 
    lat = LATITUDESTART, 
    lon = LONGITUDESTART, 
    depth = DEPTHSTART, 
    spp = SPECIESSCIENTIFICNAME, 
    stratumarea = STRATAHECTARE)

#In seus there are two 'COLLECTIONNUMBERS' per 'EVENTNAME', with no exceptions; EFFORT is always the same for each COLLECTIONNUMBER
# We sum the two tows in seus
### As of 2018-09-24 MRS found that SEUS is producing raw abundance data with all NA's in the effort column.  Have emailed them to make sure this is intentional.  in the meantime, adjusting script to reflect lack of effort data
# original code ________________________________________####
# seusSPRING <<- aggregate(list(BIOMASS = seusSPRING$SPECIESTOTALWEIGHT), by=list(haulid = seusSPRING$haulid, stratum = seusSPRING$stratum, stratumarea = seusSPRING$stratumarea, year = seusSPRING$year, lat = seusSPRING$lat, lon = seusSPRING$lon, depth = seusSPRING$depth, SEASON = seusSPRING$SEASON, EFFORT = seusSPRING$EFFORT, spp = seusSPRING$spp), FUN=sum)
# seusSPRING$wtcpue <<- seusSPRING$BIOMASS/(seusSPRING$EFFORT*2)#yields biomass (kg) per hectare for each 'spp' and 'haulid'
# seusSUMMER <<- aggregate(list(BIOMASS = seusSUMMER$SPECIESTOTALWEIGHT), by=list(haulid = seusSUMMER$haulid, stratum = seusSUMMER$stratum, stratumarea = seusSUMMER$stratumarea, year = seusSUMMER$year, lat = seusSUMMER$lat, lon = seusSUMMER$lon, depth = seusSUMMER$depth, SEASON = seusSUMMER$SEASON, EFFORT = seusSUMMER$EFFORT, spp = seusSUMMER$spp), FUN=sum)
# seusSUMMER$wtcpue <<- seusSUMMER$BIOMASS/(seusSUMMER$EFFORT*2)#yields biomass (kg) per hectare for each 'spp' and 'haulid'
# seusFALL <<- aggregate(list(BIOMASS = seusFALL$SPECIESTOTALWEIGHT), by=list(haulid = seusFALL$haulid, stratum = seusFALL$stratum, stratumarea = seusFALL$stratumarea, year = seusFALL$year, lat = seusFALL$lat, lon = seusFALL$lon, depth = seusFALL$depth, SEASON = seusFALL$SEASON, EFFORT = seusFALL$EFFORT, spp = seusFALL$spp), FUN=sum)
# seusFALL$wtcpue <<- seusFALL$BIOMASS/(seusFALL$EFFORT*2)#yields biomass (kg) per hectare for each 'spp' and 'haulid'
#________________________________________________________
# temp code _______________________________________####
#yields biomass (kg) per hectare for each 'spp' and 'haulid'
biomass <- seus %>% 
  group_by(haulid, stratum, stratumarea, year, lat, lon, depth, SEASON, spp) %>% 
  summarise(wtcpue = sum(SPECIESTOTALWEIGHT)) 

seus <- left_join(seus, biomass, by = c("haulid", "stratum", "stratumarea", "year", "lat", "lon", "depth", "SEASON", "spp"))
# double check that column numbers haven't changed by more than 1.  

seus <- seus %>% 
  # remove non-fish
  filter(
    !spp %in% c('MISCELLANEOUS INVERTEBRATES','XANTHIDAE','MICROPANOPE NUTTINGI','ALGAE','DYSPANOPEUS SAYI', 'PSEUDOMEDAEUS AGASSIZII')
  ) %>% 
  # adjust spp names
  mutate(
    spp = ifelse(grepl("ANCHOA", spp), "ANCHOA", spp), 
    spp = ifelse(grepl("LIBINIA", spp), "LIBINIA", spp)
  )  %>% 
  group_by(haulid, stratum, stratumarea, year, lat, lon, depth, spp, SEASON) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add temporary region column that will be converted to seasonal
  mutate(region = "Southeast US") %>% 
  select(region, haulid, year, lat, lon, stratum, stratumarea, depth, spp, wtcpue, SEASON) %>% 
  ungroup()

# now that lines have been removed from the main data set, can split out seasons
# SEUS spring ====
#Separate the the spring season and convert to dataframe
seusSPRING <- seus %>% 
  filter(SEASON == "spring") %>% 
  select(-SEASON) %>% 
  mutate(region = "Southeast US Spring")

if (HQ_DATA_ONLY == TRUE){
  # I used this section by creating the graph, adjusting the parameters of the
  # test group, filtering out of the main data set, and then recreating the
  # graph to see if I had removed enough missing data
  
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  # I used this section by creating the graph, adjusting the parameters of the
  # test group, filtering out of the main data set, and then recreating the
  # graph to see if I had removed enough bad data
  
  seusSPRING %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year))) +
    geom_jitter()
  
  test <- seusSPRING %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>%
    filter(count >= 29)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- seusSPRING %>% 
    filter(stratum %in% test$stratum)
  nrow(seusSPRING) - nrow(test2)
  # percent that will be lost
  print((nrow(seusSPRING) - nrow(test2))/nrow(seusSPRING))
  # 6% are removed
  
  seusSPRING <- seusSPRING %>%
    filter(stratum %in% test$stratum) 
  
  seusSPRING %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
}

# SEUS summer ====
#Separate the summer season and convert to dataframe
seusSUMMER <- seus %>% 
  filter(SEASON == "summer") %>% 
  select(-SEASON) %>% 
  mutate(region = "Southeast US Summer")

if (HQ_DATA_ONLY == TRUE){
  # I used this section by creating the graph, adjusting the parameters of the
  # test group, filtering out of the main data set, and then recreating the
  # graph to see if I had removed enough missing data
  
  seusSUMMER %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year))) +
    geom_jitter()
  
  # no missing data
}

# SEUS fall ====
seusFALL <- seus %>% 
  filter(SEASON == "fall") %>% 
  select(-SEASON) %>% 
  mutate(region = "Southeast US Fall")

if (HQ_DATA_ONLY == TRUE){
  # I used this section by creating the graph, adjusting the parameters of the
  # test group, filtering out of the main data set, and then recreating the
  # graph to see if I had removed enough missing data
  
  seusFALL %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year))) +
    geom_jitter()
  
  test <- seusFALL %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>%
    filter(count >= 29)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- seusFALL %>% 
    filter(stratum %in% test$stratum)
  nrow(seusFALL) - nrow(test2)
  # percent that will be lost
  print((nrow(seusFALL) - nrow(test2))/nrow(seusFALL))
  # 2% are removed
  
  seusFALL <- seusFALL %>%
    filter(stratum %in% test$stratum) 
  
  seusFALL %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
}

rm(seus_catch, seus_haul, seus_strata, end, start, meanwt, misswt, biomass, i, test, test2)

# Compile Scotian Shelf ====
scot_sumr <- read_csv("data_raw/scot_summer.csv", col_types = cols(
  .default = col_double(),
  Stratum = col_integer(),
  Mission = col_character(),
  SurveyYear = col_integer(),
  Season = col_character(),
  SurveyDate = col_character(),
  SetNumber = col_integer(),
  Gear = col_character(),
  MinimumDepth_Fathoms = col_integer(),
  MaximumDepth_Fathoms = col_integer(),
  Species = col_integer(),
  TaxonomicSerialNumber = col_integer(),
  ScientificName = col_character(),
  TaxonomicNameAuthor = col_character()
))

scot_fall <- read_csv("data_raw/scot_fall.csv", col_types = cols(
  .default = col_double(),
  Stratum = col_integer(),
  Mission = col_character(),
  SurveyYear = col_integer(),
  Season = col_character(),
  SurveyDate = col_character(),
  SetNumber = col_integer(),
  Gear = col_character(),
  MinimumDepth_Fathoms = col_integer(),
  MaximumDepth_Fathoms = col_integer(),
  Species = col_integer(),
  TaxonomicSerialNumber = col_integer(),
  ScientificName = col_character(),
  TaxonomicNameAuthor = col_character()
))
scot_spr <- read_csv("data_raw/scot_spring.csv", col_types = cols(
  .default = col_double(),
  Stratum = col_integer(),
  Mission = col_character(),
  SurveyYear = col_integer(),
  Season = col_character(),
  SurveyDate = col_character(),
  SetNumber = col_integer(),
  Gear = col_character(),
  MinimumDepth_Fathoms = col_integer(),
  MaximumDepth_Fathoms = col_integer(),
  Species = col_integer(),
  TaxonomicSerialNumber = col_integer(),
  ScientificName = col_character(),
  TaxonomicNameAuthor = col_character()
))

scot <- rbind(scot_fall, scot_spr, scot_sumr)

# convert mission to haul_id
scot <- scot %>% 
  rename(haulid = Mission, 
         wtcpue = TotalWeightStandardized_KG, 
         stratum = Stratum, 
         year = SurveyYear, 
         season = Season, 
         lat = Latitude_DD, 
         lon = Longitude_DD, 
         depth = MaximumDepth_Fathoms, 
         spp = ScientificName) %>%
  # create placeholder column to fill in with data at the next step
  mutate(stratumarea = NA)

# calculate stratum area for each stratum
strat <- scot %>%
  select(stratum) %>% 
  distinct()

for(i in seq(strat$stratum)){
  temp <- scot %>% 
    filter(stratum == strat$stratum[i]) %>% 
    mutate(area = calcarea(lon, lat))
  scot <- scot %>% 
    mutate(stratumarea = ifelse(stratum == strat$stratum[i], temp$area[1], stratumarea))
}

# are any spp eggs or non-organism notes? As of 2018, nothing stuck out as needing to be removed
# test <- scot %>%
#   select(spp) %>%
#   filter(!is.na(spp)) %>%
#   distinct() %>%
#   mutate(spp = as.factor(spp))

# combine the wtcpue for each species by haul
scot <- scot %>% 
  group_by(haulid, stratum, stratumarea, year, season, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  ungroup() %>% 
  # remove extra columns
  select(haulid, year, lat, lon, stratum, stratumarea, depth, spp, wtcpue, season)

# split out the seasons
scot_sumr <- scot %>% 
  filter(season == "SUMMER") %>% 
  select(-season) %>% 
  mutate(region = "Scotian Shelf Summer")

if (HQ_DATA_ONLY == TRUE){
  # plot the strata by year
  scot_sumr %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  # there is a very faint blip of white in 1984 which is fewer species in a trawl, not a missing trawl.
}  

scot_fall <- scot %>% 
  filter(season == "FALL") %>% 
  select(-season) %>% 
  mutate(region = "Scotian Shelf Fall")

if (HQ_DATA_ONLY == TRUE){
  # plot the strata by year
  scot_fall %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  test <- scot_fall %>% 
    filter(year != 1986, year != 1978) %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>%
    filter(count >= 6)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- scot_fall %>% 
    filter(year != 1986, year != 1978) %>% 
    filter(stratum %in% test$stratum)
  nrow(scot_fall) - nrow(test2)
  # percent that will be lost
  print((nrow(scot_fall) - nrow(test2))/nrow(scot_fall))
  # 9% are removed
  
  scot_fall <- scot_fall  %>%
    filter(year != 1986, year != 1978) %>% 
    filter(stratum %in% test$stratum) 
  
  scot_fall %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
}  

scot_spr <- scot %>% 
  filter(season == "SPRING") %>% 
  select(-season) %>% 
  mutate(region = "Scotian Shelf Spring")


if (HQ_DATA_ONLY == TRUE){
  # plot the strata by year
  scot_spr %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  test <- scot_spr %>% 
    filter(year <= 1984) %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>%
    filter(count >= 6)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- scot_spr %>% 
    filter(year <= 1984) %>% 
    filter(stratum %in% test$stratum)
  nrow(scot_spr) - nrow(test2)
  # percent that will be lost
  print((nrow(scot_spr) - nrow(test2))/nrow(scot_spr))
  # 51% are removed
  
  scot_spr <- scot_spr  %>%
    filter(year <= 1984) %>% 
    filter(stratum %in% test$stratum) 
  
  scot_spr %>% 
    filter(year <= 1984) %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
}  


# Compile TAX ====
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

# Master Data Set ####
dat <- rbind(ai, ebs, goa, neusS, neusF, wctri, wcann, gmex, seusSPRING, seusSUMMER, seusFALL, scot_sumr, scot_fall, scot_spr)

# Remove NA values in wtcpue
dat <- dat %>% 
  filter(!is.na(wtcpue))


# add a nice spp and common name
dat2 <- left_join(dat, select(tax, taxon, name, common), by = c("spp" = "taxon")) 
dat2 <- dat2 %>% 
  select(region, haulid, year, lat, lon, stratum, stratumarea, depth, spp, common, wtcpue)

# check for errors in name matching
if(sum(dat2$spp == 'NA') > 0 | sum(is.na(dat2$spp)) > 0){
  warning('>>create_master_table(): Did not match on some taxon [Variable: `tax`] names.')
}

# replace dat with dat2
dat <- dat2


if(isTRUE(REMOVE_REGION_DATASETS)) {
  rm(ai,ebs,gmex,goa,neus,wcann,wctri, neusF, neusS, seus, seusFALL, seusSPRING, seusSUMMER, scot, scot_fall, scot_spr, scot_sumr)
}

if(isTRUE(OPTIONAL_OUTPUT_DAT_MASTER_TABLE)){
  save(dat, file = paste("trawl_allregions_", Sys.Date(), ".RData", sep = ""))
}

# load(file = "trawl_allregions_2019-01-07.RData")

#At this point, we have a compiled `dat` master table on which we can begin our analysis.
#If you have not cleared the regional datasets {By setting REMOVE_REGION_DATASETS=FALSE at the top}, 
#you are free to do analysis on those sets individually as well.

##FEEL FREE TO ADD, MODIFY, OR DELETE ANYTHING BELOW THIS LINE

# Trim species ####

# Find a standard set of species (present at least 3/4 of the years in a region)
# this result differs from the original code because it does not include any species that have a pres value of 0.  It does, however, include speices for which the common name is NA.
presyr <- dat %>% 
  filter(wtcpue > 0) %>% 
  group_by(region, spp, common, year) %>% 
  summarise(pres = n())

# years in which spp was present
presyrsum <- presyr %>% 
  filter(pres > 0) %>% 
  group_by(region, spp, common) %>% 
  summarise(presyr = n())

# max num years of survey in each region
maxyrs <- presyrsum %>% 
  group_by(region) %>% 
  summarise(maxyrs = max(presyr))

# merge in max years
presyrsum <- left_join(presyrsum, maxyrs, by = "region")

# retain all spp present at least 3/4 of the available years in a survey
spplist <- presyrsum %>% 
  filter(presyr >= (maxyrs * 3/4)) %>% 
  select(region, spp, common)

# Trim dat to these species (for a given region, spp pair in spplist, in dat, keep only rows that match that region, spp pairing)
trimmed_dat <- dat %>% 
  filter(paste(region, spp) %in% paste(spplist$region, spplist$spp))
rm (maxyrs, presyr, presyrsum, spplist)

# BY_SPECIES_DATA ####
# Calculate mean position through time for species 
## Calculate mean latitude and depth of each species by year within each survey/region
### mean lat/lon/depth for each stratum
dat_strat <- trimmed_dat %>% 
  select(stratum, region, lat, lon, depth, stratumarea, haulid) %>% 
  distinct(region, stratum, haulid, .keep_all = T) %>% 
  group_by(stratum, region) %>% 
  summarise(lat = meanna(lat), 
            lon = meanna(lon), 
            depth = meanna(depth), 
            stratumarea = meanna(stratumarea))

### mean wtcpue in each stratum/yr/spp (new code includes more lines because it
### includes rows that do not have a common name)
dat_strat_yr <- trimmed_dat %>% 
  group_by(region, spp, common, stratum, year) %>% 
  summarise(wtcpue = meanna(wtcpue))

# add stratum lat/lon/depth/area
dat_strat_yr <- left_join(dat_strat_yr, dat_strat, by = c("region", "stratum"))

# index of biomass per stratum: mean wtcpue times area
dat_strat_yr <- dat_strat_yr %>% 
  mutate(wttot = wtcpue * stratumarea)

# calculate mean lat
cent_bio_lat <- dat_strat_yr %>% 
  group_by(region, spp, common, year) %>% 
  summarise(lat = questionr::wtd.mean(lat, wttot, na.rm = T))

# mean depth
cent_bio_depth <- dat_strat_yr %>% 
  group_by(region, spp, common, year) %>% 
  summarise(depth = questionr::wtd.mean(depth, wttot, na.rm = T))

# mean lon
cent_bio_lon <- dat_strat_yr %>% 
  group_by(region, spp, common, year) %>% 
  summarise(lon = questionr::wtd.mean(lon, wttot, na.rm = T))

# merge
cent_bio <- left_join(cent_bio_lat, cent_bio_depth, by = c("region", "spp", "common", "year"))
cent_bio <- left_join(cent_bio, cent_bio_lon, by = c("region", "spp", "common", "year"))

# standard error for lat
cent_bio_lat_se <- dat_strat_yr %>%
  group_by(region, spp, year) %>% 
  summarise(lat_se = sqrt(questionr::wtd.var(lat, wttot, na.rm=TRUE, normwt=TRUE))/sqrt(sum(!is.na(lat) & !is.na(wttot))))

cent_bio <- left_join(cent_bio, cent_bio_lat_se, by = c("region", "spp", "year"))

cent_bio_depth_se <- dat_strat_yr %>%
  group_by(region, spp, year) %>% 
  summarise(depth_se = sqrt(questionr::wtd.var(depth, wttot, na.rm=TRUE, normwt=TRUE))/sqrt(sum(!is.na(depth) & !is.na(wttot))))

cent_bio <- left_join(cent_bio, cent_bio_depth_se, by = c("region", "spp", "year"))

cent_bio_lon_se <- dat_strat_yr %>%
  group_by(region, spp, year) %>% 
  summarise(lon_se = sqrt(questionr::wtd.var(lon, wttot, na.rm=TRUE, normwt=TRUE))/sqrt(sum(!is.na(lon) & !is.na(wttot))))

cent_bio <- left_join(cent_bio, cent_bio_lon_se, by = c("region", "spp", "year"))

BY_SPECIES_DATA <- cent_bio %>%
  ungroup() %>% 
  arrange(region, spp, year)

rm(cent_bio, cent_bio_depth, cent_bio_depth_se, cent_bio_lat, cent_bio_lat_se, cent_bio_lon, cent_bio_lon_se, dat_strat, dat_strat_yr, dat2, strat, temp, tax, test, test2)

# #  Add 0's ####
# 
# # no columns are factors
# # test <- sapply(trimmed_dat, is.factor)
# 
# # For every haulid, year, stratum, stratumarea lat lon depth have a species with
# # a wtcpue of the recorded value or zero if that was not observed.
# dat.exploded <- as.data.table(trimmed_dat)
# 
# setorder(dat.exploded, haulid, stratum, year, lat, lon, stratumarea, depth)
# 
# u.spp <- dat.exploded[,as.character(unique(spp))]
# u.cmmn <- dat.exploded[,common[!duplicated(as.character(spp))]]
# 
# x.loc <- dat.exploded[,list(haulid, year, stratum, stratumarea, lat, lon, depth)]
# setkey(x.loc, haulid, year)
# 
# # the following command 
# x.skele <- x.loc[,list(spp=u.spp, common=u.cmmn), by=eval(colnames(x.loc))]
# setkey(x.skele, haulid, year, spp)
# x.skele <- unique(x.skele)
# setcolorder(x.skele, c("haulid","year","spp", "common", "stratum", "stratumarea","lat","lon","depth"))
# 
# x.spp.dat <- dat.exploded[,list(haulid, year, spp, wtcpue)]
# setkey(x.spp.dat, haulid, year, spp)
# x.spp.dat <- unique(x.spp.dat)
# 
# 
# dat.exploded <- left_join(x.skele, x.spp.dat, by = c("haulid", "year", "spp"))
# # test <- x.spp.dat[x.skele]
# 
# dat.exploded <- dat.exploded %>% 
#   mutate(wtcpue = ifelse(is.na(wtcpue), 0, wtcpue))
# rm(x.loc, x.skele, x.spp.dat)
# write_csv(dat.exploded, path = paste0(Sys.Date(), "_dat_exploded.csv"))
# rm(dat.exploded)


#By region data ####
#Requires function species_data's dataset [by default: BY_SPECIES_DATA] or this function will not run properly.
## Calculate mean position through time for regions ####
## Find a standard set of species (present every year in a region)
presyr <- dat %>% 
  filter(wtcpue > 0) %>% 
  group_by(region, spp, year) %>% 
  summarise(pres = n())

# num years in which spp was present
presyrsum <- presyr %>% 
  filter(pres > 0) %>% 
  group_by(region, spp) %>% 
  summarise(presyr = n())

# max num years of survey in each region
maxyrs <- presyrsum %>% 
  group_by(region) %>% 
  summarise(maxyrs = max(presyr))

# merge in max years
presyrsum <- left_join(presyrsum, maxyrs, by = "region") 

# retain all spp present at least once every time a survey occurs
# retain all spp present at least 3/4 of the available years in a survey
spplist <- presyrsum %>% 
  filter(presyr >= (maxyrs * 3/4)) %>% 
  select(region, spp)

# Make a new centbio dataframe for regional use, only has spp in spplist
centbio2 <- BY_SPECIES_DATA %>% 
  filter(paste0(region, spp) %in% paste0(spplist$region, spplist$spp))

# Calculate offsets of lat and depth (start at 0 in initial year of survey)
# find initial year in each region
startyear <- centbio2 %>%
  group_by(region) %>% 
  summarise(startyear = min(year))
# add to dataframe
centbio2 <- left_join(centbio2, startyear, by = "region")
# find starting lat and depth by spp
startpos <- centbio2 %>% 
  ungroup() %>% 
  filter(year == startyear) %>% 
  select(region, spp, lat, lon, depth) %>% 
  rename(startlat = lat, 
         startlon = lon, 
         startdepth = depth)

# add in starting lat and depth
centbio2 <- left_join(centbio2, startpos, by = c("region", "spp")) 

centbio2 <- centbio2 %>% 
  mutate(latoffset = lat - startlat, 
         lonoffset = lon - startlon,
         depthoffset = depth - startdepth)


# Calculate regional average offsets
regcentbio <- centbio2 %>% 
  group_by(year, region) %>% 
  summarise(lat = mean(latoffset), 
            depth = mean(depthoffset), 
            lon = mean(lonoffset))

regcentbiose <- centbio2 %>% 
  group_by(year, region) %>% 
  summarise(lat_se = se(latoffset), 
            depth_se = se(depthoffset), 
            lonse = se(lonoffset))

# calc number of species per region
regcentbiospp <- centbio2 %>% 
  ungroup() %>% 
  select(region, spp) %>% 
  distinct() %>% 
  group_by(region) %>% 
  summarise(numspp = n()) 

regcentbio <- left_join(regcentbio, regcentbiose, by = c("year", "region"))
regcentbio <- left_join(regcentbio, regcentbiospp, by = "region")


# order by region, year
BY_REGION_DATA  <- regcentbio %>% 
  arrange(region, year)

# By national data ####
#Returns national data
#Requires function species_data's dataset [by default: BY_SPECIES_DATA] or this function will not run properly.

## Calculate mean position through time for the US #####


#WHEN USING ENGLISH NAMES FROM add_region_column(), UNCOMMENT NEXT LINE:
regstouse <- c('Eastern Bering Sea', 'Northeast US Spring', 'Northeast US Fall') # Only include regions not constrained by geography in which surveys have consistent methods through time
#WHEN USING DEFAULT NAMES FROM add_region_column(), UN COMMENT NEXT LINE:
#regstouse = c('AFSC_EBS', 'NEFSC_NEUSSpring') # Only include regions not constrained by geography in which surveys have consistent methods through time
natstartyear <- 1982 # a common starting year for the both focal regions

# find the latest year that all regions have in common
maxyrs <- dat %>% 
  filter(region %in% regstouse) %>% 
  group_by(region) %>% 
  summarise(maxyear = max(year))

natendyear <- min(maxyrs$maxyear)

## Find a standard set of species (present every year in the focal regions) for the national analysis
# For national average, start in prescribed year, only use focal regions
# find which species are present in which years
presyr <- dat %>% 
  filter(year >= natstartyear & year <= natendyear,
         region %in% regstouse,
         wtcpue > 0) %>% 
  group_by(region, spp, year) %>% 
  summarise(pres = n())

# num years in which spp was present
presyrsum <- presyr %>% 
  filter(pres > 0) %>% 
  group_by(region, spp) %>% 
  summarise(presyr = n())

# max num years of survey in each region
maxyrs <- presyrsum %>% 
  group_by(region) %>% 
  summarise(maxyears = max(presyr))

# merge in max years
presyrsum <- left_join(presyrsum, maxyrs, by = "region") 

# retain all spp present at least once every time a survey occurs
spplist2 <- presyrsum %>% 
  filter(presyr == maxyears) %>% 
  select(region, spp)

# Make a new centbio dataframe for regional use, only has spp in spplist
centbio3 <- BY_SPECIES_DATA %>% 
  ungroup() %>% 
  filter(paste(region, spp) %in% paste(spplist2$region, spplist2$spp), 
         year >= natstartyear & year <= natendyear) %>% 
  select(region, spp, year, lat, lon, depth)

# Calculate offsets of lat and depth (start at 0 in initial year of survey)
# find initial year in each region
startyear <- centbio3 %>% 
  group_by(region) %>% 
  summarise(startyear = min(year))

# add to dataframe
centbio3 <- left_join(centbio3, startyear, by = "region") 

# find starting lat and depth by spp
startpos <- centbio3 %>% 
  filter(year == startyear) %>% 
  select(region, spp, lat, lon, depth) %>% 
  rename(startlat = lat, 
         startlon = lon, 
         startdepth = depth)

# add in starting lat and depth
centbio3 <- left_join(centbio3, startpos, by = c("region", "spp")) 

centbio3 <- centbio3 %>% 
  mutate(latoffset = lat - startlat,
         lonoffset = lon - startlon,
         depthoffset = depth - startdepth)

# Calculate national average offsets
natcentbio <- centbio3 %>% 
  group_by(year) %>% 
  summarise(lat = mean(latoffset), 
            depth = mean(depthoffset), 
            lon = mean(lonoffset))

natcentbiose <- centbio3 %>% 
  group_by(year) %>% 
  summarise(lat_se = se(latoffset), 
            depth_se = se(depthoffset), 
            lonse = se(lonoffset))

natcentbio <- left_join(natcentbio, natcentbiose, by = "year")

natcentbio$numspp = lunique(paste(centbio3$region, centbio3$spp)) # calc number of species per region  

BY_NATIONAL_DATA <- natcentbio

save(BY_SPECIES_DATA, BY_REGION_DATA, BY_NATIONAL_DATA, file = paste0("centbios", Sys.Date(), ".Rdata"))


if(isTRUE(OPTIONAL_PLOT_CHARTS)) {

# Plot Species #####
  centbio <- BY_SPECIES_DATA

# for latitude
#quartz(width = 10, height = 8)
print("Starting latitude plots for species")
pdf(file=paste("sppcentlatstrat_", Sys.Date(), '.pdf', sep=''), width=10, height=8)

regs = sort(unique(centbio$region))
for(i in 1:length(regs)){
  print(i)
  par(mfrow = c(6,6), mai=c(0.3, 0.3, 0.2, 0.05), cex.main=0.7, cex.axis=0.8, omi=c(0,0.2,0.1,0), mgp=c(2.8, 0.7, 0), font.main=3)
  spps = sort(unique(centbio$spp[centbio$region == regs[i]]))  
  
  xlims = range(as.numeric(centbio$year[centbio$region == regs[i]]))
  
  for(j in 1:length(spps)){
    inds = centbio$spp == spps[j] & centbio$region == regs[i]
    minlat = centbio$lat[inds] - centbio$lat_se[inds]
    maxlat = centbio$lat[inds] + centbio$lat_se[inds]
    minlat[is.na(minlat) | is.infinite(minlat)] = centbio$lat[inds][is.na(minlat) | is.infinite(minlat)] # fill in missing values so that polygon draws correctly
    maxlat[is.na(maxlat) | is.infinite(maxlat)] = centbio$lat[inds][is.na(maxlat) | is.infinite(maxlat)]
    ylims = c(min(minlat, na.rm=TRUE), max(maxlat, na.rm=TRUE))
    
    plot(0,0, type='l', ylab='Latitude (°)', xlab='Year', ylim=ylims, xlim=xlims, main=spps[j], las=1)
    polygon(c(centbio$year[inds], rev(centbio$year[inds])), c(maxlat, rev(minlat)), col='#CBD5E8', border=NA)
    lines(centbio$year[inds], centbio$lat[inds], col='#D95F02', lwd=2)
    
    if((j-1) %% 6 == 0) mtext(text='Latitude (°N)', side=2, line=2.3, cex=0.6)
    if(j %% 36 < 7) mtext(text=regs[i], side=3, line=1.3, cex=0.6)
  }
}

dev.off()

# for depth
print("Starting depth plots for species")
pdf(file=paste('sppcentdepthstrat_', Sys.Date(), '.pdf', sep=''), width=10, height=8)

regs = sort(unique(centbio$region))
for(i in 1:length(regs)){
  print(i)
  par(mfrow = c(6,6), mai=c(0.3, 0.3, 0.2, 0.05), cex.main=0.7, cex.axis=0.8, omi=c(0,0.2,0.1,0), mgp=c(2.8, 0.7, 0), font.main=3)
  spps = sort(unique(centbio$spp[centbio$region == regs[i]]))  
  
  xlims = range(as.numeric(centbio$year[centbio$region == regs[i]]))
  
  for(j in 1:length(spps)){
    inds = centbio$spp == spps[j] & centbio$region == regs[i]
    mindep = centbio$depth[inds] - centbio$depth_se[inds]
    maxdep = centbio$depth[inds] + centbio$depth_se[inds]
    mindep[is.na(mindep) | is.infinite(mindep)] = centbio$depth[inds][is.na(mindep) | is.infinite(mindep)] # fill in missing values so that polygon draws correctly
    maxdep[is.na(maxdep) | is.infinite(maxdep)] = centbio$depth[inds][is.na(maxdep) | is.infinite(maxdep)]
    ylims = c(min(mindep, na.rm=TRUE), max(maxdep, na.rm=TRUE))
    
    plot(0,0, type='l', ylab='Depth (m)', xlab='Year', ylim=ylims, xlim=xlims, main=spps[j], las=1)
    polygon(c(centbio$year[inds], rev(centbio$year[inds])), c(maxdep, rev(mindep)), col='#CBD5E8', border=NA)
    lines(centbio$year[inds], centbio$depth[inds], col='#D95F02', lwd=2)
    
    if((j-1) %% 6 == 0) mtext(text='Depth (m)', side=2, line=2.3, cex=0.6)
    if(j %% 36 < 7) mtext(text=regs[i], side=3, line=1.3, cex=0.6)
  }
}

dev.off()

  
  # Plot Regional ####
  #quartz(width=6, height=6)
  pdf(file=paste('regcentlat_depth_strat_', Sys.Date(), '.pdf', sep=''), width=6, height=6)
  par(mfrow=c(3,3)) # page 1: latitude
  
  regs = sort(unique(regcentbio$region))
  for(i in 1:length(regs)){
    inds = regcentbio$region == regs[i]
    minlat = regcentbio$lat[inds] - regcentbio$lat_se[inds]
    maxlat = regcentbio$lat[inds] + regcentbio$lat_se[inds]
    xlims = range(as.numeric(regcentbio$year[regcentbio$region == regs[i]]))
    ylims = c(min(minlat, na.rm=TRUE), max(maxlat, na.rm=TRUE))
    
    plot(0,0, type='l', ylab='Latitude (°)', xlab='Year', ylim=ylims, xlim=xlims, main=regs[i], las=1)
    polygon(c(regcentbio$year[inds], rev(regcentbio$year[inds])), c(maxlat, rev(minlat)), col='#CBD5E8', border=NA)
    lines(regcentbio$year[inds], regcentbio$lat[inds], col='#D95F02', lwd=2)
  }
  
  par(mfrow=c(3,3)) # page 2: depth
  regs = sort(unique(regcentbio$region))
  for(i in 1:length(regs)){
    inds = regcentbio$region == regs[i]
    mindep = regcentbio$depth[inds] - regcentbio$depth_se[inds]
    maxdep = regcentbio$depth[inds] + regcentbio$depth_se[inds]
    xlims = range(as.numeric(regcentbio$year[regcentbio$region == regs[i]]))
    ylims = c(min(mindep, na.rm=TRUE), max(maxdep, na.rm=TRUE))
    
    plot(0,0, type='l', ylab='Depth (m)', xlab='Year', ylim=ylims, xlim=xlims, main=regs[i], las=1)
    polygon(c(regcentbio$year[inds], rev(regcentbio$year[inds])), c(maxdep, rev(mindep)), col='#CBD5E8', border=NA)
    lines(regcentbio$year[inds], regcentbio$depth[inds], col='#D95F02', lwd=2)
  }
  
  
  dev.off()


  # National
  #quartz(width=6, height=3.5)
  pdf(file=paste('natcentlatstrat_', Sys.Date(), '.pdf', sep=''), width=6, height=3.5)
  par(mfrow=c(1,2), mai=c(0.8, 0.8, 0.3, 0.2), mgp=c(2.4,0.7,0))
  
  minlat = natcentbio$lat - natcentbio$lat_se
  maxlat = natcentbio$lat + natcentbio$lat_se
  mindepth = natcentbio$depth - natcentbio$depth_se
  maxdepth = natcentbio$depth + natcentbio$depth_se
  ylims = c(min(minlat), max(maxlat))
  xlims = range(natcentbio$year)
  plot(0,0, type='l', ylab='Offset in latitude (°)', xlab='Year', ylim=ylims, xlim=xlims, main='Latitude', cex.lab = 1.5, cex.axis=1.2)
  polygon(c(natcentbio$year, rev(natcentbio$year)), c(maxlat, rev(minlat)), col='#CBD5E8', border=NA)
  lines(natcentbio$year, natcentbio$lat, col='#D95F02', lwd=2)
  
  ylims = rev(c(min(mindepth), max(maxdepth)))
  xlims = range(natcentbio$year)
  plot(0,0, type='l', ylab='Offset in depth (m)', xlab='Year', ylim=ylims, xlim=xlims, main='Depth', cex.lab = 1.5, cex.axis=1.2)
  polygon(c(natcentbio$year, rev(natcentbio$year)), c(maxdepth, rev(mindepth)), col='#CBD5E8', border=NA)
  lines(natcentbio$year, natcentbio$depth, col='#D95F02', lwd=2)
  
  dev.off()



