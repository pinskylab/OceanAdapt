
library(EML)

# setwd("/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/metaData")


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
	"HAUL" = "haul number", # problem here is that the leading and trailing white space turn what shoudl be an integer into a character
	"Areakm2" = gen.units[["stratumarea"]]
	
)







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
	afsc_address <- new(
		"address", 
		deliveryPoint = "7600 Sand Point Way, N.E. bldg. 4",
		city = "Seattle",
		administrativeArea = "WA",
		postalCode = "98115",
		country = "USA"
	)
	creator <- c(as("", "creator"))
	creator[[1]]@organizationName <- afsc.name
	creator[[1]]@address <- afsc_address
	creator[[1]]@onlineUrl <- "http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm"

# <contact>
	# as(as.person("First Last <email@address.com>"), "creator")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
	
	# example w/ multiple contacts, taken from AI
	contact <- as(as.person("Wayne Palsson <Wayne.Palsson@noaa.gov>"), "contact")
	# add the organization to each human
	contact@organizationName <- afsc.name
	contact@address <- afsc_address
	

# <metadataProvider>
	# as(as.person("First Last <email@address.com>"), "metadataProvider")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
	metadataProvider <- c(as(as.person("Ryan Batt <battrd@gmail.com>"), "metadataProvider"))

# <associatedParty>
	# as(as.person("First Last <email@address.com>"), "associatedParty")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
	associatedParty <- c(as(as.person("Bob Lauth [ctb] <Bob.Lauth@noaa.gov>"), "associatedParty"))
	associatedParty[[1]]@organizationName <- afsc.name
	
# <pubDate>
	pubDate <- "2012"

# <intellectualRights>
	# IR <- "this is just a long piece of text"

# <abstract>
	abstract <- "The Resource Assessment and Conservation Engineering Division (RACE) of the Alaska Fisheries Science Center (AFSC) conducts bottom trawl surveys to monitor the condition of the demersal fish and crab stocks of Alaska. These data include catch per unit effort for each identified species at a standard set of stations. This is a subset of the main racebase datase. Excluded are non standard stations, earlier years using different gear, and other types of data collected other than species id, species weight, water temperature and depth."

# <keywordSet>
	# eml_keyword(list(
	# 		"LTER controlled vocabulary" = c("bacteria", "carnivorous plants", "genetics", "thresholds"),
	# 		"LTER core area" = c("populations", "inorganic nutrients", "disturbance")
	# 		"HFR default" = c("Harvard Forest", "HFR", "LTER", "USA")
	# ))

# <coverage>
	# eml_coverage(
	# 	scientific_names = ,
	# 	dates = ,
	# 	geographic_description = ,
	# 	NSEWbox = c(lat, lat, lon, lon)
	# )

# <methods>
	methods <- 	new(
		"methods",
		methodStep=c(
			new("methodStep",
				dataSource="http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm",
				description="http://www.afsc.noaa.gov/RACE/groundfish/survey_data/metadata_template.php?fname=RACEweb.xml"
			) # end new methodStep
		) # end c() of methodStep

	) # end new methods


# ======================
# = Create EML Objects =
# ======================
# Create "dataTable": the physical data set with associated column definitions and units
ai.dataTable <- eml_dataTable(
		dat=ai.data,
		name="ai",
		col.defs=ai.cols,
		unit.defs=ai.units
)

# Create "dataset": adds the other metadata to the annotated data
dataset <- new(
	"dataset", 
    title = dataTitle,
    creator = creator,
    contact = contact,
	metadataProvider = metadataProvider,
    pubDate = pubDate,
    # intellectualRights = rights,
    abstract = abstract,
    associatedParty = associatedParty,
    # keywordSet = keys,
    # coverage = coverage,
    methods = methods,
    dataTable = c(ai.dataTable)
)


# Create "eml": the full/ final EML object
eml <- new(
	"eml",
    packageId = uuid::UUIDgenerate(),
    system = "uuid", # type of identifier
    dataset = dataset#,
    # additionalMetadata = additionalMetadata
)


# Write EML data file
eml_write(eml, file="metaData_AI.xml")