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

  
