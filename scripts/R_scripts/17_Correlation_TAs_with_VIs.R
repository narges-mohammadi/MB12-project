
# This code is the function format of "15_Correlation_TAs_with_NDVI.R"

setwd("C:/Users/sanaz/")

#1: Load R packages
## Install & load packages
pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet",
          "rasterVis","gridExtra","RColorBrewer","plotly",
          "RStoolbox","sp","IRdisplay","reshape","here", 
          "bfast", "bfastSpatial", "rkt", "xlsx"))# "rkt" : for time series analysis

new_pck <- pck[!pck %in% installed.packages()[,"Package"]]

if(length(new_pck)){install.packages(new_pck)}

sapply(pck , require, character.only=TRUE)

#read in a self defined function 
source(here("Documents", "MB12-project", "scripts", "R_scripts", "rename_S2.R"))

#2: Load Auxillary data
### Define your area of interest (aoi), which is MFC2 (bacino_MFC_corrected) or bounding_box_MFC or else #
aoi <- rgdal::readOGR(dsn=here::here("Documents", "MB12-project", "data", "vector", "Site1_MFC2_agroforestry"), layer= "MFC2")
aoi_2 <- rgdal::readOGR(dsn=here("Documents", "MB12-project", "data", "vector","Site2_GOR_forest", "Site2_GOR_forest"), layer="GOR")



# the function recieves the x (X32 or X267 or ... )  and decides if the layer is 
# in "wet" , "dry" or "transition" season
three_season <- function(x){
    if(x %in% c(paste0('X', 305:365), paste0('X', 1:60))){
        season <- "wet"
    }else if(x %in% c(paste0('X', 121:245))){
        season <- "dry"
    }else if (x %in% c(paste0('X', 246:304), paste0('X', 61:120))){
        season <- "transition"
    }
    return(season)
}


# following function calculates the matrixes containing 
# correlation values of VIs with TAs in areas of interest(and writes them to drive)
# for now it only supports NDVI and NDWI


corr_ta_vi <- function(vi, site, vi_dir, dir_ta, out_dir) {
    
    # Define the extent of study sites(will be used in crop())
    if(site == "GOR"){
        study_site <- aoi_2
        shared_extent <- extent(519180, 519880, 4461980, 4462830)
        
    }else if(site == "MFC2"){
        study_site <- aoi
        shared_extent <- extent(515380, 516010, 4468070, 4468560)
    }
    
  
    if(site == "GOR"){
        dir_ta_site <- here(dir_ta, "TA_GOR1_10m")  
    }else if(site == "MFC2"){
        dir_ta_site <- here(dir_ta, "TA_MFC2_10m")
    }
    
    ta_stack_path <- list.files(dir_ta_site,
                                         recursive = FALSE, 
                                         full.names = TRUE, 
                                         pattern = "*10m.tif$")
    
    # Creates a list of "RasterLayer"s each one corresponding to one Topographic attribute(rasters are already cropped)
    if(length(ta_stack_path)){ta_stack <- pbapply::pblapply(1:length(ta_stack_path), 
                                                                     function(x){raster(ta_stack_path[x])
                                                                     })
    }
    
    
    # choose folder to read from based on VI
    if(vi == "NDVI"){
        
        selected_vi_stack_path <- list.files(here(vi_dir, "NDVI", site, "Extracted_dfs"), 
                                             recursive = FALSE, 
                                             full.names = TRUE, 
                                             pattern="selected_")
    }else if(vi == "NDWI"){
        
        selected_vi_stack_path <- list.files(here(vi_dir, "NDWI", site, "Extracted_dfs"), 
                                             recursive = FALSE, 
                                             full.names = TRUE, 
                                             pattern="selected_")
        }
        
    
    # read in the stack VIs
    if(length(selected_vi_stack_path)){vi_stack <- pbapply::pblapply(1:length(selected_vi_stack_path), 
                                                                     function(x){stackOpen(selected_vi_stack_path[[x]])
                                                                     })}
    
 
    
    # rename the VI names to DOY(using "rename_sntl" function) added using "source"
    if(length(vi_stack)){vi_stack_names <- pbapply::pblapply(1:length(vi_stack), 
                                                             function(x){rename_sntl(site, vi, names(vi_stack[[x]]
                                                                                                 ))
                                                             })}
    # assign new names to VIs
    names(vi_stack[[1]]) <- vi_stack_names[[1]]
    names(vi_stack[[2]]) <- vi_stack_names[[2]]
    names(vi_stack[[3]]) <- vi_stack_names[[3]]
    names(vi_stack[[4]]) <- vi_stack_names[[4]]
    
    # Creates a list of "RasterBrick"s each with 3 layers(dry, transition, wet) for every year
    mean_stack <- pbapply::pblapply(1:length(vi_stack),  
                                        function(x){stackApply(vi_stack[[x]],
                                                               indices = lapply(names(vi_stack[[x]]), FUN = three_season),
                                                               fun = mean)})
        
    # Create a list of "RasterLayer"s that each one is the mean VI for each pixel in each year
    mean_stack_annual <- pbapply::pblapply(1:length(mean_stack),
                                               function(x){calc(mean_stack[[x]], 
                                                                      fun = mean)})
    
    # Set name for each "RasterLayer" in the "mean_stack_annual":
    # This list is used for naming(Change it if you use other years) 
    year_list <- list(2017, 2018, 2019, 2020)#list(2018, 2020)#
    
    mean_stack_annual_names <- pbapply::pblapply(1:length(mean_stack_annual),
                      function(x){sprintf("avg_%s_%s_%s", tolower(vi), tolower(site), year_list[[x]] )}
                      )
    names(mean_stack_annual[[1]]) <- mean_stack_annual_names[[1]]
    names(mean_stack_annual[[2]]) <- mean_stack_annual_names[[2]]
    names(mean_stack_annual[[3]]) <- mean_stack_annual_names[[3]]
    names(mean_stack_annual[[4]]) <- mean_stack_annual_names[[4]]
    
    
    #Create one "RasterLayer" that averages VI values of all the years
    mean_vi <- calc(stack(mean_stack_annual[[1]], mean_stack_annual[[2]], 
                          mean_stack_annual[[3]], mean_stack_annual[[4]]),
                    fun = mean)
    
    names(mean_vi) <- sprintf("avg_%s_%s", vi, site)
    
    
    # For NDWI change the resolution from 20m to 10 m to be able to later combine with Topographic Attributes(10m)
    if(vi == "NDWI"){
        # disaggregate from 20x20 resolution to 10x10 (factor = 2)
        
        mean_stack_annual_resampled <- pbapply::pblapply(1:length(mean_stack_annual),
                                               function(x){disaggregate(mean_stack_annual[[x]], fact = 2)
                                                   })
        mean_vi_resampled <- disaggregate(mean_vi, fact = 2)
        
        # Now to keep the rest of code unchanged, assign the new values to the previous names
        mean_stack_annual <- mean_stack_annual_resampled
        
        mean_vi <- mean_vi_resampled
    }
    
   
    
    # Make the extent of two raster stacks the same
    
    ta_crop <- pbapply::pblapply(1:length(ta_stack),
                                 function(x){raster::crop(ta_stack[[x]], shared_extent)})
   
    
    vi_annual_crop <- pbapply::pblapply(1:length(mean_stack_annual),
                      function(x){raster::crop(mean_stack_annual[[x]], shared_extent)})
    
    vi_crop <- crop(mean_vi, shared_extent)# one layer raster (VI average of all years pixel wise)
    
    # Mask out the raster values outside the study site boundary
    clipped_vi_annual <- pbapply::pblapply(1:length(vi_annual_crop),
                                           function(x){raster::mask(vi_annual_crop[[x]], study_site)})
    
    clipped_vi <- raster::mask(vi_crop, study_site)
    

    # Convert the raster stacks to Dataframes
    # List of dataframes 
    list_df_ta <- pbapply::pblapply(1:length(ta_crop),
                               function(x){as.data.frame(ta_crop[[x]])})
   
    # List of dataframes 
    list_df_annual_vi <- pbapply::pblapply(1:length(clipped_vi_annual),
                                            function(x){as.data.frame(clipped_vi_annual[[x]])})
    
    
    df_vi <- as.data.frame(clipped_vi)    
     
    # Create Matrix (Here needs work)
    # List of 4 dataframes containting VIs for each year and TAs
    list_df_vi_ta <- pbapply::pblapply(1:length(list_df_annual_vi),
                      function(x){cbind(list_df_annual_vi[[x]], 
                                        list_df_ta[[1]], list_df_ta[[2]], list_df_ta[[3]],
                                        list_df_ta[[4]], list_df_ta[[5]], list_df_ta[[6]],
                                        list_df_ta[[7]], list_df_ta[[8]], list_df_ta[[9]])})
    
    # List of matrixes
    list_matrix_vi_ta <- pbapply::pblapply(1:length(list_df_vi_ta),
                                           function(x){as.matrix(list_df_vi_ta[[x]])})
   
    
    # Create matrix from VI average of all years & TAs
    df_vi_ta <- cbind(df_vi, list_df_ta[[1]], list_df_ta[[2]], list_df_ta[[3]],
                      list_df_ta[[4]], list_df_ta[[5]], list_df_ta[[6]],
                      list_df_ta[[7]], list_df_ta[[8]], list_df_ta[[9]])
    
    matrix_vi_ta <- as.matrix(df_vi_ta)
    
    # Correlation matrix
    
    # List of correlation matrix for each year
    list_corr_matrix <- pbapply::pblapply(1:length(list_matrix_vi_ta),
                      function(x){cor(list_matrix_vi_ta[[x]], use = "pairwise.complete.obs")})
    
    # Correlation matrix for average VI(over 4 years) and TAs
    M_avg <- cor(matrix_vi_ta, 
                 use = "pairwise.complete.obs",
                 method = "pearson")
    
    
    # Write the matrixes to drive
    pbapply::pblapply(1:length(list_corr_matrix),
                      function(x){write.csv(list_corr_matrix[[x]], 
                                            file = file.path(out_dir,
                                                             sprintf("Corr_Matrix_%s_%s_with_TAs_%s.csv", vi, year_list[x], site)))})
    
    # save the matrix as csv file
    write.csv(M_avg, file = file.path(out_dir, 
                                        sprintf("Corr_Matrix_%s_with_TAs_%s.csv", vi, site)))
    
   
}


#VI input directory
vi_dir <- here("Desktop","Playground_dir_14")

# For github repo:
#vi_dir <- "data"/"extracted_dfs"/


#TA input dir
dir_ta <- here("Documents", "MB12-project", "data",
             "Gridded_topographic_attributes")

# For github repo:
#dir_ta <- "data"/"Gridded_topographic_attributes"/

# output dir
out_dir <- here(vi_dir, "output")

corr_ta_vi(vi="NDWI", site="GOR", vi_dir = vi_dir, dir_ta = dir_ta, out_dir = out_dir)


# Visualization of correlation Matrix(using corrplot())

cor_matrix_dir <- here(vi_dir, "output")

# Finds the full path of correlation matrixes containing the specified study site name
cor_matrix_names <- list.files(cor_matrix_dir,
                               pattern = sprintf("*%s*.csv", site),
                               full.names = TRUE)

# Create the correlation plots and writes them as pdf
if(length(cor_matrix_names)){cor_matrix <- pbapply::pblapply(1:length(cor_matrix_names), 
                                                        function(x){
                                                          # import the .csv matrixes into R(Be aware that read.csv() output is in dataframe class)
                                                          dec = "."    
                                                          df <- read.csv(cor_matrix_names[x], dec=dec, 
                                                                         header = TRUE, stringsAsFactors=FALSE)
                                                          
                                                          # convert "character" to "numeric" in dataframe
                                                          cols.num <- colnames(df)[2:11]
                                                          
                                                          df[cols.num] <- sapply(df[cols.num], as.numeric)
                                                          
                                                          # convert df to matrix (needed for corrplot() function)
                                                          my_mat <- apply(as.matrix.noquote(df),  # Using apply function
                                                                          2,
                                                                          as.numeric)
                                                          
                                                          # Give the names of columns to rows
                                                          rownames(my_mat) <- colnames(my_mat)[2:11]
                                                          
                                                          pdf(file = file.path(cor_matrix_dir, 
                                                                               paste0(strsplit(basename(cor_matrix_names[x]), ".csv"), "_Corrplot.pdf")),
                                                              width = 10,
                                                              height = 10)
                                                          
                                                          corrplot::corrplot(my_mat[1:10,2:11], 
                                                                             method = "square",
                                                                             type="upper",
                                                                             title= sprintf("%s correlation plot", site),
                                                                             addCoef.col = "black", # Add coefficient of correlation
                                                                             # Combine with significance
                                                                             sig.level = 0.05, insig = "blank", 
                                                                             #diag=FALSE,
                                                                             # hide correlation coefficient on the principal diagonal
                                                                             mar=c(0,0,1,0) # http://stackoverflow.com/a/14754408/54964)
                                                          )
                                                          
                                                          dev.off()
                                                          
                                                        })
}



