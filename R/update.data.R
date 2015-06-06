

library(data.table)

# =============
# = Update AI =
# =============
# this approach prevents adding duplicate rows either by using write.csv(..., append=TRUE), or by rbind() on something that's already been updated
oldAI <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/ai_data.csv")
newAI <- as.data.table(read.csv("~/Downloads/ai2014.csv")) # had to use read.csv to auto remove whitespace in col names
updatedAI0 <- rbind(oldAI, newAI)
updatedAI <- as.data.table(updatedAI0)
setkeyv(updatedAI, names(updatedAI))
updatedAI <- unique(updatedAI)
write.csv(updatedAI, file="~/Documents/School&Work/pinskyPost/OceanAdapt/ai_data.csv", row.names=FALSE)



# ==============
# = Update EBS =
# ==============
oldEBS <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/ebs_data.csv")
newEBS <- as.data.table(read.csv("~/Downloads/ebs201_20143.csv")) # had to use read.csv to auto remove whitespace in col names
updatedEBS0 <- rbind(oldEBS, newEBS)
updatedEBS <- as.data.table(updatedEBS0)
setkeyv(updatedEBS, names(updatedEBS))
updatedEBS <- unique(updatedEBS)
write.csv(updatedEBS, file="~/Documents/School&Work/pinskyPost/OceanAdapt/ebs_data.csv", row.names=FALSE)


# ==============
# = Update GOA =
# ==============
# As of 5-June-2015, GOA doesn't have any new data (new meaning 2014)
# skip for now




# ===============
# = Update WFSC =
# ===============
# oldWC.fish <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/wcann_fish.csv", colClasses=c("character","character","numeric","numeric"))
# newWC <- as.data.table(read.csv("~/Downloads/wcann201_20143.csv")) # had to use read.csv to auto remove whitespace in col names
# updatedWC0 <- rbind(oldWC, newWC)
# updatedWC <- as.data.table(updatedWC0)
# setkeyv(updatedWC, names(updatedWC))
# updatedWC <- unique(updatedWC)
# write.csv(updatedWC, file="~/Documents/School&Work/pinskyPost/OceanAdapt/wcann_data.csv", row.names=FALSE)


# ===============
# = Update GMEX =
# ===============
# bio
newGMEX.bio0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/BGSREC.csv"))
oldGMEX.bio <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_bio.csv")
# any(!names(oldGMEX.bio)%in%names(newGMEX.bio0)) # FALSE good
gmex.bio.names <- names(oldGMEX.bio)
newGMEX.bio <- newGMEX.bio0[,(gmex.bio.names), with=FALSE]
write.csv(newGMEX.bio, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_bio.csv", row.names=FALSE)

# cruise
newGMEX.cruise0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/CRUISES.csv"))
oldGMEX.cruise <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_cruise.csv")
# any(!names(oldGMEX.bio)%in%names(newGMEX.bio0)) # FALSE good
gmex.cruise.names <- names(oldGMEX.cruise)
oldGMEX.cruise <- newGMEX.cruise0[,(gmex.cruise.names), with=FALSE]
write.csv(oldGMEX.cruise, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_cruise.csv", row.names=FALSE)

# spp
newGMEX.spp0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/NEWBIOCODESBIG.csv"))
oldGMEX.spp <- fread("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_spp.csv")
# any(!names(oldGMEX.spp)%in%names(newGMEX.spp0)) # FALSE good
gmex.spp.names <- names(oldGMEX.spp)
oldGMEX.spp <- newGMEX.spp0[,(gmex.spp.names), with=FALSE]
write.csv(oldGMEX.spp, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_spp.csv", row.names=FALSE)

# station
newGMEX.station0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/STAREC.csv")) # had to open .csv in excel, resave as a csv. Did nothing else, then worked.
oldGMEX.station <- as.data.table(read.csv("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_station.csv"))
# any(!names(oldGMEX.station)%in%names(newGMEX.station0)) # FALSE good
gmex.station.names <- names(oldGMEX.station)
oldGMEX.station <- newGMEX.station0[,(gmex.station.names), with=FALSE]
write.csv(oldGMEX.station, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_station.csv", row.names=FALSE)

# tow
newGMEX.tow0 <- as.data.table(read.csv("~/Downloads/public_seamap_csvs/INVREC.csv"))
oldGMEX.tow <- as.data.table(read.csv("~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_tow.csv"))
# any(!names(oldGMEX.tow)%in%names(newGMEX.tow0)) # FALSE good
gmex.tow.names <- names(oldGMEX.tow)
oldGMEX.tow <- newGMEX.tow0[,(gmex.tow.names), with=FALSE]
write.csv(oldGMEX.tow, file="~/Documents/School&Work/pinskyPost/OceanAdapt/gmex_tow.csv", row.names=FALSE)

