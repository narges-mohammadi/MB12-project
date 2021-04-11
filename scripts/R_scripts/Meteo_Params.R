#######
# The following code is for 
# Exploratory Data ploting & analysis of Meteorological Inputs
# of 2 study sites GOR & MFC2
########

meteo_data_to_df <- function(save_dir){
  #1: Load R packages
  ## Install & load packages
  pck <- (c("tidyr","rgdal","ggplot2","raster",
           "leaflet","rasterVis","gridExtra","RColorBrewer",
            "plotly","RStoolbox","sp","IRdisplay","reshape", 
            "here", "patchwork","readxl", "ggExtra","viridis"))

  new_pck <- pck[!pck %in% installed.packages()[,"Package"]]

  if(length(new_pck)){install.packages(new_pck)}

  sapply(pck , require, character.only=TRUE)

  # read the .xlsx file into R
  meteo_GOR <- read_xlsx(here("data", "Raw_data", "Meteorological_Data", 
                    "TABLE_ClimateData_MFC2_GOR1_2017_to_2020.xlsx"),  #GOR1_P_ET0.xls
                    col_names = c("Year", "Month", "Day", "Prec_mm", "T_Celsius", "ET0_mm", "DATE","DOY"),
                    range = "GOR1!A2:H1876" #cell_rows(2:1876)
                    )

  #"Budget!B2:G14"
  meteo_MFC2 <- read_xlsx(here("data", "Raw_data", "Meteorological_Data", 
                             "TABLE_ClimateData_MFC2_GOR1_2017_to_2020.xlsx"),  #MFC2_P_ET0.xls
                        col_names = c("Year", "Month", "Day", "Prec_mm", "T_Celsius", "ET0_mm", "DATE", "DOY"),
                        range = "MFC2!A2:H1749"
                        )


  # char_date  <-  function(x){
  #   if (x["Day"] < 10 ) 
  #     if (x["Month"] >= 10)
  #       return(gsub(" ", "",paste0(x["Year"], x["Month"], paste0(0,x["Day"]))))
  #   
  #   else 
  #     return(gsub(" ", "", paste0(x["Year"], paste0(0,x["Month"]), paste0(0,x["Day"]))))
  #   
  #   
  #   else if (x["Day"] >= 10 ) 
  #     if (x["Month"] >= 10)
  #       return(gsub(" ", "",paste0(x["Year"],x["Month"],x["Day"])))
  #   
  #   else
  #     return(gsub(" ", "", paste0(x["Year"], paste0(0,x["Month"]), x["Day"])))
  #   
  # }
  # 
 
  # char_to_doy <- function(x){
  #   return(as.numeric(strftime(lubridate::ymd(x["char_date"]),format = "%j")))
  # }

  # Add "char_date" column to dataframes (needed for DOY(next step))
  # meteo_GOR$char_date <- apply(meteo_GOR, 1, 
  #                              FUN=char_date)
  # 
  # meteo_MFC2$char_date <- apply(meteo_MFC2, 1, 
  #                               FUN=char_date)

  # Add "DOY" column to dataframes
  # meteo_GOR$DOY <- apply(meteo_GOR, 1, 
  #                        FUN=char_to_doy)
  #   
  # meteo_MFC2$DOY <- apply(meteo_MFC2, 1, 
  #                               FUN=char_to_doy)

  # Add "site" column to dataframes
  #meteo_GOR$site <- "GOR1"
  #meteo_MFC2$site <- "MFC2"

  # Add "site" column to '"tbl_df" "tbl" "data.frame"'
  meteo_GOR <- meteo_GOR %>% tibble::add_column(site="GOR1")
  meteo_MFC2 <- meteo_MFC2 %>% tibble::add_column(site="MFC2")

  # subset years(2017 to 2020)
  meteo_GOR <- subset(meteo_GOR, meteo_GOR$Year >= 2017 &  meteo_GOR$Year <= 2020)
  meteo_MFC2 <- subset(meteo_MFC2, meteo_MFC2$Year >= 2017 &  meteo_MFC2$Year <= 2020)

 # Combine 2 dfs into one
 #meteo_combi <- rbind(meteo_MFC2, meteo_GOR)

 # Combine 2 '"tbl_df" "tbl" "data.frame"'
 #meteo_combi <- dplyr::bind_rows(meteo_MFC2, meteo_GOR)

 # Save the dfs to the drive (the initial .xlsx file is now divided to 2 dataframes(for each site) and has a column identifying site name)
 saveRDS(meteo_GOR, file = file.path(save_dir, 
                                    paste0("meteorological_df_",meteo_GOR$site[1])))

 saveRDS(meteo_MFC2, file = file.path(save_dir, 
                                    paste0("meteorological_df_",meteo_MFC2$site[1])))

}

# # save directory
# save_dir <- here("data", "Augmented_data", "Playground_dir_11", "output")
# 
# # invoke function 
# meteo_data_to_df(save_dir)
# 
# meteo_GOR <- readRDS(file = file.path(save_dir, "meteorological_df_GOR1"
#                                         ))
# 
# meteo_MFC2 <- readRDS(file = file.path(save_dir, "meteorological_df_MFC2"
#                                      ))
# 
# ## Plots 
# list_parameter <- list("Temperature", "Precipitation", "Evapotranspiration")
# site_list <- list("MFC2", "GOR")
# list_meteo <- list(meteo_MFC2, meteo_GOR)
# 
# # Convert "Year" as a grouping variable
# list_meteo_factorized <- pbapply::pblapply(1:length(site_list), 
#                                                  function(x){
#                                                    list_meteo[[x]]$Year <- as.character(list_meteo[[x]]$Year);
#                                                    list_meteo[[x]]$Year <- factor(list_meteo[[x]]$Year, levels=c("2017", "2018", "2019", "2020"));
#                                                    list_meteo[[x]]$Month <- as.character(list_meteo[[x]]$Month);
#                                                    list_meteo[[x]]$Month <- factor(list_meteo[[x]]$Month, levels=c("1", "2", "3", "4", "5", "6",
#                                                                                                                    "7", "8", "9", "10", "11", "12"));
#                                                    return(list_meteo[[x]])
#                                                    
#                                                  })
# 
# 
# pbapply::pblapply(1:length(site_list), function(x) pbapply::pblapply(1:length(list_parameter), 
#                                                                    function(y) {
#                                                                     
#                                                                      
#                                                                      if(list_parameter[[y]] == "Temperature") y_axis_name <- "T_Celsius"
#                                                                      
#                                                                      else if(list_parameter[[y]] == "Precipitation") y_axis_name <- "Prec_mm"
#                                                                      
#                                                                      else if(list_parameter[[y]] == "Evapotranspiration") y_axis_name <- "ET0_mm" 
#                                                                      
#                                                                      ggplot(list_meteo_factorized[[x]], aes_string("DOY", y_axis_name, 
#                                                                                                         colour = "Year")) + 
#                                                                        geom_line()+
#                                                                        scale_color_viridis(discrete=TRUE, option = "cividis" , direction = -1)+# option="inferno"
#                                                                        scale_x_continuous(breaks = seq(1, 365, by = 7))+  
#                                                                        scale_y_continuous(breaks = seq(0, 100, by = 10))+
#                                                                        theme(text = element_text(size = 8),
#                                                                              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5))+
#                                                                        xlab("DOY") + 
#                                                                        ylab(sprintf("%s ", list_parameter[[y]])) +
#                                                                        labs(title = sprintf("%s near %s Site", 
#                                                                                             list_parameter[[y]],
#                                                                                             site_list[[x]]))+
#                                                                        ggExtra::removeGrid(x = TRUE, y = FALSE)+
#                                                                        #facet_wrap(~site,ncol = 1)
#                                                                        facet_wrap(~Year, ncol = 1)
#                                                                      
#                                                                      write_dir <- here("data", "Augmented_data", "Playground_dir_11","plots")
#                                                                      
#                                                                      ggsave(here(write_dir, paste0(sprintf("%s_%s", list_parameter[[y]], site_list[[x]]), ".pdf")), 
#                                                                             scale = 1,
#                                                                             width = 10,
#                                                                             height = 10,
#                                                                             dpi = 300
#                                                                      )
#                                                                      
#                                                                    }))
# 
# 
# # Boxplot
# pbapply::pblapply(1:length(site_list), 
#                   function(x) pbapply::pblapply(1:length(list_parameter), 
#                                                 function(y) {
#                                                   if(list_parameter[[y]] == "Temperature") y_axis_name <- "T_Celsius"
#                                                                        
#                                                    else if(list_parameter[[y]] == "Precipitation"){
#                                                      y_axis_name <- "Prec_mm"; 
#                                                      
#                                                      # to remove outliers from "precipitation" column in the boxplot
#                                                      library(dplyr)
#                                                    
#                                                      is_outlier <- function(z) {
#                                                        return(z < quantile(z, 0.25) - 1.5 * IQR(z) | z > quantile(z, 0.75) + 1.5 * IQR(z))
#                                                      }
#                                                    
#                                                      list_meteo_factorized[[x]] <- list_meteo_factorized[[x]] %>% 
#                                                                                       group_by(as.numeric(as.character(Month))) %>% 
#                                                                                             mutate(outlier = is_outlier(Prec_mm)) %>% 
#                                                                                                                     filter(outlier == FALSE) 
#                                                    }
#                                                    else if(list_parameter[[y]] == "Evapotranspiration") y_axis_name <- "ET0_mm"
#                                                      
#                                                 
#                                                    ggplot(list_meteo_factorized[[x]], aes_string("Month", y_axis_name)) + 
#                                                             geom_boxplot()+ #,outlier.shape = NA 
#                                                             ylab(sprintf("%s", list_parameter[[y]])) +
#                                                             labs(title = paste0(sprintf("Monthly %s near %s Site",
#                                                                                                      list_parameter[[y]],
#                                                                                                      site_list[[x]])," over years"))+
#                                                             theme(text = element_text(size = 20),
#                                                                                aspect.ratio= 12/16)+
#                                                             facet_wrap(~Year, ncol =  1)
#                                                                        
#                                                     write_dir <- here("data", "Augmented_data", "Playground_dir_11", "plots")
#                                                                        
#                                                     ggsave(here(write_dir, paste0(sprintf("Boxplot_monthly_%s_%s", 
#                                                                                           list_parameter[[y]],
#                                                                                           site_list[[x]]), ".pdf")), 
#                                                                 scale = 2,
#                                                                 width = 15,
#                                                                 height = 20,
#                                                                 dpi = 300
#                                                                 )
#                                                              
#                                                                        
#                                                                      }))

# # A small change in dataframe to have the month abbreviation 
# # instead of number of the month in plot
# meteo_MFC2$month_abb <- month.abb[meteo_MFC2$Month]
# meteo_GOR$month_abb <- month.abb[meteo_GOR$Month]
# meteo_combi$month_abb <- month.abb[meteo_combi$Month]


# temperature
# x11()
# site <-  meteo_GOR$site[1] # meteo_MFC2$site[1]
# ggplot(meteo_GOR, aes(month_abb, T_Celsius)) +
#   geom_boxplot(aes(month_abb, T_Celsius, group = cut_width(Month, 1))) +
#   labs(title = sprintf("Monthly Temperature near %s Site", site)) +
#   scale_x_discrete(limits = month.abb)+ # to order the months chronologically
#   xlab("month") + 
#   ylab("Temperature [°C]") +
#   facet_wrap(~Year,ncol = 1)
# 
# # boxplot(T_Celsius~Month, 
# #         data = meteo_MFC2)
#   
# write_dir <- here("Desktop", "Playground_dir_11","plots")
# ggsave(here(write_dir, paste0(sprintf("boxplot_monthly_temperature_%s", 
#                                       tolower(site)), 
#                                       "_years.pdf")), 
#        #scale = 3, 
#        dpi = 300) 


