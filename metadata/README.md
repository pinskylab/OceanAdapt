OceanAdapt Metadata
================

data\_clean
--------------------------------------------------------------------------------

The data we report on OceanAdapt are curated from several data sources. Our curated data can be found here:

-   [all-regions-full.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/all-regions-full.RData) is a table containing all rows from all regions with the following columns:
    -   region - character - the region where the survey occurred.
    -   haulid - character - a unique identifier of the trawl haul.
    -   year - numeric - the year the trawl occurred.
    -   lat - numeric - the latitude in decimal degrees where the trawl occurred.
    -   lon - numeric - the longitude in decimal degrees where the trawl occurred.
    -   stratum - numeric - the stratum code where the trawl occurred.
    -   depth - numeric - the depth in meters of the trawl.
    -   spp - character - the Genus and species of the organism captured in the trawl.
    -   common - character - the common name of the organism captured in the trawl.
    -   wtcpue - numeric - the weight in kilograms captured per unit effort.
-   [all-regions-trimmed.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/all-regions-trimmed.RData) is the all-regions\_full table reduced to include only species present at least 3/4 of the available years in a survey. The columns are the same as those listed above.
-   [by\_national.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/by_national.RData) is a table of national averages by year for the trawl surveys with the following columns:
    -   year - numeric - the year the trawl occurred.
    -   lat - numeric - the mean latitude in decimal degrees where all trawls occurred.
    -   lon - numeric - the mean longitude in decimal degrees where all trawls occurred.
    -   depth - numeric - the mean depth in meters of all trawls.
    -   lat\_se - numeric - the standard error of the mean latitude.
    -   lonse - numeric - the standard error of the mean longitude.
    -   depth\_se - numeric - the standard error of the mean depth.
    -   numspp - numeric - the total number of species observed that year.
-   [by\_region.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/by_region.RData) is a table of regional averages by year for the trawl surveys with the following columns:
    -   region - character - the region where the survey occurred.
    -   year - numeric - the year the trawl occurred.
    -   lat - numeric - the mean latitude in decimal degrees where all trawls occurred.
    -   lon - numeric - the mean longitude in decimal degrees where all trawls occurred.
    -   depth - numeric - the mean depth in meters of all trawls.
    -   lat\_se - numeric - the standard error of the mean latitude.
    -   lonse - numeric - the standard error of the mean longitude.
    -   depth\_se - numeric - the standard error of the mean depth.
    -   numspp - numeric - the total number of species observed that year in that region.
-   [by\_species.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/by_species.RData) is a table of averages by species for the trawl surveys with the following columns:
    -   region - character - the region where the survey occurred.
    -   year - numeric - the year the trawl occurred.
    -   lat - numeric - the mean latitude in decimal degrees where the species was found in a given year.
    -   lon - numeric - the mean longitude in decimal degrees where the species was found in a given year.
    -   depth - numeric - the mean depth in meters where the species was found in a given year.
    -   lat\_se - numeric - the standard error of the mean latitude.
    -   lonse - numeric - the standard error of the mean longitude.
    -   depth\_se - numeric - the standard error of the mean depth.
    -   spp - character - the Genus and species of the organism captured in the trawl.
    -   common - character - the common name of the organism captured in the trawl.
-   [dat\_exploded.RData](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean/by_species.RData) a table where all species found in a region occupy a row in the table in all years and represented with zeros when not observed. The table is made up of the same columns as all-data-full and all-data-trimmed.

data\_raw
----------------

contains data that are downloaded from the websites of various government agencies. Raw data is regionally sourced and those sources are the best place to find the most current information about the raw data:
- [Alaska Fisheries Science Center - NOAA](https://www.afsc.noaa.gov/RACE/groundfish/survey_data/metadata_template.php?fname=RACEweb.xml) - This NOAA center provides data for the Aleutian Islands, Eastern Bering Sea, and Gulf of Alaska.
- [Northwest Fisheries Science Center - NOAA](https://www.nwfsc.noaa.gov/research/divisions/fram/index.cfm) - This NOAA center provides data for the West Coast Triennial and West Coast Annual surveys.
- [Gulf States Marine Fisheries online SEAMAP access](https://seamap.gsmfc.org/documents/SEAMAP_Data_Structures.pdf) - This program provides data for the Gulf of Mexico.
- [Northeast Fisheries Science Center](https://www.nefsc.noaa.gov/rcb/projects/ntap/) - This NOAA center provides data for the Northeast US.
- [SEAMAP South Atlantic](https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports) - This program provides data for the Southeast US.
- [Canadian Department of Fisheries and Oceans](http://www.dfo-mpo.gc.ca/index-eng.htm) - Canada DFO provides data for the Scotian Shelf, Gulf of St. Lawrence, and Canadian Pacific.

R
----------------
within this directory are all R scripts used for data acquisition and processing, except compile.R

Python
----------------
Contains the OAGenerateRasterFiles.py script, which is used to make the maps of interpolated biomass hosted on oceanadapt.rutgers.edu.


plots
----------------
within this directory are all plots generated by compile.R and add_spp_to_taxonomy.Rmd

compile.R plots:
   - sppcentdepthstrat.png
   - sppcentlatstrat.png
   - regional-lat.png
   - regional-depth.png
   - national-lat.png
   - national-depth.png
   - and all (region)\_hq\_dat\_removed.png 

add_spp_to_taxonomy.Rmd plots:
   - all (region)\_tax_check_test.png


spp\_QAQC
----------------
Within this directory are two folders, /flagged and /exclude\_spp

- /flagged contain a .csv file for each region containing rows for each species "flagged" as suspicious by our taxonomy QAQC script contained in the add_spp_to_taxonomy.Rmd file

- /exclude\_spp contains a .csv file for each region containing rows for each species and an "exclude" column with TRUE/FALSE flags based on data provider comments


figures
----------------
within this directory are figures used to summarize and present on OceanAdapt and scripts used to generate them.





