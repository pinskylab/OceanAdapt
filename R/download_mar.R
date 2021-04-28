 #' In February 2021, Mike McMahon and Brian Bowers directed us to their newly uploaded Maritimes data on the open.canada.ca site.
 #' 
 #' Visit the following links to and copy download URL by right-clicking "Access" button next to dataset on website
 #' to make sure that the download URL has not changed
 #' If new link, copy and paste URL into download.file() functions below
 #' Then right script
 #' Fall: https://open.canada.ca/data/en/dataset/5f82b379-c1e5-4a02-b825-f34fc645a529
 #' Spring: https://open.canada.ca/data/en/dataset/fecf045a-95a2-4b69-8a40-818649a62716
 #' Summer: https://open.canada.ca/data/en/dataset/1366e1f1-e2c8-4905-89ae-e10f1be0a164
 #' 4VSW: https://open.canada.ca/data/en/dataset/a851ce30-e216-4d7d-a29c-05631eef140e #too small a region 
 #' and short a time series to warrant inclusion; however, worth checking annually
 #'
 #' 

#Maritimes Fall
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "MAR_FALL_MISSION.csv"
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Maritimes_Research_Vessel_Survey/FALL_csv.zip",temp)
data <- read.csv(unz(temp, "FALL_2020GSMISSIONS.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "MAR_FALL_CATCH.csv"
data <- read.csv(unz(temp, "FALL_2020_GSCAT.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "MAR_FALL_INF.csv"
data <- read.csv(unz(temp, "FALL_2020_GSINF.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "MAR_FALL_SPP.csv"
data <- read.csv(unz(temp, "FALL_2020_GSSPECIES.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp) 



#Maritimes Spring
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "MAR_SPRING_MISSION.csv"
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Maritimes_Research_Vessel_Survey/SPRING_csv.zip",temp)
data <- read.csv(unz(temp, "SPRING_2020GSMISSIONS.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "MAR_SPRING__CATCH.csv"
data <- read.csv(unz(temp, "SPRING_2020_GSCAT.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "MAR_SPRING__INF.csv"
data <- read.csv(unz(temp, "SPRING_2020_GSINF.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "MAR_SPRING__SPP.csv"
data <- read.csv(unz(temp, "SPRING_2020_GSSPECIES.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp) 

#Maritimes Summer
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "MAR_SUMMER_MISSION.csv"
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Maritimes_Research_Vessel_Survey/SUMMER_csv.zip",temp)
data <- read.csv(unz(temp, "SUMMER_2020GSMISSIONS.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "MAR_SUMMER_CATCH.csv"
data <- read.csv(unz(temp, "SUMMER_2020_GSCAT.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "MAR_SUMMER_INF.csv"
data <- read.csv(unz(temp, "SUMMER_2020_GSINF.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "MAR_SUMMER_SPP.csv"
data <- read.csv(unz(temp, "SUMMER_2020_GSSPECIES.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp) 

#4VSW
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "4VSW_MISSION.csv"
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Maritimes_Research_Vessel_Survey/4VSW_csv.zip",temp)
data <- read.csv(unz(temp, "4VSW_2020GSMISSIONS.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "4VSW_CATCH.csv"
data <- read.csv(unz(temp, "4VSW_2020_GSCAT.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "4VSW_INF.csv"
data <- read.csv(unz(temp, "4VSW_2020_GSINF.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "4VSW_SPP.csv"
data <- read.csv(unz(temp, "4VSW_2020_GSSPECIES.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp) 
#' Old script preserved below
------------------------------------------------------------  
 #' 
 #' In June 2020, Mike McMahon said that new data is always available at: ftp://ftp.dfo-mpo.gc.ca/MarPED/RVSurvey_20200420.zip
 #' In March 2020, Mike McMahon referred us to his Git profile, from which this script was downloaded.
 #' Though he suggested using his package "FGP" (https://github.com/Maritimes/FGP/), we opted to write 
 #' the function "get_DFO_REST" directly (https://github.com/Maritimes/FGP/blob/master/R/get_DFO_REST.R).
 #' The package is only functional in some versions of R, whereas this function is nearly universal, 
 #' and the only piece of the package we need. Run the following:
 #' 
 #' 
 #' @title get_DFO_REST
 #' @description This function facilitates the extraction of data from the DFO 
 #' ESRI REST services into R objects and other formats.  
 #' By default, the REST services only allow the extraction of 1000 records at a 
 #' time, and this function does many successive extractions, and merges the
 #' records together into a single object. 
 #' @param host The default is \code{https://gisp.dfo-mpo.gc.ca}.  This identifies the host  url for the service.
 #' @param service  The default value is
 #' \code{'FGP/ADAPT_Canada_Atlantic_Summer_2016'}.  This identifies the folder and service from
 #' which you want to extract data.
 #' @param save_csv The default value is \code{TRUE}, which means that the
 #' extracted data is saved to a csv file in your working directory.  If
 #' \code{FALSE}, no csv will be created.
 #' @param n_rec The default is \code{0}.  Primarily for debugging, this
 #' allows the user to select only some records, rather than doing a full
 #' extraction.
 #' @family ArcGIS
 #' @author  Mike McMahon, \email{Mike.McMahon@@dfo-mpo.gc.ca}
 #' @importFrom jsonlite fromJSON
 #' @importFrom utils setTxtProgressBar
 #' @importFrom utils txtProgressBar
 #' @importFrom utils write.csv
 #' @export
#  get_DFO_REST <-function(host = "https://gisp.dfo-mpo.gc.ca", service='FGP/ADAPT_Canada_Atlantic_Summer_2016', save_csv=TRUE, n_rec = 0) {
#    timer.start=proc.time() #start timing, for science!
#    base_url= paste0(host,'/arcgis/rest/services/',service,'/MapServer/0/')
#    extr_Lim = 1000 #can get this many at a time
#    
#    #total number of records available
#    json_cnt_url <- paste0(base_url,'query?where=1=1&f=pjson&returnCountOnly=true')
#    json_cnt <- jsonlite::fromJSON(json_cnt_url)
#    if ('error' %in% names(json_cnt)) stop(paste0('\nSomething appears to be wrong with the selected service. Please try again later.
#                                                  \nYou can try visiting the following url in your browser to see if there\'s any additional information:
#                                                  \n',base_url))
#    rec_Avail = json_cnt$count
#    cat('\n',rec_Avail,' records available')
#    if (n_rec==0){
#      wanted = rec_Avail
#      cat('\nStarting complete extraction')
#    }else{
#      wanted = n_rec
#      cat('\nStarting extraction of first ',n_rec,' records')
#    }
#    
#    pb = txtProgressBar(min=0,
#                        max=ceiling(wanted/extr_Lim),
#                        style = 3)
#    rec_Start=0
#    for (i in 1:ceiling(wanted/extr_Lim)){
#      if ((wanted-rec_Start) < extr_Lim){
#        extr_Lim<-(wanted-rec_Start)
#      }
#      this_pull <- paste0(base_url,'query?where=OBJECTID%3E=0&f=pjson&returnCountOnly=false&returnGeometry=false&outFields=*&resultOffset=',rec_Start,'&resultRecordCount=',extr_Lim)
#      this_data <- jsonlite::fromJSON(this_pull)
#      if(i==1){    #first resultset, instantiate df
#        this.df=this_data$features$attributes
#      }else{       # add to existing df
#        this.df = rbind(this.df, this_data$features$attributes)
#      }
#      rec_Start = rec_Start+extr_Lim
#      Sys.sleep(0.1)
#      setTxtProgressBar(pb, i)
#    }
#    close(pb)
#    
#    names(this.df) = this_data$fields$alias
#    this.df$OBJECTID = NULL
#    elapsed=timer.start-proc.time() #determine runtime
#    cat(paste0('\nExtraction of ',nrow(this.df),' records completed in ',round(elapsed[3],0)*-1, ' seconds'))
#    if (save_csv){
#      filename = paste0(gsub(".*/","",service),'.csv')
#      write.csv(this.df,filename, row.names = FALSE)
#      cat(paste0("\ncsv written to ",getwd(), "/",filename))
#    }
#    return(this.df)
#  }
# 
# # now that get_DFO_REST() is written, use it to download and name the files. 
# # Change the host and service URLs if it has been updated/changed since the previous year. 
#  
# summerNew=get_DFO_REST(host = "https://gisp.dfo-mpo.gc.ca", service='FGP/ADAPT_Canada_Atlantic_Summer_2019_EN') 
# fallNew=get_DFO_REST(host = "https://gisp.dfo-mpo.gc.ca", service='FGP/ADAPT_Canada_Atlantic_Fall_2019_EN') 
# springNew=get_DFO_REST(host = "https://gisp.dfo-mpo.gc.ca", service='FGP/ADAPT_Canada_Atlantic_Spring_2019_EN') 
# 
# #Test=get_DFO_REST(host = "https://gisp.dfo-mpo.gc.ca", service='FGP/ADAPT_Canada_Atlantic_Summer_2019_EN') 


#additional scotian shelf data


# temp <- tempfile()
# save_loc <- "data_raw"
# save_date <- Sys.Date()
# file_name <- "SCOT_CATCH.csv"
# download.file("ftp://ftp.dfo-mpo.gc.ca/MarPED/RVSurvey_20201130.zip",temp)
# data <- load(unz(temp, "RV_Survey_20201130/RV.GSCAT.RData"))
# write_csv(GSCAT, here::here(save_loc, file_name))
# data <- load(unz(temp, "RV_Survey_20201130/RV.GSCAT.RData"))
# write_csv(GSCAT, here::here(save_loc, file_name))
# data <- load(unz(temp, "RV_Survey_20201130/RV.GSCAT.RData"))
# write_csv(GSCAT, here::here(save_loc, file_name))
