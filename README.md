OceanAdapt
================

<img src="https://user-images.githubusercontent.com/29224545/58205284-33653280-7cac-11e9-94d8-96ffe420ef0d.jpg" width="100%">

Git repository to support documentation and development of the [Ocean Adapt](http://oceanadapt.rutgers.edu) website

[Download the lastest release (full data and code)](https://github.com/mpinsky/OceanAdapt/releases/tag/update2019)

OceanAdapt Metadata

-   [\[data\_clean\](https://github.com/mpinsky/OceanAdapt/tree/update\_2019/data\_clean)](#data_clean)
-   [\[data\_raw\](https://github.com/mpinsky/OceanAdapt/tree/update\_2019/data\_raw)](#data_raw)

[data\_clean](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean)
--------------------------------------------------------------------------------

The data we report on OceanAdapt are curated from several data sources. Our curated data can be found here:

-   [all-regions-full.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/all-regions-full.RData) is a table containing all rows from all regions with the following columns:
    -   region - character - the region where the survey occurred.
    -   haulid - character - a unique identifier of the trawl haul.
    -   year - numeric (YYYY) - the year the trawl occurred.
    -   lat - numeric - the latitude in decimal degrees where the trawl occurred.
    -   lon - numeric - the longitude in decimal degrees where the trawl occurred.
    -   stratum - numeric - the stratum code where the trawl occurred.
    -   depth - numeric - the depth in meters of the trawl.
    -   spp - character - the Genus and species of the organism captured in the trawl.
    -   common - character - the common name of the organism captured in the trawl.
    -   wtcpue - numeric - the weight in kilograms captured per unit effort.
-   [all-regions-trimmed.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/all-regions-trimmed.RData) is the all-regions\_full table reduced to include only species present at least 3/4 of the available years in a survey. The columns are the same as those listed above.
-   [by\_national.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/by_national.RData) is a table of national averages by year for the trawl surveys with the following columns:
    -   year - numeric (YYYY) - the year the trawl occurred.
    -   lat - numeric - the mean latitude in decimal degrees where all trawls occurred.
    -   lon - numeric - the mean longitude in decimal degrees where all trawls occurred.
    -   depth - numeric - the mean depth in meters of all trawls.
    -   lat\_se - numeric - the standard error of the mean latitude.
    -   lonse - numeric - the standard error of the mean longitude.
    -   depth\_se - numeric - the standard error of the mean depth.
    -   numspp - numeric - the total number of species observed that year.
-   [by\_region.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/by_region.RData) is a table of regional averages by year for the trawl surveys with the following columns:
    -   region - character - the region where the survey occurred.
    -   year - numeric (YYYY) - the year the trawl occurred.
    -   lat - numeric - the mean latitude in decimal degrees where all trawls occurred.
    -   lon - numeric - the mean longitude in decimal degrees where all trawls occurred.
    -   depth - numeric - the mean depth in meters of all trawls.
    -   lat\_se - numeric - the standard error of the mean latitude.
    -   lonse - numeric - the standard error of the mean longitude.
    -   depth\_se - numeric - the standard error of the mean depth.
    -   numspp - numeric - the total number of species observed that year in that region.
-   [by\_species.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/by_species.RData) is a table of averages by species for the trawl surveys with the following columns:
    -   region - character - the region where the survey occurred.
    -   year - numeric (YYYY) - the year the trawl occurred.
    -   lat - numeric - the mean latitude in decimal degrees where the species was found in a given year.
    -   lon - numeric - the mean longitude in decimal degrees where the species was found in a given year.
    -   depth - numeric - the mean depth in meters where the species was found in a given year.
    -   lat\_se - numeric - the standard error of the mean latitude.
    -   lonse - numeric - the standard error of the mean longitude.
    -   depth\_se - numeric - the standard error of the mean depth.
    -   spp - character - the Genus and species of the organism captured in the trawl.
    -   common - character - the common name of the organism captured in the trawl.
-   [dat\_exploded.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/by_species.RData) a table where all species found in a region occupy a row in the table in all years and represented with zeros when not observed. The table is made up of the same columns as all-data-full and all-data-trimmed.

[data\_raw](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_raw)
----------------------------------------------------------------------------

contains data that are downloaded from the websites of various government agencies. Raw data is regionally sourced and those sources are the best place to find the most current information about the raw data: - [Alaska Fisheries Science Center - NOAA](https://www.afsc.noaa.gov/RACE/groundfish/survey_data/metadata_template.php?fname=RACEweb.xml) - This NOAA center provides data for the Aleutian Islands, Eastern Bering Sea, and Gulf of Alaska. Files provided by the Alaska Fisheries Science Center: - ai1983\_2000.zip - ai2002\_2012.zip - ai2014\_2018.zip - ebs1982\_1984.zip - ebs1985\_1989.zip - ebs1990\_1994.zip - ebs1995\_1999.zip - ebs2000\_2004.zip - ebs2005\_2008.zip - ebs2009\_2012.zip - ebs2013\_2016.zip - ebs2017\_2018.zip - goa1984\_1987.zip - goa1990\_1999.zip - goa2001\_2005.zip - goa2007\_2013.zip - goa2015\_2017.zip

The columns contained in all of these files are the same: - LATITUDE in decimal degrees (double) - LONGITUDE in decimal degrees (double) - STATION a character description of the station number (character) - STRATUM a unique stratum identifier (double) - YEAR the year of the survey (double) (YYYY) - DATETIME the date and time of the trawl (character) (MM/DD/YYYY HH:MM) - WTCPUE the weight caught per unit effort in kg (double) - NUMCPUE the number caught per unit effort (double) - COMMON the common name of the species caught (character) - SCIENTIFIC the scientific name of the species caught (character) - SID the species identifier (double) - BOT\_DEPTH the bottom depth in meters (double) - BOT\_TEMP the bottom temperature in degrees Celcius (double) - SURF\_TEMP the surface temperature in degrees Celcius (double) - VESSEL the vessel identifier (double) - CRUISE the cruise identifier (double) - HAUL the haul identifier (double)

In addition to the data files, there are strata files that were generated by hand typing strata information into a csv file. The strata files are: - ai\_strata.csv - ebs\_strata.csv - goa\_strata.csv The columns for these files are: - NPFMCArea the location of the stratum (character) - Subarea Description description of location of stratum (character) - StratumCode unique identifier of stratum (double) - DepthIntervalm the range of depth in meters (character) - Areakm2 the area of the stratum in kilometers squared (double)

-   [Northwest Fisheries Science Center - NOAA](https://www.nwfsc.noaa.gov/research/divisions/fram/index.cfm) - This NOAA center provides data for the West Coast Triennial and West Coast Annual surveys. The files provided are:
    -   wcann\_catch.csv.zip this file is zipped because it is so large. It holds the catch data for the West Coast Annual surveys.
    -   wctri\_catch.csv this file holds the West Coast Triennial catch data. For both of these files, the columns are:
    -   catch\_id a unique row identifier (double)
    -   common\_name the common name for the species caught (character)
    -   cpue\_kg\_per\_ha\_der the calculated catch per unit effort in units of kilogram per hectare (double)
    -   cpue\_numbers\_per\_ha\_der the calculated catch per unit effort in units of number caught per hectare (double)
    -   date\_yyyymmdd the date of the trawl in the format yyyymmdd (double)
    -   depth\_m the depth in meters (double)
    -   latitude\_dd the latitude of the trawl in decimal degrees (double)
    -   longitude\_dd the longitude of the trawl in decimal degrees (double)
    -   pacfin\_spid the unique species identifier (character)
    -   partition notes about the catch (character)
    -   performance value can be "Satisfactory", "Unsatisfactory", or "Indeterminate" (character)
    -   program value is "Bottom Trawl" (character)
    -   project value is "Groundfish Slope and Shelf Combination Survey" (character)
    -   sampling\_end\_hhmmss the time sampling ended in the format of hhmmss (character)
    -   sampling\_start\_hhmmss the time sampling began in the format of hhmmss (character)
    -   scientific\_name the scientific name of the species captured (character)
    -   station\_code the unique identifier of the station where sampling occurred (double)
    -   subsample\_count the number of fish of this species counted (double)
    -   subsample\_wt\_kg the weight of the subsample in kilograms (double)
    -   total\_catch\_numbers the number of fish of this species captured in this haul (double)
    -   total\_catch\_wt\_kg the total weight of fish of this species in this haul (double)
    -   tow\_end\_timestamp the date and time the tow ended in the format yyyy-mm-dd hh:mm:ss (character)
    -   tow\_start\_timestamp the date and time the tow began in the format yyyy-mm-dd hh:mm:ss (character)
    -   trawl\_id the unique trawl identifier (double)
    -   vessel the name of the ship that ran the survey (character)
    -   vessel\_id the unique identifier for the ship (double)
    -   year the year the trawl occurred in YYYY format (double)
    -   year\_stn\_invalid a column that holds no values (character)

The files that pertain to haul conditions are: - wcann\_haul.csv - wctri\_haul.csv The columns in these files are: - X1 the row number (double) - area\_swept\_ha\_der the calculated area covered by the haul in hectares (double) - date\_yyyymmdd the date of the haul in the format yyyymmdd (double) - depth\_hi\_prec\_m the high precision depth of the haul in meters (double) - invertebrate\_weight\_kg the weight in kilograms of invertebrates captured in the haul (double) - latitude\_hi\_prec\_dd the high precision latitude of the haul in decimal degrees (double) - longitude\_hi\_prec\_dd the high precision longitude of the haul in decimal degrees (double) - mean\_seafloor\_dep\_position\_type the type of position at mean seafloor depth (character) - midtow\_position\_type the type of position at midtow (character) - nonspecific\_organics\_weight\_kg the weight in kilograms of non-specific organics (double) - performance value can be "Satisfactory", "Unsatisfactory", or "Indeterminate" (character) - program value is "Bottom Trawl" (character) - project value is "Groundfish Slope and Shelf Combination Survey" (character) - sample\_duration\_hr\_der the calculated duration of the sampling event in hours (double) - sampling\_end\_hhmmss the time that sampling ended in hhmmss (character) - sampling\_start\_hhmmss the time that sampling began in hhmmss (character) - station\_code the unique identifier of the station where sampling occurred (double) - tow\_end\_timestamp the date and time the tow ended in the format yyyy-mm-dd hh:mm:ss (character) - tow\_start\_timestamp the date and time the tow began in the format yyyy-mm-dd hh:mm:ss (character) - trawl\_id the unique trawl identifier (double) - vertebrate\_weight\_kg the weight in kilograms of vertebrates captured in the haul (double) - vessel the name of the ship that ran the survey (character) - vessel\_id the unique identifier for the ship (double) - year the year the trawl occurred in YYYY format (double) - year\_stn\_invalid a column that holds no values (character)

-   [Gulf States Marine Fisheries online SEAMAP access](https://seamap.gsmfc.org/documents/SEAMAP_Data_Structures.pdf) - This program provides data for the Gulf of Mexico. The files provided are:
-   gmex\_BGSREC.csv.zip this file is zipped due to large size. The columns for this file are: BGSID = col\_double(), CRUISEID = col\_double(), STATIONID = col\_double(), VESSEL = col\_double(), CRUISE\_NO = col\_double(), P\_STA\_NO = col\_character(), CATEGORY = col\_double(), GENUS\_BGS = col\_character(), SPEC\_BGS = col\_character(), BGSCODE = col\_logical(), CNT = col\_double(), CNTEXP = col\_double(), SAMPLE\_BGS = col\_double(), SELECT\_BGS = col\_double(), BIO\_BGS = col\_double(), NODC\_BGS = col\_double(), IS\_SAMPLE = col\_character(), TAXONID = col\_logical(), INVRECID = col\_logical(), X20 = col\_character()

-   [Northeast Fisheries Science Center](https://www.nefsc.noaa.gov/rcb/projects/ntap/) - This NOAA center provides data for the Northeast US.
-   [SEAMAP South Atlantic](https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports) - This program provides data for the Southeast US.
-   [Canadian Department of Fisheries and Oceans](http://www.dfo-mpo.gc.ca/index-eng.htm) - Canada DFO provides data for the Scotian Shelf.
