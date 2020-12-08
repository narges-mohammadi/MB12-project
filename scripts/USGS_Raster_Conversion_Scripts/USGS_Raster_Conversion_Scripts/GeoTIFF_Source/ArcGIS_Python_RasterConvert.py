# // ***************************************************************************
# // *  ArcGIS_Python_RasterConvert.py
# // *  Use ArcGIS 10+ Python libraries to convert raster
# // *
# // *  last change or bug fix^: December 2012
# // ****************************************************************************/
# //
# // Released under the MIT License; see 
# // http^://www.opensource.org/licenses/mit-license.php 
# // or http^://en.wikipedia.org/wiki/MIT_License
# //
# // Permission is hereby granted, free of charge, to any person
# // obtaining a copy of this software and associated documentation
# // files ^(the "Software"^), to deal in the Software without
# // restriction, including without limitation the rights to use,
# // copy, modify, merge, publish, distribute, sublicense, and/or sell
# // copies of the Software, and to permit persons to whom the
# // Software is furnished to do so, subject to the following
# // conditions^:
# //
# // The above copyright notice and this permission notice shall be
# // included in all copies or substantial portions of the Software.
# //
# // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# // EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# // OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# // NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# // HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# // WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# // FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# // OTHER DEALINGS IN THE SOFTWARE.
# //
# //
# //*****************************************************************************
# //
# // Configuration/Development Notes^:
# //
# // 1^) Run python ArcGIS_Python_RasterConvert.py to obtain USAGE directions
# //
# //*****************************************************************************

try:
	# Import arcpy module
	import arcpy

	# Parameter 1 - Required - Input Dataset
	Input_Raster = arcpy.GetParameterAsText(0)
	if Input_Raster == '#' or not Input_Raster:
		raise Exception("ERROR: Missing Input Source Data")

	# Parameter 2 - Required - Output Raster
	Output_Raster_Dataset = arcpy.GetParameterAsText(1)
	if Output_Raster_Dataset == '#' or not Output_Raster_Dataset:
		raise Exception("ERROR: Missing Output Location")

	# Parameter 3 - Optional - Pyramid settings
	Pyramid = arcpy.GetParameterAsText(2)
	if Pyramid == '1':
		# All Pyramid levels, Nearest Neighbor sampling, LZ77 Compression, ignore compression factor..., Do not skip first level
		Pyramid = "PYRAMIDS -1 NEAREST LZ77 75 NO_SKIP"
	elif Pyramid == '2':
		# All Pyramid levels, Cubic Convolution sampling, LZ77 Compression, ignore compression factor..., Do not skip first level
		Pyramid = "PYRAMIDS -1 CUBIC LZ77 75 NO_SKIP"
	elif Pyramid == '3':
		# All Pyramid levels, Bilinear sampling, LZ77 Compression, ignore compression factor..., Do not skip first level
		Pyramid = "PYRAMIDS -1 BILINEAR LZ77 75 NO_SKIP"
	elif Pyramid == '4':
		# All Pyramid levels, Cubic Convolution sampling, Default Compression (JPEG or LZ77), 75% compression factor, Do not skip first level
		Pyramid = "PYRAMIDS -1 CUBIC DEFAULT 75 NO_SKIP"
	elif Pyramid == '5':
		# All Pyramid levels, Nearest Neighbor sampling, LZ77 Compression, ignore compression factor..., Do not skip first level
		Pyramid = "PYRAMIDS -1 NEAREST LZ77 75 NO_SKIP"
	elif Pyramid == '6':
		# All Pyramid levels, Cubic Convolution sampling, Default Compression (JPEG or LZ77), 75% compression factor, Skip first level
		Pyramid = "PYRAMIDS -1 CUBIC DEFAULT 75 SKIP_FIRST"
	elif Pyramid == '7':
		# All Pyramid levels, Nearest Neighbor sampling, LZ77 Compression, ignore compression factor..., Skip first level
		Pyramid = "PYRAMIDS -1 NEAREST LZ77 75 SKIP_FIRST"
	elif Pyramid == '8':
		# All Pyramid levels, Nearest Neighbor sampling, Default Compression (JPEG or LZ77), 75% compression factor, Skip first level
		Pyramid = "PYRAMIDS -1 BILINEAR DEFAULT 75 SKIP_FIRST"
	else:
		# No Pyramids - default value
	   Pyramid = "NONE"

	# Parameter 4 - Optional - Raster Data Storage Compression
	Compression = arcpy.GetParameterAsText(3)
	if Compression == '1':
		# JPEG Compression - 50%
		Compression = "'JPEG' 50"
	elif Compression == '2':
		# JPEG Compression - 60%
		Compression = "'JPEG' 60"
	elif Compression == '3':
		# JPEG Compression - 70%
		Compression = "'JPEG' 70"
	elif Compression == '4':
		# JPEG Compression - 80%
		Compression = "'JPEG' 80"
	elif Compression == '5':
		# JPEG Compression - 90%
		Compression = "'JPEG' 90"
	elif Compression == '6':
		# JPEG2000 Compression - 50%
		Compression = "'JPEG2000' 50"
	elif Compression == '7':
		# JPEG2000 Compression - 60%
		Compression = "'JPEG2000' 60"
	elif Compression == '8':
		# JPEG2000 Compression - 70%
		Compression = "'JPEG2000' 70"
	elif Compression == '9':
		# JPEG2000 Compression - 80%
		Compression = "'JPEG2000' 80"
	elif Compression == '10':
		# JPEG2000 Compression - 90%
		Compression = "'JPEG2000' 90"
	elif Compression == '11':
		# JPEG2000 Compression - 100%
		Compression = "'JPEG2000' 100"
	elif Compression == '12':
		# JPEG Compression - 100%
		Compression = "'JPEG' 100"
	elif Compression == '13':
		# RLE Compression
		Compression = "RLE"
	elif Compression == '14':
		# No compression
		Compression = "NONE"
	else:
		# LZ77 Compression - default value
	   Compression = "LZ77"

	# Process: Copy Raster - preserving environment settings for compression and pyramids
	tempEnvironment0 = arcpy.env.compression
	arcpy.env.compression = Compression
	tempEnvironment1 = arcpy.env.pyramid
	arcpy.env.pyramid = Pyramid
	arcpy.CopyRaster_management(Input_Raster, Output_Raster_Dataset, "", "", "", "NONE", "NONE", "", "NONE", "NONE")
	arcpy.env.compression = tempEnvironment0
	arcpy.env.pyramid = tempEnvironment1

except:
    print "ERROR: Convert Raster Failed!"
    print arcpy.GetMessages()

    print "USAGE:  python ArcGIS_Python_RasterConvert.py <Input Data Source> <Output Data Source> [Pyramids Settings] [Compression Settings]"
    print "  <Input Data Source> = This is the relative or full path to the "
    print "                        Source Data that will be converted."
    print "  <Output Data Source> = This is the relative or full path to the "
    print "                         output data that will be created."
    print "  [Pyramids Settings] = A number to indicate the settings for the "
    print "                        pyramids - May be any of the following:"
    print "                        1 - All levels, Nearest Neighbor, LZ77"
    print "                        2 - All levels, Cubic Convolution, LZ77"
    print "                        2 - All levels, Bilinear, LZ77"
    print "                        3 - All levels, Cubic Convolution, JPEG 75%-LZ77"
    print "                        4 - All levels, Nearest Neighbor, LZ77"
    print "                        5 - Skip First Level, Cubic Convolution, JPEG 75%-LZ77"
    print "                        6 - Skip First Level, Nearest Neighbor, LZ77"
    print "                        7 - Skip First Level, Nearest Neighbor, JPEG 75%-LZ77"
    print "                        [DEFAULT] - No Pyramids"
    print "  [Compression Settings] = A number to indicate the settings for the "
    print "                           compression - May be any of the following:"
    print "                           1 - JPEG Compression - 50%"
    print "                           2 - JPEG Compression - 60%"
    print "                           3 - JPEG Compression - 70%"
    print "                           4 - JPEG Compression - 80%"
    print "                           5 - JPEG Compression - 90%"
    print "                           6 - JPEG2000 Compression - 50%"
    print "                           7 - JPEG2000 Compression - 60%"
    print "                           8 - JPEG2000 Compression - 70%"
    print "                           9 - JPEG2000 Compression - 80%"
    print "                           10 - JPEG2000 Compression - 90%"
    print "                           11 - JPEG2000 Compression - 100%"
    print "                           12 - JPEG Compression - 100%"
    print "                           13 - RLE Compression"
    print "                           14 - No compression"
    print "                           [DEFAULT] - LZ77 Compression - default value"
