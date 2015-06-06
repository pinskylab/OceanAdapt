

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

