# To do: Read the downloaded .SAFE files into R and resample them

# Method 1: Using sen2r package:
s2_l2a_example <- file.path("C:/Users/sanaz/Documents/MB12-project/data/raster/sentinel2/",
                            "S2A_MSIL2A_20190806T095031_N0213_R079_T33TWE_20190806T114240.SAFE")
outdir <- "C:/Users/sanaz/Documents/MB12-project/data/raster/sentinel2/GeotiffFromSAFE/"
sen2r::s2_translate(infile = s2_l2a_example , outdir , format = "GTiff" )

# Method 2 :Using stars package


library(stars)
## Loading required package: abind
## Loading required package: sf
## Linking to GEOS 3.5.1, GDAL 2.2.1, proj.4 4.9.3
library(tibble)   # print
#url="C:\\Users\\sanaz\\Documents\\MB12-project\\data\\raster\\sentinel2\\S2A_MSIL2A_20190707T095031_N0212_R079_T33TWE_20190707T114200.SAFE"
#md = get_data(url, "md")


# install.packages("starsdata", repos = "http://pebesma.staff.ifgi.de", type = "source") 
library(stars)

#EPSG (for more info:https://forum.step.esa.int/t/epsg-code-of-sentinel-2-images/17787)

s2  <-"C:\\Users\\sanaz\\Documents\\MB12-project\\data\\raster\\sentinel2\\S2A_MSIL2A_20190816T095031_N0213_R079_T33TWE_20190816T124638.SAFE\\GRANULE\\L2A_T33TWE_A021669_20190816T095419\\IMG_DATA\\R10m"
#p  <-  read_stars(s2)#, proxy = TRUE , driver=NULL
#class(p)


library(rgdal)
library(rlist)
#s2a <- readGDAL("C:\\Users\\sanaz\\Documents\\MB12-project\\data\\raster\\sentinel2\\S2A_MSIL2A_20190816T095031_N0213_R079_T33TWE_20190816T124638.SAFE\\GRANULE\\L2A_T33TWE_A021669_20190816T095419\\IMG_DATA\\R10m\\T33TWE_20190816T095031_AOT_10m.jp2")


#List all files having ".jp2" extension
list<- list.files("C:\\Users\\sanaz\\Documents\\MB12-project\\data\\raster\\sentinel2\\S2A_MSIL2A_20190816T095031_N0213_R079_T33TWE_20190816T124638.SAFE\\GRANULE\\L2A_T33TWE_A021669_20190816T095419\\IMG_DATA\\R10m\\",pattern = ".jp2")


wd <- "C:\\Users\\sanaz\\Documents\\" 

new_list = c('a','b','c','d','e','f','g')#initialize the list
for (i in 1:length(list))
  new_list[i] <- paste0(wd,"MB12-project\\data\\raster\\sentinel2\\S2A_MSIL2A_20190816T095031_N0213_R079_T33TWE_20190816T124638.SAFE\\GRANULE\\L2A_T33TWE_A021669_20190816T095419\\IMG_DATA\\R10m\\",list[i])
#create Stack
stk<- raster::stack(new_list)

#save stacked image to yor hard drive
#writeRaster(stk, "Layerstack_im.tif", driver = "GTiff")


