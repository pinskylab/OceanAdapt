#visit the following link to download .csv files survey (1970 to present):
https://open.canada.ca/data/en/dataset/1989de32-bc5d-c696-879c-54d422438e64
#double-click data download and copy/paste the URL into the url_catch line below


library(readr)
library("jsonlite")
cgulf_save_loc <- "data_raw"
save_date <- Sys.Date()
cgulf_file_name <- "cgulf.csv"
data <- read.csv("https://raw.githubusercontent.com/dfo-gulf-science/fgp-datasets/master/rv_survey/sGSL-September-RV-FGP.csv")
write_csv(data, here::here(cgulf_save_loc, cgulf_file_name))
rm(data, url, save_date, cgulf_file_name, cgulf_save_loc)

