setwd("C:\\Users\\sanaz\\Documents\\MB12-project")
#install.packages("devtools")
#devtools::install_github("16EAGLE/getSpatialData")
library(getSpatialData)
library(sf)
library(raster)
library(rgdal)


# Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
aoi <- readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp")
set_aoi(aoi)
view_aoi()

# Define an archive directory:
set_archive("C:/Users/sanaz/Documents/MB12-project/data/raster/")


# There are three services to login at:
login_CopHub(username = "sunymo")

# Print the status of all services:
#services()

# Query all available records for multiple products and a given time range at once,
# For Sentinel-2 :
records <- get_records(time_range = c("2016-01-01", "2020-10-30"),#"starting date of Sentinel:2015-06-23"
                       products = "Sentinel-2")

View(records)

#### Filter to have only Level-2A data that is already preprocessed in terms of atmospheric and geometric correction ######
records_filt_L2a <- records[records$level == "Level-2A",]

# display the footprint geometries of each record on a map:
view_records(records[1:3])

# calculate the cloud cover of optical sentinel data in an aoi based on small previews
dir_out <- "C:/Users/sanaz/Documents/MB12-project/data/raster/cloud_calc_output"
calc_cloudcov(records_filt_L2a[1:5,] ,dir_out = dir_out)


# Write table with few variables for each tile/sensor date  
library(dplyr)

new_record_table <- records_filt_L2a %>%
  dplyr::select( preview_url, date_ingestion , tile_id , orbit_direction, platform_serial, level , size , cloudcov ,vegetation , cloudcov_notvegetated , water ) 

# It's a .txt file ####
write.table( new_record_table, file="C:/Users/sanaz/Documents/MB12-project/data/List_Sentinel-2.txt"
            ,col.names=TRUE,row.names=FALSE)

# change the column name "preview_url" to "preview_file" to check if view_previews() work
test_df <- records_filt_L2a
test_df <- dplyr::rename( test_df , preview_file = preview_url)

# preview (Here you can preview and select data based on quicklooks. Make sure that you select using T for TRUE or F for False) ######
dir_out_preview <- "C:/Users/sanaz/Documents/MB12-project/data/raster/previews"
select <- NULL
#nrow(records_filt_L2a)

for(i in 1:5){
  
  get_previews( records_filt_L2a[i,] , dir_out = dir_out_preview , force =TRUE)
  #view_previews(records_filt_L2a[i,] , show_aoi = TRUE)
  #plot_previews(records_filt_L2a[i,])
  #select <- c(select, as.logical(readline("Select? ")))
}

records.filt2 <- records_filt_L2a[select,]
records.filt2<- records.filt2[-1,]



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

