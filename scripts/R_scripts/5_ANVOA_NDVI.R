##########################
# In this piece of code, ANalysis Of Variance(ANOVA) using aov()
# on NDVI and LAI is performed.
##########################
setwd("C:/Users/sanaz/")

#1: Load R packages
## Install & load packages
pck <- (c("tidyr","rgdal","ggplot2","raster","leaflet","rasterVis","gridExtra","RColorBrewer","plotly","RStoolbox","sp","IRdisplay","reshape","here","readr", "lubridate","dplyr"))
new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
if(length(new_pck)){install.packages(new_pck)}
sapply(pck , require, character.only=TRUE)

setwd("C:/Users/sanaz/Desktop/Playground_dir_3/NDVI_cropped")

ndvi_dataframe <- function(year, study_site) {
  site <- toupper(study_site)
  base_dir <- here("Desktop","Playground_dir_3","NDVI_cropped")
  ndvi_dir <- here("Desktop","Playground_dir_3","NDVI_cropped",site,year)
  ndvi_list <- list.files(ndvi_dir,recursive = TRUE, full.names = TRUE, pattern="^NDVI_")
  
  filenames <- list.files(path = base_dir, pattern = "*.Rds$", full.names = TRUE)
  
  if (year == 2017){
    select_10m <-readRDS(file = filenames[1])
  }
  else if (year == 2018){
    select_10m <-readRDS(file = filenames[2])  
  }
  else if(year == 2019){
    select_10m <-readRDS(file = filenames[3])
  }
  else if(year == 2020){
    select_10m <-readRDS(file = filenames[4])
  }
  
  # select tiles based on select_10m
  ndvi_list_df <- as.data.frame(ndvi_list)
  select_10m_df <- as.data.frame(select_10m)
  ndvi_list_selected <- cbind(ndvi_list_df , select_10m_df)
  ndvi_list_selected<- ndvi_list_selected %>% filter(select_10m == TRUE)
  ndvi_stack <- stack(ndvi_list_selected$ndvi_list)
  # Create a dataframe from ndvi_stack
  ndvi_stack_df <- as.data.frame(ndvi_stack, xy = TRUE) %>%
    melt(id.vars = c('x','y'))
  
  # Extract the acquisition date and add it to df as "date" column
  new_df_with_date <- ndvi_stack_df %>% 
    rowwise() %>% 
    mutate(date = as.Date(parse_date_time(strsplit(strsplit(as.character(variable), "_")[[1]][5],"T")[[1]][1],orders = "ymd" )))
  
  # Add "year" $ "month" columns to df 
  new_df_with_date$year <- year(new_df_with_date$date)
  new_df_with_date$month <- month(new_df_with_date$date)
  
  # Meteorological Seasons
  new_df_with_date <- new_df_with_date %>%
    mutate(
      season = case_when(
        month %in%  9:11 ~ "Fall",
        month %in%  c(12, 1, 2)  ~ "Winter",
        month %in%  3:5  ~ "Spring",
        TRUE ~ "Summer"))
  
  # Add the "site" column to the dataframe
  new_df_with_date$Site <- site
  
  return(new_df_with_date)
}

# Call the previously defined function to create the NDVI_df for ANOVA 
ndvi_2017_mfc2 <- ndvi_dataframe(2017,"mfc2")
ndvi_2018_mfc2 <- ndvi_dataframe(2018,"mfc2")
ndvi_2019_mfc2 <- ndvi_dataframe(2019,"mfc2")
ndvi_2020_mfc2 <- ndvi_dataframe(2020,"mfc2")

ndvi_2017_gor <- ndvi_dataframe(2017,"gor")
ndvi_2018_gor <- ndvi_dataframe(2018,"gor")
ndvi_2019_gor <- ndvi_dataframe(2019,"gor")
ndvi_2020_gor <- ndvi_dataframe(2020,"gor")


# Combine yearly ndvi dataframes into one 
ndvi_df_combi_mfc2 <- rbind(ndvi_2017_mfc2, ndvi_2018_mfc2, ndvi_2019_mfc2, ndvi_2020_mfc2)
ndvi_df_combi_gor <- rbind(ndvi_2017_gor, ndvi_2018_gor, ndvi_2019_gor, ndvi_2020_gor)

# Combine dfs of two study sites
ndvi_df_combi <- rbind(ndvi_df_combi_mfc2, ndvi_df_combi_gor)


# Before performing the ANOVA, visulize the data
plot(value~year, data=ndvi_df_combi_gor)#ndvi_df_combi_mfc2
boxplot(value~year , data = ndvi_df_combi_mfc2)

# I reorder the groups order : I change the order of the factor ndvi_df_combi$season
ndvi_df_combi$season <- factor(ndvi_df_combi$season , levels=c( "Spring", "Summer", "Fall", "Winter"))
boxplot(value~season, data = ndvi_df_combi)# seasonal on one year and one site


# Before ANOVA, compute descriptive statistics 
ndvi_df_combi_gor %>%
  group_by(year) %>% 
  summarise(mean = mean(value))

ndvi_df_combi_mfc2 %>%
  group_by(year) %>%
  summarise(median = median(value))

ndvi_df_combi%>%
  group_by(season) %>%
  summarise(median = median(value))



# ANOVA yearly(2017,2018,2019,2020)
res_aov <- aov(value~year, data = ndvi_df_combi_gor)

summary(res_aov)

# Test homogenity of the variance and the normality of the residuals 
plot(res_aov, which = 1) # : Homogenity

plot(res_aov, which = 2) # : Normality


# ANOVA comparison between 2 sites(GOR, MFC2)
res_aov_sites <- aov(value~Site, data = ndvi_df_combi)

summary(res_aov_sites)

# Test homogenity of the variance and the normality of the residuals 
plot(res_aov_sites, which = 1) # : Homogenity

plot(res_aov_sites, which = 2) # : Normality



# ANOVA comparison between different seasons
res_aov_seasons <- aov(value~season, data = ndvi_df_combi)

summary(res_aov_seasons)

# Test homogenity of the variance and the normality of the residuals 
plot(res_aov_seasons, which = 1) # : Homogenity

plot(res_aov_seasons, which = 2) # : Normality






# Manual process of creating the dataframes(w/o using function)

# Read the NDVIs in and stack them _ GOR 
#ndvi_dir <- here("Desktop","Playground_dir_3","NDVI_cropped","GOR","GOR_2017")
#ndvi_dir <- here("Desktop","Playground_dir_3","NDVI_cropped","GOR","GOR_2018")
#ndvi_dir <- here("Desktop","Playground_dir_3","NDVI_cropped","GOR","GOR_2019")

# Read the NDVIs in and stack them _ MFC_2 
#ndvi_dir <- here("Desktop","Playground_dir_3","NDVI_cropped","MFC_2","MFC2_2017")
#ndvi_dir <- here("Desktop","Playground_dir_3","NDVI_cropped","MFC_2","MFC2_2018")
ndvi_dir <- here("Desktop","Playground_dir_3","NDVI_cropped","MFC_2","MFC2_2019")



ndvi_list <- list.files(ndvi_dir,recursive = TRUE, full.names = TRUE, pattern="^NDVI_")

#Load the select_10m.Rds ("select_10m" based on "RGB_10m")
#select_10m <-readRDS(file = "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/L2A_2017/RGB/select10m.Rds")
#select_10m <-readRDS(file = "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/L2A_2018/RGB/select10m_2018.Rds")
select_10m <-readRDS(file = "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/L2A_2019/RGB/select10m_2019.Rds")



# select tiles based on select_10m
ndvi_list_df <- as.data.frame(ndvi_list)
select_10m_df <- as.data.frame(select_10m)
ndvi_list_selected <- cbind(ndvi_list_df , select_10m_df)
ndvi_list_selected<- ndvi_list_selected %>% filter(select_10m == TRUE)


ndvi_stack <- stack(ndvi_list_selected$ndvi_list)



# Create a dataframe from ndvi_stack
ndvi_stack_df <- as.data.frame(ndvi_stack, xy = TRUE) %>%
  melt(id.vars = c('x','y'))

# add a new column to dataframe indicating the year of NDVI
#ndvi_stack_df$year <-  "2017"
#ndvi_stack_df$year <- "2018"
ndvi_stack_df$year <- "2019"


#ndvi_stack_df_2017 <- ndvi_stack_df
#ndvi_stack_df_2018 <- ndvi_stack_df
ndvi_stack_df_2019 <- ndvi_stack_df



# Combine three ndvi dataframes into one 
#ndvi_df_combi_gor <- rbind(ndvi_stack_df_2017, ndvi_stack_df_2018, ndvi_stack_df_2019 )
ndvi_df_combi_mfc2 <- rbind(ndvi_stack_df_2017, ndvi_stack_df_2018, ndvi_stack_df_2019 )

# Add a new column indicating the name of study site
#ndvi_df_combi_gor$site <- "GOR"
ndvi_df_combi_mfc2$site <- "MFC2"


# Combine ndvi dataframes of two study sites
ndvi_df_combi <- rbind(ndvi_df_combi_gor, ndvi_df_combi_mfc2)




# Extract the acquisition date from each row of the dataframe
new_df_with_date <- ndvi_stack_df_2018 %>% 
                          rowwise() %>% 
                      mutate(date = as.Date(parse_date_time(strsplit(strsplit(as.character(variable), "_")[[1]][5],"T")[[1]][1],orders = "ymd" )))






# Before performing the ANOVA, visulize the data
plot(value~year, data=ndvi_df_combi_gor)#ndvi_df_combi_gor,ndvi_df_combi_mfc2
boxplot(value~year , data = ndvi_df_combi_gor)



# Before ANOVA, compute descriptive statistics 
ndvi_df_combi_gor %>%
  group_by(year) %>% 
  summarise(mean = mean(value))

ndvi_df_combi_gor %>%
  group_by(year) %>%
  summarise(median = median(value))#quantile(value)


# ANOVA yearly(2017,2018,2019,2020)
res_aov <- aov(value~year , data = ndvi_df_combi_gor)

summary(res_aov)

# Test homogenity of the variance and the normality of the residuals 
plot(res_aov, which=1) # : Homogenity

plot(res_aov, which=2) # : Normality


# ANOVA comparison between 2 sites(GOR, MFC2)
res_aov_sites <- aov(value~site , data = ndvi_df_combi)

summary(res_aov_sites)
