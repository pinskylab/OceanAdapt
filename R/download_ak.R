# This function replaces existing ak files in the data_raw folder with the most recent version.

# Check [Alaskan website](https://www.fisheries.noaa.gov/alaska/commercial-fishing/alaska-groundfish-bottom-trawl-survey-data) for any new data and add it to the list, files to watch are ai2014-2018, ebs2017-2018, and goa2015-2017.  Did the names changes?  Are there more recent files?
library(tibble)
download_ak <- function(){
  # define the destination folder
  for (i in seq(ak_files$survey)){
    # define the destination file path
    file <- paste("data_raw", ak_files$survey[i], sep = "/")
    # define the source url
    url <- paste("https://www.afsc.noaa.gov/RACE/groundfish/survey_data/downloads", ak_files$survey[i], sep = "/")
    # download the file from the url to the destination file path
    download.file(url,file)
    # unzip the new file - this will overwrite an existing file of the same name
    unzip(file, exdir = "data_raw")
    # delete the downloaded zip file
    file.remove(file)
  }
}

ak_files <- tibble(survey = c("ai1983_2000.zip", 
                              "ai2002_2012.zip", 
                              "ai2014_2018.zip", 
                              
                              "ebs1982_1984.zip", 
                              "ebs1985_1989.zip", 
                              "ebs1990_1994.zip", 
                              "ebs1995_1999.zip", 
                              "ebs2000_2004.zip", 
                              "ebs2005_2008.zip", 
                              "ebs2009_2012.zip", 
                              "ebs2013_2016.zip", 
                              "ebs2017_2018.zip", 
                              
                              "goa1984_1987.zip", 
                              "goa1990_1999.zip", 
                              "goa2001_2005.zip", 
                              "goa2007_2013.zip", 
                              "goa2015_2017.zip"))

file_list <- ak_files$survey
download_ak(file_list)
