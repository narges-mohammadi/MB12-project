#############################
# The code intends to select the appropriate tiles
#(no cloud cover over study areas) based on RGB-10m
# each site will have different "select" file
# The main side product of this code snippet is RGB files
############################

write_rgb <- function(path, site, year, rgb_dir){

  #1: Load R packages
  ## Install & load packages
  pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet",
            "rasterVis","gridExtra","RColorBrewer","plotly",
            "RStoolbox","sp","IRdisplay","reshape","here"))
  new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
  if(length(new_pck)){install.packages(new_pck)}
  sapply(pck , require, character.only=TRUE)

  #2: Load Auxillary data
  ### Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
  aoi <- rgdal::readOGR(dsn=here::here("data","Raw_data", "vector", "Site1_MFC2_agroforestry"), layer= "MFC2")
  aoi_2 <- rgdal::readOGR(dsn=here("data", "Raw_data", "vector","Site2_GOR_forest", "Site2_GOR_forest"), layer="GOR")


  MFC2_bbox <- as(raster::extent(515379.3, 516012.9, 4468068.3, 4468567.9), 'SpatialPolygons')
  crs(MFC2_bbox) <- crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")
  GOR_bbox <- as(raster::extent(519177.4, 519889, 4461970.6, 4462834), 'SpatialPolygons')
  crs(GOR_bbox) <- crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")


  # Load S2 tiles (attention to ^ in pattern)
  S2_names <-  path
  S2_names_1 <- list.files(S2_names,recursive = FALSE, 
                          full.names = TRUE, 
                          pattern="*.SAFE$"
                          )#S2[A,B]_MSIL2A_[[:alnum:]]{15}_[[:alnum:]]{5}_[[:alnum:]]{4}_[[:alnum:]]{6}_[[:alnum:]]{15}.SAFE

  S2_names_T <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                          pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B0[234]_10m.tif$")

  S2_names_L2A_v1 <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE,
                              pattern="L2A_T[[:alnum:]]{5}_[[:alnum:]]{15}_B0[234]_10m.tif$")
  S2_names <- lapply(1:length(S2_names_T), function(x){raster(S2_names_T[x])})                                                      

  if(length(S2_names_L2A_v1)){S2_names_L2A <- lapply(1:length(S2_names_L2A_v1), 
                                                   function(x){raster(S2_names_L2A_v1[x])})
  }else{S2_names_L2A <- character(0)}


  num_loop <- length(S2_names_T) / 3


  # The loop calculates RGB for tiles in which names of 10m bands start with "T"
  for(i in 1:num_loop){
    # Stack all the .tiff bands(10m)
    S2_names_indexed <- S2_names[((i-1)*3+1):((i-1)*3+3)]
  
    S2_stack <- stack(S2_names_indexed)
  
    # crop around each study area
    if (site == "MFC2"){
      crop_box <- MFC2_bbox
    }else{
      crop_box <- GOR_bbox
    }
  
    # crop around the study areas
    S2_stack_crop_bbox <- crop(S2_stack , crop_box)
  
    rgb_10m <- list()
  
    rgb_10m <- stack(S2_stack_crop_bbox[[1]],S2_stack_crop_bbox[[2]],S2_stack_crop_bbox[[3]])
  
    rgb_name <- paste0("RGB_", paste0(site,"_"),
                     unlist(strsplit(strsplit(S2_names_T[(i-1)*3+1],'/')[[1]][9],'[.]')[[1]][1]))
  
  
    # Export the RGB_10m raster
    name <- rgb_name
  
    dir.create(file.path(rgb_dir, site))
  
    dir.create(file.path(rgb_dir, site, as.character(year)))
  
    dir_name <- file.path(rgb_dir, site, as.character(year))
  
    filename <- file.path(dir_name, name)
  
    writeRaster(x = rgb_10m, #if i doesn't work , replace with 1
                filename = filename,#
                format = "GTiff", # save as a tif
                datatype='FLT4S', 
                #progress='text',
                overwrite = TRUE)
  
}



if(length(S2_names_L2A)){num_loop_L2A <- length(S2_names_L2A) / 3}
# This loop calculates RGB for tiles in which names of 10m bands start with "L2A"
if(length(S2_names_L2A_v1)){for(i in 1:num_loop_L2A){
  # Stack all the .tiff bands(10m)
  S2_names_indexed <- S2_names_L2A[((i-1)*3+1):((i-1)*3+3)]
  
  S2_stack <- stack(S2_names_indexed)
  
  
  # crop around each study area
  if (site == "MFC2"){
    crop_box <- MFC2_bbox
  }else{
    crop_box <- GOR_bbox
  }
  
  # crop around the study areas
  S2_stack_crop_bbox <- crop(S2_stack , crop_box)
  
  
  # Derive RGB
  rgb_10m <- list()
  
  rgb_10m <- stack(S2_stack_crop_bbox[[1]],S2_stack_crop_bbox[[2]],S2_stack_crop_bbox[[3]])
  
  rgb_name <- paste0("RGB_", paste0(site,"_"),
                     unlist(strsplit(strsplit(S2_names_L2A_v1[(i-1)*3+1],'/')[[1]][9],'[.]')[[1]][1]))
  
  
  # Export the RGB_10m raster
  name <- rgb_name
  
  dir_name <- file.path(rgb_dir, site, as.character(year))
  
  filename = file.path(dir_name, name)
  
  writeRaster(x = rgb_10m,
              filename = filename,
              format = "GTiff", # save as a tif
              datatype='FLT4S', 
              progress='text',
              overwrite = TRUE) 
  
}}

}

# change site and year here
#site <- "MFC2" # "GOR"
#year <- 2017
#year_dir <- paste0("L2A_", year)

#path <- here("CREODIAS_part", "data_from_CREODIAS", "L2A_2017_sen2cor")#year_dir

# Base directory for writing RGB files
#rgb_dir <- here("Desktop", "Playground_dir_10")

#write_rgb(path, site, year, rgb_dir)


char_to_doy <- function(x) {
  # Use of pipes
  DOY <- x %>%
    lubridate::ymd() %>%
    strftime(format = "%j") %>%
    as.numeric()
  
  return (DOY)
}



# following function shows the rgb for each site and year & lets you select
tile_sel_rgb <- function(site, year, rgb_dir){
  
  #1: Load R packages
  ## Install & load packages
  pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet",
            "rasterVis","gridExtra","RColorBrewer","plotly",
            "RStoolbox","sp","IRdisplay","reshape","here"))
  new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
  if(length(new_pck)){install.packages(new_pck)}
  sapply(pck , require, character.only=TRUE)
  
  #2: Load Auxillary data
  ### Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
  aoi <- rgdal::readOGR(dsn=here::here("data", "vector", "Site1_MFC2_agroforestry"), layer= "MFC2")
  aoi_2 <- rgdal::readOGR(dsn=here::here("data", "vector","Site2_GOR_forest", "Site2_GOR_forest"), layer="GOR")
  
  
  MFC2_bbox <- as(raster::extent(515379.3, 516012.9, 4468068.3, 4468567.9), 'SpatialPolygons')
  raster::crs(MFC2_bbox) <- raster::crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")
  GOR_bbox <- as(raster::extent(519177.4, 519889, 4461970.6, 4462834), 'SpatialPolygons')
  raster::crs(GOR_bbox) <- raster::crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")
  
  
  # RGB (for selecting the appropriate tiles for the analysis)
  # To choose which tiles to use for analysis based on cloud cover(use of 10m resolution) 
  # Read the RGBs and stack them
  dir_name <- file.path(rgb_dir, site, as.character(year))
  rgb_list <- list.files(dir_name, recursive = TRUE, full.names = TRUE, 
                         pattern="^RGB_")
  rgb_ras <- lapply(1:length(rgb_list), function(x){raster::brick(rgb_list[x])}) 

  #define and intialize the select_10m
  select_10m <- rep(TRUE, length(rgb_list))# 63: varies depend on the n of tiles
  
  # create a dataframe containing "select" and "name" of the chosen rgb
  df <- data.frame(Choose=logical(length=length(rgb_list)),
                   Name=character(length=length(rgb_list)),
                   stringsAsFactors=FALSE)
  
  
  # following params are for plotting inside the loop
  
  
  # poly based on each study area
  if (site == "MFC2"){
    poly <- ggplot2::fortify(aoi)
    names(poly)[1:2] <- c('x','y')
  }else{
    poly <- ggplot2::fortify(aoi_2)
    names(poly)[1:2] <- c('x','y')
  }
  
  e <- raster::extent(rgb_ras[[1]])
  
  

  for(i in 1:length(rgb_list)){#
    if (site == "MFC2"){
      rgb_doy <- gsub("RGB_MFC2_S2[AB]_MSIL2A_|T[[:digit:]]{6}_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}.tif", 
                      "", 
                      basename(rgb_list[i]))
    }else{
      rgb_doy <- gsub("RGB_GOR_S2[AB]_MSIL2A_|T[[:digit:]]{6}_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}.tif", 
                      "", 
                      basename(rgb_list[i]))
    }
    
    print(ggplot2::ggplot() + RStoolbox::ggRGB(img = rgb_ras[[i]],
                          r = 3,
                          g = 2,
                          b = 1,
                          #stretch = 'hist',
                          ggLayer = T) + 
            ggplot2::xlim(e[1:2]) + ggplot2::ylim(e[3:4]) + 
            ggplot2::geom_path(ggplot2::aes(x,y), alpha = 0.9, colour = "red" ,data = poly)+
            ggplot2::ggtitle(sprintf("%s",char_to_doy(rgb_doy)))
            #geom_path(aes(x2,y2), alpha = 0.9,  colour = "red",data = poly2)+
            #coord_equal()
            )
  
    select_10m[i] <- as.logical(readline("Select? ")) #c(select_10m, as.logical(readline("Select? ")))
    
    }
   
  # Populate the dataframe
  df$Choose <- select_10m
  df$Name <- lapply(rgb_list, FUN=function(x){basename(x)})
  
  
  #save the "select_10m" on the drive("select_10m" based on RGB_10m)
  saveRDS(select_10m, 
          file = file.path(dir_name, paste0("select10m_", year, "_", site, ".Rds")))
  
  # save the dataframe containing names of chosen tiles
  saveRDS(df, 
          file = file.path(dir_name, paste0("df_withNames_select10m_", year, "_", site, ".Rds")))

}

# input folder
#rgb_dir <- here("Results","Playground_dir_10")

#tile_sel_rgb(site, year, rgb_dir)



