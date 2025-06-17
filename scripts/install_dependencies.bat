@echo off
echo Installing Angular dependencies and building...

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

REM Install dependencies
if exist package.json (
   echo Installing npm dependencies...
   "%NPM_EXE%" ci --only=production
   if %errorlevel% neq 0 (
       echo npm install failed
       exit /b 1
   )
) else (
   echo No package.json found
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

REM Build the Angular application for production
echo Building Angular application...
"%NG_EXE%" build --configuration production
if %errorlevel% neq 0 (
   echo Angular build failed
   exit /b 1
)

REM Set file permissions for IIS
echo Setting file permissions...
icacls "C:\inetpub\wwwroot" /grant "IIS_IUSRS:(OI)(CI)F" /T >nul 2>&1
icacls "C:\inetpub\wwwroot" /grant "IIS APPPOOL\DefaultAppPool:(OI)(CI)F" /T >nul 2>&1

echo Build completed successfully