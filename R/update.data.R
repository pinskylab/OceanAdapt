

library(data.table)


# ==================
# = Old Data Files =
# ==================

read.csv.zip <- function(zipfile, pattern="\\.csv$", ...) {
	
	# Create a name for the dir where we'll unzip
	zipdir <- tempfile()
	
	# Create the dir using that name
	dir.create(zipdir)
	
	# Unzip the file into the dir
	unzip(zipfile, exdir=zipdir)
	
	# Get a list of csv files in the dir
	files <- list.files(zipdir, rec=TRUE, pattern=pattern)
	
	# Create a list of the imported csv files
	csv.data <- sapply(files, 
		function(f){
		    fp <- file.path(zipdir, f)
			dat <- fread(fp, ...)
			flush.console()
		    return(dat)
		}
	)
	
	# Use csv names to name list elements
	# un <- gsub(gsub("(?<=\\/).+", "", files[1],perl=T),"",files)
	un <- gsub(".+\\/", "", files,perl=T) # just use basename() instead?
	names(csv.data) <- un
	
	# Return data
	return(csv.data)
}

# ============================================
# = Read in Old Data Sets (currently zipped) =
# ============================================
zipFiles <- file.info(list.files("~/Documents/School&Work/pinskyPost/OceanAdapt/data", full=TRUE, patt="^Data_Updated_.+"))
recentZip <- row.names(zipFiles[order(zipFiles$mtime, zipFiles$ctime, zipFiles$atime, decreasing=TRUE)[1],])
upData <- read.csv.zip(recentZip)
old.csv.names <- names(upData)

# Unzip locally
# this kind of makes the whole process of read.csv.zip function pointless, as now I could simply read in the data files from this folder
# actually, nvm, it's still useful if the newly downloaded data are in a zip file
unzip(recentZip, exdir="~/Documents/School&Work/pinskyPost/OceanAdapt/data", setTimes=TRUE)
zip.folder <- gsub("(\\.[^.]+$)", "", recentZip)
new.zip.folder <- gsub("(?<=Data_Updated).+", "", zip.folder, perl=T)
file.rename(zip.folder, new.zip.folder) # rename folder


# =============
# = Update AI =
# =============
# this approach prevents adding duplicate rows either by using write.csv(..., append=TRUE), or by rbind() on something that's already been updated
oldAI <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/ai_data.csv")
oldAI <- upData$ai_data.csv
if(file.exists("~/Downloads/ai2014.csv")){
	newAI <- as.data.table(read.csv("~/Downloads/ai2014.csv")) # had to use read.csv to auto remove whitespace in col names
	updatedAI0 <- rbind(oldAI, newAI)
	updatedAI <- as.data.table(updatedAI0)
	setkeyv(updatedAI, names(updatedAI))
	updatedAI <- unique(updatedAI)
	write.csv(updatedAI, file="~/Documents/School&Work/pinskyPost/OceanAdapt/ai_data.csv", row.names=FALSE)
}




# ==============
# = Update EBS =
# ==============
oldEBS <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/ebs_data.csv")
newEBS <- as.data.table(read.csv("~/Downloads/ebs201_20143.csv")) # had to use read.csv to auto remove whitespace in col names
updatedEBS0 <- rbind(oldEBS, newEBS)
updatedEBS <- as.data.table(updatedEBS0)
setkeyv(updatedEBS, names(updatedEBS))
updatedEBS <- unique(updatedEBS)
write.csv(updatedEBS, file="~/Documents/School&Work/pinskyPost/OceanAdapt/ebs_data.csv", row.names=FALSE)


# ==============
# = Update GOA =
# ==============
# As of 5-June-2015, GOA doesn't have any new data (new meaning 2014)
# skip for now


# ===============
# = Update WFSC =
# ===============
# oldWC.fish <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/wcann_fish.csv", colClasses=c("character","character","numeric","numeric"))
oldWC <- upData[grepl("wcann", names(upData))]

zipFiles_wc <- file.info(list.files("~/Downloads", full=TRUE, patt="^Comprehensive.+.zip"))
recentZip_wc <- row.names(zipFiles_wc[order(zipFiles_wc$mtime, zipFiles_wc$ctime, zipFiles_wc$atime, decreasing=TRUE)[1],])
newWC <- read.csv.zip(recentZip_wc, integer64="character")

namesWC <- c("wcann_fish.csv","wcann_haul.csv","wcann_invert.csv")
wc.match <- c(
	wcann_fish.csv="ComprehensiveDataPkg_20150722FishCatch.csv",
	wcann_haul.csv="ComprehensiveDataPkg_20150722Hauls.csv",
	wcann_invert.csv="ComprehensiveDataPkg_20150722_InvertebrateCatch.csv"
)

# WC Ann Fish
wcann_fish.names <- names(oldWC$wcann_fish.csv)
new_wcann_fish <- newWC[[wc.match["wcann_fish.csv"]]][,wcann_fish.names,with=F]

# WC Ann Haul
wcann_haul.names <- names(oldWC$wcann_haul.csv)
new_wcann_haul <- newWC[[wc.match["wcann_haul.csv"]]][,wcann_haul.names,with=F]

# WC Ann Invert
wcann_invert.names <- names(oldWC$wcann_invert.csv)
new_wcann_invert <- newWC[[wc.match["wcann_invert.csv"]]][,wcann_invert.names,with=F]

write.csv(new_wcann_fish, file=paste(new.zip.folder,"wcann_fish.csv",sep="/"), row.names=FALSE)
write.csv(new_wcann_invert, file=paste(new.zip.folder,"wcann_invert.csv",sep="/"), row.names=FALSE)
write.csv(new_wcann_haul, file=paste(new.zip.folder,"wcann_haul.csv",sep="/"), row.names=FALSE)




# newWC <- as.data.table(read.csv("~/Downloads/wcann201_20143.csv")) # had to use read.csv to auto remove whitespace in col names
# updatedWC0 <- rbind(oldWC, newWC)
# updatedWC <- as.data.table(updatedWC0)
# setkeyv(updatedWC, names(updatedWC))
# updatedWC <- unique(updatedWC)
# write.csv(updatedWC, file="~/Documents/School&Work/pinskyPost/OceanAdapt/wcann_data.csv", row.names=FALSE)


# ===============
# = Update GMEX =
# ===============
# bio
newGMEX.bio0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/BGSREC.csv"))
oldGMEX.bio <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_bio.csv")
# any(!names(oldGMEX.bio)%in%names(newGMEX.bio0)) # FALSE good
gmex.bio.names <- names(oldGMEX.bio)
newGMEX.bio <- newGMEX.bio0[,(gmex.bio.names), with=FALSE]
write.csv(newGMEX.bio, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_bio.csv", row.names=FALSE)

# cruise
newGMEX.cruise0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/CRUISES.csv"))
oldGMEX.cruise <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_cruise.csv")
# any(!names(oldGMEX.bio)%in%names(newGMEX.bio0)) # FALSE good
gmex.cruise.names <- names(oldGMEX.cruise)
oldGMEX.cruise <- newGMEX.cruise0[,(gmex.cruise.names), with=FALSE]
write.csv(oldGMEX.cruise, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_cruise.csv", row.names=FALSE)

# spp
newGMEX.spp0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/NEWBIOCODESBIG.csv"))
oldGMEX.spp <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_spp.csv")
# any(!names(oldGMEX.spp)%in%names(newGMEX.spp0)) # FALSE good
gmex.spp.names <- names(oldGMEX.spp)
oldGMEX.spp <- newGMEX.spp0[,(gmex.spp.names), with=FALSE]
write.csv(oldGMEX.spp, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_spp.csv", row.names=FALSE)

# station
newGMEX.station0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/STAREC.csv")) # had to open .csv in excel, resave as a csv. Did nothing else, then worked.
oldGMEX.station <- as.data.table(read.csv("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_station.csv"))
# any(!names(oldGMEX.station)%in%names(newGMEX.station0)) # FALSE good
gmex.station.names <- names(oldGMEX.station)
oldGMEX.station <- newGMEX.station0[,(gmex.station.names), with=FALSE]
write.csv(oldGMEX.station, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_station.csv", row.names=FALSE)

# tow
newGMEX.tow0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/INVREC.csv"))
oldGMEX.tow <- as.data.table(read.csv("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_tow.csv"))
# any(!names(oldGMEX.tow)%in%names(newGMEX.tow0)) # FALSE good
gmex.tow.names <- names(oldGMEX.tow)
oldGMEX.tow <- newGMEX.tow0[,(gmex.tow.names), with=FALSE]
write.csv(oldGMEX.tow, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_tow.csv", row.names=FALSE)



# =====================
# = Zip Up and Rename =
# =====================
zip(new.zip.folder, files=list.files(new.zip.folder, full=TRUE))
new.zip.file0 <- paste0(new.zip.folder,".zip")
file.rename(new.zip.file0, renameNow(new.zip.file0))
