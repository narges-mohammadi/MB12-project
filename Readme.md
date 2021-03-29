## Introduction about study sites

The two experimental sites (MFC2 and GOR1) are located in the Upper Alento River Catchment (UARC) in Campania (southern Italy):

* MFC2 representative of the cropland zone of UARC with a co-existence of relatively sparse horticultural crops, olive, walnut, and cherry trees, 
    located near the village of Monteforte Cilento, on the south-facing hillslope of UARC.  

* GOR1 is representative of the woodland zone of UARC on the north-facing hillslope of UARC, located near the village of Gorga.


## Analysis

Analysis chain recieves L2A Sentinel-2 tiles from 2017 to 2020. 
It starts by unzipping tiles, then converting Jp2 bands to Gtiff, selecting tiles that have no cloud cover over two study areas, calculating Vegetation Indexes(NDVI & NDWI(Gao)).
Then calculating correlation coefficient (pearson) of VIs with meteorological parameters and Topographic Attributes for each study site.
Meteorological parameters including Temperature, Precipitation, Evapotranspiration were provided by Paolo Nasta which can be found in the data folder.


## 







[For more details on this project visit European Geosciences Union (EGU) website](https://blogs.egu.eu/divisions/hs/2020/12/02/featured-catchment-the-alento-hydrological-observatory-in-the-middle-of-the-mediterranean-region/?fbclid=IwAR2ZeiDsMvgiA-mFSMGo7fuptGc7FwzszJSLg3NHTVzhsJCWHmu4mBBiwtI)
