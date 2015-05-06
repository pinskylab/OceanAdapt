
library(EML)

# setwd("/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/metaData")


# =============================================
# = Copy Example GOA Data from `trawl` Project =
# =============================================
# head() of goa after merge
goa.data <- structure(list(STRATUM = c("10", "10", "10", "10", "10", "10"
), LATITUDE = c(54.00767, 54.00767, 54.00767, 54.00767, 54.00767, 
54.00767), LONGITUDE = c(-165.42167, -165.42167, -165.42167, 
-165.42167, -165.42167, -165.42167), STATION = c("55-41", "55-41", 
"55-41", "55-41", "55-41", "55-41"), YEAR = c(1984L, 1984L, 1984L, 
1984L, 1984L, 1984L), DATETIME = c("07/13/1984 14:00", "07/13/1984 14:00", 
"07/13/1984 14:00", "07/13/1984 14:00", "07/13/1984 14:00", "07/13/1984 14:00"
), WTCPUE = c(4.8096, 7.8754, 0.1058, 0.1585, 26.2158, 0.0529
), NUMCPUE = c(1.8644, 17.2456, 0.4661, 0.6991, 13.5168, NA), 
    COMMON = c("Pacific halibut", "arrowtooth flounder", "flathead sole", 
    "yellow Irish lord", "Pacific cod", "Oregon triton"), SCIENTIFIC = c("Hippoglossus stenolepis", 
    "Atheresthes stomias", "Hippoglossoides elassodon", "Hemilepidotus jordani", 
    "Gadus macrocephalus", "Fusitriton oregonensis"), SID = c(10120L, 
    10110L, 10130L, 21347L, 21720L, 72500L), BOT_DEPTH = c(84L, 
    84L, 84L, 84L, 84L, 84L), BOT_TEMP = c(6.2, 6.2, 6.2, 6.2, 
    6.2, 6.2), SURF_TEMP = c(7.2, 7.2, 7.2, 7.2, 7.2, 7.2), VESSEL = c(57L, 
    57L, 57L, 57L, 57L, 57L), CRUISE = c(198401L, 198401L, 198401L, 
    198401L, 198401L, 198401L), HAUL = c("106", "106", "106", 
    "106", "106", "106"), Areakm2 = c(8333L, 8333L, 8333L, 8333L, 
    8333L, 8333L)), .Names = c("STRATUM", "LATITUDE", "LONGITUDE", 
"STATION", "YEAR", "DATETIME", "WTCPUE", "NUMCPUE", "COMMON", 
"SCIENTIFIC", "SID", "BOT_DEPTH", "BOT_TEMP", "SURF_TEMP", "VESSEL", 
"CRUISE", "HAUL", "Areakm2"), class = "data.frame", row.names = c(NA, 
-6L))



# =====================
# = Define GOA columns =
# =====================
goa.cols <- c(
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
# = Define GOA units =
# ===================
goa.units <- list(
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
# = Define GOA metadata components =
# =================================


# <title>
	# character vector title
	dataTitle <- "Gulf of Alaska bottom trawl survey"

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
	contact <- as(as.person("Wayne Palsson <Wayne.Palsson@noaa.gov>"), "contact")
	# add the organization to each human
	contact@organizationName <- afsc.name
	contact@address <- afsc_address
	

# <metadataProvider>
	metadataProvider <- c(as(as.person("Ryan Batt <battrd@gmail.com>"), "metadataProvider"))

# <associatedParty>
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
goa.dataTable <- eml_dataTable(
		dat=goa.data,
		name="goa",
		col.defs=goa.cols,
		unit.defs=goa.units
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
    dataTable = c(goa.dataTable)
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
eml_write(eml, file="metaData_GOA.xml")