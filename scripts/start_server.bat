@echo off
echo Starting Angular development server...

cd /d "%~dp0\.."

set "NG_EXE=C:\Users\Administrator\AppData\Roaming\npm\ng.cmd"

echo Stopping existing Node.js processes...
taskkill /F /IM node.exe 2>nul

echo Waiting 5 seconds...
ping 127.0.0.1 -n 6 > nul

echo Starting Angular development server on port 4200...
start "Angular Dev Server" /B "%NG_EXE%" serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000

echo Waiting 30 seconds for server to start...
ping 127.0.0.1 -n 31 > nul

echo Checking if server started...
netstat -an | findstr ":4200" >nul
if %errorlevel% equ 0 (
    echo SUCCESS: Angular server is listening on port 4200
) else (
    echo WARNING: Port 4200 not found in netstat
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
echo     cd /d "%CD%"
echo     start "Angular Dev Server" /B "%NG_EXE%" serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000
echo ^)
echo goto loop
) > "C:\monitor-angular.bat"

start "Angular Monitor" /MIN "C:\monitor-angular.bat"

echo Angular server started successfully