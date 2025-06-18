@echo off
echo Starting Angular development server...

cd /d "%~dp0\.."

set "NODE_EXE=C:\Program Files\nodejs\node.exe"
set "NG_EXE=C:\Users\Administrator\AppData\Roaming\npm\ng.cmd"

echo Current directory: %CD%
echo Verifying project structure...
if exist angular.json (
    echo Found angular.json
) else (
    echo ERROR: No angular.json found
    exit /b 1
)

if exist node_modules (
    echo Found node_modules directory
) else (
    echo ERROR: No node_modules directory found
    echo Running npm install...
    "C:\Program Files\nodejs\npm.cmd" install
)

echo Stopping existing processes...
taskkill /F /IM node.exe 2>nul
ping 127.0.0.1 -n 6 > nul

echo Testing Angular CLI directly...
"%NG_EXE%" --version > C:\ng-version.log 2>&1
if %errorlevel% equ 0 (
    echo Angular CLI is working
    type C:\ng-version.log
) else (
    echo Angular CLI test failed
    type C:\ng-version.log
)

echo Setting up environment...
set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;%PATH%"
set "NODE_PATH=C:\Users\Administrator\AppData\Roaming\npm\node_modules"

echo Creating startup script...
echo @echo off > C:\start-angular-direct.bat
echo cd /d "%CD%" >> C:\start-angular-direct.bat
echo set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;%%PATH%%" >> C:\start-angular-direct.bat
echo set "NODE_PATH=C:\Users\Administrator\AppData\Roaming\npm\node_modules" >> C:\start-angular-direct.bat
echo "%NG_EXE%" serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000 >> C:\start-angular-direct.bat

echo Starting Angular server...
start "Angular Dev Server" C:\start-angular-direct.bat

echo Waiting 60 seconds for server to start...
for /L %%i in (1,1,12) do (
    ping 127.0.0.1 -n 6 > nul
    netstat -an | findstr ":4200" >nul
    if !errorlevel! equ 0 (
        echo SUCCESS: Angular server is now listening on port 4200
        goto :server_started
    )
    echo Attempt %%i/12: Waiting for server...
)

:server_started
netstat -an | findstr ":4200" >nul
if %errorlevel% equ 0 (
    echo Angular server is running on port 4200
) else (
    echo WARNING: Server may not be running
    echo Checking processes:
    tasklist | findstr node.exe
    
    echo Checking for error logs...
    if exist "%USERPROFILE%\.npm\_logs" (
        echo Recent npm logs:
        dir "%USERPROFILE%\.npm\_logs" /o:d
    )
)

echo Creating monitoring script...
(
echo @echo off
echo :loop
echo ping 127.0.0.1 -n 61 ^> nul
echo netstat -an ^| findstr ":4200" ^>nul
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo Restarting Angular server...
echo     taskkill /F /IM node.exe 2^>nul
echo     ping 127.0.0.1 -n 6 ^> nul
echo     start "Angular Dev Server" C:\start-angular-direct.bat
echo ^)
echo goto loop
) > "C:\monitor-angular.bat"

start "Angular Monitor" /MIN "C:\monitor-angular.bat"

echo Startup completed