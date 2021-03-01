install.packages('finch')
library(finch)
library(readr)
library("jsonlite")

#Visit the following website to download data as a DwC-A file, metadata also in link:
 # http://ipt.iobis.org/obiscanada/redatasource?r=obis_dfo_cna_multispeciessurveys


temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
file_name <- "CCA.csv"
data <- dwca_read("http://ipt.iobis.org/obiscanada/archive.do?r=obis_dfo_cna_multispeciessurveys&v=4.2")  
data <- read_delim(data$data, '\t')
write_csv(data, here::here(save_loc, file_name))
