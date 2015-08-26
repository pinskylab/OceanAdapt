# OceanAdapt
Git repository to support documentation and development of [Ocean Adapt](http://oceanadapt.rutgers.edu)

* [`complete_r_script.R`](https://github.com/mpinsky/OceanAdapt/blob/master/complete_r_script.R): 
   * the master script that analyzes data for OceanAdapt
   * Comments at head of script provide for instructions on how to run it
* [`data_updates/`](https://github.com/mpinsky/OceanAdapt/tree/master/data_updates): 
   * raw and not-so-raw data from the trawl surveys  
   * Most recent `Data_Vis_YYYY_MM_DD.zip` contains data files for use with `complete_r_script.R`  
* [`metaData/`](https://github.com/mpinsky/OceanAdapt/tree/master/metaData): 
   * has EML (Ecological Metadata Language) files to document the surveys and the data files. 
   * Example data files are also included. 
     * These are not completely raw data files directly from the surveys, but have been combined into a single file per survey.
* [`R/`](https://github.com/mpinsky/OceanAdapt/tree/master/R): 
   * R code to support OceanAdapt. 
   * Currently has a scripts to 
     * generate the initial metadata for each region 
     * facilitate updating the data each year
