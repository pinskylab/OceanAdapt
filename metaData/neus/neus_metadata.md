Northeast U.S.
-------------------------------

**Sources:** 
1. [NOAA Northeast Fisheries Science Center Fall Bottom Trawl Survey](https://inport.nmfs.noaa.gov/inport/item/22560)
2. [NOAA Northeast Fisheries Science Center Spring Bottom Trawl Survey](https://inport.nmfs.noaa.gov/inport/item/22561)

**Related papers:** 
- [Guide to some trawl-caught marine fishes from Maine to Cape Hatteras, North Carolina, Flescher, 1980](https://spo.nmfs.noaa.gov/content/circular-431-guide-some-trawl-caught-marine-fishes-maine-cape-hatteras-north-carolina)
- [A brief historical review of the Woods Hole Laboratory trawl survey time series, Azarovitz, 1981](http://dmoserv3.whoi.edu/data_docs/NEFSC_Bottom_Trawl/Azarovitz1981.pdf)
- [An Evaluation of the Bottom Trawl Survey Program of the Northeast Fisheries Center, NEFSC, 1988](https://www.st.nmfs.noaa.gov/tm/nec_image/nec052image.pdf)
- [A historical perspective on the abundance and biomass of northeast demersal complex stocks from NMFS and Massachusetts inshore bottom trawl surveys, 1963-2002, Sosebe and Cardin, 2006](https://repository.library.noaa.gov/view/noaa/5259)
- [Estimation of Albatross IV to Henry B. Bigelow Calibration Factors, Miller et al., 2010](https://www.nefsc.noaa.gov/publications/crd/crd1005/crd1005.pdf)
- [Northeast Fisheries Science Center Bottom Trawl Survey Protocols for the NOAA Ship Henry B. Bigelow, Politis et al., 2014](https://www.nefsc.noaa.gov/publications/crd/crd1406/)
- [Groundfish Bottom Trawl Survey Protocols, NOAA Fisheries, 2018](https://www.fisheries.noaa.gov/resource/document/groundfish-bottom-trawl-survey-protocols)
- [Density-Independent and Density-Dependent Factors Affecting Spatio-Temporal Dynamics of Atlantic Cod (Gadus Morhua) Distribution in the Gulf of Maine, Zengguang et al., 2018](https://doi.org/10.1093/icesjms/fsx246)
- [Technical Documentation, State of the Ecosystem Report, NEFSC, 2019](https://noaa-edab.github.io/tech-doc/)
- [NEFSC trawl strata](https://pinskylab.github.io/OceanAdapt/metaData/neus_NEFSC_trawl_strata.pdf)

**How we process the data:**
- Before 2020, we emailed a staff member at NOAA with a data request and recieved a RData file. This file was a combination of the SVBIO, SVCAT, and SVSTA files and some column names were changed. Now we download the files from the publicly available data set. We combine those files and change the column names to match the column names we used to receive so that subsequent code will work. The changes include changing EST_YEAR to YEAR, changing DECDEG_BEGLAT to LAT, DECDEG_BEGLON to LON, AVGDEPTH to DEPTH, EXPCATCHWT to BIOMASS.
- There are some commas and special characters in the svcat.csv files that cause them to parse incorrectly. We import those files with read_lines, remove the commas and special characters from the comments, and proceed to read them into R as .csvs.
- We group the data by YEAR, SEASON, LAT, LON, DEPTH, CRUISE6, STATION, STRATUM, and SVSPP and sum the BIOMASS (which is reported by sex) to calculate wtcpue.
- We create a haulid by combining a 6 digit leading zero cruise number with a 3 digit leading zero station number and a 4 digit leading zero stratum number, separated by “-”, for example: (cruise-station-stratum) 456354-067-0001.
- We convert square nautical miles to square kilometers.
- We remove any SCINAME spp values that contain the word “egg” or “unidentified”, or where the only value in the SCINAME field is white space.
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue.
- We separate the trawls into Fall and Spring seasons.

**What the raw data include:**

The current files of raw data for the Northeast U.S. are neus_fall_svcat.csv, neus_fall_svsta.csv, neus_spring_svcat.csv, neus_spring_svsta.csv, neus_strata.csv, and neus_svspp.csv.

**neus_strata.csv is constant through the years.**
In 2020 this file was updated to add a leading zero to the STRATUM column to match the STRATUM column in the publicly available data.

| attributeName      | col_classes              | attributeDefinition   | unit |         
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|STRGRP_DESC|	character|	Description of stratum group.|	dimensionless
|STRATUM|	character|	A predefined area where a net dredge, or other piece of gear was deployed. Code consists of 2 parts: Stratum group code number (2 bytes) and stratum number (3 bytes). Stratum group refers to if area fished is inshore or offshore North or South of Cape Hatteras or the type of cruise (shellfish, State of MA, offshore deepwater). The stratum number (third and fourth digits of code) refers to area defined by depth zone. See SVDBS.SVMSTRATA. The fifth digit of the code increases the length of the stratum number for revised strata after the Hague Line was established. Stratum group code: 01 = Trawl, offshore north of Hatteras; 02 = BIOM; 03 = Trawl, inshore north of Hatteras; 04 = Shrimp; 05 = Scotian shelf; 06 = Shellfish; 07 = Trawl, inshore south of Hatteras; 08 = Trawl, Offshore south of Hatteras; 09 = MA DMF; 99 = Offshore deepwater (outside the stratified area). A change in Bottom Trawl Stratum for the Gulf of Maine-Bay of Fundy has been in effect since Spring 1987, and may be summarized as follows: Previous strata: 01350; Present strata: 01351, 01352.|	dimensionless
|STRATUM_NAME|	character|	Name of stratum area.|	dimensionless
|STRATUM_AREA|	numeric	|Stratum area measured in square nautical miles.|	dimensionless
|MIDLAT|	numeric	|Middle latitude in stratum for auditing purposes.	|dimensionless
|MIDLON|	numeric|	Middle longitude in stratum for auditing purposes.|	dimensionless
|MINLAT|	numeric|	Minimum latitude in stratum for auditing purposes.|	dimensionless
|MAXLAT|	numeric|	Maximum latitude in stratum for auditing purposes.|	dimensionless
|MINLON|	numeric|	Minimum longitude in stratum for auditing purposes.|	dimensionless
|MAXLON|	numeric|	Maximum longitude in stratum for auditing purposes.|	dimensionless

**neus_spring_svcat.csv and neus_fall_svcat.csv are updated annually.**
| attributeName      | col_classes              | attributeDefinition   | unit |         
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|CRUISE6|	character|	Code uniquely identifying cruise. The first four digits indicate the year and the last two digit uniquely identify the cruise within the year. The 5th byte signifies cruises other than groundfish: Shrimp survey = 7 (i.e. 201470), State of Massachusetts survey = 9 (i.e. 201491), Food habits = 5 (i.e.199554)|	dimensionless
|STRATUM|	character|	A predefined area where a net dredge, or other piece of gear was deployed. Code consists of 2 parts: Stratum group code number (2 bytes) and stratum number (3 bytes). Stratum group refers to if area fished is inshore or offshore North or South of Cape Hatteras or the type of cruise (shellfish, State of MA, offshore deepwater). The stratum number (third and fourth digits of code) refers to area defined by depth zone. See SVDBS.SVMSTRATA. The fifth digit of the code increases the length of the stratum number for revised strata after the Hague Line was established. Stratum group code: 01 = Trawl, offshore north of Hatteras; 02 = BIOM; 03 = Trawl, inshore north of Hatteras; 04 = Shrimp; 05 = Scotian shelf; 06 = Shellfish; 07 = Trawl, inshore south of Hatteras; 08 = Trawl, Offshore south of Hatteras; 09 = MA DMF; 99 = Offshore deepwater (outside the stratified area). A change in Bottom Trawl Stratum for the Gulf of Maine-Bay of Fundy has been in effect since Spring 1987, and may be summarized as follows: Previous strata: 01350; Present strata: 01351, 01352.|	dimensionless
|TOW|	character|	Sequential number representing order in which station was selected within a stratum.	|dimensionless
|STATION|	character|	Unique sequential order in which stations have been completed. Hangups and short tows each receive a non-repeated consecutive number.|	dimensionless
|ID|	character|	Concatenation of Cruise, Stratum, Tow and Station values.|	dimensionless
|LOGGED_SPECIES_NAME|	character|	Name of the species, either common, scientific or both.	|dimensionless
|SVSPP|	character|	A standard code which represents a species caught in a trawl or dredge. Refer to the SVDBS.SVSPECIES_LIST (if you are looking at the OceanAdapt website, SVSPP.RData)	|dimensionless
|CATCHSEX|	character|	Code used to identify species that are sexed at the catch level. See SVDBS.SEX_CODES|	dimensionless
|EXPCATCHNUM|	numeric|	Expanded number of individuals of a species caught at a given station.|	dimensionless
|EXPCATCHWT|	numeric|	Expanded catch weight of a species caught at a given station.|	dimensionless

**neus_spring_svsta.csv and neus_fall_svsta.csv are updated annually.**
| attributeName      | col_classes              | attributeDefinition   | unit |         
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|CRUISE6|	character|	Code uniquely identifying cruise. The first four digits indicate the year and the last two digit uniquely identify the cruise within the year. The 5th byte signifies cruises other than groundfish: Shrimp survey = 7 (i.e. 201470), State of Massachusetts survey = 9 (i.e. 201491), Food habits = 5 (i.e.199554)	|dimensionless
|STRATUM|	character|	A predefined area where a net dredge, or other piece of gear was deployed. Code consists of 2 parts: Stratum group code number (2 bytes) and stratum number (3 bytes). Stratum group refers to if area fished is inshore or offshore North or South of Cape Hatteras or the type of cruise (shellfish, State of MA, offshore deepwater). The stratum number (third and fourth digits of code) refers to area defined by depth zone. See SVDBS.SVMSTRATA. The fifth digit of the code increases the length of the stratum number for revised strata after the Hague Line was established. Stratum group code: 01 = Trawl, offshore north of Hatteras; 02 = BIOM; 03 = Trawl, inshore north of Hatteras; 04 = Shrimp; 05 = Scotian shelf; 06 = Shellfish; 07 = Trawl, inshore south of Hatteras; 08 = Trawl, Offshore south of Hatteras; 09 = MA DMF; 99 = Offshore deepwater (outside the stratified area). A change in Bottom Trawl Stratum for the Gulf of Maine-Bay of Fundy has been in effect since Spring 1987, and may be summarized as follows: Previous strata: 01350; Present strata: 01351, 01352.	|dimensionless
|TOW|	character|	Sequential number representing order in which station was selected within a stratum.	|dimensionless
|STATION|	character|	Unique sequential order in which stations have been completed. Hangups and short tows each receive a non-repeated consecutive number.|	dimensionless
|ID|	character|	Concatenation of Cruise, Stratum, Tow and Station values.	|dimensionless
|AREA|	character|	Standard area code used for commercial data (New England Statistical Area Code) for the position of the beginning of the tow.|	dimensionless
|SVVESSEL|	character|	Standard two character code for a survey vessel. Refer to SVDBS.SV_VESSEL|	dimensionless
|CRUNUM|	character|	National Ocean Services (NOS) consecutive cruise number on a particular vessel.|	dimensionless
|SVGEAR|	numeric|	Code referencing predominant gear type used on a cruise. See SVDBS.SVGEAR table.|	dimensionless
|BEGIN_EST_TOWDATE|	date|	Date and time represented by Eastern Standard Time (EST) for the start of a tow or deployment.|	MM/DD/YYYY hh:mm:ss a
|END_EST_TOWDATE|	date|	Date and time represented by Eastern Standard Time (EST) at the end of a tow or deployment.	|MM/DD/YYYY hh:mm:ss a
|BEGIN_GMT_TOWDATE|	date|	Date and time represented by Greenwich Mean Time (GMT) for the start of a tow or deployment.|	MM/DD/YYYY hh:mm:ss a
|END_GMT_TOWDATE|	date|	Date and time represented by Greenwich Mean Time (GMT) for the end of a tow or deployment.|	MM/DD/YYYY hh:mm:ss a
|EST_YEAR|	numeric|	Year, represented by Eastern Standard Time (EST).	|dimensionless
|EST_MONTH|	character|	Month, represented by Eastern Standard Time (EST).	|dimensionless
|EST_DAY|	character|	Day of the month represented by Eastern Standard Time (EST).	|dimensionless
|EST_JULIAN_DAY|	numeric|	Julian day of towdate represented as Eastern Standard Time (EST).|	dimensionless
|EST_TIME|	character|	Time, represented by Eastern Standard Time (EST).|	dimensionless
|GMT_YEAR|	numeric|	Year, represented as Greenwich Mean Time (GMT).|	dimensionless
|GMT_MONTH|	character|	Month, represented as Greenwich Mean Time (GMT).	|dimensionless
|GMT_DAY|	character|	Day of the month, represented as Greenwich Mean Time (GMT).	|dimensionless
|GMT_JULIAN_DAY|	numeric|	Julian day of towdate represented as Greenwich Mean Time (GMT).|	dimensionless
|GMT_TIME|	character|	Time, represented as Greenwich Mean Time (GMT).|	dimensionless
|TOWDUR|	numeric|	Duration of tow in minutes.|	minute
|SETDEPTH|	numeric	|Depth at the time the primary gear is set to fish, to the nearest meter.|	meter
|ENDDEPTH|	numeric|	Water depth (m) at end of tow.	|meter
|MINDEPTH|	numeric|	Minimum depth (m) at which gear fished.	|meter
|MAXDEPTH|	numeric|	Maximum depth at which gear fished.|	meter
|AVGDEPTH|	numeric|	A four digit number recording the average depth, to the nearest meter, during a survey gear deployment.	|meter
|BEGLAT|	numeric|	Beginning latitude of tow (decimal degrees).|	dimensionless
|BEGLON|	numeric|	Beginning longitude of tow (decimal degrees).	|dimensionless
|ENDLAT|	numeric|	Latitude at end of tow.	|dimensionless
|ENDLON|	numeric|	Logitude at end of tow.	|dimensionless
|DECDEG_BEGLAT|	numeric|	Beginning latitude of tow in decimal degrees.	|decimal degree
|DECDEG_BEGLON|	numeric|	Beginning longitude of tow in decimal degrees.	|decimal degree
|DECDEG_ENDLAT|	numeric|	Ending latitide of tow in decimal degrees.	|decimal degree
|DECDEG_ENDLON|	numeric|	Ending longitude of tow in decimal degrees.	|decimal degree
|CABLE|	numeric|	Wire out (meters) at the water surface.|	meter
|PITCH|	numeric|	Pitch of variable pitch propeller.|	dimensionless
|HEADING|	numeric|	Vessel compass heading.	|degree
|COURSE|	numeric|	Actual course the vessel made good in degrees.|	degree
|RPM|	numeric|	Average shaft revolutions per minute while under tow.|	dimensionless
|DOPDISTB|	numeric|	Speed over bottom recorded by GPS.	|dimensionless
|DOPDISTW|	numeric|	Speed through water recorded by AMATEK when the water depth is >200m.	|dimensionless
|DESSPEED|	numeric|	Designated towing speed for a particular gear (knots).	|knot
|AIRTEMP|	numeric|	Air temperature (degrees Celsius) rounded to nearest whole degree.	|celsius
|CLOUD|	numeric|	Code to represent percentage of cloud cover. See SVDBS.CLOUD	|dimensionless
|BAROPRESS|	numeric|	Barometric pressure (millibars).	|millibar
|WINDDIR|	numeric|	Direction of wind during deployment of gear (degrees).|	degree
|WINDSP|	numeric|	Speed of wind in knots.	|knot
|WEATHER|	numeric|	Code reflecting weather condition. See SVDBS.WEATHER table	|dimensionless
|WAVEHGT|	numeric|	Height of waves (m).|	meter
|SWELLDIR|	numeric|	Swell direction (degrees).|	degree
|SWELLHGT|	numeric|	Swell height (m).|	meter
|BKTTEMP|	numeric|	Surface water temperature (degrees Celsius).	|celsius
|XBT|	numeric|	Code associated with expendable bathythermograph (temperature/depth profile instrument). See SVDBS.XBT	|dimensionless
|SURFTEMP|	numeric|	Surface temperature of water (degrees Celcius).|	celsius
|SURFSALIN|	numeric|	Salinity at water surface in practical salinity units (PSU).	|dimensionless
|BOTTEMP|	numeric|	Bottom temperature (degrees Celsius).|	celsius
|BOTSALIN|	numeric|	Bottom salinity in Practical Salinity Units (PSU).	|dimensionless

**neus_svspp.csv connects species codes to species names.**
| attributeName      | col_classes              | attributeDefinition   | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|SCINAME|	character|	Scientific name for a species|	dimensionless
|SVSPP|	character|	A standard code which represents a species caught in a trawl or dredge. Refer to the SVDBS.SVSPECIES_LIST (if you are looking at the OceanAdapt website, SVSPP.RData)	|dimensionless
|ITISSPP|	character|	species identifiers used by the Integrated Taxonomic Information System (ITIS)|	dimensionless
|COMNAME|	character|	The common name of the marine organism associated with the SCIENTIFIC_NAME	|dimensionless
|AUTHOR|	character|	The author who described the species	|dimensionless

The Ecological Metadata Language file can be accessed [here](https://github.com/pinskylab/OceanAdapt/blob/new_canada_2019/metaData/neus/neus.xml)
