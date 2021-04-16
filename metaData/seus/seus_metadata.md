
Southeast U.S. 
-------------------------------

**Source:** [Southeast Area Monitoring and Assessment Program - South Atlantic](http://www.seamap.org/)

**Related papers:** 
- [Descriptions of surveys and data for SEAMAP](https://pinskylab.github.io/OceanAdapt/metaData/seus_seamap_data_descriptions.pdf)
- [SEAMAP-SA Coastal Trawl Survey](http://www.seamap.org/documents/Coastal%20Survey.pdf)

**How we process the data:**
- We remove equal signs and quotes.
- The STRATA column is a subset of the first 2 characters of the STATIONCODE.
- We remove any rows where DEPTHZONE is “OUTER”.
- We change the SEASON column to be “winter” if the month is 1-3, “spring” if the month is 4-6, “summer” if the month is 7 or 8, and “fall” if the month is 9-12.
- We find rows where weight was not provided for a species, calculate the mean weight for those species, and replace the missing values with mean weight.
- We fix some data entry issues with lat lon, specifically, coordinates of less than -360 (like -700), do not exist. This is a missing decimal. We fix this by dividing the value by 10.
- We calculate trawl distance in order to calculate effort.
- There are two COLLECTIONNUMBERS per EVENTNAME, with no exceptions; EFFORT is always the same for each COLLECTIONNUMBER. We sum the two tows.
- We calculate biomass by grouping the data by haulid, stratum, stratumarea, year, lat, lon, depth, SEASON, EFFORT, and spp and summing up the SPECIESTOTALWEIGHT.
- We calculate wtpcue by dividing the biomass by 2 x EFFORT.
- We remove any SPECIESSCIENTIFICNAME spp with the value ‘MISCELLANEOUS INVERTEBRATES’, ‘XANTHIDAE’, ‘MICROPANOPE NUTTINGI’, ‘ALGAE’, ‘DYSPANOPEUS SAYI’, or ‘PSEUDOMEDAEUS AGASSIZII’.
- Any values SPECIESSCIENTIFICNAME spp values that contain the word “ANCHOA” are changed to only “ANCHOA” because more than one genus/spp combo was used to describe the same organism over time. This also holds true for LIBINIA.
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue.
- We split the data out into spring, summer, and fall seasons.

**What the raw data include:**
The current files of raw data for the Aleutian Islands are seus_catch.csv, seus_haul.csv, and seus_strata.csv.

**seus_strata.csv is constant through the years with the column definitions:**
| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|STRATA |	a numeric character code asigned to each unique stratum |	character	|dimensionless
|STRATAHECTARE |	The area of the stratum in hectares |	numeric | hectares

**seus_catch.csv is updated annually, with the column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|PROJECTNAME| Name of the project	| character| dimensionless
|PROJECTAGENCY|	agency implementing the survey| character| dimensionless
|DATE	|date in mm/dd/yy format|character| date
|EVENTNAME|event name is comprised of survey name and survey number | character| dimensionless
|COLLECTIONNUMBER|collection number is comprised of survey year and colleciton number|character|dimensionless	
|VESSELNAME	|name of the vessel|character|dimensionless
|GEARNAME	|equipment and technique used for trawl|character| dimensionless
|GEARCODE	|unique code for each gear type|numeric|dimensionless|SPECIESCODE	|The scientific name of the organism associated with the COMMON_NAME.	|character	|dimensionless
|MRRI_CODE	|?	|numeric	|dimensionless
|SPECIESSCIENTIFICNAME	|scientific name of species caught	|character	|dimensionless
|SPECIESCOMMONNAME	|common name of species if available|character	|dimensionless
|NUMBERTOTAL|total number of individuals caught|numeric|count
|SPECIESTOTALWEIGHT	|	total weight of species caught in kg|numeric	|kilograms
|SPECIESSUBWEIGHT	||	numeric	|kilograms
|SPECIESWGTPROCESSED|||kilograms
|WEIGHTMETHODDESC	|method used to weight catch|character|dimensionless
|ORGWTUNITS	|units of weight (kilograms)|character	|dimensionless
|EFFORT	|NA (blank)|	|
|CATCHSUBSAMPLED	|boolean of subsampled catch|character	|T/F
|CATCHWEIGHT	|catch weight in kilograms|numeric	|kilograms
|CATCHSUBWEIGHT	||numeric	|dimensionless
|TIMESTART	||numeric	|dimensionless
|DURATION	||numeric	|dimensionless
|TOWTYPETEXT	||numeric	|dimensionless
|LOCATION	||numeric	|dimensionless
|REGION	||numeric	|dimensionless
|DEPTHZONE	||numeric	|dimensionless
|ACCSPGRIDCODE	||numeric	|dimensionless
|STATIONCODE	||numeric	|dimensionless
|TEMPSURFACE	||numeric	|dimensionless
|TEMPBOTTOM	||numeric	|dimensionless
|SALINITYSURFACE	||numeric	|dimensionless
|SALINITYBOTTOM	||numeric	|dimensionless
|SDO	||numeric	|dimensionless
|BDO	||numeric	|dimensionless
|TEMPAIR	||numeric	|dimensionless
|LATITUDESTART	||numeric	|dimensionless
|LATITUDEEND	||numeric	|dimensionless
|LONGITUDESTART	||numeric	|dimensionless
|LONGITUDEEND	||numeric	|dimensionless
|SPECSTATUSDESCRIPTION	||numeric	|dimensionless
|LASTUPDATED	||numeric	|dimensionless

**seus_haul.csv is updated annually, with the column definitions:**
| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|PROJECTNAME| Name of the project	| character| dimensionless
|PROJECTAGENCY|	agency implementing the survey| character| dimensionless
|DATE	|date in mm/dd/yy format|character| date
|EVENTNAME|event name is comprised of survey name and survey number | character| dimensionless
|COLLECTIONNUMBER|collection number is comprised of survey year and colleciton number|character|dimensionless	
|VESSELNAME	|name of the vessel|character|dimensionless
|GEARNAME	|equipment used for trawl|character| dimensionless
|GEARCODE	|unique code for each gear type|numeric|dimensionless
|TOWTYPETEXT|method used for trawl|character|dimensionless
|LOCATION	|location of the haul|character|dimensionless
|REGION	|region of the haul|character|dimensionless
|DEPTHZONE|	depth; inner or outer|character|dimensionless
|STATIONCODE|unique code for each station	|character|dimensionless
|EVENTTYPEDESCRIPTION|description of the type of trawl survey|character|dimensionless
|TEMPSURFACE	|ocean surface temperature in degrees celsius|numeric|degrees celsius
|TEMPBOTTOM|ocean bottom temperature in degrees celsius|numeric|degrees celsius
|SALINITYSURFACE|ocean surface salinity in parts per thousand|numeric|parts per thousand
|SALINITYBOTTOM	|ocean bottom salinity in parts per thousand|numeric|parts per thousand
|LIGHTPHASE	|day or night|character|dimensionless
|TIMESTART|time start from 00:00 to 24:00|character|hh:mm
|TIMEZONE	|time zone in three character acronym|character|dimensionless
|DURATION	|duration of trawl in minutes|numeric|minutes
|DEPTHSTART| start depth in meters|numeric|meters
|DEPTHEND|end depth in meters|numeric|meters
|PRESSURE|barometric pressure|numeric|mmHg
|WINDSPEED|wind speed in knots	|numeric|knots
|WINDDIRECTION|wind direction (0-360 degrees)|numeric|degrees
|WAVEHEIGHT	|wave height in meters|numeric|meters
|TEMPAIR	|air temperature in celsius|numeric|degrees celsius
|PRECIPITATION|boolean for preciptation|character| T/F
|ESTIMATEDLOC	|NA||
|LATITUDESTART|latitude of trawl start in decimal degrees|numeric|decimal degrees
|LATITUDEEND	|latitude of trawl end in decimal degrees|numeric|decimal degrees
|LONGITUDESTART|longitude of trawl start in decimal degrees|numeric|decimal degrees
|LONGITUDEEND	|longitude of trawl end in decimal degrees|numeric|decimal degrees
|SDO	|NA||
|BDO|NA||
|SEDSIZEDESC	|categorical description of sediment size |character|dimensionless
|BTMCOMPDESC|NA||
|WEATHERDESC	|NA||
|WATERLVLDESC	|NA||
|ALTERATIONDESC	|NA||
|ACTIVITYDESC	|NA||
|NUMBERREP	|NA||
|ACCSPGRIDCODE|?||
|COMMENTS|comments ("test" or blank)|character|dimensionless
|LASTUPDATED|year of last update|numeric|year

The Ecological Metadata Language file can be accessed [here](https://github.com/pinskylab/OceanAdapt/blob/new_canada_2019/metaData/seus/seus.xml)
