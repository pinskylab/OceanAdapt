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
  
file.copy(from=paste0(dir,"/BGSREC.csv"), to=file.path("data_updates/Data_Updated/gmex_bio.csv"), overwrite=TRUE)
# check to make sure these files are identical
 
      }
  }
  readr::write_csv(dat, path = paste0("data_updates/Data_Updated/", dirs[i], "_data.csv"))
  
    
    print(paste0("completed ", dirs[i]))


