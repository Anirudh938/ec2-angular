@echo off
echo Starting Angular development server with direct Node.js...

cd /d "%~dp0\.."

set "NODE_EXE=C:\Program Files\nodejs\node.exe"
set "NPX_EXE=C:\Program Files\nodejs\npx.cmd"

echo Verifying Node.js...
"%NODE_EXE%" --version
if %errorlevel% neq 0 (
    echo ERROR: Node.js not found
    exit /b 1
)

echo Stopping existing Node.js processes...
taskkill /F /IM node.exe 2>nul

echo Waiting 5 seconds...
ping 127.0.0.1 -n 6 > nul

echo Starting Angular development server using npx...
start "Angular Dev Server" /B "%NPX_EXE%" ng serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000

echo Waiting 45 seconds for server to start...
ping 127.0.0.1 -n 46 > nul

echo Checking if server started...
netstat -an | findstr ":4200" >nul
if %errorlevel% equ 0 (
    echo SUCCESS: Angular server is listening on port 4200
) else (
    echo WARNING: Port 4200 not found, checking processes...
    tasklist | findstr node.exe
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
echo     start "Angular Dev Server" /B "%NPX_EXE%" ng serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000
echo ^)
echo goto loop
) > "C:\monitor-angular.bat"

start "Angular Monitor" /MIN "C:\monitor-angular.bat"

echo Angular server startup completed