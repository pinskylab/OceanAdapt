# Calculate stratum area for strata that are not found in the original strata files

# Calculate stratum area for goa ####
missing <- goa %>% 
  filter(is.na(Areakm2)) %>% 
  select(STRATUM, LONGITUDE, LATITUDE) %>% 
  distinct()
# for every missing area, calculate the area based on observed lat lons
for(i in seq(missing$STRATUM)){
  temp <- missing %>% 
    filter(STRATUM == missing$STRATUM[i]) %>% 
    mutate(area = calcarea(as.numeric(LONGITUDE), as.numeric(LATITUDE)))
  goa <- goa %>% 
    mutate(Areakm2 = ifelse(STRATUM == missing$STRATUM[i], temp$area[1], Areakm2))
}
strata <- goa %>% 
  select(STRATUM, Areakm2) %>% 
  distinct() %>% 
  rename(StratumCode = STRATUM)

write_csv(strata, "data_raw/goa_strata_new.csv")

# Calculate stratum area for NEUS - takes 4+ minutes ####
missing <- neus %>% 
  ungroup() %>% 
  filter(is.na(Areanmi2)) %>% 
  select(STRATUM) %>% 
  distinct()
# for every missing area, calculate the area based on observed lat lons
Sys.time()
for(i in seq(missing$STRATUM)){
  temp <- neus %>% 
    ungroup() %>% 
    select(STRATUM, LAT, LON) %>% 
    filter(STRATUM == missing$STRATUM[i]) %>% 
    mutate(area = calcarea(as.numeric(LON), as.numeric(LAT)))
  neus <- neus %>% 
    mutate(Areanmi2 = ifelse(STRATUM == missing$STRATUM[i], temp$area[1], Areanmi2))
}
Sys.time()

strata <- neus %>% 
  ungroup() %>% 
  select(STRATUM, Areanmi2) %>% 
  distinct() %>% 
  rename(StratumCode = STRATUM)

write_csv(strata, "data_raw/neus_strata_new.csv")
