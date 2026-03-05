@echo off
title Quick Closer
setlocal EnableDelayedExpansion

:: Create folder if it doesn't exist
set "folder=%~dp0Quick Closer development"
if not exist "%folder%" mkdir "%folder%"

set "favfile=%folder%\favorites.txt"
set "colorfile=%folder%\color.txt"

:: Load or set default color
if not exist "%colorfile%" (
    echo 0B > "%colorfile%"
)
set /p color=<"%colorfile%"
color %color%

:: Protect explorer.exe
if not exist "%favfile%" (
    echo explorer.exe > "%favfile%"
) else (
    findstr /i /c:"explorer.exe" "%favfile%" >nul || echo explorer.exe >> "%favfile%"
)

:menu
cls
echo.
echo ==========================================
echo             QUICK CLOSER
echo ==========================================
echo.
echo   1. Choose apps to KEEP (auto-saves favorites)
echo   2. Close everything except saved favorites
echo   3. View / Remove favorites
echo   4. Change color theme
echo   5. Instant Restart PC
echo   6. Instant Shutdown PC
echo   7. Exit
echo.
echo ==========================================
echo.
set /p choice=Pick (1-7): 

if "%choice%"=="1" goto select
if "%choice%"=="2" goto closefavs
if "%choice%"=="3" goto manage
if "%choice%"=="4" goto colormenu
if "%choice%"=="5" goto restartpc
if "%choice%"=="6" goto shutdownpc
if "%choice%"=="7" exit
goto menu

:select
cls
echo.
echo ==========================================
echo      Running Programs (unique names)
echo ==========================================
echo.

set count=0
for /f "tokens=1 delims=," %%A in ('tasklist /fo csv /nh /fi "username eq %username%" ^| sort /unique') do (
    set "proc=%%~A"
    set "skip=0"
    for %%S in (System "System Idle Process" smss.exe csrss.exe wininit.exe services.exe lsass.exe svchost.exe RuntimeBroker.exe SearchHost.exe ShellHost.exe dwm.exe) do (
        if /i "!proc!"=="%%~S" set skip=1
    )
    if !skip!==0 (
        set /a count+=1
        set "app!count!=!proc!"
        echo   !count!. !proc!
    )
)

echo.
echo ==========================================
echo Type numbers to KEEP (space separated)
echo ==========================================
set /p keepnums=Your choice: 

for %%K in (!keepnums!) do (
    set "chosen=!app%%K!"
    if defined chosen (
        findstr /i /c:"!chosen!" "%favfile%" >nul || echo !chosen! >> "%favfile%"
    )
)

echo.
echo Closing the rest...
call :loading

for /l %%I in (1,1,!count!) do (
    set "kill=1"
    for %%K in (!keepnums!) do if %%I==%%K set "kill=0"
    if !kill!==1 taskkill /f /im "!app%%I!" >nul 2>&1
)

echo.
echo Done
timeout /t 2 >nul
goto menu

:closefavs
cls
echo.
echo ==========================================
echo   Closing everything except favorites...
echo ==========================================
echo.
call :loading

for /f "tokens=1 delims=," %%A in ('tasklist /fo csv /nh /fi "username eq %username%"') do (
    set "proc=%%~A"
    set "kill=1"
    for /f "delims=" %%F in ("%favfile%") do (
        if /i "!proc!"=="%%F" set "kill=0"
    )
    if !kill!==1 taskkill /f /im "!proc!" >nul 2>&1
)

echo.
echo Done
timeout /t 2 >nul
goto menu

:manage
cls
echo.
echo ==========================================
echo           Your Favorites
echo ==========================================
echo.

set fc=0
for /f "delims=" %%L in ("%favfile%") do (
    set /a fc+=1
    echo   !fc!. %%L
)

if !fc! equ 0 echo   (empty)

echo.
echo ==========================================
echo Numbers to REMOVE (space sep or Enter)
echo ==========================================
set /p remnums=Remove: 

if "!remnums!"=="" goto menu

set "tmp=%temp%\qc_temp.txt"
del "%tmp%" 2>nul

set ln=0
for /f "delims=" %%L in ("%favfile%") do (
    set /a ln+=1
    set "skip=0"
    for %%R in (!remnums!) do if !ln!==%%R set "skip=1"
    if !skip!==0 echo %%L >> "%tmp%"
)

move /y "%tmp%" "%favfile%" >nul
echo.
echo Updated
timeout /t 2 >nul
goto menu

:colormenu
cls
echo.
echo ==========================================
echo         Color Themes ~ Pick your vibe ♡
echo ==========================================
echo.
echo   0A   Matrix green (classic hacker)
echo   0B   Cyan cool (default cute)
echo   0C   Bright red (alert mode)
echo   0E   Yellow sunny (happy vibes)
echo   1F   White on deep blue (clean pro)
echo   2F   Green on blue (forest dream)
echo   3F   Aqua/teal (ocean fresh)
echo   4F   Red on blue (danger cute)
echo   5F   Purple dreamy (magic mode)
echo   6F   Yellow on blue (sunny day)
echo   9F   Bright blue (sky high)
echo   A0   Light green (minty fresh)
echo   B0   Light cyan (pastel sky)
echo   C0   Light red (soft pinkish)
echo   E0   Light yellow (soft gold)
echo   07   White on black (pure minimal)
echo   70   Black on white (inverted clean)
echo   4E   Red on yellow (warning pop)
echo   5E   Purple on yellow (royal fun)
echo   8F   Gray on blue (dark mode lite)
echo   0D   Pinkish magenta (kawaii alert)
echo   D0   Light magenta (cute bubblegum)
echo   F0   Bright white (super clean)
echo   0F   Bright white on black (neon pop)
echo   3E   Aqua on yellow (tropical fun)
echo   6E   Yellow on purple (candy mode)
echo   CE   Light red on yellow (sunset glow)
echo   FE   Bright white on magenta (ultra kawaii)
echo.
echo   Type code (like 0B or FE) or Enter to go back~
echo ==========================================
echo.
set /p newcolor=Your color code: 

if "!newcolor!"=="" goto menu

set "valid=0"
for %%C in (0A 0B 0C 0E 1F 2F 3F 4F 5F 6F 9F A0 B0 C0 E0 07 70 4E 5E 8F 0D D0 F0 0F 3E 6E CE FE) do (
    if /i "!newcolor!"=="%%C" (
        set "color=%%C"
        echo %%C > "%colorfile%"
        color %%C
        set "valid=1"
        echo.
        echo Color changed~ nya~ 💖
        timeout /t 2 >nul
    )
)

if !valid!==0 (
    echo.
    echo Oops~ That code isn't valid cutie~ Try again~ 😽
    timeout /t 3 >nul
)
goto menu

:restartpc
cls
echo.
echo ==========================================
echo      Restarting PC in 5 seconds...
echo ==========================================
echo.
shutdown /r /t 5 /f
timeout /t 5 >nul
exit

:shutdownpc
cls
echo.
echo ==========================================
echo      Shutting down PC in 5 seconds...
echo ==========================================
echo.
shutdown /s /t 5 /f
timeout /t 5 >nul
exit

:loading
<nul set /p "=Processing"
for /l %%i in (1,1,8) do (
    <nul set /p "=."
    timeout /t 0 /nobreak >nul
)
echo.
exit /b