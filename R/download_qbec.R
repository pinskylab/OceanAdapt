Visit the following link to download .csv files:

https://open.canada.ca/data/en/dataset/d4ec2d6b-f4bc-4c6c-b866-b26e507a3b76 # demersal GoSL link
https://open.canada.ca/data/en/dataset/f1fc359c-0ed1-4045-a421-adef2497b68d # pelagic GoSL link


#Demersal Gulf of St. Lawrence
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Teleost_Especes_Demersales_Abondance_2008-2017/Teleost_Especes_Demersales_Abondance_2008-2017.zip",temp)
file_name <- "GOSL_south_dem.csv"
data <- read.csv(unz(temp, "Abondance_Sud_2008a2017.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "GOSL_north_dem.csv"
data <- read.csv(unz(temp, "Abondance_Nord_2008a2017.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp)

#Pelagic Gulf of St. Lawrence
temp <- tempfile()
save_loc <- "data_raw"
save_date <- Sys.Date()
download.file("https://pacgis01.dfo-mpo.gc.ca/FGPPublic/Pelagic_fish_species_abondance_Teleost/Teleost_Especes_Pelagiques_Abondance_2009-2018.zip",temp)
file_name <- "GOSL_south_pel.csv"
data <- read.csv(unz(temp, "Abondance_Sud_2009a2018.csv"))
write_csv(data, here::here(save_loc, file_name))
file_name <- "GOSL_north_pel.csv"
data <- read.csv(unz(temp, "Abondance_Nord_2009a2018.csv"))
write_csv(data, here::here(save_loc, file_name))
unlink(temp)
