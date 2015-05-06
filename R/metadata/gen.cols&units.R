
# =================================================================
# = Define Possible Units and Column Descriptions for All Regions =
# =================================================================

# General units – data from a given region have columns which are in one of the following units
# All units must be custom defined or found here: https://knb.ecoinformatics.org/#external//emlparser/docs/eml-2.1.1/./eml-unitTypeDefinitions.html#StandardUnitDictionary
gen.units <- list(
	"year"=c(unit = "number",precision = 1), 
	"datetime" = c(format = "MM/DD/YYYY HH:MM"),
	"timezone"= c(
		"1" = "Eastern Standard Time",
		"2" = "Eastern Daylight Savings Time",
		"3"	= "Central Standard Time",
		"4"	= "Central Daylight Savings Time",
		"5"	= "Atlantic Standard Time",
		"6"	= "Atlantic Daylight Savings Time",
		"7" = "Blank",
		"8"	= "Greenwich Mean Time",
		"9" = "Other (Explained in Comments Section)"
	),
	
	"time"= c(format = "MMHH"),
	"date" = c(format="YYYY-MM-DD", precision=1),
	"season" = c(
		"SPRING" = "spring",
		"FALL" = "fall"
	),
	
	"spp" = "Genus species",
	"common" = "common name",
	"genus" = "Genus",
	"species" = "species",
	
	"BGSCODE" = c(
		" "="adults", # NOTE: this should really just be "", but it's an error to assign 0-length variable name. Ugh.
		"T"="young of year",
		"E"="estimated weights",
		"C"="counts taken without weights",
		"S"="samples taken",
		"I"="Invalid barcode",
		"W"="unknown meaning"
	),
	
	"haulid" = "haul id",
		
	"gearsize" = c(unit = "Foot_US", precision=1),
	"geartype" = c(
			"ST" = "shrimp trawl",
			"BB" = "trawl, bib (only used in 1985)",
			"ES" = "experimental shrimp trawl (only used in 1993, 2008)",
			"FT" = "fish trawl (used sporadically)",
			"HO" = "high opening bottom trawl (only used in 1986, 2006)",
			"SM" = "standard mongoose trawl (only used in 1982)",
			"BL" = "bottom longline",
			"HL" = "??",
			"MS" = "miscellaneous",
			"OB" = "off-bottom longline",
			"PN" = "plankton, general (bongo, etc.)",
			"RV" = "remotely operated vehicle",
			"TR" = "fish trap",
			"TV" = "video trap",
			"VC" = "video camera"
	),
	"meshsize" = c(unit = "inch", precision=0.01),
	"duration" = c(unit = "minute", precision=1),
	"towspeed" = c(unit="knots", precision=0.1),
	
	"stratum" = "1 degree lon lat", 
	"stratumarea"=c(unit = "squareKilometers",precision = 1),
	"stratumarea2"=c(unit = "nauticalMile", precision = 1), # WRONG: needs to be nautical miles squared, needs custom unit 
	"lat"=c(unit = "degree", precision = 0.001), 
	"lon"=c(unit = "degree", precision = 0.001),
	"lat.deg" = c(unit = "degree", precision=1),
	"lon.deg" = c(unit="degree",precision=1),
	"lat.min" = c(unit = "minute", precision = 0.1),
	"lon.min" = c(unit = "minute" , precision = 0.1),
	
	"depth"=c(unit = "meter", precision = 1),
	"depth2" = c(unit="fathom", precision=0.1),
	"stemp"=c(unit = "celsius",precision = 0.1), 
	"btemp"=c(unit = "celsius",precision = 0.1), 
	
	"wtcpue" =c(unit = "kilogramsPerHectare",precision = 0.0001),# WRONG, needs to be per hectare
	"cntcpue"=c(unit = "numberPerKilometerSquared", precision = 0.01),
	"cnt" = c(unit="number"),
	"weight"=c(unit="kilogram")
)


# General column definitions (data columns from a region have one of the following definitions)
gen.cols <- c(
	# time information
	"year" = "year of haul", 
	"datetime" = "the day and time of the haul",
	"timezone" = "time zone",
	"time" = "starting time of the tow",
	"date" = "date of the tow",
	
	# species names
	"spp" = "species scientific name; Genus species",
	"common" = "the common name of the organism sampled",
	"genus" = "the genus of the species",
	"species" = "the species name of the species",
	
	# haul ID info
	"BGSID" = "record ID number", # from gmex
	"SID" = "species identification number",
	"vessel" = "vessel ID",
	"cruise" = "cruise ID",
	"haul" = "the integer haul number within a cruise", # does same description apply beyond just AI?
	"haulid" = "a unique identifier for the haul; vessel ID - cruise ID - haul number", 
	"stratum" = "the statistical stratum of the haul",
	"station"= "the station ID for the haul" ,
	
	# Method info
	"BGSCODE" = "flags information about the biological sample",
	"gearsize" = "the dimension of the gear; for trawl net, the width of the mouth in ft",
	"geartype" = "code for the type of gear used",
	"meshsize" = "the size of the net mesh (inches of stretch)",
	"duration" = "duration of the haul (how long the net was being towed)",
	"towspeed" = "the speed of the vessel",
	
	# location info
	"stratumarea" = "the area of the statistical stratum (km2)",
	"stratumarea2" = "the area of the statistical stratum (nmi2)", 
	"lat" = "latitude of the haul", 
	"lon" = "longitude of the haul, in western hemisphere degrees (for lon > 0, do lon-360)",
	"lat.deg" = "latitude of the haul; degree component",
	"lat.min" = "latitude of the haul; minutes component",
	"lon.deg" = "longitude of the haul; degree component",
	"lon.min" = "longitude of the haul; minutes component",
	"depth" = "the maximum depth of the water at the location of the haul",
	"depth2"= "depth of the haul",
	"NPFMCArea" = "region name",
	"Subarea Description" = "subarea name",
	"StratumCode" = "matches STRATUM column in bio data set",
	"OldStratumCode" = "stratum code from older classification system (only neus)",
	"DepthIntervalm" = "range of depths for the stratum, in meters",
	
	# environmental info
	"stemp" = "water temperature at the surface at the location of the haul", 
	"btemp" = "water temperature at the bottom at the location of the haul",
	
	# species measurements
	"wtcpue" = "weight (mass) of the catch", 
	"cntcpue"="number of individuals caught per hectare in the haul",
	"cnt" = "number of individuals in the whole net (may be extrapolated)",
	# "cnt_sample" = "number of individuals counted (may be a subsample)",
	"weight"="the weight (mass) of all items in the net (may be extrapolated)"#,
	# "weight_sample" = "the weight (mass) of the sample (may be subsampled)"
	
)

