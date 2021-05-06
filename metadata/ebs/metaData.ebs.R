



library(EML)

# setwd("/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/metaData")
source("../../OceanAdapt/R/metadata/gen.cols&units.R")


# =============================================
# = Copy Example EBS Data from `trawl` Project =
# =============================================
# head() of ebs after merge
ebs.data <- structure(list(STRATUM = c("10", "10", "10", "10", "10", "10"
), LATITUDE = c(58.65167, 58.65167, 58.65167, 58.65167, 58.65167, 
58.65167), LONGITUDE = c(-164.65167, -164.65167, -164.65167, 
-164.65167, -164.65167, -164.65167), STATION = c("L-06", "L-06", 
"L-06", "L-06", "L-06", "L-06"), YEAR = c(1982L, 1982L, 1982L, 
1982L, 1982L, 1982L), DATETIME = c("06/14/1982 17:00", "06/14/1982 17:00", 
"06/14/1982 17:00", "06/14/1982 17:00", "06/14/1982 17:00", "06/14/1982 17:00"
), WTCPUE = c(4.7416, 0.6186, 0.3093, 0.4638, 0.5463, 0.8247), 
    NUMCPUE = c(2.727, NA, NA, NA, NA, NA), COMMON = c("walleye pollock", 
    "ridged crangon", "circumboreal toad crab", "hermit crab unident.", 
    "helmet crab", "red king crab"), SCIENTIFIC = c("Theragra chalcogramma", 
    "Crangon dalli", "Hyas coarctatus", "Paguridae", "Telmessus cheiragonus", 
    "Paralithodes camtschaticus"), SID = c(21740L, 66530L, 68577L, 
    69010L, 68781L, 69322L), BOT_DEPTH = c(40L, 40L, 40L, 40L, 
    40L, 40L), BOT_TEMP = c(1.5, 1.5, 1.5, 1.5, 1.5, 1.5), SURF_TEMP = c(3.6, 
    3.6, 3.6, 3.6, 3.6, 3.6), VESSEL = c(1L, 1L, 1L, 1L, 1L, 
    1L), CRUISE = c(198203L, 198203L, 198203L, 198203L, 198203L, 
    198203L), HAUL = c("49", "49", "49", "49", "49", "49"), Areakm2 = c(77871L, 
    77871L, 77871L, 77871L, 77871L, 77871L)), .Names = c("STRATUM", 
"LATITUDE", "LONGITUDE", "STATION", "YEAR", "DATETIME", "WTCPUE", 
"NUMCPUE", "COMMON", "SCIENTIFIC", "SID", "BOT_DEPTH", "BOT_TEMP", 
"SURF_TEMP", "VESSEL", "CRUISE", "HAUL", "Areakm2"), class = "data.frame", row.names = c(NA, 
-6L))



# =====================
# = Define ebs columns =
# =====================
ebs.cols <- c(
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
# = Define ebs units =
# ===================
ebs.units <- list(
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
# = Define ebs metadata components =
# =================================


# <title>
	# character vector title
	dataTitle <- "Eastern Berring Sea bottom trawl survey"

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
	contact <- as(as.person("Bob Lauth <Bob.Lauth@noaa.gov>"), "contact")
	# add the organization to each human
	contact@organizationName <- afsc.name
	contact@address <- afsc_address
	

# <metadataProvider>
	metadataProvider <- c(as(as.person("Ryan Batt <battrd@gmail.com>"), "metadataProvider"))

# <associatedParty>
	associatedParty <- c(as(as.person("Wayne Palsson [ctb] <Wayne.Palsson@noaa.gov>"), "associatedParty"))
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
		dat=ebs.data,
		name="ebs",
		col.defs=ebs.cols,
		unit.defs=ebs.units
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
eml_write(eml, file="metaData_EBS.xml")
