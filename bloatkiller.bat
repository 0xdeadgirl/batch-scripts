::
: Name: Bloatkiller
: Description: Disables superfluous Windows services
: Authors: Lukas Lynch <madi@mxdi.xyz>, T. Fierro <null>
: License: MIT
: Version: 1.4
:
: Notes:
:   "echo | set /p="..." removes trailing newline from 'echo' command
:
:   'sc' is the command for configuring services.
:   Relevant return codes (a.k.a. errorLevel):
:   - 0: No issues
:   - 1060: Service not found/valid
:   - 1062: Service not running/already stopped (for stop operation)
:
:   The default options for the 'choice' command are Y/N.
:   Relevant return codes (a.k.a. errorLevel):
:   - 1: Y
:   - 2: N
:
:   "[{number}m" are ANSI escape sequences; for color.
::
@echo off
setlocal enableDelayedExpansion
title Bloatkiller

echo [1mNow disabling unnecessary background services.
echo ==============================================[0m
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
	echo | set/p="Stopping %service% - "
	sc stop %service% >nul 2>&1
	if !errorLevel! NEQ 0 (
		if !errorLevel! == 1062 (
			echo [[92mSUCCESS[0m] - Service already stopped
		) else (
			if !errorLevel! == 1060 (
				echo [NULL] - Service not present
			) else (echo [[91mERROR[0m] - sc failed to stop %service%. [Error: !errorLevel!] 1>&2)
		)
	) else (echo [[92mSUCCESS[0m])

	echo | set/p="Disabling %service% - "
	sc qc %service% | findstr DISABLED >nul 	&:: Check if service is already diasabled
	if !errorLevel! NEQ 0 (
		sc config %service% start= disabled >nul 2>&1
		if !errorLevel! NEQ 0 (
			if !errorLevel! == 1060 (
				echo [NULL] - Service not found
			) else (echo [[91mERROR[0m] - sc failed to disable %service%. [Error: !errorLevel!] 1>&2)
		) else (echo [[92mSUCCESS[0m])
	) else (echo [[92mSUCCESS[0m] - Service already disabled)
	
	echo.
	set /a index=%index%+1
	goto loop
)

:: This is to spawn msconfig, for checking for malicious services (allows us to filter out Microsoft services)
echo | set /p="Launch msconfig? "
choice
if %errorLevel% == 1 (
	msconfig
)

:: This is to spawn Services, for checking all services -TF
echo(
echo | set /p="Launch Services? "
choice
if %errorLevel% == 1 (
	services.msc
)

:end
echo(
echo | set /p="Continue console session? "
choice
if %errorLevel% == 1 (
	cmd /K
)
