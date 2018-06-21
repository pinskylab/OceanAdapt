# Fix Alaska Data 2018 ####

# use this on the raw data before it gets zipped up

# As of 2018, some of the Alaska files contain an extra line of header titles buried in the data.  This causes errors in the complete_R_script.  This section finds those extra lines and removes them.


dirs <- c("ai", "goa", "ebs")
for (i in seq(dirs)){
  target <- paste0("data_raw/", dirs[i], "/", Sys.Date())
  dir <- list.dirs(target)
  files <- list.files(dir)
  for (j in seq(files)){
    if(!grepl("strata", files[j])){
      temp2 <- readr::read_csv(paste0(dir,"/", files[j]))
      temp2 <- dplyr::filter(temp2, LATITUDE != "LATITUDE")
      write.csv(temp2, file = paste0(dir,"/" , files[j]), row.names = F)
    }
  }
}
 # as code executes, it will flash the warnings of all of the files that have these text headers where there should be numbers, that is a good thing.
