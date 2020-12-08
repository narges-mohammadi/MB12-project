#source : https://github.com/sentinel-hub/custom-scripts/blob/master/sentinel-2/lai/script.js

#source : https://step.esa.int/docs/extra/ATBD_S2ToolBox_L2B_V1.1.pdf; page:39
 #X* = 2*(X-XMin)/(XMax-XMin)-1
 #Where X* is the normalized input, X the original value, Xmin and Xmax respectively the minimum and maximum values.

#Resampling in R : consider using raster::resample 
# https://csaybar.github.io/blog/2018/12/05/resample/

# To do: Read the downloaded .SAFE files into R and resample them  then feed
# them to the following function to calculate the LAI
s2_l2a_example <- file.path("C:/Users/sanaz/Documents/MB12-project/data/raster/sentinel2/",
                            "S2A_MSIL2A_20190806T095031_N0213_R079_T33TWE_20190806T114240.SAFE")
outdir <- "C:/Users/sanaz/Documents/MB12-project/data/raster/sentinel2/GeotiffFromSAFE/"
sen2r::s2_translate(infile = s2_l2a_example , outdir , format = "GTiff" )


# open raster data
library(raster)
# address type is from my ubuntu subsystem
resampled_ras = raster("/mnt/c/Users/sanaz/Documents/MB12-project/data/raster/S2_geotiff/test_dir/T33TWE_20190816T095031_B02_20m_resampled.tiff")

wd <- setwd("/mnt/c/Users/sanaz/Documents/MB12-project/data/raster/S2_geotiff/test_dir/")

#pattern = "*.tiff$" - filters for main raster files only and skips any associated files (e.g. world files)
rast_list <- list.files(wd , pattern = "*.tiff$")

#create a raster stack from the input raster files 
s <- raster::stack(paste0(wd, "/", rast_list))

degToRad <-  pi / 180


evaluatePixelOrig <- function(s) {
    sample   <- samples[0]
    b03_norm   <- normalize(s[[2]], 0, 0.253061520471542)  
    b04_norm   <- normalize(s[[3]], 0, 0.290393577911328)  
    b05_norm   <- normalize(s[[4]], 0, 0.305398915248555)  
    b06_norm   <- normalize(s[[5]], 0.006637972542253, 0.608900395797889)  
    b07_norm   <- normalize(s[[6]], 0.013972727018939, 0.753827384322927)  
    b8a_norm   <- normalize(s[[7]], 0.026690138082061, 0.782011770669178)  
    b11_norm   <- normalize(s[[8]], 0.016388074192258, 0.493761397883092)  
    b12_norm   <- normalize(s[[9]], 0, 0.493025984460231)  
    #the problem here is that I could not find the following 3 bands for the L2A data
    viewZen_norm   <- normalize(cos(sample.viewZenithMean * degToRad), 0.918595400582046, 1)  
    sunZen_norm    <- normalize(cos(sample.sunZenithAngles * degToRad), 0.342022871159208, 0.936206429175402)  
    relAzim_norm   <- cos((sample.sunAzimuthAngles - sample.viewAzimuthMean) * degToRad)
  
    n1   <- neuron1(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm)  
    n2   <- neuron2(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm)  
    n3   <- neuron3(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm)  
    n4   <- neuron4(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm)  
    n5   <- neuron5(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm)  
  
    l2   <- layer2(n1, n2, n3, n4, n5)  
  
    lai  <-  denormalize(l2, 0.000319182538301, 14.4675094548151)
    return(lai/3)
    
  # return {
  #   default: [lai / 3]
  # }
}

neuron1 <- function(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm) {
    sum   <-
          + 4.96238030555279
          - 0.023406878966470 * b03_norm
          + 0.921655164636366 * b04_norm
          + 0.135576544080099 * b05_norm
          - 1.938331472397950 * b06_norm
          - 3.342495816122680 * b07_norm
          + 0.902277648009576 * b8a_norm
          + 0.205363538258614 * b11_norm
          - 0.040607844721716 * b12_norm
          - 0.083196409727092 * viewZen_norm
          + 0.260029270773809 * sunZen_norm
          + 0.284761567218845 * relAzim_norm   
  
  return (tansig(sum))
}

neuron2 <- function(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm) {
     sum   <-
          + 1.416008443981500
          - 0.132555480856684 * b03_norm
          - 0.139574837333540 * b04_norm
          - 1.014606016898920 * b05_norm
          - 1.330890038649270 * b06_norm
          + 0.031730624503341 * b07_norm
          - 1.433583541317050 * b8a_norm
          - 0.959637898574699 * b11_norm
          + 1.133115706551000 * b12_norm
          + 0.216603876541632 * viewZen_norm
          + 0.410652303762839 * sunZen_norm
          + 0.064760155543506 * relAzim_norm   
  
  return(tansig(sum))
}

neuron3 <- function(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm) {
    sum <- 
        + 1.075897047213310
        + 0.086015977724868 * b03_norm
        + 0.616648776881434 * b04_norm
        + 0.678003876446556 * b05_norm
        + 0.141102398644968 * b06_norm
        - 0.096682206883546 * b07_norm
        - 1.128832638862200 * b8a_norm
        + 0.302189102741375 * b11_norm
        + 0.434494937299725 * b12_norm
        - 0.021903699490589 * viewZen_norm
        - 0.228492476802263 * sunZen_norm
        - 0.039460537589826 * relAzim_norm  
  
  return(tansig(sum))
}

neuron4 <- function(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm) {
    sum <- 
        + 1.533988264655420
        - 0.109366593670404 * b03_norm
        - 0.071046262972729 * b04_norm
        + 0.064582411478320 * b05_norm
        + 2.906325236823160 * b06_norm
        - 0.673873108979163 * b07_norm
        - 3.838051868280840 * b8a_norm
        + 1.695979344531530 * b11_norm
        + 0.046950296081713 * b12_norm
        - 0.049709652688365 * viewZen_norm
        + 0.021829545430994 * sunZen_norm
        + 0.057483827104091 * relAzim_norm  
  
  return(tansig(sum))
}

neuron5 <- function(b03_norm,b04_norm,b05_norm,b06_norm,b07_norm,b8a_norm,b11_norm,b12_norm, viewZen_norm,sunZen_norm,relAzim_norm) {
    sum <- 
        + 3.024115930757230
        - 0.089939416159969 * b03_norm
        + 0.175395483106147 * b04_norm
        - 0.081847329172620 * b05_norm
        + 2.219895367487790 * b06_norm
        + 1.713873975136850 * b07_norm
        + 0.713069186099534 * b8a_norm
        + 0.138970813499201 * b11_norm
        - 0.060771761518025 * b12_norm
        + 0.124263341255473 * viewZen_norm
        + 0.210086140404351 * sunZen_norm
        - 0.183878138700341 * relAzim_norm  
  
  return(tansig(sum))
}

layer2 <- function(neuron1, neuron2, neuron3, neuron4, neuron5) {
      sum   <-
        + 1.096963107077220
        - 1.500135489728730 * neuron1
        - 0.096283269121503 * neuron2
        - 0.194935930577094 * neuron3
        - 0.352305895755591 * neuron4
        + 0.075107415847473 * neuron5  
  
  return(sum)
}



normalize <- function(x,x_min,x_max){
  x_norm   <- 2 * (x - x_min) / (x_max - x_min) - 1
  return(x_norm)
}

denormalize <- function(x_norm,x_min,x_max){
  x_denorm   <- 0.5 * (x_norm + 1) *(x_max - x_min) + x_min
  return(x_denorm)
}

tansig <- function(input){
  output <- (2 / (1 + exp(-2 * input)) - 1)
  return(output)
}



