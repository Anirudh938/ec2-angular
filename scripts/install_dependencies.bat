@echo off
echo Starting Angular development server...

REM Navigate to the deployment directory
cd /d "%~dp0\.."

REM Set Angular CLI path
set "NG_EXE=C:\Users\Administrator\AppData\Roaming\npm\ng.cmd"

REM Stop any existing Node.js processes
echo Stopping existing Node.js processes...
taskkill /F /IM node.exe 2>nul
timeout /t 5 /nobreak >nul

REM Start Angular development server on port 4200
echo Starting Angular development server on port 4200...
start "Angular Dev Server" /B "%NG_EXE%" serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000

REM Wait for server to start
echo Waiting 30 seconds for Angular server to start...
timeout /t 30 /nobreak >nul

REM Simple test using curl if available, otherwise just check process
echo Testing if Angular server started...
curl -s http://localhost:4200 >nul 2>&1
if %errorlevel% equ 0 (
    echo SUCCESS: Angular server is responding on port 4200
) else (
    echo Angular server may still be starting or curl not available
    echo Checking if node process is running...
    tasklist /FI "IMAGENAME eq node.exe" | find /I "node.exe" >nul
    if %errorlevel% equ 0 (
        echo Node.js process found - Angular server should be running
    ) else (
        echo WARNING: No Node.js process found
    )
)

REM Create simple monitoring script
echo Creating monitoring script...
echo @echo off > "C:\monitor-angular.bat"
echo :monitor_loop >> "C:\monitor-angular.bat"
echo timeout /t 60 /nobreak ^>nul >> "C:\monitor-angular.bat"
echo netstat -an ^| findstr ":4200" ^>nul >> "C:\monitor-angular.bat"
echo if %%ERRORLEVEL%% NEQ 0 ^( >> "C:\monitor-angular.bat"
echo     echo Restarting Angular server... >> "C:\monitor-angular.bat"
echo     taskkill /F /IM node.exe 2^>nul >> "C:\monitor-angular.bat"
echo     timeout /t 5 /nobreak ^>nul >> "C:\monitor-angular.bat"
echo     cd /d "%CD%" >> "C:\monitor-angular.bat"
echo     start "Angular Dev Server" /B "%NG_EXE%" serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000 >> "C:\monitor-angular.bat"
echo ^) >> "C:\monitor-angular.bat"
echo goto monitor_loop >> "C:\monitor-angular.bat"

REM Start monitoring script
start "Angular Monitor" /MIN "C:\monitor-angular.bat"

echo Angular development server setup completed