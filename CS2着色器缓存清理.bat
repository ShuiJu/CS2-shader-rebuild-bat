@echo off
:: CS2 Shader Cache Cleaner - Fixed Version
chcp 65001 >nul
title CS2 Shader Cache Cleaner
setlocal enabledelayedexpansion

:: Request admin privileges
fltmc >nul 2>&1 || (
    echo [!] Requesting administrator privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

echo CS2 Shader Cache Cleaner - Fixed Version

:: Check and read log files
set "useLogPaths="
if exist "%~dp0steamPath.log" (
    if not exist "%~dp0cs2Path.log" (
        goto askPath
    )

    for %%F in ("%~dp0steamPath.log") do (
        if %%~zF LSS 1024 (
            echo.
            echo Found steamPath.log file
            echo File content:
            type "%~dp0steamPath.log"

            echo.
            echo Found cs2Path.log file
            echo File content:
            type "%~dp0cs2Path.log"
            
            set /p "confirm=Use paths from these files? [Y/n] (default Y) "
            if /i "!confirm!"=="" set "confirm=Y"
            
            if /i "!confirm!"=="Y" (
                set "useLogPaths=1"
                set /p "steamPath=" < "%~dp0steamPath.log"
                set /p "cs2Path=" < "%~dp0cs2Path.log"
                
                :: Remove possible quotes from paths
                set "steamPath=!steamPath:"=!"
                set "cs2Path=!cs2Path:"=!"
                
                echo.
                echo Using paths from log files:
                echo Steam path: !steamPath!
                echo CS2 path: !cs2Path!
                echo.
            )
        )
    )
)

:: If not using log paths, ask user for input
:askPath
if not defined useLogPaths (
    :: Ask for Steam and CS2 paths
    set "defaultSteamPath=C:\Program Files (x86)\Steam\steam.exe"
    set "defaultCS2Path=C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe"

    echo Enter Steam.exe path [Press Enter for default: !defaultSteamPath!]:
    set /p "steamPath="
    if "!steamPath!"=="" set "steamPath=!defaultSteamPath!"

    echo Enter CS2.exe path [Press Enter for default: !defaultCS2Path!]:
    set /p "cs2Path="
    if "!cs2Path!"=="" set "cs2Path=!defaultCS2Path!"
)

:: Automatically derive other paths
for %%A in ("%cs2Path%") do (
    set "cs2Dir=%%~dpA"
    :: Go back from bin\win64\ to game\ directory
    set "csgoPath=!cs2Dir:~0,-11!\csgo\"
    set "corePath=!cs2Dir:~0,-11!\csgo_core\"
)

:: Verify paths exist
if not exist "!csgoPath!" (
    echo Error: CSGO directory not found: !csgoPath!
    pause
    exit /b
)
if not exist "!corePath!" (
    echo Error: CORE directory not found: !corePath!
    pause
    exit /b
)

:: Check if CS2 is running and kill it
tasklist /FI "IMAGENAME eq cs2.exe" 2>nul | find /I "cs2.exe" >nul && (
    taskkill /F /IM cs2.exe >nul 2>&1 && (
        echo CS2 was running. Game closed.
    ) || (
        echo CS2 is running but cannot be closed. Please close the game manually and press Enter.
        pause >nul
    )
)

:: Delete shader cache files
echo Deleting shader cache files in !csgoPath! and !corePath!...
del /q "!csgoPath!\shaders_*.vpk"
del /q "!corePath!\shaders_*.vpk"
if errorlevel 1 (
    echo No shader cache files found.
)

:: Complete DirectX cache cleanup
echo.
echo [1/2] Deleting known cache directories...
del /f /q "%USERPROFILE%\AppData\Local\Microsoft\Windows\DXCache\*" 2>nul
del /f /q "%USERPROFILE%\AppData\Local\D3DSCache\*" 2>nul
del /f /q "%USERPROFILE%\AppData\Local\NVIDIA\DXCache\*" 2>nul
del /f /q "%USERPROFILE%\AppData\Local\AMD\DxCache\*" 2>nul

echo [2/2] Running system disk cleanup...
if exist "%SystemRoot%\System32\cleanmgr.exe" (
    echo Please use the Disk Cleanup window to clean DirectX Shader Cache, then press Enter to continue...
    timeout /t 5 >nul
    start "" %SystemRoot%\System32\cleanmgr.exe
    pause >nul
) else (
    echo Warning: cleanmgr.exe not found, skipping disk cleanup
)

echo Verifying CS2 game integrity...
start "" steam://validate/730
timeout /t 2 >nul
echo shader_build 730 | clip
echo.
echo.
echo.
echo "shader_build 730" copied to clipboard!
echo.
echo ===== Shader Rebuild Instructions =====
echo.
echo [Step 1] Wait for game verification to complete
echo 1. Make sure Steam has finished verifying game integrity
echo 2. Open Steam Console (Steam top menu Help -> Console)
echo 3. Press Ctrl+V to paste command and press Enter
echo.
echo [Step 2] Preload game resources
echo 1. Create a local room or join casual mode
echo 2. Buy all weapons
echo 3. Throw all items
echo 4. Perform all actions
echo 5. Wait for the game to become completely smooth
echo.
echo [Tip] This process only needs to be done once
echo ========================================
echo.

timeout /t 15
start "" steam://open/console
pause
exit
