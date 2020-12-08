@ECHO OFF
REM // ***************************************************************************
REM // *  GDAL_ADF_2_DEM.bat
REM // *  Use GDAL to convert ArcGrid Downloads to DEM Format
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
REM // 1^) The gdal_translate.exe needs to be located at c^:\Program Files\GDAL\gdal_translate.exe
REM //    or be in the path.  If not, then the location of gdal_translate needs to be edited.
REM //
REM // 2^) Run GDAL_ADF_2_DEM.bat to obtain USAGE directions
REM //
REM //*****************************************************************************

ECHO #===========================================================================
ECHO START GDAL_ADF_2_DEM.bat
ECHO #===========================================================================

REM initialize paramters to blanks
SET GDAL_ADF_2_DEM_SRC=
SET GDAL_ADF_2_DEM_OUTPUT=

REM Check the parameters passed in, there should be 1 or 2, but not 0.
IF /I "%1" EQU "" (
  REM No file name was passed in for the ArcGrid SRC, so print out the USAGE
  ECHO   ERROR^: Missing Input Parameter^(s^)^!
  ECHO.
  GOTO:BAT_DIRECTIONS
) ELSE (
  REM Now check the values of the parameters, First make sure source file exists
  IF NOT EXIST "%1" (
	REM ArcGrid SRC does not exist, so print out the USAGE
	ECHO   ERROR^: ^<ArcGrid Input Dir^> ^(%1^) does not exist^!
	ECHO.
	GOTO:BAT_DIRECTIONS
  ) ELSE (
    REM Source exists so set the GDAL_ADF_2_DEM_SRC
	SET GDAL_ADF_2_DEM_SRC=%1
	
    REM Now check for the output location
    IF /I "%2" EQU "" (
	  REM The output location was not specified, so attempt to make local output directory and set GDAL_ADF_2_DEM_OUTPUT
	  IF NOT EXIST DEM_Output\NUL (
	    REM Output Directory does not exist, so create it.
		MKDIR DEM_Output
	  ) ELSE (
	    IF EXIST DEM_Output\GDAL_ADF_2_DEM.dem (
			ECHO   ERROR^: The specified [Output DEM File Name] ^(DEM_Output\GDAL_ADF_2_DEM.dem^) already exists^!
			ECHO.
			GOTO:BAT_DIRECTIONS
		)
	  )
      SET GDAL_ADF_2_DEM_OUTPUT=DEM_Output\GDAL_ADF_2_DEM.dem
	) ELSE (
	  REM Attempt to use parameter 2 for the output
	  IF EXIST "%2" (
	    ECHO   ERROR^: The specified [Output DEM File Name] ^(%2^) already exists^!
		ECHO.
		GOTO:BAT_DIRECTIONS
	  ) ELSE (
	    SET GDAL_ADF_2_DEM_OUTPUT=%2
	  )
	)
  )
)

REM All the parameters are set, so now call gdal_translate with the parameters
IF EXIST "c:\Program Files\GDAL\gdal_translate.exe" (
  ECHO "c:\Program Files\GDAL\gdal_translate.exe" -of USGSDEM %GDAL_ADF_2_DEM_SRC% %GDAL_ADF_2_DEM_OUTPUT%
  CALL "c:\Program Files\GDAL\gdal_translate.exe" -of USGSDEM %GDAL_ADF_2_DEM_SRC% %GDAL_ADF_2_DEM_OUTPUT%
) ELSE (
  ECHO "gdal_translate.exe" -of USGSDEM %GDAL_ADF_2_DEM_SRC% %GDAL_ADF_2_DEM_OUTPUT%
  CALL "gdal_translate.exe" -of USGSDEM %GDAL_ADF_2_DEM_SRC% %GDAL_ADF_2_DEM_OUTPUT%
)

REM Skip the Directions if we got here
GOTO:End_BAT

REM Print out the USAGE directions
:BAT_DIRECTIONS
ECHO   USAGE^:  GDAL_ADF_2_DEM ^<ArcGrid Input Dir^> [Output DEM File Name]
ECHO       ^<ArcGrid Input Dir^> = This is the relative or full path to the 
ECHO                                ArcGrid file that contains the ArcGrid 
ECHO                                data.
ECHO       [Output DEM File Name] = This is the relative or full path to the 
ECHO                                DEM output file that will be created.  If 
ECHO                                this is not set, it will attempt to make 
ECHO                                a sub-folder under the current directory 
ECHO                                called DEM_Output, and a file in that 
ECHO                                folder called GDAL_ADF_2_DEM.dem.
pause

REM finish the script...
:End_BAT
ECHO ************
ECHO ************
ECHO   WARNING^: DEM format rounds elevation values to integers^!^!^!
ECHO ************
ECHO ************
ECHO #===========================================================================
ECHO END GDAL_ADF_2_DEM.bat
ECHO #===========================================================================

