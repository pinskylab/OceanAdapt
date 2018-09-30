# = Function to Wrap in Quotes =====
wrap.quotes <- function(x){gsub("(.+)", "\"\\1\"", x)}

# Update neus ====
target <- paste0("data_raw/neus/", params$date)
# list the directory at that file path
dir <- list.dirs(target)
# list the files within that directory
files <- list.files(dir, full.names = T)

for (i in seq(files)){
  if (grepl("Survdat", files[i])){
    load(files[i])
  }
  if (grepl("SVSPP", files[i])){
    load(files[i])
  }
  if (grepl("strata", files[i])){
    file.copy(from=files[i], to=file.path("data_updates/Data_Updated/"), overwrite=TRUE)
  }
  if (grepl("svspp", files[i])){
    file.copy(from=files[i], to=file.path("data_updates/Data_Updated/"), overwrite=TRUE)
  }
}

# ---- process or copy survey and spp files ----

  # Need to add a leading column named ""
survdat <- survdat %>% 
  mutate(X = NA) %>% 
  select(X, CRUISE6, STATION, STRATUM, SVSPP, CATCHSEX, SVVESSEL, YEAR, SEASON, LAT, LON, DEPTH, SURFTEMP, SURFSALIN, BOTTEMP, BOTSALIN, ABUNDANCE, BIOMASS, LENGTH, NUMLEN)

# # rename the X-NA column as ""
# setnames(survdat, "X", "\"\"") 
# # wrap all column names in quotes
# setnames(survdat, names(survdat)[-1], wrap.quotes(names(survdat))[-1])

readr::write_csv(survdat, path = "data_updates/Data_Updated/neus_data.csv")


# repeat for spp file ----
spp <- spp %>%
  # add a leading column 
  mutate(X = NA) %>% 
  select(X, everything())

# # rename the X-NA column as ""
# setnames(spp, "X", "\"\"") 
# # wrap all column names in quotes
# setnames(spp, names(spp), wrap.quotes(names(spp)))

readr::write_csv(spp, path = paste0("data_updates/Data_Updated/neus_svspp.csv"))


print(paste0("completed neus"))
