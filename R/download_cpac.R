library(readr)
library("jsonlite")


#visit the following links to download .csv files survey (1970 to present):
https://open.canada.ca/data/en/dataset/86af7918-c2ab-4f1a-ba83-94c9cebb0e6c
https://open.canada.ca/data/en/dataset/557e42ae-06fe-426d-8242-c3107670b1de
https://open.canada.ca/data/en/dataset/780a1c02-1f9c-4994-bc70-a0e9ef8e3968
https://open.canada.ca/data/en/dataset/5ee30758-b1d6-49fe-8c4e-5136f4b39ad1
https://open.canada.ca/data/en/dataset/d880ba18-8790-41a2-bf73-e9247380759b
#double-click data download and copy/paste the URL into the url_catch line below

#Queen Charlotte Sound
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "QCS_effort.csv"
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Groundfish_Synoptic_Trawl_Surveys/Queen_Charlotte_Sound/english.zip",temp)
data <- read.csv(unz(temp, "English/QCS_effort.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "QCS_catch.csv"
data <- read.csv(unz(temp, "English/QCS_catch.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "QCS_biomass.csv"
data <- read.csv(unz(temp, "English/QCS_biomass.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "QCS_biology.csv"
data <- read.csv(unz(temp, "English/QCS_biology.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp)

#West Coast Vancouver
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Groundfish_Synoptic_Trawl_Surveys/West_Coast_VI/english.zip",temp)
file_name <- "WCV_effort.csv"
data <- read.csv(unz(temp, "English/WCVI_effort.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "WCV_catch.csv"
data <- read.csv(unz(temp, "English/WCVI_catch.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "WCV_biomass.csv"
data <- read.csv(unz(temp, "English/WCVI_biomass.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "WCV_biology.csv"
data <- read.csv(unz(temp, "English/WCVI_biology.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp)

#Hecate Strait
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Groundfish_Synoptic_Trawl_Surveys/Hecate_Strait/english.zip",temp)
file_name <- "HS_effort.csv"
data <- read.csv(unz(temp, "English/HS_effort.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "HS_catch.csv"
data <- read.csv(unz(temp, "English/HS_catch.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "HS_biomass.csv"
data <- read.csv(unz(temp, "English/HS_biomass.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "HS_biology.csv"
data <- read.csv(unz(temp, "English/HS_biology.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp)

#West Coast Haida Gwaii
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Groundfish_Synoptic_Trawl_Surveys/West_Coast_HG/english.zip",temp)
file_name <- "WCHG_effort.csv"
data <- read.csv(unz(temp, "English/WCHG_effort.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "WCHG_catch.csv"
data <- read.csv(unz(temp, "English/WCHG_catch.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "WCHG_biomass.csv"
data <- read.csv(unz(temp, "English/WCHG_biomass.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "WCHG_biology.csv"
data <- read.csv(unz(temp, "English/WCHG_biology.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp)

#Strait of Georgia
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Groundfish_Synoptic_Trawl_Surveys/Strait_of_Georgia/english.zip",temp)
file_name <- "SOG_effort.csv"
data <- read.csv(unz(temp, "English/SOG_effort.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "SOG_catch.csv"
data <- read.csv(unz(temp, "English/SOG_catch.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "SOG_biomass.csv"
data <- read.csv(unz(temp, "English/SOG_biomass.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "SOG_biology.csv"
data <- read.csv(unz(temp, "English/SOG_biology.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp)

#clean environment
rm(data, file_name, save_date, save_loc, temp, zip)
