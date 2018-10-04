# The complete_r_script, updated to do all munging in one file, replaceing the data_update.R, updateOA.R, and get_wcann.R scripts.

# Workspace setup ====
# This script works best when the repository is downloaded from github, 
# especially when that repository is loaded as a project into RStudio.
# The working directory is assumed to be the OceanAdapt directory of this repository.

library(tidyverse)
library(jsonlite)
library(data.table)

# Functions ====
download_ak <- function(region, ak_files){
  # define the destination folder
  new_dir <- file.path(paste0("data_raw/", region, "/", Sys.Date()))
  # create the destination folder
  dir.create(new_dir)
  for (i in seq(ak_files$survey)){
    # define the destination file path
    file <- paste(new_dir, ak_files$survey[i], sep = "/")
    # define the source url
    url <- paste("https://www.afsc.noaa.gov/RACE/groundfish/survey_data/downloads", ak_files$survey[i], sep = "/")
    # download the file from the url to the destination file path
    download.file(url,file)
    # unzip the new file
    unzip(file, exdir = new_dir)
    # delete the downloaded zip file
    file.remove(file)
  }
  #Unzip the most recent zip and copy over the strata file.
  
  # list all of the zip files for this region
  zipFiles <- file.info(list.files(paste0("data_raw/", region), full=TRUE, patt=".zip"))
  
  # define the most recent zip file
  recentZip <- row.names(zipFiles[order(zipFiles$mtime, zipFiles$ctime, zipFiles$atime, decreasing=TRUE)[1], ])
  
  # define a temporary space to unzip the file
  zipdir <- tempfile()# Create a name for the dir where we'll unzip
  
  # create the temporary space
  dir.create(zipdir)# Create the dir using that name
  
  # unzip the file into that temp space
  unzip(recentZip, exdir=zipdir)# Unzip the file into the dir
  
  # list any files that contain strata in the name
  strat<- list.files(zipdir, recursive = T, pattern = "strata", full = T)
  
  # copy over the strat file
  file.copy(from=strat, to=new_dir)
}

# Define Regions of Interest ====
raw_regions <- tibble(region = c(
    "ai", #(Aleutian Islands) 
  "ebs", #(Eastern Bering Sea)
  "gmex", #(Gulf of Mexico)
"goa", #(Gulf of Alaska)
  "neus", #(Northeast US)
  "seus", #(Southeast US)
  "taxonomy", #(not a region/ survey, but this folder should exist)
  "wcann", #(West Coast Annual)
  "wctri" #(West Coast Triennial)
  # add canada region here
))

# Download AI ====
# 1. Visit website and confirm that the following list of files is complete. (cmd-click)
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
ai_files <- tibble(survey = c(
  "ai1983_2000.zip", 
  "ai2002_2012.zip",
  "ai2014_2016.zip"
))

# 2. Download the raw data from the website and copy over the strata file
download_ak("ai", ai_files)

# Download EBS ====
# 1. Visit website and confirm that the following list of files is complete. (cmd-click)
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
ebs_files <- tibble(survey = c(
  "ebs1982_1984.zip", 
  "ebs1985_1989.zip", 
  "ebs1990_1994.zip",
  "ebs1995_1999.zip",
  "ebs2000_2004.zip",
  "ebs2005_2008.zip",
  "ebs2009_2012.zip",
  "ebs2013_2016.zip",
  "ebs2017.zip" )
)

# 2. Download the raw data from the website and copy over the strata file
download_ak("ebs", ebs_files)

# Download GOA ====
# 1. Visit website and confirm that the following list of files is complete. (cmd-click)
# http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
goa_files <- tibble(survey = c(
  "goa1984_1987.zip",
  "goa1990_1999.zip",
  "goa2001_2005.zip",
  "goa2007_2013.zip",
  "goa2015_2017.zip"
   )
)

# 2. Download the raw data from the website and copy over the strata file
download_ak("goa", goa_files)

# Update Alaska ====
# munge the regional Alaska data into one table per region and save to the Data_Updated directory
dirs <- c("ai", "goa", "ebs")


# create the destination folder
dir.create(file.path("data_updates/Data_Updated/"))

for (i in seq(dirs)){
  # define file path
  target <- paste0("data_raw/", dirs[i], "/", Sys.Date())
  # list the directory at that file path
  dir <- list.dirs(target)
  # list the files within that directory
  files <- list.files(dir)
  # files <- list.files(dir, full = T) # don't need full names?
  
  # create blank table
  dat <- tibble()
  for (j in seq(files)){
    # if the file is not the strata file (which is assumed to not need correction)
    if(!grepl("strata", files[j])){
      # read the csv
      temp2 <- read.csv(paste0(dir,"/", files[j]), stringsAsFactors = F)
      # remove any data rows that have the value "LATITUDE" as data
      temp2 <- filter(temp2, LATITUDE != "LATITUDE", 
        # remove any data rows that are blank for LONGITUDE (blank data row)
        !is.na(LONGITUDE))
      dat <- rbind(dat, temp2)
    }else{
      file.copy(from=paste0(dir,"/", files[j]), to=file.path("data_updates/Data_Updated/"), overwrite=TRUE)
      
    }
  }
  readr::write_csv(dat, path = paste0("data_updates/Data_Updated/", dirs[i], "_data.csv"))
  
  
  print(paste0("completed ", dirs[i]))
}

# clean up
rm(ai_files, dat, ebs_files, goa_files, temp2, dir, dirs, files, i, j, new_dir, target)

# Download WCANN ====

wcann_save_loc <- "data_raw/wcann"
save_date <- Sys.Date()
catch_file_name <- paste("wcann", "catch.csv", sep="_")
haul_file_name <- paste("wcann", "haul.csv", sep="_")

old_names <- c("Anoplopoma fimbria", "Antimora microlepis", "Apristurus brunneus",
  "Bathyagonus nigripinnis", "Bathyraja kincaidii (formerly B. interrupta)",
  "Careproctus melanurus", "Chauliodus macouni", "Glyptocephalus zachirus",
  "Lycodes cortezianus", "Lycodes diapterus", "Lyopsetta exilis",
  "Merluccius productus", "Microstomus pacificus", "Raja rhina",
  "Sagamichthys abei", "Sebastolobus alascanus", "Sebastolobus altivelis",
  "Bathylagidae unident.", "Bothrocara brunneum", "Coryphaenoides acrolepis",
  "Lampanyctus sp.", "Lycenchelys crotalinus", "Myxinidae", "Atheresthes stomias",
  "Bathyagonus pentacanthus", "Hydrolagus colliei", "Ophiodon elongatus",
  "Sebastes alutus", "Sebastes babcocki", "Sebastes crameri", "Sebastes diploproa",
  "Albatrossia pectoralis", "Alepocephalus tenebrosus", "Coryphaenoides cinereus",
  "Embassichthys bathybius", "Talismania bifurcata", "Agonopsis vulsa",
  "Icelinus filamentosus", "Sebastes brevispinis", "Sebastes elongatus",
  "Sebastes emphaeus", "Sebastes entomelas", "Sebastes flavidus",
  "Sebastes helvomaculatus", "Sebastes jordani", "Sebastes paucispinis",
  "Sebastes pinniger", "Sebastes proriger", "Sebastes reedi", "Sebastes ruberrimus",
  "Sebastes wilsoni", "Sebastes zacentrus", "Bathylagus sp.", "Bathyraja trachura",
  "Diaphus theta", "Eptatretus sp.", "Myctophidae", "Paraliparis cephalus",
  "Sternoptyx sp.", "Eopsetta jordani", "Gadus macrocephalus",
  "Parophrys vetulus", "Sebastes melanostictus or Sebastes aleutianus",
  "Squalus suckleyi", "Xeneretmus latifrons", "Hippoglossoides elassodon",
  "Hippoglossus stenolepis", "Citharichthys sordidus", "Lycodes pacificus",
  "Thaleichthys pacificus", "Alosa sapidissima", "Cryptacanthodes giganteus",
  "Ronquilus jordani", "Sebastes saxicola", "Macropinna microstoma",
  "Maulisia mauli", "Tactostoma macropus", "Avocettina infans",
  "Hemilepidotus hemilepidotus", "Hexagrammos decagrammus", "Sebastes nigrocinctus",
  "Theragra chalcogramma", "Clupea pallasi", "Microgadus proximus",
  "Podothecus acipenserinus", "Psettichthys melanostictus", "Raja binoculata",
  "Rajiformes egg case", "Bothrocara molle", "Lycenchelys camchatica",
  "Lycodapus fierasfer", "Careproctus cypselurus", "Lycodapus mandibularis",
  "Paraliparis rosaceus", "Sebastes aurora", "Tarletonbeania crenularis",
  "Apristurus brunneus egg case", "Icichthys lockingtoni", "Malacocottus kincaidi",
  "Sebastes melanostomus", "Sebastes rufus", "Aristostomias scintillans",
  "Engraulis mordax", "Lepidopsetta bilineata", "Pleuronichthys decurrens",
  "Isopsetta isolepis", "Platichthys stellatus", "Icelinus burchami",
  "Anoplogaster cornuta", "Argyropelecus affinis", "Poromitra crassiceps",
  "Leuroglossus stilbius", "Sebastes chlorostictus", "Careproctus gilberti",
  "Chilara taylori", "Sebastes goodei", "Allosmerus elongatus",
  "Cymatogaster aggregata", "Leptocottus armatus", "Cataetyx rubrirostris",
  "Porichthys notatus", "Raja inornata", "Torpedo californica",
  "Oncorhynchus tshawytscha", "Elassodiscus caudatus", "Paraliparis dactylosus",
  "Osmeridae", "Zalembius rosaceus", "Raja stellulata", "Argentina sialis",
  "Genyonemus lineatus", "Nezumia stelgidolepis", "Galeorhinus galeus",
  "Peprilus simillimus", "Zaniolepis latipinnis", "Parmaturus xaniurus",
  "Sternoptyx diaphana", "Enophrys bison", "Hyperprosopon anale",
  "Mustelus californicus", "Sardinops sagax", "Squatina californica",
  "Spirinchus starksi", "Physiculus rastrelliger", "Cephaloscyllium ventriosum",
  "Sebastes caurinus", "Sebastes rubrivinctus", "Sebastes semicinctus",
  "Hippoglossina stomata", "Sebastes sp. (Vermilion And Sunset)",
  "Sebastes levis", "Icelinus fimbriatus", "Sebastes hopkinsi",
  "Zaniolepis frenata", "Pleuronichthys verticalis", "Opisthoproctidae",
  "Nezumia liolepis", "Sternoptychidae unident.", "Chiasmodon niger",
  "Nemichthyidae", "Liparidinae", "Lepidopus xantusi", "Mustelus henlei",
  "Paralabrax nebulifer", "Scorpaena guttata", "Synodus lucioceps",
  "Trachurus symmetricus", "Rajidae unident.", "Dasycottus setiger",
  "Hemilepidotus spinosus", "Sebastes maliger", "Lepidopsetta sp.",
  "Triglops macellus", "Agonidae", "Paraliparis pectoralis", "Radulinus asprellus",
  "Somniosus pacificus", "Poroclinus rothrocki", "Psychrolutes phrictus",
  "Oneirodes sp.", "Coryphaenoides filifer", "Idiacanthus antrostomus",
  "Sebastes auriculatus", "Pleuronichthys ritteri", "Spirinchus thaleichthys",
  "Sebastes rosenblatti", "Sebastes mystinus", "Lycodapus endemoscotus",
  "Xystreurys liolepis", "Sebastes umbrosus", "fish unident.",
  "shark unident.", "Argyropelecus sp.", "Centroscyllium nigrum",
  "Apristurus kampae", "Bajacalifornia burragei", "Stomias atriventer",
  "Citharichthys xanthostigma", "Prionotus stephanophrys", "Magnisudis atlantica",
  "Careproctus sp.", "Gonostomatidae", "Ophidiidae", "Lycodes palearis",
  "Shark egg case unident.", "Melanocetus johnsonii", "Anarrhichthys ocellatus",
  "Cottidae", "Ammodytes hexapterus", "Paralichthys californicus",
  "Argentinidae", "Benthalbella dentata", "Dicrolene filamentosa",
  "Rhinoliparis barbulifer", "Serrivomer sector", "Sebastes borealis",
  "Leuroglossus schmidti", "Chitonotus pugetensis", "Sebastes dalli",
  "Zoarcidae", "Scyliorhinidae", "Embiotoca lateralis", "Bajacalifornia erimoensis",
  "Brosmophycis marginata", "Sebastes ensifer", "Macrouridae",
  "Sebastes sp.", "Eptatretus stouti", "Icelinus sp.", "Raja sp. egg case",
  "Lampetra tridentata", "Bathyraja abyssicola", "Amphistichus rhodoterus",
  "Oncorhynchus kisutch", "Citharichthys sp.", "Nautichthys oculofasciatus",
  "Sebastes constellatus", "Bathyraja aleutica", "Sebastes eos",
  "Enophrys taurina", "Rhinobatidae", "Melamphaes lugubris", "Melanostomiidae",
  "Myliobatis californicus", "Bathylagus milleri", "Stenobrachius leucopsarus",
  "Nemichthys larseni", "Chesnonia verrucosa", "Petromyzontidae",
  "Sebastes melanops", "Nansenia candida", "Platytroctidae", "Engraulidae",
  "Aphanopus carbo", "Scopelosaurus harryi", "Triakididae", "Lamprogrammus niger",
  "Anguilliformes", "Hexanchus griseus", "Kathetostoma averruncus",
  "Scomber japonicus", "Embiotocidae", "Nemichthys scolopaceus",
  "Oneirodidae", "Anoplogastridae", "Chiasmodontidae", "Melanonus zugmayeri",
  "Chauliodontidae", "Osmerus mordax", "Lampanyctus ritteri", "Bathyraja sp. ",
  "Symbolophorus californiensis", "Icelinus tenuis", "fish eggs unident.",
  "Sebastes rosaceus", "Raja binoculata egg case", "Facciolella gilbertii",
  "Lycodapus sp.", "Apristurus sp.", "Eptatretus deani", "Sebastes macdonaldi",
  "Bathyraja sp. egg case", "Chaenophryne draco", "Sebastes serranoides",
  "Phanerodon furcatus", "Coelorinchus scaphopsis", "Maynea californica",
  "Symphurus atricauda", "Bathylagus pacificus", "Sebastes lentiginosus",
  "Bellator xenisma", "Seriphus politus", "Xeneretmus leiops",
  "Hemilepidotus sp.", "Damalichthys vacca", "Merluccius productus YOY",
  "Melanostigma pammelas", "Lestidiops ringens", "Saccopharyngidae",
  "Melamphaidae", "Arctozenus risso", "Venefica sp.", "Sebastes serriceps",
  "Zapteryx exasperata", "Zesticelus profundorum", "Bathyraja trachura egg case",
  "Jordania zonope", "Stromateidae", "Kali indica", "Icosteus aenigmaticus",
  "Citharichthys stigmaeus", "Leuroglossus sp.", "Sebastes carnatus",
  "Kali normani", "Synodontidae", "Trachipterus altivelis", "Tarletonbeania sp.",
  "Clinocottus acuticeps", "Careproctus colletti", "Lycodapus dermatinus",
  "Nectoliparis pelagicus", "Tetragonurus cuvieri", "Alepocephalidae",
  "Cataetyx sp.", "Amphistichus argenteus", "Rhacochilus toxotes",
  "Nettastomatidae", "Serrivomeridae", "Rhinoliparis sp.", "Gigantactis vanhoeffeni",
  "Scopelengys tristis", "Bathyraja kincaidii egg case", "Radulinus taylori",
  "Stomiidae", "Sebastes gilli", "Argyropelecus lychnus", "Cryptopsaras couesii",
  "Moridae", "Bothidae unident.", "Sebastes (=Sebastomus) sp.",
  "Myliobatidae", "Serrivomer jesperseni", "Sebastes ovalis", "Sebastes simulator",
  "Stomiiformes", "Lyconectes aleutensis", "Lycodes brevipes",
  "Rhinoliparis attenuatus", "Diaphus sp.", "Halargyreus johnsoni",
  "Prionace glauca", "Torpedinidae", "Borostomias panamensis",
  "Careproctus ovigerum", "Batrachoididae", "Sciaenidae", "Liparidae n. gen. (Orr)",
  "Bolinia euryptera", "Malacosteidae", "Lycodema barbatum", "Maulisia sp.",
  "Bathylychnops exilis", "Caristius macropus", "Bathophilus flemingi",
  "Elassodiscus tremebundus", "Hypomesus pretiosus", "Paricelinus hopliticus",
  "Paraliparis sp.", "Rhamphocottus richardsoni", "Scorpaenichthys marmoratus",
  "Dasyatidae", "Chaenophryne longiceps", "Oneirodes thompsoni",
  "Howella sherborni", "Phanerodon atripes", "Glyptocephalus zachirus larvae",
  "fish larvae unident.", "Liparis fucensis", "Liparis pulchellus",
  "Mola mola", "Atherinops affinis", "Venefica tentaculata", "Alepocephalus sp.",
  "Bathyagonus sp.", "Psychrolutes paradoxus", "Agonopsis sterletus",
  "Trichodon trichodon", "Dolichopteryx sp.", "Gymnocanthus tricuspis",
  "Icelinus borealis", "Ophidion scrippsae", "Harriotta raleighana",
  "Hydrolagus colliei egg case", "Howella brodiei", "Lepidopsetta polyxystra",
  "Oneirodes acanthias", "Caulophryne jordani", "Centrolophidae",
  "Lepidopus fitchi", "Stichaeidae", "Gibbonsia metzi", "Odontopyxis trispinosa",
  "Cheilotrema saturnum", "Serrivomer sp.", "Plectobranchus evides",
  "Malacocephalus laevis", "Sebastolobus sp.", "Platytroctes apus",
  "Scymnodon squamulosus ", "Pleuronectidae", "Pleuronichthys coenosus",
  "Cryptacanthodidae", "Dolichopteryx longipes", "Stenobrachius sp.",
  "Lycodapus parviceps", "Uranoscopidae", "Benthodesmus pacificus",
  "Pleuronectiformes", "Hydrolagus spp.", "Sebastes variegatus",
  "Oxylebius pictus", "Zaniolepididae", "Neoclinus blanchardi",
  "Desmodema lorum", "Gonostoma sp.", "Aphanopus intermedius",
  "Syngnathidae", "Caulolatilus princeps", "Malacanthidae", "Melanonidae",
  "Bathymasteridae", "Leptocephalus sp.", "Lumpenus maculatus",
  "Triakis semifasciata", "Heterodontus francisci", "Ceratiidae unident.",
  "Bathymaster signatus", "Eurypharynx pelecanoides", "Trachipteridae",
  "Saccopharynx sp.", "Amblyraja badia")

url_catch <- "https://www.nwfsc.noaa.gov/data/api/v1/source/trawl.catch_fact/selection.json?filters=project=Groundfish%20Slope%20and%20Shelf%20Combination%20Survey,date_dim$year>=2003"
data_catch <- jsonlite::fromJSON( url_catch )

url_haul <- "https://www.nwfsc.noaa.gov/data/api/v1/source/trawl.operation_haul_fact/selection.json?filters=project=Groundfish%20Slope%20and%20Shelf%20Combination%20Survey,date_dim$year>=2003"
data_haul <- jsonlite::fromJSON( url_haul )

if(!dir.exists(file.path(wcann_save_loc, save_date))){
  dir.create(file.path(wcann_save_loc, save_date))
}

write.csv(data_catch, file=file.path(wcann_save_loc, save_date, catch_file_name), row.names=FALSE)
write.csv(data_haul, file=file.path(wcann_save_loc, save_date, haul_file_name), row.names=FALSE)

# Update WCANN ====
# define the file we are looking for
target <- paste0("data_raw/wcann/", Sys.Date())
# get the directory
dir <- list.dirs(target)
# list the files in that directory
files <- list.files(dir)
full_files <- list.files(dir, full.names = T)

catch <- read.csv(paste0(dir, "/wcann_catch.csv"), stringsAsFactors = F)
catch <- catch %>% 
  select("trawl_id","year","longitude_dd","latitude_dd","depth_m","scientific_name","total_catch_wt_kg","cpue_kg_per_ha_der")

haul <- read.csv(paste0(dir, "/wcann_haul.csv"), stringsAsFactors = F)
haul <- haul %>% 
  select("trawl_id","year","longitude_hi_prec_dd","latitude_hi_prec_dd","depth_hi_prec_m","area_swept_ha_der")

# this merge needs to be successful for complete_r_script to have a chance at working  
test <- merge(catch, haul, by=c("trawl_id","year"), all.x=TRUE, all.y=FALSE, allow.cartesian=TRUE) 

# Write files as .csv's
readr::write_csv(catch, path = "data_updates/Data_Updated/wcann_catch.csv")
readr::write_csv(haul, path = "data_updates/Data_Updated/wcann_haul.csv")  

print(paste0("completed WCANN"))

#clean up
rm(catch, data_catch, data_haul, haul, test, catch_file_name, dir, files, full_files, haul_file_name, old_names, save_date, target, url_catch, url_haul, wcann_save_loc)

# Download GMEX ====
# Have to go to the website (cmd+click) http://seamap.gsmfc.org/

# Pull in the data from your Downloads folder
new_dir <- file.path(paste0("data_raw/gmex/", Sys.Date()))
# create the destination folder
dir.create(new_dir)

# copy the file from the downloads folder into the current day's directory
file.copy(from = "~/Downloads/public_seamap_csvs/BGSREC.csv", to = new_dir)
file.copy(from = "~/Downloads/public_seamap_csvs/CRUISES.csv", to = new_dir)
file.copy(from = "~/Downloads/public_seamap_csvs/NEWBIOCODESBIG.csv", to = new_dir)
file.copy(from = "~/Downloads/public_seamap_csvs/STAREC.csv", to = new_dir)
file.copy(from = "~/Downloads/public_seamap_csvs/INVREC.csv", to = new_dir)

# Update GMEX ====
# define file path
target <- new_dir

# list the directory at that file path
dir <- list.dirs(target)
# list the files within that directory
files <- list.files(dir)

bio <-read.csv(paste0(dir,"/BGSREC.csv"), stringsAsFactors = F) %>% 
  select(-INVRECID, -X)
readr::write_csv(bio, path = "data_updates/Data_Updated/gmex_bio.csv")

cruise <-read.csv(paste0(dir,"/CRUISES.csv"), stringsAsFactors = F) %>% 
  select(-X)
readr::write_csv(cruise, path = "data_updates/Data_Updated/gmex_cruise.csv")

spp <-read.csv(paste0(dir,"/NEWBIOCODESBIG.csv"), stringsAsFactors = F) %>% 
  select(-X, -tsn_accepted)
readr::write_csv(spp, path = "data_updates/Data_Updated/gmex_spp.csv")

gmexStation_raw <- readLines(paste0(dir,"/STAREC.csv"))
esc_patt <- "\\\\\\\""
esc_replace <- "\\\"\\\""
gmexStation_noEsc <- gsub(esc_patt, esc_replace, gmexStation_raw)
cat(gmexStation_noEsc, file="data_updates/Data_Updated/gmex_station.csv", sep="\n")

tow <-read.csv(paste0(dir,"/INVREC.csv"), stringsAsFactors = F) %>% 
  select(-X)
readr::write_csv(tow, path = "data_updates/Data_Updated/gmex_tow.csv")


print(paste0("completed gmex"))

