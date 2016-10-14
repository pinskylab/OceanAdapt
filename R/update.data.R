
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
ai_fold <- "ai"
ai.raw.path.top <- file.path(new_data_loc,ai_fold)
ai.fileS <- list.files(ai.raw.path.top, full.names=T, pattern=date.zip.patt)
ai.file2 <- "ai_strata.csv"
new_data_raw_ai <- sort(ai.fileS, dec=T)[1]


# EBS
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
ebs_fold <- "ebs"
ebs.raw.path.top <- file.path(new_data_loc,ebs_fold)
ebs.fileS <- list.files(ebs.raw.path.top, full.names=T, pattern=date.zip.patt)
ebs.file2 <- "ebs_strata.csv"
new_data_raw_ebs <- sort(ebs.fileS, dec=T)[1]

# GOA
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
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
gmex.station.file <- "STAREC.csv" #"STAREC.csv"
gmex.tow.file <- "INVREC.csv"

# NEUS
# Sean Lucey - NOAA Federal <sean.lucey@noaa.gov>
neus_fold <- "neus"
neus.raw.path.top <- file.path(new_data_loc,neus_fold)
neus.fileS <- list.files(neus.raw.path.top, full.names=T, pattern=date.zip.patt)
new_data_raw_neus <- sort(neus.fileS, dec=T)[1]

neus_surv_rdata <- "Survdat.RData"
neus_spp_rdata <- "SVSPP.RData"
neus_strata_rdata <- "Strata.RData"

neus_surv_csv <- "neus_neus.csv"
neus_spp_csv <- "neus_svspp.csv"
neus_strata_csv <- "neus_strata.csv"

# SEUS
seus_fold <- "seus"
seus.raw.path.top <- file.path(new_data_loc,seus_fold)
seus.fileS <- list.files(seus.raw.path.top, full.names=T, pattern=date.zip.patt)
new_data_raw_seus <- sort(seus.fileS, dec=T)[1]

seus.catch.file <- "seus_catch.csv"
seus.haul.file <- "seus_haul.csv"
seus.strata.file <- "seus_strata.csv"



# WC
# Email Beth Horness <Beth.Horness@noaa.gov>
wcann_fold <- "wcann"
wcann.raw.path.top <- file.path(new_data_loc,wcann_fold)
wcann.fileS <- list.files(wcann.raw.path.top, full.names=TRUE, pattern=date.zip.patt)
new_data_raw_wcann <- sort(wcann.fileS, dec=T)[1]

wcann.catch.pattern <- "wcann_catch\\.csv$"
wcann.haul.pattern <- "wcann_haul\\.csv$"


# wcann_fish_set_cn <- c("Trawl Id"="TowID","Species"="Sci","Haul Weight (kg)"="Wt","Individual Average Weight (kg)")
# old columns names as the names, current column names (that match) as the elements
# if NA, means that there doesn't seem to be an appropriate equivalent in the new data format
# column in the new data format that don't have a match in the old are not listed here
# wcann_haul_set_cn <- c("Survey","Survey Cycle","Vessel","Cruise Leg","Trawl Id","Trawl Performance","Trawl Date","Trawl Start Time","Best Latitude (dd)","Best Longitude (dd)","Best Position Type","Best Depth (m)","Best Depth Type","Trawl Duration (min)","Area Swept by the Net (hectares)","Temperature At the Gear (degs C)")
# wcann_invert_set_cn <- c("Trawl Id","Species","Haul Weight (kg)","Individual Average Weight (kg)")

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
read.csv.zip <- function(zipfile, pattern="\\.csv$", SIMPLIFY=TRUE, iterate=FALSE, rawHeader=FALSE, ...){
	
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
		csv.header <- structure(vector("list",length(files)), .Names=basename(files))
		for(i in 1:length(files)){
			# if(i ==14){next}
			t_file <- basename(files)[i]
			cat("\tReading",t_file,"\n")
			csv.data[[t_file]] <- tryCatch(read_func(files[i]), error=function(cond)NA)
			csv.header[[t_file]] <- tryCatch(readLines(file.path(zipdir, files[i]), n=1), error=function(cond)NA)
		}
	}else{
		if(SIMPLIFY){
			csv.data <- sapply(files, read_func)
			csv.header <- sapply(file.path(zipdir, files), readLines, n=1)
		}else{
			csv.data <- lapply(files,read_func)
			csv.header <- lapply(file.path(zipdir, files), readLines, n=1)
		}
	}
	
	# Use csv names to name list elements
	names(csv.data) <- basename(files)
	
	# Return data
	if(rawHeader){
		for(i in 1:length(csv.data)){
			attr(csv.data[[i]], which="rawHeader") <- csv.header[[i]]
		}
	}
	return(csv.data)
	
}


# ============================================
# = Read in Old Data Sets (currently zipped) =
# ============================================
zipFiles <- file.info(list.files("../data_updates", full=TRUE, patt="^Data_.+.zip")) # zipFiles only used in next few lines; intended to find old data sets, which is used both for main data (which we're now just redownloading every year), as well as for the strata files etc.
recentZip <- row.names(zipFiles[order(zipFiles$mtime, zipFiles$ctime, zipFiles$atime, decreasing=TRUE)[1],])
data.vis <- sort(list.files("../data_download",pattern="Data_Vis_.[0-9,_]*.zip", full=T),dec=T)[1] # grab most recent data.viz 
# downData <- read.csv.zip(data.vis, SIMPLIFY=T, iterate=TRUE)
upData <- read.csv.zip(recentZip, SIMPLIFY=T, iterate=TRUE, rawHeader=TRUE)

old_upData_colNames <- lapply(upData, names)
old_upData_rawHeader <- lapply(upData, function(x)attributes(x)$rawHeader)
old_upData_colClasses <- lapply(upData, function(x)sapply(x, class))


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
# unzip(normalizePath(recentZip), exdir=new.zip.folder, junkpaths=TRUE, setTimes=TRUE)


# ================================
# = Function for alaskan regions =
# ================================
update_ai_goa_ebs <- function(new_data_raw_reg, reg=c("ai","ebs","goa")){
	reg <- match.arg(reg)
	
	reg_name_dat <- paste0(reg,"_data.csv") # for saving data
	reg_name_strat <- paste0(reg,"_strata.csv") # for saving strat
	
	cat("Reading new files\n")
	newREG0 <- read.csv.zip(new_data_raw_reg, SIMPLIFY=FALSE)
	
	oldREG_data <- upData[[reg_name_dat]]
	newREG_data <- newREG0[names(newREG0)!=reg_name_strat] # non-strata files
	newREG_data <- rbindlist(newREG_data) # combine files into 1 data.table
	stopifnot(all(names(newREG_data)%in%names(oldREG_data))) # make sure new data have all columns in old data
	updated_newREG_data <- newREG_data[,names(oldREG_data),with=FALSE] # drop any columns not in old
	setkeyv(newREG_data, names(newREG_data)) # sort, and define which columns determine uniqueness of rows
	updated_newREG_data <- unique(newREG_data) # drops redundant rows
	cat("Saving new data files\n")
	write.csv(updated_newREG_data, file=paste(new.zip.folder,reg_name_dat,sep="/"), row.names=FALSE, quote=FALSE)

	# ---- update strata file ----
	oldREG_strata <- upData[[reg_name_strat]]
	newREG_strata <- newREG0[names(newREG0)==reg_name_strat][[1]]
	stopifnot(all(names(newREG_strata)%in%names(oldREG_strata)))
	updated_newREG_strata <- newREG_strata[,names(newREG_strata),with=F]
	setkeyv(updated_newREG_strata, names(updated_newREG_strata))
	updated_newREG_strata <- unique(updated_newREG_strata)
	cat("Saving new strata files\n")
	write.csv(updated_newREG_strata, file=paste(new.zip.folder,reg_name_strat,sep="/"), row.names=FALSE, quote=FALSE)
	
	invisible(NULL)
}


# =============
# = Update AI =
# =============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
update_ai_goa_ebs(new_data_raw_ai, "ai")


# ==============
# = Update EBS =
# ==============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
update_ai_goa_ebs(new_data_raw_ebs, "ebs")


# ==============
# = Update GOA =
# ==============
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/data.htm
update_ai_goa_ebs(new_data_raw_goa, "goa")


# ===============
# = Update GMEX =
# ===============
# http://seamap.gsmfc.org/
newGMEX <- read.csv.zip(new_data_raw_gmex)

update_gmex <- function(readFile, writeFile){
	# needs newGMEX, old_upData_colNames, new.zip.folder (getting from parent.frame())
	old_names <- old_upData_colNames[[writeFile]]
	new_data <- newGMEX[[readFile]][,old_names, with=FALSE]
	stopifnot(all(old_names%in%names(new_data)))
	cat("\tWriting",writeFile,"\n")
	write.csv(new_data, file=file.path(new.zip.folder,writeFile), row.names=FALSE, quote=TRUE)
	invisible(NULL)
}

update_gmex(readFile=gmex.bio.file, writeFile="gmex_bio.csv")# ---- bio ----
update_gmex(readFile=gmex.cruise.file, writeFile="gmex_cruise.csv")# ---- cruise ----
update_gmex(readFile=gmex.spp.file, writeFile="gmex_spp.csv")# ---- spp ----
update_gmex(readFile=gmex.tow.file, writeFile="gmex_tow.csv")# ---- tow ----

# ---- station ----
# can't read this file in normally
# because it has bad characters
# so need to go through each step and use lower-level functions
# to surgically remove the bad \" and replace with ""
gmex_zipdir <- tempfile()
dir.create(gmex_zipdir)
unzip(new_data_raw_gmex, exdir=gmex_zipdir)
gmex.station.file.path <- list.files(gmex_zipdir, rec=TRUE, full=TRUE, pattern=gsub("\\.", "\\\\.", gmex.station.file))
gmex.station.file.path <- normalizePath(gmex.station.file.path)
if(!interactive()){
	
	gmexStation_raw <- readLines(gmex.station.file.path)
	esc_patt <- "\\\\\\\""
	esc_replace <- "\\\"\\\""
	gmexStation_noEsc <- gsub(esc_patt, esc_replace, gmexStation_raw)
	gmex.station.file.new <- file.path(new.zip.folder,"gmex_station.csv")
	cat(gmexStation_noEsc, file=gmex.station.file.new, sep="\n")
}else{
	m1 <- paste0("\tThe following GMEX file needs to be fixed by replacing \\\" with \"\":\n\t\t",gmex.station.file.path,"\n\tEnter one of the following responses:\n")
	m1.o1 <- "\t\t 'system' to open the file with a text editor whose GUI can be initiated via command line\n"
	m1.o2 <- "\t\t 'done' if you have fixed the file and are ready for the script to proceed\n\t\t"
	r1 <- readline(cat(m1, m1.o1, m1.o2))
	m2 <- switch(r1,
		system = readline("You have selected to open the file via command line. Please enter the command to open in a text editor, e.g., 'open' (generic) or 'mate' (if textmate command line tools)\n"),
		done = cat("You should have now edited file, and Ocean Adapt update is proceeding\n")
	)
	switch(r1,
		system = {
			system2(m2, gmex.station.file.path)
			readline(paste0("You have selected ",m2,", please type 'done' when you have edited the file\n"))
		},
		done = ""
	)
	
	cat("Copying and renaming edited GMEX station file\n")
	file.copy(from=gmex.station.file.path, to=paste(new.zip.folder,"gmex_station.csv",sep="/"), overwrite=TRUE)
	# new_gmexStation <- as.data.table(read.csv(gmex.station.file.new))[,old_upData_colNames[["gmex_station.csv"]], with=FALSE]
	# write.csv(new_gmexStation, file=gmex.station.file.new, row.names=FALSE, quote=TRUE)
	
}


# ========
# = NEUS =
# ========
# NEUS Data
if(file.exists(new_data_raw_neus)){
	neus_zipdir <- tempfile()
	dir.create(neus_zipdir)
	unzip(new_data_raw_neus, exdir=neus_zipdir)
	
	# .csv files will just be copied, b/c new files come as .RData
	neus_csv_files <- list.files(neus_zipdir, rec=TRUE, pattern="\\.csv$", full=TRUE)
	neus_csv_files <- sapply(neus_csv_files, normalizePath, USE.NAMES=FALSE)
	
	# .RData files are considered to be potentially new, so will be processed
	neus_rdata_files <- list.files(neus_zipdir, rec=TRUE, pattern="\\.RData", full=TRUE)
	neus_rdata_files <- sapply(neus_rdata_files, normalizePath, USE.NAMES=FALSE)
	
	# Load RData files
	local({
		for(i in 1:length(neus_rdata_files)){
			load(neus_rdata_files[i])
		}
		rm(list='i')
		newNEUS <<- mget(ls())
		rm(list=ls())
	})
	
	# ---- process or copy survey file ----
	if(neus_surv_rdata%in%basename(neus_rdata_files)){
		newNEUS_data <- copy(newNEUS$survdat)
		# Need to add a leading column named ""
		newNEUS_data <- data.table(X=NA, newNEUS_data)
		
		stopifnot(all(old_upData_colNames$neus_neus.csv%in%names(newNEUS_data))) # upData$neus_neus.csv
		updated_newNEUS_data <- newNEUS_data[,old_upData_colNames$neus_neus.csv,with=FALSE]
		setnames(updated_newNEUS_data, "X", "\"\"") # rename the NA column as ""
		setnames(updated_newNEUS_data, names(updated_newNEUS_data)[-1], wrap.quotes(names(updated_newNEUS_data))[-1])
		cat("\tWriting",neus_surv_csv,"\n")
		write.csv(updated_newNEUS_data, file=file.path(new.zip.folder,neus_surv_csv), row.names=FALSE, quote=FALSE) 
	}else{
		stopifnot(neus_surv_csv%in%basename(neus_csv_files))
		
	}
	
	# ---- process or copy spp file ----
	if(neus_spp_rdata%in%basename(neus_rdata_files)){
		newNEUS_spp <- copy(newNEUS$spp)
		newNEUS_spp[,AUTHOR:=wrap.quotes(AUTHOR)]
		setnames(newNEUS_spp, names(newNEUS_spp), wrap.quotes(names(newNEUS_spp)))
		newNEUS_spp <- data.table(X=NA, newNEUS_spp)
		setnames(newNEUS_spp, "X", "\"\"")
		cat("\tWriting",neus_spp_csv,"\n")
		write.csv(newNEUS_spp, file=file.path(new.zip.folder,neus_spp_csv), row.names=FALSE, quote=FALSE)
	}else{
		svspp_ind <- neus_spp_csv==basename(neus_csv_files)
		stopifnot(any(svspp_ind))
		cat("\tCopying",neus_spp_csv,"\n")
		result <- file.copy(from=neus_csv_files[svspp_ind], to=file.path(new.zip.folder, neus_spp_csv), overwrite=TRUE)
		if(result){cat("\tSuccessfully copied",neus_spp_csv,"\n")}else{cat("\tFailed to copy",neus_spp_csv,"\n")}
	}
	
	# ---- process or copy strata file ----
	if(neus_strata_rdata%in%basename(neus_rdata_files)){
		# I don't have a .RData file for the strata
	}else{
		strata_ind <- neus_strata_csv==basename(neus_csv_files)
		stopifnot(any(strata_ind))
		cat("\tCopying",neus_strata_csv,"\n")
		result <- file.copy(from=neus_csv_files[strata_ind], to=file.path(new.zip.folder, neus_strata_csv), overwrite=TRUE)
		if(result){cat("\tSuccessfully copied",neus_strata_csv,"\n")}else{cat("\tFailed to copy",neus_strata_csv,"\n")}
	}
	
}


# ========
# = SEUS =
# ========
newSEUS <- read.csv.zip(new_data_raw_seus)
update_seus <- function(readFile, writeFile){
	# needs newSEUS, old_upData_colNames, new.zip.folder (getting from parent.frame())
	# old_names <- old_upData_colNames[[writeFile]]
	new_data <- newSEUS[[readFile]]#[,old_names, with=FALSE]
	# stopifnot(all(old_names%in%names(new_data)))
	cat("\tWriting",writeFile,"\n")
	write.csv(new_data, file=file.path(new.zip.folder,writeFile), row.names=FALSE, quote=FALSE)
	invisible(NULL)
}
update_seus(seus.catch.file, seus.catch.file)
update_seus(seus.haule.file, seus.haule.file)
update_seus(seus.strata.file, seus.strata.file)


# ===============
# = Update WFSC =
# ===============
if(file.exists(new_data_raw_wcann)){
	newWCANN <- read.csv.zip(new_data_raw_wcann) # custom function to read from zip
	names(newWCANN)[grepl(wcann.catch.pattern, names(newWCANN))] <- "wcann_catch.csv"
	names(newWCANN)[grepl(wcann.haul.pattern, names(newWCANN))] <- "wcann_haul.csv"
	
	newWCANN_catch <- newWCANN[["wcann_catch.csv"]]
	newWCANN_catch <- newWCANN_catch[,c("trawl_id","year","longitude_dd","latitude_dd","depth_m","scientific_name","total_catch_wt_kg","cpue_kg_per_ha_der"),with=FALSE]

	newWCANN_haul <- newWCANN[["wcann_haul.csv"]]
	newWCANN_haul <- newWCANN_haul[,c("trawl_id","year","longitude_hi_prec_dd","latitude_hi_prec_dd","depth_hi_prec_m","area_swept_ha_der"), with=FALSE]
	
	# d <- merge(newWCANN_catch, newWCANN_haul, by=c("trawl_id","year"), all.x=TRUE, all.y=FALSE, allow.cartesian=TRUE) # this merge needs to be successful for complete_r_script to have a chance at working
	
	# Write files as .csv's
	write.csv(newWCANN_catch, file=paste(new.zip.folder,"wcann_catch.csv",sep="/"), row.names=FALSE, quote=FALSE)
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


# =================
# = Copy Taxonomy =
# =================
file.copy(from="../data_raw/taxonomy/spptaxonomy.csv", to="../data_updates/Data_Updated", overwrite=TRUE)



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


# ============================================
# = Reorganize Updated Data for Upload to OA =
# ============================================
# For each region, create a new directory
regions2upload <- c("ai","ebs","goa","gmex","neus", "seus", "wcann","wctri")
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





