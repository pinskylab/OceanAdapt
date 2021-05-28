Species Quality Analysis/Quality Control (spp_QAQC)
-------------------------------

The spp_QAQC process is associated with the compile.R script, the add-spp-to-taxonomy.Rmd script, and the spp_QAQC folder.

## Process Overview ##

1. Run compile.R until you reach the "Trim Species" section.
2. Open add-spp-to-taxonomy.Rmd and run.
3. Compare flagspp files to excludespp files for each region and contact data providers if discrepancies appeared.
4. Return to compile.R and complete analyses.

## compile.R ###

Once you've adjusted the compile.R script this year and all of the regional data filtration processes are complete, run the compile.R script until the "Trim Species" section. At this point, open the add-spp-to-taxonomy.Rmd script.

## add-spp-to-taxonomy.Rmd ## 

This script is located in the "/R" directory. Running the compile.R script through to the "Trim Species" section will produce two files needed for this markdown script: 1) individual-regions.rds and 2) all-regions-full.rds. 

This script includes two sections.  

*Section 1.* The first section uses a function, "flag_spp()" to produce lists of "suspicious" species from each region. These are species that are present for <95% of surveys and only switch from present to absent (or absent to present) once through the full timeseries. 
These checks are not reliable for surveys less frequent than annual, and thus should not be performed or should be disregarded for WCTRI. This will produce flagspp files in the flagspp directory.

*Section 2.* The second section adds new species to the spptaxonomy.csv. Run the script and check to make sure that the length of "not_in_tax" has not increased substantially from last year (103 taxa currently), and does not contain many taxa with species desginations (i.e., is primarily families or odd designations like "eggs").

## /flagged ##

The first section of add-spp-to-taxonomy.Rmd will produce csvs of "suspicious" species for each region saved within this directory. Please open these files and compare to the excludespp files located in the /exclude_spp directory. If there are additional taxa in a flagspp.csv compared to the excludespp.csv for the same region, please contact the appropriate regional contact (see Regional_Contacts.md) and ask about the taxon or taxa (are they reliably caught, and can they be included?).

## /exclude_spp ##

Contains a list of taxa initially produced from the flagspp.csv files, annotated with notes from the regional contacts and a TRUE/FALSE column for exclusion. Taxa with "TRUE" in this column will be excluded from the data analysis in compile.R.

