##############
# The following snippet is converting the .jp2 bands of sentinel2 to .tiff files
# and removing the jp2 bands afterward
################

#1: Load R packages
## Install & load packages
pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet","rasterVis","gridExtra","RColorBrewer","plotly","RStoolbox","sp","IRdisplay","reshape", "gdalUtils"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)


#set working directory
setwd("C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/L2A_2017")#"C:/Users/sanaz/Desktop/Playground_dir_2"


# Load Sentinel2 safe directories
S2_names_safe <- "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/L2A_2017"#"C:/Users/sanaz/Desktop/Playground_dir_2"
S2_safe_dir_T <- list.files(S2_names_safe, recursive = TRUE, full.names = TRUE, pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.jp2$")#^[T][[:alnum:]]{5}_[[:alnum:]]{15}_
S2_safe_dir_L2A <- list.files(S2_names_safe, recursive = TRUE, full.names = TRUE, pattern="L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B0[2348]_10m.jp2$")

# Convert jp2 to Gtiff and remove the Jp2 bands
S2_gtiff_T <- lapply(1:length(S2_safe_dir_T), function(x){base_dir <- sub("[[:alnum:]]{6}_[[:alnum:]]{15}_B0[2,3,4,8]_10m.jp2$", "", S2_safe_dir_T[x]); name <- paste0(strsplit(basename(S2_safe_dir_T[x]),'[.]')[[1]][1],".tif"); path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_T[x],path_name); unlink(S2_safe_dir_T[x], recursive=TRUE, force = TRUE)}) 

S2_gtiff_L2A <- lapply(1:length(S2_safe_dir_L2A), function(x){base_dir <- sub("L2A_[[:alnum:]]{6}_[[:alnum:]]{15}_B0[2,3,4,8]_10m.jp2$", "", S2_safe_dir_L2A[x]); name <- paste0(strsplit(basename(S2_safe_dir_L2A[x]),'[.]')[[1]][1],".tif"); path_name <- file.path(base_dir, name); gdal_translate(S2_safe_dir_L2A[x],path_name); unlink(S2_safe_dir_L2A[x], recursive=TRUE, force = TRUE)})


