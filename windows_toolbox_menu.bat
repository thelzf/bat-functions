@echo off
:: Robust Windows Toolbox Menu - Thelzf Bat (Base64 decode fallback + clearer errors)
:: Save as windows_toolbox_menu.bat and run (right-click -> Run as administrator for some actions)

:: --- Title & obfuscated subtitle setup (with verification & robust decode) ---
title Thelzf Bat
cls

:: Base64 of: https://github.com/thelzf/bat-functions
set "OBF=aHR0cHM6Ly9naXRodWIuY29tL3RoZWx6Zi9iYXQtZnVuY3Rpb25z"

:: Clear SUB
set "SUB="

:: 1) Try PowerShell decode (preferred)
for /f "delims=" %%S in ('powershell -NoProfile -Command "try { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%OBF%')) } catch { Write-Error 'PS decode failed'; exit 1 }" 2^>nul') do set "SUB=%%S"

:: 2) If PowerShell gave nothing, try certutil fallback
if "%SUB%"=="" (
    :: create temp files
    set "B64=%TEMP%\b64_obf.txt"
    set "OUT=%TEMP%\b64_out.txt"
    >"%B64%" echo %OBF%
    :: certutil requires a blank line at end sometimes; we wrote only the string which usually works
    certutil -decode "%B64%" "%OUT%" >nul 2>&1
    if exist "%OUT%" (
        setlocal enabledelayedexpansion
        set "LINE="
        for /f "usebackq delims=" %%L in ("%OUT%") do (
            if defined LINE (
                rem accumulate multiple lines (if any)
                set "LINE=!LINE!%%L"
            ) else (
                set "LINE=%%L"
            )
        )
        endlocal & set "SUB=%LINE%"
        del "%B64%" >nul 2>&1
        del "%OUT%" >nul 2>&1
    )
)

:: expected value
set "EXPECTED=https://github.com/thelzf/bat-functions"

:: If still empty, show debug info and pause so user can see the error
if "%SUB%"=="" (
    echo.
    echo ERROR: Failed to decode obfuscated subtitle via PowerShell and certutil.
    echo Possible reasons:
    echo  - PowerShell not available or blocked by policy.
    echo  - certutil not present or denied.
    echo  - Permission issues writing to %TEMP%.
    echo.
    echo Debug info:
    echo OBF: %OBF%
    echo EXPECTED: %EXPECTED%
    echo.
    echo Check if PowerShell runs by typing: powershell -NoProfile -Command "Write-Output 'hello'"
    echo Check certutil by typing: certutil -?
    echo.
    echo The script will not modify the file but will exit now. Press a key to continue...
    pause >nul
    exit /b 1
)

:: verify decoded value matches expected exactly (case-insensitive)
if /i not "%SUB%"=="%EXPECTED%" (
    echo.
    echo ERROR: subtitle verification failed.
    echo Expected: %EXPECTED%
    echo Found:    %SUB%
    echo.
    echo The script will now exit and lock itself to prevent accidental modification.
    :: make the .bat file read-only to hinder edits (non-destructive)
    attrib +r "%~f0" >nul 2>&1
    :: log the mismatch to a file in the same folder
    echo %date% %time% - Subtitle mismatch: expected %EXPECTED% found %SUB%>>"%~dp0verification_fail.log"
    echo A log was written to: "%~dp0verification_fail.log"
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: If OK, display header normally
echo ===============================
echo Thelzf Bat
echo -------------------------------
echo Subtitle: %SUB%
echo ===============================
echo.

:main
cls
echo ===============================
echo Windows Toolbox Menu
echo ===============================
echo 1. Clean temporary files (Temp folder)
echo 2. Open programs (Chrome, File Explorer, Word, Excel, PowerPoint)
echo 3. Shutdown the PC
echo 4. Prank: Create 10,000 folders on Desktop (CONFIRMATION REQUIRED)
echo 5. Toggle Desktop Icons (show/hide)
echo 6. Other utilities (open command prompt, restart Explorer)
echo 0. Exit
echo ===============================
set /p choice=Choose an option:
if "%choice%"=="1" goto clean_temp
if "%choice%"=="2" goto open_programs
if "%choice%"=="3" goto shutdown_pc
if "%choice%"=="4" goto troll_folders
if "%choice%"=="5" goto toggle_icons
if "%choice%"=="6" goto other_utils
if "%choice%"=="0" goto eof
echo Invalid option. Press any key to try again...
pause >nul
goto main

:clean_temp
cls
echo *** Clean Temporary Files ***
echo This will delete files inside your TEMP folder: %TEMP%
set /p confirm=Are you sure? Type YES to proceed:
if /i not "%confirm%"=="YES" (
    echo Aborted. Returning to menu...
    timeout /t 2 >nul
    goto main
)
echo Deleting files... This may take a while.
del /q /f "%TEMP%\*" 2>nul
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" 2>nul
echo Done cleaning TEMP.
pause >nul
goto main

:open_programs
cls
echo *** Open Programs ***
echo Choose a program to open:
echo 1. Google Chrome
echo 2. File Explorer
echo 3. Microsoft Word
echo 4. Microsoft Excel
echo 5. Microsoft PowerPoint
echo 6. Open All (Chrome, Explorer, Word, Excel, PowerPoint)
echo 0. Back
set /p pchoice=Choice:
if "%pchoice%"=="1" start "" "chrome.exe" & goto opened
if "%pchoice%"=="2" start "" explorer.exe & goto opened
if "%pchoice%"=="3" start "" winword.exe & goto opened
if "%pchoice%"=="4" start "" excel.exe & goto opened
if "%pchoice%"=="5" start "" powerpnt.exe & goto opened
if "%pchoice%"=="6" start "" "chrome.exe" & start "" explorer.exe & start "" winword.exe & start "" excel.exe & start "" powerpnt.exe & goto opened
if "%pchoice%"=="0" goto main
echo Could not start. Make sure the applications are installed and in PATH.
pause >nul
goto open_programs

:opened
echo Program(s) launched. Returning to menu...
timeout /t 1 >nul
goto main

:shutdown_pc
cls
echo *** Shutdown PC ***
echo This will shut down your computer.
set /p confirm=Type SHUTDOWN to confirm and proceed:
if /i not "%confirm%"=="SHUTDOWN" (
    echo Aborted. Returning to menu...
    timeout /t 2 >nul
    goto main
)
echo Shutting down in 10 seconds. Press Ctrl+C to cancel.
shutdown /s /t 10
goto main

:troll_folders
cls
echo *** Prank: Create Folders on Desktop ***
echo WARNING: This will create a large number of folders on your Desktop. This can slow or destabilize the system.
set /p confirm=Type CREATE to proceed (or anything else to cancel):
if /i not "%confirm%"=="CREATE" (
    echo Aborted. Returning to menu...
    timeout /t 2 >nul
    goto main
)
set "DESKTOP=%USERPROFILE%\Desktop"
echo Enter number of folders to create (suggestion: 10000):
set /p count=Number:
if "%count%"=="" set count=10000
set /a i=1
echo Creating %count% folders in %DESKTOP% ...
for /l %%i in (1,1,%count%) do (
    md "%DESKTOP%\prank_%%i" 2>nul
)
echo Done. Created %count% folders.
pause >nul
goto main

:toggle_icons
cls
echo *** Toggle Desktop Icons (Show/Hide) ***
echo This will toggle desktop icons visibility. Explorer will restart to apply.
set /p confirm=Type TOGGLE to proceed:
if /i not "%confirm%"=="TOGGLE" (
    echo Aborted. Returning to menu...
    timeout /t 2 >nul
    goto main
)
echo Reading current value...
for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons 2^>nul') do set cur=%%B
if "%cur%"=="0x1" (
    echo Currently hidden -> showing icons (set to 0)
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons /t REG_DWORD /d 0 /f >nul 2>&1
) else (
    echo Currently shown or undefined -> hiding icons (set to 1)
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons /t REG_DWORD /d 1 /f >nul 2>&1
)
echo Restarting Explorer to apply changes...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo Done.
pause >nul
goto main

:other_utils
cls
echo *** Other Utilities ***
echo 1. Open Command Prompt
echo 2. Restart Explorer (refresh desktop)
echo 0. Back
set /p ochoice=Choice:
if "%ochoice%"=="1" start cmd.exe & goto main
if "%ochoice%"=="2" (
    echo Restarting Explorer...
    taskkill /f /im explorer.exe >nul 2>&1
    start explorer.exe
    echo Done.
    pause >nul
    goto main
)
echo Invalid option. Returning to main menu...
timeout /t 1 >nul
goto main

:eof
echo Goodbye!
exit /b 0
