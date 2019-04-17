OceanAdapt Metadata
================

-   [[data\_clean](../data_clean)](#data_clean)
-   [data\_raw folder](#data_raw-folder)
-   [compile.R script](#compile.r-script)
-   [plots](#plots)
-   [metaData folder](#metadata-folder)

[data\_clean](../data_clean)
----------------------------

The data we report on OceanAdapt are curated from several data sources. Our curated data can be found here:

-   [all-regions-full.RData](../data_clean/all-regions-full.RData) is a table containing all rows from all regions with the following columns:
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
-   [all-regions-trimmed.RData](../data_clean/all-regions-trimmed.RData) is the all-regions\_full table reduced to include only species present at least 3/4 of the available years in a survey. The columns are the same as those listed above.
-   [by\_national.RData](../data_clean/by_national.RData) is a table of national averages by year for the trawl surveys with the following columns:
    -   year - numeric - the year the trawl occurred.
    -   lat - numeric - the mean latitude in decimal degrees where all trawls occurred.
    -   lon - numeric - the mean longitude in decimal degrees where all trawls occurred.
    -   depth - numeric - the mean depth in meters of all trawls.
    -   lat\_se - numeric - the standard error of the mean latitude.
    -   lonse - numeric - the standard error of the mean longitude.
    -   depth\_se - numeric - the standard error of the mean depth.
    -   numspp - numeric - the total number of species observed that year.
-   [by\_region.RData](../data_clean/by_region.RData) is a table of regional averages by year for the trawl surveys with the following columns:
    -   region - character - the region where the survey occurred.
    -   year - numeric - the year the trawl occurred.
    -   lat - numeric - the mean latitude in decimal degrees where all trawls occurred.
    -   lon - numeric - the mean longitude in decimal degrees where all trawls occurred.
    -   depth - numeric - the mean depth in meters of all trawls.
    -   lat\_se - numeric - the standard error of the mean latitude.
    -   lonse - numeric - the standard error of the mean longitude.
    -   depth\_se - numeric - the standard error of the mean depth.
    -   numspp - numeric - the total number of species observed that year in that region.
-   [by\_species.RData](../data_clean/by_species.RData) is a table of averages by species for the trawl surveys with the following columns:
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
-   [dat\_exploded.RData](../data_clean/by_species.RData) a table where all species found in a region occupy a row in the table in all years and represented with zeros when not observed. The table is made up of the same columns as all-data-full and all-data-trimmed.

data\_raw folder
----------------

contains data that are downloaded from the websites of various government agencies. Raw data is regionally sourced and those sources are the best place to find the most current information about the raw data:
- [Alaska Fisheries Science Center - NOAA](https://www.afsc.noaa.gov/RACE/groundfish/survey_data/metadata_template.php?fname=RACEweb.xml) - This NOAA center provides data for the Aleutian Islands, Eastern Bering Sea, and Gulf of Alaska.
- [Northwest Fisheries Science Center - NOAA](https://www.nwfsc.noaa.gov/research/divisions/fram/index.cfm) - This NOAA center provides data for the West Coast Triennial and West Coast Annual surveys.
- [Gulf States Marine Fisheries online SEAMAP access](https://seamap.gsmfc.org/documents/SEAMAP_Data_Structures.pdf) - This program provides data for the Gulf of Mexico.
- [Northeast Fisheries Science Center](https://www.nefsc.noaa.gov/rcb/projects/ntap/) - This NOAA center provides data for the Northeast US.
- [SEAMAP South Atlantic](https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports) - This program provides data for the Southeast US.
- [Canadian Department of Fisheries and Oceans](http://www.dfo-mpo.gc.ca/index-eng.htm) - Canada DFO provides data for the Scotian Shelf.

compile.R script
----------------

generates tables that vary slightly from the orignal raw data. All of these tables can be found as RData in the [data\_clean](https://github.com/mpinsky/OceanAdapt/tree/update_2019/data_clean) folder. Descriptions of the tables follow.
- [all-regions-full.RData](https://github.com/mpinsky/OceanAdapt/blob/update_2019/data_clean/all-regions-full.RData) - all of the raw data from all regions, combined, and reduced to the following columns:

    - region - the region where the trawl survey was conducted.
    - haulid - a unique identifier of each tow.
    - year - the year the survey was conducted in %YYYY format.
    - lat - the latitude where the tow was conducted in decimal units.
    - lon - the longitude where the tow was conducted in decimal units.
    - stratum - the stratum identifier for the tow.
    - stratumarea - the area in km^2 covered by the tow.
    - depth - the depth in meters of the tow.
    - spp - the scientific name of the species observed in the tow.
    - common - the common name of the speices observed in the tow.
    - wtcpue - the weight of catch per unit effort for the species in the tow.  

-   [all-regions-trimmed.RData](https://github.com/mpinsky/OceanAdapt/blob/update_2019/data_clean/all-regions-trimmed.RData) - the full data table above reduced to include only speices that are in present in at least 3/4 of the years for each region.

    -   region - the region where the trawl survey was conducted.
    -   haulid - a unique identifier of each tow.
    -   year - the year the survey was conducted in %YYYY format.
    -   lat - the latitude where the tow was conducted in decimal units.
    -   lon - the longitude where the tow was conducted in decimal units.
    -   stratum - the stratum identifier for the tow.
    -   stratumarea - the area in km^2 covered by the tow.
    -   depth - the depth in meters of the tow.
    -   spp - the scientific name of the species observed in the tow.
    -   common - the common name of the speices observed in the tow.
    -   wtcpue - the weight of catch per unit effort for the species in the tow.

-   [by-national.RData](https://github.com/mpinsky/OceanAdapt/blob/update_2019/data_clean/by_national.RData) - shows the national averages, reduced to only data sets with consistent methods over time.

    -   year - the year the survey was conducted in %YYYY format.
    -   lat - the mean latitude where the tows were conducted in decimal units.
    -   lon - the mean latitude where the tows were conducted in decimal units.
    -   depth - the mean depth in meters of the tows.
    -   lat\_se - the standard error of the mean latitude for the year.
    -   lonse - the standard error of the mean longitude for the year.

    -   depth\_se - the standard error of the mean depth for the year.
    -   numspp - the number of species observed for the year.

-   [by-region.RData](https://github.com/mpinsky/OceanAdapt/blob/update_2019/data_clean/by_region.RData) - shows the regional averages by year.

    -   region - the region where the trawl survey was conducted.
    -   year - the year the survey was conducted in %YYYY format.
    -   lat - the latitude where the tow was conducted in decimal units.
    -   lon - the longitude where the tow was conducted in decimal units.
    -   depth - the depth in meters of the tow.
    -   lat\_se - the standard error of the mean latitude for the year.
    -   lonse - the standard error of the mean longitude for the year.

    -   depth\_se - the standard error of the mean depth for the year.
    -   numspp - the number of species observed for the year.

-   [by-species.RData](https://github.com/mpinsky/OceanAdapt/blob/update_2019/data_clean/by_species.RData) - shows the annual averages by species within regions.

    -   region - the region where the trawl survey was conducted.
    -   spp - the scientific name of the species observed in the tow.
    -   common - the common name of the speices observed in the tow.
    -   year - the year the survey was conducted in %YYYY format.
    -   lat - the latitude where the tow was conducted in decimal units.
    -   lon - the longitude where the tow was conducted in decimal units.
    -   depth - the depth in meters of the tow.
    -   lat\_se - the standard error of the mean latitude for the year.
    -   lonse - the standard error of the mean longitude for the year.

    -   depth\_se - the standard error of the mean depth for the year.

-   [dat\_exploded.RData](https://github.com/mpinsky/OceanAdapt/blob/update_2019/data_clean/dat_exploded.Rdata) - this file contains all speices by region in all years.

    -   region - the region where the trawl survey was conducted.
    -   haulid - a unique identifier of each tow.
    -   year - the year the survey was conducted in %YYYY format.
    -   lat - the latitude where the tow was conducted in decimal units.
    -   lon - the longitude where the tow was conducted in decimal units.
    -   stratum - the stratum identifier for the tow.
    -   stratumarea - the area in km^2 covered by the tow.
    -   depth - the depth in meters of the tow.
    -   spp - the scientific name of the species observed in the tow.
    -   common - the common name of the speices observed in the tow.
    -   wtcpue - the weight of catch per unit effort for the species in the tow.

plots
-----

This folder holds plots used to check that the data is being processed as expected.

metaData folder
---------------

This folder contains many documents related to the collection and calculation of the data found on the OceanAdapt website. - [00-scripts]()

    - [gen-cols-units]() - a helper script to define units for generating Ecological Metadata Language (EML) documents.  
    - metaData.template.R

-   [ai]()

    -   adp\_codebook\_2011.pdf
    -   AFSC\_Aleutians\_metadata.txt
    -   ai\_345fd2.csv - a sample data set
    -   metaData.ai.R - a script for generating an EML file for the ai data set.
    -   metaData\_AI.xml - an EML file for the ai data set.
    -   Orr et al. 2014 species identification in GoA and AI surveys.pdf
    -   species\_codebook\_2011.pdf
    -   Stauffer 2003 groundfish protocols.pdf
    -   von Szalay et al. 2011.pdf
    -   Wayne Palsson 2012-03-29 Meaning of STATION.pdf

-   [ebs]()

    -   AFSC EBS strata map.jpg
    -   AFSC\_EBS\_metadata.txt
    -   EBS Spp ID Confidence 2009-04.pdf
    -   ebs\_121213.csv - sample data
    -   Kotwicki & Lauth in prep.pdf
    -   Lauth 2010 NOAA-TM-AFSC-227.pdf
    -   metaData.ebs.R - a script for generating an EML file for this data set
    -   metaData\_EBS.xml - an EML file for this dataset.

-   [gmex]()

    -   filedef.doc
    -   filestr.doc
    -   gmex\_25d0f9.csv - sample data
    -   Grace et al. 2010 Marine Fish Review.pdf
    -   metaData.gmex.R - a script for generating an EML file for this data set
    -   metaData\_gmex.xml - an EML doc for this dataset.
    -   Rester 2012-06-28-SEAMAP data.pdf
    -   SEAMAP-gmex\_metadata.txt
    -   SEDAR7\_DW1.pdf
    -   SEDAR7\_DW53.pdf

-   [goa]()

    -   AFSC\_GOA\_metadata.txt
    -   goa\_2f7db6.csv - sample data
    -   metaData.goa.R - a script for writing an EML document
    -   metaData\_GOA.xml - an EML document
    -   von Szalay et al. 2010 NOAA-TM-AFSC-208.pdf - this document was used to define the stratum areas for goa, hand typed into the goa\_strata.csv file.

-   [neus]()

    -   flescher1980 common trawl-caught fish.pdf
    -   metaData.neus.R - a script for writing an EML file
    -   metaData\_NEUS.xml - an EML file
    -   NEFSC trawl strata.pdf
    -   NEFSC\_metadata.txt
    -   NEFSC\_overview\_www.gulfofmaine-census.org.html
    -   NEUS\_6f90fb.csv
    -   neus\_strata\_map.gif
    -   neusStrata.csv
    -   SeanLucycode folder

        -   bigelow\_fall\_calibration.csv
        -   bigelow\_spring\_calibration.csv
        -   Survdat\_calibrate.r
        -   survey.r

    -   Sosebee & Cardin 2006 inshore bottom trawl survey.pdf
    -   strata\_shapefile folder - contains GIS layers
    -   SVDBS Elements by Table and Column.docx
    -   SVDBSvariabledefinitions.pdf
    -   svspp.tsv
    -   SWG 1988 evaluation of bottom trawl - NMFS.pdf

-   [ocean\_adapt\_docs]()

    -   oa\_upload\_colNames.txt
    -   Ocean Adapt Report - 6-30-2016.docx

-   [scot]()
-   [seus]()
-   [taxonomy]()
-   [wcann]()
-   [wctri]()
