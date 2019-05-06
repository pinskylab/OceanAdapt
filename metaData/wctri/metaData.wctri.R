
library(EML)

# setwd("/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/metaData")
source("../../OceanAdapt/R/metadata/gen.cols&units.R")



wctri.data <- structure(list(SPECIES_CODE = c(2L, 2L, 2L, 3L, 3L, 3L), CRUISEJOIN = c(406L, 
406L, 433L, 433L, 852418L, 929471L), HAULJOIN = c(40780L, 40795L, 
43689L, 43681L, 839969L, 929516L), VESSEL = c(19L, 19L, 39L, 
39L, 94L, 94L), CRUISE = c(198601L, 198601L, 198301L, 198301L, 
199501L, 199802L), HAUL = c(205L, 220L, 195L, 187L, 7L, 254L), 
    CATCHJOIN = c(690632L, 690900L, 735220L, 735022L, 844562L, 
    930660L), WEIGHT = c(0.09, 0.04, 0.04, 0.09, 0.05, 0), NUMBER_FISH = c(69L, 
    200L, 4L, 1L, 1L, 2L), HAUL_TYPE = c(3L, 3L, 3L, 3L, 3L, 
    3L), PERFORMANCE = c(0, 0, 0, 0, 0, 0), START_TIME = c("8/23/1986 15:00:00", 
    "8/25/1986 14:00:00", "8/31/1983 10:00:00", "8/29/1983 17:00:00", 
    "6/10/1995 10:08:00", "8/7/1998 10:30:00"), DURATION = c(0.5, 
    0.5, 0.5, 0.5, 0.5, 0.52), DISTANCE_FISHED = c(2.92, 2.61, 
    2.57, 3.18, 2.75, 2.96), NET_WIDTH = c(13.5, 13.8, 13.44, 
    13.44, 13.34, 15.06), STRATUM = c(52L, 52L, 8L, 48L, 10L, 
    29L), START_LATITUDE = c(47.18, 47.27, 46.78, 46.46, 34.71, 
    49.06), END_LATITUDE = c(47.15, 47.29, 46.76, 46.49, 34.74, 
    49.08), START_LONGITUDE = c(-124.83, -124.75, -124.46, -124.52, 
    -120.74, -126.86), END_LONGITUDE = c(-124.83, -124.73, -124.46, 
    -124.51, -120.74, -126.88), STATIONID = c("", "", "", "", 
    " 0003a", "116i"), BOTTOM_DEPTH = c(148L, 141L, 90L, 251L, 
    75L, 283L), SURFACE_TEMPERATURE = c(17.6, 15.3, 16.4, 16.5, 
    11.9, 15.1), GEAR_TEMPERATURE = c(6.8, 6.9, NA, NA, NA, 6
    ), SPECIES_NAME = c("", "", "", "", "", ""), COMMON_NAME = c("fish larvae unident.", 
    "fish larvae unident.", "fish larvae unident.", "fish unident.", 
    "fish unident.", "fish unident.")), .Names = c("SPECIES_CODE", 
"CRUISEJOIN", "HAULJOIN", "VESSEL", "CRUISE", "HAUL", "CATCHJOIN", 
"WEIGHT", "NUMBER_FISH", "HAUL_TYPE", "PERFORMANCE", "START_TIME", 
"DURATION", "DISTANCE_FISHED", "NET_WIDTH", "STRATUM", "START_LATITUDE", 
"END_LATITUDE", "START_LONGITUDE", "END_LONGITUDE", "STATIONID", 
"BOTTOM_DEPTH", "SURFACE_TEMPERATURE", "GEAR_TEMPERATURE", "SPECIES_NAME", 
"COMMON_NAME"), class = "data.frame", row.names = c(NA, -6L))


wctri.data[,"HAUL_TYPE"] <- as.character(wctri.data[,"HAUL_TYPE"])
wctri.data[,"PERFORMANCE"] <- as.character(wctri.data[,"PERFORMANCE"])


# ===============================
# = Column and Unit Definitions =
# ===============================


wctri.cols <- c(
	"SPECIES_CODE" = gen.cols[["SID"]], # no unit
	"CRUISEJOIN" = gen.cols[["cruise"]], # no unit
	"HAULJOIN" = gen.cols[["haul"]], # no unit
	"VESSEL" = gen.cols[["vessel"]], # no unit
	"CRUISE"= gen.cols[["cruise"]], # no unit
	"HAUL" = gen.cols[["haul"]], # no unit; note that it's somewhat different from 'hauljoin', but it's just one is to join and the other is ...
	"CATCHJOIN" = "database id for the catch record",
	"WEIGHT" = gen.cols[["weight"]],
	"NUMBER_FISH" = gen.cols[["cnt"]],
	"HAUL_TYPE" = "type of haul",
	"PERFORMANCE" = "performance code of the haul",
	"START_TIME" = gen.cols[["time"]],
	"DURATION" = gen.cols[["duration"]], # hours?
	"DISTANCE_FISHED" = "distance fished", # in km
	"NET_WIDTH" = gen.cols[["gearsize"]], # m?
	"STRATUM" = gen.cols[["stratum"]],
	"START_LATITUDE" = "latitude  at the start of the haul",
	"END_LATITUDE" = "latitude  at the end of the haul",
	"START_LONGITUDE" = "longitude  at the start of the haul",
	"END_LONGITUDE" = "longitude at the end of the haul",
	"STATIONID" = gen.cols[["station"]], # no unit
	"BOTTOM_DEPTH" = gen.cols[["depth"]],
	"SURFACE_TEMPERATURE" = gen.cols[["stemp"]],
	"GEAR_TEMPERATURE" = gen.cols[["btemp"]],
	"SPECIES_NAME" = gen.cols[["spp"]],
	"COMMON_NAME" = gen.cols[["common"]]
)


wctri.units <- list(
	"SPECIES_CODE" = c(unit="number"),
	"CRUISEJOIN" = c(unit="number"),
	"HAULJOIN" = c(unit="number"),
	"VESSEL" = c(unit="number"),
	"CRUISE"= c(unit="number"),
	"HAUL" = c(unit="number"),
	"CATCHJOIN" = c(unit="number"),
	"WEIGHT" = gen.units[["weight"]],
	"NUMBER_FISH" = gen.units[["cnt"]],
	"HAUL_TYPE" = c(
		"0"="opportunistic",
		"1"="off-bottom",
		"3"="standard bottom sample",
		"4" = "fishing power comparative sample"
	),
	"PERFORMANCE" = c(
		"0"="good",
		"positive"="satisfactory",
		"negative"="unsatisfactory"
	),
	"START_TIME" = gen.units[["time"]],
	"DURATION" = c(units="hour"), # hours?
	"DISTANCE_FISHED" = c(units="kilometer"), # in km
	"NET_WIDTH" = c(units="meter"), # m?
	"STRATUM" = c(units="number"),
	"START_LATITUDE" = gen.units[["lat"]],
	"END_LATITUDE" = gen.units[["lat"]],
	"START_LONGITUDE" = gen.units[["lon"]],
	"END_LONGITUDE" = gen.units[["lon"]],
	"STATIONID" = c(unit="number"),
	"BOTTOM_DEPTH" = gen.units[["depth"]],
	"SURFACE_TEMPERATURE" = gen.units[["stemp"]],
	"GEAR_TEMPERATURE" = gen.units[["btemp"]],
	"SPECIES_NAME" = gen.units[["spp"]],
	"COMMON_NAME" = gen.units[["common"]]
)


# =============================
# = Name Meta Data Components =
# =============================

# <title>
	# character vector title
	dataTitle <- "West Coast Triennial bottom trawl survey"

# <creator>
	# as(as.person("First Last <email@address.com>"), "creator")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
	# organization name
	wctri.name <- "National Oceanic and Atmospheric Administration (NOAA) Alaska Fisheries Science Center (AFSC)"
	# create organization address
	wctri_address <- new(
		"address", 
		deliveryPoint = "7600 Sand Point Way, N.E. bldg. 4",
		city = "Seattle",
		administrativeArea = "WA",
		postalCode = "98115",
		country = "USA"
	)
	creator <- c(as("", "creator"))
	creator[[1]]@organizationName <- wctri.name
	creator[[1]]@address <- wctri_address
	creator[[1]]@onlineUrl <- "http://www.afsc.noaa.gov"

# <contact>
	# as(as.person("First Last <email@address.com>"), "contact")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
	
	# example, taken from AI
	contact <- as(as.person("Bob Lauth <Bob.Lauth@noaa.gov>"), "contact")
	# add the organization info
	contact@organizationName <- wctri.name
	contact@address <- wctri_address
	

# <metadataProvider>
	# c(as(as.person("First Last <email@address.com>"), "metadataProvider"))
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
	
	# example, from AI; note that you need something in the [] in the as.person() text (it's the person's role, I think this can be anything)
	associatedParty <- c(as(as.person("Mark Wilkins [ctb] <Mark.Wilkins@noaa.gov>"), "associatedParty"))
	associatedParty[[1]]@organizationName <- wctri.name
	
	
# <pubDate>
	pubDate <- "2004"

# <intellectualRights>
	# IR <- "this is just a long piece of text"

# <abstract>
	# abstract <- "another long piece "

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
	# new("methods",
	# 	methodStep=c(
	# 		new("methodStep",
	# 			dataSource=character(0),
	# 			description=character(0),
	# 			citation=new("ListOfcitation", list()),
	# 			instrumentation=character(0)
	# 		) # end new methodStep
	# 	) # end c() of methodStep
	#
	# ) # end new methods





# ======================
# = Create EML Objects =
# ======================
# Create "dataTable": the physical data set with associated column definitions and units
wctri.dataTable <- eml_dataTable(
		dat=wctri.data,
		name="wctri",
		col.defs=wctri.cols,
		unit.defs=wctri.units
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
    # abstract = abstract,
    associatedParty = associatedParty,
    # keywordSet = keys,
    # coverage = coverage,
    # methods = methods,
    dataTable = c(wctri.dataTable)
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
eml_write(eml, file="metaData_wctri.xml")



