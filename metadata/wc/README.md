West Coast U.S.
-------------------------------

**Source:** [NOAA Northwest Fisheries Science Center U.S. West Coast Groundfish Bottom Trawl Survey](https://www.nwfsc.noaa.gov/data/api/v1/source)

**Related papers:** 
- [Munro, P. T. 1998. A decision rule based on the mean square error for correcting relative fishing power differences in trawl survey data. Fish. Bull. 96:538-546.](https://www.st.nmfs.noaa.gov/spo/FishBull/963/munro.pdf)
- [Estimation of the Fishing Power Correction Factor](ftp://ftp.library.noaa.gov/noaa_documents.lib/NMFS/AFSC/AFSC_PR/PR1992-01.pdf)
- [Helser, Thomas, André Punt, and Richard Methot. 2004. “A Generalized Linear Mixed Model Analysis of a Multi-Vessel Fishery Resource Survey.” Fisheries Research 70 (December): 251–64](https://doi.org/10.1016/j.fishres.2004.08.007)
- [Cooper, Andrew B., Andrew A. Rosenberg, Gunnar Stefánsson, and Marc Mangel. 2004. “Examining the Importance of Consistency in Multi-Vessel Trawl Survey Design Based on the U.S. West Coast Groundfish Bottom Trawl Survey.” Fisheries Research, Models in Fisheries Research: GLMs, GAMS and GLMMs, 70 (2): 239–50.](https://doi.org/10.1016/j.fishres.2004.08.006)
- [The Northwest Fisheries Science Center’s West Coast Groundfish Bottom Trawl Survey: History, Design, and Description](https://repository.library.noaa.gov/view/noaa/14179/noaa_14179_DS2.pdf)

**How we process the data:**

**West Coast Annual (wcann)**
- We create a “strata” value by using lat, lon and depth to create a value in 100m bins.
- We calculate a wtcpue value with the units kg per hectare (10,000 m2) by dividing total_catch_wt_kg by area_swept_ha_der.
- We calculate the area of the stratum by creating a closed hull of lat lon points, creating a polygon with a map projection, converting to kilometers, and calculating the area of the polygon, all using the function calcarea as defined in the compile.R script.
- We remove any SPECIES_NAME spp values that contain the word “egg” or where the only value in the SPECIES_NAME field is white space.
- Any values SPECIES_NAME values that contain the word “Lepidopsetta” are changed to “Lepidopsetta sp.” because more than one genus/spp combo was used to describe the same organism over time. This also holds true for Bathyraja sp.
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue.

**West Coast Triennial (wctri)**
- We keep only hauls of type 3 and performance 0.
- We calculate a haulid by combining a 3 digit leading zero vessel number with a 3 digit leading zero cruise number and a 3 digit leading zero haul number, separated by “-”, for example: (vessel-cruise-haul) 354-067-001.
- We create a “strata” value by using lat, lon and depth to create a value in 100m bins.
- We create a wtcpue value with the units weight per hectare (10,000 m2) by multiplying the WEIGHT by 10,000 and dividing by the product of the DISTANCE_FISHED * 1000 * NET_WIDTH.
- We calculate the area of the stratum by creating a closed hull of lat lon points, creating a polygon with a map projection, converting to kilometers, and calculating the area of the polygon, all using the function calcarea as defined in the compile.R script.
- We remove any SPECIES_NAME spp values that contain the word “egg” or where the only value in the SPECIES_NAME field is white space.
- Any values SPECIES_NAME values that contain the word “Lepidopsetta” are changed to “Lepidopsetta sp.” because more than one genus/spp combo was used to describe the same organism over time. This also holds true for Bathyraja sp.
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue

**What the raw data include:**
The current files of raw data for the West Coast U.S. Annual are wcann_catch.csv.zip, wcann_haul.csv.
The files of raw data for the West Coast U.S. Triennial are constant (these surveys are no longer occurring) and are wctri_catch.csv, wctri_haul.csv, and wctri_species.csv.

**wcann_haul.csv files has the column definitions:**
| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|area_swept_ha_der	| Total trawl area in hectares |	numeric	| hectares
|date_yyyymmdd | Survey data |	character	| dimensionless
|depth_hi_prev_m |	Single point estimate for seafloor depth representing the overall seafloor depth in meters for the haul|	numeric	| meters
|invertebrate_weight_kg|	Total catch invertebrate weight in kilograms |	numeric	| kilograms
|latitude_hi_prec_dd |	The latitude portion of a derived single point position for a haul in decimal degrees |	numeric | decimal degrees
|longitude_hi_prec_dd |	The longitude portion of a derived single point position for a haul in decimal degrees |	numeric | decimal degrees
|mean_seafloor_dep_position_type |	Method used for deriving the seafloor depth single point |	character | dimensionless
|midtow_position_type |	Method used for deriving the haul latitude/longitude single point |	character | dimensionless
|nonspecific_organics_weight_kg |	Total non-specific organics weight in kilograms |	numeric | kilograms
|performance |	performance of the operation |	string | dimensionless
|program |	type of fram program |	string | dimensionless
|project |	project name |	string | dimensionless
|sample_duration_hr_der |	Difference in hours between the net liftoff and touchdown times |	numeric | hours
|sampling_end_hhmmss |	concatenation of military hour, minute, second |	string | dimensionless
|sampling_start_hhmmss |	concatenation of military hour, minute, second |	string | dimensionless
|station_code |	unique identifier for a station definition |	string | dimensionless
|tow_end_timestamp |	operation end date timestamp |	string | dimensionless
|tow_start_timestamp |	operation start date timestamp |	string | dimensionless
|trawl_id |	identifier for a sampling operation |	numeric | dimensionless
|vertebrate_weight_kg |		Total catch vertebrate weight in kilograms |	numeric | kilograms
|vessel |	name of the vessel used for the operation |	string | dimensionless
|vessel_id |	field database vessel id number |	numeric | dimensionless
|year |		operation year |	numeric | year
|year_stn_invalid |	Survey year the station became invalid for trawl |	numeric | year


**wcann_catch.csv has column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|catch_id	|unique(legacy) identifier for the catch from a haul, sorted to taxonomic group or debris type.|	numeric	| dimensionless
|common_name |	Only one broadly used common name is supported by this design.|	character	|dimensionless
|cpue_kg_per_ha_der|derivation of catch per unit effort in weight (kilograms) per hectare ordinarily estimated as the expanded haul catch weight divided by the area swept by the net.|numeric |kilograms per hectare
|date_yyyymmdd	|text representation of year month day	|character	|dimensionless
|year |operation year |	numeric | year
|depth_m	|depth low precision measurement in meters to the tenth of a meter (except for special fathom boundaries)|numeric	|meters
|latitude_dd	|numeric representation of latitude in degrees|	numeric	|decimal degrees
|longitude_dd	|numeric representation of longitude in degrees	|numeric	|decimal degrees
|pacfin_spid |	pacfin species id - many taxa may not have one of these	|character|	dimensionless
|partition	|	Refines the partition type	|character	| partition
|performance	|performance of the operation	|string	|dimensionless
|program |	type of fram program |	string | dimensionless
|project |	project name |	string | dimensionless
|sampling_end_hhmmss |	concatenation of military hour, minute, second |	string | dimensionless
|sampling_start_hhmmss |	concatenation of military hour, minute, second |	string | dimensionless
|scientific_name	|This number uniquely identifies a haul within a cruise. It is a sequential number, in chronological order of occurrence.	|numeric	|dimensionless
|station_code |	unique identifier for a station definition |	string | dimensionless
|subsample_count	|count of the subsample used for numbers expansion|	numeric	|dimensionless
|subsample_wt_kg |weight in kilograms of the subsample used for numbers expansion|	numeric	|kilograms
|total_catch_numbers	|numbers expansion for a taxonomic group within a haul.|	numeric	| dimensionless
|total_catch_wt_kg	|total catch weight in kilograms is ordinarily the weight of a taxonomic group within a haul.|	numeric	|kilograms
|tow_end_timestamp |	operation end date timestamp |	string | dimensionless
|tow_start_timestamp |	operation start date timestamp |	string | dimensionless
|trawl_id |	identifier for a sampling operation |	numeric | dimensionless
|vessel |	name of the vessel used for the operation |	string | dimensionless
|vessel_id |	field database vessel id number |	numeric | dimensionless
|year |		operation year |	numeric | year
|year_stn_invalid |	Survey year the station became invalid for trawl |	numeric | year


