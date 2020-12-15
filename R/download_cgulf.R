library(readr)
library(jsonlite)

#visit the following link to download .csv files survey, Southern GSL demersal (1970 to present):
https://open.canada.ca/data/en/dataset/1989de32-bc5d-c696-879c-54d422438e64
#double-click data download and copy/paste the URL into the url_catch line below

save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "GSLsouth.csv"
data <- read.csv("https://raw.githubusercontent.com/dfo-gulf-science/fgp-datasets/master/rv_survey/sGSL-September-RV-FGP.csv")
write_csv(data, here::here(save_loc, file_name))
rm(data, save_date, file_name, save_loc)

#visit the following link to download .csv files survey, Estuary of GSL pelagic (2009 to 2018):
https://open.canada.ca/data/en/dataset/f1fc359c-0ed1-4045-a421-adef2497b68d
#double-click data download and copy/paste the URL into the url_catch line below

save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "GSL_pelagic_north.csv"
temp <- tempfile()
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Pelagic_fish_species_abondance_Teleost/Teleost_Especes_Pelagiques_Abondance_2009-2018.zip",temp)
data <- read.csv(unz(temp, "Abondance_Nord_2009a2018.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "GSL_pelagic_south.csv"
data <- read.csv(unz(temp, "Abondance_Sud_2009a2018.csv"))
write_csv(data, here::here(save_loc, file_name))
rm(data, save_date, file_name, save_loc)

#visit the following link to download .csv files survey northern GSL demersal, MV Lady Hammond (1984 to 1990):
https://open.canada.ca/data/en/dataset/86a9d0b0-fcce-48ed-a124-68061d7b7553
#double-click data download and copy/paste the URL into the url_catch line below

save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "GSLnorth_hammond.csv"
data <- read.csv("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/lady_hammond/PGF_LadyHammond.csv")
write_csv(data, here::here(save_loc, file_name))
rm(data, save_date, file_name, save_loc)

#visit the following link to download .csv files survey northern GSL demersal MV Gadus Atlantica (1978 to 1994):
https://open.canada.ca/data/en/dataset/4bbd03ce-ae48-4aaa-97ac-5594c2a3a6c2
#double-click data download and copy/paste the URL into the url_catch line below

save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "GSLnorth_gadus.csv"
data <- read.csv("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/gadus_atlantica/PGF_Gadus.csv")
write_csv(data, here::here(save_loc, file_name))
rm(data, save_date, file_name, save_loc)


#visit the following link to download .csv files survey northern GSL demersal, Mobile Gear Sentinel (1995 to present):
https://open.canada.ca/data/en/dataset/929fe07f-ab8e-4b3c-8ee3-1aa7a9ea0b1a
#double-click data download and copy/paste the URL into the url_catch line below

save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "GSLnorth_sentinel.csv"
data <- read_delim("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/mobile_gear/PGF_PSM.csv", ";")
write_csv(data, here::here(save_loc, file_name))
rm(data, save_date, file_name, save_loc)

#visit the following link to download .csv files survey northern GSL demersal, CCGS Alfred Needler (1990 to 2005):
https://open.canada.ca/data/en/dataset/4eaac443-24a8-4b37-9178-d7cce4eb7c7b
#double-click data download and copy/paste the URL into the url_catch line below

save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "GSLnorth_needler.csv"
data <- read.csv("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/needler/PGF_Needler.csv")
write_csv(data, here::here(save_loc, file_name))
rm(data, save_date, file_name, save_loc)

#visit the following link to download .csv files survey northern GSL demersal, CCGS Teleost (2004 to 2019):
https://open.canada.ca/data/en/dataset/40381c35-4849-4f17-a8f3-707aa6a53a9d
#double-click data download and copy/paste the URL into the url_catch line below

save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "GSLnorth_teleost.csv"
data <- read.csv("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/teleost/PGF_Teleost.csv")
write_csv(data, here::here(save_loc, file_name))
rm(data, save_date, file_name, save_loc)







