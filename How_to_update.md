# OceanAdapt

We follow these steps to update the OceanAdapt data annually.

1. Acquire new data. We want the full dataset every single time, from the start of the survey through the most recent year. This helps catch any updates the surveys have made to past years (they sometimes catch and fix old errors). 
   1. Alaska Fisheries Science Center has data for 3 regions:
      1. Aleutian Islands ([ai](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
        <!-- * Rename X to Y -->
      2. Eastern Bering Sea ([ebs](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
        <!-- * Rename X to Y -->
      3. Gulf of Alaska ([goa](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
        <!-- * Rename X to Y -->
   3. Northwest Fisheries Science Center has the 'wcann' data download using one of two methods:
      1. [R/get_wcann.R](https://github.com/mpinsky/OceanAdapt/blob/master/R/get_wcann.R)
        <!-- * Rename X to Y
        * Rename X to Y -->
      2. Using a GUI/ map you can download one species at a time (yuck) [here](https://www.nwfsc.noaa.gov/data/)
   4. Gulf of Mexico SEAMAP has the 'gmex' region, and the data can be acquired as  
      1. CSV files from [here](http://seamap.gsmfc.org/) (note: can also get Microsoft Access database, but not preferred)
        <!-- * Rename X to Y -->
        <!-- * Rename X to Y -->
      2. Or email Jeff Rester (<jrester@gsmfc.org>) for .CSV outputs (no preferred, though)
   5. Northeast Fisheries Science Center has data for Northeast U.S. (neus): 
      1. Email Sean Lucey (<sean.lucey@noaa.gov>, preferred) or Jon Hare (<jon.hare@noaa.gov>), and ask for latest survdata.RData file
      2. Other needed data files should be carried over from previous years
   6. SEAMAP has data for Southeast U.S. (seus)
      1. [website](https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports); need to delete last lines in each file manually
   7. West Coast Triennial (wctri): *no longer updated*. Used to be operated by the Alaska Fishery Science Center.
      1. But still copy the files over to new year

2. Organize new data files into data_raw/ directory
   1. Within data_raw/, each survey has a sub-directory. 
   2. Within each survey's sub-directory, you should create a folder with naming format exactly `YYYY-MM-DD`, reflecting the date on which you downloaded the latest files for this survey.
   3. Put all the files for that survey in that new folder.
   4. Copy over the strata file from the previous version from this region (presumably it has not changed). There are no strata files for gmex, wctri, or wcann.
   5. If you are updating NEUS, copy over SVSPP.Rdata from the previous version of neus (assuming it is not in the update).
   6. Zip the survey's sub-directory up
   7. Delete the original folder (keeping the .zip)

3. Prepare the raw data for processing
   1. Open [R/update.data.R](https://github.com/mpinsky/OceanAdapt/blob/master/R/update.data.R). The working directory should be set to this script's directory ([R/](https://github.com/mpinsky/OceanAdapt/tree/master/R))
   2. The script does a lot of formatting and checking:  
      * The script will check the headers in the files and make sure they are correct, and to only continue saving/ processing columns needed by OA  
      * It strips problematic character formats from files (e.g., escaped quotes)  
      * It concatenates files together (e.g., the AI region has files for different years)   
      * It formats files to be .csv (NEUS comes as .RData)   
      * It normalizes file names across regions (creating, e.g., ai_data.csv)  
      * It creates a .zip file containing the formatted data files for each region  
   3. The script will produce a new file called [data_updates](https://github.com/mpinsky/OceanAdapt/tree/master/data_updates)/Data_Updated_YYYY-MM-DD_HH-MM-SS-EDT.zip  
4. Run complete R script  
   1. Make sure the directory is set to the folder containing [complete_r_script.R](https://github.com/mpinsky/OceanAdapt/blob/master/complete_r_script.R), which should be the top level
	 2. From here, complete_r_script.R will access the updated files, making specific corrections/ standardizations to data format and content, and calculating statistics etc.

4. Upload to website
   1. Eventually the website should only need the complete_r_script.R and the most recent data_updated zip file; but a good goal is to provide the folder structure of the github repo, so that helper scripts can be easily incorporated in the future.
   6. Repeat for each region.
   7. After midnight has passed (and the update script has run), make sure it all worked (look at graphs on OceanAdapt)
