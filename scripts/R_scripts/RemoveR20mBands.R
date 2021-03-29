##################
# remove the R20m directory in SAFE folders
# to free up space
##################

#1: Load R packages
## Install & load packages
pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet","rasterVis","gridExtra","RColorBrewer","plotly","RStoolbox","sp","IRdisplay","reshape", "gdalUtils"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)


#set working directory
setwd("C:/Users/sanaz/Desktop/Playground_dir")


# Load Sentinel2 safe directories and remove the R20m folder
S2_names_safe <- "C:/Users/sanaz/Desktop/Playground_dir"
S2_safe_dir <- list.dirs(path = S2_names_safe, full.names = TRUE, recursive = FALSE)
S2_safe_r20 <- list.files(S2_safe_dir, recursive = TRUE, full.names = TRUE, pattern="[T_][[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_20m.jp2$")
lapply(1:length(S2_safe_r20), function(x){ unlink(dirname(S2_safe_r20[x]), recursive=TRUE, force = TRUE)}) 


#unlink(dirname(S2_safe_r20[x]), recursive=TRUE, force = TRUE)






