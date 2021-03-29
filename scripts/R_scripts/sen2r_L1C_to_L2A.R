
setwd("C:/Users/sanaz/")


#1: Load R packages
## Install & load packages
pck <- (c("tidyr", "rgdal", "ggplot2", "raster",
          "leaflet", "rasterVis","gridExtra", "RColorBrewer",
          "plotly", "RStoolbox", "sp", "sf", "IRdisplay", "reshape", 
          "here", "patchwork", "tidyverse", "cowplot", "sen2r"))
new_pck <- pck[!pck %in% installed.packages()[, "Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck, require, character.only=TRUE)


dir_l1c <- here("Documents", "MB12-project", "CREODIAS_part",
                "data_from_CREODIAS", "L1C_2018", "Sanaz_S2_2018")

L1C_names <- list.files(dir_l1c,
                            recursive = FALSE, 
                            full.names = FALSE, #TRUE
                            pattern = "*.SAFE$")
L1C_name_list <- as.list(L1C_names)

subset_l1c_dir<- L1C_name_list[1:5]

outdir <- here("Documents", "MB12-project", "CREODIAS_part", 
               "data_from_CREODIAS", "L1C_2018", "L2A_sen2r_2018")

sen2cor(
  subset_l1c_dir, 
  l1c_dir = dir_l1c, 
  outdir = outdir,
  use_dem = FALSE
)
