###############################################################
# The following calculates NDVI for each tile in each iteration 
# of the loop and saves the result on the drive
# following Sarah's recommandation
###############################################################


#1: Load R packages
## Install & load packages
pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet","rasterVis","gridExtra","RColorBrewer","plotly","RStoolbox","sp","IRdisplay"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)

## set working directory
setwd("C:/Users/sanaz/Documents/MB12-project/Outputs/NDVI/")


#2: Load Auxillary data
### Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
aoi <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp")
aoi_2 <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site2_GOR_forest/Site2_GOR_forest/GOR.shp")
points_in_MFC2 <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Points_in_MFC2.shp")


# Load S2 tiles (attention to ^ in pattern)
S2_names <- "C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//testdir"
S2_names_1 <- list.files(S2_names,recursive = FALSE, full.names = TRUE, pattern="S2[A,B]_MSIL2A_[[:alnum:]]{15}_[[:alnum:]]{5}_[[:alnum:]]{4}_[[:alnum:]]{6}_[[:alnum:]]{15}.SAFE$")#S2[A,B]
S2_names_T <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.jp2$")
S2_names_L2A <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, pattern="L2A_T[[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.jp2$")
#S2_names_T_L2A <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, pattern="[L2A_T,T][[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.jp2$")
S2_names <- lapply(1:length(S2_names_T), function(x){raster(S2_names_T[x])})                                                      
S2_names_L2A <- lapply(1:length(S2_names_L2A), function(x){raster(S2_names_L2A[x])})

b <- as(extent(515379.3,519889,4461970.6,4468567.9), 'SpatialPolygons')
crs(b) <- crs(S2_stack)
num_loop <- length(S2_names_1)
# The following loop calculates NDVI for tiles in which the names of 10 m bands start with "T"
for(i in 1:num_loop){
# Stack all the .jp2 bands(10m)
  S2_names_indexed <- S2_names[((i-1)*4+1):((i-1)*4+4)]
  S2_stack <- stack(S2_names_indexed)

# crop around the study areas
  S2_stack_crop_bbox <- crop(S2_stack , b)

# Derive NDVI 
  NDVI <- list()
# To make sure, result of division is integer(necessary for indexing the list & stack)
  n <- as.integer(length(S2_names_indexed)/4)#
  for(j in 1:n){
    NDVI[[j]] <- overlay(x=S2_stack_crop_bbox[[((j-1)*4+3)]], y=S2_stack_crop_bbox[[((j-1)*4+4)]], fun=function(x,y){(y-x)/(y+x)})
    names(NDVI[[j]]) <- paste0("NDVI_", unlist(strsplit(strsplit(strsplit(S2_names_1[i],"//")[[1]][8],'/')[[1]][2],"[.]"))[1])
  }

# NDVI 
#plot(NDVI[[1]])

# Export your raster
  name <- names(NDVI[[1]])
  writeRaster(x = NDVI[[1]],
              filename = name,
              format = "GTiff", # save as a tif
              datatype='INT2S', # save as a INTEGER rather than a float
              overwrite = TRUE) 

}

# The following loop calculates NDVI for tiles in which the names of 10 m bands start with "L2A"
for(i in 1:num_loop){
  # Stack all the .jp2 bands(10m)
  S2_names_indexed <- S2_names_L2A[((i-1)*4+1):((i-1)*4+4)]
  S2_stack <- stack(S2_names_indexed)
  
  # crop around the study areas
  S2_stack_crop_bbox <- crop(S2_stack , b)
  
  # Derive NDVI 
  NDVI <- list()
  # To make sure, result of division is integer(necessary for indexing the list & stack)
  n <- as.integer(length(S2_names_indexed)/4)#
  for(j in 1:n){
    NDVI[[j]] <- overlay(x=S2_stack_crop_bbox[[((j-1)*4+3)]], y=S2_stack_crop_bbox[[((j-1)*4+4)]], fun=function(x,y){(y-x)/(y+x)})
    names(NDVI[[j]]) <- paste0("NDVI_", unlist(strsplit(strsplit(strsplit(S2_names_1[i],"//")[[1]][8],'/')[[1]][2],"[.]"))[1])
  }
  
  # NDVI 
  #plot(NDVI[[1]])
  
  # Export your raster
  name <- names(NDVI[[1]])
  writeRaster(x = NDVI[[1]],
              filename = name,
              format = "GTiff", # save as a tif
              datatype='INT2S', # save as a INTEGER rather than a float
              overwrite = TRUE) 
  
}


# extract data from the raster for selected pixels
click(NDVI[[1]], id=TRUE, xy=TRUE, cell=TRUE, n=1)

# Creating a nice map with the leaflet package in R 
library(leaflet)
r <- NDVI[[1]]
pal <- colorNumeric(c("#ffffff", "#4dff88", "#004d1a"), values(r),
                    na.color = "transparent")

map <- leaflet() %>% addTiles() %>%
  addRasterImage(r, colors = pal, opacity = 0.8) %>%
  addLegend(pal = pal, values = values(r),
            title = "NDVI")
map


#Creating NDVI time series for 2 points in study area: 
# Extract pixel value at points coordinates
NDVI_points <- lapply(NDVI, FUN = function(NDVI){extract(NDVI,points_in_MFC2, method='bilinear', df=TRUE)})


# Combine df
NDVI_point_df <- do.call("cbind", NDVI_points)

# Clean df - remove duplicate columns
NDVI_point_df <- NDVI_point_df[, !duplicated(colnames(NDVI_point_df))]


# Arrange df
NDVI_point_df <- gather(NDVI_point_df, key=Date, value=value, -ID)

# Plot NDVI temporal series
ndvi_plot <- ggplot(data=NDVI_point_df,aes(x=Date, y=value, group=ID, color=ID)) + 
  geom_line() + 
  geom_point()

#for better visualization, the x labels are positioned vertically
ndvi_plot + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# this function facilitates zooming the plot, downloading it as png, pan and selection.
ggplotly(ndvi_plot)

