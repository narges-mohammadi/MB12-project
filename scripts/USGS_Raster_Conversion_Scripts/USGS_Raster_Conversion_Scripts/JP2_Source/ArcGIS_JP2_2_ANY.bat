@ECHO OFF
REM // ***************************************************************************
REM // *  ArcGIS_JP2_2_ANY.bat
REM // *  Use ArcGIS Python to convert JP2 Downloads to Format specified by extension
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
REM // 1^) Run ArcGIS_JP2_2_ANY.bat to obtain USAGE directions
REM //
REM //*****************************************************************************

ECHO #===========================================================================
ECHO START ArcGIS_JP2_2_ANY.bat
ECHO #===========================================================================

REM initialize paramters to blanks
SET ArcGIS_JP2_2_ANY_SRC=
SET ArcGIS_JP2_2_ANY_OUTPUT=

REM Check the parameters passed in, there should be 1 or 2, but not 0.
IF /I "%1" EQU "" (
  REM No file name was passed in for the JP2 SRC, so print out the USAGE
  ECHO   ERROR^: Missing Input Parameter^(s^)^!
  ECHO.
  GOTO:BAT_DIRECTIONS
) ELSE (
  REM Now check the values of the parameters, First make sure source file exists
  IF NOT EXIST "%1" (
	REM JP2 SRC does not exist, so print out the USAGE
	ECHO   ERROR^: ^<JP2 Input File^> ^(%1^) does not exist^!
	ECHO.
	GOTO:BAT_DIRECTIONS
  ) ELSE (
    REM Source exists so set the ArcGIS_JP2_2_ANY_SRC
	SET ArcGIS_JP2_2_ANY_SRC=%1
	
    REM Now check for the output location
    IF /I "%2" EQU "" (
	  REM The output location was not specified, so attempt to make local output directory and set ArcGIS_JP2_2_ANY_OUTPUT
	  IF NOT EXIST ANY_Output\NUL (
	    REM Output Directory does not exist, so create it.
		MKDIR ANY_Output
	  ) ELSE (
	    IF EXIST ANY_Output\ArcGIS_JP2_2_ANY.bil (
			ECHO   ERROR^: The specified [Output File Name] ^(ANY_Output\ArcGIS_JP2_2_ANY.bil^) already exists^!
			ECHO.
			GOTO:BAT_DIRECTIONS
		)
	  )
      SET ArcGIS_JP2_2_ANY_OUTPUT=ANY_Output\ArcGIS_JP2_2_ANY.bil
	) ELSE (
	  REM Attempt to use parameter 2 for the output
	  IF EXIST "%2" (
	    ECHO   ERROR^: The specified [Output File Name] ^(%2^) already exists^!
		ECHO.
		GOTO:BAT_DIRECTIONS
	  ) ELSE (
	    SET ArcGIS_JP2_2_ANY_OUTPUT=%2
	  )
	)
  )
)


REM All the parameters are set, so now find the version of ArcGIS installed Python to call
REM NOTE: This is not pretty, but ArcGIS installs many copies of Python.exe using paths that vary per version and thus using a FOR loop to FIND
REM       the correct one is much more difficult than it needs to be.  So, a bunch of IF statements are used which means each version of ArcGIS
REM       needs to have a new one added.  Or the user must have the correct one added to the PATH environment variable (which takes privileged 
REM       user access - PR or admin account for most government users...)
IF EXIST "C:\Python27\ArcGIS10.3\python.exe" (
  ECHO "C:\Python27\ArcGIS10.3\python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
  CALL "C:\Python27\ArcGIS10.3\python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
) ELSE (
  IF EXIST "C:\Python27\ArcGIS10.2\python.exe" (
    ECHO "C:\Python27\ArcGIS10.2\python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
    CALL "C:\Python27\ArcGIS10.2\python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
  ) ELSE (
	IF EXIST "C:\Python27\ArcGIS10.1\python.exe" (
	  ECHO "C:\Python27\ArcGIS10.1\python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
	  CALL "C:\Python27\ArcGIS10.1\python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
	) ELSE (
	  IF EXIST "C:\Python26\ArcGIS10\python.exe" (
		ECHO "C:\Python26\ArcGIS10\python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
		CALL "C:\Python26\ArcGIS10\python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
	  ) ELSE (
		ECHO "python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
		CALL "python.exe" ArcGIS_Python_RasterConvert.py %ArcGIS_JP2_2_ANY_SRC% %ArcGIS_JP2_2_ANY_OUTPUT%
	  )
	)
  )
)

REM Skip the Directions if we got here
GOTO:End_BAT

REM Print out the USAGE directions
:BAT_DIRECTIONS
ECHO   USAGE^:  ArcGIS_JP2_2_^<JP2 Input File^> [Output File Name]
ECHO       ^<JP2 Input File^> = This is the relative or full path to the 
ECHO                                JP2 file that contains the source 
ECHO                                data.
ECHO       [Output File Name] = This is the relative or full path to the 
ECHO                            output file that will be created.  If 
ECHO                            this is not set, it will attempt to make 
ECHO                            a sub-folder under the current directory 
ECHO                            called ANY_Output, and a file in that 
ECHO                            folder called ArcGIS_JP2_2_ANY.bil.  The 
ECHO                            default format is BIL, but if a different
ECHO                            extension is specified then it will use the
ECHO                            format specified by the extension.
pause

REM finish the script...
:End_BAT
ECHO #===========================================================================
ECHO END ArcGIS_JP2_2_ANY.bat
ECHO #===========================================================================

