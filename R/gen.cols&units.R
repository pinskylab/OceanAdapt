
# =================================================================
# = Define Possible Units and Column Descriptions for All Regions =
# =================================================================

# General units – data from a given region have columns which are in one of the following units
# All units must be custom defined or found here: https://knb.ecoinformatics.org/#external//emlparser/docs/eml-2.1.1/./eml-unitTypeDefinitions.html#StandardUnitDictionary
gen.units <- list(
	"year"=c(
		unit = "number",
		precision = 1
		), 
	"datetime" = c(
		format = "MM/DD/YYYY HH:MM"
		), 
	"spp" = "Genus species", 
	"haulid" = "haul id", 
	"stratum" = "1 degree lon lat", 
	"stratumarea"=c(
		unit = "squareKilometers",
		precision = 1
		),
	"stratumarea2"=c(
		unit = "nauticalMile", # WRONG: needs to be nautical miles squared, needs custom unit
		precision = 1
		), 
	"lat"=c(
		unit = "degree",
		precision = 0.001
		), 
	"lon"=c(
		unit = "degree",
		precision = 0.001
		), 
	"depth"=c(
		unit = "meter",
		precision = 1
		), 
	"stemp"=c(
		unit = "celsius",
		precision = 0.1
		), 
	"btemp"=c(
		unit = "celsius",
		precision = 0.1
		), 
	"wtcpue" =c(
		unit = "kilogramsPerHectare",
		precision = 0.0001
		),
	"cntcpue"=c(
		unit = "numberPerKilometerSquared", # WRONG, needs to be per hectare
		precision = 0.01
		) 
)


# General column definitions (data columns from a region have one of the following definitions)
gen.cols <- c(
	# time information
	"year" = "year of haul", 
	"datetime" = "the day and time of the haul", 
	
	# species names
	"spp" = "species scientific name; Genus species",
	"common" = "the common name of the organism sampled",
	
	# haul ID info
	"SID" = "species identification number",
	"vessel" = "vessel ID",
	"cruise" = "cruise ID",
	"haul" = "the integer haul number within a cruise", # does same description apply beyond just AI?
	"haulid" = "a unique identifier for the haul; vessel ID - cruise ID - haul number", 
	"stratum" = "the statistical stratum of the haul",
	"station"= "the station ID for the haul" ,
	
	# location info
	"stratumarea" = "the area of the statistical stratum (km2)",
	"stratumarea2" = "the area of the statistical stratum (nmi2)", 
	"lat" = "latitude of the haul", 
	"lon" = "longitude of the haul, in western hemisphere degrees (for lon > 0, do lon-360)", 
	"depth" = "the maximum depth of the water at the location of the haul", 
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
	"cntcpue"="number of individuals caught per hectare in the haul"
)

