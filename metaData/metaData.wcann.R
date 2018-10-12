


library(EML)

# setwd("/Users/Battrd/Documents/School&Work/pinskyPost/OceanAdapt/metaData")
source("../../OceanAdapt/R/metadata/gen.cols&units.R")


wcann.data <- structure(list(Trawl.Id = c("200303003001", "200303003001", "200303003001", 
"200303003001", "200303003001", "200303003001"), Species = c("Anoplopoma fimbria", 
"Antimora microlepis", "Apristurus brunneus", "Bathyagonus nigripinnis", 
"Bathyraja kincaidii (formerly B. interrupta)", "Careproctus melanurus"
), Haul.Weight..kg. = c(10.8, 2.3, 4.05, 0.005, 0.9, 0.9), Individual.Average.Weight..kg. = c(1.35, 
0.115, 0.27, 0.003, 0.9, 0.3), Survey = c("Groundfish Slope and Shelf Combination Survey", 
"Groundfish Slope and Shelf Combination Survey", "Groundfish Slope and Shelf Combination Survey", 
"Groundfish Slope and Shelf Combination Survey", "Groundfish Slope and Shelf Combination Survey", 
"Groundfish Slope and Shelf Combination Survey"), Survey.Cycle = c("Cycle 2003", 
"Cycle 2003", "Cycle 2003", "Cycle 2003", "Cycle 2003", "Cycle 2003"
), Vessel = c("Blue Horizon", "Blue Horizon", "Blue Horizon", 
"Blue Horizon", "Blue Horizon", "Blue Horizon"), Cruise.Leg = c(1L, 
1L, 1L, 1L, 1L, 1L), Trawl.Performance = c("Fisheries Assessment Acceptable", 
"Fisheries Assessment Acceptable", "Fisheries Assessment Acceptable", 
"Fisheries Assessment Acceptable", "Fisheries Assessment Acceptable", 
"Fisheries Assessment Acceptable"), Trawl.Date = c("8/31/03", 
"8/31/03", "8/31/03", "8/31/03", "8/31/03", "8/31/03"), Trawl.Start.Time = c("8/31/03 18:12", 
"8/31/03 18:12", "8/31/03 18:12", "8/31/03 18:12", "8/31/03 18:12", 
"8/31/03 18:12"), Best.Latitude..dd. = c(46.30424583, 46.30424583, 
46.30424583, 46.30424583, 46.30424583, 46.30424583), Best.Longitude..dd. = c(-124.7250958, 
-124.7250958, -124.7250958, -124.7250958, -124.7250958, -124.7250958
), Best.Position.Type = c("Vessel Track Midpoint", "Vessel Track Midpoint", 
"Vessel Track Midpoint", "Vessel Track Midpoint", "Vessel Track Midpoint", 
"Vessel Track Midpoint"), Best.Depth..m. = c(527.5, 527.5, 527.5, 
527.5, 527.5, 527.5), Best.Depth.Type = c("Bottom Depth", "Bottom Depth", 
"Bottom Depth", "Bottom Depth", "Bottom Depth", "Bottom Depth"
), Trawl.Duration..min. = c(17.68, 17.68, 17.68, 17.68, 17.68, 
17.68), Area.Swept.by.the.Net..hectares. = c(1.654034, 1.654034, 
1.654034, 1.654034, 1.654034, 1.654034), Temperature.At.the.Gear..degs.C. = c(5.17, 
5.17, 5.17, 5.17, 5.17, 5.17)), .Names = c("Trawl.Id", "Species", 
"Haul.Weight..kg.", "Individual.Average.Weight..kg.", "Survey", 
"Survey.Cycle", "Vessel", "Cruise.Leg", "Trawl.Performance", 
"Trawl.Date", "Trawl.Start.Time", "Best.Latitude..dd.", "Best.Longitude..dd.", 
"Best.Position.Type", "Best.Depth..m.", "Best.Depth.Type", "Trawl.Duration..min.", 
"Area.Swept.by.the.Net..hectares.", "Temperature.At.the.Gear..degs.C."
), class = "data.frame", row.names = c(NA, -6L))


# ===============================
# = Column and Unit Definitions =
# ===============================


wcann.cols <- c(
	"Trawl.Id" = gen.cols[["haulid"]], 
	"Species" = gen.cols[["spp"]], 
	"Haul.Weight..kg." = gen.cols[["weight"]],
	"Individual.Average.Weight..kg." = "average individual weight (weight/count)", 
	"Survey" = "Indicates the survey time series within which a trawl sample was conducted; either the West Coast Slope Bottom Trawl Survey or the West Coast Slope/Shelf Bottom Trawl Survey", 
	"Survey.Cycle" = gen.cols[["year"]], 
	"Vessel" = gen.cols[["vessel"]], 
	"Cruise.Leg" = "The West Coast Groundfish Bottom Trawl Surveys have been conducted coastwide from the U.S. / Canada border to a southern boundary that has expanded southward from Point Conception to the U.S. - Mexico border over time (see accompanying data annotations document).  The full north to south extent is traversed in two passes each survey season.  Each pass is divided into four (Slope survey) to five (Slope/Shelf combined survey) continuous segments separated by rest periods in ports along the coast.  Cruise leg indicates the sequential segment (1-5) in which a trawl operation was conducted.", 
	"Trawl.Performance" = "All trawl operations are reviewed and rated as to the quality of their execution and their applicability to formal fishery assessment analysis products.  Trawl Performance indicates these determinations.  See the accompanying data annotations document for a more detailed description.", 
	"Trawl.Date" =gen.cols[["date"]], 
	"Trawl.Start.Time" = gen.cols[["datetime"]], 
	"Best.Latitude..dd." = gen.cols[["lat"]], 
	"Best.Longitude..dd." = gen.cols[["lon"]], 
	"Best.Position.Type" = "The best trawl position (Best Latitude, Best Longitude) available has been provided in decimal degrees North Latitude and annotated with its type (Best Position Type).  Preference is given to any recorded gear position, usually an estimate of the onbottom midpoint: [(start_lat+end_lat)/2,  (start_lon+end_lon)/2].  If no acceptable onbottom gear position can be determined, a vessel position is provided, usually a similarly determined trawl midpoint estimate for the vessel.  If no acceptable vessel position can be determined, position data recorded for the defined station is provided.", 
	"Best.Depth..m." = gen.cols[["depth"]], 
	"Best.Depth.Type" = "how depth was determined", 
	"Trawl.Duration..min." = gen.cols[["duration"]], 
	"Area.Swept.by.the.Net..hectares." = gen.cols[["areaswept"]], 
	"Temperature.At.the.Gear..degs.C." = gen.cols[["btemp"]]
)


wcann.units <- list(
	"Trawl.Id" = gen.units[["haulid"]], 
	"Species" = gen.units[["spp"]], 
	"Haul.Weight..kg." = gen.units[["weight"]],
	"Individual.Average.Weight..kg." = c(units = "kilogram"), # WRONG, should actually be kilogramsPerNumber (?? or should it ??)
	"Survey" = "Survey text",
	"Survey.Cycle" = gen.units[["year"]], 
	"Vessel" = "Vessel text", 
	"Cruise.Leg" = c(units="number"), 
	"Trawl.Performance" = "Trawl.Performance text", 
	"Trawl.Date" =gen.units[["date"]], 
	"Trawl.Start.Time" = gen.units[["datetime"]], 
	"Best.Latitude..dd." = gen.units[["lat"]], 
	"Best.Longitude..dd." = gen.units[["lon"]], 
	"Best.Position.Type" = "Best.Position.Type text", 
	"Best.Depth..m." = gen.units[["depth"]], 
	"Best.Depth.Type" = "Best.Depth.Type text", 
	"Trawl.Duration..min." = gen.units[["duration"]], 
	"Area.Swept.by.the.Net..hectares." = gen.units[["areaswept"]], 
	"Temperature.At.the.Gear..degs.C." = gen.units[["btemp"]]
)


# =============================
# = Name Meta Data Components =
# =============================

# <title>
	# character vector title
	dataTitle <- "West Coast Annual Bottom Trawl Survey"

# <creator>
	# as(as.person("First Last <email@address.com>"), "creator")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
	# organization name
	wcann.name <- "National Oceanic and Atmospheric Administration (NOAA) Northwest Fisheries Science Center (NWFSC)"
	# create organization address
	wcann_address <- new(
		"address", 
		deliveryPoint = "2725 Montlake Boulevard East",
		city = "Seattle",
		administrativeArea = "WA",
		postalCode = "98112",
		country = "USA"
	)
	creator <- c(as("", "creator"))
	creator[[1]]@organizationName <- wcann.name
	creator[[1]]@address <- wcann_address
	creator[[1]]@onlineUrl <- "http://www.nwfsc.noaa.gov/index.cfm"

# <contact>
	# as(as.person("First Last <email@address.com>"), "contact")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
	
	# example, taken from AI
	contact <- as(as.person("Beth Horness <beth.horness@noaa.gov>"), "contact")
	# add the organization info
	contact@organizationName <- wcann.name
	contact@address <- wcann_address
	

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
	# associatedParty <- c(as(as.person("Bob Lauth [ctb] <Bob.Lauth@noaa.gov>"), "associatedParty"))
	# associatedParty[[1]]@organizationName <- wcann.name
	
	
# <pubDate>
	pubDate <- "2012"

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
wcann.dataTable <- eml_dataTable(
		dat=wcann.data,
		name="wcann",
		col.defs=wcann.cols,
		unit.defs=wcann.units
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
    # methods = methods,
    dataTable = c(wcann.dataTable)
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
eml_write(eml, file="metaData_wcann.xml")

