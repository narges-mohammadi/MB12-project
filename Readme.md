## Introduction about study sites

The two experimental sites (MFC2 and GOR1) are located in the Upper Alento River Catchment (UARC) in Campania (southern Italy):

* The hydrological observatory MFC2 is representative of the cropland zone with a co-existence of relatively sparse horticultural crops, olive, walnut, and cherry trees, 
    located near the village of Monteforte Cilento, on the south-facing hillslope of UARC. 
     

* GOR1 is representative of the woodland zone of UARC on the north-facing hillslope of UARC, located near the village of Gorga. 
    At GOR1, the groundwater level is about 40 to 50 meters below the soil surface.

Characteristics of sites:

* MFC2: The soil is largely set on a regolith (matrix of silt and clay and a subordinate fraction of sand and gravel) above a turbidite argillaceous bedrock and is characterized 
    by a relatively low permeability.

* GOR1: The groundwater level is about 40 to 50 meters below the soil surface and is set on bedrock made up of turbidite sandstones with medium permeability, and mantled 
    by a regolith zone characterized by sand-silt mixtures.

[source](https://www.researchgate.net/publication/336830026_Integrating_ground-based_and_remote_sensing-based_monitoring_of_near-surface_soil_moisture_in_a_Mediterranean_environment?enrichId=rgreq-9bd52def02ebd432c5175c926ce98599-XXX&enrichSource=Y292ZXJQYWdlOzMzNjgzMDAyNjtBUzo4MTgyNTk3MTI1NDQ3NjhAMTU3MjA5OTcyNjA1NQ%3D%3D&el=1_x_2&_esc=publicationCoverPdf)


## Analysis

Analysis chain recieves L2A Sentinel-2 tiles from 2017 to 2020. It starts by unzipping tiles, moves on to converting Jp2 bands to Gtiff, selecting tiles that have no cloud cover over two study areas,
masking out man-made areas in MFC2 and calculating Vegetation Indexes (NDVI & NDWI). For NDVI B4 and B8 of S2 were used. NDWI[Normalized Difference Water Index](Gao) as a measure of liquid water in vegetation canopies was calculated using S2 B8a and B11.

Then calculating correlation coefficients (pearson) of VIs with meteorological parameters and Topographic Attributes for each study site.

Daily meteorological measurements including Temperature(°C), Precipitation(mm), Evapotranspiration(mm) were provided by Paolo Nasta which can be found in the data folder.

DEM and Topographic Attributes were provided by Dr. Sarah Schönbrodt-Stitt.


## Importance of analysis

The calculated VIs is going to be used in the hydrological models as additional features and their contribution will be evaluated.


## Discussion

* MFC2: 

* GOR1: 





[For more details on this project visit European Geosciences Union (EGU) website](https://blogs.egu.eu/divisions/hs/2020/12/02/featured-catchment-the-alento-hydrological-observatory-in-the-middle-of-the-mediterranean-region/?fbclid=IwAR2ZeiDsMvgiA-mFSMGo7fuptGc7FwzszJSLg3NHTVzhsJCWHmu4mBBiwtI)
