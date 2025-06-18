@echo off
echo Starting Angular development server...

REM Navigate to the deployment directory
cd /d "%~dp0\.."

REM Set Node.js and Angular CLI paths
set "NG_EXE=C:\Users\Administrator\AppData\Roaming\npm\ng.cmd"

REM Stop any existing Node.js processes
echo Stopping existing Node.js processes...
taskkill /F /IM node.exe 2>nul
timeout /t 5 /nobreak >nul

REM Start Angular development server on port 4200
echo Starting Angular development server on port 4200...
start "Angular Dev Server" /B "%NG_EXE%" serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000

REM Wait for server to start
echo Waiting for Angular server to start...
timeout /t 30 /nobreak >nul

REM Test if Angular server is responding
echo Testing Angular server...
powershell -Command "for($i=0; $i -lt 10; $i++) { try { $response = Invoke-WebRequest -Uri 'http://localhost:4200' -UseBasicParsing -TimeoutSec 10; Write-Host 'SUCCESS: Angular server is running on port 4200 - Status:' $response.StatusCode; break } catch { Write-Host 'Attempt' ($i+1) '/10: Waiting for Angular server...'; Start-Sleep 5 } if($i -eq 9) { Write-Host 'ERROR: Angular server failed to start' } }"

REM Create monitoring script to keep Angular running
echo Creating monitoring script...
(
echo @echo off
echo :monitor_loop
echo timeout /t 60 /nobreak ^>nul
echo netstat -an ^| findstr ":4200" ^>nul
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo Angular server not found on port 4200, restarting...
echo     taskkill /F /IM node.exe 2^>nul
echo     timeout /t 5 /nobreak ^>nul
echo     cd /d "%CD%"
echo     start "Angular Dev Server" /B "%NG_EXE%" serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000
echo     timeout /t 30 /nobreak ^>nul
echo ^)
echo goto monitor_loop
) > "C:\monitor-angular.bat"

REM Start monitoring script
start "Angular Monitor" /MIN "C:\monitor-angular.bat"

echo Angular development server started on port 4200
echo Monitoring script started to keep server running