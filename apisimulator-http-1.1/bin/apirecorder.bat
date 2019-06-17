@echo off
@rem @echo on

@rem ---------------------------------------------------------------------------
@rem Start/Stop Script for an API Recorder
@rem Environment variables that can be set when this script is called:
@rem APIRECORDER_JAVA      Points at the JDK to use.
@rem TODO
@rem ---------------------------------------------------------------------------

if "%OS%" == "Windows_NT" Setlocal

@rem cd "%~dp0"
@rem set "THIS_SCRIPT_DIR=%cd%"
set "THIS_SCRIPT_DIR=%~dp0"

@rem This script is expected to be in 'bin' directory under the simulator's home directory
@rem cd "%THIS_SCRIPT_DIR%\.."
@rem set "APIRECORDER_HOME=%cd%"
set "APIRECORDER_HOME=%THIS_SCRIPT_DIR%\.."


if "%APIRECORDER_JAVA%"=="" set "APIRECORDER_JAVA=%JAVA_HOME%"
if "%APIRECORDER_JAVA%"=="" (
  @echo APIRECORDER_JAVA nor JAVA_HOME environment variables are set
  goto End
)


@rem set "APIRECORDER_CONFIG=%APIRECORDER_HOME%\config"
set "APIRECORDER_CONFIG=%APIRECORDER_HOME%\config"
if not exist "%APIRECORDER_CONFIG%" (
  @echo Simulation configuration directory "%APIRECORDER_CONFIG%" doesn't exist
  goto End
)


@REM TODO - "logs" directory doesn't exist for the recorder (not like for a simulation)
set "APIRECORDER_LOG_PATH=%APIRECORDER_HOME%\logs"
if not exist "%APIRECORDER_LOG_PATH%" (
  @echo Simulation logs directory "%APIRECORDER_LOG_PATH%" doesn't exist
  goto End
)

set "APIRECORDER_LOG_NAME=apirecorder.log"
set "APIRECORDER_OUT_NAME=apirecorder.out"

if ""%1"" == ""stop"" set "APIRECORDER_LOG_NAME=apirecorder-stop.log"
if ""%1"" == ""stop"" set "APIRECORDER_OUT_NAME=apirecorder-stop.out"

set "APIRECORDER_LOG=%APIRECORDER_LOG_PATH%\%APIRECORDER_LOG_NAME%"
set "APIRECORDER_OUT=%APIRECORDER_LOG_PATH%\%APIRECORDER_OUT_NAME%"

if "%APIRECORDER_LOG_FILE%"=="" set "APIRECORDER_LOG_FILE=apirecorder-log4j2.xml"

set "APIRECORDER_LOG_CONFIG=%APIRECORDER_CONFIG%\%APIRECORDER_LOG_FILE%"
if not exist "%APIRECORDER_LOG_CONFIG%" (
  set "APIRECORDER_LOG_CONFIG=%APIRECORDER_HOME%\config\%APIRECORDER_LOG_FILE%"
)

@rem No spaces in the log directory or log file names!! -Dlog4j.debug
set "APIRECORDER_LOG_ARGS=-Dlog4j.configurationFile=%APIRECORDER_LOG_CONFIG%"
set "APIRECORDER_LOG_ARGS=%APIRECORDER_LOG_ARGS% -DAPIRECORDER_LOG=%APIRECORDER_LOG% "


set "APIRECORDER_CP=%APIRECORDER_CONFIG%\*;%APIRECORDER_HOME%\lib\*"
set "CP=%CP%;%APIRECORDER_CP%"


if ""%1"" == ""start"" goto DoStart
if ""%1"" == ""stop"" goto DoStop

echo Usage:  %0% ( commands ... )
echo commands:
echo   start             Start API Recorder in a separate window
echo   stop              Stop API Recorder
goto end

:DoStart
shift
set CMD_LINE_ARGS=
:SetStartArgs
if ""%1""=="""" goto DoneSetStartArgs
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto SetStartArgs
:DoneSetStartArgs

if "%APIRECORDER_HEAP_SIZE%"=="" set "APIRECORDER_HEAP_SIZE=-Xms96m -Xmx96m"
set "APIRECORDER_OPTS=-server %APIRECORDER_OPTS% %APIRECORDER_HEAP_SIZE%"

if "%TITLE%" == "" set "TITLE=API Recorder"
start "%TITLE%" /min cmd /c ""%APIRECORDER_JAVA%\bin\java" %APIRECORDER_OPTS% -cp "%CP%" %APIRECORDER_LOG_ARGS% com.apisimulator.http.recorder.APIRecorder %CMD_LINE_ARGS% > %APIRECORDER_OUT% 2>&1" 
@rem start "%TITLE%" /min cmd /c ""%APIRECORDER_JAVA%\bin\java" %APIRECORDER_OPTS% -cp "%CP%" %APIRECORDER_LOG_ARGS% com.apisimulator.http.recorder.APIRecorder %CMD_LINE_ARGS% 2>&1" 
goto End

:DoStop
shift
set CMD_LINE_ARGS=
:SetStopArgs
if ""%1""=="""" goto DoneSetStopArgs
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto SetStopArgs
:DoneSetStopArgs

if "%APIRECORDER_HEAP_SIZE%"=="" set "APIRECORDER_HEAP_SIZE=-Xms64m -Xmx64m"
set "APIRECORDER_OPTS=%APIRECORDER_OPTS% %APIRECORDER_HEAP_SIZE%"

@rem "%APIRECORDER_JAVA%\bin\java" %APIRECORDER_OPTS% -cp "%CP%" %APIRECORDER_LOG_ARGS% com.apisimulator.http.recorder.APIRecorder -stop %CMD_LINE_ARGS% > %APIRECORDER_OUT% 2>&1
"%APIRECORDER_JAVA%\bin\java" %APIRECORDER_OPTS% -cp "%CP%" %APIRECORDER_LOG_ARGS% com.apisimulator.http.recorder.APIRecorder -stop %CMD_LINE_ARGS% 2>&1
goto End

:End
