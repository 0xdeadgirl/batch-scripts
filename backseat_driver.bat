::
: Name: Backseat Driver
: Description: Uninstalls HID mouse devices
: License: MIT
: Version: 1.1
:
: Notes:
:   This script uninstalls HID mouse devices, and theoretically leave virtual mice unaffected.
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

:: Check if there are currently HID mice. 0=devices found; 1=none found
powershell -Command "Get-PnpDevice -Class Mouse" >NUL 2>&1
if %errorlevel% == 0 (
	powershell -Command "Get-PnpDevice -Class Mouse | ForEach-Object { &'pnputil' /remove-device $_.InstanceId }" >nul 2>&1
) else (
	pnputil /scan-devices >nul 2>&1
)
