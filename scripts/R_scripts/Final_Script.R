
# the only time "setwd()" is being used in the entire project to set the root(project) directory for "here" package
setwd("C:/Users/sanaz/Documents/MB12-project")


library(here)
library(pbapply)

############################################################################
############################################################################
###                                                                      ###
###                              SECTION 1:                              ###
###                       DATA DOWNLOAD (CREODIAS)                       ###
###                                                                      ###
############################################################################
############################################################################

## Download S2 data from creodias
source(here::here("scripts", "R_scripts", "download_from_creodias.R"))

# Here insert your credentials from creodias
username <- "YOUR CREODIAS USERNAME HERE"

password <- "YOUR CREODIAS PASSWORD HERE"

# specify where the files should be saved on drive
download_path_base <- here::here("CREODIAS_part", "data_from_CREODIAS")

# 2017 
if(!dir.exists(here(download_path_base, "L1C_2017"))){
  dir.create(here(download_path_base, "L1C_2017"))
}

download_path <- here(download_path_base, "L1C_2017")

# The 'finder_api_url' is "Rest query" created after specifying search criteria in "https://finder.creodias.eu/";
# one should visit the mentioned website, search for the product and copy the content of "Rest query" to the following line
finder_api_url <- "https://finder.creodias.eu/resto/api/collections/Sentinel2/search.json?maxRecords=100&startDate=2017-01-01T00%3A00%3A00Z&completionDate=2017-12-31T23%3A59%3A59Z&cloudCover=%5B0%2C80%5D&processingLevel=LEVEL1C&geometry=POLYGON((15.167336516570561+40.30482661907769%2C15.212770580812675+40.353317305038416%2C15.233215909721627+40.31175599287076%2C15.167336516570561+40.30482661907769))&sortParam=startDate&sortOrder=descending&status=all&dataset=ESA-DATASET"

# call the function to start downloading for 2017
download_creodias(username, password, finder_api_url, download_path)

# 2018 
if(!dir.exists(here(download_path_base, "L1C_2018"))){
  dir.create(here(download_path_base, "L1C_2018"))
}

download_path <- here(download_path_base, "L1C_2018")
finder_api_url <- "https://finder.creodias.eu/resto/api/collections/Sentinel2/search.json?maxRecords=100&startDate=2018-01-01T00%3A00%3A00Z&completionDate=2018-12-31T23%3A59%3A59Z&cloudCover=%5B0%2C80%5D&processingLevel=LEVEL1C&geometry=POLYGON((15.167336516570561+40.30482661907769%2C15.212770580812675+40.353317305038416%2C15.233215909721627+40.31175599287076%2C15.167336516570561+40.30482661907769))&sortParam=startDate&sortOrder=descending&status=all&dataset=ESA-DATASET"

# call the function to start downloading for 2018
download_creodias(username, password, finder_api_url, download_path)


# 2019
if(!dir.exists(here(download_path_base, "L2A_2019"))){
  dir.create(here(download_path_base, "L2A_2019"))
}

download_path <- here(download_path_base, "L2A_2019")
finder_api_url <- "https://finder.creodias.eu/resto/api/collections/Sentinel2/search.json?maxRecords=100&startDate=2019-01-01T00%3A00%3A00Z&completionDate=2019-12-31T23%3A59%3A59Z&cloudCover=%5B0%2C80%5D&processingLevel=LEVEL1C&geometry=POLYGON((15.167336516570561+40.30482661907769%2C15.212770580812675+40.353317305038416%2C15.233215909721627+40.31175599287076%2C15.167336516570561+40.30482661907769))&sortParam=startDate&sortOrder=descending&status=all&dataset=ESA-DATASET"

# call the function to start downloading for 2019
download_creodias(username, password, finder_api_url, download_path)

# 2020
if(!dir.exists(here(download_path_base, "L2A_2020"))){
  dir.create(here(download_path_base, "L2A_2020"))
}

download_path <- here(download_path_base, "L2A_2020")
finder_api_url <- "https://finder.creodias.eu/resto/api/collections/Sentinel2/search.json?maxRecords=100&startDate=2020-01-01T00%3A00%3A00Z&completionDate=2020-12-31T23%3A59%3A59Z&cloudCover=%5B0%2C80%5D&processingLevel=LEVEL1C&geometry=POLYGON((15.167336516570561+40.30482661907769%2C15.212770580812675+40.353317305038416%2C15.233215909721627+40.31175599287076%2C15.167336516570561+40.30482661907769))&sortParam=startDate&sortOrder=descending&status=all&dataset=ESA-DATASET"

# call the function to start downloading for 2020
download_creodias(username, password, finder_api_url, download_path)


###########################################################################
###########################################################################
###                                                                     ###
###                              SECTION 2:                             ###
###                             UNZIP TILES                             ###
###                                                                     ###
###########################################################################
###########################################################################

## Unzip tiles using the unzip_s2_tiles() function in "1_Unzip.R" script
source(here("scripts", "R_scripts", "1_Unzip.R"))

year_list <- list(2017, 2018)

pbapply::pblapply(1:length(year_list), 
                  function(x){
                    year_dir <- sprintf("L1C_%s", year_list[[x]][1])
                    
                    path_zip <- here::here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    out_dir <- here::here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    unzip_s2_tiles(path_zip, out_dir)
                  }
)

year_list_2 <- list(2019, 2020)

pbapply::pblapply(1:length(year_list_2), 
                  function(x){
                    year_dir <- sprintf("L2A_%s", year_list_2[[x]][1])
                    
                    path_zip <- here::here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    out_dir <- here::here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    unzip_s2_tiles(path_zip, out_dir)
                  }
)


############################################################################
############################################################################
###                                                                      ###
###                              SECTION 3:                              ###
###                         SEN2COR (L1C TO L2A)                         ###
###                                                                      ###
############################################################################
############################################################################

# convert L1C to L2A
source(here("scripts", "R_scripts", "L1C_to_L2A.R"))

# Insert the path where "Sen2Cor" is installed in computer
L2A_process_path <-  file.path("C:", "Users", "sanaz", 
                               "Documents",  "Sen2Cor-02.08.00-win64", "L2A_Process.bat")

# 2017
# path of folder containing "L1C" data
inFolder <-  here::here("CREODIAS_part", "data_from_CREODIAS", "L1C_2017")

# path of folder where "L2A" should be saved
if(!dir.exists(here("CREODIAS_part", "data_from_CREODIAS", "L2A_2017_sen2cor"))){
  dir.create(here("CREODIAS_part", "data_from_CREODIAS", "L2A_2017_sen2cor"))
}

outFolder <-  here("CREODIAS_part", "data_from_CREODIAS", "L2A_2017_sen2cor")

# invoke function to start converting 2017
L1c2L2a(inFolder, L2A_process_path, outFolder)

# 2018
# path of folder containing "L1C" data
inFolder <-  here::here("CREODIAS_part", "data_from_CREODIAS", "L1C_2018")

# path of folder where "L2A" should be saved
if(!dir.exists(here("CREODIAS_part", "data_from_CREODIAS", "L2A_2018_sen2cor"))){
  dir.create(here("CREODIAS_part", "data_from_CREODIAS", "L2A_2018_sen2cor"))
}

outFolder <-  here("CREODIAS_part", "data_from_CREODIAS", "L2A_2018_sen2cor")

# invoke function to start converting 2018
L1c2L2a(inFolder, L2A_process_path, outFolder)


############################################################################
############################################################################
###                                                                      ###
###                              SECTION 4:                              ###
###                         CONVERT JP2 TO GTIFF                         ###
###                                                                      ###
############################################################################
############################################################################

# Convert jp2 to Gtiff using "jp2ToGtif()" in "2_Jp2ToGtiff_Resample.R" script
source(here("scripts", "R_scripts", "2_Jp2ToGtiff_Resample.R"))

pbapply::pblapply(1:length(year_list), 
                  function(x){
                    year_dir <- sprintf("L2A_%s_sen2cor", year_list[[x]][1])
                    
                    path <- here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    jp2ToGtif(path)
                  }
)

pbapply::pblapply(1:length(year_list_2), 
                  function(x){
                    year_dir <- sprintf("L2A_%s", year_list_2[[x]][1])
                    
                    path <- here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    jp2ToGtif(path)
                  }
)

############################################################################
############################################################################
###                                                                      ###
###                              SECTION 5:                              ###
###                              RGB FILES                               ###
###                                                                      ###
############################################################################
############################################################################

# Create RGB files to use in tile selection 
source(here("scripts", "R_scripts","8_tile_select_site_specific.R"))

# this directory can be changed to any other existing directory(specify where you want the RGBs to be saved)
rgb_dir <- here("data", "Augmented_data", "Playground_dir_10")

site_list <- list("MFC2", "GOR")

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                function(y) {
                                                  year_dir <- sprintf("L2A_%s_sen2cor", year_list[[y]][1])
                                                 
                                                  path <- here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                 
                                                  write_rgb(path, site_list[[x]][1], year_list[[y]][1], rgb_dir)
                                                 }))

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list_2), 
                                                function(y) {
                                                  year_dir <- sprintf("L2A_%s", year_list_2[[y]][1])
                                                                       
                                                  path <- here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
                                                  write_rgb(path, site_list[[x]][1], year_list_2[[y]][1], rgb_dir)
                                                                     }))

############################################################################
############################################################################
###                                                                      ###
###                              SECTION 6:                              ###
###                      SELECT TILES WITHOUT CLOUD                      ###
###                                                                      ###
############################################################################
############################################################################

# Select tiles without cloud cover over study areas

# input folder(Notice where you have saved your RGB files)
rgb_dir <- here("data", "Augmented_data", "Playground_dir_10")

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                     function(y) {
                                                                       
                                                                       tile_sel_rgb(site_list[[x]][1], year_list[[y]][1], rgb_dir)
                                                                       
                                                                     }))

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list_2), 
                                                                     function(y) {
                                                                       
                                                                       tile_sel_rgb(site_list[[x]][1], year_list_2[[y]][1], rgb_dir)
                                                                       
                                                                     }))

###########################################################################
###########################################################################
###                                                                     ###
###                              SECTION 7:                             ###
###         NORMALIZED DIFFERENCE VEGETATION INDEX (NDVI) TIFFS         ###
###                                                                     ###
###########################################################################
###########################################################################

# Create NDVIs and save to drive
source(here("scripts", "R_scripts","9_Cropped_Ndvi_from_Gtiff_Function.R"))

# Output directory of NDVI( change to your preferred directory)
ndvi_crop_dir <- here("data", "Augmented_data", "Playground_dir_8", "NDVI")

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                     function(y) {
                                                                       year_dir <- sprintf("L2A_%s_sen2cor", year_list[[y]][1])
                                                                       
                                                                       path <- here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
                                                                       write_NDVI_site_year(path, site_list[[x]][1], year_list[[y]][1], ndvi_crop_dir)
                                                                       
                                                                     }))

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list_2), 
                                                                     function(y) {
                                                                       year_dir <- sprintf("L2A_%s", year_list_2[[y]][1])
                                                                       
                                                                       path <- here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
                                                                       write_NDVI_site_year(path, site_list[[x]][1], year_list_2[[y]][1], ndvi_crop_dir)
                                                                       
                                                                     }))

###########################################################################
###########################################################################
###                                                                     ###
###                              SECTION 8:                             ###
###                 NDVI DATAFRAMES & TIME SERIES PLOTS                 ###
###                                                                     ###
###########################################################################
###########################################################################

# Save NDVI dataframes, NDVI-plots of selected tiles & NDVI time series 

# input directory for the "NDVI_plots_site_year" function
ndvi_dir_base <- here("data", "Augmented_data","Playground_dir_8", "NDVI")

# input rgb directory
rgb_dir_base <- here("data", "Augmented_data", "Playground_dir_10")

# directory for saving the selected NDVI stack into drive to use in "correlation"
save_dir <- here("data", "Augmented_data", "Playground_dir_14", "NDVI")

# Save the avearge NDVI dataframe to drive (will be used in "17_Correlation_NDWI_with_NDVI.R")
save_dir_avg <- here("data", "Augmented_data", "Playground_dir_8", "NDVI", "output")


full_year_list <- list(2017, 2018, 2019, 2020)

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(full_year_list), 
                                                                     function(y) {
                                                                       
                                                                       NDVI_plots_site_year(site_list[[x]][1], full_year_list[[y]][1], 
                                                                                            ndvi_dir_base, 
                                                                                            rgb_dir_base, 
                                                                                            save_dir, 
                                                                                            save_dir_avg)
                                                                       
                                                                     }))

############################################################################
############################################################################
###                                                                      ###
###                              SECTION 9:                              ###
###      NORMALIZED DIFFERENCE WATER INDEX (NDWI) [GAO, 1996] TIFFS      ###
###                                                                      ###
############################################################################
############################################################################

# Create NDWIs and save to drive
source(here("scripts", "R_scripts","16_NDWI.R"))

# Output directory of NDWI( change to your preferred directory)
ndwi_crop_dir <- here("data", "Augmented_data", "Playground_dir_15")


pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                     function(y) {
                                                                       year_dir <- sprintf("L2A_%s_sen2cor", year_list[[y]][1])
                                                                       
                                                                       path <- here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
                                                                       write_NDWI_site_year(path, site_list[[x]][1], year_list[[y]][1], ndwi_crop_dir)
                                                                       
                                                                     }))

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list_2), 
                                                                     function(y) {
                                                                       year_dir <- sprintf("L2A_%s", year_list_2[[y]][1])
                                                                       
                                                                       path <- here("CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
                                                                       write_NDWI_site_year(path, site_list[[x]][1], year_list_2[[y]][1], ndwi_crop_dir)
                                                                       
                                                                     }))

###########################################################################
###########################################################################
###                                                                     ###
###                             SECTION 10:                             ###
###                 NDWI DATAFRAMES & TIME SERIES PLOTS                 ###
###                                                                     ###
###########################################################################
###########################################################################

# Saves NDWI dataframes to drive, also plots the NDWI time series & writes the dfs & plots to drive

# input directory of ndwi (wherever the NDWIs are saved)
ndwi_crop_dir <- here("data", "Augmented_data", "Playground_dir_15") 

# save the selected NDWI stack into drive to use in "correlation"
save_dir_ndwi <- here("data", "Augmented_data","Playground_dir_14", "NDWI")

# directory for saving NDWI plots of selected tiles and NDWI time series as png files
write_dir_ndwi <- here("data", "Augmented_data","Playground_dir_8", "NDWI")

# directory for saving average of NDWI stack over whole study area 
save_dir_avg_ndwi <- here("data", "Augmented_data", "Playground_dir_8", "NDWI","output")

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(full_year_list), 
                                                                     function(y) {
                                                                       
                                                                       NDWI_dfs_site_year(site_list[[x]][1], 
                                                                                          full_year_list[[y]][1], 
                                                                                          ndwi_crop_dir, 
                                                                                          save_dir_ndwi, 
                                                                                          write_dir_ndwi, 
                                                                                          save_dir_avg_ndwi)
                                                                       
                                                                     }))

############################################################################
############################################################################
###                                                                      ###
###                              SECTION 11:                             ###
###  CORRELATION OF VEGETATION INDEXES WITH TOPOGRAPHIC ATTRIBUTES(TAS)  ###
###                                                                      ###
############################################################################
############################################################################

# Correlation 
source(here::here("scripts", "R_scripts","17_Correlation_TAs_with_VIs.R"))

#VI input directory
vi_dir <- here::here("data", "Augmented_data", "Playground_dir_14")


#TA input dir
dir_ta <- here::here("data", "Raw_data", "Gridded_topographic_attributes")

# output dir
out_dir <- here::here(vi_dir, "output")

# list of VIs
vi_list <- list("NDVI", "NDWI")

pbapply::pblapply(1:length(vi_list), function(x) pbapply::pblapply(1:length(site_list), 
                                                                     function(y) {
                                                                       corr_ta_vi(vi=vi_list[[y]][1], 
                                                                                  site=site_list[[x]][1], 
                                                                                  vi_dir = vi_dir, 
                                                                                  dir_ta = dir_ta, 
                                                                                  out_dir = out_dir) 
                                                                     }))

############################################################################
############################################################################
###                                                                      ###
###                              SECTION 12:                             ###
###                     VISUALIZATION OF CORRELATION                     ###
###                                                                      ###
############################################################################
############################################################################

# Visualization of correlation Matrix(using corrplot())

#VI input directory
vi_dir <- here::here("data", "Augmented_data", "Playground_dir_14")

cor_matrix_dir <- here::here(vi_dir, "output")

site_list <- list("MFC2", "GOR")

# Finds the full path of correlation matrixes containing the specified study site name
cor_matrix_names <- pbapply::pblapply(1:length(site_list), 
                                      function(x){
                                        list.files(cor_matrix_dir,
                                                   pattern = sprintf("*%s*.csv", site_list[x][[1]]),
                                                   full.names = TRUE)
                                      }
)


pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(cor_matrix_names[[x]]), 
                                                                     function(y){
                                                                       # import the .csv matrixes into R(Be aware that read.csv() output is in dataframe class)
                                                                       dec = "."    
                                                                       df <- read.csv(cor_matrix_names[[x]][y], dec=dec, 
                                                                                      header = TRUE, stringsAsFactors=FALSE)
                                                                       
                                                                       # convert "character" to "numeric" in dataframe
                                                                       cols.num <- colnames(df)[2:11]
                                                                       
                                                                       df[cols.num] <- sapply(df[cols.num], as.numeric)
                                                                       
                                                                       # convert df to matrix (needed for corrplot() function)
                                                                       my_mat <- apply(as.matrix.noquote(df),  # Using apply function
                                                                                       2,
                                                                                       as.numeric)
                                                                       
                                                                       # Give the names of columns to rows
                                                                       rownames(my_mat) <- colnames(my_mat)[2:11]
                                                                       
                                                                       pdf(file = file.path(cor_matrix_dir, 
                                                                                            paste0(strsplit(basename(cor_matrix_names[[x]][y]), ".csv"), "_Corrplot.pdf")),
                                                                           width = 10,
                                                                           height = 10)
                                                                       
                                                                       corrplot::corrplot(my_mat[1:10,2:11], 
                                                                                          method = "square",
                                                                                          type="upper",
                                                                                          title= sprintf("%s correlation plot", site_list[x][[1]]),
                                                                                          addCoef.col = "black", # Add coefficient of correlation
                                                                                          # Combine with significance
                                                                                          sig.level = 0.05, insig = "blank", 
                                                                                          #diag=FALSE,
                                                                                          # hide correlation coefficient on the principal diagonal
                                                                                          mar=c(0,0,1,0) # http://stackoverflow.com/a/14754408/54964)
                                                                       )
                                                                       
                                                                       dev.off()
                                                                       
                                                                     })
)

############################################################################
############################################################################
###                                                                      ###
###                              SECTION 13:                             ###
###   CORRELATION OF VEGETATION INDEXES WITH METEOROLOGICAL PARAMETERS   ###
###                                                                      ###
############################################################################
############################################################################

source(here::here("scripts", "R_scripts","Correlation_NDVI_NDWI_with_meteo.R"))

write_dir <- here("data", "Augmented_data","Playground_dir_11","output")

# invoke the function 
create_vi_meteo_dfs(write_dir)

# read in the data 
df_mfc2_four_yrs <- read.csv(here::here("data","Augmented_data", "Playground_dir_11",
                                        "output", "df_mfc2_with_Season.csv"))

df_gor_four_yrs <- read.csv(here::here("data","Augmented_data", "Playground_dir_11",
                                       "output", "df_gor1_with_Season.csv"))

# create list of dfs
list_df_four_yrs <- list(df_mfc2_four_yrs, df_gor_four_yrs)

if(!dir.exists(here("data","Augmented_data", "Playground_dir_11", "tables"))){
  dir.create(here("data","Augmented_data", "Playground_dir_11", "tables"))
}
if(!dir.exists(here("data","Augmented_data", "Playground_dir_11", "tables", "GOR1"))){
  dir.create(here("data","Augmented_data", "Playground_dir_11", "tables", "GOR1"))
}
if(!dir.exists(here("data","Augmented_data", "Playground_dir_11", "tables", "MFC2"))){
  dir.create(here("data","Augmented_data", "Playground_dir_11", "tables", "MFC2"))
}

# "arsenal" package for summary tables
#GOR1
my_controls <-  arsenal::tableby.control(
  test = T,
  total = T,
  numeric.test = "anova", 
  cat.test = "chisq",
  numeric.stats = c("meansd", "medianq1q3", "range"),
  cat.stats = c("countpct", "Nmiss2"),
  stats.labels = list(
    meansd = "Mean (SD)",
    medianq1q3 = "Median (Q1, Q3)",
    range = "Min - Max"
  )
)

# NDVI in this dataframe represents 
# the mean NDVI value for this area of interest on a given day.
my_labels <- list(
  T_Celsius = "Temperature (°C)",
  Prec_mm = "Precipitation (mm)",
  ET0_mm = "Evapotranspiration (mm)",
  meanNDVI = "mean NDVI over study area"
)

df_gor_four_yrs$season_factor <- as.factor(df_gor_four_yrs$season)

table_two <-  arsenal::tableby(season_factor ~ .,
                               data = df_gor_four_yrs,
                               control = my_controls
)

summary(table_two,
        labelTranslations = my_labels,
        title = "Summary Statistic of GOR1 Dataframe"
)


# MFC2
my_controls <- arsenal::tableby.control(
  test = T,
  total = T,
  numeric.test = "anova", 
  cat.test = "chisq",
  numeric.stats = c("meansd", "medianq1q3", "range"),
  cat.stats = c("countpct", "Nmiss2"),
  stats.labels = list(
    meansd = "Mean (SD)",
    medianq1q3 = "Median (Q1, Q3)",
    range = "Min - Max"
  )
)


my_labels <- list(
  T_Celsius = "Temperature (Â°C)",
  Prec_mm = "Precipitation (mm)",
  ET0_mm = "Evapotranspiration (mm)",
  meanNDVI = "mean NDVI over study area"
)

df_mfc2_four_yrs$season_factor <- as.factor(df_mfc2_four_yrs$season)

table_two <-  arsenal::tableby(season_factor ~ .,
                               data = df_mfc2_four_yrs,
                               control = my_controls
)

summary(table_two,
        labelTranslations = my_labels,
        title = "Summary Statistic of MFC2 Dataframe"
)


# Scatter plot with correlation coefficient
plot_dir <- here("data","Augmented_data","Playground_dir_11", "plots")

# Convert "Year" as a grouping variable
list_df_four_yrs_factorized <- pbapply::pblapply(1:length(site_list), 
                                                 function(x){
                                                   list_df_four_yrs[[x]]$Year <- as.character(list_df_four_yrs[[x]]$Year);
                                                   list_df_four_yrs[[x]]$Year <- factor(list_df_four_yrs[[x]]$Year, levels=c("2017", "2018", "2019", "2020"));
                                                   return(list_df_four_yrs[[x]])
                                                   
                                                 }
)


list_parameter <- list("Temperature", "Precipitation", "Evapotranspiration")

list_method <- list("spearman", "pearson", "kendall")

list_vi <- list("NDVI", "NDWI")

pbapply::pblapply(1:length(list_parameter), 
                  function(x) pbapply::pblapply(1:length(list_vi), 
                                                function(y) pbapply::pblapply(1:length(list_method),
                                                                              function(z) {
                                                                                if(list_parameter[[x]] == "Temperature"){x_axis_name <- "T_Celsius"; metric <- "[°C]"}
                                                                                                                             
                                                                                 else if(list_parameter[[x]] == "Precipitation"){x_axis_name <- "Prec_mm"; metric <- "[mm]"}
                                                                                                                             
                                                                                 else if(list_parameter[[x]] == "Evapotranspiration"){x_axis_name <- "ET0_mm"; metric <- "[mm]"} 
                                                                                                                             
                                                                                                                             
                                                                                 sp <- ggscatter(rbind(list_df_four_yrs_factorized[[1]], list_df_four_yrs_factorized[[2]]),
                                                                                                 x = x_axis_name,#"T_Celsius", 
                                                                                                 y = sprintf("mean%s", list_vi[[y]]),
                                                                                                 parse=TRUE,
                                                                                                 # combine = TRUE
                                                                                                 add = "reg.line",  # Add regressin line
                                                                                                 add.params = list(color = "black", fill = "lightgray"), # Customize reg. line
                                                                                                 fullrange= TRUE, 
                                                                                                 color = "Year",
                                                                                                 title = sprintf("%s correlation coefficient & p-value for %s vs. %s", 
                                                                                                                 list_method[[z]], list_parameter[[x]], list_vi[[y]]), 
                                                                                                 palette = c("blue", "red", "green","orange"),
                                                                                                 facet.by= "site.x",#"Year",##c("Year", "site.x"),
                                                                                                 xlab = sprintf("%s %s", list_parameter[[x]], metric), 
                                                                                                 ylab = sprintf("%s [-]", list_vi[[y]]), 
                                                                                                 conf.int = FALSE # Add confidence interval
                                                                                                                             );
                                                                                                                             
                                                                                   # Add correlation coefficient   
                                                                                   sp + stat_cor(aes(color = Year), label.x = 4 ,
                                                                                                 method = list_method[[z]],
                                                                                                 #label = paste0("R = ", ..r.., ", P = ", ..p..),
                                                                                                 label.x.npc =  'left', 
                                                                                                 label.y.npc = 'bottom');
                                                                                                                             
                                                                                    ggsave(here(plot_dir, paste0(sprintf("%s_%s_correlation_r_%s_sites_yrs", 
                                                                                                                         list_parameter[[x]], list_vi[[y]], list_method[[z]]), ".pdf")), #spearman
                                                                                           scale = 1, 
                                                                                           width = 10,
                                                                                           height = 10,
                                                                                           dpi = 300);
                                                                                                                           }
)))
