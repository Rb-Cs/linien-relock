@echo off
setlocal ENABLEDELAYEDEXPANSION

echo ------------------------------------------------------------
echo     LINIEN SERVER DEPLOYMENT STARTED
echo ------------------------------------------------------------
echo.

:: ------------------------------
:: CONFIGURATION (EDIT THIS)
:: ------------------------------
set RP_IP=rp-XXXXXX.local
:: ------------------------------

set LOCAL_DIR=.\linien\server
set RP_TARGET_DIR=/usr/local/lib/python3.5/dist-packages/linien/server

:: 1. Verify local directory
if not exist "%LOCAL_DIR%" (
    echo ERROR: Local directory "%LOCAL_DIR%" does not exist.
    exit /b 1
)

echo Local directory: %LOCAL_DIR%
echo Remote directory: %RP_TARGET_DIR%
echo.

:: 2. Copy modified files. No SSH key required - you'll be prompted
::    for the root password.
echo Copying modified linien_server files to Red Pitaya...
echo You may be asked for the Red Pitaya root password.
scp -r "%LOCAL_DIR%\*" root@%RP_IP%:%RP_TARGET_DIR%/

if %errorlevel% neq 0 (
    echo ERROR: scp failed. Deployment aborted.
    exit /b 1
)

echo Files copied successfully.
echo.

:: 3. Reboot the Red Pitaya
echo Rebooting Red Pitaya...
echo You may be asked for the root password again.
ssh root@%RP_IP% "reboot"

if %errorlevel% neq 0 (
    echo ERROR: Failed to reboot Red Pitaya.
    exit /b 1
)

echo Reboot command sent. The device will reboot shortly.
echo.

:: Finished
echo ------------------------------------------------------------
echo     LINIEN SERVER DEPLOYMENT COMPLETE
echo ------------------------------------------------------------
echo.

endlocal
exit /b 0