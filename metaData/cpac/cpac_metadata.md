
Canadian Pacific
-------------------------------

**Sources:** 

1.[DFO Queen Charlotte Sound Synoptic Bottom Trawl Survey](https://open.canada.ca/data/en/dataset/86af7918-c2ab-4f1a-ba83-94c9cebb0e6c)

2.[DFO West Coast Vancouver Island Synoptic Bottom Trawl Survey](https://open.canada.ca/data/en/dataset/557e42ae-06fe-426d-8242-c3107670b1de)

3.[DFO Hecate Strait Synoptic Bottom Trawl Survey](https://open.canada.ca/data/en/dataset/780a1c02-1f9c-4994-bc70-a0e9ef8e3968)

4.[DFO West Coast Haida Gwaii Synoptic Bottom Trawl Survey](https://open.canada.ca/data/en/dataset/5ee30758-b1d6-49fe-8c4e-5136f4b39ad1)

5.[DFO Strait of Georgia Synoptic Bottom Trawl Survey](https://open.canada.ca/data/en/dataset/d880ba18-8790-41a2-bf73-e9247380759b)

**Related papers:** 

1. [A reproducible data synopsis for over 100 species of British Columbia groundfsh](https://www.dfo-mpo.gc.ca/csas-sccs/Publications/ResDocs-DocRech/2019/2019_041-eng.pdf)

**How we process the data:**

For each subregion:

- We create a haulid by combining the "trip identifier" with the set number, separated by “-”, for example: (mission-set-date-hour) "1-1-1984-07-07 -11:55:00".
- We create a stratum column by grouping latitude and longitude (rounded to nearest degree), and depth (rounded to nearest 100 meters), separated by "-", for example: (lat-lon-depth) "49--124-300"
- We calculate stratum area using the convex hull approach.
- We remove any SCIENTIFIC spp values that contain the word “EGG”, "UNIDENTIFIED", or where the only value in the SCIENTIFIC field is white space.
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue.

**What the raw data include:**

The current files of raw data for the Canadian Pacific are:

  Queen Charlotte Sound: QCS_biology.csv, QCS_biomass.csv, QCS_catch.csv, QCS_effort.csv.

  West Coast Vancouver Island: WCV_biology.csv, WCV_biomass.csv, WCV_catch.csv, WCV_effort.csv.

  Hecate Strait: HS_biology.csv, HS_biomass.csv, HS_catch.csv, HS_effort.csv.

  West Coast Haida Gwaii: WCHG_biology.csv, WCHG_biomass.csv, WCHG_catch.csv, WCHG_effort.csv.

  Strait of Georiga: SOG_biology.csv, SOG_biomass.csv, SOG_catch.csv, SOG_effort.csv.

**All of these files are trawl data files, data added annually, with the column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|Survey Year|	The calendar year in which the survey trip occurred|numeric |year
|Trip identifier	|Unique GFBio identifier for the fishing trip|character |dimensionless
|Set number|	Each deployment of trawl fishing gear, or fishing event, is called a tow or set, and is numbered consecutively within each survey trip|numeric |dimensionless
|Vessel name|	The name of the research or charter vessel that conducted the survey trip|character |dimensionless
|Trip start date|	Date the survey trip begins (usually the date the vessel leaves the dock for the first time)|character |dimensionless
|Trip end date|	Date the survey trip ends (usually the date the vessel returns to the dock at the end of the survey)|character |dimensionless
|GMA|	Groundfish management areas used in DFO Pacific Region (http://www.pac.dfo-mpo.gc.ca/fm-gp/maps-cartes/ground-fond/ground-fond-eng.html), also known as Pacific States Marine Fisheries Commission (PSMFC) areas.|character |dimensionless
|PFMA	|Pacific Fishery Management Area (http://www.pac.dfo-mpo.gc.ca/fm-gp/maps-cartes/areas-secteurs/index-eng.html)|character |dimensionless
|Set date|	Date the fishing occurred|character |dimensionless
|Start latitude|	Latitude of the fishing start location (decimal degrees)|numeric |decimal degrees
|Start longitude|	Longitude of the fishing start location (decimal degrees)|numeric |decimal degrees
|End latitude|	Latitude of the fishing end location (decimal degrees)|numeric |decimal degrees
|End longitude|	Longitude of the fishing end location (decimal degrees)|numeric |decimal degrees
|Bottom depth (m)|	Modal bottom depth for the tow in metres|numeric |meters
|Tow duration (min)|	Duration in minutes that the net was on bottom (fishing), based on data from a bottom contact sensor; if bottom contact sensor data not available, elapsed time in minutes between deploying and retrieving gear.|numeric |minutes
|Distance towed (m)	|Distance in metres travelled while fishing|numeric |meters
|Vessel speed (m/min)	|Speed of vessel in metres per minute while fishing|numeric |meters per minute
|Trawl door spread (m)|	Distance in metres between trawl doors; if door sensor data not available,  mean doorspread for the survey trip.  Preferred metric for calculating swept area.|numeric |meters
|Trawl mouth opening height (m)|	Net mouth opening height in metres|numeric |meters
|Trawl mouth opening width (m)	|Net mouth opening width in metres|numeric |meters
|ITIS-TSN|	United States Interagency Taxonomic Information System (ITIS) Taxonomic Serial Number (TSN): Internationally recognized unique serial number for species and taxonomic groups.|character |dimensionless
|Species code|	Unique code to identify species or taxonomic groups in DFO Pacific Region|character |dimensionless
|Scientific name|	The scientific name (e.g. genus, species) of the species or taxonomic group.|character |dimensionless
|English common name|	Common name of the species or taxonomic group in English (note: not all species have English common names)|character |dimensionless
|French common name	|Common name of the species or taxonomic group in French (note: not all species have French common names)|character |dimensionless
|LSID|	"Life Sciences Identifier" - a persistent and independent identifier for biological resources using a URN (Uniform Resource Name) namespace|character |dimensionless
|Catch weight (kg)|	Total weight of the catch in kg|numeric |kilograms
|Catch count (pieces)|	Estimated number of pieces in the catch|numeric |dimenionless
|Sample identifier|	The unique record identifier for the sample.|character |dimensionless
|Specimen identifier|	The unique record identifier for the specimen.|character |dimensionless
|Fork length (mm)	|For species with a forked tail: length in millimeters, measured from the tip of the snout in a straight line to the posterior end of the shortest caudal rays in the centre of the fork. |numeric |milimeters 
|Total length (mm)|	For species without a forked tail: length in millimetres measured from the tip of the snout in a straight line to the posterior end of the caudal fin.|numeric |milimeters 
|Standard length (mm)|	For most pelagic species (e.g. smelts, herring, anchovy): length in millimetres measured from the tip of the snout in a straight line to the midlateral posterior edge of the hypural plate (in fish with a hypural plate) or to the posterior end of the vertebral column (in fish lacking a hypural plate).|numeric |milimeters 
|Second dorsal length (mm)	|For ratfish: length in millimetres measured from the snout to the posterior edge of the posterior lobe of the second dorsal fin.|numeric |milimeters 
|Sex	|Sex of the fish: 0 = not examined; 1 = male; 2 = female, 3 = unknown|character |dimensionless
|Weight (g)|	Whole round weight in grams|numeric |grams
|Age sample	|YES = Age structures were collected; NO = No age structures were collected.|character |dimensionless
|Genetics (DNA) sample|	YES = Genetics (DNA) samples were collected; NO = No genetics (DNA) samples were collected.|character |dimensionless
|Age|	Estimated age of the fish|numeric |years
|Set count|	Total number of sets in the survey for a particular year|numeric |dimensionless
|Number of positive sets	|Number of sets that caught the species of interest|numeric |dimensionless
|Biomass index	|Relative biomass index (kg)|numeric |kilograms
|Lower interval|	Bootstrapped 95% confidence interval|numeric |dimensionless
|Upper interval|	Bootstrapped 95% confidence interval|numeric |dimensionless
|CV	|Coefficient of variation of the bootstrapped biomass|numeric |dimensionless


