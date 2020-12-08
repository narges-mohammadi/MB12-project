# Read the raster data into R(first unzip the .ZIP files outside of R, then import .SAFE into R)

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

aoi_lonlat_wgs84 <- spTransform(aoi,CRS("+proj=longlat +datum=WGS84"))
aoi_2_longlat_wgs84 <- spTransform(aoi_2,CRS("+proj=longlat +datum=WGS84"))


m <- leaflet(sizingPolicy = leafletSizingPolicy(defaultHeight = 200 , viewer.suppress = TRUE , knitr.figure=FALSE)) %>%
  addProviderTiles(providers$OpenStreetMap) %>% 
  addPolygons(data=aoi_2_longlat_wgs84,
              stroke = FALSE,
              smoothFactor = 0.5)

m

#3 : Load Sentinel2 data
S2 <- "C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//testdir/"
S2 <- list.files(S2,recursive = TRUE, full.names = TRUE, pattern="B0[2348]_10m.jp2$")
S2 <- lapply(1:length(S2), function(x){raster(S2[x])})

# Load preview of tiles
S2_pvi <- "C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//testdir/"
S2_pvi <- list.files(S2_pvi,recursive = TRUE, full.names = TRUE, pattern="^T[[:alnum:]]{5}_[[:alnum:]]{15}_PVI.jp2$")
S2_pvi <- lapply(1:length(S2_pvi), function(x){stack(S2_pvi[x])})# used stack() bc the preview has 3 bands(rgb)


# Set layout
options(repr.plot.width=41,repr.plot.height=20)
m <- rbind(c(1,2))
layout(m)

# Stack the .jp2 bands(10m)
S2_stack <- stack(S2)

# Stack the previews(to choose which tiles to use for analysis(w/o cloud and cloud shadow for study areas))
S2_pvi_stack <- stack(S2_pvi)

#Plot True/False images
plotRGB(S2_stack , r=3, g=2 ,b=1 ,scale=maxValue(S2[[2]]), stretch='hist')
plot(aoi , add= TRUE , border= 'yellow' , lwd= 5)
#false color composit
plotRGB(S2_stack , r=4 , g =3 , b =2 , scale=maxValue(S2[[2]]), stretch='hist')
plot(aoi, add=TRUE , border='yellow' , lwd=2)



#4: Process sentinel2 data
## Set Layout
options(repr.plot.width = 35 , repr.plot.height = 10)
m <- rbind(c(1,2))
layout(m)

# Crop and plot
S2_stack_crop <- crop(S2_stack , aoi)
plotRGB(S2_stack_crop , r=3, g=2 ,b=1 ,scale=maxValue(S2[[2]]), stretch='hist')#stretch='lin'
plotRGB(S2_stack_crop , r=4, g=3 ,b=2 ,scale=maxValue(S2[[2]]), stretch='hist')#stretch='lin'

b <- as(extent(515379.3,519889,4461970.6,4468567.9), 'SpatialPolygons')
crs(b) <- crs(S2_stack)
S2_stack_crop_bbox <- crop(S2_stack , b)
plotRGB(S2_stack_crop_bbox , r=3, g=2 ,b=1 ,scale=maxValue(S2[[2]]), stretch='hist')#stretch='lin'
plotRGB(S2_stack_crop_bbox , r=4, g=3 ,b=2 ,scale=maxValue(S2[[2]]), stretch='hist')#stretch='lin'



# Plot the previews with the two study areas over them & decide whether to keep them or not
plotRGB(S2_pvi[[10]] , r=1, g=2 ,b=3 ,scale=maxValue(S2_pvi[[6]]), stretch='hist')
plot(aoi , add= TRUE , border= 'red' , lwd= 1)
plot(aoi_2 , add= TRUE , border= 'red' , lwd= 1)

# To choose which tiles to use for analysis based on cloud cover over study areas 
select <- list()
for(i in 1:length(S2_pvi)){
  plotRGB(S2_pvi[[i]] , r=1, g=2 ,b=3 ,scale=maxValue(S2_pvi[[2]]), stretch='hist')
  plot(aoi , add= TRUE , border= 'red' , lwd= 1)
  plot(aoi_2 , add= TRUE , border= 'red' , lwd= 1)
  select <- c(select, as.logical(readline("Select? ")))# F: FALSE, T: TRUE
}

#save the "select" on the drive
saveRDS(select, file = "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/testdir/select_testdir.Rds")
#Load the select.Rds 
select <- readRDS(file = "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/testdir/select_testdir.Rds") 

# S2_stack to a dataframe and use "select" on it to choose the appropriate tiles

records.filt2 <- records_filt_new[select2,]




# Derive NDVI 
NDVI <- list()
# To make sure, result of division is integer(necessary for indexing the list & stack)
n <- as.integer(length(S2)/4)
for(i in 1:n){
  NDVI[[i]] <- overlay(x=S2_stack_crop_bbox[[((i-1)*4+3)]], y=S2_stack_crop_bbox[[((i-1)*4+4)]], fun=function(x,y){(y-x)/(y+x)})
  names(NDVI[[i]]) <- paste0("NDVI_", strsplit(strsplit(names(S2_stack_crop_bbox[[(i-1)*4+4]]), "_")[[1]][2], "T")[[1]][1])
}
NDVI


# Set the layout(define the dimensions of plot)
options(repr.plot.width = 600, repr.plot.height = 600)
# Create custom color
breaks <- c(-1, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1)
pal <- brewer.pal(11,"RdYlGn")
mapTheme <- rasterTheme(region= pal)
mapTheme$fontsize$text = 10

# Plot NDVI && points of reference
levelplot(stack(NDVI), scales= list(draw=FALSE), colorkey= FALSE , par.settings= mapTheme)
+layer(sp.polygons(aoi, col = 69, bg='black', lwd=30))

# Extract pixel value at points coordinates
NDVI_points <- lapply(NDVI, FUN = function(NDVI){extract(NDVI,points_in_MFC2, method='bilinear', df=TRUE)})
NDVI_points[1]

# Combine df
NDVI_point_df <- do.call("cbind", NDVI_points)

# Clean df - remove duplicate columns
NDVI_point_df <- NDVI_point_df[, !duplicated(colnames(NDVI_point_df))]
NDVI_point_df

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



# The basic method; the above way of coding is more elegant than the following

#aoi <- sf::st_read(dsn = "C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp" , layer = "MFC2")
# create a matrix containing two sites of the study
matrix <- rbind(c(515379.3,4461970.6),c(515379.3,4468567.9),c(519889,4468567.9),c(519889,4461970.6))

# convert UTM to lat long 
sputm <- SpatialPoints(matrix, proj4string=CRS("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs"))  
spgeo <- spTransform(sputm, CRS("+proj=longlat +datum=WGS84"))

# Create a Polygon, wrap that into a Polygons object, then wrap that into a SpatialPolygons object
p  <-  Polygon(spgeo)
ps  <-  Polygons(list(p),1)
sps  <-  SpatialPolygons(list(ps))
# set crs
proj4string(sps)  <-  CRS(" +proj=utm +zone=33 +datum=WGS84 +units=m +no_defs ")
proj4string(sps)  <-  CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# check the validity of S2 tile and get metadata from its path:
# Define product name
s2_name <- "C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//L2A_2018/S2A_MSIL2A_20180622T095031_N0208_R079_T33TWE_20180622T114532.SAFE"

# Return some specific information without scanning files
metadata_s2 <- sen2r::safe_getMetadata(s2_name, info=c("level", "id_tile" , "prod_type" , "utm",
                                                       "xml_main","clouds","res","sensing_datetime","id_orbit"))

b2 <- raster('C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//L2A_2018/S2A_MSIL2A_20180622T095031_N0208_R079_T33TWE_20180622T114532.SAFE//GRANULE//L2A_T33TWE_A015663_20180622T095438//IMG_DATA//R10m//T33TWE_20180622T095031_B02_10m.jp2')
b3 <- raster('C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//L2A_2018/S2A_MSIL2A_20180622T095031_N0208_R079_T33TWE_20180622T114532.SAFE//GRANULE//L2A_T33TWE_A015663_20180622T095438//IMG_DATA//R10m//T33TWE_20180622T095031_B03_10m.jp2')
b4 <- raster('C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//L2A_2018/S2A_MSIL2A_20180622T095031_N0208_R079_T33TWE_20180622T114532.SAFE//GRANULE//L2A_T33TWE_A015663_20180622T095438//IMG_DATA//R10m//T33TWE_20180622T095031_B04_10m.jp2')
b8 <- raster('C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//L2A_2018/S2A_MSIL2A_20180622T095031_N0208_R079_T33TWE_20180622T114532.SAFE//GRANULE//L2A_T33TWE_A015663_20180622T095438//IMG_DATA//R10m//T33TWE_20180622T095031_B08_10m.jp2')

plot(b8)
summary(b8)

# Stacking raster data
stacked = stack(b2,b3,b4,b8)
plot(stacked)
names(stacked)
# False color composite
plotRGB(stacked, r = 3, g = 2, b = 1, stretch = "hist")

# color composite with linear stretch
plotRGB(stacked, r = 3, g = 2, b = 1, stretch = "lin")


# function for calculating the VI
ndvi <-  function(nir,red) {
  return (nir-red)/(nir+red)
}

e <- extent(c(515379.3,519889,4461970.6,4468567.9))
b4_e <- crop(b4,e)
b8_e <- crop(b8,e)

ndvi_S2_e <- ndvi(b8_e,b4_e)
plot(ndvi_S2_e)

# convert .jp2 to .tif (might get better results for NDVI)
library(rgdal)
library(gdalUtils)
gdal_chooseInstallation(hasDrivers='JP2OpenJPEG')

src_dataset <- 'C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//L2A_2018//S2A_MSIL2A_20180622T095031_N0208_R079_T33TWE_20180622T114532.SAFE//GRANULE//L2A_T33TWE_A015663_20180622T095438//IMG_DATA//R10m//T33TWE_20180622T095031_B02_10m.jp2'
dst_dataset <- 'C://Users//sanaz//Documents//MB12-project//CREODIAS_part//data_from_CREODIAS//TIFF_files'
gdalUtils::gdal_translate(src_dataset=src_dataset,dst_dataset=dst_dataset,
                          of = "GTiff",
)

#classify NDVI 
#rules  <-  c(-1, -0.5, 1, -0.5, 0, 2, 0, 0.2, 3, 0.2, 0.5, 4, 0.5, 1, 5) class = matrix(rules, ncol = 3, byrow = TRUE)
#class  <-  matrix(rules, ncol = 3, byrow = TRUE)
#  <-  reclassify(ndvi_Sentinel2, class)
#plot(classified_ndvi)            


dem  <-  raster("C://Users//sanaz//Documents//MB12-project//data//DEM_5m_Sarah//DEM5m_UARC.tif")
plot(dem)

slope  <-  terrain(dem, opt = "slope", unit = "degrees")
plot(slope)

aspect  <-  terrain(dem, opt = "aspect")
plot(aspect)

hill_dem  <-  hillShade(slope, aspect, 40, 270)
plot(hill_dem)
