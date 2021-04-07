
setwd("C:/Users/sanaz/")

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
source(here("Documents", "MB12-project", "scripts", "R_scripts", "download_from_creodias.R"))

# Here insert your credentials from creodias
username <- "YOUR CREODIAS USERNAME HERE"

password <- "YOUR CREODIAS PASSWORD HERE"

# The 'finder_api_url' is "Rest query" created after specifying search criteria in "https://finder.creodias.eu/";
# one should visit the mentioned website, search for the product and copy the content of "Rest query" to the following line
finder_api_url = 'https://finder.creodias.eu/resto/api/collections/Sentinel2/search.json?maxRecords=10&startDate=2021-04-01T00%3A00%3A00Z&completionDate=2021-04-07T23%3A59%3A59Z&cloudCover=%5B0%2C80%5D&processingLevel=LEVEL1C&geometry=POLYGON((14.900562186990717+40.62231989565893%2C14.936503116659681+40.597907191371405%2C14.95920265118745+40.63380514092955%2C14.900562186990717+40.62231989565893))&sortParam=startDate&sortOrder=descending&status=all&dataset=ESA-DATASET'

# specify where the files should be saved on drive
download_path <- here("Desktop", "Playground_dir_17")

# call the function to start downloading
download_creodias(username, password, finder_api_url, download_path)


###########################################################################
###########################################################################
###                                                                     ###
###                              SECTION 3:                             ###
###                             UNZIP TILES                             ###
###                                                                     ###
###########################################################################
###########################################################################

## Unzip tiles using the unzip_s2_tiles() function in "1_Unzip.R" script
source(here("Documents", "MB12-project", "scripts", "R_scripts", "1_Unzip.R"))

year_list <- list(2017, 2018)

pbapply::pblapply(1:length(year_list), 
                  function(x){
                    year_dir <- sprintf("L1C_%s", year_list[[x]][1])
                    
                    path_zip <- here::here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    out_dir <- here::here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    unzip_s2_tiles(path_zip, out_dir)
                  }
)

year_list_2 <- list(2019, 2020)

pbapply::pblapply(1:length(year_list_2), 
                  function(x){
                    year_dir <- sprintf("L2A_%s", year_list_2[[x]][1])
                    
                    path_zip <- here::here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    out_dir <- here::here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    unzip_s2_tiles(path_zip, out_dir)
                  }
)

############################################################################
############################################################################
###                                                                      ###
###                              SECTION 4:                              ###
###                         CONVERT JP2 TO GTIFF                         ###
###                                                                      ###
############################################################################
############################################################################

# Convert jp2 to Gtiff using "jp2ToGtif()" in "2_Jp2ToGtiff_Resample.R" script
source(here("Documents", "MB12-project", "scripts", "R_scripts", "2_Jp2ToGtiff_Resample.R"))

pbapply::pblapply(1:length(year_list), 
                  function(x){
                    year_dir <- sprintf("L2A_%s_sen2cor", year_list[[x]][1])
                    
                    path <- here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
                    jp2ToGtif(path)
                  }
)

pbapply::pblapply(1:length(year_list_2), 
                  function(x){
                    year_dir <- sprintf("L2A_%s", year_list_2[[x]][1])
                    
                    path <- here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                    
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
source(here("Documents", "MB12-project", "scripts", "R_scripts","8_tile_select_site_specific.R"))

# this directory can be changed to any other existing directory(specify where you want the RGBs to be saved)
rgb_dir <- here("Desktop", "Playground_dir_10")

site_list <- list("MFC2", "GOR")

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                               function(y) {
                                                 year_dir <- sprintf("L2A_%s_sen2cor", year_list[[y]][1])
                                                 
                                                 path <- here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                 
                                                 write_rgb(path, site_list[[x]][1], year_list[[y]][1])
                                                 }))

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list_2), 
                                                                     function(y) {
                                                                       year_dir <- sprintf("L2A_%s_sen2cor", year_list_2[[y]][1])
                                                                       
                                                                       path <- here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
                                                                       write_rgb(path, site_list[[x]][1], year_list_2[[y]][1])
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
rgb_dir <- here("Desktop","Playground_dir_10")

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
source(here("Documents", "MB12-project", "scripts", "R_scripts","9_Cropped_Ndvi_from_Gtiff_Function.R"))

# Output directory of NDVI( change to your preferred directory)
ndvi_crop_dir <- here("Desktop", "Playground_dir_8", "NDVI")

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                     function(y) {
                                                                       year_dir <- sprintf("L2A_%s_sen2cor", year_list[[y]][1])
                                                                       
                                                                       path <- here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
                                                                       write_NDVI_site_year(path, site_list[[x]][1], year_list[[y]][1], ndvi_crop_dir)
                                                                       
                                                                     }))

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list_2), 
                                                                     function(y) {
                                                                       year_dir <- sprintf("L2A_%s", year_list_2[[y]][1])
                                                                       
                                                                       path <- here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
                                                                       write_NDVI_site_year(path, site_list[[x]][1], year_list[[y]][1], ndvi_crop_dir)
                                                                       
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
ndvi_dir_base <- here("Desktop","Playground_dir_8", "NDVI")

# input rgb directory
rgb_dir_base <- here("Desktop", "Playground_dir_10")

# directory for saving the selected NDVI stack into drive to use in "correlation"
save_dir <- here("Desktop","Playground_dir_14", "NDVI")

# Save the avearge NDVI dataframe to drive (will be used in "17_Correlation_NDWI_with_NDVI.R")
save_dir_avg <- here("Desktop", "Playground_dir_8", "NDVI", "output")


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
source(here("Documents", "MB12-project", "scripts", "R_scripts","16_NDWI.R"))

# Output directory of NDVI( change to your preferred directory)
ndwi_crop_dir <- here("Desktop", "Playground_dir_15")


pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                     function(y) {
                                                                       year_dir <- sprintf("L2A_%s_sen2cor", year_list[[y]][1])
                                                                       
                                                                       path <- here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
                                                                       write_NDWI_site_year(path, site_list[[x]][1], year_list[[y]][1], ndwi_crop_dir)
                                                                       
                                                                     }))

pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list_2), 
                                                                     function(y) {
                                                                       year_dir <- sprintf("L2A_%s", year_list_2[[y]][1])
                                                                       
                                                                       path <- here("Documents", "MB12-project", "CREODIAS_part", "data_from_CREODIAS", year_dir)
                                                                       
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
ndwi_crop_dir <- here("Desktop", "Playground_dir_15") 

# save the selected NDWI stack into drive to use in "correlation"
save_dir_ndwi <- here("Desktop","Playground_dir_14", "NDWI")

# directory for saving NDWI plots of selected tiles and NDWI time series as png files
write_dir_ndwi <- here("Desktop","Playground_dir_8", "NDWI")

# directory for saving average of NDWI stack over whole study area 
save_dir_avg_ndwi <- here("Desktop", "Playground_dir_8", "NDWI","output")

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
source(here("Documents", "MB12-project", "scripts", "R_scripts","17_Correlation_TAs_with_VIs.R"))

#VI input directory
vi_dir <- here("Desktop","Playground_dir_14")


#TA input dir
dir_ta <- here("Documents", "MB12-project", "data",
               "Gridded_topographic_attributes")

# output dir
out_dir <- here(vi_dir, "output")

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

cor_matrix_dir <- here(vi_dir, "output")

# Finds the full path of correlation matrixes containing the specified study site name
cor_matrix_names <- list.files(cor_matrix_dir,
                               pattern = sprintf("*%s*.csv", site),
                               full.names = TRUE)

# Create the correlation plots and writes them as pdf
if(length(cor_matrix_names)){cor_matrix <- pbapply::pblapply(1:length(cor_matrix_names), 
                                                             function(x){
                                                               # import the .csv matrixes into R(Be aware that read.csv() output is in dataframe class)
                                                               dec = "."    
                                                               df <- read.csv(cor_matrix_names[x], dec=dec, 
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
                                                                                    paste0(strsplit(basename(cor_matrix_names[x]), ".csv"), "_Corrplot.pdf")),
                                                                   width = 10,
                                                                   height = 10)
                                                               
                                                               corrplot::corrplot(my_mat[1:10,2:11], 
                                                                                  method = "square",
                                                                                  type="upper",
                                                                                  title= sprintf("%s correlation plot", site),
                                                                                  addCoef.col = "black", # Add coefficient of correlation
                                                                                  # Combine with significance
                                                                                  sig.level = 0.05, insig = "blank", 
                                                                                  #diag=FALSE,
                                                                                  # hide correlation coefficient on the principal diagonal
                                                                                  mar=c(0,0,1,0) # http://stackoverflow.com/a/14754408/54964)
                                                               )
                                                               
                                                               dev.off()
                                                               
                                                             })
}

