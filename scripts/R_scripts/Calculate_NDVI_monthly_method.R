#1: Load R packages
## Install & load packages
pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet","rasterVis","gridExtra","RColorBrewer","plotly","RStoolbox","sp","IRdisplay"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)

## set working directory
setwd("C:/Users/sanaz/Documents/MB12-project/")


#2: Load Auxillary data
### Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
aoi <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp")
aoi_2 <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site2_GOR_forest/Site2_GOR_forest/GOR.shp")
points_in_MFC2 <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Points_in_MFC2.shp")


# Load S2 tiles of 2017(attention to ^ in pattern)
S2_names <- "C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//testdir/"
S2_names_2017_dez_1 <- list.files(S2_names,recursive = FALSE, full.names = TRUE, pattern="S2[A,B]_MSIL2A_201712*[[:alnum:]]{9}_[[:alnum:]]{5}_[[:alnum:]]{4}_[[:alnum:]]{6}_[[:alnum:]]{15}.SAFE$")#S2[A,B]
S2_names_2017_dez <- list.files(S2_names_2017_dez_1, recursive = TRUE, full.names = TRUE, pattern="^T[[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.jp2$")
S2_names_2017_dez <- lapply(1:length(S2_names_2017_dez), function(x){raster(S2_names_2017_dez[x])})                                                      

# Stack the .jp2 bands(10m)
S2_stack <- stack(S2_names_2017_dez)

# crop around the study areas
b <- as(extent(515379.3,519889,4461970.6,4468567.9), 'SpatialPolygons')
crs(b) <- crs(S2_stack)
S2_stack_crop_bbox <- crop(S2_stack , b)

#find the max value(used for plotRGB)
num <- as.integer(length(S2_names_2017_dez))
x <- vector("list", num)
for(i in 1:num) {
  Ps <- maxValue(S2_stack_crop_bbox[[i]])  ## where i is whatever your Ps is
  x[[i]] <- Ps
}
max_val <- max(unlist(x))



# To choose which tiles to use for analysis based on cloud cover(use of 10m resolution) 
select_10m <- list()
m <- as.integer(length(S2_names_2017_dez)/4)
for(i in 1:m){
  blue <- S2_stack_crop_bbox[[((i-1)*4+1)]]
  green <- S2_stack_crop_bbox[[((i-1)*4+2)]]
  red <- S2_stack_crop_bbox[[((i-1)*4+3)]]
  s <- stack(red,green,blue)
  plotRGB(s , r=1, g=2 ,b=3 ,scale=max_val, stretch='hist')#scale=maxValue(S2_stack_crop_bbox[[2]]),
  plot(aoi , add= TRUE , border= 'red' , lwd= 1)
  plot(aoi_2 , add= TRUE , border= 'red' , lwd= 1)
  select_10m <- c(select_10m, as.logical(readline("Select? ")))# F: FALSE, T: TRUE
}

# Retrieve the names of the SAFE folders
S2_names_df <- data.frame(S2_names_2017_dez_1)

## Convert list into dataframe columns 
select_df <- data.frame(unlist(select_10m)) 

## Names of columns of dataframe 
names(select_df) <- "SAFE_names"

S2_names_df_filt <- S2_names_df[select_df$SAFE_names,]

#3 : Load Sentinel2 data
S2_selected <- list.files(S2_names_df_filt,recursive = TRUE, full.names = TRUE, pattern="T[[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.jp2$")#T33TWE_20191229T095319_B03_10m
S2_selected <- lapply(1:length(S2_selected), function(x){stack(S2_selected[x])})


# Derive NDVI 
NDVI <- list()
# To make sure, result of division is integer(necessary for indexing the list & stack)
n <- as.integer(length(S2_selected)/4)#
for(i in 1:n){
  NDVI[[i]] <- overlay(x=S2_stack_crop_bbox[[((i-1)*4+3)]], y=S2_stack_crop_bbox[[((i-1)*4+4)]], fun=function(x,y){(y-x)/(y+x)})
  names(NDVI[[i]]) <- paste0("NDVI_", strsplit(strsplit(names(S2_stack_crop_bbox[[(i-1)*4+4]]), "_")[[1]][2], "T")[[1]][1])
}

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

# Set the layout(define the dimensions of plot)
options(repr.plot.width = 600, repr.plot.height = 600)
# Create custom color
breaks <- c(-1, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1)
pal <- brewer.pal(11,"RdYlGn")
mapTheme <- rasterTheme(region= pal)
mapTheme$fontsize$text = 10

# Plot NDVI && points of reference
levelplot(stack(NDVI), scales= list(draw=FALSE), colorkey= FALSE , par.settings= mapTheme)
+layer(sp.polygons(aoi, col = 69, bg='black', lwd=30))#+layer(sp.polygons(aoi_2, col = 69, bg='black', lwd=30))
    
    