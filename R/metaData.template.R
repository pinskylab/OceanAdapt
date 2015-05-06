


# <title>
	# character vector title
	sreg.title <- "Example region bottom trawl survey"

# <creator>
	# as(as.person("First Last <email@address.com>"), "creator")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
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
	contact@organizationName <- afsc.name
	contact@address <- afsc_address
	

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
	associatedParty <- c(as(as.person("Bob Lauth [ctb] <Bob.Lauth@noaa.gov>"), "associatedParty"))
	associatedParty[[1]]@organizationName <- afsc.name
	
	
# <pubDate>
	pubDate <- "2012"

# <intellectualRights>
	IR <- "this is just a long piece of text"

# <abstract>
	abstract <- "another long piece "

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
