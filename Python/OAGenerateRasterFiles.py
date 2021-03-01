{\rtf1\ansi\ansicpg1252\cocoartf2513
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fmodern\fcharset0 Courier;\f1\froman\fcharset0 Times-Roman;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;}
{\*\expandedcolortbl;;\cssrgb\c0\c0\c0;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs24 \cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 #############################################################################################\
# Ocean Adapt - http://oceanadapt.rutgers.edu/\
# Generate Raster File\
#\
# This script was made to generate the time series, interpolateed biomass maps by fish species and region for use on OceanAdapt. If you require additional information\
#       or would like to see the script refined further for more general and public use, please contact Malin Pinsky at ( malin.pinsky@rutgers.edu ).  For questions specific to the python code, please \
#		contact Daniel Farnsworth at ( danfarns@njaes.rutgers.edu )\
#\
# Help Contact(s):\
#       Dr. Malin Pinsky ( malin.pinsky@rutgers.edu )\
#       Daniel Farnsworth ( danfarns@njaes.rutgers.edu )\
#\
# Additional Items:\
#       If you want to completly recreate the maps on your own or run the script as-is, you can download the supplement here:\
#       http://oceanadapt.rutgers.edu/ArcGIS_Analysis_Files.zip (~217 MBs)\
#       *Please make sure to create the CSV data (as it is significantly large) and place it in the CSV_DIRECTORY folder you specify below.\
#\
# Version:\
#       0.9 Public Beta\
#\
# Version Description:\
#       This is the start of a cleaned up script (code and comment wise) beta version for the public to use in their own programs or to generate their own maps. Some variables may be deprecated.\
#       Some items still need to be cleaned up code wise, and possibly optimized, mainly the more intesive parts of the code.\
#       Possible future support for Python 3 (for ArcGIS Pro) may be implemented at a future point in time, however all arcpy.mapping functions should have an equivalent arcpy.mp function.\
#\
# Tested on: \
#       Windows ArcGIS 10.3.1 / Python 2.7.8\
#       [Partially] Windows ArcGIS 10.3.1 / Python 2.7.14\
#       [Partially] Windows ArcGIS 10.3.5 / Python 2.7.13\
#\
# Recommended Settings:\
#  *These settings are what the author has specifically tested on. This script may work on prior versions of the specifications listed, however they were not tested on those specifications.\
#  *In addition: Versions higher than the specifications listed should work, however, the code was not tested on those specifications\
#       ArcGIS 10.3.1\
#       ArcPy Spatial Extension\
#       Python 2.7.8; 2.7.13; 2.7.14\
#       Windows Machine (Windows 7 / 10)\
#############################################################################################\
\
print ("--Ocean Adapt: Generate Raster Pictures v0.9-Public Beta--")\
print ("The script requries the following:")\
print ("> ArcGIS 10.3+ ( ArcGIS Pro not currently tested. )")\
print (">> REQUIRES SPATIAL EXTENSION. The program will not run if it is not detected or activated")\
print ("> Python 2.7+ ( Python 3.0 not currently tested. )")\
print ("> CSV Files downloaded from the OceanAdapt Website")\
print ("> Windows Machine ( 7+ ). ( Linux and Mac OSX not tested. )")\
\
import os\
import sys\
from datetime import date\
import shutil\
\
\
##VARIABLES FOR THIS PROGRAM\
\
#The directory this script is in.        \
BASE_DIRECTORY = os.path.dirname(os.path.realpath(__file__)) + "\\\\"\
#Raster Files will go here.\
ANALYSIS_DIRECTORY = BASE_DIRECTORY + "Analysis_Folder\\\\" \
#CSV files will be read from\
CSV_DIRECTORY = BASE_DIRECTORY + "fish_data\\\\"\
\
#Output the pictures to the Picture Folder.\
#This will require a little bit of effort if set to true.\
OUTPUT_PICTURES = False\
MAP_DIRECTORY = BASE_DIRECTORY + "Map_Shapefiles\\\\"\
PICTURE_FOLDER = BASE_DIRECTORY + "Map_Picture_Collection\\\\"\
\
## The table_names variable includes the following information:\
##        table_names[0]: The region shape that gets used for the mask and extent of the environment variable, and the output coordinate system\
##        table_names[1]: The boundary shape file ( a single Polyline ) that gets used by arcpy.gp.Idw_sa\
##        table_names[2]: The abbreviation of the region (for file/folder structure)\
##        table_names[3]: The actual name of the region\
##        table_names[4]: The CSV file that contains this region's data\
##        table_names[5]: ??? The PRJ datum used by the region shapefile (table_names[0]). These are included within the ArcGIS installation. Please see\
##                            https://desktop.arcgis.com/en/arcmap/10.5/map/projections/pdf/projected_coordinate_systems.pdf \
##                            for valid Projection Names or inside arcgis itself.\
##                            The variable itself does not appear to be used, it's just there for my reference.\
##        table_names[6]: A shapefile containing contour lines for outputting pictures.\
\
## In order to automate generating raster files and pictures for the Ocean Adapt website, This array of information was used to allow controlled and regulated so all regions are treated the exact same way.\
table_names = [\
        [ 'AI_Shape', 'AI_Boundary','AI', 'Aleutian Islands', 'ai_csv', 'NAD_1983_2011_UTM_Zone_1N', 'Contour_etop01_2'],\
        [ 'EBS_Shape', 'EBS_Boundary','EBS', 'Eastern Bering Sea', 'ebs_csv', 'NAD_1983_2011_UTM_Zone_3N', 'contour_ebs'],\
        [ 'GOA_Shape', 'GOA_Boundary','GOA', 'Gulf of Alaska', 'goa_csv', 'NAD_1983_2011_UTM_Zone_5N', 'contour_goa'],\
        \
        [ 'GOM_Shape', 'GOM_Boundary','GOM', 'Gulf of Mexico', 'gmex_csv', 'NAD_1983_2011_UTM_Zone_15N', 'contour_gom'],\
        \
        [ 'NEUS_Fall_Shape', 'NEUS_Fall_Boundary','NEUS_F', 'Northeast US Fall', 'neusf_csv', 'NAD_1983_2011_UTM_Zone_18N', 'contour_neus'],\
        [ 'NEUS_Spring_Shape', 'NEUS_Spring_Boundary','NEUS_S', 'Northeast US Spring', 'neus_csv', 'NAD_1983_2011_UTM_Zone_18N', 'contour_neus'],\
\
\
        [ 'SEUS_Shape', 'SEUS_Boundary','SEUS_SPR', 'Southeast US Spring', 'seus_spr_csv', 'NAD_1983_2011_UTM_Zone_17N', 'contour_seus'],\
        [ 'SEUS_Shape', 'SEUS_Boundary','SEUS_SUM', 'Southeast US Summer', 'seus_sum_csv', 'NAD_1983_2011_UTM_Zone_17N', 'contour_seus'],\
        [ 'SEUS_Shape', 'SEUS_Boundary','SEUS_FALL', 'Southeast US Fall', 'seus_fal_csv', 'NAD_1983_2011_UTM_Zone_17N', 'contour_seus'],\
        \
        [ 'WC_Ann_Shape', 'WC_Ann_Boundary','WC_ANN', 'West Coast Annual', 'wcann_csv', 'NAD_1983_2011_UTM_Zone_10N', 'contour_wc'],\
        [ 'WC_Tri_Shape', 'WC_Tri_Boundary','WC_TRI', 'West Coast Triennial', 'wctri_csv', 'NAD_1983_2011_UTM_Zone_10N', 'contour_wc']\
\
] \
\
DEBUG_LEVEL = 0\
#0: No Debugging Ouput\
#1: Some probably important stuff\
#2: mostly important stuff\
#3: Probably literally everything, as verbose as necessary.\
\
#Since the user may be running this from inside arcGIS, we will output to both the Python Command Line (e.g. IDLE) and arcpy.AddMessage\
#ARCPY MUST BE IMPORTED BEFORE USING THIS.\
def print_both(message):\
        arcpy.AddMessage(message)\
        print(message)\
#Output a message if level is under or equal to the DEBUG_LEVEL   \
def DEBUG_OUTPUT(level, message):\
        if level <= DEBUG_LEVEL:\
                print_both("[DEBUG LEVEL ("+ str(level) + " / " + str(DEBUG_LEVEL) +")] " + message )\
                \
#Define a single way to exit the program on success or error\
def exit_program(message = "No Message Specified"):\
        try: #Py 2.7\
                raw_input(message + "\\r\\nPress [Enter] to close the program ...")\
        except (NameError, AttributeError) as thrownError: #Py. 3.4\
                input(message + "\\r\\nPress [Enter] to close the program ...")        \
        exit(0);\
\
\
        \
print ("[Main] Checking for ArcPy")\
\
#If arcpy is already imported, we can skip since it takes a while to load\
try:\
	arcpy\
	print_both("[Main] ArcPY already imported")\
except NameError:\
        #Typically having ArcGIS already is enough to not have to search specific places for it,\
        #       so ImportError should not happen.\
        try:\
                import arcpy\
                print("[Main] ArcPY is activated. ")\
        except ImportError:\
                print ("[Main] ArcPY was not found. We will try to look on your system in the common areas for ArcPy...")\
                #Code block searches any place arc py might be on Windows.\
                #If you know where arcpy is, extend sys.path to the appropriate folders.\
                #If the system cannot find arcpy a second time, we exit the program.\
                if sys.version_info.major < 3:\
                        #Version detection for the future when we let arcpy 3+ to work.\
                        sys.path.extend([\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.1\\arcpy',\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.1\\bin' ,\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.1\\ArcToolbox\\Scripts',\
                                r'C:\\Python27\\ArcGIS10.1\\lib',\
                                r'C:\\Python27\\ArcGIS10.1\\Lib\\site-packages',\
                                \
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.2\\arcpy',\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.2\\bin' ,\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.2\\ArcToolbox\\Scripts',\
                                r'C:\\Python27\\ArcGIS10.2\\lib',\
                                r'C:\\Python27\\ArcGIS10.2\\Lib\\site-packages',\
                                \
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.3\\arcpy',\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.3\\bin' ,\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.3\\ArcToolbox\\Scripts',\
                                r'C:\\Python27\\ArcGIS10.3\\lib',\
                                r'C:\\Python27\\ArcGIS10.3\\Lib\\site-packages',\
                                \
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.4\\arcpy',\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.4\\bin' ,\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.4\\ArcToolbox\\Scripts',\
                                r'C:\\Python27\\ArcGIS10.4\\lib',\
                                r'C:\\Python27\\ArcGIS10.4\\Lib\\site-packages',\
                                \
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.5\\arcpy',\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.5\\bin' ,\
                                r'C:\\Program Files (x86)\\ArcGIS\\Desktop10.5\\ArcToolbox\\Scripts',\
                                r'C:\\Python27\\ArcGIS10.5\\lib',\
                                r'C:\\Python27\\ArcGIS10.5\\Lib\\site-packages'\
                        ])\
                        try:\
                                import arcpy\
                                print("[Main] ArcPY was imported successfully!")\
                        except ImportError:\
                                exit_program("[Main] Could not import the ArcPy Module.")\
                elif sys.version_info.major == 3:\
                        try:\
                                import arcpy\
                                #print(sys.modules)\
                                print("[Main] ArcPY was imported successfully!")\
                        except ImportError:\
                                exit_program("[Main] Could not import the ArcPy Module.")\
                        \
                \
#Import from arcpy where available        \
from arcpy import env\
from arcpy.sa import * #Spatial Analysis Tool\
\
##USER DEFINED IMPORTS HERE\
\
\
#This program cannot run without having the Spatial Extension authorized.\
#If it doesn't exist or cannot be checked out, we will exit the program.\
if arcpy.CheckExtension("Spatial") == "Available":\
        print_both("[Main] Checking out SPATIAL EXTENSION")\
        arcpy.CheckOutExtension("Spatial")\
else:\
        ##Exit program, we're unable to check out this extension. Script cannot run without it.\
        exit_program("[Main] Could not check out ArcGIS [Spatial] Extension.")\
        \
######################################\
## IMPORTS AND VARIABLES SHOULD BE DONE, PLEASE DO NOT IMPORT AFTER THIS\
######################################\
\
DEBUG_OUTPUT(1, "Base Dir: " + BASE_DIRECTORY)\
DEBUG_OUTPUT(1, "Map Dir: " + MAP_DIRECTORY)\
DEBUG_OUTPUT(1, "Analysis Dir: " + ANALYSIS_DIRECTORY)\
DEBUG_OUTPUT(1, "CSV Dir: " + CSV_DIRECTORY)\
DEBUG_OUTPUT(1, "Picture Dir: " + PICTURE_FOLDER)\
\
#Check Existance of Analysis, CSV, Picture Dir.\
#if analysis directory doesn't exist, we're done\
#if csv directory doesn't exist, we're done\
#if picture directory doesn't exist, try to create it\
\
if not os.path.exists( ANALYSIS_DIRECTORY ) and not os.path.isdir( ANALYSIS_DIRECTORY ):\
        os.makedirs( ANALYSIS_DIRECTORY )\
                \
if not os.path.exists( CSV_DIRECTORY ) and not os.path.isdir( CSV_DIRECTORY ):\
        exit_program('[Main] Could not find Fish Data Directory')\
        \
if not os.path.exists( PICTURE_FOLDER ) and not os.path.isdir( PICTURE_FOLDER ):\
        os.makedirs( PICTURE_FOLDER )\
        \
print_both("[Main] All folders exist. Continuing...")\
\
\
######################################\
## Functions specific to this program\
######################################\
\
##\
# Function: unique_field\
#       Generic function to return all the unique values within a specified field\
# @param string table: The name of the layer that contains the field to be searched\
# @param string field: which field to look\
# @return array: a sorted array of unique values.\
##\
def unique_field(table,field):\
        with arcpy.da.SearchCursor(table, [field]) as cursor:\
                return sorted(\{row[0] for row in cursor\})\
        \
##\
# Function: unique_fish\
#       Gets the unique fish species within a dataset\
# @param string table: The name of the layer that contains the fish information\
# @return array: a sorted array of unique fish species.\
##\
def unique_fish(table):\
        arcpy.SelectLayerByAttribute_management( table, "CLEAR_SELECTION" ) \
        with arcpy.da.SearchCursor(table, ["spp"]) as cursor:\
                return sorted(\{row[0] for row in cursor\})\
  \
##\
# Function: unique_year\
#       Gets the unique years (that have data) for a fish species\
# @param string table: The name of the layer that contains the fish information\
# @param string which_fish: The scientific name (spp) of the fish species to look at\
# @return array: a sorted year array so we can go in order.\
##\
def unique_year(table, which_fish):\
        arcpy.SelectLayerByAttribute_management( table, "CLEAR_SELECTION" ) \
        with arcpy.da.SearchCursor(table, ["year"], "\\"spp\\"='"+ which_fish +"'") as cursor:\
                return sorted(\{row[0] for row in cursor\})\
                \
##\
# Function: select_by_fish\
#       Selects the rows of fish species data in a 5 year span for use by the Inverse Distance Weighted (IDW) function.\
# @param string table: The name of the layer that contains the fish information\
# @param string which_fish: The scientific name (spp) of the fish species to look at\
# @param string base_year: The origin year (as a string) to get a five year range (-2 to +2) of data for this fish.\
# @return integer 1: returns 1 on complete\
##        \
def select_by_fish(table, which_fish, base_year):\
        #This clears the selection just incase it is not empty, even though "NEW_SELECTION" should theroetically take care of this\
        #base_year should already be converted to string using str()\
        DEBUG_OUTPUT(3, "Selecing from table `"+ table.name +"`")\
        DEBUG_OUTPUT(3, "With Statement:`\\"spp\\"='"+ which_fish +"' AND \\"year\\" >= ("+base_year+"-2 ) AND \\"year\\" <= (" + base_year+ "+2)`" )\
\
        arcpy.SelectLayerByAttribute_management( table, "CLEAR_SELECTION" ) \
        arcpy.SelectLayerByAttribute_management( table, "NEW_SELECTION", "\\"spp\\"='"+ which_fish +"' AND \\"year\\" >= ("+base_year+"-2 ) AND \\"year\\" <= ("+base_year+"+2 ) " ) \
        return 1\
 \
##\
# Function: select_by_fish_no_years\
#       Does same thing as @function select_by_fish, just all of the years worth of data.\
# @param string table: The name of the layer that contains the fish information\
# @param string which_fish: The scientific name (spp) of the fish species to look at\
# @return boolean True: returns True on complete.\
##\
def select_by_fish_no_years(table, which_fish):\
        DEBUG_OUTPUT(3, "Selecing from table `"+ table.name +"`")\
        DEBUG_OUTPUT(3, "With Statement:`\\"spp\\"='"+ which_fish + "'`" )\
        \
        arcpy.SelectLayerByAttribute_management( table, "CLEAR_SELECTION" ) \
        arcpy.SelectLayerByAttribute_management( table, "NEW_SELECTION", "\\"spp\\"='"+ which_fish +"'" ) \
        return 1\
\
\
\
\
#CODE FROM HERE ON OUT (2017-09-28) ARE LEFT AS-IS FOR NOW.\
## FURTHER REFINEMENT CAN BE REQUESTED\
\
\
##\
# Function: output_pictures\
#       Generates pictures to be uploaded to the website.\
# @params follow the variables described above with some extra items.\
# @return integer 1: returns 1 on complete\
##   \
def output_pictures(base_dir, analysis_folder, picture_folder, region_name, species_name, first_raster, stat_min, stat_max, stat_mean, stat_std, contour, mid_val):\
        #Opens a precreated mapping document for the region_name.\
        mxd = arcpy.mapping.MapDocument(base_dir + region_name + "\\\\" + region_name + ".mxd")\
		#prepares the dataframe\
        df = arcpy.mapping.ListDataFrames( mxd )[0]\
\
		#The mxd must have a legend item so we can do some On-The-Fly manipulating.\
		#Also we disable autoadding items to the legend so we can control exactly what layers are supposed to be seen.\
        my_legend = arcpy.mapping.ListLayoutElements (mxd, "LEGEND_ELEMENT")[0]\
        my_legend.autoAdd = False\
\
		#Add all of the layers in the species folder for a specific region\
        for layer_file in reversed( os.listdir(analysis_folder + "\\\\" + region_name + "\\\\" + species_name + "\\\\") ):\
                if layer_file.endswith(".lyr"):\
                        this_layer = arcpy.mapping.Layer(analysis_folder + "\\\\" + region_name + "\\\\" + species_name + "\\\\" + layer_file)\
                        this_layer.visible = False\
                        arcpy.mapping.AddLayer(df, this_layer )\
\
        ##Also add the contour lines to display on the map.\
        contour_lines = arcpy.mapping.Layer(base_dir + region_name + "\\\\" + contour + ".lyr")\
\
        ##Make sure contour lines is pointing to the right space, since the layer might not be pointing at the correct path due to being absolutely pathing.\
        contour_lines.replaceDataSource(base_dir + region_name + "\\\\", "NONE", contour )\
        arcpy.mapping.AddLayer(df, contour_lines )\
		\
		\
        #now add the earliest layer under EVERYthing so it is never seen. \
		# This is so the legend will only display the first year's information and is never visible.\
		#Since other items are not added to the legend, and it's under the basemap and other layers, the legend will be static.\
        my_legend.autoAdd = True\
        first_raster.visible = True\
        first_raster.name = ''\
		#Add it and put it on the bottom.\
        arcpy.mapping.AddLayer(df, first_raster, "BOTTOM")\
\
		#If there is already a saved debugging MXD file, delete it so we can save the MXD for viewing at a later time.\
        arcpy.Delete_management(analysis_folder + "\\\\" + region_name + "\\\\" + species_name + "\\\\" + species_name + ".mxd")\
        arcpy.RefreshActiveView()\
        \
		#Any layers that should not be looped on for outputting to pictures should be placed here.\
		#If you have a specific name for your layer, add it here, otherwise it will be included during picture generation\
        my_layer_exclusion_list = ['', 'contour_etop01_2','contour_ebs',   'contour_neus',    'contour_seus',    'contour_gom',  'contour_wc',  'contour_goa', 'reference','canvas/world_light_gray_reference','light gray canvas reference','basemap','canvas/world_light_gray_base','light gray canvas base']\
\
        individualDataFrameList = arcpy.mapping.ListDataFrames(mxd)\
\
		#The year_txt is an absolutely named item in the original Map Document so we can specifically place the year of the current raster\
		#The mid_txt is an absolutely named item in the original Map Document so we can specifically place the mid value there\
		#	Otherwise we would only see the MIN and MAX values on the legend.\
        #Update mid val text box "Mid : #.#####"\
        year_txt = ''\
        for textElement in arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT"):\
                if textElement.name == "mid_txt":\
                        textElement.text = "Mid : " + str(mid_val)\
                elif textElement.name == "year_txt":\
                        year_txt = textElement\
        arcpy.RefreshActiveView()\
        \
                \
\
\
        #all layers should have been added to the map and turned off, we will loop on the data frame to export to png\
		\
		#This loop goes through each of the layers in the Map Document to:\
		#	Make them visible\
		#	Update year_txt to currently selected year\
		#	Temporarily removes the name of the layer so it doesn't interfere with the legend element\
		#	refresh view just incase,\
		#	export the picture to the proper folder\
		#	rehide layer\
		# 	and finally restore it's name.\
        for individualDataFrame in individualDataFrameList:\
                individualLayerList = arcpy.mapping.ListLayers(mxd, "", individualDataFrame)\
                for individualLayer in individualLayerList:\
                        if individualLayer.name.lower() not in my_layer_exclusion_list:\
                                #arcpy.SetRasterProperties_management(individualLayer, data_type="", statistics="1 "+ str(stat_min) +" "+ str(stat_max) +" "+ str(stat_mean)+ " "+ str(stat_std), stats_file="", nodata="", key_properties="")\
                                #individualLayer.save()\
                                my_name = individualLayer.name\
                                \
                                filename, file_extension = os.path.splitext( individualLayer.name )\
                                year_txt.text = "- " + my_name.split(".")[0]\
                                \
                                individualLayer.name = ''\
                                individualLayer.visible = True\
                                arcpy.RefreshActiveView()\
                                arcpy.mapping.ExportToPNG(mxd, picture_folder + "\\\\" + region_name + "\\\\" + species_name + "\\\\picture_"+ filename.lower() +".png")\
                                individualLayer.visible = False\
                                individualLayer.name = my_name\
                                #arcpy.AddMessage('[FUNC output_pictures] Layer Name: `'+ individualLayer.name.lower() +'`')\
		#Just for debugging or looking at the data as it is supposed to after processing.\
        mxd.saveACopy(analysis_folder + "\\\\" + region_name + "\\\\" + species_name + "\\\\" + species_name + ".mxd" )\
        DEBUG_OUTPUT(2, "A MXD file was saved to [ "+analysis_folder + "\\\\" + region_name + "\\\\" + species_name + "\\\\" + species_name + ".mxd"+" ]")\
\
		#memory management and closing loose ends.\
        del my_legend\
        del df\
        del year_txt\
        del individualDataFrameList\
        del individualDataFrame\
        del individualLayer\
        del textElement\
        del contour_lines\
        del first_raster\
        del mxd\
        \
        return True	\
\
\
\
print_both("[Main] Beginning program...")\
\
##!!WARNING!!:::::::SET THE OVERWRITE TO ON - ANY ITEMS THAT GET SAVED WILL BE OVERWRITTEN\
arcpy.env.overwriteOutput = True\
\
#Start looping over the table_name array as we go region by region.\
for chosen_table in table_names:\
        #For benchmarking.\
        my_log = open(PICTURE_FOLDER + chosen_table[2] + "_fish_log.log", "a+")\
        my_log.write("STARTING REGION `"+chosen_table[2]+"` ON "+ time.strftime("%c") +"\\r\\n\\r\\n")\
        my_log.close\
\
        #These do not delete from the physical hard disk drive, just from the ArcPY Environment IF THEY EXIST.\
        arcpy.Delete_management(chosen_table[0])\
        arcpy.Delete_management(chosen_table[1])\
        arcpy.Delete_management(chosen_table[2] + '_Layer_VIEW')\
        arcpy.Delete_management(chosen_table[2] + '_Layer')\
\
        #THIS WILL ACTUALLY DELETE FROM THE PHYSICAL HARD DISK DRIVE since it is pointing to a specific location.\
        arcpy.Delete_management(MAP_DIRECTORY+chosen_table[2]+"\\\\" + chosen_table[2] + "_Layer.shp")\
\
\
        ##Create the directories in the folders above that we know exist.\
        if not os.path.exists( ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] ) and not os.path.isdir( ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] ):\
                os.makedirs( ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] ) \
                \
        if not os.path.exists( PICTURE_FOLDER + "\\\\" + chosen_table[2] ) and not os.path.isdir( PICTURE_FOLDER + "\\\\" + chosen_table[2] ):\
                os.makedirs( PICTURE_FOLDER + "\\\\" + chosen_table[2] )\
\
\
        #The shapefile used to create the extent and mask for the environment variable\
        my_shape = arcpy.mapping.Layer(MAP_DIRECTORY+chosen_table[2]+"\\\\" + chosen_table[0] + ".shp")\
\
        #The boundaries used by the sa.Idw to create the raster tif files.\
        my_bounds = arcpy.mapping.Layer(MAP_DIRECTORY+chosen_table[2]+"\\\\" + chosen_table[1] + ".shp")\
\
        #we need to set the mask and extent of the environment, or the raster and items may not come out correctly.\
        arcpy.env.extent = arcpy.Describe(my_shape).extent\
        arcpy.env.mask = MAP_DIRECTORY+chosen_table[2]+"\\\\" + chosen_table[0] + ".shp"\
\
        #Generate the shapefile to be used. We output this to the file system in the appropriate folder.\
        print_both('> Generating '+ chosen_table[2] +' Shapefile. This may take a while... Please wait...')\
\
        #Set the output coordinate system to what is available for us.\
        arcpy.env.outputCoordinateSystem = MAP_DIRECTORY + chosen_table[2]+"\\\\" + chosen_table[0] + ".prj"\
\
        #create a point file from all of the data available in the CSV\
        arcpy.MakeXYEventLayer_management(CSV_DIRECTORY + chosen_table[4] + ".csv" ,"lon","lat","DATA_VIEW","#","#")\
\
        #Make it a feature class and output it to the local hard disk drive (for usage and debugging purposes)\
        arcpy.FeatureClassToFeatureClass_conversion(in_features="DATA_VIEW", out_path=MAP_DIRECTORY+chosen_table[2]+"\\\\", out_name=chosen_table[2] + "_Layer.shp",\
                                                    where_clause='',\
                                                    field_mapping="""Field1 "Field1" true true false 50 Text 0 0 ,First,#,DATA_VIEW,Field1,-1,-1;region "region" true true false 50 Text 0 0 ,First,#,DATA_VIEW,region,-1,-1;haulid "haulid" true true false 255 Text 0 0 ,First,#,DATA_VIEW,haulid,-1,-1;year "year" true true false 4 Long 0 0 ,First,#,DATA_VIEW,year,-1,-1;spp "spp" true true false 50 Text 0 0 ,First,#,DATA_VIEW,spp,-1,-1;wtcpue "wtcpue" true true false 8 Double 10 20 ,First,#,DATA_VIEW,wtcpue,-1,-1;common "common" true true false 50 Text 0 0 ,First,#,DATA_VIEW,common,-1,-1;lat "lat" true true false 8 Double 10 20 ,First,#,DATA_VIEW,lat,-1,-1;stratum "stratum" true true false 50 Text 0 0 ,First,#,DATA_VIEW,stratum,-1,-1;stratumare "stratumare" true true false 50 Text 0 0 ,First,#,DATA_VIEW,stratumarea,-1,-1;lon "lon" true true false 8 Double 10 20 ,First,#,DATA_VIEW,lon,-1,-1;depth "depth" true true false 50 Text 0 0 ,First,#,DATA_VIEW,depth,-1,-1""",\
                                                    config_keyword="")\
        #Prepare the points layer\
        my_points = arcpy.mapping.Layer(MAP_DIRECTORY+chosen_table[2]+"\\\\" + chosen_table[2] + "_Layer.shp")\
\
        #Clear the XY Event Layer from memory.\
        arcpy.Delete_management("DATA_VIEW")\
\
        \
\
\
\
\
# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script\
# The following inputs are layers or table views: "NEUS_S_Layer"\
        arcpy.AddField_management(in_table=my_points, field_name="wtc_cube", field_type="DOUBLE", field_precision="20", field_scale="10", field_length="", field_alias="", field_is_nullable="NULLABLE", field_is_required="NON_REQUIRED", field_domain="")\
		# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script\
# The following inputs are layers or table views: "NEUS_S_Layer"\
# This applies a cube-root to the trawl data in order to minimize the impacts of any extremely large trawl pulls in the data.  The results of the IDW model are cubed back to normal values during the map creation process.\
        arcpy.CalculateField_management(in_table=my_points, field="wtc_cube", expression="math.pow(!wtcpue!,(1.0/3.0))", expression_type="PYTHON_9.3", code_block="")\
        #arcpy.env.outputCoordinateSystem = None\
        arcpy.env.cartographicCoordinateSystem = MAP_DIRECTORY+chosen_table[2]+"\\\\" + chosen_table[0] + ".shp"\
        \
        print_both('> Generating '+ chosen_table[2] +' Shapefile complete.')\
\
        my_unique_fish = unique_fish( my_points )\
\
        #If you want to intercept which fish you want to output or from a specific region,, either for debugging or testing,\
        #       Interceipt my_unique_fish here following the example(s):\
                #my_unique_fish = ['Atlantic cod'] #NEUS both\
                #my_unique_fish = ['Alaska skate'] #AI\
                #my_unique_fish = ['Alaska great tellin'] #EBS\
                #my_unique_fish = ['Henricia spp.'] #EBS\
\
\
        #If you want to remove any specific fish from analysis or from a specific region, either for debugging or testing,\
        #       Intercept my_unique_fish here following the examples(s):\
                #if chosen_table[2] == 'EBS':\
                #       my_unique_fish.remove('Henrica spp.')\
                #       arcpy.AddMessage( "[EBS] 'Henrica spp.' removed")\
                \
\
        ##Finally we will start looping of the uniquely identified fish in this csv.\
        for this_fish in my_unique_fish:\
                #We prepare a place so that we can place fish data relevant to the fish species we're looking at.\
                my_fish_dir = this_fish.replace("'","")\
                my_fish_dir = my_fish_dir.replace(".","")\
\
                \
                print_both( "["+this_fish+"] Creating Raster Files in directory `"+my_fish_dir+"` ")\
                \
                #Create a special folder for them\
                if not os.path.exists( ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir ) and not os.path.isdir( ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir ):\
                        os.makedirs( ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir )\
                        \
                if not os.path.exists( PICTURE_FOLDER + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir ) and not os.path.isdir( PICTURE_FOLDER + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir ):\
                        os.makedirs( PICTURE_FOLDER + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir )\
\
                #Get all of the unique years\
                my_unique_years = unique_year( my_points, this_fish.replace("'","''") )\
\
                #set the year to the future, where no data should exist.\
                #We will update this variable as we loop over the uniquely identified years for later.\
                year_smallest = date.today().year + 100\
                \
                for this_year in my_unique_years:\
                        #select the fish species data by the year provided.\
                        select_by_fish(my_points, this_fish.replace("'","''"), str(this_year))\
\
                        #Get a count of all the points and store it.\
                        result = arcpy.GetCount_management(my_points)\
                        count = int(result.getOutput(0))\
\
                        #Generate the interpolated Raster file and store it on the local hard drive. Can now be used in other ArcGIS Documents\
                        # Please make sure when importing, that you are projecting it on the map propertly.\
                        \
                        # Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script\
                        # The following inputs are layers or table views: "AI_Layer", "AI_Boundary"\
                        arcpy.gp.Idw_sa(my_points, "wtc_cube", ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir + "\\\\" + str(this_year) + ".tif", "#", "1", "VARIABLE 15 200000", my_bounds)\
                        \
                        del result\
			\
                        if this_year < year_smallest:\
                                get_max = arcpy.mapping.Layer(ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir + "\\\\" + str(this_year) + ".tif")\
                                \
                                if float(arcpy.GetRasterProperties_management(get_max,"MAXIMUM").getOutput(0)) != 0:\
                                        year_smallest=this_year\
                                del get_max\
       \
                #We should now have the smallest year to grab the data from.\
                first_raster = arcpy.mapping.Layer(ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir + "\\\\" + str(year_smallest) + ".tif" )\
\
				\
		#We are pretty much going to set min to 0, max to STD(OVER YEARS)*2+AVG(OVER YEARS), and the other two shouldn't matter, but we'll set those anyways.\
                select_by_fish_no_years(my_points, this_fish.replace("'","''") )\
\
		#Do statistical analysis on the points (my_points) and output it to dbf so we can read it in quickyl.\
                arcpy.Statistics_analysis(in_table=my_points, out_table=ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir + "\\\\" +"stats.dbf", statistics_fields="wtc_cube STD;wtc_cube MEAN", case_field="")\
                my_stats = arcpy.mapping.TableView(ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir + "\\\\" +"stats.dbf")\
\
                #The point of this is to set the appropriate ramps that compare to the very first available year of data we have\
                # So that "red" is always "red" across all years of data since MINs and MAXs can change through the years, distorting the color ramp.\
				# The statistics of the data are cubed here to return their values to the original scale.\
                minimum = float(arcpy.GetRasterProperties_management(first_raster,"MINIMUM").getOutput(0)) #Should be zero\
                maximum = 0\
                max_cubed = 0\
                mid_val = 0\
                mean = 0\
                std = 0\
                with arcpy.da.SearchCursor(my_stats, ['STD_wtc_cu', 'MEAN_wtc_c']) as cursor:\
                    for row in cursor:\
                        #arcpy.AddMessage( "STD_wtc_cu: `"+ str(row[0])+"`,MEAN_wtc_c: `"+ str(row[1]) +"`")\
                        maximum = (row[0]*2) + row[1]\
\
                        mid_val = round( (maximum / 2.0) ** 3.0, 6 )\
                        \
                        max_cubed = maximum**3.0\
                        max_cubed2 = maximum*maximum*maximum\
                        std =row[0]\
                        mean = row[1]\
                        #arcpy.AddMessage( "MAX: `"+ str(maximum) +"`,MIN: `"+ str(maximum) +"`")\
\
                #The first raster is pretty much our "Legend" Layer\
                #Apply the NON-CUBED value to it\
				\
                #maximum = float(arcpy.GetRasterProperties_management(first_raster,"MAXIMUM").getOutput(0))\
                #mean = float(arcpy.GetRasterProperties_management(first_raster,"MEAN").getOutput(0))\
                #std = float(arcpy.GetRasterProperties_management(first_raster,"STD").getOutput(0))\
                #arcpy.AddMessage( "["+this_fish+"] Smallest Year = `"+ str(year_smallest) +"` ")\
                \
                DEBUG_OUTPUT(2, "Statistics Variable Command: 1 "+ str(minimum) +" "+ str(maximum) +" "+ str(mean)+ " "+ str(std) + ",MAX CUBED: `"+ str(max_cubed)+"`")\
\
                #clear some memory.\
                del my_stats\
                del row\
                \
                print_both("Setting Raster Properties...")\
                arcpy.SetRasterProperties_management(first_raster, data_type="", statistics="1 "+ str( minimum ) +" "+ str( max_cubed ) +" "+ str(mean)+ " "+ str(std), stats_file="", nodata="", key_properties="")\
\
                #In order to get the colors correct, we need to apply a symbology layer since ArcGIS apparently has a hard time setting some options on the fly (like reverse color order)\
                #If I find the buried options/api to do this in the script, I can get rid of this layer file.\
                print_both("Applying Symbology...")\
                arcpy.ApplySymbologyFromLayer_management(first_raster, MAP_DIRECTORY + "base_symbology.lyr")\
\
                #If a species symbology layer for this already exists, we're going to clear it first....\
                arcpy.Delete_management(ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir + "\\\\species_symbology.lyr") \
                print_both("Clearing Species Symbology...")\
                #...And then recreate it.\
                arcpy.SaveToLayerFile_management( first_raster,  ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir + "\\\\species_symbology.lyr")\
                print_both("Setting Species Symbology...")\
\
                #Loop over each of the raster files and apply the symbology, min and maxes\
                for this_year in my_unique_years:\
                        apply_symb_and_prop = arcpy.mapping.Layer(ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir + "\\\\" + str(this_year) + ".tif" )\
                        arcpy.SetRasterProperties_management(apply_symb_and_prop, data_type="", statistics="1 "+ str(minimum) +" "+ str(maximum) +" "+ str(mean)+ " "+ str(std), stats_file="", nodata="", key_properties="")\
                        arcpy.ApplySymbologyFromLayer_management(apply_symb_and_prop, ANALYSIS_DIRECTORY + "\\\\" + chosen_table[2] + "\\\\" + my_fish_dir + "\\\\species_symbology.lyr")\
                        \
                        apply_symb_and_prop.save()\
                        del apply_symb_and_prop\
################\
# The raster files should be ready for use.\
################\
\
\
                #call the function to output and we'll be complete with this fish species!!\
                notUploaded = OUTPUT_PICTURES\
                while notUploaded:\
                        try:\
                                output_pictures(MAP_DIRECTORY, ANALYSIS_DIRECTORY, PICTURE_FOLDER, chosen_table[2], my_fish_dir, first_raster, minimum, maximum, mean, std, chosen_table[6], mid_val)\
                                notUploaded=False\
                        except Exception:\
                                print_both("Exception!")\
                                exit_program("Sorry, something went wrong with outputting the picture files.")\
                                continue\
\
                del first_raster\
\
\
                        \
                #again, for bench marking purposes        \
                my_log = open(PICTURE_FOLDER + chosen_table[2] + "_fish_log.log", "a+")\
                my_log.write("FISH `"+this_fish+"` COMPLETE AT "+ time.strftime("%c") +"\\r\\n\\r\\n")\
                my_log.close\
                print_both( "["+this_fish+"] complete. ")\
        del my_bounds\
        del my_shape\
        del my_points\
               \
        #Final benchmark for the region.\
        my_log = open(PICTURE_FOLDER + chosen_table[2] + "_fish_log.log", "ab+")\
        my_log.write("REGION `"+chosen_table[2]+"` COMPLETED ON "+ time.strftime("%c") +"\\r\\n\\r\\n")\
        my_log.close \
\
\
	\
##Complete Program\
exit_program("Program has completed successfully!")\
\
\pard\pardeftab720\partightenfactor0

\f1 \cf2 \
}