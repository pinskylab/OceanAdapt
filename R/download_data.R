# this script downloads the ocean adapt data

library(tidyverse)

# This function replaces existing ak files in the data_raw folder with the most recent version.
download_ak <- function(region, ak_files){
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

# function for Scotian Shelf data
# library(remotes)
# install_github('Maritimes/FGP')
# library(FGP)

#' @title pullDFOGIS_Prod
#' @description This function extracts an r data.frame from the DFO ESRI REST 
#' service.
#' @param service  The default value is 
#' \code{'ADAPT_Canada_Atlantic_Summer_2016'}.  This identifies the service from
#' which you want to extract data.
#' @param save_csv The default value is \code{TRUE}, which means that the 
#' extracted data is saved to a csv file in your working directory.  If 
#' \code{FALSE}, no csv will be created. 
#' @param rec_Start The default is \code{0}.  Primarily for debugging, this 
#' allows the user to select only some of the records, rather than doing a full 
#' extraction. 
#' @family ArcGIS
#' @author  Mike McMahon, \email{Mike.McMahon@@dfo-mpo.gc.ca}
#' @importFrom jsonlite fromJSON
#' @export
pullDFOGIS_Prod <-function(service='ADAPT_Canada_Atlantic_Summer_2018', save_csv=TRUE, rec_Start = 0) {
  timer.start=proc.time() #start timing, for science!
  base_url= paste0('http://geoportal-geoportail.gc.ca/arcgis/rest/services/SciencePublicationsCSAS/',service,'/MapServer/0/')
  require(jsonlite)
  extr_Lim = 1000 #can get this many at a time
  
  #total number of records available
  json_cnt_url <- paste0(base_url,'query?where=1=1&f=pjson&returnCountOnly=true')
  json_cnt <- fromJSON(json_cnt_url)
  if ('error' %in% names(json_cnt)) stop(paste0('\nSomething appears to be wrong with the selected service. Please try again later.
                                                \nYou can try visiting the following url in your browser to see if there\'s any additional information:
                                                \n',base_url))
  rec_N = json_cnt$count
  print(paste0('Starting extraction of ',rec_N-rec_Start,' records'))
  
  pb = txtProgressBar(min=1, 
                      max=ceiling((rec_N-rec_Start)/extr_Lim), 
                      style = 3)
  for (i in 1:ceiling((rec_N-rec_Start)/extr_Lim)){
    this_pull <- paste0(base_url,'query?where=OBJECTID%3E=0&f=pjson&returnCountOnly=false&returnGeometry=false&outFields=*&resultOffset=',rec_Start,'&resultRecordCount=',extr_Lim)
    this_data <- fromJSON(this_pull)
    if(i==1){    #first resultset, instantiate df
      this.df=this_data$features$attributes
    }else{       # add to existing df
      this.df = rbind(this.df, this_data$features$attributes)
    } 
    rec_Start = rec_Start+extr_Lim
    Sys.sleep(0.1)
    setTxtProgressBar(pb, i)
  }
  close(pb)
  
  names(this.df) = this_data$fields$alias
  this.df$OBJECTID = NULL
  elapsed=timer.start-proc.time() #determine runtime
  cat(paste0('\nExtraction completed in ',round(elapsed[3],0)*-1, ' seconds'))
  if (save_csv){
    filename = paste0(service,'.csv')
    write.csv(this.df,filename, row.names = FALSE)
    cat(paste0("\ncsv written to ",getwd(), filename))
  }
  return(this.df)
}
#' Test calls using production 2016 services hosted on DFO eGIS infrastructure
#' fallNew=pullDFOGIS_Prod(service='ADAPT_Canada_Atlantic_Fall_2018')
#' summerNew=pullDFOGIS_Prod(service='ADAPT_Canada_Atlantic_Summer_2018')
# springNew=pullDFOGIS_Prod(service='ADAPT_Canada_Atlantic_Spring_2018')




  ## Acquire new data ====
  # We want the full dataset every single time, from the start of the survey through the most recent year. This helps catch any updates the surveys have made to past years (they sometimes catch and fix old errors). 
  
  # Download AI ====
  # 1. Visit website and confirm that the following list of files is complete. (cmd-click)
  # http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
  ai_files <- tibble(survey = c(
    "ai1983_2000.zip", 
    "ai2002_2012.zip",
    "ai2014_2016.zip"
  ))
  
  # 2. Download the raw data from the website and copy over the strata file
  download_ak("ai", ai_files)
  
  # Download EBS ====
  # 1. Visit website and confirm that the following list of files is complete. (cmd-click)
  # http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
  ebs_files <- tibble(survey = c(
    "ebs1982_1984.zip", 
    "ebs1985_1989.zip", 
    "ebs1990_1994.zip",
    "ebs1995_1999.zip",
    "ebs2000_2004.zip",
    "ebs2005_2008.zip",
    "ebs2009_2012.zip",
    "ebs2013_2016.zip",
    "ebs2017.zip" )
  )
  
  # 2. Download the raw data from the website and copy over the strata file
  download_ak("ebs", ebs_files)
  
  # Download GOA ====
  # 1. Visit website and confirm that the following list of files is complete. (cmd-click)
  # http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm
  goa_files <- tibble(survey = c(
    "goa1984_1987.zip",
    "goa1990_1999.zip",
    "goa2001_2005.zip",
    "goa2007_2013.zip",
    "goa2015_2017.zip"
  )
  )
  
  # 2. Download the raw data from the website and copy over the strata file
  download_ak("goa", goa_files)
  
  # cleanup
  rm(ai_files, ebs_files, goa_files)
  
  # Download WCANN ====
  
  haul_file_name <- "data_raw/wcann_haul.csv"
  
  url_catch <- "https://www.nwfsc.noaa.gov/data/api/v1/source/trawl.catch_fact/selection.json?filters=project=Groundfish%20Slope%20and%20Shelf%20Combination%20Survey,date_dim$year>=2003"
  data_catch <- jsonlite::fromJSON(url_catch)
  
  ###TAKES ~13 MINUTES ###
  
  url_haul <- "https://www.nwfsc.noaa.gov/data/api/v1/source/trawl.operation_haul_fact/selection.json?filters=project=Groundfish%20Slope%20and%20Shelf%20Combination%20Survey,date_dim$year>=2003"
  data_haul <- jsonlite::fromJSON(url_haul)
  
  write_csv(data_catch, "data_raw/wcann_catch.csv")
  
  write.csv(data_haul,  "data_raw/wcann_haul.csv")
  
  
  # cleanup
  rm(data_catch, data_haul, haul_file_name, url_catch, url_haul)
  
  # Download GMEX ====
  # Have to go to the website (cmd+click) http://seamap.gsmfc.org/
  
  # copy the file from the downloads folder into the current day's directory
  file.copy(from = "~/Downloads/public_seamap_csvs/BGSREC.csv", to = "data_raw/gmex_BGSREC.csv", overwrite = T)
  file.copy(from = "~/Downloads/public_seamap_csvs/CRUISES.csv", to = "data_raw/gmex_CRUISES.csv", overwrite = T)
  file.copy(from = "~/Downloads/public_seamap_csvs/NEWBIOCODESBIG.csv", to = "data_raw/gmex_NEWBIOCODESBIG.csv", overwrite = T)
  file.copy(from = "~/Downloads/public_seamap_csvs/STAREC.csv", to = "data_raw/gmex_STAREC.csv", overwrite = T)
  file.copy(from = "~/Downloads/public_seamap_csvs/INVREC.csv", to = "data_raw/gmex_INVREC.csv", overwrite = T)
  
  
  
  # Download NEUS ====
  # Email Sean Lucey,  sean.lucey_at_noaa.gov , to get the latest survdata.RData file - Sean responded within an hour of emailing.
  
  file.copy(from = "~/Downloads/Survdat.RData", to = "data_raw/neus_Survdat.Rdata", overwrite = T)
  
  
  # Download SEUS ====
  # The whack-a-mole site
  # As of 2019, don't use the safari browser, it downloads strangely.  Use Chrome.
  # Download the data from the website (cmd+click):
  # (https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports)
  # Click on Coastal Trawl Survey Extraction
  # In the "Type of Data" menu, you need 2 things: 
  #   1. Event Information 
  #   2. Abundance and Biomass
  #         For the list of data values, click the |<- button on the right and it will move all of the values over to the left.
  # * Note: It'll play whack-a-mole with you (meaning once you have moved fields to the left, they will pop back over to the right) … have fun! (If you don't encounter this annoyance, don't worry)
  
haul <- list.files(path = "~/Downloads", pattern = "EVENT", full = T)
catch <- list.files(path = "~/Downloads", pattern = "ABUNDANCE", full = T)
  
  file.copy(from = catch, to = "data_raw/seus_catch.csv", overwrite = T)
  file.copy(from = haul, to = "data_raw/seus_haul.csv", overwrite = T)
  
  rm(catch, haul)

 # Get Scotian data ====
  # the summer data takes about 10 minutes
  scot_sumr <-  pullDFOGIS_Prod(service = "ADAPT_Canada_Atlantic_Summer_2018")
  scot_fall <-  pullDFOGIS_Prod(service = "ADAPT_Canada_Atlantic_Fall_2018")
  scot_spr <-  pullDFOGIS_Prod(service = "ADAPT_Canada_Atlantic_Spring_2018")
  
  # This doesn't exist (2017 doesn't exist either)
  # summer2018 <- get_DFO_REST(service = "ADAPT_Canada_Atlantic_Summer_2018", save_csv = TRUE)
  file.rename("data_raw/ADAPT_Canada_Atlantic_Fall_2018.csv", "data_raw/scot_fall.csv")
  file.rename("data_raw/ADAPT_Canada_Atlantic_Summer_2018.csv", "data_raw/scot_summer.csv")
  file.rename("data_raw/ADAPT_Canada_Atlantic_Spring_2018.csv", "data_raw/scot_spring.csv")
  
