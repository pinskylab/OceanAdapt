# Fix SEUS Data 2018 ####

# use this on the raw data before it gets zipped up

# As of 2018, some of the SEUS files contain rows that do not contain data but contain other info that interferes with our scripts.


# library(dplyr)

# define the file we are looking for
target <- paste0("data_raw/seus/", params$date)
# get the directory
dir <- list.dirs(target)
# list the files in that directory
files <- list.files(dir)

# iterate through the files and remove erroneous lines
for (j in seq(files)){
  if(!grepl("strata", files[j])){
    temp2 <- read.csv(paste0(dir,"/", files[j]), stringsAsFactors = F)
    temp2 <- dplyr::filter(temp2, PROJECTNAME == "=Coastal Survey")
    write.csv(temp2, file = paste0(dir,"/" , files[j]), row.names = F)
  }
}
print("fix_seus complete")
# test <- read.csv("data_raw/ai/2018-09-19/ai2014_2016.csv")
