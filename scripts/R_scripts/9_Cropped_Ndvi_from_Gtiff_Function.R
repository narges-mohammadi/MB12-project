#######
# The following code consiste of 2 functions 
# First is used to calculate and saves the NDVIs for different years & sites on dirve
# Second is for ploting histogram and time series and saving them 
########


setwd("C:/Users/sanaz/")

#1: Load R packages
## Install & load packages
pck <- (c("tidyr","rgdal","ggplot2","raster",
          "leaflet","rasterVis","gridExtra","RColorBrewer",
          "plotly","RStoolbox","sp","IRdisplay","reshape", 
          "here", "patchwork"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)


#2: Load Auxillary data
### Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
aoi <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site1_MFC2_agroforestry/MFC2.shp")
aoi_2 <- rgdal::readOGR("C:/Users/sanaz/Documents/MB12-project/data/vector/Site2_GOR_forest/Site2_GOR_forest/GOR.shp")

MFC2_bbox <- as(extent(515379.3, 516012.9, 4468068.3, 4468567.9), 'SpatialPolygons')
crs(MFC2_bbox) <- crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")
GOR_bbox <- as(extent(519177.4, 519889, 4461970.6, 4462834), 'SpatialPolygons')
crs(GOR_bbox) <- crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")


ndvi_crop_dir <- here("Desktop","Playground_dir_8")

# This function calculates NDVI for the specific year and study area & writes them on the drive
write_NDVI_site_year <- function(site, year){
  site <- toupper(site)
  # Load S2 tiles 
  year_dir <- paste0("L2A_",year)
  S2_names <- here("Documents","MB12-project","CREODIAS_part", "data_from_CREODIAS", year_dir)
  S2_names_1 <- list.files(S2_names,recursive = FALSE, full.names = TRUE, pattern="S2[A,B]_MSIL2A_[[:alnum:]]{15}_[[:alnum:]]{5}_[[:alnum:]]{4}_[[:alnum:]]{6}_[[:alnum:]]{15}.SAFE$")
  S2_names_T <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.tif$")
  S2_names_L2A_v1 <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, pattern="L2A_T[[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.tif$")
  S2_names <- lapply(1:length(S2_names_T), function(x){raster(S2_names_T[x])})                                                      
  if(length(S2_names_L2A_v1)){S2_names_L2A <- lapply(1:length(S2_names_L2A_v1), function(x){raster(S2_names_L2A_v1[x])})}
  
  
  num_loop <- length(S2_names_T) / 4
  site_dir <- site
  
  # The loop calculates NDVI for tiles in which names of 10m bands start with "T"
  for(i in 1:num_loop){
    # Stack all the .tiff bands(10m)
    S2_names_indexed <- S2_names[((i-1)*4+1):((i-1)*4+4)]
    S2_stack <- stack(S2_names_indexed)
    
    # crop around each study area
    if (site == "MFC2"){
      crop_box <- MFC2_bbox
    }else{
      crop_box <- GOR_bbox
    }
    
    S2_stack_site_bbox <- crop(S2_stack , crop_box)
    
    # Derive NDVI 
    NDVI_list <- list()
    
    NDVI_site <- overlay(x=S2_stack_site_bbox[[3]], y=S2_stack_site_bbox[[4]], fun=function(x,y){(y-x)/(y+x)})
    
    names(NDVI_site) <- paste0("NDVI_", tolower(site),"_",
                               unlist(strsplit(strsplit(S2_names_T[(i-1)*4+1],'/')[[1]][9],'[.]')[[1]][1]))
                               #paste(strsplit(strsplit(strsplit(S2_names_T[(i-1)*4+1],'/')[[1]][9],'[.]')[[1]][1], "_")[[1]][3], strsplit(strsplit(strsplit(S2_names_T[(i-1)*4+1],'/')[[1]][9],'[.]')[[1]][1], "_")[[1]][4],sep="_"))
    
    # Export the NDVI raster
    
    name <- names(NDVI_site)
    #print(i,name)
    dir.create(file.path(ndvi_crop_dir,site))
    dir.create(file.path(ndvi_crop_dir,site,as.character(year)))
    write_dir <- file.path(ndvi_crop_dir,site,as.character(year))
    filename <- file.path(write_dir, name)
    
  
    writeRaster(x = NDVI_site,
                filename = filename,
                format = "GTiff", # save as a tif
                datatype='FLT4S', 
                progress='text',
                overwrite = TRUE
                )
    
    
  }
  
  if(length(S2_names_L2A_v1)){
  
    num_loop_L2A <- length(S2_names_L2A) / 4
  
    # This loop calculates NDVI for tiles in which names of 10m bands start with "L2A"
    for(i in 1:num_loop_L2A){
      # Stack all the .tiff bands(10m)
      S2_names_indexed <- S2_names_L2A[((i-1)*4+1):((i-1)*4+4)]
      S2_stack <- stack(S2_names_indexed)
    
      # crop around each study area
      if (site == "MFC2"){
        crop_box <- MFC2_bbox
      }else{
        crop_box <- GOR_bbox
      }
    
      S2_stack_site_bbox <- crop(S2_stack , crop_box)
    
      # Derive NDVI 
      NDVI_list <- list()
    
      NDVI_site <- overlay(x=S2_stack_site_bbox[[3]], 
                           y=S2_stack_site_bbox[[4]], 
                           fun=function(x,y){(y-x)/(y+x)})
    
      names(NDVI_site) <- paste0("NDVI_", tolower(site),"_",
                                unlist(strsplit(strsplit(S2_names_L2A_v1[(i-1)*4+1],'/')[[1]][9],'[.]')[[1]][1]))
                                #paste(strsplit(strsplit(strsplit(S2_names_L2A_v1[(i-1)*4+1],'/')[[1]][9],'[.]')[[1]][1], "_")[[1]][3], strsplit(strsplit(strsplit(S2_names_L2A_v1[(i-1)*4+1],'/')[[1]][9],'[.]')[[1]][1], "_")[[1]][4],sep="_"))
    
    
    
      name <- names(NDVI_site)
      filename <- file.path(write_dir, name)
      #print(name)
    
      writeRaster(x = NDVI_site,
                  filename = filename,
                  format = "GTiff", 
                  datatype='FLT4S', 
                  progress='text',
                  overwrite = TRUE
                  )
    
      }
  }
  
}

# Change site and year here
site <- "MFC2"  #"GOR"
year <- 2018
write_NDVI_site_year(site, year)


#list_year <- list(a=2018, b=2019, c=2020)
#sapply(list_year, FUN = write_NDVI_site_year, site="GOR" )

# Following function converts the character to DOY
# sample form of x is : "20200507T095029"
char_to_doy <- function(x) {
  #dt <- strsplit(x,"T")[[1]][1]
  #dt_europe <- lubridate::ymd(dt)
  #doy <- strftime(dt_europe , format = "%j")
  #DOY <- as.numeric(doy)
  # Use of pipes
  DOY <- strsplit(x,"T")[[1]][1] %>%
          lubridate::ymd() %>%
          strftime(format = "%j") %>%
          as.numeric()
  
  return (DOY)
}

# use the following "ndvi_crop_dir" for 2017 
#ndvi_crop_dir <- here("Documents","MB12-project", "CREODIAS_part",
#                      "data_from_CREODIAS", paste0("L2A_",year),"NDVI",toupper(site) )

# use the following "ndvi_crop_dir" for 2018,2019,2020
ndvi_crop_dir <- here("Desktop","Playground_dir_8", site,year)
# This function draws histogram, time series plot of NDVI 
# and writes the plots to drive
NDVI_plots_site_year <- function(site, year){
  site <- toupper(site)
  # Read the NDVIs in and stack them
  ndvi_dir <- file.path(ndvi_crop_dir)#,site,as.character(year)[used for 2019,2020]
  ndvi_list <- list.files(ndvi_dir,recursive = TRUE, 
                          full.names = TRUE, pattern="^NDVI_")
  
  #Load the select_10m.Rds
  select_10m <-readRDS(file = here("Documents", "MB12-project",
                                   "CREODIAS_part", "data_from_CREODIAS",
                                   paste0("L2A_", year),
                                   "RGB",
                                   paste0("select10m_", year, ".Rds"))) #: for 2018,2019,2020
                                   #"select10m.Rds"))
  
  # select tiles based on select_10m
  ndvi_list_df <- as.data.frame(ndvi_list)
  select_10m_df <- as.data.frame(select_10m)
  ndvi_list_selected <- cbind(ndvi_list_df, select_10m_df)
  ndvi_list_selected<- ndvi_list_selected %>% filter(select_10m == TRUE)
  
  
  ndvi_stack <- stack(ndvi_list_selected$ndvi_list)
  
  # Plotting the NDVI time series
  ndvi_stack_df <- as.data.frame(ndvi_stack, xy = TRUE) %>%
    melt(id.vars = c('x', 'y'))
  
  poly <- fortify(aoi)
  poly2 <- fortify(aoi_2)
  
  
  if (site == "MFC2"){
    pol <- poly
  }else{
    pol <- poly2
  }
  names(pol) <- c('x', 'y')
  
  
  if (site == "MFC2"){
    
    sntnlDates <- gsub("NDVI_mfc2_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                          "", 
                          ndvi_stack_df$variable)
    
  }else{
    
    sntnlDates <- gsub("NDVI_gor_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                          "", 
                          ndvi_stack_df$variable)
  }
  
  # Convert character dates in dataframe to DOY (used for plot)
  ndvi_stack_df$date <- as.data.frame(sntnlDates)
  ndvi_stack_df$doy <- apply(ndvi_stack_df[,5], 1, char_to_doy)
  
  # Create a separate panel for each time point in the time series
 ggplot() +
    geom_raster(data = ndvi_stack_df , aes(x = x, y = y, fill = value)) +
    facet_wrap(~ doy ) + 
    geom_path(aes(x,y), alpha = 0.9, colour = "black", data = pol) +
    scale_fill_distiller(palette ="RdYlGn", direction = 1) + 
    plot_annotation(
       title = sprintf("NDVI_%s_%s", site, as.character(year))
       ) +
    coord_equal()
 

  
  
  # base directory for saving the plots
  #write_dir <- file.path(ndvi_crop_dir, site, as.character(year))
  write_dir <- file.path(here("Desktop","Playground_dir_8",site)) # used for 2018 and 2017
  ggsave(here(write_dir, paste0(sprintf("ndvi_%s", tolower(site)), ".png")), 
         scale = 3, 
         dpi = 300
         )
  
  
  # View Distribution of Raster Values (Histogram)
  ggplot(ndvi_stack_df) +
    geom_histogram(aes(value), stat = "bin", bins = 30) +
    plot_annotation(
      title = sprintf("Distribution of NDVI values_%s_%s", site, as.character(year))
       ) +
    xlab("NDVI") + 
    ylab("Frequency") +
    facet_wrap(~doy)
  

  ggsave(here(write_dir, paste0(sprintf("histogram_%s", tolower(site)), ".png")), 
         scale = 3, 
         dpi = 300
         )
  
  
  # calculate mean NDVI for each raster
  avg_NDVI_stack <- cellStats(ndvi_stack, mean)
  
  # convert output array to data.frame
  avg_NDVI_stack <- as.data.frame(avg_NDVI_stack)
  
  # view column name slot
  names(avg_NDVI_stack)
  
  # rename the NDVI column
  names(avg_NDVI_stack) <- "meanNDVI"
  
  # add a site column to our data
  avg_NDVI_stack$site <- sprintf("%s_study_site", site)
  
  # # note the use of the vertical bar character ( | ) is equivalent to "or". This
  # allows us to search for more than one pattern in our text strings.
  if (site == "MFC2"){
    
    sentinelDates <- gsub("NDVI_mfc2_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                          "", 
                          row.names(avg_NDVI_stack))
  
  }else{
    
    sentinelDates <- gsub("NDVI_gor_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                          "", 
                          row.names(avg_NDVI_stack))
  }
  
  
  # Convert character dates in dataframe to DOY (used for plot)
  avg_NDVI_stack$date <- as.data.frame(sentinelDates)
  avg_NDVI_stack$doy <- apply(avg_NDVI_stack[,3], 1, char_to_doy)
  
  
  # plot NDVI
  ggplot(avg_NDVI_stack, aes(doy, meanNDVI), na.rm=TRUE) +
    geom_point(size=4,colour = "PeachPuff4") + 
    geom_line(aes(group=site)) +
    ggtitle( sprintf("Sentinel NDVI \n %s Site", site)) +
    xlab("DOY") + 
    ylab("Mean NDVI [-]") +
    ylim(0, 1) +
    theme(text = element_text(size=10))
  
  
  ggsave(here(write_dir, paste0(sprintf("ndvi_series_%s", tolower(site)), ".png")), 
         scale = 3, 
         dpi = 300)
  
  
  
}

NDVI_plots_site_year(site, year)
