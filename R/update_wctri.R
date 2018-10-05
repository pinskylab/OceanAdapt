# - Copy WCTRI ----
target <- paste0("data_raw/wctri/", params$date)
# list the directory at that file path
dir <- list.dirs(target)
# list the files within that directory
files <- list.files(dir)
full_files <- list.files(dir, full.names = T)

for (i in seq(files)){
  file.copy(from=full_files[i], to="data_updates/Data_Updated/", overwrite=TRUE)
}
print(paste0("completed wctri"))

