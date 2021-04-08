###################################################
# The following script is meant for zip folders under 4G of size, to unzip them,
# and remove the zip folders afterwards
# The function "unzip_s2_tiles()" needs 2 parameters: path of zip files and path to save the unzipped folders
###################################################

#set working directory

pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet",
          "rasterVis","gridExtra","RColorBrewer","plotly",
          "RStoolbox","sp","IRdisplay","reshape","here", 
          "bfast", "bfastSpatial", "rkt"))

new_pck <- pck[!pck %in% installed.packages()[,"Package"]]

if(length(new_pck)){install.packages(new_pck)}

sapply(pck , require, character.only=TRUE)



unzip_s2_tiles <- function(path_zip, out_dir) {
  
  # Load Sentinel2 zip tiles
  
  S2_names_list <- list.files(path_zip,
                              recursive = FALSE, 
                              full.names = TRUE, 
                              pattern="*.zip$")
  
  # Unzip and remove the zip folder 
  
  S2_names <- pbapply::pblapply(1:length(S2_names_list), 
                     function(x){unzip(S2_names_list[x], 
                                       exdir = out_dir) 
                                }
                              )
  
  pbapply::pblapply(1:length(S2_names_list), 
                                function(x){ 
                                  unlink(S2_names_list[x], recursive=TRUE, force = TRUE)
                                }
  )
}






