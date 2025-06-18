@echo off

cd /d "%~dp0\.."

set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;%PATH%"

taskkill /F /IM node.exe 2>nul

set "NG_CLI_ANALYTICS=false"

echo Starting Angular server... >> C:\userdata-log.txt

start /B "" ng serve --host 0.0.0.0 --port 4200 --disable-host-check >nul 2>&1

ping 127.0.0.1 -n 31 >nul

echo Angular server startup script completed. >> C:\userdata-log.txt