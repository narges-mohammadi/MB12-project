
# This script converts the python script provided in 
# "https://creodias.eu/forum/-/message_boards/message/150362?_19_redirect=https%3A%2F%2Fcreodias.eu%2Fknowledgebase%3Fp_p_id%3D3%26p_p_lifecycle%3D0%26p_p_state%3Dmaximized%26p_p_mode%3Dview%26_3_redirect%3D%252Fknowledgebase%253Fp_p_id%253D3%2526p_p_lifecycle%253D0%2526p_p_state%253Dnormal%2526p_p_mode%253Dview%2526_3_groupId%253D0%26_3_keywords%3Ddownload%2Bthe%2Bordered%2Bproducts%2Busing%2BCLI%2Bby%2BFinder%2BAPI%26_3_groupId%3D0%26_3_struts_action%3D%252Fsearch%252Fsearch"
# into R 

library(httr)
library(here)

# This function gets token from "creodias" by providing it username and password

get_keycloak_token <- function(username, password){
  
  ## Install & load packages
  pck <- (c("httr"))
  
  new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
  
  if(length(new_pck)){install.packages(new_pck)}
  
  sapply(pck , require, character.only=TRUE)
  
  # the following response has "token_access" within
  post_req <- httr::POST(
    
    url = "https://auth.creodias.eu/auth/realms/DIAS/protocol/openid-connect/token",
    
    body = list(client_id = "CLOUDFERRO_PUBLIC", username = username, password = password, grant_type = "password"),
    
    encode = "form",  # in case of ("application/x-www-form-urlencoded")
    
    verbose()
  )
  
  #print(post_req$status_code)
  
  # retrieve contents of request to be able to extract "token_access" 
  content_post_req <- httr::content(post_req)
  
  err_msg <- function(){
   
     print("Can't obtain a token (check username/password), exiting.")
    
     quit()
  }
  
  token <- tryCatch(
    {
      content_post_req['access_token']
    },
    
    error = function(e){
      
      err_msg()
    
      }
  )
  
  return(token)
  
}

# Here insert your credentials from creodias
username <- "YOUR CREODIAS USERNAME HERE"

password <- "YOUR CREODIAS PASSWORD HERE"

# call the function with your specific username & pass to have a valid token
#creodias_token  <- get_keycloak_token(username, password)

# The 'finder_api_url' is "Rest query" created after specifying search criteria in "https://finder.creodias.eu/";
# one should visit the website, search for the product and copy the content of "Rest query" to the following line

#finder_api_url = 'https://finder.creodias.eu/resto/api/collections/Sentinel2/search.json?maxRecords=10&startDate=2021-04-01T00%3A00%3A00Z&completionDate=2021-04-07T23%3A59%3A59Z&cloudCover=%5B0%2C80%5D&processingLevel=LEVEL1C&geometry=POLYGON((14.900562186990717+40.62231989565893%2C14.936503116659681+40.597907191371405%2C14.95920265118745+40.63380514092955%2C14.900562186990717+40.62231989565893))&sortParam=startDate&sortOrder=descending&status=all&dataset=ESA-DATASET'

# specify where the files should be saved on drive in "download_path"

#download_path <- here::here("CREODIAS_part", "data_from_CREODIAS")

download_creodias <- function(username, password, finder_api_url, download_path){
  
  ## Install & load packages
  pck <- (c("httr"))# "rkt" : for time series analysis
  
  new_pck <- pck[!pck %in% installed.packages()[,"Package"]]
  
  if(length(new_pck)){install.packages(new_pck)}
  
  sapply(pck , require, character.only=TRUE)
  
  
  response <-  httr::GET(url = finder_api_url)

  # Retrieve contents of "response" to be able to extract "download url" from it  
  content_response <- httr::content(x = response)

  #print(content_response)

  for(feature in content_response$features){
  
    token  <- get_keycloak_token(username, password)
  
    download_url <-  feature$properties$services$download$url #feature['properties']['services']['download']['url']
  
    download_url <-  paste0(download_url, '?token=', token)
  
    #total_size <-  feature$properties$services$download$size
    
    # Extract "title" of the file to use in creating the "filename"
    title <-  feature$properties$title
  
    filename  <-  paste0(title, '.zip')
  
    #print(paste0('downloading: ', filename))
  
    # Create the exact "path" where the files should be written down
    path <- file.path(download_path, filename)
  
    # Download the file(s)
    r  <-  httr::GET(url = download_url,  
                    #verbose(), 
                    progress(), 
                    write_disk(path, overwrite = TRUE)
                    )

  }
}

# invoke the function with parameters
#download_creodias(username, password, finder_api_url, download_path)
