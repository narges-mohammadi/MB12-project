##############
# The following function(jp2ToGtif) converts the .jp2 bands of S2 to .tiff files
# and removes the jp2 bands afterward(for B2348,B8A,B11,B05)
################

#set working directory
setwd("C:/Users/sanaz/")

jp2ToGtif <- function(path){
#1: Load R packages
## Install & load packages
pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet","rasterVis",
          "gridExtra","RColorBrewer","plotly","RStoolbox","sp","IRdisplay",
          "reshape", "gdalUtils","here", "pbapply"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)



# Load Sentinel2 safe directories
S2_names_safe <- path#here("Documents","MB12-project","CREODIAS_part","data_from_CREODIAS","L2A_2018_sen2cor")

S2_names_1 <- list.files(S2_names_safe, recursive = FALSE, full.names = TRUE, 
                         pattern="*.SAFE$")#for 2019 & 2020: "*.SAFE$"

### B2, B3, B4, B8(NDVI) ############################# 
# B2, B3, B4, B8: (10m resolution)
S2_safe_dir_T <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                            pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.jp2$")#^[T][[:alnum:]]{5}_[[:alnum:]]{15}_
S2_safe_dir_L2A <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                              pattern="L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B0[2348]_10m.jp2$")


# Convert jp2 to Gtiff and remove the Jp2 bands for B2, B3,B4, B8
if(length(S2_safe_dir_T)){S2_gtiff_T <- pbapply::pblapply(1:length(S2_safe_dir_T), 
                     function(x){base_dir <- sub("[[:alnum:]]{6}_[[:alnum:]]{15}_B0[2,3,4,8]_10m.jp2$", "", S2_safe_dir_T[x]); 
                     name <- paste0(strsplit(basename(S2_safe_dir_T[x]),'[.]')[[1]][1],".tif"); 
                     path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_T[x], path_name); 
                     unlink(S2_safe_dir_T[x], recursive=TRUE, force = TRUE)}) }

 if(length(S2_safe_dir_L2A)){S2_gtiff_L2A <- pbapply::pblapply(1:length(S2_safe_dir_L2A), 
                       function(x){base_dir <- sub("L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B0[2,3,4,8]_10m.jp2$", "", S2_safe_dir_L2A[x]); 
                       name <- paste0(strsplit(basename(S2_safe_dir_L2A[x]),'[.]')[[1]][1],".tif"); 
                       path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_L2A[x], path_name);
                       unlink(S2_safe_dir_L2A[x], recursive=TRUE, force = TRUE)})}



### B8A, B11( NDWI(Gao) ) ############################# 
# B11
S2_safe_dir_B11_T <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                            pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B11_20m.jp2$")#^[T][[:alnum:]]{5}_[[:alnum:]]{15}_
S2_safe_dir_B11_L2A <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                              pattern="L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B11_20m.jp2$")

# Convert jp2 to Gtiff and remove the Jp2 bands for B11(20m resolution)
if(length(S2_safe_dir_B11_T)){S2_gtiff_B11_T <- pbapply::pblapply(1:length(S2_safe_dir_B11_T), 
                     function(x){base_dir <- sub("[[:alnum:]]{6}_[[:alnum:]]{15}_B11_20m.jp2$", "", S2_safe_dir_B11_T[x]); 
                     name <- paste0(strsplit(basename(S2_safe_dir_B11_T[x]),'[.]')[[1]][1],".tif"); 
                     path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_B11_T[x], path_name)
                     #;unlink(S2_safe_dir_B11_T[x], recursive=TRUE, force = TRUE)
                     }) }

if(length(S2_safe_dir_B11_L2A)){S2_gtiff_B11_L2A <- pbapply::pblapply(1:length(S2_safe_dir_B11_L2A), 
                       function(x){base_dir <- sub("L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B11_20m.jp2$", "", S2_safe_dir_B11_L2A[x]); 
                       name <- paste0(strsplit(basename(S2_safe_dir_B11_L2A[x]),'[.]')[[1]][1],".tif"); 
                       path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_B11_L2A[x], path_name)
                       #;unlink(S2_safe_dir_B11_L2A[x], recursive=TRUE, force = TRUE)
                       })}

# B8A
S2_safe_dir_B8a_T <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                                pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B8A_20m.jp2$")#^[T][[:alnum:]]{5}_[[:alnum:]]{15}_
S2_safe_dir_B8a_L2A <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                                  pattern="L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B8A_20m.jp2$")

# Convert jp2 to Gtiff and remove the Jp2 bands for B8A(20m resolution)
if(length(S2_safe_dir_B8a_T)){S2_gtiff_B8a_T <- pbapply::pblapply(1:length(S2_safe_dir_B8a_T), 
                                                                  function(x){base_dir <- sub("[[:alnum:]]{6}_[[:alnum:]]{15}_B8A_20m.jp2$", "", S2_safe_dir_B8a_T[x]); 
                                                                  name <- paste0(strsplit(basename(S2_safe_dir_B8a_T[x]),'[.]')[[1]][1],".tif"); 
                                                                  path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_B8a_T[x], path_name)
                                                                  #;unlink(S2_safe_dir_B8a_T[x], recursive=TRUE, force = TRUE)
                                                                  }) }

if(length(S2_safe_dir_B8a_L2A)){S2_gtiff_B8a_L2A <- pbapply::pblapply(1:length(S2_safe_dir_B8a_L2A), 
                                                                      function(x){base_dir <- sub("L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B8A_20m.jp2$", "", S2_safe_dir_B8a_L2A[x]); 
                                                                      name <- paste0(strsplit(basename(S2_safe_dir_B8a_L2A[x]),'[.]')[[1]][1],".tif"); 
                                                                      path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_B8a_L2A[x], path_name)
                                                                      #;unlink(S2_safe_dir_B8a_L2A[x], recursive=TRUE, force = TRUE)
                                                                      })}
# B05
S2_safe_dir_B5_T <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                                pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B05_20m.jp2$")#^[T][[:alnum:]]{5}_[[:alnum:]]{15}_
S2_safe_dir_B5_L2A <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                                  pattern="L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B05_20m.jp2$")

# Convert jp2 to Gtiff and remove the Jp2 bands for B05(20m resolution)
if(length(S2_safe_dir_B5_T)){S2_gtiff_B5_T <- pbapply::pblapply(1:length(S2_safe_dir_B5_T), 
                                                                  function(x){base_dir <- sub("[[:alnum:]]{6}_[[:alnum:]]{15}_B05_20m.jp2$", "", S2_safe_dir_B5_T[x]); 
                                                                  name <- paste0(strsplit(basename(S2_safe_dir_B5_T[x]),'[.]')[[1]][1],".tif"); 
                                                                  path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_B5_T[x], path_name) 
                                                                  #; unlink(S2_safe_dir_B7_T[x], recursive=TRUE, force = TRUE)
                                                                  }) }

if(length(S2_safe_dir_B5_L2A)){S2_gtiff_B5_L2A <- pbapply::pblapply(1:length(S2_safe_dir_B5_L2A), 
                                                                      function(x){base_dir <- sub("L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B05_20m.jp2$", "", S2_safe_dir_B5_L2A[x]); 
                                                                      name <- paste0(strsplit(basename(S2_safe_dir_B5_L2A[x]),'[.]')[[1]][1],".tif"); 
                                                                      path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_B5_L2A[x], path_name)
                                                                      #; unlink(S2_safe_dir_B7_L2A[x], recursive=TRUE, force = TRUE)
                                                                      })}




}

library(here)
path <- here("Documents","MB12-project","CREODIAS_part","data_from_CREODIAS","L2A_2018_sen2cor")

# call the function to work on the specified path
jp2ToGtif(path)


# resample B11 to 10 m resolution (This part is not necessary anymore(reason of commenting this section) as NDWI(Gao) needs B8A(with 20m resolution and not B8))
# S2_safe_dir_B11_T_new <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
#                                    pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B11_20m.tif$")#^[T][[:alnum:]]{5}_[[:alnum:]]{15}_
# S2_safe_dir_B11_L2A_new <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
#                                      pattern="L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B11_20m.tif$")
# 
# 
# if(length(S2_safe_dir_B11_T_new)){S2_gtiff_resample_B11_T <- pbapply::pblapply(1:length(S2_safe_dir_B11_T_new), 
#                          function(x){
#                          base_dir <- sub("T33TWE_[[:alnum:]]{15}_B11_20m.tif$", "",
#                                          S2_safe_dir_B11_T_new[x]); 
#                          # to remove the final "/" from the path
#                          base_dir <- here(base_dir)
#                          name <- paste(strsplit(strsplit(basename(S2_safe_dir_B11_T_new[1]), "\\.")[[1]][1], "_")[[1]][1],
#                                        strsplit(strsplit(basename(S2_safe_dir_B11_T_new[1]), "\\.")[[1]][1], "_")[[1]][2],
#                                        strsplit(strsplit(basename(S2_safe_dir_B11_T_new[1]), "\\.")[[1]][1], "_")[[1]][3],
#                                        "resampled",sep = "_");
#                          name_complete <- paste0(name, ".tif")
#                          path_name <- file.path(base_dir, name_complete); 
#                          src_dataset <- S2_safe_dir_B11_T_new[x];
#                          dst_dataset <- path_name;
#                          gdal_translate(src_dataset, dst_dataset, 
#                                         tr=c(10,10), r="bilinear", verbose = T);
#                          }) }
# 
# if(length(S2_safe_dir_B11_L2A_new)){S2_gtiff_resample_B11_L2A <- pbapply::pblapply(1:length(S2_safe_dir_B11_L2A_new), 
#                                   function(x){
#                                       base_dir <- sub("L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B11_20m.tif$", "",
#                                                       S2_safe_dir_B11_L2A_new[x]); 
#                                       # to remove the final "/" from the path
#                                       base_dir <- here(base_dir)
#                                       name <- paste(strsplit(basename(S2_safe_dir_B11_L2A_new[x]), "_")[[1]][1],
#                                                     strsplit(basename(S2_safe_dir_B11_L2A_new[x]), "_")[[1]][2],
#                                                     strsplit(basename(S2_safe_dir_B11_L2A_new[x]), "_")[[1]][3],
#                                                     strsplit(basename(S2_safe_dir_B11_L2A_new[x]), "_")[[1]][4],
#                                                     "resampled",sep = "_");
#                                       name_complete <- paste0(name, ".tif")
#                                       path_name <- file.path(base_dir, name_complete); 
#                                       src_dataset <- S2_safe_dir_B11_L2A_new[x];
#                                       dst_dataset <- path_name;
#                                       gdal_translate(src_dataset, dst_dataset, 
#                                                      tr=c(10,10), r="bilinear", verbose = T);
#                                   }) }



# These parts are for testing my functions to see if they work 
### defining the "resample()" function from 20 m to 10 m ############################# 
resample <- function(x){
    base_dir <- sub("L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B11_20m$", "", x); 
    # to remove the final "/" from the path
    base_dir <- here(base_dir)
    name <- paste(strsplit(basename(x), "_")[[1]][1],
                  strsplit(basename(x), "_")[[1]][2],
                  strsplit(basename(x), "_")[[1]][3],
                  strsplit(basename(x), "_")[[1]][4], "resampled",sep = "_");
    name_complete <- paste0(name, ".tif")
    path_name <- file.path(base_dir, name_complete); 
    src_dataset <- x;
    dst_dataset <- path_name;
    gdal_translate(src_dataset, dst_dataset, 
                   tr=c(10,10), r="bilinear", verbose = T);
    
}

x <- here("Desktop", "S2B_MSIL2A_20171010T095019_N0205_R079_T33TWE_20171010T095105.SAFE",
          "GRANULE", "L2A_T33TWE_A003108_20171010T095105", "IMG_DATA", 
          "R20m", "L2A_T33TWE_20171010T095019_B11_20m.tif")# remember that the suffix should be exactly ".tif"

#x_2 <- here("Desktop", "L2A_B11_20m.tif")
resample(x)


### defining the "convert()" function ############################# 
convert <- function(x){
    base_dir <- sub("L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B0[2,3,4,8]_10m.jp2$", "", x); 
    name <- paste0(strsplit(basename(x),'[.]')[[1]][1],".tif"); 
    path_name <- file.path(base_dir, name); 
    gdal_translate(x, path_name);
    unlink(x, recursive=TRUE, force = TRUE)
}

x <- "C:\\Users\\sanaz\\Documents\\MB12-project\\CREODIAS_part\\data_from_CREODIAS\\L2A_2018\\S2B_MSIL2A_20180319T095019_N0206_R079_T33TWE_20180319T115422.SAFE\\GRANULE\\L2A_T33TWE_A005396_20180319T095605\\IMG_DATA\\R10m\\L2A_T33TWE_20180319T095019_B08_10m.jp2"
convert(z)

