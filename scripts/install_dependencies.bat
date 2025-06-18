@echo off
echo Installing Angular dependencies...

cd /d "%~dp0\.."

echo Current directory: %CD%
echo Files in directory:
dir /b

set "NODE_EXE=C:\Program Files\nodejs\node.exe"
set "NPM_EXE=C:\Program Files\nodejs\npm.cmd"
set "NG_EXE=C:\Users\Administrator\AppData\Roaming\npm\ng.cmd"

echo Checking Node.js installation...
if exist "%NODE_EXE%" (
    echo Node.js found at %NODE_EXE% >> C:\application-log.txt
) else (
    echo ERROR: Node.js not found at %NODE_EXE% >> C:\application-log.txt
    exit /b 1
)

if exist package.json (
    echo Found package.json, installing ALL dependencies including dev dependencies...
    REM Use npm install to get both prod and dev dependencies
    "%NPM_EXE%" install --prefer-offline --no-audit --no-fund
    if %errorlevel% neq 0 (
        echo npm install failed, trying without optimizations... >> C:\application-log.txt
        "%NPM_EXE%" install
        if %errorlevel% neq 0 (
            echo npm install failed completely >> C:\application-log.txt
            exit /b 1
        )
    )
    echo Dependencies installed successfully
) else (
    echo ERROR: No package.json found
    exit /b 1
)

if not exist "%NG_EXE%" (
    echo Installing Angular CLI...
    "%NPM_EXE%" install -g @angular/cli
    if %errorlevel% neq 0 (
        echo Angular CLI installation failed
        exit /b 1
    )
    echo Angular CLI installed successfully
) else (
    echo Angular CLI already installed
)

echo Configuring Windows Firewall...
netsh advfirewall firewall delete rule name="Angular Dev Server" 2>nul
netsh advfirewall firewall add rule name="Angular Dev Server" dir=in action=allow protocol=TCP localport=4200

echo Install script completed successfully