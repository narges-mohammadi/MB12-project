
# "input_names" is of character class containing the names of VIs one instance 

# Following function converts the character to DOY
# This function must be loaded before calling the "NDWI_dfs_site_year" function
# sample form of x is : "20200507T095029"
char_to_doy <- function(x) {
  # Use of pipes
  DOY <- strsplit(x,"T")[[1]][1] %>%
    lubridate::ymd() %>%
    strftime(format = "%j") %>%
    as.numeric()
  
  return (DOY)
}

# each "input_names" parameter is made up of multiple names like: "NDWI_gor_S2B_MSIL2A_20181025T095059_N9999_R079_T33TWE_20210329T120906"

rename_sntl <- function(site, vi, input_names){

  if(vi == "NDWI"){
    if (site == "MFC2"){
  
      sntnlDates <- gsub("NDWI_mfc2_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                     "", 
                     input_names)
  
    }else{
  
      sntnlDates <- gsub("NDWI_gor_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                     "", 
                     input_names)
    }
  }else if(vi == "NDVI"){
    if (site == "MFC2"){
      
      sntnlDates <- gsub("NDVI_mfc2_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                         "", 
                         input_names)
      
    }else{
      
      sntnlDates <- gsub("NDVI_gor_S2[AB]_MSIL2A_|_N[[:digit:]]{4}_R[[:digit:]]{3}_T33TWE_[[:alnum:]]{15}", 
                         "", 
                         input_names)
    }
  }

  # Convert character dates in raster names  to DOY (used for plot)
  df_date <- as.data.frame(sntnlDates)
  out_names <- apply(df_date, 1, char_to_doy)
  
  return(out_names)
  
}

#input_names <- names(vi_stack[[1]])

#rename_sntl("GOR", input_names)
