

library(EML)

# setwd("/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/metaData")
source("../../OceanAdapt/R/metadata/gen.cols&units.R")

# ========================
# = GMEX Data Set (e.g.) =
# ========================
gmex.data <- structure(list(CRUISEID = c(5L, 5L, 5L, 5L, 5L, 5L), VESSEL = c(4L, 
4L, 4L, 4L, 4L, 4L), BIO_BGS = c("108020000", "108021802", "108021802", 
"108031101", "108031101", "110040205"), STATIONID = c(57649L, 
57724L, 57774L, 57633L, 57691L, 57560L), CRUISE_NO = c(127L, 
127L, 127L, 127L, 127L, 127L), P_STA_NO = c(36878L, 36953L, 37003L, 
36862L, 36920L, 36789L), BGSID = c(767556L, 769055L, 770355L, 
767311L, 768432L, 766224L), CATEGORY = c(3L, 3L, 3L, 3L, 3L, 
3L), GENUS_BGS = c("CARCHAR", "RHIZOPR", "RHIZOPR", "MUSTELU", 
"MUSTELU", "RAJA"), SPEC_BGS = c("HIIDA", "TERRAE", "TERRAE", 
"CAIS", "CAIS", "EGLAT"), BGSCODE = c("", "", "", "", "", ""), 
    CNTEXP = c(1L, 4L, 1L, 1L, 1L, 1L), SELECT_BGS = c(22.68, 
    4.565, 3.266, 7.258, 2.948, 0.68), INVRECID = c(49330L, 49387L, 
    49426L, 49317L, 49366L, 49271L), GEAR_SIZE = c(40L, 40L, 
    40L, 40L, 40L, 40L), GEAR_TYPE = c("ST", "ST", "ST", "ST", 
    "ST", "ST"), MESH_SIZE = c(1.63, 1.63, 1.63, 1.63, 1.63, 
    1.63), OP = c("", "", "", "", "", ""), MIN_FISH = c(21L, 
    27L, 30L, 11L, 16L, 30L), TIME_ZN = c(4L, 4L, 4L, 4L, 4L, 
    4L), TIME_MIL = c(132L, 2041L, 206L, 48L, 239L, 2301L), S_LATD = c(29L, 
    28L, 28L, 28L, 28L, 29L), S_LATM = c(2.8, 51.5, 21, 51.1, 
    12.8, 29.3), S_LOND = c(89L, 94L, 95L, 89L, 91L, 88L), S_LONM = c(56, 
    23.5, 49.4, 28.3, 52.8, 51.9), DEPTH_SSTA = c(25.6, 23.8, 
    25.6, 45.7, 73.2, 14.6), MO_DAY_YR = c("1982-06-19", "1982-07-01", 
    "1982-07-08", "1982-06-17", "1982-06-25", "1982-06-01"), 
    E_LATD = c(29L, 28L, 28L, 28L, 28L, 29L), E_LATM = c(1.7, 
    50.3, 19.5, 50.5, 11.6, 28.4), E_LOND = c(89L, 94L, 95L, 
    89L, 91L, 88L), E_LONM = c(56.1, 23.5, 48.2, 28.6, 53.1, 
    51), TEMP_SSURF = c(30.5, 30.14, NA, 28.33, 31.05, 30), TEMP_BOT = c(23.61, 
    24.53, NA, 19.94, 18.5, 23.89), VESSEL_SPD = c(3, 3, 3, 3, 
    3, 2.5), COMSTAT = c("LOST SHARK FROM MOUTH OF ET", "", "SIGLE TOW", 
    "O BTM GRAB CURRET TOO STROG", "", ""), TAXONOMIC = c("CARCHARHIIDAE", 
    "RHIZOPRIOODO TERRAEOVAE", "RHIZOPRIOODO TERRAEOVAE", "MUSTELUS CAIS", 
    "MUSTELUS CAIS", "RAJA EGLATERIA"), TITLE = c("Summer SEAMAP Groundfish Survey", 
    "Summer SEAMAP Groundfish Survey", "Summer SEAMAP Groundfish Survey", 
    "Summer SEAMAP Groundfish Survey", "Summer SEAMAP Groundfish Survey", 
    "Summer SEAMAP Groundfish Survey")), .Names = c("CRUISEID", 
"VESSEL", "BIO_BGS", "STATIONID", "CRUISE_NO", "P_STA_NO", "BGSID", 
"CATEGORY", "GENUS_BGS", "SPEC_BGS", "BGSCODE", "CNTEXP", "SELECT_BGS", 
"INVRECID", "GEAR_SIZE", "GEAR_TYPE", "MESH_SIZE", "OP", "MIN_FISH", 
"TIME_ZN", "TIME_MIL", "S_LATD", "S_LATM", "S_LOND", "S_LONM", 
"DEPTH_SSTA", "MO_DAY_YR", "E_LATD", "E_LATM", "E_LOND", "E_LONM", 
"TEMP_SSURF", "TEMP_BOT", "VESSEL_SPD", "COMSTAT", "TAXONOMIC", 
"TITLE"), class = "data.frame", row.names = c(NA, -6L))



# NOTE: need to change some column classes to have useful column definitions
gmex.data[,"TIME_ZN"] <- factor(gmex.data[,"TIME_ZN"])
gmex.data[,"TIME_MIL"] <- as.character(gmex.data[,"TIME_MIL"])



# =====================
# = Define GMEX columns =
# =====================
gmex.cols <- c(
	"CRUISEID" = gen.cols[["cruise"]],
	"VESSEL" = gen.cols[["vessel"]],
	"BIO_BGS" = gen.cols[["SID"]],
	"STATIONID" = gen.cols[["station"]],
	"CRUISE_NO" = gen.cols[["cruise"]], # don't know how this is different from CRUISEID
	"P_STA_NO" = gen.cols[["station"]], # don't know how it's different from stationid
	"BGSID" = gen.cols[["BGSID"]],
	"CATEGORY" = "unknown",
	
	"GENUS_BGS" = gen.cols[["genus"]],
	"SPEC_BGS" = gen.cols[["species"]],
	"BGSCODE" = gen.cols[["BGSCODE"]],
	
	"CNTEXP" = gen.cols[["cnt"]],
	"SELECT_BGS" = gen.cols[["weight"]],
	
	"INVRECID" = "tow ID",
	
	"GEAR_SIZE" = gen.cols[["gearsize"]],
	"GEAR_TYPE" = gen.cols[["geartype"]],
	"MESH_SIZE" = gen.cols[["meshsize"]],
	"OP" = "status of the tow; blank is good, so is a '.'; all else bad (see filedef.doc)",
	"MIN_FISH" = gen.cols[["duration"]],
	
	"TIME_ZN"=gen.cols[["timezone"]],
	"TIME_MIL"=gen.cols[["time"]],
	
	
	"S_LATD"=paste("starting", gen.cols[["lat.deg"]]),
	"S_LATM"=paste("starting", gen.cols[["lat.min"]]),
	"S_LOND"=paste("starting", gen.cols[["lon.deg"]]),
	"S_LONM"=paste("starting", gen.cols[["lon.min"]]),
	
	"DEPTH_SSTA" = paste("starting", gen.cols[["depth2"]]),
	"MO_DAY_YR" = gen.cols[["date"]],
	
	"E_LATD"=paste("ending", gen.cols[["lat.deg"]]),
	"E_LATM"=paste("ending", gen.cols[["lat.min"]]),
	"E_LOND"=paste("ending", gen.cols[["lon.deg"]]),
	"E_LONM"=paste("ending", gen.cols[["lon.min"]]),
	
	
	"TEMP_SSURF" = gen.cols[["stemp"]],
	"TEMP_BOT" = gen.cols[["btemp"]],
	
	"VESSEL_SPD"=gen.cols[["towspeed"]],
	"COMSTAT"= "station comments",
	"TAXONOMIC" = gen.cols[["spp"]],
	"TITLE" = "survey name"
	
	
)

# ===================
# = Define GMEX units =
# ===================
gmex.units <- list(
	"CRUISEID" = c(unit = "number"), #gen.units[["cruise"]],
	"VESSEL" = c(unit = "number"), #gen.units[["vessel"]],
	"BIO_BGS" = c(unit = "number"), #gen.units[["SID"]],
	"STATIONID" = c(unit = "number"), #gen.units[["station"]],
	"CRUISE_NO" = c(unit = "number"), #gen.units[["cruise"]], # don't know how this is different from CRUISEID
	"P_STA_NO" = c(unit = "number"), #gen.units[["station"]], # don't know how it's different from stationid
	"BGSID" = c(unit = "number"), #gen.units[["BGSID"]],
	"CATEGORY" = c(unit = "number"),
	
	"GENUS_BGS" = gen.units[["genus"]],
	"SPEC_BGS" = gen.units[["species"]],
	"BGSCODE" = gen.units[["BGSCODE"]],
	
	"CNTEXP" = gen.units[["cnt"]],
	"SELECT_BGS" = gen.units[["weight"]],
	
	"INVRECID" = c(unit = "number"),
	
	"GEAR_SIZE" = gen.units[["gearsize"]],
	"GEAR_TYPE" = gen.units[["geartype"]],
	"MESH_SIZE" = gen.units[["meshsize"]],
	"OP" = c(unit = "number"),
	"MIN_FISH" = gen.units[["duration"]],
	
	"TIME_ZN"=gen.units[["timezone"]],
	"TIME_MIL"=gen.units[["time"]],
	
	
	"S_LATD"=gen.units[["lat.deg"]],
	"S_LATM"=gen.units[["lat.min"]],
	"S_LOND"=gen.units[["lon.deg"]],
	"S_LONM"=gen.units[["lon.min"]],
	
	"DEPTH_SSTA" = gen.units[["depth2"]],
	"MO_DAY_YR" = gen.units[["date"]],
	
	"E_LATD"=gen.units[["lat.deg"]],
	"E_LATM"=gen.units[["lat.min"]],
	"E_LOND"=gen.units[["lon.deg"]],
	"E_LONM"=gen.units[["lon.min"]],
	
	
	"TEMP_SSURF" = gen.units[["stemp"]],
	"TEMP_BOT" = gen.units[["btemp"]],
	
	"VESSEL_SPD"=gen.units[["towspeed"]],
	"COMSTAT"= "character description",
	"TAXONOMIC" = gen.units[["spp"]],
	"TITLE" = "character description"
	
	
)



# ===================================
# = Define GMEX Metadata Components =
# ===================================

# <title>
	# character vector title
	dataTitle <- "Gulf of Mexico bottom trawl survey"

# <creator>
	seamap.name <- "National Marine Fisheries Service (NMFS) Southeast Area Monitoring and Assessment Program (SEAMAP) Gulf States Marine Fisheries Commission (GSMFC)"
	# create organization address
	seamap_address <- new(
		"address", 
		deliveryPoint = "2404 Government St",
		city = "Ocean Springs",
		administrativeArea = "MS",
		postalCode = "39564",
		country = "USA"
	)
	creator <- c(as("", "creator"))
	creator[[1]]@organizationName <- seamap.name
	creator[[1]]@address <- seamap_address
	creator[[1]]@onlineUrl <- "http://seamap.gsmfc.org/"

# <contact>
	contact <- as(as.person("Jeff Rester <JRester@gsmfc.org>"), "contact")
	# add the organization info
	contact@organizationName <- seamap.name
	contact@address <- seamap_address
	contact@phone <- "228-875-5912"
	

# <metadataProvider>
	metadataProvider <- c(as(as.person("Ryan Batt <battrd@gmail.com>"), "metadataProvider"))

# <associatedParty>
	# example, from AI; note that you need something in the [] in the as.person() text (it's the person's role, I think this can be anything)
	# associatedParty <- c(as(as.person("Bob Lauth [ctb] <Bob.Lauth@noaa.gov>"), "associatedParty"))
	# associatedParty[[1]]@organizationName <- afsc.name
	
# <pubDate>
	pubDate <- "2014"

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
methods <- 	new(
	"methods",
	methodStep=c(
		new("methodStep",
			dataSource="http://seamap.gsmfc.org/",
			description="http://seamap.gsmfc.org/documents/SEAMAP_Data_Structures.pdf"
		) # end new methodStep
	) # end c() of methodStep

) # end new methods



# ======================
# = Create EML Objects =
# ======================
# Create "dataTable": the physical data set with associated column definitions and units
gmex.dataTable <- eml_dataTable(
		dat=gmex.data,
		name="gmex",
		col.defs=gmex.cols,
		unit.defs=gmex.units
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
    # associatedParty = associatedParty,
    # keywordSet = keys,
    # coverage = coverage,
    methods = methods,
    dataTable = c(gmex.dataTable)
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
eml_write(eml, file="metaData_gmex.xml")
