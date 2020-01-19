## ---- oceanadapt

# If running from R instead of RStudio, please set the working directory to the folder containing this script before running this script.
# This script is designed to run within the following directory structure:
# Directory 1 contains:
# 1. compile.R script - this script
# 2. data_raw directory - folder containing all raw data files
# 3. R directory - folder containing scripts used in the making of this script

# The zip file you downloaded created this directory structure for you.

# a note on species name adjustment #### 
# At some point during certain surveys it was realized that what was believed to be one species was actually a different species or more than one species.  Species have been lumped together as a genus in those instances.

# Answer the following questions using all caps TRUE or FALSE to direct the actions of the script =====================================

# 1. Some strata and years have very little data, should they be removed? #DEFAULT: TRUE. 
HQ_DATA_ONLY <- TRUE

# 2. View plots of removed strata for HQ_DATA. #OPTIONAL, DEFAULT:FALSE
# It takes a while to generate these plots.
HQ_PLOTS <- FALSE

# 3. Remove ai,ebs,gmex,goa,neus,seus,wcann,wctri, scot. Keep `dat`. #DEFAULT: FALSE 
REMOVE_REGION_DATASETS <- FALSE

# 4. Create graphs based on the data similar to those shown on the website and outputs them to pdf. #DEFAULT:FALSE
PLOT_CHARTS <- FALSE
# This used to be called OPTIONAL_PLOT_CHARTS, do I need to change it back?

# 5. If you would like to write out the clean data, would you prefer it in Rdata or CSV form?  Note the CSV's are much larger than the Rdata files. #DEFAULT:TRUE, FALSE generates CSV's instead of Rdata.
PREFER_RDATA <- TRUE

# 5. Output the clean full master data frame. #DEFAULT:FALSE
WRITE_MASTER_DAT <- FALSE
# This used to be called OPTIONAL_OUTPUT_DAT_MASTER_TABLE, do I need to change the name back?

# 6. Output the clean trimmed data frame. #DEFAULT:FALSE
WRITE_TRIMMED_DAT <- FALSE

# 7. Generate dat.exploded table. #OPTIONAL, DEFAULT:TRUE
DAT_EXPLODED <- TRUE

# 8. Output the dat.exploded table #DEFAULT:FALSE
WRITE_DAT_EXPLODED <- FALSE

# 9. Output the BY_SPECIES, BY_REGION, and BY_NATIONAL tables. #DEFAULT:FALSE
WRITE_BY_TABLES <- FALSE


# Workspace setup ---------------------------------------------------------
print("Workspace setup")

# This script works best when the repository is downloaded from github, 
# especially when that repository is loaded as a project into RStudio.

# The working directory is assumed to be the OceanAdapt directory of this repository.

library(tidyverse) # use ggplot2, tibble, readr, dplyr, stringr
library(lubridate) # for date manipulation
library(PBSmapping) # for calculating stratum areas 
library(data.table) # for dat.exploded
library(gridExtra) #grid.arrange plots of HQ data
library(questionr) # for the wgtmean function
library(geosphere) # for calculating trawl distance for SEUS 
library(here) # for relative file paths


# Functions ===========================================================
print("Functions")

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

lunique = function(x) length(unique(x)) # number of unique values in a vector

present_every_year <- function(dat, ...){
  presyr <- dat %>% 
    filter(wtcpue > 0) %>% 
    group_by(...) %>% 
    summarise(pres = n())
  return(presyr)
}

num_year_present <- function(presyr, ...){
  presyrsum <- presyr %>% 
    filter(pres > 0) %>% 
    group_by(...) %>% 
    summarise(presyr = n()) 
  return(presyrsum)
}

max_year_surv <- function(presyrsum, ...){
  maxyrs <- presyrsum %>% 
    group_by(...) %>% 
    summarise(maxyrs = max(presyr))
  return(maxyrs)
  
}

explode0 <- function(x, by=c("region")){
  # x <- copy(x)
  stopifnot(is.data.table(x))
  
  # print(x[1])
  
  # x <- as.data.table(x)
  # x <- as.data.table(trimmed_dat)[region=="Scotian Shelf Summer"]
  # setkey(x, haulid, stratum, year, lat, lon, stratum_area, depth)
  # group the data by these columns
  setorder(x, haulid, stratum, year, lat, lon, stratum_area, depth)
  
  # pull out all of the unique spp
  u.spp <- x[,as.character(unique(spp))]
  # pull out all of the unique common names
  u.cmmn <- x[,common[!duplicated(as.character(spp))]]
  
  # pull out these location related columns and sort by haul_id and year
  x.loc <- x[,list(haulid, year, stratum, stratum_area, lat, lon, depth)]
  setkey(x.loc, haulid, year)
  
  # attatch all spp to all locations
  x.skele <- x.loc[,list(spp=u.spp, common=u.cmmn), by=eval(colnames(x.loc))]
  setkey(x.skele, haulid, year, spp)
  x.skele <- unique(x.skele)
  setcolorder(x.skele, c("haulid","year","spp", "common", "stratum", "stratum_area","lat","lon","depth"))
  
  # pull in multiple observations of the same species 
  x.spp.dat <- x[,list(haulid, year, spp, wtcpue)]
  setkey(x.spp.dat, haulid, year, spp)
  x.spp.dat <- unique(x.spp.dat)
  
  out <- x.spp.dat[x.skele, allow.cartesian = TRUE]
  
  out$wtcpue[is.na(out$wtcpue)] <- 0
  
  out
}
  
# Compile AI =====================================================
print("Compile AI")

## Special fix
#there is a comment that contains a comma in the 2014-2018 file that causes the delimiters to read incorrectly.  Fix that here::here:
temp <- read_lines(here::here("data_raw", "ai2014_2018.csv"))
# replace the string that causes the problem
temp_fixed <- stringr::str_replace_all(temp, "Stone et al., 2011", "Stone et al. 2011")
# read the result in as a csv
temp_csv <- read_csv(temp_fixed)
## End special fix

files <- as.list(dir(pattern = "ai", path = "data_raw", full.names = T))

# exclude the strata file and the raw 2014-2016 data file which has been fixed in temp_csv
files <- files[-c(grep("strata", files),grep("2014", files))]

# combine all of the data files into one table
ai_data <- files %>% 
  # read in all of the csv's in the files list
  map_dfr(read_csv) %>%
  # add in the data fixed above
  rbind(temp_csv) %>% 
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE", !is.na(LATITUDE)) %>% 
  mutate(stratum = as.integer(STRATUM)) %>% 
  # remove unused columns
  select(-STATION, -DATETIME, -NUMCPUE, -SID, -BOT_TEMP, -SURF_TEMP, -STRATUM) %>% 
  # remove any extra white space from around spp and common names
  mutate(COMMON = str_trim(COMMON), 
         SCIENTIFIC = str_trim(SCIENTIFIC))

# The warning of 13 parsing failures is pointing to a row in the middle of the data set that contains headers instead of the numbers expected, this row is removed by the filter above.

ai_strata <- read_csv(here::here("data_raw", "ai_strata.csv"), col_types = cols(NPFMCArea = col_character(),
      SubareaDescription = col_character(),
      StratumCode = col_integer(),
      DepthIntervalm = col_character(),
      Areakm2 = col_integer()
    ))  %>% 
      select(StratumCode, Areakm2) %>% 
  mutate(stratum = StratumCode)
    

ai <- left_join(ai_data, ai_strata, by = "stratum")
  
  

# are there any strata in the data that are not in the strata file?
stopifnot(nrow(filter(ai, is.na(Areakm2))) == 0)

# the following chunk of code reformats and fixes this region's data
ai <- ai %>% 
  mutate(
    # Create a unique haulid
    haulid = paste(formatC(VESSEL, width=3, flag=0), CRUISE, formatC(HAUL, width=3, flag=0), sep='-'), 
         # change -9999 wtcpue to NA
         wtcpue = ifelse(WTCPUE == "-9999", NA, WTCPUE)) %>% 
  # rename columns
  rename(year = YEAR, 
         lat = LATITUDE, 
         lon = LONGITUDE, 
         depth = BOT_DEPTH, 
         spp = SCIENTIFIC, 
         stratum_area = Areakm2) %>% 
  # remove rows that are eggs
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
  select(haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue) %>% 
  type_convert(col_types = cols(
    lat = col_double(),
    lon = col_double(),
    year = col_integer(),
    wtcpue = col_double(),
    spp = col_character(),
    depth = col_integer(),
    haulid = col_character()
  )) %>% 
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # Calculate a corrected longitude for Aleutians (all in western hemisphere coordinates)
  ungroup() %>% 
  mutate(lon = ifelse(lon > 0, lon - 360, lon), 
         region = "Aleutian Islands") %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue)

if (HQ_DATA_ONLY == TRUE){
  
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  # plot the strata by year
 p1 <- ai %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p2 <- ai %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
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
  # 0% of rows are removed
  ai <- ai %>% 
    filter(stratum %in% test$stratum)
  
  # plot the results after editing
  p3 <- ai %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p4 <- ai%>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
  temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "ai_hq_dat_removed.pdf"))
    rm(temp)
  }
  rm(test, test2, p1, p2, p3, p4)
}
# clean up
rm(ai_data, ai_strata, files, temp_fixed, temp_csv)

# Compile EBS ============================================================
print("Compile EBS")

files <- as.list(dir(pattern = "ebs", path = "data_raw", full.names = T))

# exclude the strata file
files <- files[-grep("strata", files)]

# combine all of the data files into one table
ebs_data <- files %>% 
  # read in all of the csv's in the files list
  map_dfr(read_csv) %>%
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE", !is.na(LATITUDE)) %>% 
  mutate(stratum = as.integer(STRATUM))  %>% 
  # remove unused columns
  select(-STATION, -DATETIME, -NUMCPUE, -SID, -BOT_TEMP, -SURF_TEMP, -STRATUM) %>% 
  # remove any extra white space from around spp and common names
  mutate(COMMON = str_trim(COMMON), 
         SCIENTIFIC = str_trim(SCIENTIFIC))

# import the strata data
ebs_strata <- read_csv(here::here("data_raw", "ebs_strata.csv"), col_types = cols(
  SubareaDescription = col_character(),
  StratumCode = col_integer(),
  Areakm2 = col_integer()
)) %>% 
  select(StratumCode, Areakm2) %>% 
  rename(stratum = StratumCode)

ebs <- left_join(ebs_data, ebs_strata, by = "stratum")

# are there any strata in the data that are not in the strata file?
stopifnot(nrow(filter(ebs, is.na(Areakm2))) == 0)

ebs <- ebs %>% 
  mutate(
    # Create a unique haulid
    haulid = paste(formatC(VESSEL, width=3, flag=0), CRUISE, formatC(HAUL, width=3, flag=0), sep='-'), 
    # convert -9999 to NA 
    wtcpue = ifelse(WTCPUE == "-9999", NA, WTCPUE)) %>%  
  # rename columns
  rename(year = YEAR, 
         lat = LATITUDE, 
         lon = LONGITUDE, 
         depth = BOT_DEPTH, 
         spp = SCIENTIFIC, 
         stratum_area = Areakm2) %>% 
  # remove eggs
  filter(spp != '' &
           !grepl("egg", spp)) %>% 
  # adjust spp names
  mutate(spp = ifelse(grepl("Atheresthes", spp), "Atheresthes sp.", spp), 
         spp = ifelse(grepl("Lepidopsetta", spp), "Lepidopsetta sp.", spp),
         spp = ifelse(grepl("Myoxocephalus", spp), "Myoxocephalus sp.", spp),
         spp = ifelse(grepl("Bathyraja", spp), 'Bathyraja sp.', spp), 
         spp = ifelse(grepl("Hippoglossoides", spp), "Hippoglossoides sp.", spp)) %>% 
  # change from all character to fitting column types
  type_convert(col_types = cols(
    lat = col_double(),
    lon = col_double(),
    STATION = col_character(),
    year = col_integer(),
    DATETIME = col_character(),
    wtcpue = col_double(),
    NUMCPUE = col_double(),
    COMMON = col_character(),
    spp = col_character(),
    SID = col_integer(),
    depth = col_integer(),
    BOT_TEMP = col_double(),
    SURF_TEMP = col_double(),
    VESSEL = col_integer(),
    CRUISE = col_integer(),
    HAUL = col_integer(),
    haulid = col_character()
  ))  %>%  
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add region column
  mutate(region = "Eastern Bering Sea") %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
 p1 <- ebs %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
 p2 <- ebs %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
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
  # 4% of rows are removed
  ebs <- ebs %>% 
    filter(stratum %in% test$stratum)
  
  p3 <- ebs %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year))) +
    geom_jitter()
  
  p4 <- ebs %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "ebs_hq_dat_removed.pdf"))
    rm(temp)
  }
  rm(test, test2, p1, p2, p3, p4)
}
# clean up
rm(files, ebs_data, ebs_strata)


# Compile GOA =============================================================
print("Compile GOA")

files <- as.list(dir(pattern = "goa", path = "data_raw", full.names = T))

# exclude the 2 strata files; the 1 and 2 elements
files <- files[-grep("strata", files)]

# combine all of the data files into one table
goa_data <- files %>% 
  # read in all of the csv's in the files list
  map_dfr(read_csv) %>%
  # remove any data rows that have headers as data rows
  filter(LATITUDE != "LATITUDE", !is.na(LATITUDE)) %>% 
  mutate(stratum = as.integer(STRATUM)) %>% 
  # remove unused columns
  select(-STATION, -DATETIME, -NUMCPUE, -SID, -BOT_TEMP, -SURF_TEMP, -STRATUM)

# import the strata data
files <- as.list(dir(pattern = "goa_strata", path = "data_raw", full.names = T))

goa_strata <- files %>% 
  # read in all of the csv's in the files list
  map_dfr(read_csv) %>% 
  select(StratumCode, Areakm2) %>% 
  distinct() %>% 
  rename(stratum = StratumCode)

goa <- left_join(goa_data, goa_strata, by = "stratum")

# are there any strata in the data that are not in the strata file?
stopifnot(nrow(filter(goa, is.na(Areakm2))) == 0)



goa <- goa %>%
  mutate(
    # Create a unique haulid
    haulid = paste(formatC(VESSEL, width=3, flag=0), CRUISE, formatC(HAUL, width=3, flag=0), sep='-'),    
    wtcpue = ifelse(WTCPUE == "-9999", NA, WTCPUE)) %>% 
  rename(year = YEAR, 
         lat = LATITUDE, 
         lon = LONGITUDE, 
         depth = BOT_DEPTH, 
         spp = SCIENTIFIC, 
         stratum_area = Areakm2) %>% 
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
  type_convert(col_types = cols(
    lat = col_double(),
    lon = col_double(),
    STATION = col_character(),
    year = col_integer(),
    DATETIME = col_character(),
    wtcpue = col_double(),
    NUMCPUE = col_double(),
    COMMON = col_character(),
    spp = col_character(),
    SID = col_integer(),
    depth = col_integer(),
    BOT_TEMP = col_double(),
    SURF_TEMP = col_double(),
    VESSEL = col_integer(),
    CRUISE = col_integer(),
    HAUL = col_integer(),
    haulid = col_character()
  ))  %>% 
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  mutate(region = "Gulf of Alaska") %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  p1 <- goa %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p2 <- goa %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
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
  # 4% of rows are removed
  goa <- goa %>% 
    filter(stratum %in% test$stratum) %>%
    filter(year != 2001)
  
 p3 <-  goa %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p4 <- goa %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "goa_hq_dat_removed.pdf"))

    rm(temp)
  }
  rm(test, test2, p1, p2, p3, p4)
}
rm(files, goa_data, goa_strata)


# Compile WCTRI ===========================================================
print("Compile WCTRI")

wctri_catch <- read_csv(here::here("data_raw", "wctri_catch.csv"), col_types = cols(
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
  select(CRUISEJOIN, HAULJOIN, VESSEL, CRUISE, HAUL, SPECIES_CODE, WEIGHT)

wctri_haul <- read_csv(here::here("data_raw", "wctri_haul.csv"), col_types = 
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
  select(CRUISEJOIN, HAULJOIN, VESSEL, CRUISE, HAUL, HAUL_TYPE, PERFORMANCE, START_TIME, DURATION, DISTANCE_FISHED, NET_WIDTH, STRATUM, START_LATITUDE, END_LATITUDE, START_LONGITUDE, END_LONGITUDE, STATIONID, BOTTOM_DEPTH)

wctri_species <- read_csv(here::here("data_raw", "wctri_species.csv"), col_types = cols(
  SPECIES_CODE = col_integer(),
  SPECIES_NAME = col_character(),
  COMMON_NAME = col_character(),
  REVISION = col_character(),
  BS = col_character(),
  GOA = col_character(),
  WC = col_character(),
  AUDITJOIN = col_integer()
)) %>% 
  select(SPECIES_CODE, SPECIES_NAME, COMMON_NAME)

# Add haul info to catch data
wctri <- left_join(wctri_catch, wctri_haul, by = c("CRUISEJOIN", "HAULJOIN", "VESSEL", "CRUISE", "HAUL"))
#  add species names
wctri <- left_join(wctri, wctri_species, by = "SPECIES_CODE")


wctri <- wctri %>% 
  # trim to standard hauls and good performance
  filter(HAUL_TYPE == 3 & PERFORMANCE == 0) %>% 
  # Create a unique haulid
  mutate(
    haulid = paste(formatC(VESSEL, width=3, flag=0), formatC(CRUISE, width=3, flag=0), formatC(HAUL, width=3, flag=0), sep='-'), 
    # Extract year where needed
    year = substr(CRUISE, 1, 4), 
    # Add "strata" (define by lat, lon and depth bands) where needed # degree bins # 100 m bins # no need to use lon grids on west coast (so narrow)
    stratum = paste(floor(START_LATITUDE)+0.5, floor(BOTTOM_DEPTH/100)*100 + 50, sep= "-"), 
    # adjust for tow area # weight per hectare (10,000 m2)	
    wtcpue = (WEIGHT*10000)/(DISTANCE_FISHED*1000*NET_WIDTH)
  )

# Calculate stratum area where needed (use convex hull approach)
wctri_strats <- wctri %>% 
  group_by(stratum) %>% 
  summarise(stratum_area = calcarea(START_LONGITUDE, START_LATITUDE))

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
         spp = ifelse(grepl("Bathyraja", spp), 'Bathyraja sp.', spp), 
         spp = ifelse(grepl("Squalus", spp), 'Squalus suckleyi', spp)) %>%
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add region column
  mutate(region = "West Coast Triennial") %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  
  p1 <- wctri %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p2 <- wctri %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
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
  # 23% of rows are removed
  wctri <- wctri %>% 
    filter(stratum %in% test$stratum)
  
  p3 <- wctri %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p4 <- wctri %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
             geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "wctri_hq_dat_removed.pdf"))
    rm(temp)
  }
  rm(test, test2, p1, p2, p3, p4)
}

rm(wctri_catch, wctri_haul, wctri_species, wctri_strats)

# Compile WCANN ===========================================================
print("Compile WCANN")

wcann_catch <- read_csv(unz(here::here("data_raw", "wcann_catch.csv.zip"), "wcann_catch.csv"), col_types = cols(
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
  select("trawl_id","year","longitude_dd","latitude_dd","depth_m","scientific_name","total_catch_wt_kg","cpue_kg_per_ha_der", "partition")

wcann_haul <- read_csv(here::here("data_raw", "wcann_haul.csv"), col_types = cols(
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
# It is ok to get warning message that missing column names filled in: 'X1' [1].

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
  summarise(stratum_area = calcarea(longitude_dd, latitude_dd), na.rm = T)

wcann <- left_join(wcann, wcann_strats, by = "stratum")

wcann <- wcann %>% 
  rename(lat = latitude_dd, 
         lon = longitude_dd, 
         depth = depth_m, 
         spp = scientific_name) %>% 
  # remove non-fish
  filter(!grepl("Egg", partition), 
         !grepl("crushed", spp)) %>% 
  # adjust spp names
  mutate(
    spp = ifelse(grepl("Lepidopsetta", spp), "Lepidopsetta sp.", spp),
    spp = ifelse(grepl("Bathyraja", spp), 'Bathyraja sp.', spp)
  ) %>%
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add region column
  mutate(region = "West Coast Annual") %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue) %>% 
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
  p1 <- wcann %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p2 <- wcann %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, nrow = 2)
      ggsave(plot = temp, filename = here::here("plots", "wcann_hq_dat_removed.pdf"))
      rm(temp)
  }
  rm(p1, p2)
}

# cleanup
rm(wcann_catch, wcann_haul, wcann_strats)

# Compile GMEX ===========================================================
print("Compile GMEX")

gmex_station_raw <- read_lines(here::here("data_raw", "gmex_STAREC.csv"))
# remove oddly quoted characters
gmex_station_clean <- str_replace_all(gmex_station_raw, "\\\\\\\"", "\\\"\\\"") %>% 
  str_replace(., "HAULVALUE\",", "HAULVALUE\"")
gmex_station <- read_csv(gmex_station_clean) %>% 
  select(STATIONID, CRUISEID, CRUISE_NO, P_STA_NO, TIME_ZN, TIME_MIL, S_LATD, S_LATM, S_LOND, S_LONM, E_LATD, E_LATM, E_LOND, E_LONM, DEPTH_SSTA, MO_DAY_YR, VESSEL_SPD, COMSTAT, HAULVALUE) 
# %>% 
#   filter(HAULVALUE == "G")
print("imported gmex_station")

# remove extra comma from first row that causes problems in the parsing
gmex_tow_raw <- read_lines(here::here("data_raw", "gmex_INVREC.csv")) %>% 
  str_replace(., "COMBIO\",", "COMBIO\"")
gmex_tow <-read_csv(gmex_tow_raw) %>%
  select('STATIONID', 'CRUISE_NO', 'P_STA_NO', 'INVRECID', 'GEAR_SIZE', 'GEAR_TYPE', 'MESH_SIZE', 'MIN_FISH', 'OP') %>%
  filter(GEAR_TYPE=='ST')
print("imported gmex_tow, 2 parsing failures for COMBIO delimiter are ok")

# remove extra comma from first row that causes problems in the parsing
gmex_spp_raw <- read_lines(here::here("data_raw","gmex_NEWBIOCODESBIG.csv")) %>% 
  str_replace(., "tsn_accepted\",", "tsn_accepted\"")
gmex_spp <-read_csv(gmex_spp_raw)
print("imported gmex_spp")

# remove extra comma from first row that causes problems in the parsing
gmex_cruise_raw <- read_lines(here::here("data_raw", "gmex_CRUISES.csv")) %>% 
  str_replace(., "NGEST_PROGRAM_VER\",", "NGEST_PROGRAM_VER\"")
gmex_cruise <-read_csv(gmex_cruise_raw) %>% 
  select(CRUISEID, VESSEL, TITLE)
print("imported gmex_cruise")

# remove extra comma from first row that causes problems in the parsing
gmex_bio_raw <- read_lines(unz(here::here("data_raw", "gmex_BGSREC.csv.zip"), "gmex_BGSREC.csv")) %>% 
  str_replace(., "INVRECID\",", "INVRECID\"")
gmex_bio <-read_csv(gmex_bio_raw, col_types = cols(.default = col_character())) %>% 
  select(CRUISEID, STATIONID, VESSEL, CRUISE_NO, P_STA_NO, GENUS_BGS, SPEC_BGS, BGSCODE, BIO_BGS, SELECT_BGS) %>%
  # trim out young of year records (only useful for count data) and those with UNKNOWN species
  filter(BGSCODE != "T" | is.na(BGSCODE),
         GENUS_BGS != "UNKNOWN" | is.na(GENUS_BGS))  %>%
  # remove the few rows that are still duplicates
  distinct()

gmex_bio <- type_convert(gmex_bio, cols(
  CRUISEID = col_integer(),
  STATIONID = col_integer(),
  VESSEL = col_character(),
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
  tsn = NA, 
  tsn_accepted = NA) 

# remove the duplicates that were just combined  
gmex_spp <- gmex_spp %>% 
  distinct(CODE, .keep_all = T)
# add the combined records on to the end. trim out extra columns from gmexspp
gmex_spp <- rbind(gmex_spp, newspp) %>% 
  select(CODE, TAXONOMIC) %>% 
  rename(BIO_BGS = CODE)

# merge tow information with catch data, but only for shrimp trawl tows (ST)
gmex <- left_join(gmex_bio, gmex_tow, by = c("STATIONID", "CRUISE_NO", "P_STA_NO")) %>% 
  # add station location and related data
  left_join(gmex_station, by = c("CRUISEID", "STATIONID", "CRUISE_NO", "P_STA_NO")) %>% 
  # add scientific name
  left_join(gmex_spp, by = "BIO_BGS") %>% 
  # add cruise title
  left_join(gmex_cruise, by = c("CRUISEID", "VESSEL"))


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
  summarise(stratum_area = calcarea(lon, lat))
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
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add region column
  mutate(region = "Gulf of Mexico") %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue) %>% 
  ungroup()

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  p1 <- gmex %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p2 <- gmex %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
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
  # lose 19% of rows
  gmex <- gmex %>%
    filter(stratum %in% test$stratum) %>% 
    filter(year >= 2008, year != 2018) 
  
  p3 <- gmex %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p4 <- gmex %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "gmex_hq_dat_removed.pdf"))
    rm(temp)
  }
  rm(test, test2, p1, p2, p3, p4)
}
rm(gmex_bio, gmex_cruise, gmex_spp, gmex_station, gmex_tow, newspp, problems, gmex_station_raw, gmex_station_clean, gmex_strats, dups)

# Compile NEUS SPRING ===========================================================
# process spp file

load(here::here("data_raw", "neus_SVSPP.RData"))
neus_spp <- spp %>% 
  # remove some columns from spp data
  select(-ITISSPP, -COMNAME, -AUTHOR) %>% 
  mutate(SCINAME = as.character(SCINAME))

files <- as.list(dir(pattern = "neus_strata", path = "data_raw", full.names = T))

neus_strata <- read_csv(here::here("data_raw", "neus_strata.csv")) %>% 
  select(stratum, stratum_area) %>% 
  distinct()

print("Compile NEUS SPRING")

## Special fix
#there is a comment that contains a comma in the svcat.csv file that causes the delimiters to read incorrectly.
temp <- read_lines(here::here("data_raw", "neus_spring_svcat.csv"))
temp_fixed <- stringr::str_replace_all(temp, "SQUID, CUTTLEFISH, AND OCTOPOD UNCL", "SQUID CUTTLEFISH AND OCTOPOD UNCL")
temp_fixed2 <- stringr::str_replace_all(temp_fixed, "SHRIMP \\(PINK,BROWN,WHITE\\)", "SHRIMP PINK BROWN WHITE")
temp_fixed3 <- stringr::str_replace_all(temp_fixed2, "SHRIMP \\(PINKBROWNWHITE\\) UNCL", "SHRIMP PINK BROWN WHITE UNCL")
neus_spr_catch <- read_csv(temp_fixed3, col_types = cols(
  CRUISE6 = col_character(),
  STRATUM = col_character(),
  TOW = col_character(),
  STATION = col_character(),
  ID = col_character(),
  LOGGED_SPECIES_NAME = col_character(),
  SVSPP = col_double(),
  CATCHSEX = col_double(),
  EXPCATCHNUM = col_double(),
  EXPCATCHWT = col_double()
))
rm(temp, temp_fixed, temp_fixed2, temp_fixed3)

neus_spr_station <- read_csv(here::here("data_raw", "neus_spring_svsta.csv"), col_types = cols(.default = col_character()))

neus_spr_survdat <- left_join(neus_spr_catch, neus_spr_station, by = c("CRUISE6", "STRATUM", "TOW", "STATION", "ID")) %>% 
  select(ID, CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX, SVVESSEL, EST_YEAR, DECDEG_BEGLAT, DECDEG_BEGLON,  AVGDEPTH, SURFTEMP, SURFSALIN, BOTTEMP, BOTSALIN, EXPCATCHWT) %>% 
  distinct() %>% 
  rename(YEAR = EST_YEAR, 
         LAT = DECDEG_BEGLAT,
         LON = DECDEG_BEGLON, 
         DEPTH = AVGDEPTH, 
         BIOMASS = EXPCATCHWT) %>% 
  # sum different sexes of same spp together
  group_by(ID,YEAR, LAT, LON, DEPTH, CRUISE6, STATION, STRATUM, SVSPP) %>% 
  summarise(wtcpue = sum(BIOMASS)) 

neus_spr <- left_join(neus_spr_survdat, neus_spp, by = "SVSPP") %>%
  left_join(neus_strata, by = c("STRATUM" = "stratum"))

neus_spr <- neus_spr %>%
  mutate(
    # Create a unique haulid
    haulid = str_c(str_sub(ID, 1,6),"-", str_sub(ID, -4), "-", str_sub(ID, 7,11)), 
    # Calculate stratum area where needed (use convex hull approach)
    # convert square nautical miles to square kilometers
    stratum_area = stratum_area * 3.429904) %>% 
  rename(year = YEAR,
         spp = SCINAME,
         lat = LAT, 
         lon = LON, 
         depth = DEPTH,
         stratum = STRATUM) %>%
  filter(
    # per neus data steward strata 07940 and 07980 should not be used because they are undefined and should not have been included in the public dataset
    stratum != "07940",
    stratum != "07980",
    # remove unidentified spp and non-species
    spp != "" | !is.na(spp), 
    !grepl("EGG", spp), 
    !grepl("UNIDENTIFIED", spp)) %>%
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add temporary region column (this will be replaced with seasonal name)
  mutate(region = "Northeast US") %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue) %>% 
  ungroup() %>% 
  mutate(region = "Northeast US Spring")

# are there any strata in the data that are not in the strata file?
# stopifnot(nrow(filter(neus_spr, is.na(stratum_area))) == 0)

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  p1 <-neus_spr %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p2 <- neus_spr %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  # for neus Spring, right away it is apparent that 1972 and earlier be eliminated
  neus_spr <- neus_spr %>% 
    filter(year > 1972)
  
  # it's hard to read the strata labels so I'm finding them here::here
  test <- neus_spr %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>%
    filter(count < 40)
  
  neus_spr <- neus_spr %>%
    filter(!stratum %in% test$stratum)
  
  # check by year
  test <- neus_spr %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(year) %>% 
    summarise(count = n()) %>%
    filter(count > 67)
  
  neus_spr <- neus_spr %>%
    filter(year %in% test$year)
  
  p3 <- neus_spr %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p4 <- neus_spr %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "neus_spr_hq_dat_removed.pdf"))
    rm(temp)
  }
  rm(test, p1, p2, p3, p4)
}

# Compile NEUS FALL ===========================================================
print("Compile NEUS FALL")
temp <- read_lines(here::here("data_raw", "neus_fall_svcat.csv"))
temp_fixed <- stringr::str_replace_all(temp, "SQUID, CUTTLEFISH, AND OCTOPOD UNCL", "SQUID CUTTLEFISH AND OCTOPOD UNCL")
temp_fixed2 <- stringr::str_replace_all(temp_fixed, "SHRIMP \\(PINK,BROWN,WHITE\\)", "SHRIMP PINK BROWN WHITE")
temp_fixed3 <- stringr::str_replace_all(temp_fixed2, "SHRIMP \\(PINKBROWNWHITE\\) UNCL", "SHRIMP PINK BROWN WHITE UNCL")
temp_fixed4 <- stringr::str_replace_all(temp_fixed3, "SEA STAR, BRITTLE STAR, AND BASKETSTAR UNCL", "SEA STAR BRITTLE STAR AND BASKETSTAR UNCL")
temp_fixed5 <- stringr::str_replace_all(temp_fixed4, "MOON SNAIL, SHARK EYE, AND BABY-EAR UNCL", "MOON SNAIL SHARK EYE AND BABY EAR UNCL")
neus_fall_catch <- read_csv(temp_fixed5, col_types = cols(
  CRUISE6 = col_character(),
  STRATUM = col_character(),
  TOW = col_character(),
  STATION = col_character(),
  ID = col_double(),
  LOGGED_SPECIES_NAME = col_character(),
  SVSPP = col_double(),
  CATCHSEX = col_double(),
  EXPCATCHNUM = col_double(),
  EXPCATCHWT = col_double()
))
rm(temp, temp_fixed, temp_fixed2, temp_fixed3, temp_fixed4, temp_fixed5)
# End special fix


neus_fall_station <- read_csv(here::here("data_raw", "neus_fall_svsta.csv"), col_types = cols(.default = col_character()))

neus_fall_survdat <- right_join(neus_fall_station, neus_fall_catch, by = c("CRUISE6", "STRATUM", "TOW", "STATION", "ID")) %>% 
  select(CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX, SVVESSEL, EST_YEAR, DECDEG_BEGLAT, DECDEG_BEGLON,  AVGDEPTH, SURFTEMP, SURFSALIN, BOTTEMP, BOTSALIN, EXPCATCHWT) %>% 
  distinct() %>% 
  rename(YEAR = EST_YEAR, 
         LAT = DECDEG_BEGLAT,
         LON = DECDEG_BEGLON, 
         DEPTH = AVGDEPTH, 
         BIOMASS = EXPCATCHWT) %>% 
  # sum different sexes of same spp together
  group_by(YEAR, LAT, LON, DEPTH, CRUISE6, STATION, STRATUM, SVSPP) %>% 
  summarise(wtcpue = sum(BIOMASS))

neus_fall <- left_join(neus_spr_survdat, neus_spp, by = "SVSPP") %>%
  left_join(neus_strata, by = "STRATUM")

# are there any strata in the data that are not in the strata file?
# stopifnot(nrow(filter(neus_fall, is.na(STRATUM_AREA))) == 0)

neus_fall <- neus_fall %>%
  mutate(
    # Create a unique haulid
    haulid = str_c(str_sub(ID, 1,6),"-", str_sub(ID, -4), "-", str_sub(ID, 7,11)), 
    # Calculate stratum area where needed (use convex hull approach)
    # convert square nautical miles to square kilometers
    stratum_area = stratum_area * 3.429904) %>% 
  rename(year = YEAR,
         spp = SCINAME,
         lat = LAT, 
         lon = LON, 
         depth = DEPTH,
         stratum = STRATUM) %>%
  filter(
    # per neus data steward strata 07940 and 07980 should not be used because they are undefined and should not have been included in the public dataset
    stratum != "07940",
    stratum != "07980",
    # remove unidentified spp and non-species
    spp != "" | !is.na(spp), 
    !grepl("EGG", spp), 
    !grepl("UNIDENTIFIED", spp)) %>%
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add temporary region column (this will be replaced with seasonal name)
  mutate(region = "Northeast US") %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue) %>% 
  ungroup()  %>% 
  mutate(region = "Northeast US Fall")

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  
  p1 <- neus_fall %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year))) +
    geom_jitter()
  
  p2 <- neus_fall %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  test <- neus_fall %>% 
    filter(year != 2017, year >= 1972) %>% 
    select(stratum, year) %>% 
    distinct() %>% 
    group_by(stratum) %>% 
    summarise(count = n()) %>%
    filter(count >= 45)
  
  # how many rows will be lost if only stratum trawled ever year are kept?
  test2 <- neus_fall %>% 
    filter(year != 2017, year >= 1972) %>% 
    filter(stratum %in% test$stratum)
  nrow(neus_fall) - nrow(test2)
  # percent that will be lost
  (nrow(neus_fall) - nrow(test2))/nrow(neus_fall)
  # 60% is too much, by removing bad years we get rid of 9%, which is not so bad.
  # When bad strata are removed after bad years we only lose 37%
  
  neus_fall <- neus_fall %>%
    filter(year != 2017, year >= 1972) %>% 
    filter(stratum %in% test$stratum) 
  
  p3 <- neus_fall %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p4 <- neus_fall %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "neus_fall_hq_dat_removed.pdf"))
    rm(temp)
  }
  rm(test, test2, p1, p2, p3, p4)
}
rm(neus_spp, neus_strata, neus_survdat, neus, survdat, spp,  files)

# Compile SEUS ===========================================================
print("Compile SEUS")
# turns everything into a character so import as character anyway
seus_catch <- read_csv(unz(here::here("data_raw", "seus_catch.csv.zip"), "seus_catch.csv"), col_types = cols(.default = col_character())) %>% 
  # remove symbols
  mutate_all(list(~str_replace(., "=", ""))) %>% 
  mutate_all(list(~str_replace(., '"', ''))) %>% 
  mutate_all(list(~str_replace(., '"', '')))

# The 9 parsing failures are due to the metadata at the end of the file that does not fit into the data columns

# problems should have 0 obs
problems <- problems(seus_catch) %>% 
  filter(!is.na(col))
stopifnot(nrow(problems) == 0)

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

seus_haul <- read_csv(here::here("data_raw", "seus_haul.csv"), col_types = cols(.default = col_character())) %>% 
  distinct(EVENTNAME, DEPTHSTART)  %>% 
  # remove symbols
  mutate_all(list(~str_replace(., "=", ""))) %>% 
  mutate_all(list(~str_replace(., '"', ''))) %>% 
  mutate_all(list(~str_replace(., '"', '')))

# problems should have 0 obs
problems <- problems(seus_haul) %>% 
  filter(!is.na(col))
stopifnot(nrow(problems) == 0)

seus_haul <- type_convert(seus_haul, col_types = cols(
  EVENTNAME = col_character(),
  DEPTHSTART = col_integer()
))


# contains strata areas
seus_strata <- read_csv(here::here("data_raw", "seus_strata.csv"), col_types = cols(
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
  summarise(mean_wt = mean(SPECIESTOTALWEIGHT, na.rm = T))

# rows that need to be changed
change <- seus %>%
  filter(is.na(SPECIESTOTALWEIGHT))

# remove those rows from SEUS
seus <- anti_join(seus, change)

# change the rows
change <- change %>% 
  select(-SPECIESTOTALWEIGHT)

# update the column values
change <- left_join(change, meanwt, by = "SPECIESCODE") %>% 
  rename(SPECIESTOTALWEIGHT = mean_wt)

# rejoin to the data
seus <- rbind(seus, change)


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
start <- as.matrix(seus[,c("LONGITUDESTART", "LATITUDESTART")], nrow = nrow(seus), ncol = 2)
# create a matrix of ending positions
end <- as.matrix(seus[,c("LONGITUDEEND", "LATITUDEEND")], nrow = nrow(seus), ncol = 2)
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
    stratum_area = STRATAHECTARE)

#In seus there are two 'COLLECTIONNUMBERS' per 'EVENTNAME', with no exceptions; EFFORT is always the same for each COLLECTIONNUMBER
# We sum the two tows in seus
biomass <- seus %>% 
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, SEASON, spp, EFFORT) %>% 
  summarise(biomass = sum(SPECIESTOTALWEIGHT)) %>% 
  mutate(wtcpue = biomass/(EFFORT*2))

seus <- left_join(seus, biomass, by = c("haulid", "stratum", "stratum_area", "year", "lat", "lon", "depth", "SEASON", "spp", "EFFORT"))
# double check that column numbers haven't changed by more than 2.  

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
  group_by(haulid, stratum, stratum_area, year, lat, lon, depth, spp, SEASON) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  # add temporary region column that will be converted to seasonal
  mutate(region = "Southeast US") %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue, SEASON) %>% 
  ungroup()

# now that lines have been removed from the main data set, can split out seasons
# SEUS spring ====
#Separate the the spring season and convert to dataframe
seusSPRING <- seus %>% 
  filter(SEASON == "spring") %>% 
  select(-SEASON) %>% 
  mutate(region = "Southeast US Spring")

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  
  p1 <- seusSPRING %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year))) +
    geom_jitter()
  
  p2 <- seusSPRING %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
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
  
  p3 <- seusSPRING %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p4 <- seusSPRING %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "seusSPR_hq_dat_removed.pdf"))
    rm(temp)
  }
  rm(test, p1, p2, p3, p4)
}

# SEUS summer ====
#Separate the summer season and convert to dataframe
seusSUMMER <- seus %>% 
  filter(SEASON == "summer") %>% 
  select(-SEASON) %>% 
  mutate(region = "Southeast US Summer")

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  p1 <- seusSUMMER %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year))) +
    geom_jitter()
  
  p2 <- seusSUMMER %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "seusSUM_hq_dat_removed.pdf"))
    rm(temp)
  }
  rm(p1, p2)
}
  # no missing data

# SEUS fall ====
seusFALL <- seus %>% 
  filter(SEASON == "fall") %>% 
  select(-SEASON) %>% 
  mutate(region = "Southeast US Fall")

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense
  
  
  p1 <- seusFALL %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year))) +
    geom_jitter()
  
  p2 <- seusFALL %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
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
  
  p3 <- seusFALL %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  
  p4 <- seusFALL %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  
  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "seusFALL_hq_dat_removed.pdf"))
    rm(temp)
  }
  rm(test, test2, p1, p2, p3, p4)
}

rm(seus_catch, seus_haul, seus_strata, end, start, meanwt, misswt, biomass, problems, change, seus)


# Compile Scotian Shelf ---------------------------------------------------
print("Compile SCOT")

files <- as.list(dir(pattern = "scot", path = "data_raw", full.names = T))

scot <- files %>% 
  map_dfr(~ read_csv(.x, col_types = cols(
    .default = col_double(),
    MISSION = col_character(),
    SEASON = col_character(),
    SURVEYDATE = col_character(),
    GEAR = col_character(),
    SCIENTIFICNAME = col_character(),
    TAXONOMICNAMEAUTHOR = col_character()
  ))) 

names(scot) <- tolower(names(scot))

scot <- scot %>% 
  # convert mission to haul_id
  rename(haulid = mission, 
         wtcpue = totalweightstandardized_kg, 
         year = surveyyear, 
         season = season, 
         lat = latitude_dd, 
         lon = longitude_dd, 
         depth = maximumdepth_fathoms, 
         spp = scientificname) %>% 
  # include stratum in the haul_id
  mutate(haulid = paste(haulid, stratum, depth, sep = "_"))



# calculate stratum area for each stratum
scot <- scot %>% 
  group_by(stratum) %>% 
  mutate(stratum_area = calcarea(lon, lat)) %>% 
  ungroup()


# Does the spp column contain any eggs or non-organism notes? As of 2019, nothing stuck out as needing to be removed
test <- scot %>%
  select(spp) %>%
  filter(!is.na(spp)) %>%
  distinct() %>%
  mutate(spp = as.factor(spp)) %>% 
  filter(grepl("egg", spp) & grepl("", spp))
stopifnot(nrow(test)==0)


# combine the wtcpue for each species by haul
scot <- scot %>% 
  group_by(haulid, stratum, stratum_area, year, season, lat, lon, depth, spp) %>% 
  summarise(wtcpue = sumna(wtcpue)) %>% 
  ungroup() %>% 
  # remove extra columns
  select(haulid, year, lat, lon, stratum, stratum_area, depth, spp, wtcpue, season)

# split out the seasons
# Scotian Summer ####
scot <- scot %>% 
  filter(season == "SUMMER") %>% 
  select(-season) %>% 
  mutate(region = "Scotian Shelf")

if (HQ_DATA_ONLY == TRUE){
  # look at the graph and make sure decisions to keep or eliminate data make sense

    # plot the strata by year
  p1 <- scot %>% 
    select(stratum, year) %>% 
    ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
    geom_jitter()
  p2 <- scot %>%
    select(lat, lon) %>% 
    ggplot(aes(x = lon, y = lat)) +
    geom_jitter()
  

  if (HQ_PLOTS == TRUE){
    temp <- grid.arrange(p1, p2, nrow = 2)
    ggsave(plot = temp, filename = here::here("plots", "scot-hq_dat_removed.pdf"))
  }
}  

# Scotian Fall ####
# scot_fall <- scot %>% 
#   filter(season == "FALL") %>% 
#   select(-season) %>% 
#   mutate(region = "Scotian Shelf Fall")
# 
# if (HQ_DATA_ONLY == TRUE){
#   # plot the strata by year
#   p1 <- scot_fall %>% 
#     select(stratum, year) %>% 
#     ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
#     geom_jitter()
#   
#   p2 <- scot_fall %>%
#     select(lat, lon) %>% 
#     ggplot(aes(x = lon, y = lat)) +
#     geom_jitter()
#   
#   # find strata sampled every year 
#   annual_strata <- scot_fall %>% 
#     filter(year != 1986, year != 1978) %>% 
#     select(stratum, year) %>% 
#     distinct() %>% 
#     group_by(stratum) %>% 
#     summarise(count = n()) %>%
#     filter(count >= 6)
#   
#   # how many rows will be lost if only stratum trawled ever year are kept?
#   test <- scot_fall %>% 
#     filter(year != 1986, year != 1978) %>% 
#     filter(stratum %in% annual_strata$stratum)
#   nrow(scot_fall) - nrow(test)
#   # percent that will be lost
#   print((nrow(scot_fall) - nrow(test))/nrow(scot_fall))
#   # 19% are removed
#   
#   scot_fall <- scot_fall  %>%
#     filter(year != 1986, year != 1978) %>% 
#     filter(stratum %in% annual_strata$stratum) 
#   
#   p3 <- scot_fall %>% 
#     select(stratum, year) %>% 
#     ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
#     geom_jitter()
#   
#   p4 <- scot_fall %>%
#     select(lat, lon) %>% 
#     ggplot(aes(x = lon, y = lat)) +
#     geom_jitter()
#   
#   if (HQ_PLOTS == TRUE){
#     temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
#       ggsave(plot = temp, filename = here::here("plots", "scot_fall-hq_dat_removed.pdf"))
#   }
# }  
# 
# # Scotian Spring ####
# scot_spr <- scot %>% 
#   filter(season == "SPRING") %>% 
#   select(-season) %>% 
#   mutate(region = "Scotian Shelf Spring")
# 
# 
# if (HQ_DATA_ONLY == TRUE){
#   # plot the strata by year
#   p1 <- scot_spr %>% 
#     select(stratum, year) %>% 
#     ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
#     geom_jitter()
#   
#   p2 <- scot_spr %>%
#     select(lat, lon) %>% 
#     ggplot(aes(x = lon, y = lat)) +
#     geom_jitter()
#   
#   test <- scot_spr %>% 
#     filter(year <= 1984) %>% 
#     select(stratum, year) %>% 
#     distinct() %>% 
#     group_by(stratum) %>% 
#     summarise(count = n()) %>%
#     filter(count >= 6)
#   
#   # how many rows will be lost if only stratum trawled ever year are kept?
#   test2 <- scot_spr %>% 
#     filter(year <= 1984) %>% 
#     filter(stratum %in% test$stratum)
#   nrow(scot_spr) - nrow(test2)
#   # percent that will be lost
#   print((nrow(scot_spr) - nrow(test2))/nrow(scot_spr))
#   # 58% are removed
#   
#   scot_spr <- scot_spr  %>%
#     filter(year <= 1984) %>% 
#     filter(stratum %in% test$stratum) 
#   
#   p3 <- scot_spr %>% 
#     filter(year <= 1984) %>% 
#     select(stratum, year) %>% 
#     ggplot(aes(x = as.factor(stratum), y = as.factor(year)))   +
#     geom_jitter()
#   
#   p4 <- scot_spr %>%
#     select(lat, lon) %>% 
#     ggplot(aes(x = lon, y = lat)) +
#     geom_jitter()
#   
#   if (HQ_PLOTS == TRUE){
#     temp <- grid.arrange(p1, p2, p3, p4, nrow = 2)
#     ggsave(plot = temp, filename = here::here("plots", "scot_spr-hq_dat_removed.pdf"))
#     rm(temp)
#   }
#   rm(p1, p2, p3, p4, test, test2)
# }  

rm(files, temp)

# Because scot_fall and scot_spring are rare surveys, only use scot_summer


# Compile TAX ===========================================================
print("Compile TAX")
tax <- read_csv(here::here("data_raw", "spptaxonomy.csv"), col_types = cols(
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
)) %>% 
  select(taxon, name, common)


if(isTRUE(WRITE_MASTER_DAT)){
save(ai, ebs, gmex, goa, neus_fall, neus_spr, scot, seusFALL, seusSPRING, seusSUMMER, tax, wcann, wctri, file = here("data_clean", "individual-regions.rda"))
}

# Master Data Set ===========================================================
print("Join into Master Data Set")
dat <- rbind(ai, ebs, goa, neus_spr, neus_fall, wctri, wcann, gmex, seusSPRING, seusSUMMER, seusFALL, scot) %>% 
# Remove NA values in wtcpue
  filter(!is.na(wtcpue))

# add a case sensitive spp and common name
dat <- left_join(dat, tax, by = c("spp" = "taxon")) %>% 
  select(region, haulid, year, lat, lon, stratum, stratum_area, depth, name, common, wtcpue) %>% 
  distinct() %>% 
  rename(spp = name)

# check for errors in name matching
if(sum(dat$spp == 'NA') > 0 | sum(is.na(dat$spp)) > 0){
  warning('>>create_master_table(): Did not match on some taxon [Variable: `tax`] names.')
}

if(isTRUE(REMOVE_REGION_DATASETS)) {
  rm(ai,ebs,gmex,goa,neus,wcann,wctri, neus_fall, neus_spr, seus, seusFALL, seusSPRING, seusSUMMER, scot, tax)
}

if(isTRUE(WRITE_MASTER_DAT)){
  if(isTRUE(PREFER_RDATA)){
    saveRDS(dat, file = here::here("data_clean", "all-regions-full.rds"))
  }else{
    write_csv(dat, here::here("data_clean", "all-regions-full.csv"))
  }
}

# At this point, we have a compiled `dat` master table on which we can begin our analysis.

# If you have not cleared the regional datasets {By setting REMOVE_REGION_DATASETS=FALSE at the top}, 
#you are free to do analysis on those sets individually as well.

##FEEL FREE TO ADD, MODIFY, OR DELETE ANYTHING BELOW THIS LINE

# Trim species ===========================================================
print("Trim species")

# Find a standard set of species (present at least 3/4 of the years in a region)
# this result differs from the original code because it does not include any species that have a pres value of 0.  It does, however, include speices for which the common name is NA.
presyr <- present_every_year(dat, region, spp, common, year) 

# years in which spp was present
presyrsum <- num_year_present(presyr, region, spp, common)

# max num years of survey in each region
maxyrs <- max_year_surv(presyrsum, region)

# merge in max years
presyrsum <- left_join(presyrsum, maxyrs, by = "region")

# retain all spp present at least 3/4 of the available years in a survey
spplist <- presyrsum %>% 
  filter(presyr >= (maxyrs * 3/4)) %>% 
  select(region, spp, common)

# Trim dat to these species (for a given region, spp pair in spplist, in dat, keep only rows that match that region, spp pairing)
trimmed_dat <- dat %>% 
  filter(paste(region, spp) %in% paste(spplist$region, spplist$spp)) %>% 
  # some spp have whitespace - this should potentially be moved up to NEUS section
  mutate(
    spp = ifelse(grepl("LIMANDA FERRUGINEA", spp), "LIMANDA FERRUGINEA", spp),
    spp = ifelse(grepl("PSEUDOPLEURONECTES AMERICANUS", spp), "PSEUDOPLEURONECTES AMERICANUS", spp))

rm (maxyrs, presyr, presyrsum, spplist)

if(isTRUE(WRITE_TRIMMED_DAT)){
  if(isTRUE(PREFER_RDATA)){
    saveRDS(trimmed_dat, file = here::here("data_clean", "all-regions-trimmed.rds"))
  }else{
    write_csv(trimmed_dat, here::here("data_clean", "all-regions-trimmed.csv"))
  }
}

# are there any spp in trimmed_dat that are not in the taxonomy file?
test <- anti_join(select(trimmed_dat, spp, common), tax, by = c("spp" = "name")) %>% 
  distinct()

# if test contains more than 0 obs, use the add-spp-to-taxonomy.R script to add new taxa to the spptaxonomy.csv and go back to "Compile Tax".
rm(test)

# BY_SPECIES_DATA ===========================================================
print("By species data")
# Calculate mean position through time for species 
## Calculate mean latitude and depth of each species by year within each survey/region
### mean lat/lon/depth for each stratum
dat_strat <- trimmed_dat %>% 
  select(stratum, region, lat, lon, depth, stratum_area, haulid) %>% 
  distinct(region, stratum, haulid, .keep_all = T) %>% 
  group_by(stratum, region) %>% 
  summarise(lat = meanna(lat), 
            lon = meanna(lon), 
            depth = meanna(depth), 
            stratum_area = meanna(stratum_area))

### mean wtcpue in each stratum/yr/spp (new code includes more lines because it
### includes rows that do not have a common name)
dat_strat_yr <- trimmed_dat %>% 
  group_by(region, spp, common, stratum, year) %>% 
  summarise(wtcpue = meanna(wtcpue))

# add stratum lat/lon/depth/area
dat_strat_yr <- left_join(dat_strat_yr, dat_strat, by = c("region", "stratum"))

# index of biomass per stratum: mean wtcpue times area
dat_strat_yr <- dat_strat_yr %>% 
  mutate(wttot = wtcpue * stratum_area)

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

if(isTRUE(WRITE_BY_TABLES)){
  if(isTRUE(PREFER_RDATA)){
    saveRDS(BY_SPECIES_DATA, file = here::here("data_clean", "by_species.rds"))
  }else{
    write_csv(BY_SPECIES_DATA, here::here("data_clean", "by_species.csv"))
  }
}

rm(cent_bio, cent_bio_depth, cent_bio_depth_se, cent_bio_lat, cent_bio_lat_se, cent_bio_lon, cent_bio_lon_se, dat_strat, dat_strat_yr)

# Dat_exploded -  Add 0's ======================================================
print("Dat exploded") 
# these Sys.time() flags are here::here to see how long this section of code takes to run.
Sys.time()
# This takes about 5 minutes
if (DAT_EXPLODED == TRUE){
  dat.exploded <- as.data.table(trimmed_dat)[,explode0(.SD), by="region"]
  
  if(isTRUE(WRITE_DAT_EXPLODED)){
    if(isTRUE(PREFER_RDATA)){
      saveRDS(dat.exploded, file = here::here("data_clean", "dat_exploded.rds"))
    }else{
      write_csv(dat.exploded, here::here("data_clean", "dat_exploded.csv"))
    }
  }

}
Sys.time()


#By region data ================================================
print("by region data")

#Requires function species_data's dataset [by default: BY_SPECIES_DATA] or this function will not run properly.
## Calculate mean position through time for regions 
## Find a standard set of species (present every year in a region)
presyr <- present_every_year(dat, region, spp, year)

# num years in which spp was present
presyrsum <- num_year_present(presyr, region, spp)

# max num years of survey in each region
maxyrs <- max_year_surv(presyrsum, region)


# merge in max years
presyrsum <- left_join(presyrsum, maxyrs, by = "region") 

# retain all spp present at least once every time a survey occurs
spplist <- presyrsum %>% 
  filter(presyr >= (maxyrs)) %>% 
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

if(isTRUE(WRITE_BY_TABLES)){
  if(isTRUE(PREFER_RDATA)){
    saveRDS(BY_REGION_DATA, file = here::here("data_clean", "by_region.rds"))
  }else{
    write_csv(BY_REGION_DATA, here::here("data_clean", "by_region.csv"))
  }
}

# By national data ===========================================================
print("by national data")

#Returns national data
#Requires function species_data's dataset [by default: BY_SPECIES_DATA] or this function will not run properly.

## Calculate mean position through time for the US #


# Only include regions not constrained by geography in which surveys have consistent methods through time
regstouse <- c('Eastern Bering Sea', 'Northeast US Spring', 'Northeast US Fall') 

natstartyear <- 1982 # a common starting year for the focal regions

# find the latest year that all regions have in common
maxyears <- dat %>% 
  filter(region %in% regstouse) %>% 
  group_by(region) %>% 
  summarise(maxyear = max(year))

natendyear <- min(maxyears$maxyear)

## Find a standard set of species (present every year in the focal regions) for the national analysis
# For national average, start in prescribed year, only use focal regions
# find which species are present in which years
presyr <- present_every_year(dat, region, spp, year) %>% 
  filter(year >= natstartyear & year <= natendyear & 
           region %in% regstouse)  

# num years in which spp was present
presyrsum <- num_year_present(presyr, region, spp)

# max num years of survey in each region
maxyars <- max_year_surv(presyrsum, region)

# merge in max years
presyrsum <- left_join(presyrsum, maxyars, by = "region") 

# retain all spp present at least once every time a survey occurs
spplist2 <- presyrsum %>% 
  filter(paste0(region,presyr) %in% paste0(maxyars$region, maxyars$maxyrs)) %>% 
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

natcentbio$numspp <- lunique(paste(centbio3$region, centbio3$spp)) # calc number of species per region  

BY_NATIONAL_DATA <- natcentbio

if(isTRUE(WRITE_BY_TABLES)){
  if(isTRUE(PREFER_RDATA)){
    saveRDS(BY_NATIONAL_DATA, file = here::here("data_clean", "by_national.rds"))
  }else{
    write_csv(BY_NATIONAL_DATA, here::here("data_clean", "by_national.csv"))
  }
}

rm(centbio2, centbio3, maxyrs, natcentbio, natcentbiose, presyr, presyrsum, regcentbio, regcentbiospp, spplist, spplist2, startpos, startyear, regcentbiose)


if(isTRUE(PLOT_CHARTS)) {
  
  # Plot Species #####

  centbio <- BY_SPECIES_DATA
  
  # for latitude
  print("Starting latitude plots for species")
  pdf(file = here("plots", "sppcentlatstrat.pdf"), width=10, height=8)
  
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
  pdf(file = here("plots", "sppcentdepthstrat.pdf"), width=10, height=8)
  
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

  reg_lat_depth <- BY_REGION_DATA %>%
    ungroup() %>%
    mutate(year = as.numeric(year),
           mindpeth = depth - depth_se,
           maxdepth = depth + depth_se,
           minlat = lat - lat_se,
           maxlat = lat + lat_se, 
           minlat = ifelse(is.na(minlat), lat, minlat), 
           maxlat = ifelse(is.na(maxlat), lat, maxlat), 
           mindepth = ifelse(is.na(mindpeth), depth, mindpeth),
           maxdepth = ifelse(is.na(maxdepth), depth, maxdepth))
  
  
  reg_lat_plot <- ggplot(data = reg_lat_depth, aes(x=year, y=lat, ymin=minlat, ymax=maxlat)) + 
    geom_line(color = "#D95F02") + 
    geom_ribbon(alpha=0.5, color = "#CBD5E8") + 
    theme_bw ()+
    theme(
      panel.border = element_rect(),
      plot.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = "12", hjust = 0.5, )
    ) +
    xlab("Year") + 
    ylab("Offset in latitude (°)") +
    ggtitle("Regional Latitude Offset") +
    facet_wrap(vars(region)) +
    scale_x_continuous(limit=c(1970,2020)
                       ,breaks=seq(1970,2020,15)
    )
  ggsave(reg_lat_plot, filename =  here::here("plots", "regional-lat.png"), width = 8.5, height = 11)
  
  reg_depth_plot <- ggplot(data = reg_lat_depth, aes(x=year, y=depth, ymin=mindepth, ymax=maxdepth)) + 
    geom_line(color = "#D95F02") + 
    geom_ribbon(alpha=0.5, color = "#CBD5E8") + 
    theme_bw ()+
    theme(
      panel.border = element_rect(),
      plot.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = "12", hjust = 0.5)
    ) +
    xlab("Year") + 
    ylab("Offset in depth (m)") +
    ggtitle("Regional Depth Offset") +
    facet_wrap(vars(region)) +
    scale_x_continuous(limit=c(1970,2020)
                       ,breaks=seq(1970,2020,15)
    )
  ggsave(reg_depth_plot, filename =  here::here("plots", "regional-depth.png"), width = 8.5, height = 11)

  
  # Plot National ####
  
  nat_lat_depth <- BY_NATIONAL_DATA %>%
    ungroup() %>%
    mutate(year = as.numeric(year),
           mindpeth = depth - depth_se,
           maxdepth = depth + depth_se,
           minlat = lat - lat_se,
           maxlat = lat + lat_se, 
           minlat = ifelse(is.na(minlat), lat, minlat), 
           maxlat = ifelse(is.na(maxlat), lat, maxlat), 
           mindepth = ifelse(is.na(mindpeth), depth, mindpeth),
           maxdepth = ifelse(is.na(maxdepth), depth, maxdepth))
  
  
  nat_lat_plot <- ggplot(data = nat_lat_depth, aes(x=year, y=lat, ymin=minlat, ymax=maxlat)) + 
    geom_line(color = "#D95F02") + 
    geom_ribbon(alpha=0.5, color = "#CBD5E8") + 
    theme_bw ()+
    theme(
      panel.border = element_rect(),
      plot.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = "12", hjust = 0.5, )
    ) +
    xlab("Year") + 
    ylab("Offset in latitude (°)") +
    ggtitle("National Latitude Offset") +
    scale_x_continuous(limit=c(1980,2020)
                       ,breaks=seq(1980,2020,15)
    )
  ggsave(nat_lat_plot, filename =  here::here("plots", "national-lat.png"), width = 6, height = 3.5)

  nat_depth_plot <- ggplot(data = nat_lat_depth, aes(x=year, y=depth, ymin=mindepth, ymax=maxdepth)) + 
    geom_line(color = "#D95F02") + 
    geom_ribbon(alpha=0.5, color = "#CBD5E8") + 
    theme_bw ()+
    theme(
      panel.border = element_rect(),
      plot.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = "12", hjust = 0.5)
    ) +
    xlab("Year") + 
    ylab("Offset in depth (m)") +
    ggtitle("National Depth Offset") +
    scale_x_continuous(limit=c(1980,2020)
                       ,breaks=seq(1980,2020,15)
    )
  ggsave(nat_depth_plot, filename =  here::here("plots", "national-depth.png"), width = 6, height = 3.5)

}
  
