# Set the working directory to the top level of the repository (e.g., OceanAdapt/)

# dir.create("OAUpdate")
# file.copy("R","OAUpdate", recursive=TRUE)
# file.copy("complete_r_script.R", "OAUpdate")


zipFiles <- file.info(list.files("data_updates", full=TRUE, patt="^Data_.+.zip"))
recentZip <- row.names(zipFiles[order(zipFiles$mtime, zipFiles$ctime, zipFiles$atime, decreasing=TRUE)[1],])

# dir.create("OAUpdate/data_updates")
# file.copy(recentZip, "OAUpdate/data_updates", recursive=TRUE)

# zip("OAUpdate", files=list.files(basename("OAUpdate"),full=TRUE))
zip("OAUpdate", files=c("R","complete_r_script.R",recentZip))

# unlink("OAUpdate", recursive=TRUE)
