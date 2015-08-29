### READ THIS FIRST TO RUN THIS FILE
# This script runs using the RAW data as downloaded from the OceanAdapt website (http://oceanadapt.rutgers.edu)
# All of the raw data files need to be in the same directory.
# There are then three ways to run the script, from easiest to somewhat more advanced:
#   1) Put this script in the same directory as the data files and use `source('PATH/complete_r_script.R', chdir=TRUE)`, where PATH is replaced with the path to the script (even easier on some systems: drag and drop this script onto the R window and it will source it automatically). The chdir option will temporarily change the working directory to where the script is located. Please use command `?source` for more information.
#   2) Open R, manually change the working directory to the directory with the data files, and run all the code in this script. 
#   3) Manually change the WORKING_DIRECTORY variable (line 27) to the directory with your data and run the script. 
      
 
### File Structure
#In this file: the top contains required variables and libraries and flags.
#The middle contains all functions used by this file
#The bottom (Search[Ctrl+f] for `programfunction` without quotes) contains the instructions for R to recreate `dat`, the master table
#Also at the bottom (Search[Ctrl+f] for `modifyprogram` without quotes) you can do your own analysis. We have the code we use there as an example for you.

### Required Libraries
#You should be able to use the install.packages() function here if the libraries do not exist on your machine
#Please use command `?install.packages` for more information
library(data.table) # much of this code could be sped up by converting to data.tables
library(PBSmapping) # for calculating stratum areas
library(maptools) # for calculating stratum areas
library(Hmisc)
require(stringr) # allow 'STRATA' to be extracted from 'STATIONCODE' with seus
require(lubridate) # for manipulating 'DATE' and extracting 'SEASON' with sues
require(zoo) # allows 'SEASON' to be extracted from 'DATE' with seus

### IMPORTANT VARIABLES
WORKING_DIRECTORY = getwd()

#FLAGS, please make TRUE or FALSE [Yes, in all CAPS].
PRINT_STATUS = TRUE #DEFAULT: TRUE. Simply uses print() to give a status update to the user. Used by `print_status()`.
HQ_DATA_ONLY = TRUE #DEFAULT: TRUE. Some strata and years have very little data, so they get removed.
REMOVE_REGION_DATASETS = FALSE #DEFAULT: FALSE Remove ai,ebs,gmex,goa,neus,wcann,wctri. Keep `dat`
OPTIONAL_PLOT_CHARTS = FALSE #OPTIONAL, DEFAULT:FALSE, creates graphs based on the data like shown on the website and outputs them to pdf.
OPTIONAL_OUTPUT_DAT_MASTER_TABLE = FALSE #OPTIONAL, DEFAULT:FALSE, Outputs the dat into an rdata file


### Useful generic functions 
sumna = function(x){
  #acts like sum(na.rm=T) but returns NA if all are NA
  if(!all(is.na(x))) return(sum(x, na.rm=T))
  if(all(is.na(x))) return(NA)
}

lunique = function(x) length(unique(x)) # number of unique values in a vector

# function to calculate convex hull area in km2
#developed from http://www.nceas.ucsb.edu/files/scicomp/GISSeminar/UseCases/CalculateConvexHull/CalculateConvexHullR.html
calcarea = function(lonlat){
  hullpts = chull(x=lonlat[,1], y=lonlat[,2]) # find indices of vertices
  hullpts = c(hullpts,hullpts[1]) # close the loop
  ps = appendPolys(NULL,mat=as.matrix(lonlat[hullpts,]),1,1,FALSE) # create a Polyset object
  attr(ps,"projection") = "LL" # set projection to lat/lon
  psUTM = convUL(ps, km=TRUE) # convert to UTM in km
  polygonArea = calcArea(psUTM,rollup=1)
  return(polygonArea$area)
}

print_status = function (message) { 
  #This function is useful for printing messages if the user wants to see them
  #Looks at the global flag PRINT_STATUS to determine if messages should be printed
  #to the console.
  if(isTRUE(PRINT_STATUS)){ 
    print( message )
  }
  return(TRUE)
}

meanna = function(x){
  if(!all(is.na(x))) return(mean(x, na.rm=T))
  if(all(is.na(x))) return(NA)
}

# weighted mean for use with summarize(). values in col 1, weights in col 2
wgtmean = function(x, na.rm=FALSE) wtd.mean(x=x[,1], weights=x[,2], na.rm=na.rm)

se = function(x) sd(x)/sqrt(length(x)) # assumes no NAs

# weighted standard error that takes a matrix, for use with summarize. values in col 1, weights in col 2
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

#Useful specific functions 

#Compiling/Read and Reformat functions :
#These functions are ran first generally to combine the csvs/rdata into one sheet so that they can be compared and evaluated on

compile_TAX = function () {
  #Function returns tax
  # Scientific to common names
  tax = read.csv(paste(WORKING_DIRECTORY, '/spptaxonomy.csv', sep=''))
  return(tax)
  
}
compile_AI = function () {
  #Function returns ai
  # Aleutian Islands
  ai = read.csv(paste(WORKING_DIRECTORY, '/ai_data.csv', sep=''))
  aistrata = read.csv(paste(WORKING_DIRECTORY, '/ai_strata.csv', sep=''))
  ai = merge(ai, aistrata[,c('StratumCode', 'Areakm2')], by.x='STRATUM', by.y='StratumCode', all.x=TRUE)
  return(ai)
  
}
compile_EBS = function () {
  #Function returns ebs
  # Eastern Bering Sea
  ebs = read.csv(paste(WORKING_DIRECTORY, '/ebs_data.csv', sep=''))
  ebsstrata = read.csv(paste(WORKING_DIRECTORY, '/ebs_strata.csv', sep=''))
  ebs = merge(ebs, ebsstrata[,c('StratumCode', 'Areakm2')], by.x='STRATUM', by.y='StratumCode', all.x=TRUE)
  return(ebs)
  
}
compile_GOA = function () {
  #Function returns goa
  # Gulf of Alaska
  goa = read.csv(paste(WORKING_DIRECTORY, '/goa_data.csv', sep=''))
  goastrata = read.csv(paste(WORKING_DIRECTORY, '/goa_strata.csv', sep=''))
  goa = merge(goa, goastrata[,c('StratumCode', 'Areakm2')], by.x='STRATUM', by.y='StratumCode', all.x=TRUE)
  return(goa)
  
}
compile_NEUS = function () {
  #Northeast US
  #function returns neus
  survdat = data.table(read.csv(paste(WORKING_DIRECTORY, '/neus_data.csv', sep='')))
  neusstrata = read.csv(paste(WORKING_DIRECTORY, '/neus_strata.csv', sep=''))
  spp = data.table(read.csv(paste(WORKING_DIRECTORY, '/neus_svspp.csv', sep='')))
  
  setkey(survdat, CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX)
  neus <- unique(survdat) # drops length data
  neus[, c('LENGTH', 'NUMLEN') := NULL] # remove length columns
  neus = neus[,sum(BIOMASS),by=list(YEAR, SEASON, LAT, LON, DEPTH, CRUISE6, STATION, STRATUM, SVSPP)] # sum different sexes of same spp together
  setnames(neus, 'V1', 'wtcpue')
  neus = neus[SEASON=='SPRING',] # trim to spring survey only
  spp[,c('ITISSPP', 'COMNAME', 'AUTHOR') := NULL] # remove some columns from spp data.table
  neus = merge(neus, spp, by='SVSPP') # add species names
  neus = as.data.frame(neus) # this makes the calculations less efficient... but avoids having to rewrite the code for data.tables
  neus = merge(neus, neusstrata[,c('StratumCode', 'Areanmi2')], by.x='STRATUM', by.y = 'StratumCode', all.x=TRUE)
  
  return(neus)
}

compile_NEUSF = function () {
  #Northeast US
  #function returns neus
  survdat = data.table(read.csv(paste(WORKING_DIRECTORY, '/neus_data.csv', sep='')))
  neusstrata = read.csv(paste(WORKING_DIRECTORY, '/neus_strata.csv', sep=''))
  spp = data.table(read.csv(paste(WORKING_DIRECTORY, '/neus_svspp.csv', sep='')))
  
  setkey(survdat, CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX)
  neusF <- unique(survdat) # drops length data
  neusF[, c('LENGTH', 'NUMLEN') := NULL] # remove length columns
  neusF = neusF[,sum(BIOMASS),by=list(YEAR, SEASON, LAT, LON, DEPTH, CRUISE6, STATION, STRATUM, SVSPP)] # sum different sexes of same spp together
  setnames(neusF, 'V1', 'wtcpue')
  neusF = neusF[SEASON=='FALL',] # trim to spring survey only
  spp[,c('ITISSPP', 'COMNAME', 'AUTHOR') := NULL] # remove some columns from spp data.table
  neusF = merge(neusF, spp, by='SVSPP') # add species names
  neusF = as.data.frame(neusF) # this makes the calculations less efficient... but avoids having to rewrite the code for data.tables
  neusF = merge(neusF, neusstrata[,c('StratumCode', 'Areanmi2')], by.x='STRATUM', by.y = 'StratumCode', all.x=TRUE)
  
  return(neusF)
}

compile_WCTri = function () {
  #function returns wctri
  # West Coast Trienniel 
  wctricatch = read.csv(paste(WORKING_DIRECTORY, '/wctri_catch.csv', sep=''))
  wctrihaul = read.csv(paste(WORKING_DIRECTORY, '/wctri_haul.csv', sep=''))
  wctrispecies = read.csv(paste(WORKING_DIRECTORY, '/wctri_species.csv', sep=''))
  wctri = merge(wctricatch[,c('CRUISEJOIN', 'HAULJOIN', 'VESSEL', 'CRUISE', 'HAUL', 'SPECIES_CODE', 'WEIGHT')], wctrihaul[,c('CRUISEJOIN', 'HAULJOIN', 'VESSEL', 'CRUISE', 'HAUL', 'HAUL_TYPE', 'PERFORMANCE', 'START_TIME', 'DURATION', 'DISTANCE_FISHED', 'NET_WIDTH', 'STRATUM', 'START_LATITUDE', 'END_LATITUDE', 'START_LONGITUDE', 'END_LONGITUDE', 'STATIONID', 'BOTTOM_DEPTH')], all.x=TRUE) # Add haul info to catch data
  wctri = merge(wctri, wctrispecies[,c('SPECIES_CODE', 'SPECIES_NAME', 'COMMON_NAME')]) #  add species names
  wctri = wctri[wctri$HAUL_TYPE==3 & wctri$PERFORMANCE==0,] # trim to standard hauls and good performance
  return(wctri)
}
compile_WCAnn = function () {
  #function returns wcann
  # West Coast annual
  wcannfish = read.csv(paste(WORKING_DIRECTORY, '/wcann_fish.csv', sep=''))
  wcannhaul = read.csv(paste(WORKING_DIRECTORY, '/wcann_haul.csv', sep=''))
  wcanninvert = read.csv(paste(WORKING_DIRECTORY, '/wcann_invert.csv', sep=''))
  wcanncatch = rbind(wcannfish[,names(wcanninvert)], wcanninvert) # wcannfish has an extra column, so trim it out while combining with inverts
  wcann = merge(wcannhaul, wcanncatch)
  return(wcann)
  
}
compile_GMEX = function () {
  #Gulf of Mexico
  #function returns gmex
  gmexstation = read.csv(paste(WORKING_DIRECTORY, '/gmex_station.csv', sep=''))
  gmextow = read.csv(paste(WORKING_DIRECTORY, '/gmex_tow.csv', sep=''), allowEscapes=TRUE)
  gmexspp = read.csv(paste(WORKING_DIRECTORY, '/gmex_spp.csv', sep=''))
  gmexcruise = read.csv(paste(WORKING_DIRECTORY, '/gmex_cruise.csv', sep=''))
  test = read.csv(paste(WORKING_DIRECTORY, '/gmex_bio.csv', sep=''), nrows=2) # gmexbio is a large file: only read in some columns
  biocols = c('CRUISEID', 'STATIONID', 'VESSEL', 'CRUISE_NO', 'P_STA_NO', 'GENUS_BGS', 'SPEC_BGS', 'BGSCODE', 'BIO_BGS', 'SELECT_BGS')
  colstoread = rep('NULL', ncol(test)) # NULL means don't read that column (see ?read.csv)
  colstoread[names(test) %in% biocols] = NA # NA means read that column
  gmexbio = read.csv(paste(WORKING_DIRECTORY, '/gmex_bio.csv', sep=''), colClasses=colstoread) # sped up by reading in only some columns
  # trim out young of year records (only useful for count data) and those with UNKNOWN species
  gmexbio = gmexbio[gmexbio$BGSCODE != 'T' & gmexbio$GENUS_BGS != 'UNKNOWN',]
  gmexbio = gmexbio[!duplicated(gmexbio),] # remove the few rows that are still duplicates
  newspp = data.frame(Key1 = c(503,5770), TAXONOMIC = c('ANTHIAS TENUIS AND WOODSI', 'MOLLUSCA AND UNID.OTHER #01'), CODE=c(170026003, 300000000), TAXONSIZECODE=NA, isactive=-1, common_name=c('threadnose and swallowtail bass', 'molluscs or unknown'), tsn = NA) # make two combined records where multiple species records share the same species code
  gmexspp = gmexspp[!(gmexspp$CODE %in% gmexspp$CODE[which(duplicated(gmexspp$CODE))]),] # remove the duplicates that were just combined
  gmexspp = rbind(gmexspp[,names(newspp)], newspp) # add the combined records on to the end. trim out extra columns from gmexspp
  
  gmex = merge(gmexbio, gmextow[gmextow$GEAR_TYPE=='ST', c('STATIONID', 'CRUISE_NO', 'P_STA_NO', 'INVRECID', 'GEAR_SIZE', 'GEAR_TYPE', 'MESH_SIZE', 'MIN_FISH', 'OP')]) # merge tow information with catch data, but only for shrimp trawl tows (ST)
  gmex = merge(gmex, gmexstation[,c('STATIONID', 'CRUISEID', 'CRUISE_NO', 'P_STA_NO', 'TIME_ZN', 'TIME_MIL', 'S_LATD', 'S_LATM', 'S_LOND', 'S_LONM', 'E_LATD', 'E_LATM', 'E_LOND', 'E_LONM', 'DEPTH_SSTA', 'MO_DAY_YR', 'VESSEL_SPD', 'COMSTAT')]) # add station location and related data
  gmex = merge(gmex, gmexspp[,c('CODE', 'TAXONOMIC')], by.x='BIO_BGS', by.y='CODE', all.x=TRUE) # add scientific name
  gmex = merge(gmex, gmexcruise[,c('CRUISEID', 'VESSEL', 'TITLE')], all.x=TRUE) # add cruise title
  gmex = gmex[gmex$TITLE %in% c('Summer SEAMAP Groundfish Survey', 'Summer SEAMAP Groundfish Suvey') & gmex$GEAR_SIZE==40 & gmex$MESH_SIZE == 1.63 & !is.na(gmex$MESH_SIZE) & gmex$OP %in% c(''),] # # Trim to high quality SEAMAP summer trawls, based off the subset used by Jeff Rester's GS_TRAWL_05232011.sas
  
  return(gmex)
}

compile_SEUSSpr = function () { 
  #Southeast US
  #function returns seusSPRING
  survcatch = data.table(read.csv(file=paste(WORKING_DIRECTORY, '/seus_catch.csv', sep=''), stringsAsFactors=FALSE))
  survhaul = data.table(read.csv(paste(WORKING_DIRECTORY, '/seus_haul.csv', sep=''), stringsAsFactors=FALSE)) # only needed for DEPTHSTART
  survhaul <- unique(data.table(EVENTNAME = survhaul$EVENTNAME, DEPTHSTART = survhaul$DEPTHSTART))
  seusstrata = data.table(read.csv(paste(WORKING_DIRECTORY, '/seus_strata.csv', sep=''))) # contains strata areas
  setkey(survcatch, EVENTNAME, SPECIESCODE)
  setkey(survhaul, EVENTNAME)
  seus = survcatch[survhaul] # Add depth data from survhaul 
  seus = cbind(seus, STRATA = as.integer(str_sub(string = seus$STATIONCODE, start = 1, end = 2))) #Create STRATA column
  seus = seus[seus$DEPTHZONE != "OUTER",] # Drop OUTER depth zone because it was only sampled for 10 years
  seus = merge(x=seus, y=seusstrata, by='STRATA', all.x=TRUE) #add STRATAHECTARE to main file 
                          
  #Create a 'SEASON' column using 'MONTH' as a criteria
  seus$DATE <- as.Date(seus$DATE, "%m/%d/%Y")
  seus = cbind(seus, MONTH = month(seus$DATE))
  SEASON = as.yearqtr(seus$DATE)
  seus = cbind(seus, SEASON = factor(format(SEASON, "%q"), levels = 1:4, labels = c("winter", "spring", "summer", "fall")))
  
  #seus has some unique data corrections that are dealt with here
  #Occasions where weight wasn't provided for a given species; here weight is calculated based on average weight for that species,
  seus$SPECIESTOTALWEIGHT <- replace(seus$SPECIESTOTALWEIGHT, seus$COLLECTIONNUMBER == 20010106 & seus$SPECIESCODE == 8713050104, 31.9) # roughtail stingray
  seus$SPECIESTOTALWEIGHT[is.na(seus$SPECIESTOTALWEIGHT) & seus$SPECIESCODE == 5802010101] <- 0 # these 'NA' weights needed to first be converted to 0
  seus <- within(seus, SPECIESTOTALWEIGHT[SPECIESTOTALWEIGHT == 0 & SPECIESCODE == 5802010101] <- NUMBERTOTAL[SPECIESTOTALWEIGHT == 0 & SPECIESCODE == 5802010101]*1.9) # horseshoe crabs
  seus = seus[!is.na(seus$SPECIESTOTALWEIGHT),] # remove long line fish from dataset which have 'NA' for weight
  #Three hauls have 0 or NA for 'EFFORT', which are data entry errors, the following corrects these values
  seus$EFFORT[seus$COLLECTIONNUMBER == 19910105] <- 1.71273
  seus$EFFORT[seus$COLLECTIONNUMBER == 19990065] <- 0.53648
  seus$EFFORT[seus$COLLECTIONNUMBER == 20070177] <- 0.99936
   
  #Separate the the spring season and convert to dataframe
  seusSPRING = seus[seus$SEASON == "spring",]
  seusSPRING = data.frame(seusSPRING)
  return(seusSPRING)
} 

compile_SEUSSum = function () { 
  #Southeast US
  #function returns seusSUMMER
  survcatch = data.table(read.csv(file=paste(WORKING_DIRECTORY, '/seus_catch.csv', sep=''), stringsAsFactors=FALSE))
  survhaul = data.table(read.csv(paste(WORKING_DIRECTORY, '/seus_haul.csv', sep=''), stringsAsFactors=FALSE)) # only needed for DEPTHSTART
  survhaul <- unique(data.table(EVENTNAME = survhaul$EVENTNAME, DEPTHSTART = survhaul$DEPTHSTART))
  seusstrata = data.table(read.csv(paste(WORKING_DIRECTORY, '/seus_strata.csv', sep=''))) # contains strata areas
  setkey(survcatch, EVENTNAME, SPECIESCODE)
  setkey(survhaul, EVENTNAME)
  seus = survcatch[survhaul] # Add depth data from survhaul 
  seus = cbind(seus, STRATA = as.integer(str_sub(string = seus$STATIONCODE, start = 1, end = 2))) #Create STRATA column
  seus = seus[seus$DEPTHZONE != "OUTER",] # Drop OUTER depth zone because it was only sampled for 10 years
  seus = merge(x=seus, y=seusstrata, by='STRATA', all.x=TRUE) #add STRATAHECTARE to main file 
  
  #Create a 'SEASON' column using 'MONTH' as a criteria
  seus$DATE <- as.Date(seus$DATE, "%m/%d/%Y")
  seus = cbind(seus, MONTH = month(seus$DATE))
  SEASON = as.yearqtr(seus$DATE)
  seus = cbind(seus, SEASON = factor(format(SEASON, "%q"), levels = 1:4, labels = c("winter", "spring", "summer", "fall")))
  #September EVENTS were grouped with summer, should be fall because all hauls made in late-September during fall-survey
  seus$SEASON[seus$MONTH == 9] <- "fall"
  
  #seus has some unique data corrections that are dealt with here
  #Occasions where weight wasn't provided for a given species; here weight is calculated based on average weight for that species,
  seus$SPECIESTOTALWEIGHT[is.na(seus$SPECIESTOTALWEIGHT) & seus$SPECIESCODE == 5802010101] <- 0 # these 'NA' weights needed to first be converted to 0
  seus <- within(seus, SPECIESTOTALWEIGHT[SPECIESTOTALWEIGHT == 0 & SPECIESCODE == 5802010101] <- NUMBERTOTAL[SPECIESTOTALWEIGHT == 0 & SPECIESCODE == 5802010101]*1.9) # horseshoe crabs
  seus$SPECIESTOTALWEIGHT <- replace(seus$SPECIESTOTALWEIGHT, seus$COLLECTIONNUMBER == 19940236 & seus$SPECIESCODE == 9002050101, 204) # leatherback sea turtle
  seus$SPECIESTOTALWEIGHT <- replace(seus$SPECIESTOTALWEIGHT, seus$SPECIESTOTALWEIGHT == 0 & seus$SPECIESCODE == 9002040101, 46) # loggerhead
  
  seus = seus[!is.na(seus$SPECIESTOTALWEIGHT),] # remove long line fish from dataset which have 'NA' for weight
   
  #Four hauls have 0 or NA for 'EFFORT', which are data entry errors, the following corrects these values
  seus$EFFORT[seus$COLLECTIONNUMBER == 19950335] <- 0.9775
  seus$EFFORT[seus$COLLECTIONNUMBER == 20110393] <- 1.65726
  seus$EFFORT[seus$EVENTNAME == 2014325] <- 1.755
  seus$EFFORT[seus$EVENTNAME == 1992219] <- 1.796247
  #Data entry error fixes for lat/lon coordinates
  seus$LONGITUDESTART[seus$EVENTNAME == 2010233] <- -81.006
  seus$LATITUDESTART[seus$EVENTNAME == 2014325] <- 34.616
  
  #Separate the summer season and convert to dataframe
  seusSUMMER = seus[seus$SEASON == "summer",]
  seusSUMMER = data.frame(seusSUMMER)
  return(seusSUMMER)
} 

compile_SEUSFal = function () { 
  #Southeast US
  #function returns seusFALL
  survcatch = data.table(read.csv(file=paste(WORKING_DIRECTORY, '/seus_catch.csv', sep=''), stringsAsFactors=FALSE))
  survhaul = data.table(read.csv(paste(WORKING_DIRECTORY, '/seus_haul.csv', sep=''), stringsAsFactors=FALSE)) # only needed for DEPTHSTART
  survhaul <- unique(data.table(EVENTNAME = survhaul$EVENTNAME, DEPTHSTART = survhaul$DEPTHSTART))
  seusstrata = data.table(read.csv(paste(WORKING_DIRECTORY, '/seus_strata.csv', sep=''))) # contains strata areas
  setkey(survcatch, EVENTNAME, SPECIESCODE)
  setkey(survhaul, EVENTNAME)
  seus = survcatch[survhaul] # Add depth data from survhaul 
  seus = cbind(seus, STRATA = as.integer(str_sub(string = seus$STATIONCODE, start = 1, end = 2))) #Create STRATA column
  seus = seus[seus$DEPTHZONE != "OUTER",] # Drop OUTER depth zone because it was only sampled for 10 years
  seus = merge(x=seus, y=seusstrata, by='STRATA', all.x=TRUE) #add STRATAHECTARE to main file 
  
  #Create a 'SEASON' column using 'MONTH' as a criteria
  seus$DATE <- as.Date(seus$DATE, "%m/%d/%Y")
  seus = cbind(seus, MONTH = month(seus$DATE))
  SEASON = as.yearqtr(seus$DATE)
  seus = cbind(seus, SEASON = factor(format(SEASON, "%q"), levels = 1:4, labels = c("winter", "spring", "summer", "fall")))
  #September EVENTS were grouped with summer, should be fall because all hauls made in late-September during fall-survey
  seus$SEASON[seus$MONTH == 9] <- "fall"
  
  #seus has some unique data corrections that are dealt with here
  #Occasions where weight wasn't provided for a given species; here weight is calculated based on average weight for that species,
  seus$SPECIESTOTALWEIGHT[is.na(seus$SPECIESTOTALWEIGHT) & seus$SPECIESCODE == 5802010101] <- 0 # these 'NA' weights needed to first be converted to 0
  seus <- within(seus, SPECIESTOTALWEIGHT[SPECIESTOTALWEIGHT == 0 & SPECIESCODE == 5802010101] <- NUMBERTOTAL[SPECIESTOTALWEIGHT == 0 & SPECIESCODE == 5802010101]*1.9) # horseshoe crab
  seus$SPECIESTOTALWEIGHT <- replace(seus$SPECIESTOTALWEIGHT, seus$SPECIESTOTALWEIGHT == 0 & seus$SPECIESCODE == 9002040101, 46) 
  
  seus = seus[!is.na(seus$SPECIESTOTALWEIGHT),] # remove long line fish from dataset which have 'NA' for weight
  
  #Two hauls have 0 or NA for 'EFFORT', which are data entry errors, the following corrects these values
  seus$EFFORT[seus$COLLECTIONNUMBER == 19910423] <- 0.50031
  seus$EFFORT[seus$COLLECTIONNUMBER == 20010431] <- 0.25099
  #Data entry error fix for lat/lon coordinates
  seus$LONGITUDESTART[seus$EVENTNAME == 1998467] <- -79.01
  
  #Separate the fall season and convert to dataframe
  seusFALL = seus[seus$SEASON == "fall",]
  seusFALL = data.frame(seusFALL)
  return(seusFALL)
} 

#region helper functions
#Most of these functions clean up or add to specific datasets
#Since most of the data sets per region are in their own unique formats,
#We need to help the datasets along to find common ground in which to merge them properly
# the <<- operator is used so we can modify the global environment variables from inside local functions
create_haul_id = function  () {
  # Create a unique haulid
  ai$haulid <<- paste(formatC(ai$VESSEL, width=3, flag=0), formatC(ai$CRUISE, width=3, flag=0), formatC(ai$HAUL, width=3, flag=0), sep='-')
  ebs$haulid <<- paste(formatC(ebs$VESSEL, width=3, flag=0), formatC(ebs$CRUISE, width=3, flag=0), formatC(ebs$HAUL, width=3, flag=0), sep='-')
  goa$haulid <<- paste(formatC(goa$VESSEL, width=3, flag=0), formatC(goa$CRUISE, width=3, flag=0), formatC(goa$HAUL, width=3, flag=0), sep='-')
  neus$haulid <<- paste(formatC(neus$CRUISE6, width=6, flag=0), formatC(neus$STATION, width=3, flag=0), formatC(neus$STRATUM, width=4, flag=0), sep='-')
  neusF$haulid <<- paste(formatC(neusF$CRUISE6, width=6, flag=0), formatC(neusF$STATION, width=3, flag=0), formatC(neusF$STRATUM, width=4, flag=0), sep='-')  
  wctri$haulid <<- paste(formatC(wctri$VESSEL, width=3, flag=0), formatC(wctri$CRUISE, width=3, flag=0), formatC(wctri$HAUL, width=3, flag=0), sep='-')
  wcann$haulid <<- wcann$Trawl.Id
  gmex$haulid <<- paste(formatC(gmex$VESSEL, width=3, flag=0), formatC(gmex$CRUISE_NO, width=3, flag=0), formatC(gmex$P_STA_NO, width=5, flag=0, format='d'), sep='-')
  seusSPRING$haulid <<- seusSPRING$EVENTNAME
  seusSUMMER$haulid <<- seusSUMMER$EVENTNAME
  seusFALL$haulid <<- seusFALL$EVENTNAME  
  return(TRUE)
}

gmex_calculate_decimal_lat_lon = function () {
  
  # Calculate decimal lat and lon, depth in m, where needed
  gmex$S_LATD[gmex$S_LATD == 0] <<- NA
  gmex$S_LOND[gmex$S_LOND == 0] <<- NA
  gmex$E_LATD[gmex$E_LATD == 0] <<- NA
  gmex$E_LOND[gmex$E_LOND == 0] <<- NA
  gmex$lat <<- rowMeans(cbind(gmex$S_LATD + gmex$S_LATM/60, gmex$E_LATD + gmex$E_LATM/60), na.rm=T) # mean of start and end positions, but allow one to be NA (missing)
  gmex$lon <<- -rowMeans(cbind(gmex$S_LOND + gmex$S_LONM/60, gmex$E_LOND + gmex$E_LONM/60), na.rm=T) # need negative sign since western hemisphere
  gmex$depth <<- gmex$DEPTH_SSTA*1.8288 # convert fathoms to meters
  
  return(TRUE)
}

extract_year = function () {
  # Extract year where needed
  wctri$year <<- as.numeric(substr(wctri$CRUISE, 1,4))
  wcann$year <<- as.numeric(gsub('Cycle ', '', wcann$Survey.Cycle))
  gmex$year <<- as.numeric(unlist(strsplit(as.character(gmex$MO_DAY_YR), split='-'))[seq(1,by=3,length=nrow(gmex))])
  seusSPRING$year <<- as.numeric(substr(seusSPRING$EVENTNAME, 1,4))
  seusSUMMER$year <<- as.numeric(substr(seusSUMMER$EVENTNAME, 1,4))
  seusFALL$year <<- as.numeric(substr(seusFALL$EVENTNAME, 1,4))
  
  return(TRUE)
}
add_stratum = function () {
  
  # Add "strata" (define by lat, lon and depth bands) where needed
  stratlatgrid = floor(wctri$START_LATITUDE)+0.5 # degree bins
  stratdepthgrid = floor(wctri$BOTTOM_DEPTH/100)*100 + 50 # 100 m bins
  wctri$stratum <<- paste(stratlatgrid, stratdepthgrid, sep='-') # no need to use lon grids on west coast (so narrow)
  
  stratlatgrid = floor(wcann$Best.Latitude..dd.)+0.5 # degree bins
  stratdepthgrid = floor(wcann$Best.Depth..m./100)*100 + 50 # 100 m bins
  wcann$stratum <<- paste(stratlatgrid, stratdepthgrid, sep='-') # no need to use lon grids on west coast (so narrow)
  
  stratlatgrid = floor(gmex$lat)+0.5 # degree bins
  stratlongrid = floor(gmex$lon)+0.5 # degree bins
  stratdepthgrid = floor(gmex$depth/100)*100 + 50 # 100 m bins
  gmex$stratum <<- paste(stratlatgrid, stratlongrid, stratdepthgrid, sep='-')
  
  return(TRUE)
}
high_quality_strata = function () {
  #These items were hand chosen.
  # Trim to high quality strata UPDATE TO SET ALASKA STRATA TO POSITIVE CHOICES
  ai <<- ai[!(ai$STRATUM %in% c(221, 411, 421, 521, 611)),]
  ebs <<- ebs[!(ebs$STRATUM %in% c(82,90)),]
  goa <<- goa[!(goa$STRATUM %in% c(50, 210, 410, 420, 430, 440, 450, 510, 520, 530, 540, 550)),] # strata to remove.
  neus <<- neus[neus$STRATUM %in% c("1010", "1020", "1030", "1040", "1050", "1060", "1070", "1080", "1090", "1100", "1110", "1130", "1140", "1150", "1160", "1170", "1190", "1200", "1210", "1220", "1230", "1240", "1250", "1260", "1270", "1280", "1290", "1300", "1340", "1360", "1370", "1380", "1400", "1650", "1660", "1670", "1680", "1690", "1700", "1710", "1730", "1740", "1750"), ] # strata to keep (based on Nye et al. MEPS)
  
  strat.counts <- apply(table(neusF$YEAR, neusF$STRATUM), 2, function(x)sum(x>0))
  strat.names <- names(strat.counts)
  strat.select <- strat.names[strat.counts>=max(strat.counts)]
  neusF <<- neusF[neusF$STRATUM %in% c(strat.select), ] 
  
  wctri <<- wctri[wctri$stratum %in% c("36.5-50", "37.5-150", "37.5-50", "38.5-150", "38.5-250", "38.5-350", "38.5-50", "39.5-150", "39.5-50", "40.5-150", "40.5-250", "41.5-150", "41.5-250", "41.5-50", "42.5-150", "42.5-250", "42.5-50", "43.5-150", "43.5-250", "43.5-350", "43.5-50", "44.5-150", "44.5-250", "44.5-350", "44.5-50", "45.5-150", "45.5-350", "45.5-50", "46.5-150", "46.5-250", "46.5-50", "47.5-150", "47.5-50", "48.5-150", "48.5-250", "48.5-50"),]
  
  wcann <<- wcann[wcann$stratum %in% c("36.5-50", "37.5-150", "37.5-50", "38.5-150", "38.5-250", "38.5-350", "38.5-50", "39.5-150", "39.5-50", "40.5-150", "40.5-250", "41.5-150", "41.5-250", "41.5-50", "42.5-150", "42.5-250", "42.5-50", "43.5-150", "43.5-250", "43.5-350", "43.5-50", "44.5-150", "44.5-250", "44.5-350", "44.5-50", "45.5-150", "45.5-350", "45.5-50", "46.5-150", "46.5-250", "46.5-50", "47.5-150", "47.5-50", "48.5-150", "48.5-250", "48.5-50"),] # trim wcann to same footprint as wctri
  
  gmex <<- gmex[gmex$stratum %in% c("26.5--96.5-50", "26.5--97.5-50", "27.5--96.5-50", "27.5--97.5-50", "28.5--90.5-50", "28.5--91.5-50", "28.5--92.5-50", "28.5--93.5-50", "28.5--94.5-50", "28.5--95.5-50", "28.5--96.5-50", "29.5--88.5-50", "29.5--89.5-50", "29.5--92.5-50", "29.5--93.5-50", "29.5--94.5-50"),]
  
  # all seus strata are retained
    
  return(TRUE)
}
high_quality_years = function () {
  #These items were hand chosen.
  # Trim to high-quality years (sample all strata)  
  goa <<- goa[!(goa$YEAR %in% 2001),] # 2001 didn't sample many strata
  gmex <<- gmex[!(gmex$year %in% c(1982, 1983)),] # 1982 and 1983 didn't sample many strata
  seusSPRING <<- seusSPRING[!(seusSPRING$year %in% c(1989, 2013)),] # Many strata in 1989 only had one tow, plus spring sampled at night. 2013 did not sample all strata.
  seusSUMMER <<- seusSUMMER[!(seusSUMMER$year %in% 1989),] # Many strata in 1989 only had one tow.
  seusFALL <<- seusFALL[!(seusFALL$year %in% c(1989, 1990)),] # Many strata in 1989 only had one tow. 1990 did not sample all strata
  return(TRUE)
}
fix_speed = function () {
  # Trim out or fix speed and duration records
  gmex <<- gmex[gmex$MIN_FISH<=60 & gmex$MIN_FISH > 0 & !is.na(gmex$MIN_FISH),] # trim out tows of 0, >60, or unknown minutes
  gmex$VESSEL_SPD[gmex$VESSEL_SPD==30] <<- 3 # fix typo according to Jeff Rester: 30 = 3	
  gmex <<- gmex[gmex$VESSEL_SPD <= 5 & gmex$VESSEL_SPD > 0  & !is.na(gmex$VESSEL_SPD),] # trim out vessel speeds 0, unknown, or >5 (need vessel speed to calculate area trawled)
  
  return(TRUE)
}
calculate_stratum_area = function () {
  # Calculate stratum area where needed (use convex hull approach)
  neus$stratumarea <<- 	neus$Areanmi2 * 3.429904 # convert square nautical miles to square kilometers
  neusF$stratumarea <<- neusF$Areanmi2 * 3.429904 # convert square nautical miles to square kilometers
  
  wctristrats = summarize(wctri[,c('START_LONGITUDE', 'START_LATITUDE')], by=list(stratum=wctri$stratum), FUN=calcarea, stat.name = 'stratumarea')
  wctri <<- merge(wctri, wctristrats[,c('stratum', 'stratumarea')], by.x='stratum', by.y='stratum', all.x=TRUE)
  
  wcannstrats = summarize(wcann[,c('Best.Longitude..dd.', 'Best.Latitude..dd.')], by=list(stratum=wcann$stratum), FUN=calcarea, stat.name = 'stratumarea')
  wcann <<- merge(wcann, wcannstrats[,c('stratum', 'stratumarea')], by.x='stratum', by.y='stratum', all.x=TRUE)
  
  gmexstrats = summarize(gmex[,c('lon', 'lat')], by=list(stratum=gmex$stratum), FUN=calcarea, stat.name = 'stratumarea')
  gmex <<- merge(gmex, gmexstrats[,c('stratum', 'stratumarea')], by.x='stratum', by.y='stratum', all.x=TRUE)
  return(TRUE)
}

column_names_updated = function () {
  # This is used to prepare the datasets to be combined into one final table set
  # Update column names
  names(ai)[names(ai)=='STRATUM'] <<- 'stratum'
  names(ai)[names(ai)=='YEAR'] <<- 'year'
  names(ai)[names(ai)=='LATITUDE'] <<- 'lat'
  names(ai)[names(ai)=='LONGITUDE'] <<- 'lon' 
  names(ai)[names(ai)=='BOT_DEPTH'] <<- 'depth'
  names(ai)[names(ai)=='SCIENTIFIC'] <<- 'spp'
  names(ai)[names(ai)=='WTCPUE'] <<- 'wtcpue'
  names(ai)[names(ai)=='Areakm2'] <<- 'stratumarea'
  
  names(ebs)[names(ebs)=='STRATUM'] <<- 'stratum'
  names(ebs)[names(ebs)=='YEAR'] <<- 'year'
  names(ebs)[names(ebs)=='LATITUDE'] <<- 'lat'
  names(ebs)[names(ebs)=='LONGITUDE'] <<- 'lon' # use the adjusted longitude
  names(ebs)[names(ebs)=='BOT_DEPTH'] <<- 'depth'
  names(ebs)[names(ebs)=='SCIENTIFIC'] <<- 'spp'
  names(ebs)[names(ebs)=='WTCPUE'] <<- 'wtcpue'
  names(ebs)[names(ebs)=='Areakm2'] <<- 'stratumarea'
  
  names(goa)[names(goa)=='STRATUM'] <<- 'stratum'
  names(goa)[names(goa)=='YEAR'] <<- 'year'
  names(goa)[names(goa)=='LATITUDE'] <<- 'lat'
  names(goa)[names(goa)=='LONGITUDE'] <<- 'lon'
  names(goa)[names(goa)=='BOT_DEPTH'] <<- 'depth'
  names(goa)[names(goa)=='SCIENTIFIC'] <<- 'spp'
  names(goa)[names(goa)=='WTCPUE'] <<- 'wtcpue'
  names(goa)[names(goa)=='Areakm2'] <<- 'stratumarea'
  
  names(neus)[names(neus)=='YEAR'] <<- 'year'
  names(neus)[names(neus)=='SCINAME'] <<- 'spp'
  names(neus)[names(neus)=='LAT'] <<- 'lat'
  names(neus)[names(neus)=='LON'] <<- 'lon'
  names(neus)[names(neus)=='DEPTH'] <<- 'depth'
  names(neus)[names(neus)=='STRATUM'] <<- 'stratum'
  
  names(neusF)[names(neusF)=='YEAR'] <<- 'year'
  names(neusF)[names(neusF)=='SCINAME'] <<- 'spp'
  names(neusF)[names(neusF)=='LAT'] <<- 'lat'
  names(neusF)[names(neusF)=='LON'] <<- 'lon'
  names(neusF)[names(neusF)=='DEPTH'] <<- 'depth'
  names(neusF)[names(neusF)=='STRATUM'] <<- 'stratum'
  
  names(wctri)[names(wctri)=='VESSEL'] <<- 'svvessel'
  names(wctri)[names(wctri) == 'START_LATITUDE'] <<- 'lat'
  names(wctri)[names(wctri) == 'START_LONGITUDE'] <<- 'lon'
  names(wctri)[names(wctri) == 'BOTTOM_DEPTH'] <<- 'depth'
  names(wctri)[names(wctri) == 'SPECIES_NAME'] <<- 'spp'
  names(wctri)[names(wctri)=='WEIGHT'] <<- 'wtcpue'
  
  names(wcann)[names(wcann)=='Best.Latitude..dd.'] <<- 'lat'
  names(wcann)[names(wcann)=='Best.Longitude..dd.'] <<- 'lon'
  names(wcann)[names(wcann)=='Best.Depth..m.'] <<- 'depth'
  names(wcann)[names(wcann)=='Species'] <<- 'spp'
  
  names(gmex)[names(gmex)=='TAXONOMIC'] <<- 'spp'
  
  names(seusSPRING)[names(seusSPRING)=='STRATA'] <<- 'stratum'
  names(seusSPRING)[names(seusSPRING)=='LATITUDESTART'] <<- 'lat'
  names(seusSPRING)[names(seusSPRING)=='LONGITUDESTART'] <<- 'lon' 
  names(seusSPRING)[names(seusSPRING)=='DEPTHSTART'] <<- 'depth'
  names(seusSPRING)[names(seusSPRING)=='SPECIESSCIENTIFICNAME'] <<- 'spp'
  names(seusSPRING)[names(seusSPRING)=='STRATAHECTARE'] <<- 'stratumarea'
  
  names(seusSUMMER)[names(seusSUMMER)=='STRATA'] <<- 'stratum'
  names(seusSUMMER)[names(seusSUMMER)=='LATITUDESTART'] <<- 'lat'
  names(seusSUMMER)[names(seusSUMMER)=='LONGITUDESTART'] <<- 'lon' 
  names(seusSUMMER)[names(seusSUMMER)=='DEPTHSTART'] <<- 'depth'
  names(seusSUMMER)[names(seusSUMMER)=='SPECIESSCIENTIFICNAME'] <<- 'spp'
  names(seusSUMMER)[names(seusSUMMER)=='STRATAHECTARE'] <<- 'stratumarea'
  
  names(seusFALL)[names(seusFALL)=='STRATA'] <<- 'stratum'
  names(seusFALL)[names(seusFALL)=='LATITUDESTART'] <<- 'lat'
  names(seusFALL)[names(seusFALL)=='LONGITUDESTART'] <<- 'lon' 
  names(seusFALL)[names(seusFALL)=='DEPTHSTART'] <<- 'depth'
  names(seusFALL)[names(seusFALL)=='SPECIESSCIENTIFICNAME'] <<- 'spp'
  names(seusFALL)[names(seusFALL)=='STRATAHECTARE'] <<- 'stratumarea'
  return(TRUE)
}

change_neg_9999_to_NA = function () {
  # Turn -9999 to NA where needed
  ai$wtcpue[ai$wtcpue==-9999] <<- NA
  ebs$wtcpue[ebs$wtcpue==-9999] <<- NA
  goa$wtcpue[goa$wtcpue==-9999] <<- NA
  return(TRUE)
}

adjust_tow_area = function () {
  
  # Adjust for towed area where needed
  wctri$wtcpue <<- wctri$wtcpue*10000/(wctri$DISTANCE_FISHED*1000*wctri$NET_WIDTH) # weight per hectare (10,000 m2)	
  wcann$wtcpue <<- wcann$Haul.Weight..kg./wcann$Area.Swept.by.the.Net..hectares. # kg per hectare (10,000 m2)	
  gmex$wtcpue <<- 10000*gmex$SELECT_BGS /(gmex$VESSEL_SPD * 1.85200 * 1000 * gmex$MIN_FISH / 60 * gmex$GEAR_SIZE * 0.3048) # kg per 10000m2. calc area trawled in m2: knots * 1.8 km/hr/knot * 1000 m/km * minutes * 1 hr/60 min * width of gear in feet * 0.3 m/ft # biomass per standard tow
  return(TRUE)
}

remove_paired_tows = function () {
  # Remove a tow when paired tows exist (same lat/lon/year but different haulid, only Gulf of Mexico)
  dups = which(duplicated(gmex[,c('year', 'lat', 'lon')]) & !duplicated(gmex$haulid)) # identify duplicate tows at same year/lat/lon
  dupped = gmex[paste(gmex$year, gmex$lat, gmex$lon) %in% paste(gmex$year[dups], gmex$lat[dups], gmex$lon[dups]),] # all tows at these year/lat/lon
  # sum(!duplicated(dupped$haulid)) # 26 (13 pairs of haulids)
  gmex <<- gmex[!(gmex$haulid %in% unique(dupped$haulid[grep('PORT', dupped$COMSTAT)])),] # remove the port haul (this is arbitrary, but seems to be right based on the notes associated with these hauls)
  
  #In seus there are two 'COLLECTIONNUMBERS' per 'EVENTNAME', with no exceptions; EFFORT is always the same for each COLLECTIONNUMBER
  # We sum the two tows in seus
  seusSPRING <<- aggregate(list(BIOMASS = seusSPRING$SPECIESTOTALWEIGHT), by=list(haulid = seusSPRING$haulid, stratum = seusSPRING$stratum, stratumarea = seusSPRING$stratumarea, year = seusSPRING$year, lat = seusSPRING$lat, lon = seusSPRING$lon, depth = seusSPRING$depth, SEASON = seusSPRING$SEASON, EFFORT = seusSPRING$EFFORT, spp = seusSPRING$spp), FUN=sum)
  seusSPRING$wtcpue <<- seusSPRING$BIOMASS/(seusSPRING$EFFORT*2)#yields biomass (kg) per hectare for each 'spp' and 'haulid'
  seusSUMMER <<- aggregate(list(BIOMASS = seusSUMMER$SPECIESTOTALWEIGHT), by=list(haulid = seusSUMMER$haulid, stratum = seusSUMMER$stratum, stratumarea = seusSUMMER$stratumarea, year = seusSUMMER$year, lat = seusSUMMER$lat, lon = seusSUMMER$lon, depth = seusSUMMER$depth, SEASON = seusSUMMER$SEASON, EFFORT = seusSUMMER$EFFORT, spp = seusSUMMER$spp), FUN=sum)
  seusSUMMER$wtcpue <<- seusSUMMER$BIOMASS/(seusSUMMER$EFFORT*2)#yields biomass (kg) per hectare for each 'spp' and 'haulid'
  seusFALL <<- aggregate(list(BIOMASS = seusFALL$SPECIESTOTALWEIGHT), by=list(haulid = seusFALL$haulid, stratum = seusFALL$stratum, stratumarea = seusFALL$stratumarea, year = seusFALL$year, lat = seusFALL$lat, lon = seusFALL$lon, depth = seusFALL$depth, SEASON = seusFALL$SEASON, EFFORT = seusFALL$EFFORT, spp = seusFALL$spp), FUN=sum)
  seusFALL$wtcpue <<- seusFALL$BIOMASS/(seusFALL$EFFORT*2)#yields biomass (kg) per hectare for each 'spp' and 'haulid'
  
  return(TRUE)
}
remove_rows_without_sci_names_or_fish_or_inverts = function() {
  
  # Removes rows without scientific names or that aren't fish or inverts
  ai <<- ai[ai$spp != '' & !(ai$spp %in% c("Decapodiformesunid.egg", "Decapodiformes unid. egg", "Volutopsiussp.eggs", "Volutopsius sp. eggs", "Bathyrajaaleuticaeggcase", "Bathyrajainterruptaeggcase", "Bathyrajamaculataeggcase", "Bathyraja maculata egg case", "Bathyraja mariposa egg case", "Bathyrajaparmiferaeggcase", "Bathyrajasp.", "Bathyrajasp.eggcase", "Bathyrajataranetzieggcase", "Bathyraja taranetzi egg case", "Beringiussp.eggs", "Beringius sp. eggs", "Buccinumsp.Eggs", "Fusitritonoregonensiseggs", "Fusitriton oregonensis eggs", "gastropodeggs", "Hemitripterusbolinieggs", "Hemitripterus bolini eggs", "Naticidaeeggs", "Naticidae eggs", "Neptuneasp.eggs", "Pyrulofusussp.eggs", "Rajabadiaeggcase", "Rossiapacificaeggs", "Bathyraja aleutica egg case", "Bathyraja interrupta egg case", "Bathyraja parmifera egg case", "Bathyraja sp. egg case", "Bathyraja sp. cf. parmifera egg case", "gastropod eggs", "Neptunea sp. eggs", "Rajarhinaeggcase", "Rajasp.eggcase", "Raja badia egg case", "Apristurus brunneus egg case", "Selachimorpha egg case", "Pyrulofusus sp. eggs", "Rossia pacifica eggs")),]
  ebs <<- ebs[ebs$spp != '' & !(ebs$spp %in% c("Decapodiformesunid.egg", "Volutopsiussp.eggs", "Volutopsius sp. eggs", "Bathyrajaaleuticaeggcase", "Bathyrajainterruptaeggcase", "Bathyrajamaculataeggcase", "Bathyrajaparmiferaeggcase", "Bathyrajasp.", "Bathyrajasp.eggcase", "Bathyrajataranetzieggcase", "Bathyraja taranetzi egg case", "Beringiussp.eggs", "Buccinumsp.Eggs", "Fusitritonoregonensiseggs", "gastropodeggs", "Hemitripterusbolinieggs", "Naticidaeeggs", "Naticidae eggs", "Neptuneasp.eggs", "Pyrulofusussp.eggs", "Rajabadiaeggcase", "Rossiapacificaeggs", "Bathyraja aleutica egg case", "Bathyraja interrupta egg case", "Bathyraja parmifera egg case", "Bathyraja sp. egg case", "gastropod eggs", "Neptunea sp. eggs", "Rajarhinaeggcase", "Raja binoculata egg case", "Rajasp.eggcase", "Apristurus brunneus egg case", "Selachimorpha egg case")),]
  goa <<- goa[goa$spp != '' & !(goa$spp %in% c("Decapodiformesunid.egg", "Volutopsiussp.eggs", "Bathyrajaaleuticaeggcase", "Bathyrajainterruptaeggcase", "Bathyrajamaculataeggcase", "Bathyrajaparmiferaeggcase", "Bathyrajasp.", "Bathyrajasp.eggcase", "Bathyrajataranetzieggcase", "Beringiussp.eggs", "Buccinumsp.Eggs", "Fusitritonoregonensiseggs", "gastropodeggs", "Hemitripterusbolinieggs", "Naticidaeeggs", "Neptuneasp.eggs", "Pyrulofusussp.eggs", "Rajabadiaeggcase", "Rossiapacificaeggs", "Bathyraja aleutica egg case", "Bathyraja interrupta egg case", "Bathyraja parmifera egg case", "Bathyraja sp. egg case", "gastropod eggs", "Neptunea sp. eggs", "Rajarhinaeggcase", "Rajasp.eggcase", "Apristurus brunneus egg case", "Selachimorpha egg case", "Bathyraja taranetzi egg case", "Bathyraja trachura egg case", "Beringius sp. eggs", "Cephalopoda unid. egg", "Fusitriton oregonensis eggs", "Hemitripterus bolini eggs", "Hydrolagus colliei egg case", "Naticidae eggs", "Pyrulofusus sp. eggs", "Raja binoculata egg case", "Raja rhina egg case", "Raja sp. egg case", "Volutopsius sp. eggs")),]
  neus <<- neus[!(neus$spp == '' | is.na(neus$spp)),]
  neus <<- neus[!(neus$spp %in% c('UNIDENTIFIED FISH', 'ILLEX ILLECEBROSUS EGG MOPS', 'LOLIGO PEALEII EGG MOPS')),] # remove unidentified spp and non-species
  neusF <<- neusF[!(neusF$spp == '' | is.na(neusF$spp)),]
  neusF <<- neusF[!(neusF$spp %in% c('UNIDENTIFIED FISH', 'ILLEX ILLECEBROSUS EGG MOPS', 'LOLIGO PEALEII EGG MOPS')),] # remove unidentified spp and non-species
  wctri <<- wctri[wctri$spp != '' & !(wctri$spp %in% c("Apristurus brunneus egg case", "fish eggs unident.", "Raja binoculata egg case", "Raja sp. egg case", "Rajiformes egg case", "Shark egg case unident.", "Bathyraja sp. egg case", "gastropod eggs", "Hydrolagus colliei egg case", "Selachimorpha egg case")),]
  wcann <<- wcann[wcann$spp != '' & !(wcann$spp %in% c("Apristurus brunneus egg case", "gastropod eggs", "Selachimorpha egg case", "Bathyraja sp. egg case", "fish eggs unident.", "Hydrolagus colliei egg case", "Raja binoculata egg case", "Raja sp. egg case", "Rajiformes egg case", "Shark egg case unident.")),]
  gmex <<- gmex[!(gmex$spp == '' | is.na(gmex$spp)),]
  gmex <<- gmex[!(gmex$spp %in% c('UNID CRUSTA', 'UNID OTHER', 'UNID.FISH', 'CRUSTACEA(INFRAORDER) BRACHYURA', 'MOLLUSCA AND UNID.OTHER #01', 'ALGAE', 'MISCELLANEOUS INVERTEBR', 'OTHER INVERTEBRATES')),]	# remove unidentified spp
  #For seus a few unreliable taxa are also removed 
  seusSPRING <<- seusSPRING[!(seusSPRING$spp %in% c('MISCELLANEOUS INVERTEBRATES','XANTHIDAE','MICROPANOPE NUTTINGI','ALGAE','DYSPANOPEUS SAYI')),]
  seusSUMMER <<- seusSUMMER[!(seusSUMMER$spp %in% c('MISCELLANEOUS INVERTEBRATES','XANTHIDAE','PSEUDOMEDAEUS AGASSIZII','ALGAE','DYSPANOPEUS SAYI')),]  
  seusFALL <<- seusFALL[!(seusFALL$spp %in% c('MISCELLANEOUS INVERTEBRATES','XANTHIDAE','ALGAE','DYSPANOPEUS SAYI')),]
  return(TRUE)
}

adjust_spp_names = function () {
  # Adjust spp names for those cases where they've changed or where matching failed (GMex)
  # first convert factors to strings so that we can modify them
  i <- sapply(ai, is.factor); ai[i] <<- lapply(ai[i], as.character)
  i <- sapply(ebs, is.factor); ebs[i] <<- lapply(ebs[i], as.character)
  i <- sapply(goa, is.factor); goa[i] <<- lapply(goa[i], as.character)
  i <- sapply(neus, is.factor); neus[i] <<- lapply(neus[i], as.character)
  i <- sapply(neusF, is.factor); neusF[i] <<- lapply(neusF[i], as.character)
  i <- sapply(wctri, is.factor); wctri[i] <<- lapply(wctri[i], as.character)
  i <- sapply(wcann, is.factor); wcann[i] <<- lapply(wcann[i], as.character)
  i <- sapply(gmex, is.factor); gmex[i] <<- lapply(gmex[i], as.character)
  
  
  ai$spp[ai$spp %in% c('Atheresthesevermanni', 'Atheresthesstomias')] <<- 'Atheresthessp.'
  ai$spp[ai$spp %in% c('Lepidopsettapolyxystra', 'Lepidopsettabilineata')] <<- 'Lepidopsettasp.'
  ai$spp[ai$spp %in% c('Myoxocephalusjaok', 'Myoxocephalusniger', 'Myoxocephaluspolyacanthocephalus', 'Myoxocephalusquadricornis', 'Myoxocephalusverrucosus')] <<- 'Myoxocephalussp.'
  ai$spp[ai$spp %in% c('Bathyrajaabyssicola', 'Bathyrajaaleutica', 'Bathyrajainterrupta', 'Bathyrajalindbergi', 'Bathyrajamaculata', 'Bathyrajamariposa', 'Bathyrajaminispinosa', 'Bathyrajaparmifera', 'Bathyrajasmirnovi', 'Bathyrajasp.cf.parmifera(Orretal.)', 'Bathyrajaspinosissima', 'Bathyrajataranetzi', 'Bathyrajatrachura', 'Bathyrajaviolacea')] <<- 'Bathyrajasp.'
  
  ebs$spp[ebs$spp %in% c('Atheresthes evermanni', 'Atheresthes stomias')] <<- 'Atheresthes sp.'
  ebs$spp[ebs$spp %in% c('Lepidopsetta polyxystra', 'Lepidopsetta bilineata')] <<- 'Lepidopsetta sp.'
  ebs$spp[ebs$spp %in% c('Hippoglossoides elassodon', 'Hippoglossoides robustus')] <<- 'Hippoglossoides sp.'
  ebs$spp[ebs$spp %in% c('Myoxocephalus jaok', 'Myoxocephalus niger', 'Myoxocephalus polyacanthocephalus', 'Myoxocephalus quadricornis', 'Myoxocephalus verrucosus', 'Myoxocephalus scorpioides')] <<- 'Myoxocephalus sp.'
  ebs$spp[ebs$spp %in% c('Bathyraja abyssicola', 'Bathyraja aleutica', 'Bathyraja interrupta', 'Bathyraja lindbergi', 'Bathyraja maculata', 'Bathyraja mariposa', 'Bathyraja minispinosa', 'Bathyraja parmifera', 'Bathyraja smirnovi', 'Bathyraja sp.', 'Bathyraja sp.cf.parmifera(Orretal.)', 'Bathyraja spinosissima', 'Bathyraja taranetzi', 'Bathyraja trachura', 'Bathyraja violacea')] <<- 'Bathyraja sp.'
  
  goa$spp[goa$spp %in% c('Lepidopsettapolyxystra', 'Lepidopsettabilineata')] <<- 'Lepidopsettasp.'
  goa$spp[goa$spp %in% c('Myoxocephalusjaok', 'Myoxocephalusniger', 'Myoxocephaluspolyacanthocephalus', 'Myoxocephalusquadricornis', 'Myoxocephalusverrucosus')] <<- 'Myoxocephalussp.'
  goa$spp[goa$spp %in% c('Bathyrajaabyssicola', 'Bathyrajaaleutica', 'Bathyrajainterrupta', 'Bathyrajalindbergi', 'Bathyrajamaculata', 'Bathyrajamariposa', 'Bathyrajaminispinosa', 'Bathyrajaparmifera', 'Bathyrajasmirnovi', 'Bathyrajasp.cf.parmifera(Orretal.)', 'Bathyrajaspinosissima', 'Bathyrajataranetzi', 'Bathyrajatrachura', 'Bathyrajaviolacea')] <<- 'Bathyrajasp.'
  
  # For this first draft, we don't need to clean up NEUS names here
  
  wctri$spp[wctri$spp %in% c('Lepidopsetta polyxystra', 'Lepidopsetta bilineata')] <<- 'Lepidopsetta sp.'
  wctri$spp[wctri$spp %in% c('Bathyraja interrupta', 'Bathyraja trachura', 'Bathyraja parmifera', 'Bathyraja spinosissima')] <<- 'Bathyrajasp.'
  
  wcann$spp[wcann$spp %in% c('Lepidopsetta polyxystra', 'Lepidopsetta bilineata')] <<- 'Lepidopsetta sp.' # so that species match wctri
  wcann$spp[wcann$spp %in% c('Bathyraja abyssicola', 'Bathyraja aleutica', 'Bathyraja kincaidii (formerly B. interrupta)', 'Bathyraja sp. ', 'Bathyraja trachura', 'Bathyraja parmifera', 'Bathyraja spinosissima')] <<- 'Bathyrajasp.'
  
  i = gmex$GENUS_BGS == 'PELAGIA' & gmex$SPEC_BGS == 'NOCTUL'; gmex$spp[i] <<- 'PELAGIA NOCTILUCA'; gmex$BIO_BGS[i] <<- 618030201
  i = gmex$GENUS_BGS == 'MURICAN' & gmex$SPEC_BGS == 'FULVEN'; gmex$spp[i] <<- 'MURICANTHUS FULVESCENS'; gmex$BIO_BGS[i] <<- 308011501
  i = gmex$spp %in% c('APLYSIA BRASILIANA', 'APLYSIA WILLCOXI'); gmex$spp[i] <<- 'APLYSIA'
  i = gmex$spp %in% c('AURELIA AURITA'); gmex$spp[i] <<- 'AURELIA'
  i = gmex$spp %in% c('BOTHUS LUNATUS', 'BOTHUS OCELLATUS', 'BOTHUS ROBINSI'); gmex$spp[i] <<- 'BOTHUS'
  i = gmex$spp %in% c('CLYPEASTER PROSTRATUS', 'CLYPEASTER RAVENELII'); gmex$spp[i] <<- 'CLYPEASTER'
  i = gmex$spp %in% c('CONUS AUSTINI', 'CONUS STIMPSONI'); gmex$spp[i] <<- 'CONUS'
  i = gmex$spp %in% c('CYNOSCION ARENARIUS', 'CYNOSCION NEBULOSUS', 'CYNOSCION NOTHUS'); gmex$spp[i] <<- 'CYNOSCION'
  i = gmex$spp %in% c('ECHINASTER SENTUS', 'ECHINASTER SERPENTARIUS'); gmex$spp[i] <<- 'ECHINASTER'
  i = gmex$spp %in% c('ECHINASTER SENTUS', 'ECHINASTER SERPENTARIUS'); gmex$spp[i] <<- 'ECHINASTER'
  i = gmex$spp %in% c('OPISTOGNATHUS AURIFRONS', 'OPISTOGNATHUS LONCHURUS'); gmex$spp[i] <<- 'OPISTOGNATHUS'
  i = gmex$spp %in% c('OPSANUS BETA', 'OPSANUS PARDUS', 'OPSANUS TAU'); gmex$spp[i] <<- 'OPSANUS'
  i = gmex$spp %in% c('ROSSIA BULLISI'); gmex$spp[i] <<- 'ROSSIA'
  i = gmex$spp %in% c('SOLENOCERA ATLANTIDIS', 'SOLENOCERA NECOPINA', 'SOLENOCERA VIOSCAI'); gmex$spp[i] <<- 'SOLENOCERA'
  i = gmex$spp %in% c('TRACHYPENEUS CONSTRICTUS', 'TRACHYPENEUS SIMILIS'); gmex$spp[i] <<- 'TRACHYPENEUS'

  seusSPRING$spp[seusSPRING$spp %in% c('ANCHOA HEPSETUS','ANCHOA MITCHILLI','ANCHOA LYOLEPIS')] <<- 'ANCHOA'
  seusSPRING$spp[seusSPRING$spp %in% c('LIBINIA DUBIA','LIBINIA EMARGINATA')] <<- 'LIBINIA'
  seusSUMMER$spp[seusSUMMER$spp %in% c('ANCHOA HEPSETUS','ANCHOA MITCHILLI','ANCHOA LYOLEPIS')] <<- 'ANCHOA'
  seusSUMMER$spp[seusSUMMER$spp %in% c('LIBINIA DUBIA','LIBINIA EMARGINATA')] <<- 'LIBINIA'
  seusFALL$spp[seusFALL$spp %in% c('ANCHOA HEPSETUS','ANCHOA MITCHILLI','ANCHOA LYOLEPIS')] <<- 'ANCHOA'
  seusFALL$spp[seusFALL$spp %in% c('LIBINIA DUBIA','LIBINIA EMARGINATA')] <<- 'LIBINIA'
  
  ai2 = aggregate(list(wtcpue = ai$wtcpue), by = list(haulid = ai$haulid, stratum = ai$stratum, stratumarea = ai$stratumarea, year = ai$year, lat = ai$lat, lon = ai$lon, depth = addNA(ai$depth), spp = ai$spp), FUN=sumna) # use addNA() for depth so that NA values are not dropped by aggregate()
  ai2$depth = as.numeric(as.character(ai2$depth)) # convert depth back to a numeric
  
  ebs2 = aggregate(list(wtcpue = ebs$wtcpue), by = list(haulid = ebs$haulid, stratum = ebs$stratum, stratumarea = ebs$stratumarea, year = ebs$year, lat = ebs$lat, lon = ebs$lon, depth = addNA(ebs$depth), spp = ebs$spp), FUN=sumna) # use addNA() for depth so that NA values are not dropped by aggregate()
  ebs2$depth = as.numeric(as.character(ebs2$depth)) # convert depth back to a numeric
  
  goa2 = aggregate(list(wtcpue = goa$wtcpue), by = list(haulid = goa$haulid, stratum = goa$stratum, stratumarea = goa$stratumarea, year = goa$year, lat = goa$lat, lon = goa$lon, depth = addNA(goa$depth), spp = goa$spp), FUN=sumna) # use addNA() for depth so that NA values are not dropped by aggregate()
  goa2$depth = as.numeric(as.character(goa2$depth)) # convert depth back to a numeric
  
  neus2 = aggregate(list(wtcpue = neus$wtcpue), by = list(haulid = neus$haulid, stratum = neus$stratum, stratumarea = neus$stratumarea, year = neus$year, lat = neus$lat, lon = neus$lon, depth = addNA(neus$depth), spp = neus$spp), FUN=sumna) # use addNA() for depth so that NA values are not dropped by aggregate()
  neus2$depth = as.numeric(as.character(neus2$depth)) # convert depth back to a numeric
  
  neusF2 = aggregate(list(wtcpue = neusF$wtcpue), by = list(haulid = neusF$haulid, stratum = neusF$stratum, stratumarea = neusF$stratumarea, year = neusF$year, lat = neusF$lat, lon = neusF$lon, depth = addNA(neusF$depth), spp = neusF$spp), FUN=sumna) # use addNA() for depth so that NA values are not dropped by aggregate()
  neusF2$depth = as.numeric(as.character(neusF2$depth)) # convert depth back to a numeric
  
  wctri2 = aggregate(list(wtcpue = wctri$wtcpue), by = list(haulid = wctri$haulid, stratum = wctri$stratum, stratumarea = wctri$stratumarea, year = wctri$year, lat = wctri$lat, lon = wctri$lon, depth = wctri$depth, spp = wctri$spp), FUN=sumna)
  
  wcann2 = aggregate(list(wtcpue = wcann$wtcpue), by = list(haulid = wcann$haulid, stratum = wcann$stratum, stratumarea = wcann$stratumarea, year = wcann$year, lat = wcann$lat, lon = wcann$lon, depth = wcann$depth, spp = wcann$spp), FUN=sumna)
  
  gmex2 = aggregate(list(wtcpue = gmex$wtcpue), by=list(haulid = gmex$haulid, stratum = gmex$stratum, stratumarea = gmex$stratumarea, year = gmex$year, lat = gmex$lat, lon = gmex$lon, depth = gmex$depth, spp = gmex$spp), FUN=sumna)
  
  seusSPRING2 = aggregate(list(wtcpue = seusSPRING$wtcpue), by=list(haulid = seusSPRING$haulid, stratum = seusSPRING$stratum, stratumarea = seusSPRING$stratumarea, year = seusSPRING$year, lat = seusSPRING$lat, lon = seusSPRING$lon, depth = seusSPRING$depth, spp = seusSPRING$spp), FUN=sumna)
  seusSUMMER2 = aggregate(list(wtcpue = seusSUMMER$wtcpue), by=list(haulid = seusSUMMER$haulid, stratum = seusSUMMER$stratum, stratumarea = seusSUMMER$stratumarea, year = seusSUMMER$year, lat = seusSUMMER$lat, lon = seusSUMMER$lon, depth = seusSUMMER$depth, spp = seusSUMMER$spp), FUN=sumna)
  seusFALL2 = aggregate(list(wtcpue = seusFALL$wtcpue), by=list(haulid = seusFALL$haulid, stratum = seusFALL$stratum, stratumarea = seusFALL$stratumarea, year = seusFALL$year, lat = seusFALL$lat, lon = seusFALL$lon, depth = seusFALL$depth, spp = seusFALL$spp), FUN=sumna)
  
  ai<<-ai2
  ebs<<-ebs2
  goa<<-goa2
  neus<<-neus2
  neusF<<-neusF2
  wctri<<-wctri2
  wcann<<-wcann2
  gmex<<-gmex2
  seusSPRING<<-seusSPRING2    
  seusSUMMER<<-seusSUMMER2    
  seusFALL<<-seusFALL2    
  
  return(TRUE)
}

calculate_corrected_longitude = function () {
  # Calculate a corrected longitude for Aleutians (all in western hemisphere coordinates)
  ai$lon[ai$lon>0] <- ai$lon[ai$lon>0] - 360	
  return(TRUE)
}

add_region_column = function () {
  
  # Add a region column
    ai$region <<- "Aleutian Islands"
    ebs$region <<- "Eastern Bering Sea"
    goa$region <<- "Gulf of Alaska"
    neus$region <<- "Northeast US Spring"
	  neusF$region <<- "Northeast US Fall"
    wctri$region <<- "West Coast Triennial"
    wcann$region <<- "West Coast Annual"
    gmex$region <<- "Gulf of Mexico"
    seusSPRING$region <<- "Southeast US Spring"
  	seusSUMMER$region <<- "Southeast US Summer"
	  seusFALL$region <<- "Southeast US Fall"
	
  #Here are the default names that we're not using currently
#   ai$region <<- "AFSC_Aleutians"
#   ebs$region <<- "AFSC_EBS"
#   goa$region <<- "AFSC_GOA"
#   neus$region <<- "NEFSC_NEUSSpring"
#   wctri$region <<- "AFSC_WCTri"
#   wcann$region <<- "NWFSC_WCAnn"
#   gmex$region <<- "SEFSC_GOMex"
  return(TRUE)
}

rearrange_and_trim_columns = function () {
  # Rearrange and trim columns
  nm = c('region', 'haulid', 'year', 'lat', 'lon', 'stratum', 'stratumarea', 'depth', 'spp', 'wtcpue')
  ai <<- ai[,nm]
  ebs <<- ebs[,nm]
  goa <<- goa[,nm]
  neus <<- neus[,nm]
  neusF <<- neusF[,nm]  
  wctri <<- wctri[,nm]
  wcann <<- wcann[,nm]
  gmex <<- gmex[,nm]
  seusSPRING <<- seusSPRING[,nm]  
  seusSUMMER <<- seusSUMMER[,nm]  
  seusFALL <<- seusFALL[,nm]  
  return(TRUE)
}


create_master_table = function () {
  #  combine and remove NA values
  dat = rbind(ai, ebs, goa, neus, neusF, wctri, wcann, gmex, seusSPRING, seusSUMMER, seusFALL)
  # dim(dat)
  
  # Remove NA values in wtcpue
  dat = dat[!is.na(dat$wtcpue),]
  
  # add a nice spp and common name
  dat2 = merge(dat, tax[,c('taxon', 'name', 'common')], by.x='spp', by.y='taxon')
  dat2$spp = dat2$name
  dat2 = dat2[,c('region', 'haulid', 'year', 'lat', 'lon', 'stratum', 'stratumarea', 'depth', 'spp', 'common', 'wtcpue')]
  
  # check for errors in name matching
  if(sum(dat2$spp == 'NA') > 0 | sum(is.na(dat2$spp)) > 0){
    warning('>>create_master_table(): Did not match on some taxon [Variable: `tax`] names.')
  }
  
  #set dat2 to dat, then return dat
  dat = dat2
  
  return(dat) 
}

#Functions to calculate [by region by species], by region, and by national
species_data = function () {
  #Returns species data
  
  ######################################################
  ## Calculate mean position through time for species ##
  ######################################################
  ## Find a standard set of species (present at least two years in a region)
  presyr = aggregate(list(pres = dat$wtcpue>0), by=list(region = dat$region, spp=dat$spp, common=dat$common, year=dat$year), FUN=sum, na.rm=TRUE) # find which species are present in which years
  presyrsum = aggregate(list(presyr = presyr$pres>0), by=list(region=presyr$region, spp=presyr$spp, common=presyr$common), FUN=sum) # presyr col holds # years in which spp was present
  maxyrs = aggregate(list(maxyrs = presyrsum$presyr), by=list(region = presyrsum$region), FUN=max) # max # years of survey in each region
  presyrsum = merge(presyrsum, maxyrs) # merge in max years
  spplist = presyrsum[presyrsum$presyr >= presyrsum$maxyrs*3/4,c('region', 'spp', 'common')] # retain all spp present at least half the available years in a survey
  
  # Trim to these species
  dat <<- dat[paste(dat$region, dat$spp) %in% paste(spplist$region, spplist$spp),]
  
  # Calculate mean latitude and depth of each species by year within each survey/region
  datstrat = with(dat[!duplicated(dat[,c('region', 'stratum', 'haulid')]),], aggregate(list(lat = lat, lon = lon, depth = depth, stratumarea = stratumarea), by=list(stratum = stratum, region = region), FUN=meanna)) # mean lat/lon/depth for each stratum
  
  datstratyr = aggregate(list(wtcpue = dat$wtcpue), by=list(region = dat$region, spp = dat$spp, common=dat$common, stratum = dat$stratum, year=dat$year), FUN=meanna) # mean wtcpue in each stratum/yr/spp
  
  datstratyr = merge(datstratyr, datstrat) # add stratum lat/lon/depth/area
  datstratyr$wttot = datstratyr$wtcpue * datstratyr$stratumarea # index of biomass per stratum: mean wtcpue times area
  
  centbiolat = summarize(datstratyr[, c('lat', 'wttot')], by = list(region = datstratyr$region, spp = datstratyr$spp, common=datstratyr$common, year = datstratyr$year), FUN = wgtmean, na.rm=TRUE, stat.name = 'lat') # calculate mean lat
  centbiodepth = summarize(datstratyr[, c('depth', 'wttot')], by = list(region = datstratyr$region, spp = datstratyr$spp, common=datstratyr$common, year = datstratyr$year), FUN = wgtmean, na.rm=TRUE, stat.name = 'depth') # mean depth
  centbiolon = summarize(datstratyr[, c('lon', 'wttot')], by = list(region = datstratyr$region, spp = datstratyr$spp, common=datstratyr$common, year = datstratyr$year), FUN = wgtmean, na.rm=TRUE, stat.name = 'lon') # mean depth
  centbio = merge(centbiolat, centbiodepth) # merge together
  centbio = merge(centbio, centbiolon) # merge together
  
  centbiolatse = summarize(datstratyr[, c('lat', 'wttot')], by = list(region = datstratyr$region, spp = datstratyr$spp, year = datstratyr$year), FUN = wgtse, na.rm=TRUE, stat.name = 'latse') # standard error for lat
  centbio = merge(centbio, centbiolatse) # merge together
  
  centbiodepthse = summarize(datstratyr[, c('depth', 'wttot')], by = list(region = datstratyr$region, spp = datstratyr$spp, common=datstratyr$common, year = datstratyr$year), FUN = wgtse, na.rm=TRUE, stat.name = 'depthse') # SE for depth
  centbio = merge(centbio, centbiodepthse) # merge together
  
  centbiolonse = summarize(datstratyr[, c('lon', 'wttot')], by = list(region = datstratyr$region, spp = datstratyr$spp, year = datstratyr$year), FUN = wgtse, na.rm=TRUE, stat.name = 'lonse') # standard error for lon
  centbio = merge(centbio, centbiolonse) # merge together
  
  
  # order by region, species, year
  centbio = centbio[order(centbio$region, centbio$spp, centbio$year),]
  
  return(centbio)
  
}

region_data = function (centbio) {
  #Returns region data
  #Requires function species_data's dataset [by default: BY_SPECIES_DATA] or this function will not run properly.
  
  
  ######################################################
  ## Calculate mean position through time for regions ##
  ######################################################
  ## Find a standard set of species (present every year in a region)
  presyr = aggregate(list(pres = dat$wtcpue>0), by=list(region = dat$region, spp=dat$spp, year=dat$year), FUN=sum, na.rm=TRUE) # find which species are present in which years
  presyrsum = aggregate(list(presyr = presyr$pres>0), by=list(region=presyr$region, spp=presyr$spp), FUN=sum) # presyr col holds # years in which spp was present
  maxyrs = aggregate(list(maxyrs = presyrsum$presyr), by=list(region = presyrsum$region), FUN=max) # max # years of survey in each region
  presyrsum = merge(presyrsum, maxyrs) # merge in max years
  spplist = presyrsum[presyrsum$presyr == presyrsum$maxyr,c('region', 'spp')] # retain all spp present at least once every time a survey occurs
  
  # Make a new centbio dataframe for regional use, only has spp in spplist
  centbio2 = centbio[paste(centbio$region, centbio$spp) %in% paste(spplist$region, spplist$spp),]
  
  # Calculate offsets of lat and depth (start at 0 in initial year of survey)
  startyear = aggregate(list(startyear = centbio2$year), by=list(region = centbio2$region), FUN=min) # find initial year in each region
  centbio2 = merge(centbio2, startyear) # add to dataframe
  startpos = centbio2[centbio2$year == centbio2$startyear, c('region', 'spp', 'lat', 'lon', 'depth')] # find starting lat and depth by spp
  names(startpos)[names(startpos)=='lat'] = 'startlat'
  names(startpos)[names(startpos)=='lon'] = 'startlon'
  names(startpos)[names(startpos)=='depth'] = 'startdepth'
  centbio2 = merge(centbio2, startpos) # add in starting lat and depth
  centbio2$latoffset = centbio2$lat - centbio2$startlat
  centbio2$lonoffset = centbio2$lon - centbio2$startlon
  centbio2$depthoffset = centbio2$depth - centbio2$startdepth
  
  # Calculate regional average offsets
  regcentbio = aggregate(list(lat = centbio2$latoffset, depth = centbio2$depthoffset, lon = centbio2$lonoffset), by=list(year=centbio2$year, region = centbio2$region), FUN=mean)
  regcentbiose = aggregate(list(latse = centbio2$latoffset, depthse = centbio2$depthoffset, lonse = centbio2$lonoffset), by=list(year=centbio2$year, region = centbio2$region), FUN=se)
  regcentbiospp = aggregate(list(numspp = centbio2$spp), by=list(region = centbio2$region), FUN=lunique) # calc number of species per region
  regcentbio = merge(regcentbio, regcentbiose)
  regcentbio = merge(regcentbio, regcentbiospp)
  
  
  # order by region, year
  regcentbio = regcentbio[order(regcentbio$region, regcentbio$year),]
  
  return(regcentbio)
  
}

national_data = function (centbio) {
  #Returns national data
  #Requires function species_data's dataset [by default: BY_SPECIES_DATA] or this function will not run properly.
  #####################################################
  ## Calculate mean position through time for the US ##
  #####################################################
  
  #WHEN USING ENGLISH NAMES FROM add_region_column(), UNCOMMENT NEXT LINE:
  regstouse = c('Eastern Bering Sea', 'Northeast US Spring', 'Northeast US Fall') # Only include regions not constrained by geography in which surveys have consistent methods through time
  #WHEN USING DEFAULT NAMES FROM add_region_column(), UN COMMENT NEXT LINE:
  #regstouse = c('AFSC_EBS', 'NEFSC_NEUSSpring') # Only include regions not constrained by geography in which surveys have consistent methods through time
  natstartyear = 1982 # a common starting year for the both focal regions
  maxyrs = aggregate(list(maxyear = dat$year[dat$region %in% regstouse]), by=list(region=dat$region[dat$region %in% regstouse]), FUN=max)
  natendyear = min(maxyrs$maxyear)
  
  ## Find a standard set of species (present every year in the focal regions) for the national analysis
  inds = dat$year >= natstartyear & dat$year <= natendyear & dat$region %in% regstouse # For national average, start in prescribed year, only use focal regions
  
  presyr = aggregate(list(pres = dat$wtcpue[inds]>0), by=list(region = dat$region[inds], spp=dat$spp[inds], year=dat$year[inds]), FUN=sum, na.rm=TRUE) # find which species are present in which years
  presyrsum = aggregate(list(presyr = presyr$pres>0), by=list(region=presyr$region, spp=presyr$spp), FUN=sum) # presyr col holds # years in which spp was present
  maxyrs = aggregate(list(maxyrs = presyrsum$presyr), by=list(region = presyrsum$region), FUN=max) # max # years of survey in each region
  presyrsum = merge(presyrsum, maxyrs) # merge in max years
  spplist2 = presyrsum[presyrsum$presyr == presyrsum$maxyr,c('region', 'spp')] # retain all spp present at least once every time a survey occurs
  
  # Make a new centbio dataframe for regional use, only has spp in spplist
  centbio3 = centbio[paste(centbio$region, centbio$spp) %in% paste(spplist2$region, spplist2$spp) & centbio$year >= natstartyear & centbio$year <= natendyear , c('region', 'spp', 'year', 'lat', 'lon', 'depth')]
  
  # Calculate offsets of lat and depth (start at 0 in initial year of survey)
  startyear = aggregate(list(startyear = centbio3$year), by=list(region = centbio3$region), FUN=min) # find initial year in each region
  centbio3 = merge(centbio3, startyear) # add to dataframe
  startpos = centbio3[centbio3$year == centbio3$startyear, c('region', 'spp', 'lat', 'lon', 'depth')] # find starting lat and depth by spp
  names(startpos)[names(startpos)=='lat'] = 'startlat'
  names(startpos)[names(startpos)=='lon'] = 'startlon'
  names(startpos)[names(startpos)=='depth'] = 'startdepth'
  centbio3 = merge(centbio3, startpos) # add in starting lat and depth
  centbio3$latoffset = centbio3$lat - centbio3$startlat
  centbio3$lonoffset = centbio3$lon - centbio3$startlon
  centbio3$depthoffset = centbio3$depth - centbio3$startdepth
  
  
  # Calculate national average offsets
  natcentbio = aggregate(list(lat = centbio3$latoffset, depth = centbio3$depthoffset, lon = centbio3$lonoffset), by=list(year=centbio3$year), FUN=mean)
  natcentbiose = aggregate(list(latse = centbio3$latoffset, depthse = centbio3$depthoffset, lonse = centbio3$lonoffset), by=list(year=centbio3$year), FUN=se)
  natcentbio = merge(natcentbio, natcentbiose)
  
  natcentbio$numspp = lunique(paste(centbio3$region, centbio3$spp)) # calc number of species per region  
  
  return(natcentbio)
  
}

plot_species = function(centbio) {
  # Species

	# for latitude
  #quartz(width = 10, height = 8)
  print("Starting latitude plots for species")
  pdf(file=paste(WORKING_DIRECTORY, '/sppcentlatstrat_', Sys.Date(), '.pdf', sep=''), width=10, height=8)
  
  regs = sort(unique(centbio$region))
  for(i in 1:length(regs)){
    print(i)
    par(mfrow = c(6,6), mai=c(0.3, 0.3, 0.2, 0.05), cex.main=0.7, cex.axis=0.8, omi=c(0,0.2,0.1,0), mgp=c(2.8, 0.7, 0), font.main=3)
    spps = sort(unique(centbio$spp[centbio$region == regs[i]]))  
    
    xlims = range(centbio$year[centbio$region == regs[i]])
    
    for(j in 1:length(spps)){
      inds = centbio$spp == spps[j] & centbio$region == regs[i]
      minlat = centbio$lat[inds] - centbio$latse[inds]
      maxlat = centbio$lat[inds] + centbio$latse[inds]
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
  pdf(file=paste(WORKING_DIRECTORY, '/sppcentdepthstrat_', Sys.Date(), '.pdf', sep=''), width=10, height=8)
  
  regs = sort(unique(centbio$region))
  for(i in 1:length(regs)){
    print(i)
    par(mfrow = c(6,6), mai=c(0.3, 0.3, 0.2, 0.05), cex.main=0.7, cex.axis=0.8, omi=c(0,0.2,0.1,0), mgp=c(2.8, 0.7, 0), font.main=3)
    spps = sort(unique(centbio$spp[centbio$region == regs[i]]))  
    
    xlims = range(centbio$year[centbio$region == regs[i]])
    
    for(j in 1:length(spps)){
      inds = centbio$spp == spps[j] & centbio$region == regs[i]
      mindep = centbio$depth[inds] - centbio$depthse[inds]
      maxdep = centbio$depth[inds] + centbio$depthse[inds]
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

}

plot_regional = function(regcentbio) {
  
  # Regional
  #quartz(width=6, height=6)
  pdf(file=paste(WORKING_DIRECTORY, '/regcentlat_depth_strat_', Sys.Date(), '.pdf', sep=''), width=6, height=6)
  par(mfrow=c(3,3)) # page 1: latitude
  
  regs = sort(unique(regcentbio$region))
  for(i in 1:length(regs)){
    inds = regcentbio$region == regs[i]
    minlat = regcentbio$lat[inds] - regcentbio$latse[inds]
    maxlat = regcentbio$lat[inds] + regcentbio$latse[inds]
    xlims = range(regcentbio$year[regcentbio$region == regs[i]])
    ylims = c(min(minlat, na.rm=TRUE), max(maxlat, na.rm=TRUE))
    
    plot(0,0, type='l', ylab='Latitude (°)', xlab='Year', ylim=ylims, xlim=xlims, main=regs[i], las=1)
    polygon(c(regcentbio$year[inds], rev(regcentbio$year[inds])), c(maxlat, rev(minlat)), col='#CBD5E8', border=NA)
    lines(regcentbio$year[inds], regcentbio$lat[inds], col='#D95F02', lwd=2)
  }

  par(mfrow=c(3,3)) # page 2: depth
  regs = sort(unique(regcentbio$region))
  for(i in 1:length(regs)){
    inds = regcentbio$region == regs[i]
    mindep = regcentbio$depth[inds] - regcentbio$depthse[inds]
    maxdep = regcentbio$depth[inds] + regcentbio$depthse[inds]
    xlims = range(regcentbio$year[regcentbio$region == regs[i]])
    ylims = c(min(mindep, na.rm=TRUE), max(maxdep, na.rm=TRUE))
    
    plot(0,0, type='l', ylab='Depth (m)', xlab='Year', ylim=ylims, xlim=xlims, main=regs[i], las=1)
    polygon(c(regcentbio$year[inds], rev(regcentbio$year[inds])), c(maxdep, rev(mindep)), col='#CBD5E8', border=NA)
    lines(regcentbio$year[inds], regcentbio$depth[inds], col='#D95F02', lwd=2)
  }

  
  dev.off()
}

plot_national = function(natcentbio) {
  
  # National
  #quartz(width=6, height=3.5)
  pdf(file=paste(WORKING_DIRECTORY, '/natcentlatstrat_', Sys.Date(), '.pdf', sep=''), width=6, height=3.5)
  par(mfrow=c(1,2), mai=c(0.8, 0.8, 0.3, 0.2), mgp=c(2.4,0.7,0))
  
  minlat = natcentbio$lat - natcentbio$latse
  maxlat = natcentbio$lat + natcentbio$latse
  mindepth = natcentbio$depth - natcentbio$depthse
  maxdepth = natcentbio$depth + natcentbio$depthse
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
}


#  [ programfunction ]
#Begin Preparation Protocol:

#Combine/compile data into single tables based on region.

print_status('Begin region compiling.')

if(!exists('OVERRIDE_COMPILING') || !isTRUE(OVERRIDE_COMPILING) ) {
  tryCatch({
    
    tax = compile_TAX()
    print_status('>TAX: Scientific to Common names done')
    
    ai = compile_AI()
    print_status('>AI done.')
    ebs = compile_EBS()
    print_status('>EBS done.')
    
    goa = compile_GOA()
    print_status('>GOA done.')
    
    neus = compile_NEUS()
    print_status('>NEUS done.')
	
    neusF = compile_NEUSF()
    print_status('>NEUSF done.')
    
    wctri = compile_WCTri()
    print_status('>WCTri done.')
    
    wcann = compile_WCAnn()
    print_status('>WCAnn done.')
    
    gmex = compile_GMEX()
    print_status('>GMEX done.')
    
    seusSPRING = compile_SEUSSpr()
    print_status('>SEUSSpr done.')
    
    seusSUMMER = compile_SEUSSum()
    print_status('>SEUSSum done.')
    
    seusFALL = compile_SEUSFal()
    print_status('>SEUSFal done.')
    
  }, error=function(e) {
    print("[HINT] Please run the program with chdir=TRUE. (e.g. `source('C:/Users/YOUR_USER_NAME/../complete_r_script.R', chdir=TRUE)`")
    stop("[ERROR] One or more files were missing.")
  })
  
}else{
  print_status('>Ignoring data gathering. Overriding the gathering of data is not a standard procedure and may result in errors or incorrect results.')
}


print_status('Region compiling complete.')

print_status('Create Haul IDs for each region.')
haul_id_complete = create_haul_id()
print_status('Done.')

print_status('Extract year from field if needed..')
year_extraction_complete = extract_year()
print_status('Done.')

print_status('[GMEX] Convert latitude/longitude values to Decimal Lat/Longs.')
gmex_lat_long_calculation_complete = gmex_calculate_decimal_lat_lon()
print_status('Done.')

print_status('Add Stratum to regions.')
adding_stratum_complete = add_stratum()
print_status('Done.')

if(isTRUE(HQ_DATA_ONLY)) {
  print_status('Removing Low-Quality Data.')
  hq_strata_complete = high_quality_strata()
    print_status('>Low-Quality Strata removed.')
  hq_years_complete = high_quality_years()
    print_status('>Low-Quality Years removed.')
  print_status('Done.')
}else{
  print_status('Skipping removal of Low-Quality Data.')
  hq_years_complete = TRUE
  hq_strata_complete = TRUE
}

print_status('Fix speeds if necessary.')
fix_speed_complete = fix_speed()
print_status('Done.')

print_status('Calculate Stratum Area')
calculate_stratum_area_complete = calculate_stratum_area()
print_status('Done.')

print_status('Update Column Names.')
column_names_update_complete = column_names_updated()
print_status('Done.')

print_status('Change -9999 to NA where appropriate.')
neg_9999_complete = change_neg_9999_to_NA()
print_status('Done.')

print_status('Adjust for TOW area where needed.')
adjust_tow_area_complete = adjust_tow_area()
print_status('Done.')

print_status('Removed paired TOWs.')
remove_paired_tows_complete = remove_paired_tows()
print_status('Done.')


print_status('Removing rows without scientific names or that aren\'t fish or inverts')
remove_non_sci_fish_inv_complete = remove_rows_without_sci_names_or_fish_or_inverts()
print_status('Done.')

print_status('Adjust spp names where changed or modified.')
adjust_spp_names_complete = adjust_spp_names()
print_status('Done.')
             
print_status('Calculate corrected longitude where needed.')
calculate_corrected_longitude_complete = calculate_corrected_longitude()
print_status('Done.')

print_status('Add region columns.')
add_region_columns_complete = add_region_column()
print_status('Done.')


print_status('Rearrange and Trim Columns.')
rearrange_and_trim_complete = rearrange_and_trim_columns()
print_status('Done.')



#Master data set 
print_status('Creating master database table.')
dat = create_master_table ()
print_status('Done.')

print_status('Cleaning extra variables.')
if(isTRUE(REMOVE_REGION_DATASETS)) {
  print_status('>Cleaning region datasets (BY-FLAG `REMOVE_REGION_DATASETS`).')
  rm(ai,ebs,gmex,goa,neus,wcann,wctri)
}

#Clear boolean complete values. 
rm( haul_id_complete, year_extraction_complete, gmex_lat_long_calculation_complete, adding_stratum_complete,  hq_years_complete, hq_strata_complete,  fix_speed_complete,  calculate_stratum_area_complete, column_names_update_complete, neg_9999_complete, adjust_tow_area_complete, remove_paired_tows_complete,  remove_non_sci_fish_inv_complete, adjust_spp_names_complete, calculate_corrected_longitude_complete, add_region_columns_complete, rearrange_and_trim_complete)

print_status('Scientific name/Common name data available: `tax` ')
print_status('National data available: `dat` ')
if(!isTRUE(REMOVE_REGION_DATASETS)) {
  print_status('Regional data available: `ai`, `ebs`, `gmex`, `goa`, `neus`, `neusF`, `wcann`, `seusSPRING`, `seusSUMMER`, `seusFALL`, and `wctri`')
}

if(isTRUE(OPTIONAL_OUTPUT_DAT_MASTER_TABLE)){
  print_status(paste('Outputting `dat` to file in `',  WORKING_DIRECTORY, '`.', sep='') )
  save(dat, file=paste(WORKING_DIRECTORY, '/trawl_allregions_', Sys.Date(), '.RData', sep='') )
}

print_status('**DATA PREPARATION COMPLETE**')

#At this point, we have a compiled `dat` master table on which we can begin our analysis.
#If you have not cleared the regional datasets {By setting REMOVE_REGION_DATASETS=FALSE at the top}, 
#you are free to do analysis on those sets individually as well.

#  [ modifyprogram ]
##FEEL FREE TO ADD, MODIFY, OR DELETE ANYTHING BELOW THIS LINE

print_status('Begin calculating by species, region, and national data')
##species_data modifies dat
BY_SPECIES_DATA = species_data() #NOTE: Might take a little bit depending on processor speed
print_status('>Species data complete.')
BY_REGION_DATA = region_data(BY_SPECIES_DATA) ##This function requires use of Species data and will not run properly without it.
print_status('>Region data complete.')
BY_NATIONAL_DATA = national_data(BY_SPECIES_DATA) ##This function requires use of Species data and will not run properly without it.
print_status('>National data complete.')
print_status('Data Calculations Complete')

if(isTRUE(OPTIONAL_PLOT_CHARTS)) {
  #These functions are special to these datasets and might not work as intended with custom sets.
  #For best results you should make your own functions to plot charts.
  
  print_status('Begin plotting.')
  # Species
  print_status( paste('>Plotting species to pdf in `',  WORKING_DIRECTORY, '`.', sep='') )
  plot_species(BY_SPECIES_DATA) 
  print_status( paste('>Plotting regional to pdf in `',  WORKING_DIRECTORY, '`.', sep='') )
  plot_regional(BY_REGION_DATA) 
  print_status( paste('>Plotting national to pdf in `',  WORKING_DIRECTORY, '`.', sep='') )
  plot_national(BY_NATIONAL_DATA) 
  
}else{
  print_status('Skipping plotting charts.')  
}

print_status('PROGRAM COMPLETED SUCCESSFULLY.')  

