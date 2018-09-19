# Fix Alaska Data 2018 ####

# use this on the raw data before it gets zipped up

# As of 2018, some of the Alaska files contain an extra line of header titles buried in the data.  This causes errors in the complete_R_script.  This section finds those extra lines and removes them.

library(dplyr)
dirs <- c("ai", "goa", "ebs")
for (i in seq(dirs)){
  target <- paste0("data_raw/", dirs[i], "/", Sys.Date())
  dir <- list.dirs(target)
  files <- list.files(dir)
  for (j in seq(files)){
    if(!grepl("strata", files[j])){
      temp2 <- read.csv(paste0(dir,"/", files[j]), stringsAsFactors = F)
      temp2 <- dplyr::filter(temp2, LATITUDE != "LATITUDE", !is.na(LONGITUDE))
      write.csv(temp2, file = paste0(dir,"/" , files[j]), row.names = F)
    }
  }
}

# test <- read.csv("data_raw/ai/2018-09-19/ai2014_2016.csv")
