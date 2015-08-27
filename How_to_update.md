# OceanAdapt
We follow these steps to update the OceanAdapt data annually.

1. Acquire new data
   1. We want the full dataset every single time, from the start of the survey through the most recent year. This helps catch any updates the surveys have made to past years (they sometimes catch and fix old errors). 
   2. Alaska Fisheries Science Center: download Aleutian Islands ([ai](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm)), Eastern Bering Sea ([ebs](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm)), and Gulf of Alaska ([goa](http://www.afsc.noaa.gov/RACE/groundfish/survey_data/default.htm))
   3. Northwest Fisheries Science Center: submit a data request form to Beth Horness (<beth.horness@noaa.gov>, see examples in metaData/docs/wcann/) for the West Coast Groundfish Bottom Trawl Survey (wctri).
   4. Gulf of Mexico SEAMAP (gmex): download Microsoft Access database (or, preferably, CSV outputs) from [here](http://seamap.gsmfc.org/) or email Jeff Rester (<jrester@gsmfc.org>) for .CSV outputs
   5. Northeast U.S. (neus): email Sean Tracey (<sean.tracey@noaa.gov>, preferred) or Jon Hare (<jon.hare@noaa.gov>) for latest survdata.RData file
   6. Southeast U.S. (seus): in progress, ask Jim Morley for what to do
   7. West Coast Triennial (wctri): *no longer updated*. Used to be operated by the Alaska Fishery Science Center.

2. Organize new data files into data_raw/ directory
   1. Within data_raw/, each survey has a sub-directory. 
   2. Within each sub-directory, you should create a folder with naming format exactly `YYYY-MM-DD`, reflecting the data on which you downloaded the latest files for this survey.
   3. Put all the files in that new folder.
   4. Copy over the strata file from the previous version from this region (presumably, it has not changed).
   5. Zip it up
   6. Delete the original folder

3. Prepare the raw data for uploading to OceanAdapt website
   1. Eventually, the update.data.R script should handle everything from here. It is not quite there yet.
   2. The script will check the headers in the files and make sure they are correct. It also does a minor amount of concatenating files together. It spits out .zip files containing .csv files, all ready and properly named for uploading to OceanAdapt
   3. The script will produce a new file called data_updates/Data_Updated_YYYY-MM-DD_HH-MM-SS-EDT.zip

4. Upload to website
   1. Unzip the latest data_updates/Data_Updated_YYYY-MM-DD_HH-MM-SS-EDT.zip file
   2. Log in to the OceanAdapt management portal
   3. Click “Data Upload”
   4. Select a region to upload
   5. In the dialog box, select the appropriate .zip file from data_updates/Data_Updated_YYYY-MM-DD_HH-MM-SS-EDT/
   6. Repeat for each region.
   7. After midnight has passed (and the update script has run), make sure it all worked (look at graphs on OceanAdapt)
