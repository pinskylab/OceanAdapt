
library(EML)
library(emld)
library(tidyverse)

source("https://raw.githubusercontent.com/pinskylab/OceanAdapt/master/EML_metadata/00-scripts/gen-cols-units.R")

# =============================================
# = Copy Example AI Data from `trawl` Project =
# =============================================
# head() of ai after merge
ai.data <- structure(list(STRATUM = c(211L, 211L, 211L, 211L, 211L, 211L
), LATITUDE = c(53.07167, 53.07167, 53.07167, 53.07167, 53.07167, 
53.07167), LONGITUDE = c(172.83167, 172.83167, 172.83167, 172.83167, 
172.83167, 172.83167), STATION = c("38-48", "38-48", "38-48", 
"38-48", "38-48", "38-48"), YEAR = c(1983L, 1983L, 1983L, 1983L, 
1983L, 1983L), DATETIME = c("10/29/1983 23:00", "10/29/1983 23:00", 
"10/29/1983 23:00", "10/29/1983 23:00", "10/29/1983 23:00", "10/29/1983 23:00"
), WTCPUE = c(0.008, 0.1481, 0.1241, 14.7695, 0.008, 0.016), 
    NUMCPUE = c(0.0883, 0.0883, 0.4414, 7.6812, 0.0883, 1.7658
    ), COMMON = c("scissortail sculpin", "chum salmon", "flathead sole", 
    "great sculpin", "kelp greenling", "Pacific sand lance"), 
    SCIENTIFIC = c("Triglops forficata", "Oncorhynchus keta", 
    "Hippoglossoides elassodon", "Myoxocephalus polyacanthocephalus", 
    "Hexagrammos decagrammus", "Ammodytes hexapterus"), SID = c(21352L, 
    23235L, 10130L, 21370L, 21935L, 20202L), BOT_DEPTH = c(80L, 
    80L, 80L, 80L, 80L, 80L), BOT_TEMP = c(4.3, 4.3, 4.3, 4.3, 
    4.3, 4.3), SURF_TEMP = c(6.8, 6.8, 6.8, 6.8, 6.8, 6.8), VESSEL = c(554L, 
    554L, 554L, 554L, 554L, 554L), CRUISE = c(198301L, 198301L, 
    198301L, 198301L, 198301L, 198301L), HAUL = c("251        ", 
    "251      ", "251      ", "251     ", "251        ", "251      "
    ), Areakm2 = c(3693L, 3693L, 3693L, 3693L, 3693L, 3693L)), .Names = c("STRATUM", 
"LATITUDE", "LONGITUDE", "STATION", "YEAR", "DATETIME", "WTCPUE", 
"NUMCPUE", "COMMON", "SCIENTIFIC", "SID", "BOT_DEPTH", "BOT_TEMP", 
"SURF_TEMP", "VESSEL", "CRUISE", "HAUL", "Areakm2"), class = "data.frame", row.names = c(NA, 
-6L))


# ======
# = AI =
# ======
# =====================
# = Define AI columns =
# =====================
ai.cols <- c(
	"STRATUM" = gen.cols[["stratum"]],
	"LATITUDE" = gen.cols[["lat"]],
	"LONGITUDE" = gen.cols[["lon"]],
	"STATION" = gen.cols[["station"]],
	"YEAR" = gen.cols[["year"]],
	"DATETIME" = gen.cols[["datetime"]],
	"WTCPUE" = gen.cols[["wtcpue"]],
	"NUMCPUE" = gen.cols[["cntcpue"]],
	"COMMON" = gen.cols[["common"]],
	"SCIENTIFIC" = gen.cols[["spp"]],
	"SID" = gen.cols[["SID"]],
	"BOT_DEPTH" = gen.cols[["depth"]],
	"BOT_TEMP" = gen.cols[["btemp"]],
	"SURF_TEMP" = gen.cols[["stemp"]],
	"VESSEL" = gen.cols[["vessel"]],
	"CRUISE" = gen.cols[["cruise"]],
	"HAUL" = gen.cols[["haul"]],
	"Areakm2" = gen.cols[["stratumarea"]]
	
)

# ===================
# = Define AI units =
# ===================
ai.units <- list(
	"STRATUM" = c("unit" = "number"),
	"LATITUDE" = gen.units[["lat"]],
	"LONGITUDE" = gen.units[["lon"]],
	"STATION" = "station",
	"YEAR" = gen.units[["year"]],
	"DATETIME" = gen.units[["datetime"]],
	"WTCPUE" = gen.units[["wtcpue"]],
	"NUMCPUE" = gen.units[["cntcpue"]],
	"COMMON" = "common name",
	"SCIENTIFIC" = "Genus species",
	"SID" = "number",
	"BOT_DEPTH" = gen.units[["depth"]],
	"BOT_TEMP" = gen.units[["btemp"]],
	"SURF_TEMP" = gen.units[["stemp"]],
	"VESSEL" = c("unit" = "number"),
	"CRUISE" = c("unit" = "number"),
	"HAUL" = c("unit" = "number"),, # problem here is that the leading and trailing white space turn what should be an integer into a character
	"Areakm2" = gen.units[["stratumarea"]]
	
)

# define custom units
id <- c("kilograms per tow", "number per tow", "square kilometers")
dimension <- c("weight", "count", "area")
unitTypes <- data.frame(
  id = id, dimension = dimension, stringsAsFactors = FALSE
)
units <- data.frame(
  id = id, unitType = unitTypes, stringsAsFactors = FALSE
)

unitList <- set_unitList(units, unitTypes)


attributes <- tibble::tibble(attributeName = dput(names(ai.data)), attributeDefinition = ai.cols, formatString = NA, unit = ai.units) %>% 
  mutate(formatString = ifelse(attributeName == "YEAR", "YYYY", formatString), 
         formatString = ifelse(attributeName == "DATETIME", unit, formatString), 
         unit = ifelse(attributeName == "YEAR", NA, unit))

attributeList <- set_attributes(attributes, col_classes = c("numeric", "numeric", "numeric", "character", "Date", "Date", "numeric", "numeric", "character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))

# =================================
# = Define AI metadata components =
# =================================


# <title>
	# character vector title
	dataTitle <- "Aleutian Islands bottom trawl survey"

# <creator>
	# organization name
	afsc.name <- "National Oceanic and Atmospheric Administration (NOAA) Alaska Fisheries Science Center (AFSC) Resource Assessment and Conservation Engineering Division (RACE)"
	# create organization address
	afsc_address <- list( 
		deliveryPoint = "7600 Sand Point Way, N.E. bldg. 4",
		city = "Seattle",
		administrativeArea = "WA",
		postalCode = "98115",
		country = "USA"
	)
	
	publisher <- list(
	organizationName = afsc.name,
	address = afsc_address,
	onlineUrl = "http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm")

	R_person <- person(given = "Wayne", family = "Palsson", email = "Wayne.Palsson@noaa.gov", role = "cre")
	wayne <- as_emld(R_person)

	metadataProvider <- as_emld(person(given="Michelle", family = "Stuart",email = "michelle.stuart@rutgers.edu"))
	
others <- as.person("Bob Lauth [ctb] <Bob.Lauth@noaa.gov>")
associatedParty <- as_emld(others)
associatedParty[[1]]$organizationName <- afsc.name
	
# <pubDate>
pubDate <- "2012"

# <intellectualRights>
	# IR <- "this is just a long piece of text"

# <abstract>
abstract <- "The Resource Assessment and Conservation Engineering Division (RACE) of the Alaska Fisheries Science Center (AFSC) conducts bottom trawl surveys to monitor the condition of the demersal fish and crab stocks of Alaska. These data include catch per unit effort for each identified species at a standard set of stations. This is a subset of the main racebase datase. Excluded are non standard stations, earlier years using different gear, and other types of data collected other than species id, species weight, water temperature and depth."

# This isn't working right now
# # <methods>
# 	methods <- 	list(dataSource="http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm",
# 				description="http://www.afsc.noaa.gov/RACE/groundfish/survey_data/metadata_template.php?fname=RACEweb.xml"
# 			) 
# 	set_methods(methods)

	

# ======================
# = Create EML Objects =
# ======================

ai.data <- set_physical("ai_354fd2.csv")
attributes <- attributeList
# Create "dataTable": the physical data set with associated column definitions and units
ai.dataTable <- list(
		physial=ai.data,
		entityName="ai",
		entityDescription = "Bottom Trawl Data in the Aleutian Islands",
		col.defs=ai.cols,
		unit.defs=ai.units
)

# Create "dataset": adds the other metadata to the annotated data
dataset <- list(
    title = dataTitle,
    creator = wayne,
    publisher = publisher,
    contact = wayne,
    # intellectualRights = rights,
    abstract = abstract,
    # keywordSet = keys,
    # coverage = coverage,
    # methods = methods,
    additionalMetadata = list(metadata = list(unitList = unitList)),
    dataTable = c(ai.dataTable)
)


# Create "eml": the full/ final EML object
eml <- list(
    packageId = uuid::UUIDgenerate(),
    system = "uuid", # type of identifier
    dataset = dataset#,
    # additionalMetadata = additionalMetadata
)

# validate
eml_validate(eml)

# Write EML data file
write_eml(eml, file=here::here("EML_metadata", "ai","metaData_AI.xml"))

          
