###################
# The following code consiste of 2 functions 
# First is used to calculate and saves the NDVIs for different years & sites 
# NDVI is one of the most used VIs that measures the photosynthetic activity of vegetation and describes 
# the vitality of vegetation on Earth's Surface. 
# Second is for ploting histogram and time series and saving them 
##################

# This function calculates NDVI for the specific year and study area & writes them on the drive
write_NDVI_site_year <- function(path, site, year, ndvi_crop_dir){
  
  #1: Load R packages
  ## Install & load packages
  pck <- (c("tidyr","rgdal","ggplot2","raster",
            "leaflet","rasterVis","gridExtra","RColorBrewer",
            "plotly","RStoolbox","sp","sf","IRdisplay","reshape", 
            "here", "patchwork", "tidyverse", "cowplot"))
  new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
  if(length(new_pck)){install.packages(new_pck)}
  sapply(pck , require, character.only=TRUE)
  
  
  #2: Load Auxillary data
  ### Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
  aoi <- rgdal::readOGR(dsn=here::here("data", "Raw_data", "vector", "Site1_MFC2_agroforestry"), layer= "MFC2")
  
  aoi_2 <- rgdal::readOGR(dsn=here("data", "Raw_data", "vector","Site2_GOR_forest", "Site2_GOR_forest"), layer="GOR")
  
  artifact_mfc2 <- rgdal::readOGR(dsn=here("data", "Raw_data", "vector","QGIS_part"), layer="parking_lot")#"C:/Users/sanaz/Documents/MB12-project/QGIS_part/parking_lot.shp"
  
  artifact2_mfc2 <- rgdal::readOGR(dsn=here("data", "Raw_data", "vector","QGIS_part"), layer="house")#"C:/Users/sanaz/Documents/MB12-project/QGIS_part/house.shp"
  
  # reproject data
  artifact_mfc2_new <- spTransform(artifact_mfc2,
                                   crs(aoi))
  artifact2_mfc2_new <- spTransform(artifact2_mfc2,
                                    crs(aoi))
  
  MFC2_bbox <- as(extent(515379.3, 516012.9, 4468068.3, 4468567.9), 'SpatialPolygons')
  crs(MFC2_bbox) <- crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")
  GOR_bbox <- as(extent(519177.4, 519889, 4461970.6, 4462834), 'SpatialPolygons')
  crs(GOR_bbox) <- crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")
  
  
  site <- toupper(site)
  # Load S2 tiles 
  #year_dir <- paste0("L2A_",year)
  S2_names <- path
  S2_names_1 <- list.files(S2_names, recursive = FALSE, full.names = TRUE, 
                           pattern="*.SAFE$")#S2[A,B]_MSIL2A_[[:alnum:]]{15}_[[:alnum:]]{5}_[[:alnum:]]{4}_[[:alnum:]]{6}_[[:alnum:]]{15}.SAFE$
  S2_names_T <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                           pattern="^[T][[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.tif$")
  S2_names_L2A_v1 <- list.files(S2_names_1, recursive = TRUE, full.names = TRUE, 
                                pattern="L2A_T[[:alnum:]]{5}_[[:alnum:]]{15}_B0[2348]_10m.tif$")
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
    
    # Remove the artifacts(parking lot) from NDVI files for MFC2
    if (site == "MFC2"){
      
      NDVI_site_wo_artifact  <-  NDVI_site
     
      r1 <- NDVI_site
      r1[artifact_mfc2_new] <- 94
      r1[artifact2_mfc2_new] <- 94
      names(r1) <- names(NDVI_site)
      rna <- reclassify(r1, cbind(94, NA))
      NDVI_site_wo_artifact  <-  rna
        
    
      NDVI_site <- NDVI_site_wo_artifact
    }
    

    # Export the NDVI raster
    
    name <- names(NDVI_site)
    #print(i,name)
    
    dir.create(file.path(ndvi_crop_dir, site))
    
    dir.create(file.path(ndvi_crop_dir, site, as.character(year)))
    
    write_dir <- file.path(ndvi_crop_dir, site, as.character(year))
    
    filename <- file.path(write_dir, name)
    
    
    # Define projection for NDVI before writing it to drive
    crs(NDVI_site) <- sp::CRS('+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs')
  
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
      
      # Remove the artifacts(parking lot) from NDVI files for MFC2
      if (site == "MFC2"){
        
        NDVI_site_wo_artifact  <-  NDVI_site
        
        r1 <- NDVI_site
        r1[artifact_mfc2_new] <- 94
        r1[artifact2_mfc2_new] <- 94
        names(r1) <- names(NDVI_site)
        rna <- reclassify(r1, cbind(94, NA))
        NDVI_site_wo_artifact  <-  rna
        
        
        NDVI_site <- NDVI_site_wo_artifact
      }
       
      
      # Define projection for NDVI before writing it to drive
      crs(NDVI_site) <- sp::CRS('+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs')
      
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


# input dir
#path <- here("CREODIAS_part", "data_from_CREODIAS", "L2A_2017_sen2cor")#year_dir

# Change site and year here(parameters)
#site <- "MFC2"#"GOR"  #
#year <- 2017

# output dir
#ndvi_crop_dir <- here("Results", "Playground_dir_8", "NDVI")

# invoke the function
#write_NDVI_site_year(path, site, year, ndvi_crop_dir)


# Following function converts the character to DOY
# sample form of x is : "20200507T095029"
char_to_doy <- function(x) {
  # Use of pipes
  DOY <- strsplit(x,"T")[[1]][1] %>%
          lubridate::ymd() %>%
          strftime(format = "%j") %>%
          as.numeric()
  
  return (DOY)
}


# This function draws histogram, time series plot of NDVI 
# and writes the dfs & plots to drive
NDVI_plots_site_year <- function(site, year, ndvi_dir, rgb_dir, save_dir, save_dir_avg){
  
  #1: Load R packages
  ## Install & load packages
  pck <- (c("tidyr","rgdal","ggplot2","raster",
            "leaflet","rasterVis","gridExtra","RColorBrewer",
            "plotly","RStoolbox","sp","sf","IRdisplay","reshape", 
            "here", "patchwork", "tidyverse", "cowplot"))
  
  new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
  
  if(length(new_pck)){install.packages(new_pck)}
  
  sapply(pck , require, character.only=TRUE)
  
  
  #2: Load Auxillary data
  ### Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
  aoi <- rgdal::readOGR(dsn=here::here("data", "Raw_data", "vector", "Site1_MFC2_agroforestry"), layer= "MFC2")
  
  aoi_2 <- rgdal::readOGR(dsn=here("data", "Raw_data", "vector","Site2_GOR_forest", "Site2_GOR_forest"), layer="GOR")
  
  artifact_mfc2 <- rgdal::readOGR(dsn=here("data", "Raw_data", "vector","QGIS_part"), layer="parking_lot")#"C:/Users/sanaz/Documents/MB12-project/QGIS_part/parking_lot.shp"
  
  artifact2_mfc2 <- rgdal::readOGR(dsn=here("data", "Raw_data", "vector","QGIS_part"), layer="house")#"C:/Users/sanaz/Documents/MB12-project/QGIS_part/house.shp"
  
  # reproject data
  artifact_mfc2_new <- spTransform(artifact_mfc2,
                                   crs(aoi))
  artifact2_mfc2_new <- spTransform(artifact2_mfc2,
                                    crs(aoi))
  
  MFC2_bbox <- as(extent(515379.3, 516012.9, 4468068.3, 4468567.9), 'SpatialPolygons')
  
  crs(MFC2_bbox) <- crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")
  
  GOR_bbox <- as(extent(519177.4, 519889, 4461970.6, 4462834), 'SpatialPolygons')
  
  crs(GOR_bbox) <- crs("+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")
  
  
  site <- toupper(site)
  
  # Read the NDVIs in and stack them
  ndvi_dir_specific <- file.path(ndvi_dir, site, year)
  
  ndvi_list <- list.files(ndvi_dir_specific, recursive = TRUE, 
                          full.names = TRUE, pattern="^NDVI_")
  
  #Load the select_10m.Rds
  # the following "select_10m" is different for each site
  select_10m <-readRDS(file = file.path(here("data", "Augmented_data", "Playground_dir_10", site, year),
                                        paste0("select10m_", year,"_", toupper(site),".Rds")))
  
  
  # select tiles based on select_10m
  ndvi_list_df <- as.data.frame(ndvi_list)
  
  select_10m_df <- as.data.frame(select_10m)
  
  ndvi_list_selected <- cbind(ndvi_list_df, select_10m_df)
  
  ndvi_list_selected <- ndvi_list_selected %>% filter(select_10m == TRUE)
  
  
  ndvi_stack <- stack(ndvi_list_selected$ndvi_list)
  
  poly <- fortify(aoi)
  poly2 <- fortify(aoi_2)
  
  
  if (site == "MFC2"){
    pol <- poly
  }else{
    pol <- poly2
  }
  names(pol) <- c('x', 'y', "order", "hole", "piece", "id", "group")
  
  
  if (site == "MFC2"){
    
    sntnlDates <- gsub("NDVI_mfc2_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                       "", 
                       names(ndvi_stack))
    
  }else{
    
    sntnlDates <- gsub("NDVI_gor_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                       "", 
                       names(ndvi_stack))
  }
  
  # Convert character dates in raster names to DOY (used for plot)
  df_date <- as.data.frame(sntnlDates)
  
  ndvi_stack_renamed <- ndvi_stack
  
  if(exists("char_to_doy")){names(ndvi_stack_renamed) <- apply(df_date, 1, char_to_doy)
  
  }else{ # if one forgets to load the "char_to_doy" function before the current function; it is called here
    
    char_to_doy <- function(x) {
    
    # Use of pipes
    DOY <- strsplit(x,"T")[[1]][1] %>%
      lubridate::ymd() %>%
      strftime(format = "%j") %>%
      as.numeric()
    
    return (DOY)
    }
  
    names(ndvi_stack_renamed) <- apply(df_date, 1, char_to_doy)
  }
  
  
  
  # saveRDS(ndvi_stack_renamed, file.path(save_dir, toupper(site), 
  #                                       "Extracted_dfs", sprintf("selected_ndvi_stack_%s_%s",site,year)))
  
  # I had to use "writeRaster()" for "MFC2" as I change the rasters to remove artifacts
  # stackSave() can only be used when the layers of stack are already saved on the drive;
  
  stackSave(ndvi_stack_renamed, file.path(save_dir, toupper(site),
                                          "Extracted_dfs", sprintf("selected_ndvi_stack_%s_%s", site, year))
                                           )

  
  # Plot method 1
  # use colorbrewer which loads with the rasterVis package to generate
  # a color ramp of yellow to green
  cols <- colorRampPalette(brewer.pal(9,"RdYlGn"))#"YlGn"
  
 
  png(here(ndvi_dir_specific, paste0(sprintf("ndvi_%s_%s", tolower(site), year), ".png")))
  
  # define breaks for levelplot()
  my.at <- seq(-1, 1, by = 0.1)
  
  myColorkey <- list(at=my.at, ## where the colors change
                     labels=list(
                       at=my.at ## where to print labels
                     ),
                     space="bottom")
  
  # When using levelplot()+layer() inside function, the plot did not get enough time to print the study area boundaries on rasters
  # Hence the switch over to levelplot()+spplot() is done 
  if (site=="MFC2"){ 
      
      #print(levelplot(ndvi_stack_renamed, main=sprintf("Sentinel2 NDVI %s %s", site, year), col.regions=cols, par.settings=list(layout.heights=list(xlab.key.padding=1)), panel = panel.levelplot.raster, interpolate = TRUE, colorkey = list(space="bottom"), margin = FALSE)  
            # + layer(sp.polygons(aoi, col = "black"))) 
      
      print(levelplot(ndvi_stack_renamed, main=sprintf("Sentinel2 NDVI %s %s", site, year), col.regions=cols, par.settings=list(layout.heights=list(xlab.key.padding=1)), panel = panel.levelplot.raster, interpolate = TRUE, colorkey = list(space="bottom"), margin = FALSE)
             + spplot(aoi, fill = "transparent", col = "black", xlim = c(extent(ndvi_stack_renamed)@xmin, 
                                                                                            extent(ndvi_stack_renamed)@xmax), ylim = c(extent(ndvi_stack_renamed)@ymin, extent(ndvi_stack_renamed)@ymax), 
                     colorkey = FALSE))
  
    }else{ 
      
      #print(levelplot(ndvi_stack_renamed, main=sprintf("Sentinel2 NDVI %s %s", site, year), col.regions=cols, par.settings=list(layout.heights=list(xlab.key.padding=1)), panel = panel.levelplot.raster, interpolate = TRUE, colorkey = list(space="bottom"), margin = FALSE) 
      # + layer(sp.polygons(aoi_2, col = "black")))
      
      print(levelplot(ndvi_stack_renamed, main=sprintf("Sentinel2 NDVI %s %s", site, year), col.regions=cols, par.settings=list(layout.heights=list(xlab.key.padding=1)), panel = panel.levelplot.raster, interpolate = TRUE, colorkey = list(space="bottom"), margin = FALSE)
             + spplot(aoi_2, fill = "transparent", col = "black", xlim = c(extent(ndvi_stack_renamed)@xmin, 
                                                                                       extent(ndvi_stack_renamed)@xmax), ylim = c(extent(ndvi_stack_renamed)@ymin, extent(ndvi_stack_renamed)@ymax), 
                     colorkey = FALSE))
  }
  
   
  dev.off()
   
  rgb_dir_specific <- here(rgb_dir, site, year)
  
  rgb_list <-  list.files(rgb_dir_specific, 
                                full.names=TRUE, 
                                pattern = ".tif$")
  # select tiles based on select_10m
  rgb_list_df <- as.data.frame(rgb_list)
  
  select_10m_df <- as.data.frame(select_10m)
  
  rgb_list_selected <- cbind(rgb_list_df, select_10m_df)
  
  rgb_list_selected <- rgb_list_selected %>% filter(select_10m == TRUE)
  
  rgb_list_selected$names <- lapply(rgb_list_selected$rgb_list, FUN=function(x){return(basename(x))})
  
  rgb_stack <- stack(rgb_list_selected$rgb_list)

  
  # plot rgb :method 2
  png(here(ndvi_dir_specific, paste0(sprintf("rgb_%s_%s", tolower(site), year), ".png")))
      #, width=54, height=81, unit="in", res=300)
  
  # create a layout
  # adjust the parameters so the axes colors are white. Also turn off tick marks.
  #par(mfrow=c(6,6), col.axis = "white",
  #     col.lab = "white", tck = 0)
  
  # set the initial value of list index
  i <- 1
  
  # create a list with the length of selected tiles(without cloud)
  plot_lst <- vector("list", length = nrow(rgb_list_selected))
  
  # go through each RGB file and plot it 
  for (aFile in rgb_list_selected$rgb_list){
    
    if (site=="MFC2"){
      x <- gsub("RGB_MFC2_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}.tif", 
              "", 
              basename(aFile))
      doy_x <- char_to_doy(x)
    }else{
      x <- gsub("RGB_GOR_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}.tif", 
                "", 
                basename(aFile))
      doy_x <- char_to_doy(x)
    }
    
    RGB.rastStack <- stack(aFile)
    
     
    g <-  ggRGB(RGB.rastStack, r=3, g=2, b=1) +
          ggtitle(sprintf("DOY %s", doy_x))+
          geom_polygon(col = 'Black',
                    fill = NA,
                    data = pol,#aoi_DataFrame
                    aes(x = x, y = y))+# for "aoi_DataFrame": x=long,y=lat, group = group
          theme(axis.text = element_blank(),
                    axis.text.y = element_blank(),
                    axis.title=element_blank(),
                    #title=sprintf("RGB %s %s", site , as.character(year)),
                    plot.margin=unit(c(0,0,0,0),"pt")#reduce or eliminate plot margins
                )

    plot_lst[[i]] <- g
    i <- i+1    
       
  }
  
  # Combine all plots
  # cowplot::plot_grid(plotlist = plot_lst,nrow = 6)
  
  # Using "patchwork" library for multiple plots
  pp <-  plot_lst[[1]]
  
  end_lim <- nrow(rgb_list_selected)
  
  for(i in c(2 : end_lim)){ # the end number of loop is the amount of selected tiles
    
    pp <- pp + plot_lst[[i]]
  }
  
  # the following  number of cols and rows only makes sure that the plot is drawn but the overal shape 
  # of ndvi stack and rgb stack will not be the same
  pp + plot_layout( nrow=8, ncol=8)# how should the number of rows and cols be set automatically?
  
  dev.off()
  
  # calculate mean NDVI for each raster
  avg_NDVI_stack <- cellStats(ndvi_stack, mean)
  
  # convert output array to data.frame
  avg_NDVI_stack <- as.data.frame(avg_NDVI_stack)
  
  # view column name slot
  #names(avg_NDVI_stack)
  
  # rename the NDVI column
  names(avg_NDVI_stack) <- "meanNDVI"
  
  # add a site column to our data
  avg_NDVI_stack$site <- sprintf("%s_study_site", site)
  
  # # note the use of the vertical bar character ( | ) is equivalent to "or". 
  # This allows us to search for more than one pattern in text strings.
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
  
 
  # save to drive
  saveRDS(avg_NDVI_stack, file = file.path(save_dir_avg, 
                                           paste0("avg_NDVI_stack_", site, "_", year)) )
  
  
  # plot NDVI
  ggplot(avg_NDVI_stack, aes(doy, meanNDVI), na.rm=TRUE) +
    geom_point(size=4, colour = "PeachPuff4") + 
    #geom_smooth(method = "loess", span = 0.4) + 
    geom_smooth() +
    geom_line(aes(group=site), linetype= "dashed") +
    labs(title = sprintf("Mean NDVI over %s in %s", site, year))+
    #ggtitle( sprintf("Sentinel NDVI \n %s Site", site)) +
    scale_x_continuous(breaks = seq(1, 365, by = 14))+
    xlab("DOY") + 
    ylab("Mean NDVI [-]") +
    ylim(0, 1) +
    theme(text = element_text(size = 15),
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          aspect.ratio= 12/16)
  
  
  ggsave(here(ndvi_dir_specific, paste0(sprintf("ndvi_series_%s", tolower(site)), ".png")), 
         scale = 3, 
         #width = 15, 
         #height = 10,
         dpi = 300)
  
}


# input directory for the "NDVI_plots_site_year" function
#ndvi_dir <- here("Results","Playground_dir_8", "NDVI")

# base input rgb directory
#rgb_dir <- here("Results", "Playground_dir_10")

# directory for saving the selected NDVI stack into drive to use in "correlation"
#save_dir <- here("Results","Playground_dir_14", "NDVI")

# Save the avearge NDVI dataframe to drive (will be used in "17_Correlation_NDWI_with_NDVI.R")
#save_dir_avg <- here("Results", "Playground_dir_8", "NDVI", "output")

#NDVI_plots_site_year(site, year, ndvi_dir, rgb_dir, save_dir, save_dir_avg)
