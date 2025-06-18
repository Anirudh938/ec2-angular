@echo off
echo Starting Angular development server...

cd /d "%~dp0\.."
echo Current directory: %CD%

REM Set up environment
set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;%PATH%"
set "NG_EXE=C:\Users\Administrator\AppData\Roaming\npm\ng.cmd"

REM Kill existing processes
taskkill /F /IM node.exe 2>nul

REM Start Angular server
echo Starting Angular server on port 4200...
start "Angular Server" /MIN "%NG_EXE%" serve --host 0.0.0.0 --port 4200 --disable-host-check --poll 1000

REM Wait and check
echo Waiting 45 seconds for server to start...
timeout /t 45 /nobreak

REM Check if running
netstat -an | findstr ":4200" >nul
if %errorlevel% equ 0 (
    echo Angular server is running on port 4200
) else (
    echo Checking node processes...
    tasklist | findstr node.exe
)

echo Startup completed