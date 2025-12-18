::
: Name: Backseat Driver
: Description: Uninstalls PnP mouse devices
: License: MIT
: Version: 1.3
:
: Notes:
:   This script uninstalls PnP mouse devices.
:
:   We uninstall the devices, because they can be re-enabled by unplugging them and plugging
:   them back in, or by restarting the computer. We would need to manually re-enable if we
:   outright disabled them.
:
:   '>nul 2>&1' suppresses output
::
@echo off
title Backseat Driver

:: Check for admin permissions
net session >nul 2>&1
if %errorLevel% NEQ 0 (
	echo Failure: Current permissions inadequate; try running as administrator.
	pause
	exit
)

:: Disable mouse
powershell -Command "Get-PnpDevice -Class Mouse | ForEach-Object { &'pnputil' /remove-device $_.InstanceId }" >nul 2>&1

pause

:: Re-enable mouse
pnputil /scan-devices >nul 2>&1
