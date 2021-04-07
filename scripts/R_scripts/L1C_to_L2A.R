
# This script invokes "Sen2Cor" from R to convert L1C sentinel2 tiles to L2A
setwd("C:/Users/sanaz/")


# path of folder containing "L1C" data
inFolder <-  here("Desktop", "Playground_dir_16", "L1C_2018")

# path of folder where "L2A" should be saved
outFolder <-  here("Desktop", "Playground_dir_16", "L2A_2018")

# Insert the path where "Sen2Cor" is installed in computer
L2A_process_path <-  here("Documents",  "Sen2Cor-02.08.00-win64", "L2A_Process.bat ")


L1c2L2a<- function(inFolder, L2A_process_path, outFolder){

    #1: Load R packages
    ## Install & load packages
    pck <- (c("here","pbapply"))
    
    new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
    
    if(length(new_pck)){install.packages(new_pck)}
    
    sapply(pck , require, character.only=TRUE)
    
    # Find the absolute path of L1C tiles  
    l1c_path <- list.files(inFolder,
                                recursive = FALSE, 
                                full.names = TRUE,
                                pattern = "S2[AB]_MSIL1C_[[:alnum:]]{15}_[[:alnum:]]{5}_[[:alnum:]]{4}_[[:alnum:]]{6}_[[:alnum:]]{15}.SAFE")
    
    # Convert the path names(characters) to list so that it can be used with "lapply" instead of for loop
    l1c_path_list <- as.list(l1c_path)

    # Convert L1c to L2a by calling the "L2A_Process.bat" of Sen2Cor
    pbapply::pblapply(1:length(l1c_path_list), function(x) { 
                
                # create the command structure 
                cmd <- paste0(L2A_process_path, l1c_path_list[x], " --output_dir ", outFolder)
                
                # execute the command 
                shell(cmd)
                                                                   })
}

# for structure of the previous "lapply" 
# for (file in list_l1c_path){
#     
#     print(file)
#     
#     print("Reading image:")
#     
#     print('Applying atmoshphheric correction with sen2cor')
#     
#     # insert the path where "Sen2Cor" is installed in computer
#     L2A_process_path <-  here("Documents",  "Sen2Cor-02.08.00-win64", "L2A_Process.bat ")
#     
#     cmd <- paste0(L2A_process_path, file, " --output_dir ", outFolder)
#     
#     print(cmd)
#     
#     shell(cmd)
#     
# }






