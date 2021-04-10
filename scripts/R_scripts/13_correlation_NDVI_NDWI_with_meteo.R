#######################
# Find the correlation between NDVI and meteorological params
# First plot both dataframes together 
# Afterwards use corrplot() package to quantify the correlation
#######################

### Preparation ############################# 

#1: Load R packages
## Install & load packages
pck <- (c("tidyr", "rgdal", "ggplot2", "raster",
          "leaflet", "rasterVis", "gridExtra", "RColorBrewer",
          "plotly", "RStoolbox", "sp", "IRdisplay", "reshape", 
          "here", "patchwork", "readxl", "ggExtra", "viridis",
          "corrplot", "PerformanceAnalytics", "ggpmisc", "qwraps2",
          "tableone", "pander", "arsenal", "finalfit"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)


### Creation process of dataframes(meteorological and NDVI) ############################# 

# Read in the meteorological dfs created in "11_Meteo_Params.R"

site_list <- list("MFC2", "GOR")

read_dir <- here("data", "Augmented_data","Playground_dir_11","output")

list_meteo_df <- pbapply::pblapply(1:length(site_list), 
                                      function(x){
                                          readRDS(file = file.path(read_dir, 
                                                                   paste0("meteorological_df_", site_list[[x]])))
                                      }
)

# Precipitation bar plot
# x11()
# ggplot(mfc2_meteo_df, aes(DOY, Prec_mm, colour = Year)) + 
#     #geom_line()+
#     geom_bar(stat = "identity", position = "identity", fill = NA) +
#     scale_color_viridis(discrete = FALSE, option = "cividis", direction = -1)+# option="inferno"
#     scale_x_continuous(breaks = seq(1, 365, by = 7))+  
#     scale_y_continuous(breaks = seq(0, 100, by = 10))+
#     theme(text = element_text(size = 8),
#           axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5))+
#     xlab("DOY") + 
#     ylab("Precipitation [mm]") +
#     removeGrid(x = TRUE, y = FALSE)+
#     #facet_wrap(~site, ncol = 1)
#     facet_wrap(~Year, ncol = 1)

# In this part I should use the NDVI dataframe created from "9_Cropped_Ndvi_from_Gtiff_Function"
# In which contains the average NDVIs
# NDVI ts vs DOY 
# NDVI dataframes from 2017 and 2018 contain multiple meanNDVI for the same "doy"
# There must be sth wrong in the creation of NDVI or their selection
# In 2017 and 2018, sentinel tiles had bands starting with T_* and also with L2A_*



# define a list of years
year_list <- list(2017, 2018, 2019, 2020)

# created in "9_Cropped_Ndvi_from_Gtiff_Function.R" script
read_dir_ndvi <-here("data", "Augmented_data", "Playground_dir_8", "NDVI", "output") 

list_ndvi_df <- pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                     function(y) {
                                                                         
                                                                         readRDS(file = file.path(read_dir_ndvi, 
                                                                                                  paste0("avg_NDVI_stack_", 
                                                                                                         site_list[[x]],"_",
                                                                                                         year_list[[y]])))
                                                                         
                                                                        
                                                                     }))



# NDWI created in "16_NDWI.R"
read_dir_ndwi <-here("data", "Augmented_data", "Playground_dir_8", "NDWI", "output") 

list_ndwi_df <- pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                                     function(y) {
                                                                                         
                                                                                         readRDS(file = file.path(read_dir_ndwi, 
                                                                                                                  paste0("avg_NDWI_stack_", 
                                                                                                                         site_list[[x]],"_",
                                                                                                                         year_list[[y]])))
                                                                                         
                                                                                         
                                                                                     }))



# A plot showing ndvi of GOR site during four years & precipitaion in the same site and year

# change the column name from "DOY" to "doy"
#names(gor1_meteo_df$DOY) <- "doy"
#names(mfc2_meteo_df[8]) <- "doy"


# change the name of column "DOY" to "doy"
meteo_mfc2_df <- as.data.frame(list_meteo_df[[1]])
names(meteo_mfc2_df)[8] <- "doy"

meteo_gor_df <- as.data.frame(list_meteo_df[[2]])
names(meteo_gor_df)[8] <- "doy"

meteo_mfc2_df <- subset(meteo_mfc2_df, meteo_mfc2_df$Year >= 2017 &  meteo_mfc2_df$Year <= 2020)

meteo_gor_df <- subset(meteo_gor_df, meteo_gor_df$Year >= 2017 &  meteo_gor_df$Year <= 2020)



# create list of two dataframes
meteo_df_sites_yrs <- list(meteo_mfc2_df, meteo_gor_df)


# add the "meanNDWI" column to dataframe
list_vi_df <- pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                                     function(y) {
                                                                                         
                                                                                         cbind(list_ndvi_df[[x]][[y]], 
                                                                                               meanNDWI=list_ndwi_df[[x]][[y]]$meanNDWI)
                                                                                         
                                                                                         
                                                                                     }))
# merge dataframes (NDVI and Meteorological)
list_df_merge <- pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                                   function(y) {
                                                                                       
                                                                                       na.omit(
                                                                                           merge(meteo_df_sites_yrs[[x]][meteo_df_sites_yrs[[x]]$Year == year_list[[y]],], 
                                                                                             list_vi_df[[x]][[y]], 
                                                                                             by= "doy",
                                                                                             all.x= FALSE, 
                                                                                             all.y= TRUE)
                                                                                           )
                                                                                       
                                                                                       
                                                                                   }))



# Writing dataframe data to text file
write_dir <- here("data", "Augmented_data","Playground_dir_11","output")

# Write the combined dataframes(NDVI and meteo) to drive

# Subset the each dataframe in the list to contain specific columns
list_subsetted_dfs <- pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                                      function(y) {
                                                                                          
                                                                                         subset(list_df_merge[[x]][[y]], 
                                                                                                select = -c(Month, Day, date, site.y))
                                                                                          
                                                                                      }))


# write to drive
m <- pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(year_list), 
                                                                     function(y) {
                                                                         
                                                                         df <- list_subsetted_dfs[[x]][[y]];
                                                                        
                                                                         write.table(df,
                                                                                     file = file.path(write_dir,
                                                                                                      paste0("merge_df_", df$site.x[1] , "_", df$Year[1], ".txt")),
                                                                                                sep = "\t",
                                                                                                row.names = TRUE,
                                                                                                col.names = NA)
                                                                         
                                                                     }))



### Start point: Read in the previously created dataframes ############################# 
# In future, If there was a change in your input data(Sentinel 2) tiles 
# you have to execute "Creation process of dataframes(meteorological and NDVI)" section above, otherwise 
# you can execute following lines to load in .txt files and do the plotting 

write_dir <- here("data", "Augmented_data", "Playground_dir_11", "output")

site_list_2 <- list("MFC2", "GOR1")# different from "site_list" as it has "GOR1" ;necessary due to the column name

list_read_dfs <- pbapply::pblapply(1:length(site_list_2), function(x) pbapply::pblapply(1:length(year_list), 
                                                                          function(y) {
                                                                              read.table(file = file.path(write_dir,
                                                                                                          sprintf("merge_df_%s_%s.txt", site_list_2[[x]], year_list[[y]])), 
                                                                                         header = TRUE,
                                                                                         stringsAsFactors = FALSE, 
                                                                                         sep = "\t")  
                                                                              
                                                                              
                                                                          }))



# the function recieves the x (doy)  and decides if the observation is 
# in "wet" , "dry" or "transition" season
three_season <- function(x){
    if(x %in% c( 305:365, 1:60)){
        season <- "wet"
    }else if(x %in% c(121:245)){
        season <- "dry"
    }else if (x %in% c( 246:304,  61:120)){
        season <- "transition"
    }
    return(season)
}

# add a column to dataframe containing season of rows
list_read_dfs_season_MFC2 <- lapply(list_read_dfs[[1]], 
                                    function(x) transform(x, season = three_season(doy)))

list_read_dfs_season_GOR <- lapply(list_read_dfs[[2]], 
                                    function(x) transform(x, season = three_season(doy)))

# create one dataframe that has "season" column for each study site 
df_mfc2_four_yrs <- rbind(list_read_dfs_season_MFC2[[1]], list_read_dfs_season_MFC2[[2]],
                          list_read_dfs_season_MFC2[[3]], list_read_dfs_season_MFC2[[4]])

df_gor_four_yrs <- rbind(list_read_dfs_season_GOR[[1]], list_read_dfs_season_GOR[[2]],
                         list_read_dfs_season_GOR[[3]], list_read_dfs_season_GOR[[4]])


# df_sites_four_yrs$season <- mapply(three_season, df_sites_four_yrs$doy) 
# df_gor_four_yrs$season <- mapply(three_season, df_gor_four_yrs$doy)
# df_mfc2_four_yrs$season <- mapply(three_season, df_mfc2_four_yrs$doy)

# write the new dataframes with season to drive 
write.csv(df_mfc2_four_yrs,
          here("data","Augmented_data", "Playground_dir_11", "output", "df_mfc2_with_Season.csv"), 
          row.names = FALSE)

write.csv(df_gor_four_yrs,
          here("data","Augmented_data", "Playground_dir_11", "output", "df_gor1_with_Season.csv"), 
          row.names = FALSE)


# read in the data 
df_mfc2_four_yrs <- read.csv(here::here("data","Augmented_data", "Playground_dir_11",
                                        "output", "df_mfc2_with_Season.csv"))

df_gor_four_yrs <- read.csv(here::here("data","Augmented_data", "Playground_dir_11",
                                       "output", "df_gor1_with_Season.csv"))


# create list of dfs
list_df_four_yrs <- list(df_mfc2_four_yrs, df_gor_four_yrs)


if(!dir.exists(here("data","Augmented_data", "Playground_dir_11", "tables"))){
    dir.create(here("data","Augmented_data", "Playground_dir_11", "tables"))
}
if(!dir.exists(here("data","Augmented_data", "Playground_dir_11", "tables", "GOR1"))){
    dir.create(here("data","Augmented_data", "Playground_dir_11", "tables", "GOR1"))
}
if(!dir.exists(here("data","Augmented_data", "Playground_dir_11", "tables", "MFC2"))){
    dir.create(here("data","Augmented_data", "Playground_dir_11", "tables", "MFC2"))
}

# "arsenal" package for summary tables
#GOR1
my_controls <-  arsenal::tableby.control(
    test = T,
    total = T,
    numeric.test = "anova", 
    cat.test = "chisq",
    numeric.stats = c("meansd", "medianq1q3", "range"),
    cat.stats = c("countpct", "Nmiss2"),
    stats.labels = list(
        meansd = "Mean (SD)",
        medianq1q3 = "Median (Q1, Q3)",
        range = "Min - Max"
    )
)

# Be aware that NDVI in this dataframe represents 
# the mean NDVI value for this area of interest on a given day.
my_labels <- list(
    T_Celsius = "Temperature (°C)",
    Prec_mm = "Precipitation (mm)",
    ET0_mm = "Evapotranspiration (mm)",
    meanNDVI = "mean NDVI over study area"
)

df_gor_four_yrs$season_factor <- as.factor(df_gor_four_yrs$season)

table_two <-  arsenal::tableby(season_factor ~ .,
                     data = df_gor_four_yrs,
                     control = my_controls
)

summary(table_two,
        labelTranslations = my_labels,
        title = "Summary Statistic of GOR1 Dataframe"
)



# MFC2
my_controls <- arsenal::tableby.control(
    test = T,
    total = T,
    numeric.test = "anova", 
    cat.test = "chisq",
    numeric.stats = c("meansd", "medianq1q3", "range"),
    cat.stats = c("countpct", "Nmiss2"),
    stats.labels = list(
        meansd = "Mean (SD)",
        medianq1q3 = "Median (Q1, Q3)",
        range = "Min - Max"
    )
)


my_labels <- list(
    T_Celsius = "Temperature (°C)",
    Prec_mm = "Precipitation (mm)",
    ET0_mm = "Evapotranspiration (mm)",
    meanNDVI = "mean NDVI over study area"
)

df_mfc2_four_yrs$season_factor <- as.factor(df_mfc2_four_yrs$season)

table_two <-  arsenal::tableby(season_factor ~ .,
                     data = df_mfc2_four_yrs,
                     control = my_controls
)

summary(table_two,
        labelTranslations = my_labels,
        title = "Summary Statistic of MFC2 Dataframe"
)


# Read the Topographic Attributes (dataframes) for further analysis
# Created in "15_DEM_Gridded_Topographic_Attributes.R" script
# input_dir <- here("Desktop", "Playground_dir_14")
# mfc2_dem_df <- readRDS(file=file.path(input_dir, "MFC2", "Extracted_dfs", "mfc2_dem_df"))
# 
# gor1_dem_df <- readRDS(file=file.path(input_dir, "GOR", "Extracted_dfs", "gor1_dem_df"))



plot_dir <- here("data","Augmented_data","Playground_dir_11", "plots")


# Scatter plot with correlation coefficient
#:::::::::::::::::::::::::::::::::::::::::::::::::

list_df_four_yrs[[1]]$Year <- as.character(list_df_four_yrs[[1]]$Year)

# Convert "Year" as a grouping variable
list_df_four_yrs_factorized <- pbapply::pblapply(1:length(site_list), 
                                                 function(x){
                                                     list_df_four_yrs[[x]]$Year <- as.character(list_df_four_yrs[[x]]$Year);
                                                     list_df_four_yrs[[x]]$Year <- factor(list_df_four_yrs[[x]]$Year, levels=c("2017", "2018", "2019", "2020"));
                                                     return(list_df_four_yrs[[x]])
                                                     
                                                 }
)


list_parameter <- list("Temperature", "Precipitation", "Evapotranspiration")
list_method <- list("spearman", "pearson", "kendall")
list_vi <- list("NDVI", "NDWI")

pbapply::pblapply(1:length(list_parameter), function(x) pbapply::pblapply(1:length(list_vi), function(y) pbapply::pblapply(1:length(list_method), 
                                                                                                                           function(z) {
                                                                                                                               
                                                                                                                               if(list_parameter[[x]] == "Temperature") x_axis_name <- "T_Celsius"
                                                                                                                               
                                                                                                                               else if(list_parameter[[x]] == "Precipitation") x_axis_name <- "Prec_mm"
                                                                                                                               
                                                                                                                               else if(list_parameter[[x]] == "Evapotranspiration") x_axis_name <- "ET0_mm" 
                                                                                                                               
                                                                                                                               
                                                                                                                               sp <- ggscatter(rbind(list_df_four_yrs_factorized[[1]], list_df_four_yrs_factorized[[2]]), 
                                                                                                                                               x = x_axis_name,#"T_Celsius", 
                                                                                                                                               y = sprintf("mean%s", list_vi[[y]]),
                                                                                                                                               parse=TRUE,
                                                                                                                                               # combine = TRUE, ylab = "NDVI",
                                                                                                                                               add = "reg.line",  # Add regressin line
                                                                                                                                               add.params = list(color = "black", fill = "lightgray"), # Customize reg. line
                                                                                                                                               fullrange= TRUE, 
                                                                                                                                               color = "Year",
                                                                                                                                               title = sprintf("%s correlation coefficient & p-value for %s vs. %s", 
                                                                                                                                                               list_method[[z]], list_parameter[[x]], list_vi[[y]]),
                                                                                                                                               palette = c("blue", "red", "green","orange"),
                                                                                                                                               facet.by= "site.x",#"Year",##c("Year", "site.x"),
                                                                                                                                               xlab = sprintf("%s ", list_parameter[[x]]), 
                                                                                                                                               ylab = sprintf("%s [-]", list_vi[[y]]), 
                                                                                                                                               conf.int = FALSE # Add confidence interval
                                                                                                                               );
                                                                                                                               
                                                                                                                               # Add correlation coefficient   
                                                                                                                               sp + stat_cor(aes(color = Year), label.x = 4 ,
                                                                                                                                             method = list_method[[z]],
                                                                                                                                             #label = paste0("R = ", ..r.., ", P = ", ..p..),
                                                                                                                                             label.x.npc =  'left', 
                                                                                                                                             label.y.npc = 'bottom');
                                                                                                                               
                                                                                                                               ggsave(here(plot_dir, paste0(sprintf("%s_%s_correlation_r_%s_sites_yrs", 
                                                                                                                                                                    list_parameter[[x]], list_vi[[y]], list_method[[z]]), ".pdf")), #spearman
                                                                                                                                      scale = 1, 
                                                                                                                                      width = 10,
                                                                                                                                      height = 10,
                                                                                                                                      dpi = 300);
                                                                                                                           }
)))






# NDVI(/NDWI) and Precipitation in four years for each site 

# vi_list <- list("NDVI", "NDWI")
# 
# pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(vi_list), 
#                                                                                         function(y) {
#                                                                                             
#                                                                                             colname <- sprintf("mean%s", vi_list[[y]])
#                                                                                             
#                                                                                             ggplot2::ggplot(meteo_df_sites_yrs[[x]], aes(doy, Prec_mm )) + 
#                                                                                                 geom_col(data = meteo_df_sites_yrs[[x]], aes(doy, Prec_mm))+
#                                                                                                 #geom_bar(stat = "identity") + #tells ggplot2 you'll provide the y-values for the barplot, rather than counting the aggregate number of rows for each x value
#                                                                                                 geom_point(data = list_df_four_yrs[[x]], aes(doy, !!ensym(colname)*100)) + #
#                                                                                                 geom_line(data = list_df_four_yrs[[x]] , aes(doy, !!ensym(colname)*100)) +#*100
#                                                                                                 stat_smooth(data = list_df_four_yrs[[x]]  , aes(doy, !!ensym(colname)*100), colour="blue")+#*100
#                                                                                                 scale_x_continuous(breaks = seq(1, 365, by = 7))+  
#                                                                                                 scale_y_continuous(breaks = seq(0, 100 , by= 10))+ #for Precipitation; 
#                                                                                                 scale_y_continuous(sec.axis = sec_axis(~./100, name = sprintf("%s [-]", vi_list[[y]])))+
#                                                                                                 theme(text = element_text(size = 8),
#                                                                                                       axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5))+
#                                                                                                 xlab("doy") + 
#                                                                                                 ylab("Precipitation [mm]") +
#                                                                                                 labs(title = sprintf("%s and Precipitaion in %s ", vi_list[[y]], meteo_df_sites_yrs[[1]]$site[1]))+
#                                                                                                 removeGrid(x = TRUE, y = FALSE)+
#                                                                                                 #facet_grid(Year~site.x) 
#                                                                                                 facet_wrap(~Year, ncol = 1)# vars(Year, site.x), ncol = 2  
#                                                                                             
#                                                                                             
#                                                                                             
#                                                                                             
#                                                                                             ggsave(here(plot_dir, paste0(sprintf("precipitation_%s_%s_years", vi_list[[y]], tolower(site_list[[x]])), ".pdf")), 
#                                                                                                    scale = 1, 
#                                                                                                    dpi = 300)
#                                                                                             
#                                                                                         }))


x11()

# Change the "site" and "VI "manually here
site <- "MFC2" #"GOR" #  
VI <- "NDVI"#"NDWI"# #

if(site=="MFC2"){
    data1 <- meteo_df_sites_yrs[[1]]
    data2 <- list_df_four_yrs[[1]]
} else if(site=="GOR") {
    data1 <- meteo_df_sites_yrs[[2]]
    data2 <- list_df_four_yrs[[2]]
}
if(VI == "NDVI"){
ggplot(data1, aes(doy, Prec_mm )) + 
    geom_col(data=data1, aes(doy, Prec_mm))+
    #geom_bar(stat = "identity") + #tells ggplot2 you'll provide the y-values for the barplot, rather than counting the aggregate number of rows for each x value
    geom_point(data =  data2, aes(doy, meanNDVI*100)) + 
    geom_line(data = data2 , aes(doy, meanNDVI*100)) +
    stat_smooth(data = data2 , aes(doy, meanNDVI*100), colour="blue")+
    scale_x_continuous(breaks = seq(1, 365, by = 7))+  
    scale_y_continuous(breaks = seq(0, 100 , by= 10))+ #for Precipitation; 
    scale_y_continuous(sec.axis = sec_axis(~./100, name = "NDVI [-]"))+
    theme(text = element_text(size = 8),
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5))+
    xlab("doy") + 
    ylab("Precipitation [mm]") +
    labs(title = sprintf("NDVI and Precipitaion in %s ", site))+
    removeGrid(x = TRUE, y = FALSE)+
    #facet_grid(Year~site.x) 
    facet_wrap(~Year, ncol = 1)# vars(Year, site.x), ncol = 2
}else if(VI == "NDWI"){
    ggplot(data1, aes(doy, Prec_mm )) + 
        geom_col(data=data1, aes(doy, Prec_mm))+
        #geom_bar(stat = "identity") + #tells ggplot2 you'll provide the y-values for the barplot, rather than counting the aggregate number of rows for each x value
        geom_point(data =  data2, aes(doy, meanNDWI*100)) + 
        geom_line(data = data2 , aes(doy, meanNDWI*100)) +
        stat_smooth(data = data2 , aes(doy, meanNDWI*100), colour="red")+
        scale_x_continuous(breaks = seq(1, 365, by = 7))+  
        scale_y_continuous(breaks = seq(0, 100 , by= 10))+ #for Precipitation; 
        scale_y_continuous(sec.axis = sec_axis(~./100, name = "NDWI [-]"))+
        theme(text = element_text(size = 8),
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5))+
        xlab("doy") + 
        ylab("Precipitation [mm]") +
        labs(title = sprintf("NDWI and Precipitaion in %s ", site))+
        removeGrid(x = TRUE, y = FALSE)+
        #facet_grid(Year~site.x) 
        facet_wrap(~Year, ncol = 1)# vars(Year, site.x), ncol = 2  
}

ggsave(here(plot_dir, paste0(sprintf("precipitation_%s_%s_years", VI, tolower(site)), ".pdf")), 
       scale = 1, 
       #width = 15, 
       #height = 10,
       dpi = 300)

# NDVI(NDWI) vs. Evapotranspiration in years
# remember to change the "site"
x11()
site <-  "MFC2" #"GOR"#  
VI <- "NDWI"#"NDVI" #

if(site=="MFC2"){
    data1 <- meteo_df_mfcs_yrs
    data2 <- df_mfc2_four_yrs
} else {
    data1 <- meteo_df_gor_yrs
    data2 <- df_gor_four_yrs
}
if(VI == "NDVI"){ggplot(data1, aes(doy, ET0_mm )) + 
    geom_col(data=data1, aes(doy, ET0_mm))+
    #geom_bar(stat = "identity") + #tells ggplot2 you'll provide the y-values for the barplot, rather than counting the aggregate number of rows for each x value
    geom_point(data =  data2, aes(doy, meanNDVI*10)) + 
    geom_line(data = data2 , aes(doy, meanNDVI*10)) +
    stat_smooth(data = data2 , aes(doy, meanNDVI*10), colour="blue")+
    scale_x_continuous(breaks = seq(1, 365, by = 7))+  
    scale_y_continuous(breaks = seq(0, 10 , by= 1))+ #for Evapotranspiration; 
    scale_y_continuous(sec.axis = sec_axis(~./10, name = "NDVI [-]"))+
    theme(text = element_text(size = 8),
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5))+
    xlab("doy") + 
    ylab("Evapotranspiration [mm]") +
    labs(title = sprintf("%s and Evapotranspiration in %s ", VI, site))+
    removeGrid(x = TRUE, y = FALSE)+
    #facet_grid(Year~site.x) 
    facet_wrap(~Year, ncol = 1)# vars(Year, site.x), ncol = 2
}else if(VI == "NDWI"){ggplot(data1, aes(doy, ET0_mm )) + 
        geom_col(data=data1, aes(doy, ET0_mm))+
        #geom_bar(stat = "identity") + #tells ggplot2 you'll provide the y-values for the barplot, rather than counting the aggregate number of rows for each x value
        geom_point(data =  data2, aes(doy, meanNDWI*10)) + 
        geom_line(data = data2 , aes(doy, meanNDWI*10)) +
        stat_smooth(data = data2 , aes(doy, meanNDWI*10), colour="red")+
        scale_x_continuous(breaks = seq(1, 365, by = 7))+  
        scale_y_continuous(breaks = seq(0, 10 , by= 1))+ #for Evapotranspiration; 
        scale_y_continuous(sec.axis = sec_axis(~./10, name = "NDWI [-]"))+
        theme(text = element_text(size = 8),
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5))+
        xlab("doy") + 
        ylab("Evapotranspiration [mm]") +
        labs(title = sprintf("%s and Evapotranspiration in %s ", VI, site))+
        removeGrid(x = TRUE, y = FALSE)+
        #facet_grid(Year~site.x) 
        facet_wrap(~Year, ncol = 1)# vars(Year, site.x), ncol = 2
    
}

ggsave(here(plot_dir, paste0(sprintf("evapotranspiration_%s_%s_years", VI, tolower(site)), ".pdf")), 
       scale = 1, 
       #width = 15, 
       #height = 10,
       dpi = 300)    

# this gives a fun plot to look at 
# library(GGally)
# #df_ok <- filter(df_mfc2_four_yrs,Prec_mm< 1)
# plot_dir <- here("Desktop","Playground_dir_11", "plots")
# site <- "GOR1"# "MFC2"
# if(site=="MFC2"){
#     data <- df_mfc2_four_yrs
# } else {
#     data <- df_gor_four_yrs
# }

# here I save the dataframes to send them to Sarah
write.table(df_mfc2_four_yrs,
            file.path(here("Desktop", "dataframe_to_Sarah"),"mfc2_yrs.txt"), sep="\t",row.names=FALSE)

write.table(df_gor_four_yrs,
            file.path(here("Desktop", "dataframe_to_Sarah"),"gor1_yrs.txt"), sep="\t",row.names=FALSE)


### Correlation Coefficients with P-values appended to Scatter Plot #############################

# Add Correlation Coefficients with P-values to a Scatter Plot
library(ggpubr)


list_df_four_yrs[[1]]



# 
# # Group by hydrological seasons and correlation
# # Meteoparam vs. mean NDVI
# 
# method <- "spearman" #"pearson"
# 
# # change the parameter each time in the next line
# meteo_param <- "ET0_mm"  #"Prec_mm" #"T_Celsius"# #  #
# 
# #"param_name" is chosen and used in the title of plots & plot names
# if ( meteo_param == "T_Celsius") {
#     param_name <- "Temperature"
# } else if ( meteo_param == "Prec_mm") {
#     param_name <- "Precipitation"
# } else if ( meteo_param == "ET0_mm") {
#     param_name <- "Evapotranspiration"
# } 
# sp_1 <- ggscatter(rbind(list_df_four_yrs_factorized[[1]], list_df_four_yrs_factorized[[2]]) , x = meteo_param , y = "meanNDVI",#df_sites_four_yrs
#                        add = "reg.line",  # Add regressin line
#                        add.params = list(color = "black", fill = "lightgray"), # Customize reg. line
#                        color = "season",
#                        palette = "jco", 
#                        title=sprintf("Seasonal %s correlation coefficient & p-value for %s vs. NDVI", method, param_name),
#                        facet.by= c("site.x","Year"),#, "site.x"
#                        conf.int = FALSE # Add confidence interval
# ) 
# 
# # Add correlation coefficient
# sp_1 + stat_cor(aes(color = season), show.legend = FALSE, 
#                      method = method, label.x = 3)# label.x is the number of unique values in "season"
# 
# 
# ggsave(here(plot_dir, paste0(sprintf("Seasonal %s_ndvi_correlation_r_%s_sites_yrs", param_name, method), ".pdf")), 
#        scale = 2, 
#        #width = 15, 
#        #height = 10,
#        dpi = 300)
# 




# plot the correlation plot of dataframes 
ggpairs(data %>% select(ET0_mm, Prec_mm, meanNDVI), #df_mfc2_four_yrs
        title = site)#

ggsave(here(plot_dir, paste0(sprintf("evapo_precip_ndvi_%s_correlation", tolower(site)), ".pdf")), 
       scale = 1, 
       #width = 15, 
       #height = 10,
       dpi = 300)



# combine two plots 
# source :https://github.com/tidyverse/ggplot2/wiki/Align-two-plots-on-a-page


# subset the merged dataframe so that it has only specific columns
merge_df_gor_2019_subset <- subset(merge_df_gor_2019, 
                          select = -c(Month, Day, DATE, site.x, year, date, site.y))


# calculating correlation 
# method = c("pearson", "kendall", "spearman")
M <- cor(merge_df_gor_2019_subset)
corrplot(M, method = "circle")

M_pearson <- cor(merge_df_gor_2019_subset,
         method = "pearson")
corrplot(M_pearson, method = "number", # or "circle"
                    type = "upper")


res <- cor.test(merge_df_gor_2019_subset$meanNDVI, merge_df_gor_2019_subset$T_Celsius, 
         method=c("pearson", "kendall", "spearman"))

# Extract the p.value
res$p.value

# Extract the correlation coefficient
res$estimate



# Use chart.Correlation(): Draw scatter plots
chart.Correlation(merge_df_gor_2019_subset, 
                  histogram = TRUE, pch = 19)

