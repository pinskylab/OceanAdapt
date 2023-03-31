Within this directory is the collection of RData files previously stored on Amarel. According to Jim Morley the files contain the ensemble projections for RCP 26 and 85 (i.e. the mean projections across 16 GCMs).

FILE DESCRIPTION
Each file contains 21st century projection data for a single species and two representative concentration pathways (RCP 2.6 and RCP 8.5). The files are stored as ‘.RData’ files and each contains a single data frame to be used with R computing software. Each row of data consists of projected catch-per-unit-effort on a natural-log scale, within a specific latitude-longitude referenced grid cell, for one of five time periods (2007-2020, 2021-2040, 2041-2060, 2061-2080, 2081-2100). The projections represent ensemble means from 16 climate models. Thus ‘ensMean26_logged’ is referring to the ensemble mean for RCP 2.6 and ‘ensMean85_logged’ is for RCP 8.5. 

The projection data for the 16 individual climate models are published here: https://doi.org/10.5061/dryad.1m2vn52

FILENAME CONVENTION
The beginning of each file contains the species scientific name.
Following the scientific name the species is identified as either ‘Pacific’ or ‘Atlantic’, the latter of which includes the Gulf of Mexico.

CITATION
Morley JW, Selden RL, Latour RJ, Froelicher TL, Seagraves RJ, Pinsky ML (2018) Projecting shifts in thermal habitat for 686 species on the North American continental shelf. PLoS ONE 13(5): e0196127. https://doi.org/10.1371/journal. pone.0196127 
