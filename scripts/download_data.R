setwd("C:\\Users\\sanaz\\Documents\\MB12-project")
#install.packages("devtools")
#devtools::install_github("16EAGLE/getSpatialData")
library(getSpatialData)
library(sf)
library(raster)
library(rgdal)


# Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
aoi <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp")
#aoi <- sf::st_read(dsn = "C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp" , layer = "MFC2")
set_aoi(aoi)# Site:MFC2 
view_aoi()

# Define an archive directory:
set_archive("C:/Users/sanaz/Documents/MB12-project/data/raster/sentinel2/")


# There are three services to login at:
login_CopHub(username = "sunymo")

# Print the status of all services:
#services()

# Query all available records for multiple products and a given time range at once,
# For Sentinel-2 :
records <- get_records(time_range = c("2016-01-01", "2020-10-30"),#"starting date of Sentinel:2015-06-23"
                       products = "Sentinel-2")

View(records)

# Filter to have only Level-2A data that is already preprocessed in terms of atmospheric and geometric correction ######
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


# preview (Here you can preview and select data based on quicklooks. Make sure that you select using T for TRUE or F for False) ######
dir_out_preview <- "C:/Users/sanaz/Documents/MB12-project/data/raster/previews"
select <- NULL

#create an empty data frame 
records_filt_new <- data.frame(matrix(ncol = 41, nrow = 5))
x <- colnames(records_filt_L2a)
x[39] <- "preview_file_jpg" # set the name of 39th column
x[40] <- "preview_file"     # set the name of 40th column
colnames(records_filt_new) <- x


for(i in 1:5){
  #records_filt_new[i,] <- get_previews( records_filt_L2a[i,] , dir_out = dir_out_preview)
  plot <- plot_previews(records_filt_new[i,] , show_aoi = TRUE , aoi_colour = "red")
  print(plot) # so that after each iteration, the new plot can be depicted
  #usable <- as.logical(readline("Select? "))
  #print(usable)
  select <- c(select, as.logical(readline("Select? ")))# F: FALSE, T: TRUE
}

records.filt2 <- records_filt_new[select,]
#records.filt2<- records.filt2[-1,]

# get data (Data will be downloaded to your directory set above, you will see the progress of data download) ######
records.filt2[41] <- NA
check_availability(records.filt2 ,  hub="auto" ,verbose=TRUE)
x[41] <- "download_available"
colnames(records.filt2) <- x

order_data()
files <- getSentinel_data(records.filt2, verbose=TRUE)

###### extract data (first set again your working directory, a folder [extract_data] will be created and downloaded .zip files will extracted; modify the path to your 'unzip'exe accordingly) ######
setwd("D:/DATA/Sentinel/ITALY/getSpatialData")
extr_dir <- "D:/DATA/Sentinel/ITALY/getSpatialData/extract_data"
if(!dir.exists(extr_dir)) dir.create(extr_dir)
path7zip <- "C:/Program Files/7-Zip/7z.exe"
catch <- pbsapply(files, function(x) system(paste0('"', path7zip, '" x ', x, " -o", extr_dir, " -aos"), invisible = T, show.output.on.console = F))
safe.dir <- list.dirs(extr_dir, full.names = T, recursive = F) 




