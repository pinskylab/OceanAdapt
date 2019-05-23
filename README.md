OceanAdapt
================

<img src="https://user-images.githubusercontent.com/29224545/58205284-33653280-7cac-11e9-94d8-96ffe420ef0d.jpg" width="100%" title="https://www.steveparish-natureconnect.com.au/nature-centre/warm-temperate-and-tropical-oceans/">

News
====

2018 data has been added to OceanAdapt!
---------------------------------------

-   Check out the latest update to the OceanAdapt website. New data in every region!
    [Download the lastest release (full data and code)](https://github.com/mpinsky/OceanAdapt/releases/tag/update2019)

Scotian Shelf Region has been added to OceanAdapt!
--------------------------------------------------

-   Summer, Fall, and Spring seasonal surveys have been added to a new region on the map! (Please note Fall and Spring are under construction)

OceanAdapt has a whole new look!
--------------------------------

-   Thank you to EcoTrust for all of your help in redesigning our website. Just click the red map marker to get started on exploring a region.

OceanAdapt Metadata
===================

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
