


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
	creator <- as(as.person("First Last <email@address.com>"), "creator")
	creator@organizationName <- "example organization"
	creator@positionName <- "da boss"
	creator@address <- new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	creator@phone <- "123-123-1234"
	creator@onlineUrl <- "website.com"

# <contact>
	# as(as.person("First Last <email@address.com>"), "creator")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
	
	# example w/ multiple contacts, taken from AI
	contact <- c(
		as(as.person("Bob Lauth <Bob.Lauth@noaa.gov>"), "contact"),
		as(as.person("Wayne Palsson <Wayne.Palsson@noaa.gov>"), "contact")
	)
		# add the organization to each human
	for(i in 1:length(contact)){
		contact[[i]]@organizationName <- afsc.name
		contact[[i]]@address <- afsc_address
	}
	

# <metadataProvider>
	# as(as.person("First Last <email@address.com>"), "creator")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl

# <associatedParty>
	# as(as.person("First Last <email@address.com>"), "creator")
	# @organizationName
	# @positionName
	# @address
		# new("address", deliveryPoint="1234 Treetop Lane", city="Springfield", administrativeArea="OH", postalCode="12345", country="USA")
	# @phone
	# @onlineUrl
	
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
