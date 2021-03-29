############################################
# The following code converts a bunch of .png files into a pdf file
############################################
setwd("C:/Users/sanaz")
site <- "GOR" #"MFC2"
year <- 2020

# Load libraries
pck <- (c("ggplot2","raster","leaflet","rasterVis","gridExtra","RColorBrewer",
          "plotly","RStoolbox","sp", "gdalUtils","here","png","grid"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)

# Change the content of here() based on the place where .png files are stored
#setwd(here("MB12-project","CREODIAS_part","data_from_CREODIAS","L2A_2017"))

# choose VI here:
VI <- "NDWI" #"NDVI" # 

if(VI == "NDVI"){path <- file.path(here("Desktop","Playground_dir_8"), site, year)
}else if(VI == "NDWI"){path <- file.path(here("Desktop","Playground_dir_8", "NDWI"), site, year)
}

# Store your png files in a list of grobs using rasterGrob()
plots <- lapply(ll <- list.files(path, patt='.*[.]png'),function(x){
  img <- as.raster(readPNG(file.path(path,x)))
  rasterGrob(img, interpolate = FALSE)
})

# Save them using the handy function marrangeGrob()
ggsave(paste0("MultiRes_", year, "_", site, ".pdf"),
       path = path,
       marrangeGrob(grobs=plots, 
                    nrow=1, ncol=1, top = quote(" ")))# 

