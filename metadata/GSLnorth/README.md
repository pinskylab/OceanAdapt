
Gulf of St. Lawrence North
-------------------------------

**Sources:** 

1.[DFO Evaluation of groundfish annual multidisciplinary survey in the northern Gulf of St. Lawrence (MV Lady Hammond 1984 - 1990)](https://open.canada.ca/data/en/dataset/86a9d0b0-fcce-48ed-a124-68061d7b7553)

2.[DFO Evaluation of groundfish annual multidisciplinary winter survey in the northern Gulf of St. Lawrence (MV Gadus Atlantica 1978 - 1994)](https://open.canada.ca/data/en/dataset/4bbd03ce-ae48-4aaa-97ac-5594c2a3a6c2)

3.[DFO Mobile gear sentinel fisheries program - northern Gulf of St. Lawrence (1995-present)](https://open.canada.ca/data/en/dataset/929fe07f-ab8e-4b3c-8ee3-1aa7a9ea0b1a)

4.[DFO Evaluation of groundfish and shrimp annual multidisciplinary survey in the Estuary and northern Gulf of St. Lawrence (CCGS Alfred Needler 1990 - 2005)](https://open.canada.ca/data/en/dataset/4eaac443-24a8-4b37-9178-d7cce4eb7c7b)

5.[DFO Evaluation of groundfish and shrimp annual multidisciplinary survey in the Estuary and northern Gulf of St. Lawrence (CCGS Teleost 2004 - 2019)](https://open.canada.ca/data/en/dataset/40381c35-4849-4f17-a8f3-707aa6a53a9d)

**Related papers:** 

NA

**How we process the data:**

- We remove latitude and depth records that are "NA". 
- We create a haulid by combining a mission number, a set number, the start date, and start hour, separated by “-”, for example: (mission-set-date-hour) "1-1-1984-07-07 -11:55:00".
- We create a stratum column by grouping latitude and longitude (rounded to nearest degree), and depth (rounded to nearest 100 meters), separated by "-", for example: (lat-lon-depth) "47--60-500"
- We calculate stratum area using the convex hull approach.
- We remove any SCIENTIFIC spp values that contain the word “EGG”, "UNIDENTIFIED", or where the only value in the SCIENTIFIC field is white space.
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue.

**What the raw data includes:**

The current files of raw data for the Gulf of St. Lawrence North are GSLnorth_gadus.csv, GSLnorth_hammond.csv, GSLnorth__needler.csv, GSLnorth_sentinel.csv, and GSLnorth_teleost.

**All of these files are trawl data files, data added annually, with the column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|NOM_NAVIRE	|Ship name|character |dimensionless
|NO_RELEVE	|	Mission number|numeric	|dimensionless
|TRAIT	|	Set number|numeric	|dimensionless
|DATE_DEB_TRAIT	|	Start date of the set (yyyy-mm-dd)|character |dimensionless
|DATE_FIN_TRAIT	|	End date of the set (yyyy-mm-dd)|character |dimensionless
|HRE_DEB	|Start time of the set (hh:mm:ss)|character |dimensionless
|HRE_FIN	|	End time of the set (hh:mm:ss)|character |dimensionless
|TYPE_HRE	|	Hour type (0 = standard, 1 = daylight saving)|character |dimensionless
|DUREE	|	Set duration (min)|numeric	|minute
|LATIT_DEB	|Start latitude (degree)|	numeric	|degree
|LONGIT_DEB	|Start longitude (degree)|	numeric	|degree
|LATIT_FIN	|End latitude (degree)|	numeric	|degree
|LONGIT_FIN	|	End longitude (degree)|	numeric	|degree
|DIST_CHALUTE_POSITION	|	Distance trawled (nautical miles)|numeric	|nautical miles
|VIT_TOUAGE	|	Trawling speed (knots)|numeric	|knots
|OPANO	|	Nafo division|character |dimensionless
|ENGIN	|	Fishing gear|character |dimensionless
|COD_RESULT_OPER	|Result of the fishing activity (1 = No damage to gear, 2 = Minor damage to gear - Catch unaffected)|numeric	|dimensionless
|PROF_MIN	|	Minimal depth (m)|numeric	|meters
|PROF_MAX	|	Maximum depth (m)|numeric	|meters
|NOM_SCIENT_ESP	|	Scientific name of the species |character |dimensionless
|PDS_CAPTURE	|Capture weight (kg)|numeric	|kilograms
|NB_IND_CAPTURE	|Number of specimen caughtx|numeric	|dimensionless


