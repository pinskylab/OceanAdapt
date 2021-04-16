
Gulf of St. Lawrence South
-------------------------------

**Source:** 

[NAFO Division 4T groundfish research vessel trawl survey (September Survey) dataset](https://open.canada.ca/data/en/dataset/1989de32-bc5d-c696-879c-54d422438e64)

**Related papers:** 

NA

**How we process the data:**

- We create a haulid by combining the start year, month, day, hour, and minute, separated by “-”, for example: (year-month-day-hour-minute) "1971-9-8-14-5".
- We create a stratum column by grouping latitude and longitude (rounded to nearest degree), separated by "-", for example: (lat-lon) "47--65".
- We calculate stratum area using the convex hull approach.
- We remove any SCIENTIFIC spp values that contain the word “EGG”, "UNIDENTIFIED", or where the only value in the SCIENTIFIC field is white space.
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue.

**What the raw data include:**

The current file of raw data for the Gulf of St. Lawrence South is GSLsouth.csv.

**All of these files are trawl data files, data added annually, with the column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|year|The year when the station was surveyed|numeric|year
|month|	The month when the station was surveyed|numeric|month
|day|	The day when the station was surveyed|numeric|day
|start_hour|	The hour when the station was surveyed (start of tow)|character|hour
|start_minute|The minute when the station was surveyed (start of tow)|character|minute
|latitude	|Average latitude taken from start and end positions of the station surveyed (in decimal degrees)|numeric|decimal degrees
|longitude|	Average longitude taken from start and end positions of the station surveyed (in decimal degrees)|numeric |decimal degrees
|gear|	The fishing gear used in a set|character|dimensionless
|species|	Gulf region species code|character|dimensionless
|english_name|	English name of the species identified in station being surveyed|character|dimensionless
|latin_name|	Latin name of the species identified in station being surveyed|character|dimensionless
|french_name|	French name of the species identified in station being surveyed|character|dimensionless
|weight_caught|	The total weight in kilograms of a specific species caught in the set|numeric|kilogram
|number_caught|	The estimated total number of specimens of a specific species which was caught in a set|numeric|dimensionless



