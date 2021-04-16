
Maritimes
-------------------------------

**Sources:** 
1. [Maritimes Fall Research Vessel Survey](https://open.canada.ca/data/en/dataset/5f82b379-c1e5-4a02-b825-f34fc645a529)
2. [Maritimes Spring Research Vessel Survey](https://open.canada.ca/data/en/dataset/fecf045a-95a2-4b69-8a40-818649a62716)
3. [Maritimes Summer Research Vessel Survey](https://open.canada.ca/data/en/dataset/1366e1f1-e2c8-4905-89ae-e10f1be0a164)

**Related papers:** 
NA

**How we process the data:**

- We create a haulid by combining the mission, stratum, and depth, separated by "_".
- We calculate the area of the stratum by creating a closed hull of lat lon points, creating a polygon with a map projection, converting to kilometers, and calculating the area of the polygon, all using the function calcarea as defined in the compile.R script.
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue.
- We only keep rows with the season value “SUMMER”

**What the raw data include:**

The current files of raw data for the Maritimes regions are MAR_FALL_MISSIONS.csv, MAR_SPRING_MISSIONS.csv, MAR_SUMMER_MISSIONS.csv, MAR_FALL_INF.csv, MAR_SPRING_INF.csv, MAR_SUMMER_INF.csv, MAR_FALL_CATCH.csv, MAR_SPRING_CATCH.csv, MAR_SUMMER_CATCH.csv

**MAR_FALL_MISSIONS.csv, MAR_SPRING_MISSIONS.csv, and MAR_SUMMER_MISSIONS.csv is constant through the years with the column definitions:**
| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|MISSION |	A 10 character field to identify the survey.|character|dimensionless
|VESEL|	A 1 character code used to identify the vessel.|character|dimensionless
|CRUNO	|The 3 digit identifier for the trip.|character|dimensionless
|YEAR|	The calendar year in which the survey trip occurred.|character|year
|SEASON|	The season of the survey.|character|dimensionless

**MAR_FALL_INF.csv, MAR_SPRING_INF.csv, and MAR_SUMMER_INF.csv is constant through the years with the column definitions:**
| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|MISSION|	A 10 character field to identify the survey.|character|dimensionless
|SETNO|	Each tow is assigned a numeric set identifier starting with 1 for the first tow and then assigned consecutively.|numeric|dimensionless
|SDATE|	The local date at the start of the tow.|character|dimensionless
|TIME|	The local time at the start of the tow.|character|dimensionless
|STRAT|	A numeric code to identify stratum.|numeric|dimensionless
|SLAT|	The latitude at the start of a tow recorded in decimal degrees.|numeric|dimensionless
|SLONG|	The longitude at the start of a tow recorded in decimal degrees.|numeric|dimensionless
|ELAT|	The latitude at the end of a tow recorded in decimal degrees.|numeric|dimensionless
|ELONG|	The longitude at the end of a tow recorded in decimal degrees.|numeric|dimensionless
|DUR|	Duration of tow in minutes.|numeric|dimensionless
|DIST|	The actual tow distance in nautical miles.|numeric|dimensionless
|SPEED|	The average speed of the vessel over bottom, based on GPS, to the nearest tenth of a nautical mile.|numeric|dimensionless
|GEARDESC|	Fishing gear.|character|dimensionless
|DEPTH|	Depth in meters.|numeric|dimensionless
|SURF_TEMP|	Surface Temperature in celsius.|numeric|dimensionless
|BOTT_TEMP|	Bottom temperature in celsius .|numeric|dimensionless
|BOTT_SAL|	Bottom salinity measured in pounds per square unit. |numeric|dimensionless
	
**MAR_FALL_CATCH.csv, MAR_SPRING_CATCH.csv, and MAR_SUMMER_CATCH.csv is constant through the years with the column definitions:**
| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|MISSION|	A 10 character field to identify the survey.|character|dimensionless
|SETNO|	Each tow is assigned a numeric set identifier starting with 1 for the first tow and then assigned consecutively.||
|SPEC|	Unique code to identify species or taxonomic groups in DFO Maritimes Region.|character|dimensionless
|TOTWGT|	Total weight of the catch in kg.|numeric|dimensionless
|TOTNO|	Number of pieces in the catch.|numeric|dimensionless
	
**MAR_FALL_CATCH.csv, MAR_SPRING_CATCH.csv, and MAR_SUMMER_CATCH.csv is constant through the years with the column definitions:**
| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|SPEC|	The scientific name (e.g. genus, species) of the species or taxonomic group.|character|dimensionless
|COMM	|Common name of the species or taxonomic group in English (note: not all species have English common names).|character|dimensionless
|CODE|	Unique code to identify species or taxonomic groups in DFO Maritimes Region.|character|dimensionless
|TSN|	United States Interagency Taxonomic Information System (ITIS) Taxonomic Serial Number (TSN): Internationally recognized unique serial number for species and taxonomic groups.|character|dimensionless

**Citing data from Canada:**
Please refer to the Open Government Licence - Canada
