Eastern Bering Sea
-------------------------------

**Source:** [NOAA Alaska Fisheries Science Center Groundfish Assessment Program surveys](https://apps-afsc.fisheries.noaa.gov/RACE/groundfish/survey_data/default.htm)

**Related papers:** 
- [Results of the 2010 Eastern and Northern Bering Sea Continental Shelf Bottom Trawl Survey of Groundfish and Invertebrate Fauna](https://archive.fisheries.noaa.gov/afsc/publications/afsc-tm/noaa-tm-afsc-227.pdf)
- [Kotwicki, Stan, and Robert R. Lauth. 2013. “Detecting Temporal Trends and Environmentally-Driven Changes in the Spatial Distribution of Bottom Fishes and Crabs on the Eastern Bering Sea Shelf.” Deep Sea Research Part II: Topical Studies in Oceanography, Understanding Ecosystem Processes in the Eastern Bering Sea II, 94 (October): 231–43.](https://www.sciencedirect.com/science/article/abs/pii/S096706451300115X?via%3Dihub)
- [STEVENSON, D. E., and G. R. HOFF 2009. Species identification confidence in the eastern Bering Sea shelf survey (1982-2008). AFSC Processed Rep. 2009-04, 46 p. Alaska Fish. Sci. Cent., NOAA, Natl. Mar. Fish. Serv., 7600 Sand Point Way NE, Seattle WA 98115.](https://archive.fisheries.noaa.gov/afsc/Publications/ProcRpt/PR2009-04.pdf)
- [Groundfish Bottom Trawl Survey Protocols](https://www.fisheries.noaa.gov/resource/document/noaa-protocols-groundfish-bottom-trawl-surveys)

**How we process the data:**
- Some of the files contain extra headers in the data rows, so we remove any data rows that contain the word “LATITUDE” in the LATITUDE column.
- We create a haulid by combining a 3 digit leading zero vessel number with a 3 digit leading zero cruise number and a 3 digit leading zero haul number, separated by “-”, for example: (vessel-cruise-haul) 354-067-001.
- If wtcpue is recorded as “-9999”, we change the value to NA.
- We remove any SCIENTIFIC spp values that contain the word “egg” or where the only value in the SCIENTIFIC field is white space.
- Any values SCIENTIFIC values that contain the word “Atheresthes” are changed to “Atheresthes sp.” because more than one genus/spp combo was used to describe the same organism over time. This also holds true for Lepidopsetta sp., Myoxocephalus sp., Hippoglossoides sp. & Bathyraja sp.
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue.

**What the raw data includes:**
The current files of raw data for the Eastern Bering Sea are ebs_strata.csv, ebs1982_1984.csv, ebs1985_1989.csv, ebs1990_1994.csv, ebs1995_1999.csv, ebs2000_2004.csv, ebs2005_2008.csv, ebs2009_2012.csv, ebs2013_2016.csv, ebs2017_2019.csv

**ebs_strata.csv is constant through the years with the column definitions:**
| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|NPFMCArea	|North Pacific Fisheries Management Council (NPFMC) area name |	character	|dimensionless
|SubareaDesription | NPFMC subarea name |	character	|dimensionless
|StratumCode |	a numeric character code asigned to each unique stratum, matches STRATUM column in bio dataset |	character	|dimensionless
|DepthIntervalm |	The depth interval of the stratum in 100 meter increments |	character	| meter
|Areakm2 |	The area of the stratum in square kilometers |	numeric | square kilometer

**The remaining files are trawl data files, data added annually, with the column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|LATITUDE	|The latitude (decimal degrees) at the start of the haul|	numeric	|degree
|LONGITUDE |	The longitude (decimal degrees) at the start of the haul|	numeric	|degree
|STATION|Unique sequential order in which stations have been completed. Hangups and short tows each receive a non-repeated consecutive number.|character |dimensionless
|STRATUM	|NA	|character	|dimensionless
|YEAR	|a 4 digit string containing the year of the survey	|character	|dimensionless
|DATETIME	|This is the date and time at the beginning of the haul; This is the date and time at the beginning of the haul; For groundfish trawl data, this is the on-bottom time which is determined after we have looked at the bottom-contact sensor and net-mensuration plots.	|character	|dimensionless
|WTCPUE	|Catch weight per area the net swept in KG/HA.|	numeric	|kilogramsPerHectare
|NUMCPUE	|Catch number per area the net swept in number/HA.	|numeric	|dimensionless
|COMMON |	The common name of the marine organism associated with the SCIENTIFIC_NAME	|character|	dimensionless
|SCIENTIFIC	|The scientific name of the organism associated with the COMMON_NAME.	|character	|dimensionless
|SID	|Domain: [RACE Species Codebook](http://www.afsc.noaa.gov/RACE/groundfish/species_codebook.pdf)	|numeric	|dimensionless
|BOT_DEPTH	|Weighted average depth (m) and is calculated by adding GEAR_DEPTH to NET_HEIGHT. Prior to (year), before NET_HEIGHT was regularly measured, this value was obtained using either echosounder or bathythermograph.	|numeric	|meter
|BOT_TEMP	|Weighted average temperature (in tenths of a degree Celsius) measured at the maximum depth of the headrope of the trawl. Null values indicate temperature not recoreded.	|numeric	|celsius
|SURF_TEMP	|Weighted average temperature (in tenths of a degree Celsius) measured at the sea surface of the trawl. Null values indicate temperature not recoreded.	|numeric	|celsius
|CRUISE	|This is a six-digit number identifying the Cruise number. It is of the form: YYYY99 (where YYYY = year of the cruise; 99 = 2-digit number and is sequential; 01 denotes the first cruise that vessel made in this year, 02 is the second, etc.)|	character	|dimensionless
|HAUL	|This number uniquely identifies a haul within a cruise. It is a sequential number, in chronological order of occurrence.	|numeric	|dimensionless

The Ecological Metadata Language file can be accessed [here](https://github.com/pinskylab/OceanAdapt/blob/new_canada_2019/metaData/ebs/ebs.xml)
