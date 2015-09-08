
# =================
# = Load Packages =
# =================
library(data.table)
library(rbLib) # library(devtools); install_github("rBatt/rbLib")


# ===============================
# = Guess appropriate directory =
# ===============================
if(Sys.info()["sysname"]=="Linux"){
	setwd("~/Documents/School&Work/pinskyPost/OceanAdapt/")
}else{
	setwd("~/Documents/School&Work/pinskyPost/OceanAdapt/")
}



# =======================================
# = Names & Locations of New Data Files =
# =======================================
date.zip.patt <- "[0-9]{4}-[0-9]{2}-[0-9]{2}.zip"

# AI
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# ai.file <- "~/Downloads/ai2014.csv" # TODO pointless
ai.raw.path.top <- file.path("./data_raw/ai")
ai.fileS <- list.files(ai.raw.path.top, full.names=T, pattern=date.zip.patt)
ai.file2 <- "~/Downloads/ai_strata.csv"


# EBS
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# ebs.file <- "~/Downloads/ebs201_20143.csv"
ebs.raw.path.top <- file.path("./data_raw/ebs")
ebs.fileS <- list.files(ebs.raw.path.top, full.names=T, pattern=date.zip.patt)
ebs.file2 <- "~/Downloads/ebs_strata.csv"

# GOA
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# goa.file <- "~/Downloads/goa2007_2013.csv"
goa.raw.path.top <- file.path("./data_raw/goa")
goa.fileS <- list.files(goa.raw.path.top, full.names=T, pattern=date.zip.patt)
goa.file2 <- "~/Downloads/goa_strata.csv"

# GMEX
# http://seamap.gsmfc.org/
gmex.bio.file <- "~/Downloads/public_seamap_csvs/BGSREC.csv"
gmex.cruise.file <- "~/Downloads/public_seamap_csvs/CRUISES.csv"
gmex.spp.file <- "~/Downloads/public_seamap_csvs/NEWBIOCODESBIG.csv"
gmex.station.file <- "~/Downloads/public_seamap_csvs/STAREC.csv"
gmex.tow.file <- "~/Downloads/public_seamap_csvs/INVREC.csv"

# NEUS
# Sean Lucey - NOAA Federal <sean.lucey@noaa.gov>
neus.file <- "~/Downloads/Survdat.RData"


# WC
# Email Beth Horness <Beth.Horness@noaa.gov>
zipFiles_wc <- file.info(list.files("~/Downloads", full=TRUE, patt="^Comprehensive.+.zip"))
wc.match <- c(
	wcann_fish.csv="ComprehensiveDataPkg_20150722FishCatch.csv",
	wcann_haul.csv="ComprehensiveDataPkg_20150722Hauls.csv",
	wcann_invert.csv="ComprehensiveDataPkg_20150722_InvertebrateCatch.csv"
)
wcann.zip.file <- row.names(zipFiles_wc[order(zipFiles_wc$mtime, zipFiles_wc$ctime, zipFiles_wc$atime, decreasing=TRUE)[1],])


# ====================================================
# = Function to Trim Trailing and Leading Whitespace =
# ====================================================
# http://stackoverflow.com/questions/2261079/how-to-trim-leading-and-trailing-whitespace-in-r
# Simple regex, but the answer also provides some other handy tricks
# and explanation if others are interested in learning more
trim <- function (x) gsub("^\\s+|\\s+$", "", x)


# ==============================
# = Function to Wrap in Quotes =
# ==============================
wrap.quotes <- function(x){gsub("(.+)", "\"\\1\"", x)}


# ===================================
# = Function to read files from zip =
# ===================================
read.csv.zip <- function(zipfile, pattern="\\.csv$", SIMPLIFY=TRUE, ...){
	
	# Create a name for the dir where we'll unzip
	zipdir <- tempfile()
	
	# Create the dir using that name
	dir.create(zipdir)
	
	# Unzip the file into the dir
	unzip(zipfile, exdir=zipdir)
	
	# Get a list of csv files in the dir
	files <- list.files(zipdir, rec=TRUE, pattern=pattern)
	
	# Create a list of the imported csv files
	if(SIMPLIFY){
		csv.data <- sapply(files, 
			function(f){
			    fp <- file.path(zipdir, f)
				dat <- fread(fp, ...)
			    return(dat)
			}
		)
	}else{
		csv.data <- lapply(files, 
			function(f){
			    fp <- file.path(zipdir, f)
				dat <- fread(fp, ...)
			    return(dat)
			}
		)
	}
	
	
	# Use csv names to name list elements
	names(csv.data) <- basename(files)
	
	# Return data
	return(csv.data)
}


# ============================================
# = Read in Old Data Sets (currently zipped) =
# ============================================
zipFiles <- file.info(list.files("./data_updates", full=TRUE, patt="^Data_.+.zip")) # zipFiles only used in next few lines; intended to find old data sets, which is used both for main data (which we're now just redownloading every year), as well as for the strata files etc.
recentZip <- row.names(zipFiles[order(zipFiles$mtime, zipFiles$ctime, zipFiles$atime, decreasing=TRUE)[1],])
# upData <- read.csv.zip(recentZip, integer64="character")
data.vis <- sort(list.files("./data_download",pattern="Data_Vis_.[0-9,_]*.zip", full=T),dec=T)[1] # grab most recent data.viz 
upData <- read.csv.zip(data.vis) # TODO This should probably go back to using recentZip
old.csv.names <- names(upData)


# ===========================
# = Identify New Zip Folder =
# ===========================
# new.zip.folder is where all the newly-gathered .csv's will be written
# for NEUS, is also where the helper data file (strat or spp id file) will be read
# is where a lot of the other data organization processes occur
# new.zip.folder <- "data_updates" #paste0(dirname(zip.folder),"/data_updates")
zip.folder <- gsub("(\\.[^.]+$)", "", recentZip)
new.zip.folder <- paste0(dirname(zip.folder),"/Data_Updated")


# ========================================================
# = Prepare the Directory that will be Focus of Updates  =
# ========================================================
	# ensure clean start by deleting this directory and all of its contents, the recreating it
if(file.exists(new.zip.folder)){
	# delete all of directory's contents & directory
	unlink(new.zip.folder, recursive=TRUE)
}

if(!file.exists(new.zip.folder)){
	dir.create(new.zip.folder)
}else{
	stop(paste0(
		"Failure to automatically remove directory named \n\t\t", 
		new.zip.folder, 
		"\nFresh start cannot be ensured.",
		"\nPlease remove directory and its contents manually,",
		"\nand proceed with caution (paths have likely been altered)."
	))
}


# ======================================
# = Unzip Most Recent Zip File Locally =
# ======================================
# create explosion of .csv files inside data_updates
# these .csv's are from data vis
# they are used for the bonus files like ebs_strata.csv, or neus_strata.csv
# these are files that are not reaquired during the data updating procedure (from raw file collection)
unzip(normalizePath(recentZip), exdir=new.zip.folder, junkpaths=TRUE, setTimes=TRUE)


# =============
# = Update AI =
# =============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# oldAI <- upData$ai_data.csv
if(length(ai.fileS)>=1){ # if not 0 will be true
	# Load updated, partially old AI
	recent.ai.old <- sort(ai.fileS, dec=T)[1]
	oldAI <- read.csv.zip(recent.ai.old, SIMPLIFY=FALSE)
	for(i in 1:length(oldAI)){
		if(i==1){
			t.oldAI <- oldAI[[1]]
			setnames(t.oldAI, trim(names(t.oldAI)))
			oldAI.hold <- oldAI[[1]]
			
		}else{
			t.oldAI <- oldAI[[i]]
			setnames(t.oldAI, trim(names(t.oldAI)))
			oldAI.hold <- rbind(oldAI.hold, t.oldAI)
			
		}
	}
	updatedAI <- copy(oldAI.hold)
	rm(list=c("oldAI", "oldAI.hold", "t.oldAI"))
	
	# # Load Data
# 	newAI <- as.data.table(read.csv(ai.file)) # had to use read.csv to auto remove whitespace in col names
#
# 	# Get and Check Names
# 	ai.names <- names(oldAI)
# 	stopifnot(all(ai.names%in%names(newAI)))
#
# 	# Accumulate data (region's files are not cummulative)
# 	updatedAI0 <- rbind(oldAI, newAI)
#
# 	# Sort, drop redundant rows
# 	updatedAI <- as.data.table(updatedAI0) # confirm that it's a data file (can probably be removed)
	setkeyv(updatedAI, names(updatedAI)) # sort, and define which columns determine uniqueness of rows
	updatedAI <- unique(updatedAI) # drops redundant rows
#
	# Save data
	write.csv(updatedAI, file=paste(new.zip.folder,"ai_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
} # WORKS 2015-08-27 RDB

# Update Strata file
oldAI2 <- upData$ai_strata.csv
if(file.exists(ai.file2)){ # NOT FOUND, NO CHECK 2015-08-27 RDB
	newAI2 <- as.data.table(read.csv(ai.file2)) # had to use read.csv to auto remove whitespace in col names
	ai.names2 <- names(oldAI2)
	stopifnot(all(ai.names2%in%names(newAI2)))
	updatedAI2 <- newAI2[,ai.file2,with=F]
	setkeyv(updatedAI2, names(updatedAI2))
	updatedAI2 <- unique(updatedAI2)
	write.csv(updatedAI2, file=paste(new.zip.folder,"ai_strata.csv",sep="/"), row.names=FALSE, quote=FALSE)
}


# ==============
# = Update EBS =
# ==============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# oldEBS <- upData$ebs_data.csv
# ebs.raw.path.top <- file.path("./data_raw/ebs")
# ebs.fileS <- list.files(ebs.old.path.top, full.names=T, pattern=date.zip.patt)
if(length(ebs.fileS)>=1){ # if not 0 will be true
	# Load updated, partially old EBS
	recent.ebs.old <- sort(ebs.fileS, dec=T)[1]
	oldEBS <- read.csv.zip(recent.ebs.old, SIMPLIFY=FALSE)
	for(i in 1:length(oldEBS)){
		if(i==1){
			oldEBS.hold <- oldEBS[[1]]
		}else{
			oldEBS.hold <- rbind(oldEBS.hold, oldEBS[[i]])
		}
	}
	updatedEBS <- copy(oldEBS.hold)
	rm(list=c("oldEBS", "oldEBS.hold"))
	
	# # Load Data
# 	newEBS <- as.data.table(read.csv(ebs.file)) # had to use read.csv to auto remove whitespace in col names
#
# 	# Get names, make sure new data has all needed names
# 	ebs.names <- names(oldEBS)
# 	stopifnot(all(ebs.names%in%names(newEBS)))
#
# 	# Accumulate data (region's files are not cummulative)
# 	updatedEBS0 <- rbind(oldEBS, newEBS)
#
# 	# Sort data, drop redundant rows
# 	updatedEBS <- as.data.table(updatedEBS0)
	setkeyv(updatedEBS, names(updatedEBS))
	updatedEBS <- unique(updatedEBS)
	
	# Save updated file
	write.csv(updatedEBS, file=paste(new.zip.folder,"ebs_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
} # WORKS 2015-08-27 RDB

# Update Strata file
oldEBS2 <- upData$ebs_strata.csv
if(file.exists(ebs.file2)){ # NOT FOUND, NO CHECK 2015-08-27 RDB
	
	# Load Data
	newEBS2 <- as.data.table(read.csv(ebs.file2)) # had to use read.csv to auto remove whitespace in col names
	
	# Get and check names
	ebs.names2 <- names(oldEBS2)
	stopifnot(all(ebs.names2%in%names(newEBS2)))
	
	# Update entire data set, sort, and drop redundant
	updatedEBS2 <- newEBS2[,ebs.file2,with=F]
	setkeyv(updatedEBS2, names(updatedEBS2))
	updatedEBS2 <- unique(updatedEBS2)
	
	# Save updated file
	write.csv(updatedEBS2, file=paste(new.zip.folder,"ebs_strata.csv",sep="/"), row.names=FALSE, quote=FALSE)
}


# ==============
# = Update GOA =
# ==============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# oldGOA <- upData$goa_data.csv
if(length(goa.fileS)>=1){
	# Load updated, partially old GOA
	recent.goa.old <- sort(goa.fileS, dec=T)[1]
	oldGOA <- read.csv.zip(recent.goa.old, SIMPLIFY=FALSE)
	for(i in 1:length(oldGOA)){
		if(i==1){
			t.oldGOA <- oldGOA[[1]]
			setnames(t.oldGOA, trim(names(t.oldGOA)))
			oldGOA.hold <- t.oldGOA
		}else{
			t.oldGOA <- oldGOA[[i]]
			setnames(t.oldGOA, trim(names(t.oldGOA)))
			oldGOA.hold <- t.oldGOA
			# oldGOA.hold <- rbind(oldGOA.hold, oldGOA[[i]], fill=TRUE)
			oldGOA.hold <- rbind(oldGOA.hold, t.oldGOA)
		}
	}
	updatedGOA <- copy(oldGOA.hold)
	rm(list=c("oldGOA", "oldGOA.hold"))
	
	# # Load Data
# 	newGOA <- as.data.table(read.csv(goa.file)) # had to use read.csv to auto remove whitespace in col names
#
# 	# Get names, make sure new data has all needed names
# 	goa.names <- names(oldGOA)
# 	stopifnot(all(goa.names%in%names(newGOA)))
#
# 	# Accumulate data (region's files are not cummulative)
# 	updatedGOA0 <- rbind(oldGOA, newGOA)
# 	updatedGOA <- as.data.table(updatedGOA0)
#
	# Sort data, drop redundant rows
	setkeyv(updatedGOA, names(updatedGOA))
	updatedGOA <- unique(updatedGOA)
	
	# Save data
	write.csv(updatedGOA, file=paste(new.zip.folder,"goa_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
} # WORKS with WARNING (column type fread()) 2015-08-27 RDB

# Update Strata file
oldGOA2 <- upData$goa_strata.csv
if(file.exists(goa.file2)){ # NOT FOUND, NO CHECK 2015-08-27 RDB
	newGOA2 <- as.data.table(read.csv(goa.file2)) # had to use read.csv to auto remove whitespace in col names
	goa.names2 <- names(oldGOA2)
	stopifnot(all(goa.names2%in%names(newGOA2)))
	updatedGOA2 <- newGOA2[,goa.file2,with=F]
	setkeyv(updatedGOA2, names(updatedGOA2))
	updatedGOA2 <- unique(updatedGOA2)
	write.csv(updatedGOA2, file=paste(new.zip.folder,"goa_strata.csv",sep="/"), row.names=FALSE, quote=FALSE)
}


# ===============
# = Update GMEX =
# ===============
# http://seamap.gsmfc.org/

# bio
oldGMEX.bio <- upData$gmex_bio.csv # only uses old data files for names
if(file.exists(gmex.bio.file)){ # consider having it look for the zip file too, then unzipping it
	newGMEX.bio0 <- as.data.table(read.csv(gmex.bio.file))
	stopifnot(all(names(oldGMEX.bio)%in%names(newGMEX.bio0)))
	gmex.bio.names <- names(oldGMEX.bio)
	newGMEX.bio <- newGMEX.bio0[,(gmex.bio.names), with=FALSE]
	write.csv(newGMEX.bio, file=paste(new.zip.folder,"gmex_bio.csv",sep="/"), row.names=FALSE, quote=FALSE)
} # WORKS 2015-08-27 RDB

# cruise
oldGMEX.cruise <- upData$gmex_cruise.csv
if(file.exists(gmex.cruise.file)){
	newGMEX.cruise0 <- as.data.table(read.csv(gmex.cruise.file))
	
	# Had problems with the names in this file; 
	# so I couldn't rely on the names used in the previous .csv
	# as a proper guide for naming convention required for OA
	# Thus, I am not doing the same approach for getting and checking
	# the column names, and am specifying them explicitly
	# But gmex still won't upload to OA
	# stopifnot(all(names(oldGMEX.cruise)%in%names(newGMEX.cruise0)))
	# gmex.cruise.names <- names(oldGMEX.cruise)
	
	gmex.cruise.names <- c("CRUISEID", "YR", "SOURCE", "VESSEL", "CRUISE_NO", "STARTCRU", "ENDCRU", "TITLE", "NOTE", "INGEST_SOURCE", "INGEST_PROGRAM_VER") # from .docx from Lucas
	stopifnot(all(gmex.cruise.names%in%names(newGMEX.cruise0)))
	newGMEX.cruise <- newGMEX.cruise0[,(gmex.cruise.names), with=FALSE]
	write.csv(newGMEX.cruise, file=paste(new.zip.folder,"gmex_cruise.csv",sep="/"), row.names=FALSE, quote=FALSE)
} # WORKS 2015-08-27 RDB

# spp
oldGMEX.spp <- upData$gmex_spp.csv
if(file.exists(gmex.spp.file)){
	newGMEX.spp0 <- as.data.table(read.csv(gmex.spp.file))
	stopifnot(all(names(oldGMEX.spp)%in%names(newGMEX.spp0)))
	gmex.spp.names <- names(oldGMEX.spp)
	newGMEX.spp <- newGMEX.spp0[,(gmex.spp.names), with=FALSE]
	write.csv(newGMEX.spp, file=paste(new.zip.folder,"gmex_spp.csv",sep="/"), row.names=FALSE, quote=FALSE)
} # WORKS 2015-08-27 RDB

# station
oldGMEX.station <- upData$gmex_station.csv
if(file.exists(gmex.station.file)){
	
	# I've had some problems loading this .csv into R,
	# so if you get this file updated, be sure to listen
	# to the following message ...
	msg1 <- "WAIT! You need to open"
	msg2 <- "in Excel, then resave it as a csv for the file to load properly."
	message("\n",msg1,gmex.station.file, msg2, "\n")

# Reading in and writing out the station file creates problems with quoted fields. Using quote=TRUE in the write.csv may work, but copying the file is even simpler (MLP 2015-09-08)
#	newGMEX.station0 <- as.data.table(read.csv(gmex.station.file))
#	stopifnot(all(names(oldGMEX.station)%in%names(newGMEX.station0)))
#	gmex.station.names <- names(oldGMEX.station)
#	newGMEX.station <- newGMEX.station0[,(gmex.station.names), with=FALSE]
#	write.csv(newGMEX.station, file=paste(new.zip.folder,"gmex_station.csv",sep="/"), row.names=FALSE, quote=FALSE)

	file.copy(from=gmex.station.file, to=paste(new.zip.folder,"gmex_station.csv",sep="/"))

}


# tow
oldGMEX.tow <- upData$gmex_tow.csv
if(file.exists(gmex.tow.file)){
	newGMEX.tow0 <- as.data.table(read.csv(gmex.tow.file))
	stopifnot(all(names(oldGMEX.tow)%in%names(newGMEX.tow0)))
	gmex.tow.names <- names(oldGMEX.tow)
	newGMEX.tow <- newGMEX.tow0[,(gmex.tow.names), with=FALSE]
	write.csv(newGMEX.tow, file=paste(new.zip.folder,"gmex_tow.csv",sep="/"), row.names=FALSE, quote=FALSE)
} # WORKS 2015-08-27 RDB


# ========
# = NEUS =
# ========
# NEUS Data
oldNEUS <- upData$neus_data.csv
if(file.exists(neus.file)){
	
	# The NEUS data updates come in the form of
	# .RData files; load the file in a 
	# local environment to ensure that it doesn't
	# override a local variable, because there are no guarantees
	# that the object name in this file will be consistent as
	# we continue to get updates in future
	# inside the local environment, take the 1 object in the data file
	# and save it outside the local environment as newNEUS, then 
	# remove whatever object came with the data.file
	local({
		load(neus.file)
		stopifnot(length(ls())==1)
		newNEUS <<- get(ls())
		rm(list=ls())
	})
	
	# OK, proceed with more standard approach to updating data
	neus.names <- names(oldNEUS)
	stopifnot(all(neus.names%in%names(newNEUS)))
	
	# Subset and rearrange to old column names/ order
	updatedNEUS <- newNEUS[,neus.names,with=F]
	
	# Turn into a data.table to enable easy/ quick
	# sorting and dropping of any potential duplicate rows
	updatedNEUS <- as.data.table(updatedNEUS)
	setkeyv(updatedNEUS, names(updatedNEUS))
	updatedNEUS <- unique(updatedNEUS)
	
	# Rename column headers to be wrapped in extra quotes, 
	# as per Lucas's .docx column names file indicates
	new.neus.names <- paste0("\"",names(updatedNEUS),"\"") # put names in extra quotes
	setnames(updatedNEUS, names(updatedNEUS), new.neus.names)
	
	# Need to add a leading column named ""
	updatedNEUS2 <- cbind(NA, updatedNEUS) # NA's for the values in that oclumn
	setnames(updatedNEUS2, "V1", "\"\"") # rename the NA column as ""
	
	# Save NEUS
	write.csv(updatedNEUS2, file=paste(new.zip.folder,"neus_neus.csv",sep="/"), row.names=FALSE, quote=FALSE) # neus breaks the naming convention
} # WORKS 2015-08-27 RDB

# Fix up NEUS's svspp.csv file
# This was not originally in right format, but 
# I did not receive any updates to this file, so 
# the default is to not run this section of code
# Also, the NEUS uplaod isn't working still
if(FALSE){
	neus.svspp.csv <- read.csv(paste(new.zip.folder,"neus_svspp.csv",sep="/"))
	
	# Need to add quotes around author field
	neus.svspp.csv[,"AUTHOR"] <- wrap.quotes(neus.svspp.csv[,"AUTHOR"])
	
	# Wrap column names in quotes
	names(neus.svspp.csv) <- paste0("\"",names(neus.svspp.csv),"\"")
	
	# Add "" column as first column
	neus.svspp.csv2 <- cbind(NA, neus.svspp.csv)
	names(neus.svspp.csv2)[1] <- "\"\""
	
	# Save csv
	write.csv(neus.svspp.csv2, file=paste(new.zip.folder,"neus_svspp.csv",sep="/"), row.names=FALSE, quote=FALSE)
} # NO TEST 2015-08-27 RDB


# ======
# = SA =
# ======
# gl hf Jim ;)


# ===============
# = Update WFSC =
# ===============
oldWC <- upData[grepl("wcann", names(upData))]

if(nrow(zipFiles_wc)>=1){
	
	# Data for WC Ann come in a zip file (in 2015, it contained 3 files)
	newWC <- read.csv.zip(wcann.zip.file, integer64="character") # custom function to read from zip
	namesWC <- c("wcann_fish.csv","wcann_haul.csv","wcann_invert.csv")

	# WC Ann Fish
	wcann_fish.names <- names(oldWC$wcann_fish.csv)
	new_wcann_fish <- newWC[[wc.match["wcann_fish.csv"]]][,wcann_fish.names,with=F]

	# WC Ann Haul
	wcann_haul.names <- names(oldWC$wcann_haul.csv)
	new_wcann_haul <- newWC[[wc.match["wcann_haul.csv"]]][,wcann_haul.names,with=F]

	# WC Ann Invert
	wcann_invert.names <- names(oldWC$wcann_invert.csv)
	new_wcann_invert <- newWC[[wc.match["wcann_invert.csv"]]][,wcann_invert.names,with=F]
	
	# Write files as .csv's
	write.csv(new_wcann_fish, file=paste(new.zip.folder,"wcann_fish.csv",sep="/"), row.names=FALSE, quote=FALSE)
	write.csv(new_wcann_invert, file=paste(new.zip.folder,"wcann_invert.csv",sep="/"), row.names=FALSE, quote=FALSE)
	write.csv(new_wcann_haul, file=paste(new.zip.folder,"wcann_haul.csv",sep="/"), row.names=FALSE, quote=FALSE)
}


# ========================
# = WC Tri Structure Fix =
# ========================
# This was added simply to add quotes in the region's files' 
# column names, ala Lucas's .docx file
# I orginally had trouble getting this region to upload to OA,
# But was able to get it to work on commit:
# f6b6660265ab634c411ce1932771d66ff61735c8
# This region is not receiving regular updates,
# So default is to skip this section
if(FALSE){
	wctri_catch.csv <- read.csv(file.path(new.zip.folder,"wctri_catch.csv"))
	names(wctri_catch.csv) <- paste0("\"",names(wctri_catch.csv),"\"")
	write.csv(wctri_catch.csv, file.path(new.zip.folder,"wctri_catch.csv"), row.names=FALSE, quote=FALSE)
	
	wctri_haul.csv <- read.csv(file.path(new.zip.folder,"wctri_haul.csv"))
	names(wctri_haul.csv) <- paste0("\"",names(wctri_haul.csv),"\"")
	write.csv(wctri_haul.csv, file.path(new.zip.folder,"wctri_haul.csv"), row.names=FALSE, quote=FALSE)
	
	
	wctri_species.csv <- read.csv(file.path(new.zip.folder,"wctri_species.csv"))
	names(wctri_species.csv) <- paste0("\"",names(wctri_species.csv),"\"")
	write.csv(wctri_species.csv, file.path(new.zip.folder,"wctri_species.csv"), row.names=FALSE, quote=FALSE)
}


# =======================
# = Zip File for GitHub =
# =======================
# Zip up and rename
oldwd <- getwd()
setwd(dirname(new.zip.folder)) # new.zip.folder is "./data_updates/Data_Updated"

zip(basename(new.zip.folder), files=list.files(basename(new.zip.folder),full=TRUE))
new.zip.file0 <- paste0(basename(new.zip.folder),".zip")
file.rename(new.zip.file0, renameNow(new.zip.file0))

setwd(oldwd)


# # ======================================
# # = Zip File for Amphiprion (Raw Data) =
# # ======================================
# # Copy, Zip, & Ship! Then delete.
#
# # Create directory to hold raw files locally
# raw.dir <- "./Raw_Files_Updated_on" # directory to hold raw files
# if(file.exists(raw.dir)){
# 	sapply(list.files(raw.dir, full=T), file.remove)
# }else{
# 	dir.create(raw.dir) # create directory
# }
#
# # Determine which files are available
# raw2copy0 <- unlist(sapply(ls()[grepl("\\.file$",ls())], get))
# raw2copy <- raw2copy0[file.exists(raw2copy0)]
#
# # Copy raw files into local holding folder
# file.copy(from=raw2copy, to=paste(raw.dir, basename(raw2copy),sep="/"))
#
# # Zip local holding folder, and rename with date
# # oldwd <- getwd()
# # setwd("./data_updates")
# zip(raw.dir, files=list.files(raw.dir, full=TRUE))
# # setwd(oldwd)
#
# # Rename the file that is to be push (add date)
# raw.dir.zip <- paste0(raw.dir,".zip")
# raw.dir.zip.now <- renameNow(raw.dir.zip)
# file.rename(raw.dir.zip, raw.dir.zip.now)
#
# # Push to Amphiprion
# localPath <- normalizePath(raw.dir.zip.now)
# remoteName <- "ryanb@amphiprion.deenr.rutgers.edu"
# remotePath <- "/local/shared/pinsky_lab/trawl_surveys/OA_rawData_Updates"
# push(path=localPath, remoteName=remoteName, path2=remotePath)
#
# # Cleanup by deleting holding folder and zipped holding folder
# file.remove(localPath) # delete local zip
# sapply(c(list.files(normalizePath(raw.dir), full=T),normalizePath(raw.dir)), file.remove) # delete local folder and its files


# ============================================
# = Reorganize Updated Data for Upload to OA =
# ============================================
# For each region, create a new directory
regions2upload <- c("ai","ebs","goa","gmex","neus","wcann","wctri")
files.matched <- c()
file.headers <- structure(vector("list",length(regions2upload)), .Names=regions2upload)

# get a list of all files in
# "/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/data_updates/Data_Updated/"
# these should be the .csv's from each region, as well as complete_r_script.R (?)
t.files0 <- list.files(normalizePath(new.zip.folder),full=T)

for(i in 1:length(regions2upload)){
	
	# Define region for this iteration
	t.reg <- regions2upload[i]
	
	# Create a directory where current region can
	# have its files safely renamed to somethign generic, like data.csv
	# So it creates things like:
	# "/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/data_updates/Data_Updated/ai"
	# "/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/data_updates/Data_Updated/ebs"
	# etc ...
	dir.create(paste0(normalizePath(new.zip.folder),"/",t.reg))
	
	# Identify files for this region, and remember which files found
	t.files <- t.files0[grepl(paste0(t.reg,"_"),t.files0)] # files w/ current region in name
	if(length(t.files)==0){warning(paste("skipping region",t.reg)); next} # skip w/ warning if region isn't found
	files.matched <- c(files.matched, t.files) # accumulate file names that were found
	
	# Define names for files as they will appear for upload;
	# I.e., t.files typically  has a name like goa_data.csv, 
	# whereas the corresponding t.dest.file would have
	# the name data.csv, and would be placed in the t.dest.dir,
	# which is 'goa'. This safeguards against overwriting
	t.dest.dir <- paste(dirname(t.files[1]), t.reg, sep="/")
	t.dest.file0 <- paste(t.dest.dir, basename(t.files),sep="/")
	t.dest.file <- gsub(paste0(t.reg,"_"), "", t.dest.file0) # strip region name for OA upload
	
	# Loop through the files that have been processed,
	# reading in the first line of each (the header),
	# and saving those header names into a list (to be saved
	# as a .txt metadata file later)
	file.headers[[i]] <- structure(vector("list", length(t.files)), .Names=basename(t.dest.file))
	for(j in 1:length(t.files)){
		file.headers[[i]][[j]] <- scan(t.files[j],nlines=1, sep=",", what="character", quote="", quiet=T)
	}
	
	# Copy a region's files to a folder named after that region,
	# and while copying, rename the file to the generic name 
	# required for OA upload
	# Note that I do not rename before the move in order to
	# safeguard against overwriting (several regions have a data.csv, e.g.)
	# Lastly, remove the old copy of the file
	file.copy(from=t.files, to=t.dest.file)
	file.remove(t.files)
	
	# Zip a region's files into a a file named after that region
	oldwd <- getwd()
	setwd(paste(new.zip.folder,basename(t.dest.dir),sep="/"))
	zip(file.path("..",t.reg), files=basename(t.dest.file))
	setwd(oldwd)
	
	# Delete local folder
	# sapply(c(list.files(t.dest.dir, full=T),t.dest.dir), file.remove)
	unlink(t.dest.dir, recursive=TRUE)
}

# To finish the process for preparing for the OA upload,
# mark the folder as containing the .zip files that are ready
# to be uplaoded
# r2u.dir <- paste(normalizePath(new.zip.folder),"ready2upload",sep="_")
# if(file.exists(r2u.dir)){
# 	sapply(list.files(r2u.dir, full=TRUE), file.remove)
# }
# file.rename(normalizePath(new.zip.folder), r2u.dir)


# =======================================================
# = Save the Column Headers for human-readable metadata =
# =======================================================
sink("./metadata/oa_upload_colNames.txt",type=c(type="output"))
for(i in 1:length(regions2upload)){
	cat(names(file.headers)[i], "\n")
	for(j in 1:length(file.headers[[i]])){
		cat("\t",names(file.headers[[i]])[j], "\n", paste0("\t\t",file.headers[[i]][[j]],"\n"),"\n")
	}
	if(i!=length(regions2upload)){
		cat("\n\n")
	}
}
sink(NULL)





