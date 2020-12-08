
# !!!problems with the created geojson file!!!!(only a line is created, has sth to do with crs)
# !!! Look into this script

#install.packages(rgdal)
#install.packages(spdplyr)
#install.packages(geojsonio)
#install.packages(rmapshaper)
#install.packages("lawn")
 
library(rgdal)
library(spdplyr)
library(geojsonio)
library(rmapshaper)


#read shapefiles
MFC2 <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp")
GOR <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp")

# convert to geojson
MFC2_json <- geojson_json(MFC2)
GOR_json <- geojson_json(GOR)


#Simplify GeoJSON file
library(rmapshaper)
MFC2_json_simplified <- ms_simplify(MFC2_json)
GOR_json_simplified <- ms_simplify(GOR_json)

# Test coordinate values inside the R 
library(lawn)
# bbox of MFC2
view(lawn_bbox_polygon(c(515379.3, 4468068.3, 516012.9, 4468567.9)))#

# bbox of GOR
view(lawn_bbox_polygon(c(515379.3, 4468068.3, 516012.9, 4468567.9)))


#Export geojson file
geojson_write(MFC2_json_simplified, file = "C:/Users/sanaz/Documents/MB12-project/data/vector/Sites_in_Geojson/MFC2/MFC2.geojson")
geojson_write(GOR_json_simplified, file = "C:/Users/sanaz/Documents/MB12-project/data/vector/Sites_in_Geojson/GOR/GOR.geojson")

