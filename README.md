# OceanAdapt

### To run the compile script, please make sure your working directory is set to the folder containing the compile.R script.  Also, the packages within this script require that R is at least version 3.5.  

### The package versions used in the compile.R script are:
package | verison
tidyverse | 1.2.1
lubridate | 1.7.4
PBSmapping | 2.70.5
data.table | 1.12.0
gridExtra | 2.3
here | 0.1
questionr | 0.6.3
geosphere | 1.5-7

Git repository to support documentation and development of [Ocean Adapt](http://oceanadapt.rutgers.edu)

* [`compile.R`](https://github.com/mpinsky/OceanAdapt/blob/master/compile.R): 
   * the master script that analyzes data for OceanAdapt
   * Comments at head of script provide for instructions on how to run it
* [`data_raw/`](https://github.com/mpinsky/OceanAdapt/tree/master/data_raw): 
   * The trawl data files, as originally downloaded from each source
   * Each file is named by the abbreviated region and the contents of the file, some regions provide data as ranges of years and some regions provide different types of data in different files for all years.
* [`data_clean/`](https://github.com/mpinsky/OceanAdapt/tree/master/data_clean):
  * The major objects created throughout the compile script.  These are generated optionally.
* [`metaData/`](https://github.com/mpinsky/OceanAdapt/tree/master/metaData): 
   * has EML (Ecological Metadata Language) files to document the surveys and the data files. 
   * Example data files are also included. 
     * These are not completely raw data files directly from the surveys, but have been combined into a single file per survey.
* [`R/`](https://github.com/mpinsky/OceanAdapt/tree/master/R): 
   * R code to support OceanAdapt. 
   * Currently has a scripts to 
     * download the raw data from the various websites
     * calculate strata to generate updated strata docs for regions that are missing them.
