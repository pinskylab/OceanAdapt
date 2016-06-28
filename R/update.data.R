
# =================
# = Load Packages =
# =================
library(data.table)
library(rbLib) # library(devtools); install_github("rBatt/rbLib")
library(bit64)


# ===============================
# = Guess appropriate directory =
# ===============================
if(Sys.info()["sysname"]=="Linux"){
	setwd("~/Documents/School&Work/pinskyPost/OceanAdapt/R")
}else{
	setwd("~/Documents/School&Work/pinskyPost/OceanAdapt/R")
}

new_data_loc <- "../data_raw"



# =======================================
# = Names & Locations of New Data Files =
# =======================================
date.zip.patt <- "[0-9]{4}-[0-9]{2}-[0-9]{2}.zip"

# AI
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# ai.file <- "~/Downloads/ai2014.csv" # TODO pointless
ai_fold <- "ai"
ai.raw.path.top <- file.path(new_data_loc,ai_fold)
ai.fileS <- list.files(ai.raw.path.top, full.names=T, pattern=date.zip.patt)
ai.file2 <- "ai_strata.csv"
new_data_raw_ai <- sort(ai.fileS, dec=T)[1]


# EBS
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# ebs.file <- "~/Downloads/ebs201_20143.csv"
ebs_fold <- "ebs"
ebs.raw.path.top <- file.path(new_data_loc,ebs_fold)
ebs.fileS <- list.files(ebs.raw.path.top, full.names=T, pattern=date.zip.patt)
ebs.file2 <- "ebs_strata.csv"
new_data_raw_ebs <- sort(ebs.fileS, dec=T)[1]

# GOA
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# goa.file <- "~/Downloads/goa2007_2013.csv"
goa_fold <- "goa"
goa.raw.path.top <- file.path(new_data_loc,goa_fold)
goa.fileS <- list.files(goa.raw.path.top, full.names=T, pattern=date.zip.patt)
goa.file2 <- "goa_strata.csv"
new_data_raw_goa <- sort(goa.fileS, dec=T)[1]

# GMEX
# http://seamap.gsmfc.org/
gmex_fold <- "gmex"
gmex.raw.path.top <- file.path(new_data_loc,gmex_fold)
gmex.fileS <- list.files(gmex.raw.path.top, full.names=T, pattern=date.zip.patt)
new_data_raw_gmex <- sort(gmex.fileS, dec=T)[1]

gmex.bio.file <- "BGSREC.csv"
gmex.cruise.file <- "CRUISES.csv"
gmex.spp.file <- "NEWBIOCODESBIG.csv"
gmex.station.file <- "STAREC_noescapes.csv" #"STAREC.csv"
gmex.tow.file <- "INVREC.csv"

# NEUS
# Sean Lucey - NOAA Federal <sean.lucey@noaa.gov>
neus_fold <- "neus"
neus.raw.path.top <- file.path(new_data_loc,neus_fold)
neus.fileS <- list.files(neus.raw.path.top, full.names=T, pattern=date.zip.patt)
new_data_raw_neus <- sort(neus.fileS, dec=T)[1]
# neus.file <- "Survdat.RData"


# WC
# Email Beth Horness <Beth.Horness@noaa.gov>
wcann_fold <- "wcann"
wcann.raw.path.top <- file.path(new_data_loc,wcann_fold)
wcann.fileS <- list.files(wcann.raw.path.top, full.names=TRUE, pattern=date.zip.patt)
new_data_raw_wcann <- sort(wcann.fileS, dec=T)[1]
# zipFiles_wc <- file.info(list.files(wcann.raw.path.top, full=TRUE, patt="^Comprehensive.+.zip"))
wcann.fish.pattern <- "FishCatch\\.csv$"
wcann.haul.pattern <- "Hauls\\.csv$"
wcann.invert.pattern <- "InvertebrateCatch\\.csv$"


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
read.csv.zip <- function(zipfile, pattern="\\.csv$", SIMPLIFY=TRUE, iterate=FALSE, ...){
	
	zipdir <- tempfile()# Create a name for the dir where we'll unzip
	dir.create(zipdir)# Create the dir using that name
	unzip(zipfile, exdir=zipdir)# Unzip the file into the dir
	files <- list.files(zipdir, rec=TRUE, pattern=pattern)# Get a list of csv files in the dir
	
	read_func <- function(f){
		fp <- file.path(zipdir, f)
		dat <- as.data.table(read.csv(fp, ...))
		return(dat)
	}
	
	# Create a list of the imported csv files
	if(iterate){
		csv.data <- structure(vector("list",length(files)), .Names=basename(files))
		for(i in 1:length(files)){
			if(i ==14){next}
			t_file <- basename(files)[i]
			cat("\tReading",t_file,"\n")
			csv.data[[t_file]] <- read_func(files[i])
		}
	}else{
		if(SIMPLIFY){
			csv.data <- sapply(files, read_func)
		}else{
			csv.data <- lapply(files,read_func)
		}
	}
	
	# Use csv names to name list elements
	names(csv.data) <- basename(files)
	
	# Return data
	return(csv.data)
}


# ============================================
# = Read in Old Data Sets (currently zipped) =
# ============================================
zipFiles <- file.info(list.files("../data_updates", full=TRUE, patt="^Data_.+.zip")) # zipFiles only used in next few lines; intended to find old data sets, which is used both for main data (which we're now just redownloading every year), as well as for the strata files etc.
recentZip <- row.names(zipFiles[order(zipFiles$mtime, zipFiles$ctime, zipFiles$atime, decreasing=TRUE)[1],])
# upData <- read.csv.zip(recentZip, integer64="character")
data.vis <- sort(list.files("../data_download",pattern="Data_Vis_.[0-9,_]*.zip", full=T),dec=T)[1] # grab most recent data.viz 
# upData <- read.csv.zip(data.vis, SIMPLIFY=T) # TODO This should probably go back to using recentZip
downData <- read.csv.zip(data.vis, SIMPLIFY=T, iterate=TRUE)
upData <- read.csv.zip(recentZip, SIMPLIFY=T, iterate=TRUE)
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


update_ai_goa_ebs <- function(new_data_raw_reg, reg=c("ai","ebs","goa")){
	reg <- match.arg(reg)
	
	reg_name_dat <- paste0(reg,"_data.csv") # for saving data
	reg_name_strat <- paste0(reg,"_strata.csv") # for saving strat
	
	cat("\nReading new files\n")
	newREG0 <- read.csv.zip(new_data_raw_reg, SIMPLIFY=FALSE)
	
	
	oldREG_data <- upData[[reg_name_dat]]
	newREG_data <- newREG0[names(newREG0)!=reg_name_strat] # non-strata files
	newREG_data <- rbindlist(newREG_data) # combine files into 1 data.table
	stopifnot(all(names(newREG_data)%in%names(oldREG_data))) # make sure new data have all columns in old data
	updated_newREG_data <- newREG_data[,names(oldREG_data),with=FALSE] # drop any columns not in old
	setkeyv(newREG_data, names(newREG_data)) # sort, and define which columns determine uniqueness of rows
	updated_newREG_data <- unique(newREG_data) # drops redundant rows
	cat("\nSaving new data files\n")
	write.csv(updated_newREG_data, file=paste(new.zip.folder,reg_name_dat,sep="/"), row.names=FALSE, quote=FALSE)

	# ---- update strata file ----
	oldREG_strata <- upData[[reg_name_strat]]
	newREG_strata <- newREG0[names(newREG0)==reg_name_strat][[1]]
	stopifnot(all(names(newREG_strata)%in%names(oldREG_strata)))
	updated_newREG_strata <- newREG_strata[,names(newREG_strata),with=F]
	setkeyv(updated_newREG_strata, names(updated_newREG_strata))
	updated_newREG_strata <- unique(updated_newREG_strata)
	cat("\nSaving new strata files\n")
	write.csv(updated_newREG_strata, file=paste(new.zip.folder,reg_name_strat,sep="/"), row.names=FALSE, quote=FALSE)
	
	invisible(NULL)
}
update_ai_goa_ebs(new_data_raw_ai, "ai")

# =============
# = Update AI =
# =============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# ---- update general data file ----
# oldAI_data <- upData$ai_data.csv
# if(length(ai.fileS)>=1){ # if not 0 will be true
# 	newAI0 <- read.csv.zip(new_data_raw_ai, SIMPLIFY=FALSE)
# 	newAI_data <- newAI0[names(newAI0)!="aiStrata.csv"] # non-strata files
# 	newAI_data <- rbindlist(newAI_data) # combine files into 1 data.table
# 	stopifnot(all(names(newAI_data)%in%names(oldAI_data))) # make sure new data have all columns in old data
# 	updated_newAI_data <- newAI_data[,names(oldAI_data),with=FALSE] # drop any columns not in old
# 	setkeyv(newAI_data, names(newAI_data)) # sort, and define which columns determine uniqueness of rows
# 	updated_newAI_data <- unique(newAI_data) # drops redundant rows
# 	write.csv(updated_newAI_data, file=paste(new.zip.folder,"ai_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
# }
#
# # ---- update strata file ----
# oldAI_strata <- upData$ai_strata.csv
# if(file.exists(ai.file2)){
# 	newAI_strata <- newAI0[names(newAI0)=="aiStrata.csv"][[1]]
# 	stopifnot(all(names(newAI_strata)%in%names(oldAI_strata)))
# 	updated_newAI_strata <- newAI_strata[,(newAI_strata_names),with=F]
# 	setkeyv(updated_newAI_strata, names(updated_newAI_strata))
# 	updated_newAI_strata <- unique(updated_newAI_strata)
# 	write.csv(updated_newAI_strata, file=paste(new.zip.folder,"ai_strata.csv",sep="/"), row.names=FALSE, quote=FALSE)
# }
update_ai_goa_ebs(new_data_raw_ai, "ai")


# ==============
# = Update EBS =
# ==============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# ---- update general data file ----
# oldEBS_data <- upData$ebs_data.csv
# if(length(ebs.fileS)>=1){
# 	newEBS0 <- read.csv.zip(new_data_raw_ebs, SIMPLIFY=FALSE)
# 	newEBS_data <- newEBS0[names(newEBS0)!="ebsStrata.csv"] # non-strata files
# 	newEBS_data <- rbindlist(newEBS_data) # combine files into 1 data.table
# 	stopifnot(all(names(newEBS_data)%in%names(oldEBS_data))) # make sure new data have all columns in old data
# 	updated_newEBS_data <- newEBS_data[,names(oldEBS_data),with=FALSE] # drop any columns not in old
# 	setkeyv(newEBS_data, names(newEBS_data)) # sort, and define which columns determine uniqueness of rows
# 	updated_newEBS_data <- unique(newEBS_data) # drops redundant rows
# 	write.csv(updated_newEBS_data, file=paste(new.zip.folder,"ebs_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
# }
#
# # ---- update strata file ----
# oldEBS_strata <- upData$ebs_strata.csv
# if(file.exists(ebs.file2)){
# 	newEBS_strata <- newEBS0[names(newEBS0)=="ebsStrata.csv"][[1]]
# 	stopifnot(all(names(newEBS_strata)%in%names(oldEBS_strata)))
# 	updated_newEBS_strata <- newEBS_strata[,names(newEBS_strata),with=F]
# 	setkeyv(updated_newEBS_strata, names(updated_newEBS_strata))
# 	updated_newEBS_strata <- unique(updated_newEBS_strata)
# 	write.csv(updated_newEBS_strata, file=paste(new.zip.folder,"ebs_strata.csv",sep="/"), row.names=FALSE, quote=FALSE)
# }
update_ai_goa_ebs(new_data_raw_ebs, "ebs")


# ==============
# = Update GOA =
# ==============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm


# ---- update general data file ----
# oldGOA_data <- upData$goa_data.csv
# if(length(goa.fileS)>=1){
# 	newGOA0 <- read.csv.zip(new_data_raw_goa, SIMPLIFY=FALSE)
# 	newGOA_data <- newGOA0[names(newGOA0)!="goaStrata.csv"] # non-strata files
# 	newGOA_data <- rbindlist(newGOA_data) # combine files into 1 data.table
# 	stopifnot(all(names(newGOA_data)%in%names(oldGOA_data))) # make sure new data have all columns in old data
# 	updated_newGOA_data <- newGOA_data[,names(oldGOA_data),with=FALSE] # drop any columns not in old
# 	setkeyv(newGOA_data, names(newGOA_data)) # sort, and define which columns determine uniqueness of rows
# 	updated_newGOA_data <- unique(newGOA_data) # drops redundant rows
# 	write.csv(updated_newGOA_data, file=paste(new.zip.folder,"goa_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
# }
#
# # ---- update strata file ----
# oldGOA_strata <- upData$goa_strata.csv
# newGOA_strata <- newGOA0[names(newGOA0)=="goaStrata.csv"][[1]]
# stopifnot(all(names(newGOA_strata)%in%names(oldGOA_strata)))
# updated_newGOA_strata <- newGOA_strata[,names(newGOA_strata),with=F]
# setkeyv(updated_newGOA_strata, names(updated_newGOA_strata))
# updated_newGOA_strata <- unique(updated_newGOA_strata)
# write.csv(updated_newGOA_strata, file=paste(new.zip.folder,"goa_strata.csv",sep="/"), row.names=FALSE, quote=FALSE)
update_ai_goa_ebs(new_data_raw_goa, "goa")


# ===============
# = Update GMEX =
# ===============
# http://seamap.gsmfc.org/
newGMEX <- read.csv.zip(new_data_raw_gmex)

# ---- bio ----
oldGMEX.bio <- upData$gmex_bio.csv # only uses old data files for names
newGMEX.bio0 <- newGMEX[[gmex.bio.file]]
stopifnot(all(names(oldGMEX.bio)%in%names(newGMEX.bio0)))
gmex.bio.names <- names(oldGMEX.bio)
newGMEX.bio <- newGMEX.bio0[,(gmex.bio.names), with=FALSE]
write.csv(newGMEX.bio, file=paste(new.zip.folder,"gmex_bio.csv",sep="/"), row.names=FALSE, quote=FALSE)

# ---- cruise ----
oldGMEX.cruise <- upData$gmex_cruise.csv
newGMEX.cruise0 <- newGMEX[[gmex.cruise.file]]
# Had problems with the names in this file; 
# so I couldn't rely on the names used in the previous .csv
# as a proper guide for naming convention required for OA
# Thus, I am not doing the same approach for getting and checking
# the column names, and am specifying them explicitly
# But gmex still won't upload to OA
gmex.cruise.names <- c("CRUISEID", "YR", "SOURCE", "VESSEL", "CRUISE_NO", "STARTCRU", "ENDCRU", "TITLE", "NOTE", "INGEST_SOURCE", "INGEST_PROGRAM_VER") # from .docx from Lucas
stopifnot(all(gmex.cruise.names%in%names(newGMEX.cruise0)))
newGMEX.cruise <- newGMEX.cruise0[,(gmex.cruise.names), with=FALSE]
write.csv(newGMEX.cruise, file=paste(new.zip.folder,"gmex_cruise.csv",sep="/"), row.names=FALSE, quote=FALSE)

# ---- spp ----
oldGMEX.spp <- upData$gmex_spp.csv
newGMEX.spp0 <- newGMEX[[gmex.spp.file]]
stopifnot(all(names(oldGMEX.spp)%in%names(newGMEX.spp0)))
gmex.spp.names <- names(oldGMEX.spp)
newGMEX.spp <- newGMEX.spp0[,(gmex.spp.names), with=FALSE]
write.csv(newGMEX.spp, file=paste(new.zip.folder,"gmex_spp.csv",sep="/"), row.names=FALSE, quote=FALSE)

# ---- station ----
oldGMEX.station <- upData$gmex_station.csv
# I've had some problems loading this .csv into R,
# so if you get this file updated, be sure to listen
# to the following message ...
msg1 <- "WAIT! You need to open"
msg2 <- 'in a text editor (e.g., TextWrangler), then search&replace \\" with "", then resave it for the file to load properly.'
message("\n",msg1,gmex.station.file, msg2, "\n")
# Reading in and writing out the station file creates problems with quoted fields. Using quote=TRUE in the write.csv may work, but copying the file is even simpler (MLP 2015-09-08)
#	newGMEX.station0 <- as.data.table(read.csv(gmex.station.file))
#	stopifnot(all(names(oldGMEX.station)%in%names(newGMEX.station0)))
#	gmex.station.names <- names(oldGMEX.station)
#	newGMEX.station <- newGMEX.station0[,(gmex.station.names), with=FALSE]
#	write.csv(newGMEX.station, file=paste(new.zip.folder,"gmex_station.csv",sep="/"), row.names=FALSE, quote=FALSE)

gmex_zipdir <- tempfile()
dir.create(gmex_zipdir)
unzip(new_data_raw_gmex, exdir=gmex_zipdir)
gmex.station.file.path <- list.files(gmex_zipdir, rec=TRUE, full=TRUE, pattern=gsub("\\.", "\\\\.", gmex.station.file))
file.copy(from=gmex.station.file.path, to=paste(new.zip.folder,"gmex_station.csv",sep="/"), overwrite=TRUE)

# file.copy(from=gmex.station.file, to=paste(new.zip.folder,"gmex_station.csv",sep="/"))


# ---- tow ----
oldGMEX.tow <- upData$gmex_tow.csv
newGMEX.tow0 <- newGMEX[[gmex.tow.file]]
stopifnot(all(names(oldGMEX.tow)%in%names(newGMEX.tow0)))
gmex.tow.names <- names(oldGMEX.tow)
newGMEX.tow <- newGMEX.tow0[,(gmex.tow.names), with=FALSE]
write.csv(newGMEX.tow, file=paste(new.zip.folder,"gmex_tow.csv",sep="/"), row.names=FALSE, quote=FALSE)


# ========
# = NEUS =
# ========
# NEUS Data
oldNEUS <- upData$neus_data.csv
if(file.exists(new_data_raw_neus)){
	neus_zipdir <- tempfile()
	dir.create(neus_zipdir)
	unzip(new_data_raw_neus, exdir=neus_zipdir)
	neus_files <- list.files(neus_zipdir, rec=TRUE, pattern="\\.RData", full=TRUE)
	
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
		for(i in 1:length(neus_files)){
			load(neus_files[i])
		}
		# stopifnot(length(ls())==1)
		rm(list='i')
		newNEUS <<- mget(ls())
		rm(list=ls())
	})
	newNEUS_data <- newNEUS$survdat
	newNEUS_spp <- newNEUS$spp
	
	# OK, proceed with more standard approach to updating data
	neus.names <- names(oldNEUS)
	stopifnot(all(neus.names%in%names(newNEUS_data)))
	
	# Subset and rearrange to old column names/ order
	updated_newNEUS_data <- newNEUS_data[,neus.names,with=F]
	
	# Turn into a data.table to enable easy/ quick
	# sorting and dropping of any potential duplicate rows
	updated_newNEUS_data <- as.data.table(updated_newNEUS_data)
	setkeyv(updated_newNEUS_data, names(updated_newNEUS_data))
	updated_newNEUS_data <- unique(updated_newNEUS_data)
	
	# Rename column headers to be wrapped in extra quotes, 
	# as per Lucas's .docx column names file indicates
	new.neus.names <- paste0("\"",names(updated_newNEUS_data),"\"") # put names in extra quotes
	setnames(updated_newNEUS_data, names(updated_newNEUS_data), new.neus.names)
	
	# Need to add a leading column named ""
	updated_newNEUS_data <- cbind(NA, updated_newNEUS_data) # NA's for the values in that oclumn
	setnames(updated_newNEUS_data, "V1", "\"\"") # rename the NA column as ""
	
	# Save NEUS
	write.csv(updated_newNEUS_data, file=paste(new.zip.folder,"neus_neus.csv",sep="/"), row.names=FALSE, quote=FALSE) # neus breaks the naming convention
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
}


# ======
# = SA =
# ======
# gl hf Jim ;)


# ===============
# = Update WFSC =
# ===============
oldWCANN <- upData[grepl("wcann", names(upData))]
if(file.exists(new_data_raw_wcann)){
	newWCANN <- read.csv.zip(new_data_raw_wcann) # custom function to read from zip
	namesWC <- c("wcann_fish.csv","wcann_haul.csv","wcann_invert.csv")
	names(newWCANN)[grepl(wcann.fish.pattern, names(newWCANN))] <- "wcann_fish.csv"
	names(newWCANN)[grepl(wcann.invert.pattern, names(newWCANN))] <- "wcann_invert.csv"
	names(newWCANN)[grepl(wcann.haul.pattern, names(newWCANN))] <- "wcann_haul.csv"

	# WC Ann Fish
	oldWCANN_fish_names <- names(oldWCANN$wcann_fish.csv)
	stopifnot(all(oldWCANN_fish_names%in%names(newWCANN$wcann_fish.csv)))
	newWCANN_fish <- newWCANN[["wcann_fish.csv"]][,oldWCANN_fish_names,with=F]

	# WC Ann Haul
	oldWCANN_haul_names <- names(oldWCANN$wcann_haul.csv)
	stopifnot(all(oldWCANN_haul_names%in%names(newWCANN$wcann_haul.csv)))
	newWCANN_haul <- newWCANN[["wcann_haul.csv"]][,oldWCANN_haul_names,with=F]

	# WC Ann Invert
	oldWCANN_invert_names <- names(oldWCANN$wcann_invert.csv)
	stopifnot(all(oldWCANN_invert_names%in%names(newWCANN$wcann_invert.csv)))
	newWCANN_invert <- newWCANN[["wcann_invert.csv"]][,oldWCANN_invert_names,with=F]
	
	# Write files as .csv's
	write.csv(newWCANN_fish, file=paste(new.zip.folder,"wcann_fish.csv",sep="/"), row.names=FALSE, quote=FALSE)
	write.csv(newWCANN_invert, file=paste(new.zip.folder,"wcann_invert.csv",sep="/"), row.names=FALSE, quote=FALSE)
	write.csv(newWCANN_haul, file=paste(new.zip.folder,"wcann_haul.csv",sep="/"), row.names=FALSE, quote=FALSE)
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





