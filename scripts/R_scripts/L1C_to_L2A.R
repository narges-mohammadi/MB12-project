setwd("C:/Users/sanaz/")

#1: Load R packages
## Install & load packages
pck <- (c("tidyr","rgdal","ggplot2","raster",
          "leaflet","rasterVis","gridExtra","RColorBrewer",
          "plotly","RStoolbox","sp","sf","IRdisplay","reshape", 
          "here", "patchwork", "tidyverse", "cowplot", "sen2r"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)
#C:\Users\sanaz\Desktop\Playground_dir_13


sen2cor_dir= here("Documents","MB12-project","sen2cor_dir")
install_sen2cor(sen2cor_dir = sen2cor_dir)

l1c_prodlist <- list.files(path=here("Desktop","Playground_dir_13"),
                           pattern = "*.SAFE", full.names = TRUE)
outdir <- here("Desktop","Playground_dir_13", "out_dir_L2A")


#C:\Users\sanaz\Documents\MB12-project\data\DEM_5m_Sarah
# gipp  <-  list(DEM_Directory = here("Documents", "MB12-project", "data", "DEM_5m_Sarah"),
#             DEM_Reference ="http://data_public:GDdci@data.cgiar-csi.org/srtm/tiles/GeoTIFF/")

sen2cor(
    l1c_prodlist = l1c_prodlist,
    #l1c_dir = NULL,
    outdir = outdir,
    proc_dir = NA,
    tmpdir = NA,
    rmtmp = TRUE,
    gipp = NA,
    use_dem = FALSE,
    tiles = NULL,
    parallel = TRUE,#
    timeout = 0,
    kill_errored = FALSE,
    overwrite = FALSE,
    .log_message = NA,
    .log_output = NA
)
