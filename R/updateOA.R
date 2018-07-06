# This is a script to package the data to be uploaded to the website

# Set the working directory to the top level of the repository (e.g., OceanAdapt/)

# get file info (times created, updated) for a list of all of the zip files in the data_updates directory
zipFiles <- file.info(list.files("data_updates", full=TRUE, patt="^Data_.+.zip"))

# choose the most recent one
recentZip <- row.names(zipFiles[order(zipFiles$mtime, zipFiles$ctime, zipFiles$atime, decreasing=TRUE)[1],])

# make a zip file that holds all the info that needs to be sent to the website
zip("Data_Updated", files=c("R","complete_r_script.R",recentZip))
