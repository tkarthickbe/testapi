@echo off
@rem @echo on
@rem ---------------------------------------------------------------------------
@rem API Client Script
@rem ---------------------------------------------------------------------------

if "%OS%" == "Windows_NT" setlocal

if "%APICLIENT_JAVA%"=="" set "APICLIENT_JAVA=%JAVA_HOME%"
if "%APICLIENT_JAVA%"=="" (
  @echo APICLIENT_JAVA nor JAVA_HOME environment variables are set
  goto End
)


set "THIS_SCRIPT_DIR=%~dp0"

@rem This script is expected to be in 'bin' sub-directory under the simulator's main directory
set "APICLIENT_HOME=%THIS_SCRIPT_DIR%.."


set "CP=%APICLIENT_HOME%\lib\*"


set "APICLIENT_CONFIG=%APICLIENT_HOME%\config"
if not exist "%APICLIENT_CONFIG%" (
  @echo Configuration directory "%APICLIENT_CONFIG%" doesn't exist
  goto End
)


if "%APICLIENT_LOG_FILE%"=="" set "APICLIENT_LOG_FILE=apiclient-log4j2.xml"

set "APICLIENT_LOG_CONFIG=%APICLIENT_CONFIG%\%APICLIENT_LOG_FILE%"
if not exist "%APICLIENT_LOG_CONFIG%" (
  set "APICLIENT_LOG_CONFIG=%APICLIENT_HOME%\config\%APICLIENT_LOG_FILE%"
)

@rem No spaces in the log directory or log file names!! -Dlog4j.debug
set "APICLIENT_LOG_ARGS=-Dlog4j.configurationFile=%APICLIENT_LOG_CONFIG%"
set "APICLIENT_LOG_ARGS=%APICLIENT_LOG_ARGS% -DAPICLIENT_LOG_PATH=%APICLIENT_LOG_PATH% "


:DoStart
shift
set CMD_LINE_ARGS=
:SetArgs
if ""%0""=="""" goto DoneSetArgs
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %0

if "%0"=="-f" (
  @rem Is there another argument (presumably, the file path)
  if "%1"=="" goto DoneSetArgs

  @rem Does the file path exist?
  if exist "%1" (
    set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
  ) else (
    @rem Is the file path relative to the current directory?
    set "CURRENT_DIR=%cd%"
    if exist "%CURRENT_DIR%%1" (
      set CMD_LINE_ARGS=%CMD_LINE_ARGS% "%CURRENT_DIR%%1"
    ) else (
      @rem Is the file path relative to the api client home directory?
      if exist "%APICLIENT_HOME%\%1" (
        @rem Using a little trick to make it work for file path in double quotes
        set CMD_LINE_ARGS=%CMD_LINE_ARGS% "%APICLIENT_HOME%\./%1"
      ) else (
        @rem Leave it to API Client to error out
        set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
      )
    )
  )

  shift
)

shift
goto SetArgs
:DoneSetArgs

"%APICLIENT_JAVA%\bin\java" %APICLIENT_OPTS% -cp "%CP%" %APICLIENT_LOG_ARGS% com.apisimulator.http.HttpAPIClient %CMD_LINE_ARGS%

:End
