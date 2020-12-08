Example walkthroughs of common work flows are provided in the How_To folder.  Please review the HTML documentation in that folder for more information about these scripts.

The batch files provided here are meant to make it easy to convert the TNM Raster Staged Products from the current Download formats into other common formats.

Scripts prefaced by GDAL_ use the Open Source Geospatial Data Abstraction Library (http://www.gdal.org/) or GDAL to convert data from the downloaded format to others.  GDAL is available from the main GDAL site, or packaged in some other software like FWTools, and GRASS.  Any version that is 1.7.1 (Released February 2010) or newer should work with these scripts.  If GDAL is not in the path, or is not in C:\Program Files\GDAL, then the script will need to be edited to adjust the location of the gdal_translate.exe.

Scripts preface by ArcGIS_ use the ArcGIS 10 or newer Python libraries to convert the data from the download format to other formats.  ArcGIS should be installed with the default locations of Python (C:\Python26\ArcGIS10.0 or C:\Python27\ArcGIS10.1) or the ArcGIS version of Python needs to be in the path.

These will work on the command line or by dragging and dropping the source data onto the batch files.  Scripts dealing with ArcGrid (ADF) data or converting all data use folders, while GridFloat (FLT) scripts need the actual FLT file as input.

