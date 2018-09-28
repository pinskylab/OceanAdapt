# Fix Alaska Data 2018 ####

# use this on the raw data before it gets zipped up

# As of 2018, some of the Alaska files contain an extra line of header titles buried in the data.  This causes errors in the complete_R_script.  This section finds those extra lines and removes them.

# library(dplyr)

dirs <- c("ai", "goa", "ebs")

for (i in seq(dirs)){
  # define file path
  target <- paste0("data_raw/", dirs[i], "/", params$date)
  # list the directory at that file path
  dir <- list.dirs(target)
  # list the files within that directory
  files <- list.files(dir)
  # change to full.names = T?####
  
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



