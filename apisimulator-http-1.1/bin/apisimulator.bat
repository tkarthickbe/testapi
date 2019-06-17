@echo off
@rem @echo on
@rem ---------------------------------------------------------------------------
@rem Start/Stop Script for API Simulator instances
@rem ---------------------------------------------------------------------------

if "%OS%" == "Windows_NT" Setlocal

if ""%1"" == ""init"" (
  if ""%2""=="""" goto MissingSimulationPathArgument

  if exist "%2" (
    echo Directory "%2" exists already. It will not be overwriten. Exiting...
    goto End
  )
  
  echo Initializing the simulation's directory structure...
  mkdir "%2"
  pushd "%2"
  
  md simlets\_default
  
  (
    echo response:
    echo   from: stub
    echo   status: 404
    echo   headers:
    echo   - "Content-Type: application/text; charset=UTF-8"
    echo   body: "API Simulator couldn't find a matching simlet for the request."
  ) > simlets\_default\simlet.yaml

  echo Done initializing the directory structure.
  popd
  
  goto End
)

if ""%1"" == ""start"" (
  if "%APISIMULATOR_HEAP_SIZE%"=="" set "APISIMULATOR_HEAP_SIZE=-Xms128m -Xmx128m"
  if "%APISIMULATION_LOG_FILE%"=="" set "APISIMULATION_LOG_FILE=apisimulator-log4j2.xml"
  
  goto Process
)

if ""%1"" == ""stop"" (
  if "%APISIMULATOR_HEAP_SIZE%"=="" set "APISIMULATOR_HEAP_SIZE=-Xms128m -Xmx128m"
  if "%APISIMULATION_LOG_FILE%"=="" set "APISIMULATION_LOG_FILE=apisimulator-stop-log4j2.xml"
  
  goto Process
)

goto Usage

:MissingSimulationPathArgument
echo Path to simulation expected
echo.
@rem Fall through

:Usage
echo.
echo Usage:  
echo %0% command path_to_simulation_home_directory
echo.
echo where command is one of
echo   start     Start an API Simulator instance in a separate window
echo   stop      Stop an API Simulator instance 
echo   init      Initialize a new API Simulation directory structure. Expects an absolute path for argument.
goto End

:Process
if ""%2""=="""" goto MissingSimulationPathArgument

set "CURRENT_DIR=%cd%"

set "THIS_SCRIPT_DIR=%~dp0"

@rem This script is expected to be in 'bin' directory under the simulator's home directory
set "APISIMULATOR_HOME=%THIS_SCRIPT_DIR%.."

set "APISIMULATION_HOME=%2"
if not exist "%2" (
  @rem Is the directory path relative to the current directory?
  if exist "%CURRENT_DIR%%2" (
    set "APISIMULATION_HOME=%CURRENT_DIR%%2"
  ) else (
    @rem Is the directory  path relative to the api simulator home directory?
    if exist "%APISIMULATOR_HOME%\%2" (
      @rem Using a little trick to make it work for file path in double quotes
      set "APISIMULATION_HOME=%APISIMULATOR_HOME%\./%2"
    )
  )
)
if not exist "%APISIMULATION_HOME%" (
  echo Simulation home directory "%APISIMULATION_HOME%" doesn't exist
  goto Usage
)

if "%APISIMULATOR_JAVA%"=="" set "APISIMULATOR_JAVA=%JAVA_HOME%"
if "%APISIMULATOR_JAVA%"=="" (
  @echo APISIMULATOR_JAVA nor JAVA_HOME environment variables are set
  goto End
)

set "APISIMULATION_CONFIG=%APISIMULATION_HOME%\config"
if not exist "%APISIMULATION_CONFIG%" (
  @rem @echo Simulation configuration directory "%APISIMULATION_CONFIG%" doesn't exist
  @rem goto End
  set "APISIMULATION_CONFIG=%APISIMULATION_HOME%"
)

set "APISIMULATION_SIMLETS_DIR=%APISIMULATION_HOME%\simlets"
if not exist "%APISIMULATION_SIMLETS_DIR%" (
  @echo Simulation simlets directory "%APISIMULATION_SIMLETS_DIR%" doesn't exist
  goto End
)

set "APISIMULATION_LOG_PATH=%APISIMULATION_HOME%\logs"
if not exist "%APISIMULATION_LOG_PATH%" (
  @rem @echo Simulation logs directory "%APISIMULATION_LOG_PATH%" doesn't exist
  @rem goto End
  set "APISIMULATION_LOG_PATH=%APISIMULATION_HOME%"
)

set "APISIMULATION_LOG_CONFIG=%APISIMULATION_CONFIG%\%APISIMULATION_LOG_FILE%"
if not exist "%APISIMULATION_LOG_CONFIG%" (
  set "APISIMULATION_LOG_CONFIG=%APISIMULATOR_HOME%\config\%APISIMULATION_LOG_FILE%"
)

@rem No spaces in the log directory or log file names!! -Dlog4j.debug
set "APISIMULATION_LOG_ARGS=-Dlog4j.configurationFile=%APISIMULATION_LOG_CONFIG%"
set "APISIMULATION_LOG_ARGS=%APISIMULATION_LOG_ARGS% -DAPISIMULATION_LOG_PATH=%APISIMULATION_LOG_PATH% "

set "APISIMULATION_CP=%APISIMULATION_CONFIG%\*;%APISIMULATION_HOME%\lib\*"
set "CP=%APISIMULATION_CP%;%APISIMULATOR_HOME%\lib\*"

if "%APISIMULATION_SCRIPTS_DIRS%"=="" set "APISIMULATION_SCRIPTS_DIRS=%APISIMULATION_HOME%\scripts"

if "%APISIMULATOR_CONFIG_DIRS%"=="" set "APISIMULATOR_CONFIG_DIRS=%APISIMULATOR_HOME%\config"

if ""%1"" == ""start"" goto DoStart
if ""%1"" == ""stop"" goto DoStop

:DoStart
shift
set CMD_LINE_ARGS=
:SetStartArgs
if ""%1""=="""" goto DoneSetStartArgs
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto SetStartArgs
:DoneSetStartArgs

set "APISIMULATOR_OPTS=-server %APISIMULATOR_OPTS% %APISIMULATOR_HEAP_SIZE%"
if "%TITLE%" == "" set "TITLE=API Simulator"
@rem start "%TITLE%" /min cmd /c ""%APISIMULATOR_JAVA%\bin\java" %APISIMULATOR_OPTS% -cp "%CP%" %APISIMULATION_LOG_ARGS% com.apisimulator.APISimulator -c "%APISIMULATOR_CONFIG_DIRS%" -s "%APISIMULATION_SIMLETS_DIR%" -scripts "%APISIMULATION_SCRIPTS_DIRS%" %CMD_LINE_ARGS% > %APISIMULATION_OUT% 2>&1"
start "%TITLE%" /min cmd /c ""%APISIMULATOR_JAVA%\bin\java" %APISIMULATOR_OPTS% -cp "%CP%" %APISIMULATION_LOG_ARGS% com.apisimulator.APISimulator -c "%APISIMULATOR_CONFIG_DIRS%" -s "%APISIMULATION_SIMLETS_DIR%" -scripts "%APISIMULATION_SCRIPTS_DIRS%" %CMD_LINE_ARGS% 2>&1"
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

set "APISIMULATOR_OPTS=%APISIMULATOR_OPTS% %APISIMULATOR_HEAP_SIZE%"
@rem "%APISIMULATOR_JAVA%\bin\java" %APISIMULATOR_OPTS% -cp "%CP%" %APISIMULATION_LOG_ARGS% com.apisimulator.APISimulator -stop %CMD_LINE_ARGS% > %APISIMULATION_OUT% 2>&1
"%APISIMULATOR_JAVA%\bin\java" %APISIMULATOR_OPTS% -cp "%CP%" %APISIMULATION_LOG_ARGS% com.apisimulator.APISimulator -stop %CMD_LINE_ARGS% 2>&1
goto End

:End
