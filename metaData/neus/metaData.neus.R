

library(EML)

# setwd("/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/metaData")
source("../../OceanAdapt/R/metadata/gen.cols&units.R")


neus.data <- structure(list(STRATUM = c(1010L, 1010L, 1010L, 1010L, 1010L, 
1010L), SVSPP = c("103", "103", "103", "103", "103", "103"), 
    YEAR = c(1975L, 1975L, 1977L, 1978L, 1980L, 1980L), SEASON = c("SPRING", 
    "SPRING", "SPRING", "SPRING", "SPRING", "SPRING"), LAT = c(39.833333, 
    40.7, 39.883333, 40.3, 40.066667, 40.1), LON = c(-73.35, 
    -72.633333, -72.75, -72.5, -72.933333, -73.783333), DEPTH = c(44L, 
    31L, 56L, 51L, 48L, 31L), CRUISE6 = c(197503L, 197503L, 197702L, 
    197804L, 198002L, 198002L), STATION = c(33L, 80L, 139L, 157L, 
    171L, 178L), BIOMASS = c(0, 0, 0.83969465648855, 0.687022900763359, 
    0.0763358778625954, 0.152671755725191), ABUNDANCE = c(1, 
    1, 2, 1, 1, 1), SCINAME = c("PARALICHTHYS DENTATUS", "PARALICHTHYS DENTATUS", 
    "PARALICHTHYS DENTATUS", "PARALICHTHYS DENTATUS", "PARALICHTHYS DENTATUS", 
    "PARALICHTHYS DENTATUS"), Areanmi2 = c(2516L, 2516L, 2516L, 
    2516L, 2516L, 2516L)), .Names = c("STRATUM", "SVSPP", "YEAR", 
"SEASON", "LAT", "LON", "DEPTH", "CRUISE6", "STATION", "BIOMASS", 
"ABUNDANCE", "SCINAME", "Areanmi2"), class = "data.frame", row.names = c(NA, 
-6L))


# ===============================
# = Column and Unit Definitions =
# ===============================

# Columns
neus.cols <- c(
	"STRATUM" = gen.cols[["stratum"]],
	"SVSPP" = gen.cols[["SID"]],
	"YEAR" = gen.cols[["year"]],
	"SEASON" = "survey season (i.e., season = collection of adjacent months)",
	"LAT" = gen.cols[["lat"]],
	"LON" = gen.cols[["lon"]],
	"DEPTH" = gen.cols[["depth"]],
	"CRUISE6" = gen.cols[["cruise"]],
	"STATION" = gen.cols[["station"]],
	"BIOMASS" = gen.cols[["weight"]], # corrected for certain gear changes, but not necessarily for total area hauled
	"ABUNDANCE" = gen.cols[["cnt"]], # same as biomass – linear correction factors applied to account for gear/ method changes, but not necessarily area trawled (effort only partially accounted for, perhaps)
	"SCINAME" = gen.cols[["spp"]],
	"Areanmi2" = gen.cols[["stratumarea2"]]
	
)

# Units
neus.units <- list(
	"STRATUM" = c(unit="number", precision=1), #"statistical stratum ID number",
	"SVSPP" = "species ID number", #gen.units[["SID"]],
	"YEAR" = gen.units[["year"]],
	"SEASON" = gen.units[["season"]],
	"LAT" = gen.units[["lat"]],
	"LON" = gen.units[["lon"]],
	"DEPTH" = gen.units[["depth"]],
	"CRUISE6" = c(unit="number"),
	"STATION" = c(unit="number"),
	"BIOMASS" = gen.units[["weight"]], # corrected for certain gear changes, but not necessarily for total area hauled
	"ABUNDANCE" = gen.units[["cnt"]], # same as biomass – linear correction factors applied to account for gear/ method changes, but not necessarily area trawled (effort only partially accounted for, perhaps)
	"SCINAME" = gen.units[["spp"]],
	"Areanmi2" = gen.units[["stratumarea2"]]	
)





# =============================
# = Name Meta Data Components =
# =============================

# <title>
	# character vector title
	dataTitle <- "Northeast US bottom trawl survey"

# <creator>
	REGION.name <- "Northeast Fisheries Science Center (NEFSC)"
	# create organization address
	REGION_address <- new(
		"address", 
		deliveryPoint = "166 Water Street",
		city = "Woods Hole",
		administrativeArea = "MA",
		postalCode = "02543-1026",
		country = "USA"
	)
	creator <- c(as("", "creator"))
	creator[[1]]@organizationName <- REGION.name
	creator[[1]]@address <- REGION_address
	creator[[1]]@onlineUrl <- "http://nefsc.noaa.gov/"

# <contact>
	contact <- as(as.person("Sean Lucey <Sean.Lucey@noaa.gov>"), "contact")
	# add the organization info
	contact@organizationName <- REGION.name
	contact@address <- REGION_address
	

# <metadataProvider>
	metadataProvider <- c(as(as.person("Ryan Batt <battrd@gmail.com>"), "metadataProvider"))

# <associatedParty>
	associatedParty <- c(as(as.person("Linda Despres [ctb] <Linda.Despres_@_noaa.gov>"), "associatedParty"))
	associatedParty[[1]]@organizationName <- REGION.name
	
	
# <pubDate>
	pubDate <- "2014"

# <intellectualRights>
	# IR <- "this is just a long piece of text"

# <abstract>
	abstract <- "This is the Northeast Fisheries Science Center Bottom Trawl Survey database for Northwest Atlantic marine organisms. Survey cruises use a bottom trawl to sample randomly selected stations in an attempt to delineate the species composition, geographic distribution, and abundance of various resources. Fish and selected invertebrate species are identified. Weight, length, total catch numbers, age structures, maturity stages, sex determinations and food content are recorded or collected during the survey cruises. Associated oceanographic and meteorological data, salinity, conductivity, and temperature data are available for all stations. Ichthyoplankton and zooplankton data is available for a subset of the stations. Geographic coverage is from Cape Hatteras to the Gulf of Maine and from the coast to the slope water."

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
methods <- new("methods",
		methodStep=c(
			new("methodStep",
				dataSource="http://iobis.org/mapper/"#,
				# description=character(0),
				# citation=new("ListOfcitation", list("NOAA’s National Marine Fisheries Service (NMFS) Northeast Fisheries Science Center (2005). Northeast Fisheries Science Center Bottom Trawl Survey Data. NOAA’s National Marine Fisheries Service (NMFS) Northeast Fisheries Science Center. Woods Hole, Massachusetts, United States of America."))#, # the format of this citation entry is invalid
				# instrumentation=character(0)
			) # end new methodStep
		) # end c() of methodStep

	) # end new methods





# ======================
# = Create EML Objects =
# ======================
# Create "dataTable": the physical data set with associated column definitions and units
REGION.dataTable <- eml_dataTable(
		dat=neus.data,
		name="NEUS",
		col.defs=neus.cols,
		unit.defs=neus.units
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
    dataTable = c(REGION.dataTable)
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
eml_write(eml, file="metaData_NEUS.xml")