#' ---
#' title: "Download NEUS"
#' ---
#'
#' Download the spring and fall bottom trawl survey files from 
#' [Fall](https://inport.nmfs.noaa.gov/inport/item/22560) 
#' and [Spring](https://inport.nmfs.noaa.gov/inport/item/22561). 
#' Currently ftp through R is not working, so first visit the website and download
#' files at each link under "Distribution 1" and "Distribution 2" 
#' Then use the first chunk of code to unzip the files into "ownloads "data_raw"
#' Then use the second chunk to move the files out of their subdirectory and rename
#' 
#' 
## ----neus----------------------------------------------------------------


unzip("~/Downloads/SVDBS_SupportTables.zip", exdir = here::here("data_raw"))
svdbs <- dir(pattern = "SVDBS", path = "data_raw", full.names = T)
svdbs <- svdbs[-c(grep("STRATA","SPECIES", svdbs))]
file.remove(svdbs)
file.rename(here::here("data_raw", "SVDBS_SVMSTRATA.csv"), here::here("data_raw", "neus_strata.csv"))
file.rename(here::here("data_raw", "SVDBS_SVSPECIES_LIST.csv"), here::here("data_raw", "neus_spp.csv"))

other <- dir(pattern = "SVDBS", path = "data_raw", full.names = T)
unlink(other, recursive = TRUE)

unzip("~/Downloads/22560_FSCSTables.zip", exdir = here::here("data_raw"))
unzip("~/Downloads/22561_FSCSTables.zip", exdir = here::here("data_raw"))

file.rename(here::here("data_raw","22560_FSCSTables/22560_UNION_FSCS_SVSTA.csv"), here::here("data_raw","neus_fall_svsta.csv"))
file.rename(here::here("data_raw","22560_FSCSTables/22560_UNION_FSCS_SVCAT.csv"), here::here("data_raw","neus_fall_svcat.csv"))

file.rename(here::here("data_raw","22561_FSCSTables/22561_UNION_FSCS_SVSTA.csv"), here::here("data_raw","neus_spring_svsta.csv"))
file.rename(here::here("data_raw","22561_FSCSTables/22561_UNION_FSCS_SVCAT.csv"), here::here("data_raw","neus_spring_svcat.csv"))

other <- dir(pattern = "FSCS", path = "data_raw", full.names = T)
unlink(other, recursive = TRUE)
