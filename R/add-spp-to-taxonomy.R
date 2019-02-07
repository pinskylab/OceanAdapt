# This script is intended to be used when the test after trimmed_dat (line 1973 of the compile.R script) produces rows of spp that are not found in the spptaxonomy.csv

# because this is meant to be used in that case, test should already exist in your environment as well as trimmed_dat and tax.

# create columns in our test data to simplify matching genus and species
need_common <- test %>% 
  mutate(taxon = spp) %>% 
  separate(spp, into = c("genus", "species", "other1", "other2", "other3"), sep = " ") %>% 
  mutate(genus = str_to_title(genus), 
         species = str_to_lower(species))

# add fish by genus and species -------------------------------------------
# find common names for the test table
fish <- rfishbase::fishbase
names(fish) <- str_to_lower(names(fish))

# see what matches
common_fish <- left_join(need_common, fish, by = c("genus", "species")) %>% 
  filter(!is.na(fbname)) %>% 
  mutate(common = fbname,
         superclass = NA, 
         subphylum = NA, 
         phylum = NA, 
         kingdom = NA, 
         name = ifelse(!is.na(species), paste(genus, species, sep = " "), genus)) %>% 
  select(taxon, species, genus, family, order, class, superclass, subphylum, phylum, kingdom, name, common)

# add to spptaxonomy.csv
write_csv(common_fish, here("data_raw", "spptaxonomy.csv"), append = TRUE)

# remove the fish from the list of need
need_common <- anti_join(need_common, common_fish, by = "taxon")

# Check for inverts and other critters ----------------------------------
sealife <- rfishbase::sealifebase
names(sealife) <- str_to_lower(names(sealife))
  
# see what matches
common_life <- left_join(need_common, sealife, by = c("genus", "species")) %>% 
  filter(!is.na(fbname)) %>% 
  mutate(common = fbname,
         superclass = NA, 
         subphylum = NA, 
         phylum = NA, 
         kingdom = NA, 
         name = ifelse(!is.na(species), paste(genus, species, sep = " "), genus)) %>% 
  select(taxon, species, genus, family, order, class, superclass, subphylum, phylum, kingdom, name, common)

# add to spptaxonomy.csv
write_csv(common_life, here("data_raw", "spptaxonomy.csv"), append = TRUE)

# remove the fish from the list of need
need_common <- anti_join(need_common, common_life, by = "taxon")
  
# Check by just genus ---------------------------------------------

fish_genus <- left_join(need_common, fish, by = "genus") 

# type-os become apparent here
fish_genus <- fish_genus %>%
  filter(substr(species.x, 1, 5) == substr(species.y, 1, 5)) %>% 
  mutate(common = ifelse(genus == "Clupea", "herring", common)) %>% 
  mutate(species.x = ifelse(is.na(common), species.y, species.x), 
         common = fbname)%>% 
  rename(species = species.x) %>% 
  filter(!is.na(fbname)) %>% 
  mutate(superclass = NA, 
         subphylum = NA, 
         phylum = NA, 
         kingdom = NA, 
         name = ifelse(!is.na(species), paste(genus, species, sep = " "), genus)) %>% 
  select(taxon, species, genus, family, order, class, superclass, subphylum, phylum, kingdom, name, common) %>% 
  filter(!grepl("Chosa", common), 
         !grepl("White Sea herring", common))

# add to spptaxonomy.csv
write_csv(fish_genus, here("data_raw", "spptaxonomy.csv"), append = TRUE)

# remove the fish from the list of need
need_common <- anti_join(need_common, fish_genus, by = "taxon")

# Check inverts by genus ------------------------------------------------
life_genus <- left_join(need_common, sealife, by = "genus") 

# type-os become apparent here
life_genus <- life_genus %>%
  filter(substr(species.x, 1, 6) == substr(species.y, 1, 6)) %>% 
  select(-species.x, -common) %>% 
  rename(species = species.y, 
         common = fbname) %>% 
  filter(!is.na(common)) %>% 
  mutate(superclass = NA, 
         subphylum = NA, 
         phylum = NA, 
         kingdom = NA, 
         name = ifelse(!is.na(species), paste(genus, species, sep = " "), genus)) %>% 
  select(taxon, species, genus, family, order, class, superclass, subphylum, phylum, kingdom, name, common)

# add to spptaxonomy.csv
write_csv(life_genus, here("data_raw", "spptaxonomy.csv"), append = TRUE)

# remove the fish from the list of need
need_common <- anti_join(need_common, life_genus, by = "taxon")

# cleanup
rm(common, common_fish, common_life, common1, dup_codes, dups, fish_genus, life_genus, missing, need_fish, need_life, test1, test2, thing)
rm(x, get_common_script)

# Check fish by species ------------------------------------------------
fish_spp <- left_join(need_common, fish, by = "species") 

fish_spp <- fish_spp %>%
  filter(substr(genus.x, 1, 6) == substr(genus.y, 1, 6)) 
# none of these have an FBname

life_spp <- left_join(need_common, sealife, by = "species") 

life_spp <- life_spp %>%
  filter(substr(genus.x, 1, 6) == substr(genus.y, 1, 6)) 
# none of these have an FBname

# a lot of these are just genus names with no species.  Many don't have common names in fish base or sealife base.  


need_common <- need_common %>% 
  mutate(name = ifelse(!is.na(species), paste(genus, species, sep = " "), genus)) %>% 
  mutate(superclass = NA, 
         subphylum = NA, 
         phylum = NA, 
         kingdom = NA, 
         order = NA, 
         class = NA, 
         family = NA) %>% 
  select(taxon, species, genus, family, order, class, superclass, subphylum, phylum, kingdom, name, common)

write_csv(need_common, here("data_raw", "spptaxonomy.csv"), append = TRUE)
