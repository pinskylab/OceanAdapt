# Fix Alaska Data 2018 ####

# use this on the raw data before it gets zipped up

# As of 2018, some of the Alaska files contain an extra line of header titles buried in the data.  This causes errors in the complete_R_script.  This section finds those extra lines and removes them.

# library(dplyr)

# define file path
target <- paste0("data_raw/gmex/", params$date)

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


