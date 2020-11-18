setwd("C:\\Users\\sanaz\\Documents\\MB12-project")
#install.packages("devtools")
#devtools::install_github("16EAGLE/getSpatialData")
library(getSpatialData)
library(sf)
library(raster)
library(rgdal)

# Read the shapefile

#aoi <- st_read(".\\data\\vector\\Site1_MFC2_agroforestry\\MFC2.shp", package="sf")
#aoi <- read_sf(dsn=".\\data\\vector\\Site1_MFC2_agroforestry",layer="MFC2")
#bbox_aoi <- st_bbox(aoi$geometry)

#convert shp to spatialPolygon(for input of getSpatialData package)
shp_to_SP <- readOGR(dsn=path.expand(".\\data\\vector\\Site1_MFC2_agroforestry"), layer="MFC2")


# Define an archive directory:
set_archive("C:\\Users\\sanaz\\Documents\\MB12-project\\data\\raster")

# Define an area of interest (AOI):
# Use the example AOI or draw an AOI by calling set_aoi():
set_aoi(shp_to_SP)
# View the AOI:
view_aoi()

# There are three services to login at:
login_CopHub(username = "sunymo")

# Print the status of all services:
#services()

# Query all available records for multiple products and a given time range at once,
# For Sentinel-2 :
records <- get_records(time_range = c("2016-12-01", "2018-12-30"),#"starting date of Sentinel:2015-06-23"
                       products = "Sentinel-2")

View(records)

# Filter records to contain surface reflectance ( after 2018 Level 2A available) records:
records <- records[records$level == "sr" | records$level == "Level-2A" ,]# 


# Plot records footprints:
#plot_records(records)

# Download and georeference the previews for all records:
records <- get_previews(records) 

# Display the previews interactively (all or just a selection):
view_previews(records[5,])

# Use the previews to calculate the cloud coverage in your AOI for all records:
records <- calc_cloudcov(records)


# With the result, getSpatiaData can automatically select the most usable records,
# For a series of timestamps:
#records <- select_timeseries(records,184)


# Once, you came to a selection (manually or automatically), check for availability:
records <- check_availability(records)

# Data sets that are not instantly available for download, e.g. because the have been
# archived, can be ordered:
records <- order_data(records)


# Finally, download records available for download:
records <- get_data(records)

