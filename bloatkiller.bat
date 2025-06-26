::
: Name: Bloatkiller
: Description: Disables superfluous Windows services
: Author: Lukas Lynch <madi@mxdi.xyz>
: Version: 1.0
::

@echo off
setlocal enableDelayedExpansion
echo.

set services[0]=CCleanerPerformanceOptimizerService
set services[1]=DiagTrack
set services[2]=GUBootService
set services[3]=GUMemfilesService
set services[4]=GUPMService
set services[5]=PcaSvc
set services[6]=SysMain
set services[7]=NULL

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Failure: Current permissions inadequate.
    goto end
)

set /a index=0
:loop
set service=!services[%index%]!
if %service% NEQ NULL (
    echo Stopping %service%
    sc stop %service% >nul 2>&1
    if %errorLevel% NEQ 0 if %errorLevel% NEQ 1062 (
        echo sc failed to stop %service%. [Error: %errorLevel%] 1>&2
    )

    echo Disabling %service%
    sc config %service% start= disabled >nul 2>&1
    if %errorLevel% NEQ 0 (
        echo sc failed to disable %service%. [Error: %errorLevel%] 1>&2
    )
    
    echo.
    set /a index=%index%+1
    goto loop
)

:end
:: This is just here so the shell window doesn't close on its own
echo Press any key to continue.
pause >nul
