Usage of scripts is shown in "Final_script". Sentinel 2 data is downloaded from CREODIAS

The topographic attributes (TAs) were calculated using **DEM** [[1]](#1) in SAGA. Here is the list of used attributes [[2]](#2):

| TA                              | Description |
| -----------                     | ----------- |
| Slope                           | Slope gradient (often referred to as slope) is the angle between the tangent plane and the horizontal plane at a given point of the topographical surface. |
| Aspect                          | Aspect is a clockwise angle from north to a projection of the external normal to the horizontal plane at a given point of the Earth's surface        |
| DEM                             | Digital Elevation Model        |
| Terrain Ruggedness Index (TRI)  | Terrain ruggedness (roughness) is defined as the variability or irregularity in elevation (highs and lows) within a sampled terrain unit.      |
| Topographic Wetness Index (TWI) | An indicator for the potential water content and horizon depth of the soil |
| Profile Curvature               | Profile curvature is the curvature intersecting with the plane defined by the Z-axis and maximum gradient direction.       |
| Plan Curvature                  | Plan Curvature is the horizontal curvature, intersecting with the XY plane.        | 
| AAC                             | ---        |

Meteorological measurements including temperature, precipitation and evapotranspiration were also provided by Paolo Nasta. [Department of Agricultural Sciences, Division of Agricultural, Forest and Biosystems Engineering,University of Naples Federico II, Italy]

## Brief overview of study sites:

The Alento River Catchment (ARC) is situated in the Southern Apennines (Province of Salerno, Campania, Italy). The earth dam known as Piano della Rocca separates the Upper ARC (UARC) from the Lower ARC (LARC).

The two experimental sites (MFC2 and GOR1) are located in the UARC:

* MFC2 is representative of the cropland zone of UARC with a co-existence of relatively sparse horticultural crops, olive, walnut, and cherry trees, 
    located near the village of Monteforte Cilento, on the south-facing hillslope of UARC.  

* GOR1 is representative of the woodland zone of UARC on the north-facing hillslope of UARC, located near the village of Gorga.

[For more details about the study sites visit European Geosciences Union (EGU) website](https://blogs.egu.eu/divisions/hs/2020/12/02/featured-catchment-the-alento-hydrological-observatory-in-the-middle-of-the-mediterranean-region/?fbclid=IwAR2ZeiDsMvgiA-mFSMGo7fuptGc7FwzszJSLg3NHTVzhsJCWHmu4mBBiwtI)

### List of used packages:

**Handling**: [pbapply](https://github.com/psolymos/pbapply), [here](https://github.com/jennybc/here_here), [httr](https://github.com/r-lib/httr)

**Analysing**: [raster](https://github.com/rspatial/raster), [rgdal](https://github.com/cran/rgdal), [gdalUtils](https://github.com/cran/gdalUtils), [stats](), [arsenal](https://github.com/mayoverse/arsenal), [lubridate](https://github.com/tidyverse/lubridate)

**Plotting**: [ggplot2](https://github.com/tidyverse/ggplot2), [lattice](https://github.com/cran/lattice), [rasterVis](https://github.com/oscarperpinan/rastervis), [RStoolbox](https://github.com/bleutner/RStoolbox), [ggpubr](https://github.com/kassambara/ggpubr), [corrplot](https://github.com/taiyun/corrplot)

## References
<a id="1">[1]</a> 
Paolo Nasta, Mario Palladino, Nadia Ursino, Antonio Saracino, Angelo Sommella, Nunzio Romano (2017).  
Assessing long-term impact of land-use change on hydrological ecosystem functions in a Mediterranean upland agro-forestry catchment. 
Science of the Total Environment.

<a id="2">[2]</a> 
Calogero Schillaci, Andreas Braun and Jan Kropáček (2015).  
Terrain analysis and landform recognition. 
British Society for Geomorphology, Geomorphological Techniques, Chap. 2, Sec. 4.2.