@echo off
echo Installing Angular dependencies...

REM Navigate to the deployment archive directory where files are extracted
cd /d "%~dp0\.."

echo Current directory after navigation: %CD%
echo Files in current directory:
dir /b

REM Set Node.js paths
set "NODE_EXE=C:\Program Files\nodejs\node.exe"
set "NPM_EXE=C:\Program Files\nodejs\npm.cmd"
set "NG_EXE=C:\Users\Administrator\AppData\Roaming\npm\ng.cmd"

REM Check if Node.js is installed
"%NODE_EXE%" --version >nul 2>&1
if %errorlevel% neq 0 (
   echo Node.js not found at C:\Program Files\nodejs\node.exe
   exit /b 1
)

REM Install ALL dependencies (dev dependencies needed for ng serve)
if exist package.json (
   echo Installing npm dependencies (including dev dependencies)...
   "%NPM_EXE%" install
   if %errorlevel% neq 0 (
       echo npm install failed
       exit /b 1
   )
) else (
   echo No package.json found in %CD%
   echo Available files:
   dir
   exit /b 1
)

REM Install Angular CLI globally if not present
if not exist "%NG_EXE%" (
   echo Installing Angular CLI...
   "%NPM_EXE%" install -g @angular/cli
   if %errorlevel% neq 0 (
       echo Angular CLI installation failed
       exit /b 1
   )
)

REM Configure Windows Firewall for port 4200
echo Configuring Windows Firewall for port 4200...
netsh advfirewall firewall delete rule name="Angular Dev Server" 2>nul
netsh advfirewall firewall add rule name="Angular Dev Server" dir=in action=allow protocol=TCP localport=4200

echo Dependencies installed successfully