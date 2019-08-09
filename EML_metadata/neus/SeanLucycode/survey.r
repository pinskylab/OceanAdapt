#Survey.r
#Simple scripts to segerate survey data
#3/14
#SML

#User parameters
data.dir <- "L:\\EcoAP\\Data\\survey\\"
out.dir  <- "L:\\EcoAP\\misc\\"

#-------------------------------------------------------------------------------
#Required packages
library(data.table)

#-------------------------------------------------------------------------------
#User created functions

#-------------------------------------------------------------------------------
load(paste(data.dir, "survdat.Rdata", sep = ''))

#survdat is a data table which can key several columns
#To get just stations
setkey(survdat, 
       CRUISE6,
       STATION,
       STRATUM)
station <- unique(survdat)
#Drop species columns
station[, c('SVSPP', 'CATCHSEX', 'ABUNDANCE', 'BIOMASS', 'LENGTH', 'NUMLEN') := NULL]

#To get catch
setkey(survdat,
       CRUISE6,
       STATION,
       STRATUM,
       SVSPP,
       CATCHSEX)
catch <- unique(survdat)
#drop length columns
catch[, c('LENGTH', 'NUMLEN') := NULL]
#could also drop station data
catch[, c('SVVESSEL', 'LAT', 'LON', 'DEPTH', 'SURFTEMP', 'SURFSALIN', 'BOTTEMP', 'BOTSALIN') := NULL]

#Get length data for 1 species (i.e. Cod)
cod <- survdat[SVSPP == 73, ]

#or just fall
cod.fall <- cod[SEASON == 'FALL', ]

#Add zero catch
setkey(station,
       CRUISE6,
       STATION,
       STRATUM,
       YEAR,
       SEASON)
       
cod.fall.all <- merge(station[SEASON == 'FALL', ], catch[SVSPP == 73 & SEASON == 'FALL', ], by = key(station), all = T)
#Fix NAs from merge
cod.fall.all[, SVSPP := 73L]
cod.fall.all[, CATCHSEX := 0L]
cod.fall.all[is.na(ABUNDANCE), ABUNDANCE := 0]
cod.fall.all[is.na(BIOMASS), BIOMASS := 0]

#can output as Rdata or csv
save(cod.fall.all, file = paste(out.dir, "cod_fall.Rdata", sep = ''))
write.csv(cod.fall.all, file = paste(out.dir, "cod_fall.csv", sep =''), row.names = F)
       






