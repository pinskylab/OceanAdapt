# OceanAdapt
<img src="http://pinsky.marine.rutgers.edu/wp-content/uploads/2016/07/cropped-Himokilan_Cuatros_Islas_MichelleStuart.jpg" width="500">

Git repository to support documentation and development of [Ocean Adapt](http://oceanadapt.rutgers.edu)  

[Download the lastest release (full data and code)](https://github.com/mpinsky/OceanAdapt/releases/tag/2018.1.0)  

Repository navigation:
* [`complete_r_script.R`](https://github.com/mpinsky/OceanAdapt/blob/master/complete_r_script.R): 
   * the master script that analyzes data for OceanAdapt
   * Comments at head of script provide for instructions on how to run it
* [`data_updates/`](https://github.com/mpinsky/OceanAdapt/tree/master/data_updates): 
   * The trawl data, ready to be uploaded to the OceanAdapt website
   * Each `Data_Updated_YYYY-MM-DD_HH-MM-SS-EDT.zip` file contains (or should eventually contain, once we fix some bugs) a set of zip files. Each zip file is for a particular trawl survey and is in the format that the OceanAdapt website expects upon uploading.
* [`data_raw/`](https://github.com/mpinsky/OceanAdapt/tree/master/data_raw): 
   * The trawl data files, as originally downloaded from each source
   * Each sub-directory is for a trawl survey in a particular region
   * Within each sub-directory, a zip file `YYYY-MM-DD.zip` contains the complete set of trawl data, as updated on that day.
* [`metaData/`](https://github.com/mpinsky/OceanAdapt/tree/master/metaData): 
   * has EML (Ecological Metadata Language) files to document the surveys and the data files. 
   * Example data files are also included. 
     * These are not completely raw data files directly from the surveys, but have been combined into a single file per survey.
* [`R/`](https://github.com/mpinsky/OceanAdapt/tree/master/R): 
   * R code to support OceanAdapt. 
   * Currently has a scripts to 
     * generate the initial metadata for each region 
     * facilitate updating the data each year
