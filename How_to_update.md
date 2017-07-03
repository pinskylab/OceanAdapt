# OceanAdapt

We follow these steps to update the OceanAdapt data annually.
---
## Prepare data_raw/ directory for new data files
The first step is to create the folders that will contain the updated data sets. Most of these folders exist. However, the general arrangement is OceanAdapt/data_raw/REGION/DATE, where "REGION" is one of the region abbreviations, and "DATE" is the date the updated data were acquired/ downloaded. Eventually the DATE folder will be compressed into a zip file, and the folder deleted (so you will note see DATE folders for previous years).
1. Within data_raw/, each survey has a sub-directory. 
      1. ai (Aleutian Islands)
      2. ebs (Eastern Bering Sea)
      3. gmex (Gulf of Mexico)
      4. goa (Gulf of Alaska)
      5. neus (Northeast US)
      6. seus (Southeast US)
      7. taxonomy (not a region/ survey, but this folder should exist)
      8. wcann (West Coast Annual)
      9. wctri (West Coast Triennial)
2. Within each survey's sub-directory (*except* "taxonomy"), you should create a folder with naming format exactly `YYYY-MM-DD`, reflecting the date on which you downloaded the latest files for this survey. A date folder should have a full set of data. If you download half the `wcann` data on 2016-10-12, and the other half on 2016-10-14, then just pick one of the dates to use as a folder name, and put all of the data in there. However, if you downloaded the full data set for `wcann` on each of those dates, it's OK to have multiple DATE folders per region-year ([see example here](https://github.com/mpinsky/OceanAdapt/tree/master/data_raw/wcann)). When running the updating scripts, R will look for the most recent folder for each region, and use that. Though it won't cause problems to have multiple date folders for a given year, R will only use the most recent folder and will expect it to contain the full data set for that region.
3. As new data files are acquired for each region, place them in their respective region/date folders.
4. Copy over the strata file from the previous version from this region (presumably it has not changed). There are no strata files for gmex, wctri, or wcann.
5. If you are updating NEUS, copy over SVSPP.Rdata from the previous version of neus (assuming it is not in the update).
6. Zip the survey's sub-directory up
7. Delete the original folder (keeping the .zip)


---
## Acquire new data.  
We want the full dataset every single time, from the start of the survey through the most recent year. This helps catch any updates the surveys have made to past years (they sometimes catch and fix old errors). 
1. **Aleutian Islands** ([ai](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
   * Unzip downloaded files (e.g. "ai1983_200.zip", which will contain same name w/ .csv extension)
   * The files shouldn't need renaming after unzipping. For example, an OK file name would be "ai1983_2000.csv". Just make sure the region name abbreviation is at the start, is followed by numbers, and ends in .csv.
   * Copy over last year's "ai_strata.csv" into this year's folder (data_raw/ai/DATE/)
2. **Eastern Bering Sea** ([ebs](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
   * Repeat the unzipping, renaming, and copying steps of AI (don't forget to copy last year's "ebs_strata.csv")
3. **Gulf of Alaska** ([goa](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
   * Repeat the unzipping, renaming, and copying steps of AI (don't forget to copy last year's "goa_strata.csv")
4. **West Coast Annual** (wcann) is from Northwest Fisheries Science Center. These data are downloaded using one of two methods: R script (yes) or GUI (yuck)
   1. Run the script [R/get_wcann.R](https://github.com/mpinsky/OceanAdapt/blob/master/R/get_wcann.R); this is the preferred method
     <!-- * Rename X to Y
     * Rename X to Y -->
   2. Using a GUI/ map you can download one species at a time (yuck) [here](https://www.nwfsc.noaa.gov/data/)
   3. When you run the R code, you should first set your directory to OceanAdapt/R (or any other directory whose parent is OceanAdapt/). Furthermore, before running the script make sure you create a directory that is OceanAdapt/data_raw/wcann, because the script saves the files there.
5. **Gulf of Mexico** (gmex) is from SEAMAP
   1. These data can be acquired as CSV files from [here](http://seamap.gsmfc.org/); the file is named "public_seamap_csvs.zip" 
      * A non-preferred alternative is to get the Microsoft Access database from the website
      * Another non-preferred alternative is to email Jeff Rester (<jrester@gsmfc.org>) for .CSV outputs
   2. There are usually a lot more files in this zip than what you need. You need to keep the following:
      1. BGSREC.csv
      2. CRUISES.csv
      3. INVREC.csv
      4. NEWBIOCODESBIG.csv
      5. STAREC.csv
   3. The R script you'll eventually run requires that the files are named as above, but to date those have been the default file names (in the unzipped "public_seamap_csvs.zip"), and therefore should not require renaming.
6. **Northeast US** (neus) data are from the Northeast Fisheries Science Center: 
   1. Email Sean Lucey (<sean.lucey@noaa.gov>, preferred) or Jon Hare (<jon.hare@noaa.gov>), and ask for latest survdata.RData file
   2. Other needed data files should be carried over from previous years
      1. Copy neus_strata.csv
      2. Copy neus_svspp.csv (might be redundant with SVSPP.RData)
      3. Copy SVSPP.RData (might be redundant with neus_svspp.csv)
7. **Southeast US** (seus) data are from SEAMAP
   1. [website](https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports)
   2. You have to create an account, which is easy
   3. Once you log in, click "Coastal Trawl Survey Extraction"
   4. In the "Type of Data" menu, you need 2 things: 
      1. Event Information 
      2. Abundance and Biomass
   5. For reach of these, select all values in all other fields, EXCEPT "Depth Zone", for which only "Inner" is needed (get it on the left side). You could do both depth zones, but I was getting errors in 2017 trying to do both depth zones. We only use inner, though.
      * Note: It'll play whack-a-mole with you … have fun! (If you don't encounter this annoyance, don't worry)
   6. There are 3 files you need:
      1. seus_catch.csv  This comes from the "Abundance and Biomass" type of data (need to rename file downloaded from website)
      2. seus_haul.csv This comes from the "Event Information" type of data (need to rename file downloaded from website)
      3. seus_strata.csv This is already in the repo, just copy over from previous year
   7. In the two downloaded files, you need to delete last lines in each file manually (i.e., open them up in a text editor, delete, save)
8. **West Coast Triennial** (wctri): *no longer updated*. Used to be operated by the Alaska Fishery Science Center. But still copy the files over to new year (copy wctri_catch.csv, wctri_haul.csv, wctri_species.csv from data_raw/wctri/2017-06-16.zip [or whatever the previous year's .zip is]).


---
## Prepare the raw data for processing
1. Open [R/update.data.R](https://github.com/mpinsky/OceanAdapt/blob/master/R/update.data.R). The working directory should be set to this script's directory ([R/](https://github.com/mpinsky/OceanAdapt/tree/master/R))
2. The script does a lot of formatting and checking:  
   * The script will check the headers in the files and make sure they are correct, and to only continue saving/ processing columns needed by OA  
   * It strips problematic character formats from files (e.g., escaped quotes)  
   * It concatenates files together (e.g., the AI region has files for different years)   
   * It formats files to be .csv (NEUS comes as .RData)   
   * It normalizes file names across regions (creating, e.g., ai_data.csv)  
   * It creates a .zip file containing the formatted data files for each region  
3. The script will produce a new file called [data_updates](https://github.com/mpinsky/OceanAdapt/tree/master/data_updates)/Data_Updated_YYYY-MM-DD_HH-MM-SS-EDT.zip This file is used by complete_r_script.R (next step)  

---
## Run complete R script  
The complete_r_script.R is used on a server to produce the graphs that are on OceanAdapt. However, before uploading the data to the website so that complete_r_script.R can process these new data, it is good to run the script on your computer ('locally') just to make sure there aren't any problems.
   1. Make sure the directory is set to the folder containing [complete_r_script.R](https://github.com/mpinsky/OceanAdapt/blob/master/complete_r_script.R), which should be the top level
    2. Run the script. It will access the updated files, making specific corrections/ standardizations to data format and content, and calculating statistics etc.

## Upload to website
   1. The website upload requires a zip file containing a "light" version of this repo. The zip file should contain:
      * OceanAdapt/data_updates/Data_Updated_DATE.zip (most recent zip file of updated data)
      * OceanAdapt/R/ (all the R scripts)
      * OceanAdapt/complete_r_script.R
   2. Run the script updateOA.R to create a zip file named OAUpdate.zip that can be uploaded to the OceanAdapt website.
   3. Upload the zip file to the website
   4. After midnight has passed (and the update script has run), make sure it all worked (look at graphs on OceanAdapt)
