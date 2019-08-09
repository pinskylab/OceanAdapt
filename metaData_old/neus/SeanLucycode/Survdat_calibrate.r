#Survdat.RData
#This script will generate data from the NEFSC spring and fall bottom trawl surveys
#Version 1.0
#5/2013
#SML

#-------------------------------------------------------------------------------
#User parameters
out.dir <- "L:\\EcoAP\\Data\\survey"
shg.check <- 'y' # y = use only SHG <=136 otherwise n
raw.check <- 'n' # y = save data without conversions (survdat.raw), will still save data with conversions (survdat)

#-------------------------------------------------------------------------------
#Required packages
library(RODBC); library(data.table)

#-------------------------------------------------------------------------------
#Created functions
  #Convert output to text for RODBC query
sqltext<-function(x){
  out<-x[1]
  if(length(x) > 1){
    for(i in 2:length(x)){
      out<-paste(out, x[i], sep="','")
    }
  }
  out<-paste("'", out, "'", sep='')
  return(out)
}

#-------------------------------------------------------------------------------
#Begin script

#Increase memory size (max is 4096 in 32-bit R)
memory.limit(4000)

#Connect to Oracle
channel <- odbcDriverConnect()

#Generate cruise list
cruise.qry <- "select unique year, cruise6, svvessel, season
  from mstr_cruise
  where purpose_code = 10
  and year >= 1963
  and (season = 'FALL'
    or season = 'SPRING')
  order by year, cruise6"

cruise <- as.data.table(sqlQuery(channel, cruise.qry))
cruise <- na.omit(cruise)
setkey(cruise, CRUISE6, SVVESSEL)

#Use cruise codes to select other data
cruise6 <- sqltext(cruise$CRUISE6)

#Station data
if(shg.check == 'y'){
  station.qry <- paste("select unique cruise6, svvessel, station, stratum, decdeg_beglat as lat, decdeg_beglon as lon,
    avgdepth as depth, surftemp, surfsalin, bottemp, botsalin
    from Union_fscs_svsta
    where cruise6 in (", cruise6, ")
    and SHG <= 136
    order by cruise6, station", sep='')
  }

if(shg.check == 'n'){
  station.qry <- paste("select unique cruise6, svvessel, station, stratum, decdeg_beglat as lat, decdeg_beglon as lon,
    avgdepth as depth, surftemp, surfsalin, bottemp, botsalin
    from UNION_FSCS_SVSTA
    where cruise6 in (", cruise6, ")
    order by cruise6, station", sep='')
  }
  
station <- as.data.table(sqlQuery(channel, station.qry))
setkey(station, CRUISE6, SVVESSEL)

#merge cruise and station
survdat <- merge(cruise, station)

#Catch data
catch.qry <- paste("select cruise6, station, stratum, svspp, catchsex, expcatchnum as abundance, expcatchwt as biomass
  from UNION_FSCS_SVCAT
  where cruise6 in (", cruise6, ")
  order by cruise6, station, svspp", sep='')

catch <- as.data.table(sqlQuery(channel, catch.qry))
setkey(catch, CRUISE6, STATION, STRATUM)

#merge with survdat
setkey(survdat, CRUISE6, STATION, STRATUM)
survdat <- merge(survdat, catch)

#Length data
length.qry <- paste("select cruise6, station, stratum, svspp, catchsex, length, expnumlen as numlen
  from UNION_FSCS_SVLEN
  where cruise6 in (", cruise6, ")
  order by cruise6, station, svspp, length", sep='')

len <- as.data.table(sqlQuery(channel, length.qry))
setkey(len, CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX)

#merge with survdat
setkey(survdat, CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX)
survdat <- merge(survdat, len, all.x = T)

if(raw.check == 'y'){
  survdat.raw <- survdat
  save(survdat.raw, file = paste(out.dir, "\\Survdat_raw.RData", sep =''))
  }

#Conversion Factors
#need to make abundance column a double instead of an integer
survdat[, ABUNDANCE := as.double(ABUNDANCE)]

#Grab all conversion factors off the network
convert.qry <- "select *
  from survan_conversion_factors"

convert <- as.data.table(sqlQuery(channel,convert.qry))

#DCF < 1985 Door Conversion
dcf.spp <- convert[DCF_WT > 0, SVSPP]
for(i in 1:length(dcf.spp)){
  survdat[YEAR < 1985 & SVSPP == dcf.spp[i],
      BIOMASS := BIOMASS * convert[SVSPP == dcf.spp[i], DCF_WT]]
  }
dcf.spp <- convert[DCF_NUM > 0, SVSPP]
for(i in 1:length(dcf.spp)){
  survdat[YEAR < 1985 & SVSPP == dcf.spp[i],
      ABUNDANCE := round(ABUNDANCE * convert[SVSPP == dcf.spp[i], DCF_NUM])]
  }

#GCF Spring 1973-1981  Net Conversion
gcf.spp <- convert[GCF_WT > 0, SVSPP]
for(i in 1:length(gcf.spp)){
  survdat[SEASON == 'SPRING' & YEAR > 1972 & YEAR < 1982 & SVSPP == gcf.spp[i],
      BIOMASS := BIOMASS / convert[SVSPP == gcf.spp[i], GCF_WT]]
  }
gcf.spp <- convert[GCF_NUM > 0, SVSPP]
for(i in 1:length(gcf.spp)){
  survdat[SEASON == 'SPRING' & YEAR > 1972 & YEAR < 1982 & SVSPP == gcf.spp[i],
      ABUNDANCE := round(ABUNDANCE / convert[SVSPP == gcf.spp[i], GCF_NUM])]
  }

#VCF SVVESSEL=DE  Vessel Conversion
vcf.spp <- convert[VCF_WT > 0, SVSPP]
for(i in 1:length(vcf.spp)){
  survdat[SVVESSEL == 'DE' & SVSPP == vcf.spp[i],
      BIOMASS := BIOMASS * convert[SVSPP == vcf.spp[i], VCF_WT]]
  }
vcf.spp <- convert[VCF_NUM > 0, SVSPP]
for(i in 1:length(vcf.spp)){
  survdat[SVVESSEL == 'DE' & SVSPP == vcf.spp[i],
      ABUNDANCE := round(ABUNDANCE * convert[SVSPP == vcf.spp[i], VCF_NUM])]
  }

#Bigelow >2008 Vessel Conversion - need flat files (not on network)
big.fall <- as.data.table(read.csv('bigelow_fall_calibration.csv'))
big.spring <- as.data.table(read.csv('bigelow_spring_calibration.csv'))

bf.spp <- big.fall[pW != 1, svspp]
for(i in 1:length(bf.spp)){
  survdat[SVVESSEL == 'HB' & SEASON == 'FALL' & SVSPP == bf.spp[i],
      BIOMASS := BIOMASS / big.fall[svspp == bf.spp[i], pW]]
  }
bf.spp <- big.fall[pw != 1, svspp]
for(i in 1:length(bf.spp)){
  survdat[SVVESSEL == 'HB' & SEASON == 'FALL' & SVSPP == bf.spp[i],
      ABUNDANCE := round(ABUNDANCE / big.fall[svspp == bf.spp[i], pw])]
  }

bs.spp <- big.spring[pW != 1, svspp]
for(i in 1:length(bs.spp)){
  survdat[SVVESSEL == 'HB' & SEASON == 'SPRING' & SVSPP == bs.spp[i],
      BIOMASS := BIOMASS / big.spring[svspp == bs.spp[i], pW]]
  }
bs.spp <- big.spring[pw != 1, svspp]
for(i in 1:length(bs.spp)){
  survdat[SVVESSEL == 'HB' & SEASON == 'SPRING' & SVSPP == bs.spp[i],
      ABUNDANCE := round(ABUNDANCE / big.spring[svspp == bs.spp[i], pw])]
  }

odbcClose(channel)


save(survdat, file = paste(out.dir, "\\Survdat.RData", sep=''))





