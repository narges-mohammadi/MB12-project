setwd("C:\\Users\\sanaz\\Documents\\MB12-project")

#install.packages("sen2r")
# only if you want to use the GUI of sen2r, install the packages in the next line
#install.packages(c("shinyFiles", "shinydashboard", "shinyjs", "shinyWidgets"))


library(sen2r)
library(rgdal)
library(spdplyr)
library(geojsonio)
library(rmapshaper)

# Convert shapefile to geojson (input to sen2r is required to be geojson) 
aoi <- readOGR(dsn=path.expand("C:\\Users\\sanaz\\Documents\\MB12-project\\data\\vector\\Site1_MFC2_agroforestry"), layer="MFC2")
shp_to_SP <- readOGR(dsn=path.expand(".\\data\\vector\\Site1_MFC2_agroforestry"), layer="MFC2")

# Show the first 10 rows
# head(aoi@data, 10)

# Convert to json
aoi_json <- geojson_json(aoi)

# Scihub credentials
write_scihub_login('sunymo', 'Sanaz69@')

# sen2r(
#   gui = FALSE,
#   timewindow = c(as.Date("2018-01-01"), as.Date("2019-01-01")),
#   extent =aoi_json , extent_name = "MFC2",
#   list_prods = "BOA" ,
#   #list_indices = c("NDVI", "MSAVI2"),
#   mask_type = "cloud_and_shadow",
#   max_mask = 50, mask_smooth = 30, mask_buffer = 30,
#   extent_as_mask = TRUE,
#   path_l1c = "./data/raster/SAFE", path_l2a = "./data/raster/SAFE", path_out = "./data/raster/sen2rtest/out1"
# )


#Download the data and resample 

# Set paths
out_dir_1  <- "C:\\Users\\sanaz\\Documents\\MB12-project\\data\\raster"# output folder
safe_dir_1 <- "C:\\Users\\sanaz\\Documents\\MB12-project\\data\\raster"  # folder to store downloaded SAFE


myextent_1 <- path.expand("C:\\Users\\sanaz\\Documents\\MB12-project\\data\\vector\\Site1_MFC2_agroforestry")

library(sen2r)

out_paths_1 <- sen2r(
  gui = FALSE,
  step_atmcorr = "auto",
  extent = myextent_1,
  extent_name = "MFC2",
  timewindow = c(as.Date("2019-08-01"), as.Date("2019-09-01")),
  clip_on_extent = TRUE,
  list_prods = c("BOA","SCL"),
  mask_type = "cloud_and_shadow",
  max_mask = 20, 
  overwrite = TRUE,
  path_l2a = safe_dir_1,     
  path_out = out_dir_1
)



