# OceanAdapt
Git repository to support documentation and development of http://oceanadapt.rutgers.edu

* complete_r_script.R: the master script that analyzes data for OceanAdapt. Read the top of this script for instructions on how to run it.
* data/: has the raw and not-so-raw data from the trawl surveys. Expand the latest Data_Vis_YYYY_MM_DD.zip file for the latest data files, which can be read in directly by complete_r_script.R
* metaData/: has EML (Ecological Markup Language) files to document the surveys and the data files. Example data files are also included. These are not completely raw data files directly from the surveys, but have been combined into a single file per survey.
* R/: R code to support OceanAdapt. Currently has a script to generate the initial metadata for each region and a script to facilitate updating the data each year
