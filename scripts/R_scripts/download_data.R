setwd("C:\\Users\\sanaz\\Documents\\MB12-project")
#install.packages("devtools")
#devtools::install_github("16EAGLE/getSpatialData")
pck <- (c("getSpatialData","sf","sp","raster","rgdal","RGISTools","dplyr"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)


### Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
aoi <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp")
aoi_2 <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site2_GOR_forest/Site2_GOR_forest/GOR.shp")

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
proj4string(sps)  <-  CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

getSpatialData::set_aoi(aoi)
getSpatialData::set_aoi(sps) 
getSpatialData::view_aoi()

### Define an archive directory:
getSpatialData::set_archive("C:/Users/sanaz/Documents/MB12-project/data/raster/sentinel2/")


### There are three services to login at:
getSpatialData::login_CopHub(username = "sunymo")

### Print the status of all services:
#services()

### Query all available records for multiple products and a given time range at once,
### For Sentinel-2 :
records <- getSpatialData::get_records(time_range = c("2018-01-01", "2018-12-25"),#"starting date of Sentinel:2015-06-23"
                       products = "Sentinel-2")

View(records)

### Filter to have only Level-2A data that is already preprocessed in terms of atmospheric and geometric correction ######
records_filt_L2A <- records[records$level == "Level-2A",]
records_filt_L2Ap <- records[records$level == "Level-2Ap",]
records_filt_L1C <- records[records$level == "Level-1C",]

### display the footprint geometries of each record on a map:
view_records(records[1:3])

### calculate the cloud cover of optical sentinel data in an aoi based on small previews
dir_out <- "C:/Users/sanaz/Documents/MB12-project/data/raster/cloud_calc_output"
calc_cloudcov(records_filt_L2a[1:5,] ,dir_out = dir_out)


### Write table with few variables for each tile/sensor date  
new_record_table <- records %>%
  dplyr::select( preview_url, date_ingestion , tile_id , orbit_direction, platform_serial, level , size , cloudcov ,vegetation , cloudcov_notvegetated , water ) 

### It's a .txt file ####
write.table( new_record_table, file="C:/Users/sanaz/Documents/MB12-project/data/List_Sentinel-2.txt"
            ,col.names=TRUE,row.names=FALSE)


### preview (Here you can preview and select data based on quicklooks. Make sure that you select using T for TRUE or F for False) ######
dir_out_preview <- "C:/Users/sanaz/Documents/MB12-project/data/raster/previews"
select <- NULL

### create an empty data frame 
records_filt_new <- data.frame(matrix(ncol = 41, nrow = 5))
x <- colnames(records_filt_L2A)
x[37] <- "preview_file_jpg" # set the name of 39th column
x[38] <- "preview_file"     # set the name of 40th column
colnames(records_filt_new) <- x

# Loop for downloading previews
for(i in 1:5){
  records_filt_new[i,] <- get_previews( records_filt_L2A[i,] , dir_out = dir_out_preview)
}

#  Loop for choosing which tiles to download based on their preview
for(i in 1:5){
  plot <- plot_previews(records_filt_new[i,] , show_aoi = TRUE , aoi_colour = "red")
  print(plot) # so that after each iteration, the new plot can be depicted
  #usable <- as.logical(readline("Select? "))
  #print(usable)
  #select <- c(select, as.logical(readline("Select? ")))# F: FALSE, T: TRUE
}

# In  case there was NA inside the "select"
select2 <- select
for (i in 1:length(select2)) {
  #print(i)
if(is.na(select2[i])) 
    select2[i] <- FALSE
}

#save the select2 on the drive
save(select2, file = "C:/Users/sanaz/Documents/MB12-project/data/select2.RData")
#Load the select2.RData 
load("C:/Users/sanaz/Documents/MB12-project/data/select2.RData") 
head(select2)



records.filt2 <- records_filt_new[select2,]
#records.filt2<- records.filt2[-1,]

### get data (Data will be downloaded to your directory set above, you will see the progress of data download) ######
records.filt2[41] <- NA
check_availability(records=records.filt2 , verbose=TRUE)
# !!! check_availability didn't work so I manually set the value of this column to TRUE to 
# be able to proceed to download section
x[41] <- "download_available"
colnames(records.filt2) <- x
records.filt2$download_available <- TRUE

###### download the data
files <- getSentinel_data(records.filt2[56:65,], verbose=TRUE)

###### extract data (first set again your working directory, a folder [extract_data] will be created and downloaded .zip files will extracted; modify the path to your 'unzip'exe accordingly) ######
#setwd("D:/DATA/Sentinel/ITALY/getSpatialData")
#extr_dir <- "D:/DATA/Sentinel/ITALY/getSpatialData/extract_data"
#if(!dir.exists(extr_dir)) dir.create(extr_dir)
#path7zip <- "C:/Program Files/7-Zip/7z.exe"
#catch <- pbsapply(files, function(x) system(paste0('"', path7zip, '" x ', x, " -o", extr_dir, " -aos"), invisible = T, show.output.on.console = F))
#safe.dir <- list.dirs(extr_dir, full.names = T, recursive = F) 


# Use of GIStools package for retrieving the preview of files in R 
sres <- senSearch(startDate = as.Date("2019013", "%Y%j"),
                  endDate = as.Date("2019365", "%Y%j"),
                  platform = "Sentinel-2",
                  region = sps,
                  product = "S2MSI2A",
                  username = "sunymo",
                  password = "Nargesmo69")

# preview some images
senPreview(sres, username = "sunymo", password = "Nargesmo69",n=1)
senPreview(sres, username = "sunymo", password = "Nargesmo69",n=20, add.Layer =TRUE)

# show the dates in julian days
senGetDates(names(sres),format="%Y%j")


#select_2 <- readRDS(file = "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/testdir/select_testdir.Rds")

