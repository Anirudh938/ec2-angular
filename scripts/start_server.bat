@echo off

cd /d "%~dp0\.."

set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;%PATH%"

taskkill /F /IM node.exe 2>nul

start "Angular" /MIN ng serve --host 0.0.0.0 --port 4200 --disable-host-check

ping 127.0.0.1 -n 46 >nul

netstat -an | findstr ":4200"

echo Startup completed