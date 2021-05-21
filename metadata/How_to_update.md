# OceanAdapt

We follow these steps to update the OceanAdapt data annually.
---
## Prepare data_raw/ directory for new data files ###
Make sure there is a data_raw directory within the OceanAdapt directory.

---
## Acquire new data.  ###
Run the download_x.R scripts found in the R directory within the OceanAdapt directory.  Some notes:
1. For regions in Alaska (AI, EBS, GOA), there is a function that repeats the download steps for all of the files and regions, however it is important to visit the website and make sure any new files are included in the list of files in the script.

2. West Coast Annual (WCANN), the script will download the data automatically, but one should check that the script is still pointing to the most recent version of the data after download. West Coast Triannual (WCTRI) is no longer active and so the wctri files in the data_raw directory remain the current files to use each year. Do not delete them.

3. For Gulf of Mexico (GMEX), you have to visit the website in the script and download the files to the Downloads folder manually, the script will copy them over to the correct location once they have been downloaded.

4. For Northeast US (NEUS), you have to visit the links (fall and spring) in the script and download the raw data. After download, the script will copy the files over to the correct location. Make sure the links are still up-to-date and the data are the most recent available.

6. For Southeast US (SEUS), you have to visit the website in the script and download the files to the Downloads folder manually, the script will copy them over to the correct location once they have been downloaded. Make sure the links are still up-to-date and the data are the most recent available.

6. For Maritimes (MAR) data, the script will download the data automatically, but one should double check that the script is still pointing to the most recent version of the data by visiting each URL, and seeing the most recent year included in the download.

7. For the Canadian Gulf (CGULF) regions, Gulf of St. Lawrence - South (GSLsouth) and Gulf of St. Lawrence - North (GSLnor), the script will automatically download the correct files and move them to the data_raw folder. However, visit each URL listed in the download_cgulf.R script to make sure the URLs still point to the correct files and the files are up-to-date.

8. For the Canadian Pacific (CPAC) region, the script will automatically download the correct files and move them to the data_raw folder. However, visit each URL listed in the download_cgulf.R script to make sure the URLs still point to the correct files and the files are up-to-date.

---
## Run compile.R script ###
The compile.R is used on a server to produce the graphs that are on OceanAdapt. However, before uploading the data to the website so that script can process these new data, it is good to run the script on your computer ('locally') just to make sure there aren't any problems.
   1. Make sure the directory is set to the folder containing [compile.R](https://github.com/mpinsky/OceanAdapt/blob/master/compile.R), which should be the top level
   2. Run the script. It will access the raw files, making specific corrections/ standardizations to data format and content, and calculating statistics etc.
   3. Check each region's x_hq_dat_removed.png plots to see if data filtration still looks reasonable with additional year's data
   4. If it is your first time running the compile.R script this year, stop before the "Trim Species" section. Open the add-spp-to-taxonomy.Rmd script. See README.md in /spp_QAQC for details on how to continue.
   5. Continue with compile.R through to the end (data anlysis).
---
## Upload to website ###
   1. The website upload requires a zip file containing a "light" version of this repo. The zip file should contain:
      * OceanAdapt/data_raw.zip (most recent zip file of updated data)
      * OceanAdapt/R/ (all the R scripts)
      * OceanAdapt/compile.R
   3. Upload the zip file to the website
   4. After midnight has passed (and the update script has run), make sure it all worked (look at graphs on OceanAdapt)
