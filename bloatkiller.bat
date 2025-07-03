::
: Name: Bloatkiller
: Description: Disables superfluous Windows services
: Authors: Lukas Lynch <madi@mxdi.xyz>, T. Fierro <null>
: License: MIT
: Version: 1.2
:
: Notes:
:   sc is the program for configuring services.
:   Relevant return codes (a.k.a. errorLevel):
:   - 0: No issues
:   - 1060: Service not found/valid
:   - 1062: Service not running/already stopped (for stop operation)
::

@echo off
setlocal enableDelayedExpansion
title Bloatkiller

echo(
echo Now disabling unnecessary background services.
echo ----------------------------------------------
echo(

::
: Define array of services to disable.
: Make sure to adjusted indexes if adding/removing services.
: NULL should always be last.
::
set services[0]=CCleanerPerformanceOptimizerService
set services[1]=DiagTrack
set services[2]=GUBootService
set services[3]=GUMemfilesService
set services[4]=GUPMService
set services[5]=SysMain
set services[6]=NULL

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% NEQ 0 (
	echo Failure: Current permissions inadequate; try running as administrator.
	goto end
)

set /a index=0
:loop
set service=!services[%index%]!
if %service% NEQ NULL (
	echo Stopping %service%
	sc stop %service% >nul 2>&1
	if !errorLevel! NEQ 0 if !errorLevel! NEQ 1062 (
		if !errorLevel! == 1060 (
			echo 	Service not found
		) else (echo sc failed to stop %service%. [Error: !errorLevel!] 1>&2)
	)

	echo Disabling %service%
	sc config %service% start= disabled >nul 2>&1
	if !errorLevel! NEQ 0 (
		if !errorLevel! == 1060 (
			echo 	Service not found
		) else (echo sc failed to disable %service%. [Error: !errorLevel!] 1>&2)
	)
	
	echo.
	set /a index=%index%+1
	goto loop
)

:: This is to spawn msconfig, for checking for malicious services (allows us to filter out Microsoft services) -LL
echo | set /p="Launch msconfig? "	&:: "echo set /p="..." removes trailing newline
choice					&:: The default options are Y/N. Y = 1, N = 2
if %errorLevel% == 1 (
	msconfig
)

echo(
:: This is to spawn Services, for checking all services -TF
echo | set /p="Launch Services? "	&:: "echo set /p="..." removes trailing newline
choice					&:: The default options are Y/N. Y = 1, N = 2
if %errorLevel% == 1 (
	services.msc
)

:end
echo(
:: Alternatively you could use "cmd /K" instead of "pause" as the final command, it returns you to the terminal to be able to perform more stuff rather then just closing the window -TF
::cmd /K
pause
