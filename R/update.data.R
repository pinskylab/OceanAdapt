
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
# AI
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
ai.file <- "~/Downloads/ai2014.csv"
ai.file2 <- "~/Downloads/ai_strata.csv"

# EBS
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
ebs.file <- "~/Downloads/ebs201_20143.csv"
ebs.file2 <- "~/Downloads/ebs_strata.csv"

# GOA
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
goa.file <- "~/Downloads/goa2007_2013.csv"
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
# zipFiles <- file.info(list.files("./data", full=TRUE, patt="^Data_Updated_[0-9]{4}.+"))
zipFiles <- file.info(list.files("./data", full=TRUE, patt="^Data_.+"))
recentZip <- row.names(zipFiles[order(zipFiles$mtime, zipFiles$ctime, zipFiles$atime, decreasing=TRUE)[1],])
upData <- read.csv.zip(recentZip, integer64="character")
old.csv.names <- names(upData)

# Unzip locally
# this kind of makes the whole process of read.csv.zip function pointless, as now I could simply read in the data files from this folder
# actually, nvm, it's still useful if the newly downloaded data are in a zip file
unzip(normalizePath(recentZip), exdir="data/Data_Updated", junkpaths=TRUE, setTimes=TRUE)
zip.folder <- gsub("(\\.[^.]+$)", "", recentZip)
new.zip.folder <- paste0(dirname(zip.folder),"/Data_Updated") #gsub("(?<=Data_Updated).+", "", zip.folder, perl=T)
# file.rename(zip.folder, new.zip.folder) # rename folder


# =============
# = Update AI =
# =============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
# this approach prevents adding duplicate rows either by using write.csv(..., append=TRUE), or by rbind() on something that's already been updated
oldAI <- upData$ai_data.csv
if(file.exists(ai.file)){
	newAI <- as.data.table(read.csv(ai.file)) # had to use read.csv to auto remove whitespace in col names
	ai.names <- names(oldAI)
	stopifnot(all(ai.names%in%names(newAI)))
	# updatedAI <- newAI[,ai.file,with=F]
	updatedAI0 <- rbind(oldAI, newAI)
	updatedAI <- as.data.table(updatedAI0)
	setkeyv(updatedAI, names(updatedAI))
	updatedAI <- unique(updatedAI)
	# write.csv(updatedAI, file="~/Documents/School&Work/pinskyPost/OceanAdapt/ai_data.csv", row.names=FALSE, quote=FALSE)
	write.csv(updatedAI, file=paste(new.zip.folder,"ai_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
}

# Update Strata file
oldAI2 <- upData$ai_strata.csv
if(file.exists(ai.file2)){
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
oldEBS <- upData$ebs_data.csv
if(file.exists(ebs.file)){
	newEBS <- as.data.table(read.csv(ebs.file)) # had to use read.csv to auto remove whitespace in col names
	ebs.names <- names(oldEBS)
	stopifnot(all(ebs.names%in%names(newEBS)))
	# updatedEBS <- newEBS[,ebs.file,with=F]
	updatedEBS0 <- rbind(oldEBS, newEBS)
	updatedEBS <- as.data.table(updatedEBS0)
	setkeyv(updatedEBS, names(updatedEBS))
	updatedEBS <- unique(updatedEBS)
	# write.csv(updatedEBS, file="~/Documents/School&Work/pinskyPost/OceanAdapt/ebs_data.csv", row.names=FALSE, quote=FALSE)
	write.csv(updatedEBS, file=paste(new.zip.folder,"ebs_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
}

# Update Strata file
oldEBS2 <- upData$ebs_strata.csv
if(file.exists(ebs.file2)){
	newEBS2 <- as.data.table(read.csv(ebs.file2)) # had to use read.csv to auto remove whitespace in col names
	ebs.names2 <- names(oldEBS2)
	stopifnot(all(ebs.names2%in%names(newEBS2)))
	updatedEBS2 <- newEBS2[,ebs.file2,with=F]
	setkeyv(updatedEBS2, names(updatedEBS2))
	updatedEBS2 <- unique(updatedEBS2)
	write.csv(updatedEBS2, file=paste(new.zip.folder,"ebs_strata.csv",sep="/"), row.names=FALSE, quote=FALSE)
}


# ==============
# = Update GOA =
# ==============
# As of 5-June-2015, GOA doesn't have any new data (new meaning 2014)
# skip for now
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
oldGOA <- upData$goa_data.csv
if(file.exists(goa.file)){
	newGOA <- as.data.table(read.csv(goa.file)) # had to use read.csv to auto remove whitespace in col names
	goa.names <- names(oldGOA)
	stopifnot(all(goa.names%in%names(newGOA)))
	# updatedGOA <- newGOA[,goa.file,with=F]
	updatedGOA0 <- rbind(oldGOA, newGOA)
	updatedGOA <- as.data.table(updatedGOA0)
	setkeyv(updatedGOA, names(updatedGOA))
	updatedGOA <- unique(updatedGOA)
	# write.csv(updatedGOA, file="~/Documents/School&Work/pinskyPost/OceanAdapt/goa_data.csv", row.names=FALSE, quote=FALSE)
	write.csv(updatedGOA, file=paste(new.zip.folder,"goa_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
}

# Update Strata file
oldGOA2 <- upData$goa_strata.csv
if(file.exists(goa.file2)){
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
oldGMEX.bio <- upData$gmex_bio.csv
if(file.exists(gmex.bio.file)){ # consider having it look for the zip file too, then unzipping it
	newGMEX.bio0 <- as.data.table(read.csv(gmex.bio.file))
	stopifnot(all(names(oldGMEX.bio)%in%names(newGMEX.bio0)))
	gmex.bio.names <- names(oldGMEX.bio)
	newGMEX.bio <- newGMEX.bio0[,(gmex.bio.names), with=FALSE]
	write.csv(newGMEX.bio, file=paste(new.zip.folder,"gmex_bio.csv",sep="/"), row.names=FALSE, quote=FALSE)
}

# cruise
oldGMEX.cruise <- upData$gmex_cruise.csv
if(file.exists(gmex.cruise.file)){
	newGMEX.cruise0 <- as.data.table(read.csv(gmex.cruise.file))
	stopifnot(all(names(oldGMEX.cruise)%in%names(newGMEX.cruise0)))
	gmex.cruise.names <- names(oldGMEX.cruise)
	newGMEX.cruise <- newGMEX.cruise0[,(gmex.cruise.names), with=FALSE]
	write.csv(newGMEX.cruise, file=paste(new.zip.folder,"gmex_cruise.csv",sep="/"), row.names=FALSE, quote=FALSE)
}

# spp
oldGMEX.spp <- upData$gmex_spp.csv
if(file.exists(gmex.spp.file)){
	newGMEX.spp0 <- as.data.table(read.csv(gmex.spp.file))
	stopifnot(all(names(oldGMEX.spp)%in%names(newGMEX.spp0)))
	gmex.spp.names <- names(oldGMEX.spp)
	newGMEX.spp <- newGMEX.spp0[,(gmex.spp.names), with=FALSE]
	write.csv(newGMEX.spp, file=paste(new.zip.folder,"gmex_spp.csv",sep="/"), row.names=FALSE, quote=FALSE)
}

# station
updateGMEX.station <- function(){
	oldGMEX.station <- upData$gmex_station.csv
	if(file.exists(gmex.station.file)){
		# if(!interactive()){
# 			warning(paste("Can't check",gmex.station.file, "outside interactive mode; resave it from Excel"))
# 		}
		msg1 <- "WAIT! You need to open"
		msg2 <- "in Excel, then resave it as a csv for the file to load properly."
# 		msg3 <- "Have you already completed this (weird) task? y/n"
# 		check.station.answer <- readline(paste(msg1,gmex.station.file,msg2,msg3))
		cat("\n",msg1,gmex.station.file, msg2, "\n")
		# if(check.station.answer!="y"){
# 			stop("Go resave the csv")
# 			break
# 		}else{
			newGMEX.station0 <- as.data.table(read.csv(gmex.station.file))
			stopifnot(all(names(oldGMEX.station)%in%names(newGMEX.station0)))
			gmex.station.names <- names(oldGMEX.station)
			newGMEX.station <- newGMEX.station0[,(gmex.station.names), with=FALSE]
			write.csv(newGMEX.station, file=paste(new.zip.folder,"gmex_station.csv",sep="/"), row.names=FALSE, quote=FALSE)
		# }	
	}
}
updateGMEX.station()


# tow
oldGMEX.tow <- upData$gmex_tow.csv
if(file.exists(gmex.tow.file)){
	newGMEX.tow0 <- as.data.table(read.csv(gmex.tow.file))
	stopifnot(all(names(oldGMEX.tow)%in%names(newGMEX.tow0)))
	gmex.tow.names <- names(oldGMEX.tow)
	newGMEX.tow <- newGMEX.tow0[,(gmex.tow.names), with=FALSE]
	write.csv(newGMEX.tow, file=paste(new.zip.folder,"gmex_tow.csv",sep="/"), row.names=FALSE, quote=FALSE)
}


# ========
# = NEUS =
# ========
# NEUS Data
oldNEUS <- upData$neus_data.csv
if(file.exists(neus.file)){
	# newNEUS <- as.data.table(read.csv(neus.file)) # had to use read.csv to auto remove whitespace in col names
	local({
		load(neus.file)
		stopifnot(length(ls())==1)
		newNEUS <<- get(ls())
		rm(list=ls())
	})
	neus.names <- names(oldNEUS)
	stopifnot(all(neus.names%in%names(newNEUS)))
	
	updatedNEUS <- newNEUS[,neus.names,with=F]
	
	updatedNEUS <- as.data.table(updatedNEUS)
	setkeyv(updatedNEUS, names(updatedNEUS))
	updatedNEUS <- unique(updatedNEUS)
	write.csv(updatedNEUS, file=paste(new.zip.folder,"neus_data.csv",sep="/"), row.names=FALSE, quote=FALSE)
}


# ======
# = SA =
# ======
# gl hf Jim ;)


# ===============
# = Update WFSC =
# ===============
oldWC <- upData[grepl("wcann", names(upData))]

if(nrow(zipFiles_wc)>=1){
	newWC <- read.csv.zip(wcann.zip.file, integer64="character")
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

	write.csv(new_wcann_fish, file=paste(new.zip.folder,"wcann_fish.csv",sep="/"), row.names=FALSE, quote=FALSE)
	write.csv(new_wcann_invert, file=paste(new.zip.folder,"wcann_invert.csv",sep="/"), row.names=FALSE, quote=FALSE)
	write.csv(new_wcann_haul, file=paste(new.zip.folder,"wcann_haul.csv",sep="/"), row.names=FALSE, quote=FALSE)
}


# =====================
# = Zip Up and Rename =
# =====================
zip(new.zip.folder, files=list.files(new.zip.folder, full=TRUE))
new.zip.file0 <- paste0(new.zip.folder,".zip")
file.rename(new.zip.file0, renameNow(new.zip.file0))


# =================================
# = Copy, Zip, and Ship Raw Files =
# =================================
# Create directory to hold raw files locally
raw.dir <- "./data/Raw_Files_Updated_on" # directory to hold raw files
dir.create(raw.dir) # create directory

# Determine which files are available
raw2copy0 <- unlist(sapply(ls()[grepl("\\.file$",ls())], get))
raw2copy <- raw2copy0[file.exists(raw2copy0)]

# Copy raw files into local holding folder
file.copy(from=raw2copy, to=paste(raw.dir, basename(raw2copy),sep="/"))

# Zip local holding folder, and rename with date
oldwd <- getwd()
setwd("./data")
zip(basename(raw.dir), files=list.files(basename(raw.dir), full=TRUE))
setwd(oldwd)

raw.dir.zip <- paste0(raw.dir,".zip")
raw.dir.zip.now <- renameNow(raw.dir.zip)
file.rename(raw.dir.zip, raw.dir.zip.now)

# Push to Amphiprion
localPath <- normalizePath(raw.dir.zip.now)
remoteName <- "ryanb@amphiprion.deenr.rutgers.edu"
remotePath <- "/local/shared/pinsky_lab/trawl_surveys/OA_rawData_Updates"
push(path=localPath, remoteName=remoteName, path2=remotePath)

# Cleanup by deleting holding folder and zipped holding folder
file.remove(localPath) # delete local zip
sapply(c(list.files(normalizePath(raw.dir), full=T),normalizePath(raw.dir)), file.remove) # delete local folder


# ============================================
# = Reorganize Updated Data for Upload to OA =
# ============================================
# For each region, create a new directory
regions2upload <- c("ai","ebs","goa","gmex","neus","wcann","wctri")
files.matched <- c()
t.files0 <- list.files(normalizePath(new.zip.folder),full=T)
for(i in 1:length(regions2upload)){
	t.reg <- regions2upload[i]
	dir.create(paste0(normalizePath(new.zip.folder),"/",t.reg))
	
	t.files <- t.files0[grepl(paste0(t.reg,"_"),t.files0)]
	files.matched <- c(files.matched, t.files)
	
	t.dest.dir <- paste(dirname(t.files[1]), t.reg, sep="/")
	# Update to strip region name from files when copying ... needed for OA 
	t.dest.file0 <- t.dest.file <- paste(t.dest.dir, basename(t.files),sep="/")
	t.dest.file <- gsub(paste0(t.reg,"_"), "", t.dest.file0)
	file.copy(from=t.files, to=t.dest.file)
	file.remove(t.files)
	
	oldwd <- getwd()
	# setwd(new.zip.folder)
	setwd(paste(new.zip.folder,basename(t.dest.dir),sep="/"))
	# zip(basename(t.dest.dir), files=list.files(basename(t.dest.dir), full=TRUE))
	# zip("ai", files=list.files(t.dest.file, full=TRUE))
	zip(file.path("..",t.reg), files=basename(t.dest.file))
	setwd(oldwd)
	
	
	sapply(c(list.files(t.dest.dir, full=T),t.dest.dir), file.remove) # delete local folder
	
}

# mark parent as ready for upload
file.rename(normalizePath(new.zip.folder), paste(normalizePath(new.zip.folder),"ready2upload",sep="_"))



