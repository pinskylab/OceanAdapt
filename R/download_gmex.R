# Visit the [Gulf of Mexico]("https://seamap.gsmfc.org/") website
# Click "Download" the SEAMAP Trawl/Plankton, Bottom Longline
# Fill in the form ("Scientific Research", "Educational Institution", "Trawl/Plankton Data (CSV)"
# Unzip the CSV in your downloads folder
# then copy them into the data_raw folder with the script below

file.copy(from = "~/Downloads/public_seamap_csvs/BGSREC.csv", to = "data_raw/gmex_BGSREC.csv", overwrite = T)
file.copy(from = "~/Downloads/public_seamap_csvs/CRUISES.csv", to = "data_raw/gmex_CRUISES.csv", overwrite = T)
file.copy(from = "~/Downloads/public_seamap_csvs/NEWBIOCODESBIG.csv", to = "data_raw/gmex_NEWBIOCODESBIG.csv", overwrite = T)
file.copy(from = "~/Downloads/public_seamap_csvs/STAREC.csv", to = "data_raw/gmex_STAREC.csv", overwrite = T)
file.copy(from = "~/Downloads/public_seamap_csvs/INVREC.csv", to = "data_raw/gmex_INVREC.csv", overwrite = T)

