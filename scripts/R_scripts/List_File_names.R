
path_2017 <- "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/L2A_2017/"

list_names_2017 <- list.files(path_2017, pattern="*.SAFE", all.files=TRUE,
           full.names=FALSE)


path_2018 <- "D:/L2A_2018/"

list_names_2018 <- list.files(path_2018, pattern="*.zip", all.files=TRUE,
                              full.names=FALSE)



path_2019 <- "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/L2A_2019/"

list_names_2019 <- list.files(path_2019, pattern="*.SAFE", all.files=TRUE,
                              full.names=FALSE)

path_2020 <- "C:/Users/sanaz/Documents/MB12-project/CREODIAS_part/data_from_CREODIAS/L2A_2020/"

list_names_2020 <- list.files(path_2020, pattern="*.SAFE", all.files=TRUE,
                              full.names=FALSE)


library(tidyverse) 
df1 <- data.frame(stringsAsFactors = FALSE, case1 = list_names_2017) 
df2 <- data.frame(stringsAsFactors = FALSE, case1 = list_names_2018) 
df3 <- data.frame(stringsAsFactors = FALSE, case1 = list_names_2019)
df4 <- data.frame(stringsAsFactors = FALSE, case1 = list_names_2020)

df <- rbind(df1, df2, df3, df4)
df$s2_tile_names <- df$case1 
df$case1 <- NULL



write.csv(df,"C:/Users/sanaz/Desktop/s2_tile_names.csv", 
          row.names = FALSE)
