
Gulf of Mexico
-------------------------------

**Source:** [Gulf States Marine Fisheries Commission SEAMAP Groundfish Surveys](http://seamap.gsmfc.org/)

**Related papers:** 
- [Gulf of Mexico Operations Manual](https://seamap.gsmfc.org/documents/SEAMAP%20Operations%20Manual%20March%202016.pdf)
- [Derivation of Red Snapper Time Series from SEAMAP and Groundfish Trawl Surveys](http://sedarweb.org/docs/wpapers/SEDAR7_DW1.pdf)
- [Comparisons of Relative Fishing Powers of Selected SEAMAP Survey Vessels](http://sedarweb.org/docs/wpapers/SEDAR7_DW53.pdf)
- [Fishery-independent Bottom Trawl Surveys for Deep-water Fishes and Invertebrates of the U.S. Gulf of Mexico, 2002-08](https://spo.nmfs.noaa.gov/sites/default/files/pdf-content/MFR/mfr724/mfr7242.pdf)
- [SEAMAP Oracle DMS definitions](http://seamap.gsmfc.org/documents/filedef.doc)

**How we process the data:**
- gmex_STAREC.csv has characters that prevent it from being parsed easily. We attempt to make parsing more manageable by replacing the quotes in quoted character strings using the R regex below then reading the file in as a csv.
```
gmex_station_clean <- str_replace_all(gmex_station_raw, "\\\\\"", "")
```
- We only keep gear type “ST”.
- We trim out young of year records (only useful for count data) and those with UNKNOWN species.
- We make two combined records where ‘ANTHIAS TENUIS AND WOODSI’, ‘MOLLUSCA AND UNID.OTHER #01’ share the same species code.
- We trim to high quality SEAMAP summer trawls, based off the subset used by Jeff Rester’s GS_TRAWL_05232011.sas.
- We create a haulid by combining a 3 digit leading zero vessel number with a 3 digit leading zero cruise number and a 3 digit leading zero haul number, separated by “-”, for example: (vessel-cruise-haul) 354-067-001.
- We convert fathoms to meters.
- We create a “strata” value by using lat, lon and depth to create a value in 100m bins.
- We trim out or fix speed and duration records by trimming out tows of 0, >60, or unknown minutes.
- We fix VESSEL_SP typo according to Jeff Rester: 30 = 3.
- We trim out vessel speeds 0, unknown, or >5 (need vessel speed to calculate area trawled).
- We remove a tow when paired tows exist, same lat/lon/year but different haulid.
- We adjust wtcpue (biomass per standard tow) for area towed, in units of kg per 10,000 m2. Calculate area trawled in m2: knots * 1.8 km/hr/knot * 1000 m/km * minutes * 1 hr/60 min * width of gear in feet * 0.3 m/ft.
- We remove unidentified spp, white space only values, and adjust the following names:
```
    !spp %in% c('UNID CRUSTA', 'UNID OTHER', 'UNID.FISH', 'CRUSTACEA(INFRAORDER) BRACHYURA', 'MOLLUSCA AND UNID.OTHER #01', 'ALGAE', 'MISCELLANEOUS INVERTEBR', 'OTHER INVERTEBRATES')
  ) %>% 
  # adjust spp names
  mutate(
    spp = ifelse(GENUS_BGS == 'PELAGIA' & SPEC_BGS == 'NOCTUL', 'PELAGIA NOCTILUCA', spp), 
    BIO_BGS = ifelse(spp == "PELAGIA NOCTILUCA", 618030201, BIO_BGS), 
    spp = ifelse(GENUS_BGS == 'MURICAN' & SPEC_BGS == 'FULVEN', 'MURICANTHUS FULVESCENS', spp), 
    BIO_BGS = ifelse(spp == "MURICANTHUS FULVESCENS", 308011501, BIO_BGS), 
    spp = ifelse(grepl("APLYSIA", spp), "APLYSIA", spp), 
    spp = ifelse(grepl("AURELIA", spp), "AURELIA", spp), 
    spp = ifelse(grepl("BOTHUS", spp), "BOTHUS", spp), 
    spp = ifelse(grepl("CLYPEASTER", spp), "CLYPEASTER", spp), 
    spp = ifelse(grepl("CONUS", spp), "CONUS", spp), 
    spp = ifelse(grepl("CYNOSCION", spp), "CYNOSCION", spp), 
    spp = ifelse(grepl("ECHINASTER", spp), "ECHINASTER", spp),
    spp = ifelse(grepl("OPISTOGNATHUS", spp), "OPISTOGNATHUS", spp), 
    spp = ifelse(grepl("OPSANUS", spp), "OPSANUS", spp), 
    spp = ifelse(grepl("ROSSIA", spp), "ROSSIA", spp), 
    spp = ifelse(grepl("SOLENOCERA", spp), "SOLENOCERA", spp), 
    spp = ifelse(grepl("TRACHYPENEUS", spp), "TRACHYPENEUS", spp)
 ```
- We group the data by haulid, stratum, stratumarea, year, lat, lon, depth, and spp and then sum up all of the wtcpue values for each group and reassign that as the wtcpue.


**What the raw data include:**
The current files of raw data for the Gulf of Mexico are gmex_BGSREC.csv, gmex_CRUISES.csv, gmex_INVREC.csv, gmex_NEWBIOCODESBIG.csv, gmex_STAREC.csv.

**gmex_BGSREC.csv column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|BGSID	|a unique integer assigned for each entry in the BGSREC table| numeric|	dimensionless
|CRUISEID|	a unique integer assigned for each entry in the CRUISES table|numeric|	dimensionless
|STATIONID	| a unique integer assigned for each entry in the STAREC table.|numeric|	dimensionless
|VESSEL|	a unique integer representing the Vessel name, from the VESSELS table|	numeric| dimensionless
|CRUISE_NO|	a four character string usually in the format YYXX. Such as 1304 for year 2013, fourth survey| numeric|	dimensionless
|P_STA_NO	|the Pascagoula Station Number. A five character string, using in the format of VVSSSS where VV is the vessel number and SSSS is a sequential count of the stations processed for that survey. The P_STA_NO entry should be unique for each STAREC entry per Cruise. P_STA_NO may repeat for different CRUISEIDS.| numeric|	dimensionless
|CATEGORY	|A one character field which is a code. The program assigns a code to this field based on the first character value of the biocode number. A first position biocode digit which is ‘1’ is assigned a category code of ‘3’. A first position biocode digit which is ‘2’ is assigned a category code of ‘1’. All other first position biocode digits are assigned a category code of ‘2’. It may NOT be blank or null.|character|	dimensionless
|GENUS_BGS|	A seven character field which contains the genus part of the genus/species name. This field may not be blank and should contain a valid genus name. It may NOT be blank or null.|character|	dimensionless
|SPEC_BGS	|a six character field which contains the species part of the genus/species name. It may be blank or null.|character|	dimensionless
|BGSCODE|	a one character field which contains a bgs code. Valid values are T,E,C,S,I. It may be blank or null.|character|	dimensionless
|CNT	|a six digit numeric field which represents the number of genus/species sampled. This is an integer field. Value may be blank only when the genus/species was select. It must contain a value > 0 when genus/species was ‘sample’.|	numeric|dimensionless
|CNTEXP|	an eight digit numeric field which represents one of two possible values. If the genus/species is sampled, this value is the extrapolated count of the genus/species. If the genus/species is a select, this value is the actual number of the genus/species that was selected. It may not be blank or null.|	numeric| dimensionless
|SAMPLE_BGS|	a seven character field which must be numeric. This field contains a number which must be in XXX.XXX format and represents weight in kilograms.|numeric|	kilogram
|SELECT_BGS|	seven character field which must be numeric. This field contains a number which must be in XXX.XXX format and represents select weight in kilograms. It may be blank or null.|numeric|	kilogram
|BIO_BGS|	a 9 digit field containing a number (biocode) which is based on the genus/species name.|character|	dimensionless
|NODC_BGS|	is a numeric field. This field contains a number which is based on the genus/species name. (Not Implemented/or used currently).|character|	dimensionless
|IS_SAMPLE|	a one character field which is a code. A ‘Y’ indicates when the genus/species is sampled. Sample records have a value in the count field and the sample field. An ‘N’ indicates the genus/species is select. Select records should have a value in the count expanded field and the select weight field. It may NOT be blank or null. It should contain either ‘Y’ or ‘N’.|character|	dimensionless
|TAXONID|	a numeric field. Not currently utilized.|numeric|	dimensionless
|INVRECID	|a unique integer assigned for each entry in the INVREC table.|numeric|	dimensionless
|X20|	unknown	||

**gmex_CRUISES.csv column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|CRUISEID|	a unique integer assigned for each entry in the CRUISES table|numeric|	dimensionless
|YR	| Year of the survey|numeric|	year
|SOURCE|two character code for survey location (state or US territorial waters)	|	character| dimensionless
|VESSEL	|a unique integer vessel code| numeric|	dimensionless
|CRUISE_NO|	a unique three character cruise number| numeric|	dimensionless
|STARTCRU	| start date of cruise in dd/mm/yy format| character|	dimensionless
|ENDCRU	|end date of cruise in dd/mm/yy format |character|	dimensionless
|TITLE|	survey season and project title|character|	dimensionless
|NOTE	|integer code to indicate numer of notes associated|numeric|	dimensionless
|INGEST_SOURCE|	?|character|	dimensionless
|INGEST_PROGRAM_VER	|?|	character|dimensionless

**gmex_INVREC.csv column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|INVRECID|	a unique integer assigned for each entry in the INVREC table. |numeric|	dimensionless
|STATIONID	| a unique integer assigned for each entry in the CRUISES table.|numeric|	year
|CRUISEID| a unique integer assigned for each entry in the STAREC table.	|	character| dimensionless
|VESSEL	| a unique integer representing the Vessel name, from the VESSELS table.| numeric|	dimensionless
|CRUISE_NO|	a four character string usually in the format YYXX. Such as 1304 for year
2013, fourth survey.| numeric|	dimensionless
|P_STA_NO	| the Pascagoula Station Number. A five character string, using in the format of VVSSSS where VV is the vessel number and SSSS is a sequential count of the stations processed for that survey. The P_STA_NO entry should be unique for each STAREC entry per Cruise. P_STA_NO may repeat for different CRUISEIDS.| character|	dimensionless
|GEAR_SIZE	|a three character field which is numeric. This field represents the net of feet or the number of hooks on the line. Valid range is 0 to 999. It may be blank or null. |character|	dimensionless
|GEAR_TYPE|	a two character field which represents a gear code. It may be blank or null.|character|	dimensionless
|MESH_SIZE|a five character field which must be numeric. The field format is XX.XX and represents the inches or stretch of the net or the number of hooks. Valid range is 0 to 10. It may be blank or null.|numeric|	dimensionless
|OP| a one character field which is a code. This code may be blank.|character|	dimensionless
|MIN_FISHED	|a four character field which is numeric and integer. The field format is XXXX and represents minutes. Value should represent difference between the Station start and end times.|	character|dimensionless
|WBCOLOR	|a one character field which may be blank. This field represents the gross code for water color. Valid values are ‘B’,’G’,’T’,’Y’, or ‘M’. It may be blank or null|	character|dimensionless
|BOT_TYPE	|a two character field which may be blank. Valid values are:‘B’,’CL’,’CO’,’G’,’GR’,’M’,’ML’,’OZ’,’RK’,’S’,’SH’, or ‘SP’.|	character|dimensionless
|BOT_REG	|a two character field which may be blank. Valid values are:‘S’,’L’,’O’,’P’,’E’,’M’.|	character|dimensionless
|TOT_LIVE|a seven character field which must be numeric. This field contains a number which must be in XXXXX.X format and represents total live catch in kilograms. Value must be between 0 and less than 100000. It may be blank or null.|	character|dimensionless
|FIN_CATCH	|a seven character field which must be numeric. This field contains a number which must be in XXXXX.X format and represents finfish catch in kilograms. Value must be between 0 and less than 100000. It may be blank or null.|	character|dimensionless
|CRUS_CATCH	|a seven character field which must be numeric. This field contains a number which must be in XXXXX.X format and represents the crustacean catch in kilograms. Value must be between 0 and less than 100000. It may be blank or null.|	character|dimensionless
|OTHR_CATCH	|a seven character field which must be numeric. This field contains a number which must be in XXXXX.X format and represents other catch in kilograms. Value must be between 0 and less than 100000. It may be blank or null.|	character|dimensionless
|T_SAMPLEWT	|an eight character field which must be numeric. This field contains a number which must be in XXXX.XXX format and represents sample weight in kilograms. Value must lie between 0 and less than 10000. Value should equal the summed total of the biological detail sample weights|	character|dimensionless
|T_SELECTWT	|an eight character field which must be numeric. This field contains a number which must be in XXXX.XXX format and represents select weight in kilograms. Value must lie between 0 and less than 10000.|	character|dimensionless
|FIN_SMP_WT	|an eight character field which must be numeric. This field contains a number which must be in XXXX.XXX format and represents finfish sample weight in kilograms. Value must lie between 0 and less than 10000. Value should equal the summed total of the biological detail sampled finfish weights.|	character|dimensionless
|FIN_SEL_WT	|an eight character field which must be numeric. This field contains a number which must be in XXXX.XXX format and represents finfish select weight in kilograms. Value must lie between 0 and less than 10000.|	character|dimensionless
|CRU_SMP_WT	|an eight character field which must be numeric. This field contains a number which must be in XXXX.XXX format and represents the crustacean sample weight in kilograms. Value must lie between 0 and less than 10000. Value should equal the summed total of the biological detail sampled crustacean weights.|	character|dimensionless
|CRU_SEL_WT	|an eight character field which must be numeric. This field contains a number which must be in XXXX.XXX format and represents the crustacean select weight in kilograms. Value must lie between 0 and less than 10000.|	character|dimensionless
|OTH_SMP_WT	|an eight character field which must be numeric. This field contains a number which must be in XXXX.XXX format and represents other sample weight in kilograms. Value must lie between 0 and less than 10000. Value should equal the summed total of the biological detail sampled other weights.|	character|dimensionless
|OTH_SEL_WT	|an eight character field which must be numeric. This field contains a number which must be in XXXX.XXX format and represents other select weight in kilograms. Value must lie between 0 and less than 10000.|	character|dimensionless
|COMBIO	|a two hundred character field used for comments, which may be blank. |	character|dimensionless

**gmex_NEWBIOCODESBIG.csv column definitions:**
| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|Key1|	a unique integer assigned for each entry in NEWBIOCODES table.|numeric|	dimensionless
|TAXONOMIC	| the taxonomic or scientific name for each entry.|character|dimensionless
|CODE|the NMFS assigned unique value for each entry. Referred to as “BIOCODE”.	|	character| dimensionless
|TAXONSIZECODE	|may be empty. Possible measurement code to be used when taking measurements. Not utilized.| character|	dimensionless
|Isactive| not used.| character|	dimensionless
|Common_name	| contains the common name of an entry| character|	dimensionless
|Tsn	|the (I.T.I.S) TSN value for an entry if available. |numeric|	dimensionless

**gmex_STAREC.csv column definitions:**

| attributeName                  | attributeDefinition   | col_classes             | unit |       
|--------------------------|----------------|----------------------------|-----------------------------------------------------------|
|STATIONID	| a unique integer assigned for each entry in STAREC table.|numeric|	year
|CRUISEID| a unique integer assigned for each entry in CRUISES table.	|	character| dimensionless
|VESSEL	| a unique integer representing the Vessel name, from the VESSELS table.| numeric|	dimensionless
|CRUISE_NO|	a four character string usually in the format YYXX. Such as 1304 for year 2013, fourth survey.| numeric|	dimensionless
|P_STA_NO	| the Pascagoula Station Number. A five character string, using in the format of VVSSSS where VV is the vessel number and SSSS is a sequential count of the stations processed for that survey. The P_STA_NO entry should be unique for each STAREC entry per Cruise. P_STA_NO may repeat for different CRUISEIDS.| character|	dimensionless
|TIME_ZN| a one character field which is a code which represents the time zone of the station. | numeric|	dimensionless
|TIME_MIL	|a four character field which must be numeric. This field represents station start time and should be in military format, HHMM, where HH represents hours and MM represents minutes.|character|	dimensionless
|S_LATD|	a two character field which is a numeric positive integer and represents latitude degrees.|character|	dimensionless
|S_LATM| a five character field which is numeric and represents latitude minutes. Field format is MM.HH; Where MM represents minutes and HH represents hundreds of minutes.|numeric|	dimensionless
|S_LATH| a one character field which is a code which represents the latitude hemisphere. Valid codes are “N” and “X”.|numeric|	dimensionless
|S_LOND| a three character field which is numeric positive integer and represents starting longitude degrees.|character|	dimensionless
|S_LONM	|a five character field which is numeric and represents starting longitude minutes. Field format is MM.HH; MM represents minutes and HH represents hundreds of minutes|	character|dimensionless
|S_LONH	|a one character field which is a code which represents the longitude hemisphere. Valid codes are “W” and “X”.|	character|dimensionless
|DEPTH_SSTA	|a six character field which must be numeric. This field represents the starting depth of the station in meters.|	character|dimensionless
|S_STA_NO	|a five character field labeling the station as a SEAMAP sampled station.|	character|dimensionless
|MO_DAY_YR|a date field, which in MM-DD-YYYY format|	character|dimensionless
|TIME_EMIL	|a four character field which must be numeric. This field represents station ending time and should be in military format, HHMM, where HH represents hours and MM represents minutes.|	character|dimensionless
|E_LATD	|a two character field which is a numeric positive integer and represents ending latitude degrees.|	character|dimensionless
|E_LATM	|a five character field which is numeric and represents latitude minutes. Field format is MM.HH; MM represents minutes and HH represents hundreds of minutes.|	character|dimensionless
|E_LATH	|a one character field which is a code which represents the latitude hemisphere. Valid codes are “N” and “X”.|	character|dimensionless
|E_LOND	|a three character field which is numeric positive integer and represents ending longitude degrees.|	character|dimensionless
|E_LONM	|a five character field which is numeric and represents ending longitude minutes. Field format is MM.HH; MM represents minutes and HH represents hundreds of minutes.|	character|dimensionless
|E_LONH	|a one character field which is a code which represents the longitude hemisphere. Valid codes are “W” and “X”.|	character|dimensionless
|DEPTH_ESTA	| a field that represents the ending depth of the station in meters|	character|dimensionless
|GEARS	|a thirty character field which represents up to 15 two character gear codes.|	character|dimensionless
|TEMP_SSURF	|represents the surface temperature at the station and represents degrees of centigrade.	character|dimensionless
|TEMP_BOT	|represents the bottom temperature at the station and represents degrees of centigrade.|	character|dimensionless
|TEMP_SAIR	|represents the air temperature at the station. The field format is XX.X and represents degrees of centigrade.|	character|dimensionless
|B_PRSSR	|represents the barometric pressure at the station. The field format is XXX.X and represents millibars.|	character|dimensionless
|WIND_SPD	|represents the wind speed. The field format is XX and represents knots.|	character|dimensionless
|WIND_DIR	|has the field format of XXX and represents compass degrees. |	character|dimensionless
|WAVE_HT	|represents the wave height. The field format is XX.X and represents meters. |	character|dimensionless
|SEA_COND	|a one character field which represents a valid sea condition. This field represent a code which corresponds to the Beaufort Wind Force Scale. |	character|dimensionless
|DBTYPE	|represents a valid database type code.  |	character|dimensionless
|DATA_CODE	|represents a data source code. |	character|dimensionless
|VESSEL_SPD	|in the field format XX.X and represents the speed of the vessel in knots. |	character|dimensionless
|FAUN_ZONE	|represents the faunal zone based on start of the station. |	character|dimensionless
|STAT_ZONE	|a five character field which represents the shrimp statistical zone. |	character|dimensionless
|TOW_NO	|a one character field which must be numeric. This field represents the tow number and may be blank. If present valid values are 1,2,3,4,5,6,7,8,9. |	character|dimensionless
|NET_NO	|a one character field which must be numeric. This field represents the net number and may be blank. If present, valid values are 1, 2, or 3. |	character|dimensionless
|COMSTAT	|a text comment field, up to 250 characters. |	character|dimensionless
|DECSLAT	|the latitude of the start of the station. Format DD.XXX where DD is degrees of latitude, and XXX is hundredths of a degree. |	character|dimensionless
|DECSLON	|the longitude of the start of the station. Format DDD.XXX where DDD is degrees of longitude and XXX is hundredths of a degree. May be a negative value indicating western hemisphere. |	character|dimensionless
|DECELAT	|the latitude of the end of the station. Format DD.XXX where DD is degrees of latitude, and XXX is hundredths of a degree. |	character|dimensionless
|DECELON	|the longitude of the end of the station. Format DDD.XXX where DDD is degrees of longitude and XXX is hundredths of a degree. May be a negative value indicating western hemisphere. |	character|dimensionless
|START_DATE	|a time/date field of the start of the station. Format – YYYY-MM-DD HH:MM:SS. |	character|dimensionless
|END_DATE	|a time/date field of the end of the station. Format – YYYY-MM-DD HH:MM:SS. |	character|dimensionless
|HAULVALUE	|a one character field which may be blank. Valid values are “G”,”B”. G indicates a good trawl while B indicates a bad trawl. |	character|dimensionless

The Ecological Metadata Language file can be accessed [here](https://github.com/pinskylab/OceanAdapt/blob/new_canada_2019/metaData/gmex/gmex.xml)
