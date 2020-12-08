library(raster)
library(ggmap)
library(tmap) #for static and interactive maps
library(sf) # for loading kml
library(readr)

#level 0 : country outline & level 1 : regional boundaries
Italy_L0 <- getData("GADM",country="ITA",level=0)
Italy_L3 <- getData("GADM",country="ITA",level=3)#Salerno(study area) is in Layer3

plot(Italy_L3)

# load the sub catchments into R
aoi_boundary_MFC2 <- st_read(dsn="C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp")
aoi_boundary_GOR <- st_read(dsn="C:/Users/sanaz/Documents/MB12-project/data/vector/Site2_GOR_forest/Site2_GOR_forest/GOR.shp")

# get a base map centered on Salerno, Italy at a certain zoom
m <- leaflet() %>% setView(lng = 14.767353, lat = 40.683404, zoom = 8)
m %>% addTiles()

# stamen basemap(bounding box is from Italy_L3(Italy_L3@bbox))
myMap <- get_stamenmap(bbox = c(left = 6.630879,
                                bottom = 35.492916,
                                right = 18.52069,
                                top = 47.09096),
                       maptype = "watercolor", 
                       crop = FALSE,
                       zoom = 8)
# plot map
ggmap(myMap)


# S2 tiles using sen2r
# Retrieve all the tiles
s2tiles <- sen2r::s2_tiles()

# save new object as .rds file
readr::write_rds(aoi_boundary_MFC2, file = file.path("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/", "MFC2.rds"))
ch <- readRDS("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.rds")
s2tiles_ch <- s2tiles[suppressMessages(sf::st_intersects(ch, s2tiles))[[1]],]
s2_coords <- sf::st_coordinates(suppressWarnings(sf::st_centroid(s2tiles_ch)))


# Show the tiles
plot(s2tiles_ch$geometry, border = "blue")
plot(ch, border = "red", add = TRUE)
text(s2_coords[,1], s2_coords[,2], s2tiles_ch$tile_id, col = "blue", cex = .75)

#s2_tiles <- st_read("C:/Users/sanaz/Documents/MB12-project/data/S2A_OPER_GIP_TILPAR_MPC__20151209T095117_V20150622T000000_21000101T000000_B00.kml")
#plot(s2_tiles)


# add polygons to your map
# creating a sample data.frame with your lat/lon points
#gage_location <- data.frame(lon = c(-105.178333), lat = c(40.051667))

# create a map with a point location for boulder.
shp_to_SP <- rgdal::readOGR(dsn=path.expand("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/"), layer="MFC2")
ggmap(myMap) + labs(x = "", y = "") +
  geom_polygon(data = aoi_boundary_MFC2, aes(x = long, y = lat, fill = "red", alpha = 0.2), size = 5, shape = 19) 
#+guides(fill = FALSE, alpha = FALSE, size = FALSE)
