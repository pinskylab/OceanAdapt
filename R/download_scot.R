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
 get_DFO_REST <-function(host = "https://gisp.dfo-mpo.gc.ca", service='FGP/ADAPT_Canada_Atlantic_Summer_2016', save_csv=TRUE, n_rec = 0) {
   timer.start=proc.time() #start timing, for science!
   base_url= paste0(host,'/arcgis/rest/services/',service,'/MapServer/0/')
   extr_Lim = 1000 #can get this many at a time
   
   #total number of records available
   json_cnt_url <- paste0(base_url,'query?where=1=1&f=pjson&returnCountOnly=true')
   json_cnt <- jsonlite::fromJSON(json_cnt_url)
   if ('error' %in% names(json_cnt)) stop(paste0('\nSomething appears to be wrong with the selected service. Please try again later.
                                                 \nYou can try visiting the following url in your browser to see if there\'s any additional information:
                                                 \n',base_url))
   rec_Avail = json_cnt$count
   cat('\n',rec_Avail,' records available')
   if (n_rec==0){
     wanted = rec_Avail
     cat('\nStarting complete extraction')
   }else{
     wanted = n_rec
     cat('\nStarting extraction of first ',n_rec,' records')
   }
   
   pb = txtProgressBar(min=0,
                       max=ceiling(wanted/extr_Lim),
                       style = 3)
   rec_Start=0
   for (i in 1:ceiling(wanted/extr_Lim)){
     if ((wanted-rec_Start) < extr_Lim){
       extr_Lim<-(wanted-rec_Start)
     }
     this_pull <- paste0(base_url,'query?where=OBJECTID%3E=0&f=pjson&returnCountOnly=false&returnGeometry=false&outFields=*&resultOffset=',rec_Start,'&resultRecordCount=',extr_Lim)
     this_data <- jsonlite::fromJSON(this_pull)
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
   cat(paste0('\nExtraction of ',nrow(this.df),' records completed in ',round(elapsed[3],0)*-1, ' seconds'))
   if (save_csv){
     filename = paste0(gsub(".*/","",service),'.csv')
     write.csv(this.df,filename, row.names = FALSE)
     cat(paste0("\ncsv written to ",getwd(), "/",filename))
   }
   return(this.df)
 }

summerNew=get_DFO_REST(host = "https://gisp.dfo-mpo.gc.ca", service='FGP/ADAPT_Canada_Atlantic_Summer_2018_EN') 
fallNew=get_DFO_REST(host = "https://gisp.dfo-mpo.gc.ca", service='FGP/ADAPT_Canada_Atlantic_Fall_2018_EN') 
springNew=get_DFO_REST(host = "https://gisp.dfo-mpo.gc.ca", service='FGP/ADAPT_Canada_Atlantic_Spring_2018_EN') 
