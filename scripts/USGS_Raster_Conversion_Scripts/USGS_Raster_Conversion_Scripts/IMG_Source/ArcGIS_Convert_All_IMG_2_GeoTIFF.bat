@ECHO OFF
REM // ***************************************************************************
REM // *  ArcGIS_Convert_All_IMG_2_GeoTIFF.bat
REM // *  Recursively Scans directory for GeoTIFF files and runs ArcGIS_IMG_2_ANY on all
REM // *  The IMG will be put in the same directory as the GeoTIFF file
REM // *
REM // *  last change or bug fix^: December 2012
REM // ****************************************************************************/
REM //
REM // Released under the MIT License; see 
REM // http^://www.opensource.org/licenses/mit-license.php 
REM // or http^://en.wikipedia.org/wiki/MIT_License
REM //
REM // Permission is hereby granted, free of charge, to any person
REM // obtaining a copy of this software and associated documentation
REM // files ^(the "Software"^), to deal in the Software without
REM // restriction, including without limitation the rights to use,
REM // copy, modify, merge, publish, distribute, sublicense, and/or sell
REM // copies of the Software, and to permit persons to whom the
REM // Software is furnished to do so, subject to the following
REM // conditions^:
REM //
REM // The above copyright notice and this permission notice shall be
REM // included in all copies or substantial portions of the Software.
REM //
REM // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
REM // EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
REM // OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
REM // NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
REM // HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
REM // WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
REM // FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
REM // OTHER DEALINGS IN THE SOFTWARE.
REM //
REM //
REM //*****************************************************************************
REM //
REM // Configuration/Development Notes^:
REM //
REM // 1^) Run ArcGIS_Convert_All_IMG_2_GeoTIFF.bat to obtain USAGE directions
REM //
REM //*****************************************************************************

ECHO #===========================================================================
ECHO START ArcGIS_Convert_All_IMG_2_GeoTIFF.bat
ECHO #===========================================================================

REM Check the parameters passed in, there should be 1 or 2, but not 0.
IF /I "%1" EQU "" (
  REM No file name was passed in for the IMG SRC, so print out the USAGE
  ECHO   ERROR^: Missing the parameter for ^<Dir of IMG Files^>^!
  ECHO.
  GOTO:BAT_DIRECTIONS
)

REM recursively search for all GeoTIFF files in the input directory
FOR /R %1 %%A IN (*.img) DO (
  IF NOT EXIST %%~dA%%~pA..\ArcGIS_IMG_2_ANY.tif (
    REM This directory has not been processed, so create the output
	ECHO CALL ArcGIS_IMG_2_ANY.bat %%A %%~dA%%~pA.\ArcGIS_IMG_2_ANY.tif
	CALL ArcGIS_IMG_2_ANY.bat %%A %%~dA%%~pA.\ArcGIS_IMG_2_ANY.tif
  )
)

REM Skip the Directions if we got here
GOTO:End_BAT

REM Print out the USAGE directions
:BAT_DIRECTIONS
ECHO   USAGE^:  ArcGIS_Convert_All_IMG_2_GeoTIFF ^<Dir of IMG Files^>
ECHO       ^<Dir of IMG Files^> = This is the relative or full path to the 
ECHO                                directory of the IMG files that contain 
ECHO                                the source data.  It will scan
ECHO                                sub-folders recursively and produce GeoTIFF
ECHO                                files in the same folder as the IMG files.
pause

REM finish the script...
:End_BAT
ECHO #===========================================================================
ECHO END ArcGIS_Convert_All_IMG_2_GeoTIFF.bat
ECHO #===========================================================================

