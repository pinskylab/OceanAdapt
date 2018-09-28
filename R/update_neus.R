neus_rdata_files 

# Load RData files
local({
  for(i in 1:length(neus_rdata_files)){
    load(neus_rdata_files[i])
  }
  rm(list='i')
  newNEUS <<- mget(ls())
  rm(list=ls())
})

# ---- process or copy survey file ----
if(neus_surv_rdata%in%basename(neus_rdata_files)){
  newNEUS_data <- copy(newNEUS$survdat)
  # Need to add a leading column named ""
  newNEUS_data <- data.table(X=NA, newNEUS_data)
  
  stopifnot(all(old_upData_colNames$neus_data.csv%in%names(newNEUS_data))) # upData$neus_data.csv
  updated_newNEUS_data <- newNEUS_data[,old_upData_colNames$neus_data.csv,with=FALSE]
  setnames(updated_newNEUS_data, "X", "\"\"") # rename the NA column as ""
  setnames(updated_newNEUS_data, names(updated_newNEUS_data)[-1], wrap.quotes(names(updated_newNEUS_data))[-1])
  cat("\tWriting",neus_surv_csv,"\n")
  write.csv(updated_newNEUS_data, file=file.path(new.zip.folder,neus_surv_csv), row.names=FALSE, quote=FALSE) 
}else{
  stopifnot(neus_surv_csv%in%basename(neus_csv_files))
  
}

# ---- process or copy spp file ----
if(neus_spp_rdata%in%basename(neus_rdata_files)){
  newNEUS_spp <- copy(newNEUS$spp)
  newNEUS_spp[,AUTHOR:=wrap.quotes(AUTHOR)]
  setnames(newNEUS_spp, names(newNEUS_spp), wrap.quotes(names(newNEUS_spp)))
  newNEUS_spp <- data.table(X=NA, newNEUS_spp)
  setnames(newNEUS_spp, "X", "\"\"")
  cat("\tWriting",neus_spp_csv,"\n")
  write.csv(newNEUS_spp, file=file.path(new.zip.folder,neus_spp_csv), row.names=FALSE, quote=FALSE)
}else{
  svspp_ind <- neus_spp_csv==basename(neus_csv_files)
  stopifnot(any(svspp_ind))
  cat("\tCopying",neus_spp_csv,"\n")
  result <- file.copy(from=neus_csv_files[svspp_ind], to=file.path(new.zip.folder, neus_spp_csv), overwrite=TRUE)
  if(result){cat("\tSuccessfully copied",neus_spp_csv,"\n")}else{cat("\tFailed to copy",neus_spp_csv,"\n")}
}

# ---- process or copy strata file ----
if(neus_strata_rdata%in%basename(neus_rdata_files)){
  # I don't have a .RData file for the strata
}else{
  strata_ind <- neus_strata_csv==basename(neus_csv_files)
  stopifnot(any(strata_ind))
  cat("\tCopying",neus_strata_csv,"\n")
  result <- file.copy(from=neus_csv_files[strata_ind], to=file.path(new.zip.folder, neus_strata_csv), overwrite=TRUE)
  if(result){cat("\tSuccessfully copied",neus_strata_csv,"\n")}else{cat("\tFailed to copy",neus_strata_csv,"\n")}
}

}
