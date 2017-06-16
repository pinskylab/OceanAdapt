#OceanAdapt

We follow these steps to update the OceanAdapt data annually.

---
<u>Acquire new data.</u> We want the full dataset every single time, from the start of the survey through the most recent year. This helps catch any updates the surveys have made to past years (they sometimes catch and fix old errors). 
1. Alaska Fisheries Science Center has data for 3 regions:
   1. Aleutian Islands ([ai](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
     * Unzip downloaded files (e.g. "ai1983_200.zip", which will contain same name w/ .csv extension)
     * The files shouldn't need renaming after unzipping. For example, an OK file name would be "ai1983_2000.csv". Just make sure the region name abbreviation is at the start, is followed by numbers, and ends in .csv.
     * You will re-use last year's "ai_strata.csv" file when you get to Step 2 (when you have to create the new folders, etc)
   2. Eastern Bering Sea ([ebs](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
     * Repeat the unzipping, renaming, and copying steps of AI (don't forget to copy last year's "ebs_strata.csv")
   3. Gulf of Alaska ([goa](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
     <!-- * Rename X to Y -->
3. Northwest Fisheries Science Center has the 'wcann' data download using one of two methods:
   1. Run the script [R/get_wcann.R](https://github.com/mpinsky/OceanAdapt/blob/master/R/get_wcann.R); this is the preferred method
     <!-- * Rename X to Y
     * Rename X to Y -->
   2. Using a GUI/ map you can download one species at a time (yuck) [here](https://www.nwfsc.noaa.gov/data/)
4. Gulf of Mexico SEAMAP has the 'gmex' region
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
5. Northeast Fisheries Science Center has data for Northeast U.S. (neus): 
   1. Email Sean Lucey (<sean.lucey@noaa.gov>, preferred) or Jon Hare (<jon.hare@noaa.gov>), and ask for latest survdata.RData file
   2. Other needed data files should be carried over from previous years
     1. Copy neus_strata.csv
     2. Copy neus_svspp.csv (might be redundant with SVSPP.RData)
     3. Copy SVSPP.RData (might be redundant with neus_svspp.csv)
6. SEAMAP has data for Southeast U.S. (seus)
   1. [website](https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports)
   2. You have to create an account, which is easy
   3. Once you log in, click "Coastal Trawl Survey Extraction"
   4. In the "Type of Data" menu, you need 2 things: 
     a. Event Information 
     b. Abundance and Biomass
   5. For reach of these, select all values in all other fields, EXCEPT "Depth Zone", for which only "Inner" is needed (get it on the left side). You could do both depth zones, but I was getting errors in 2017 trying to do both depth zones. We only use inner, though.
     * Note: It'll play whack-a-mole with you … have fun! (If you don't encounter this annoyance, don't worry)
   6. There are 3 files you need:
     a. seus_catch.csv  This comes from the "Abundance and Biomass" type of data (need to rename file downloaded from website)
     b. seus_haul.csv This comes from the "Event Information" type of data (need to rename file downloaded from website)
     c. seus_strata.csv This is already in the repo, just copy over from previous year
   7. In the two downloaded files, you need to delete last lines in each file manually (i.e., open them up in a text editor, delete, save)
7. West Coast Triennial (wctri): *no longer updated*. Used to be operated by the Alaska Fishery Science Center. But still copy the files over to new year

---
<u>Organize new data files into data_raw/ directory</u>
1. Within data_raw/, each survey has a sub-directory. 
2. Within each survey's sub-directory, you should create a folder with naming format exactly `YYYY-MM-DD`, reflecting the date on which you downloaded the latest files for this survey.
3. Put all the files for that survey in that new folder.
4. Copy over the strata file from the previous version from this region (presumably it has not changed). There are no strata files for gmex, wctri, or wcann.
5. If you are updating NEUS, copy over SVSPP.Rdata from the previous version of neus (assuming it is not in the update).
6. Zip the survey's sub-directory up
7. Delete the original folder (keeping the .zip)

---
<u>Prepare the raw data for processing</u>
1. Open [R/update.data.R](https://github.com/mpinsky/OceanAdapt/blob/master/R/update.data.R). The working directory should be set to this script's directory ([R/](https://github.com/mpinsky/OceanAdapt/tree/master/R))
2. The script does a lot of formatting and checking:  
   * The script will check the headers in the files and make sure they are correct, and to only continue saving/ processing columns needed by OA  
   * It strips problematic character formats from files (e.g., escaped quotes)  
   * It concatenates files together (e.g., the AI region has files for different years)   
   * It formats files to be .csv (NEUS comes as .RData)   
   * It normalizes file names across regions (creating, e.g., ai_data.csv)  
   * It creates a .zip file containing the formatted data files for each region  
3. The script will produce a new file called [data_updates](https://github.com/mpinsky/OceanAdapt/tree/master/data_updates)/Data_Updated_YYYY-MM-DD_HH-MM-SS-EDT.zip  

---
<u>Run complete R script  </u>
   1. Make sure the directory is set to the folder containing [complete_r_script.R](https://github.com/mpinsky/OceanAdapt/blob/master/complete_r_script.R), which should be the top level
	 2. From here, complete_r_script.R will access the updated files, making specific corrections/ standardizations to data format and content, and calculating statistics etc.

4. Upload to website
   1. Eventually the website should only need the complete_r_script.R and the most recent data_updated zip file; but a good goal is to provide the folder structure of the github repo, so that helper scripts can be easily incorporated in the future.
   6. Repeat for each region.
   7. After midnight has passed (and the update script has run), make sure it all worked (look at graphs on OceanAdapt)
