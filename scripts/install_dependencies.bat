@echo off
echo Installing Angular dependencies and building...

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
   echo Node.js not found! Please install Node.js first.
   exit /b 1
)

REM Install dependencies
if exist package.json (
   echo Installing npm dependencies...
   npm ci --only=production
   if %errorlevel% neq 0 (
       echo npm install failed
       exit /b 1
   )
) else (
   echo No package.json found
   exit /b 1
)

REM Install Angular CLI globally if not present
ng version >nul 2>&1
if %errorlevel% neq 0 (
   echo Installing Angular CLI...
   npm install -g @angular/cli
)

REM Build the Angular application for production
echo Building Angular application...
ng build --configuration production
if %errorlevel% neq 0 (
   echo Angular build failed
   exit /b 1
)

REM Set file permissions for IIS
echo Setting file permissions...
icacls "C:\inetpub\wwwroot" /grant "IIS_IUSRS:(OI)(CI)F" /T >nul 2>&1
icacls "C:\inetpub\wwwroot" /grant "IIS APPPOOL\DefaultAppPool:(OI)(CI)F" /T >nul 2>&1

echo Build completed successfully