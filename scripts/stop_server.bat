@echo off
echo Stopping IIS and Angular processes...

REM Stop IIS
iisreset /stop

REM Kill any existing Angular dev server processes (if any)
taskkill /f /im node.exe 2>nul
taskkill /f /im ng.exe 2>nul

echo Services stopped successfully