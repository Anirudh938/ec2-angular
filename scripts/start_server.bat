@echo off
chcp 65001 >nul

cd /d "%~dp0\.."

set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;%PATH%"

echo [%DATE% %TIME%] Starting Angular server... >> C:\userdata-log.txt

start /B "" ng serve --host 0.0.0.0 --port 4200 --disable-host-check >> C:\userdata-log.txt 2>&1

ping 127.0.0.1 -n 31 >nul

echo [%DATE% %TIME%] Angular server startup script completed. >> C:\userdata-log.txt
