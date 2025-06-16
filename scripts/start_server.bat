@echo off
echo Configuring IIS for Angular app...

REM Create application pool if it doesn't exist
%SystemRoot%\system32\inetsrv\appcmd.exe list apppool "AngularAppPool" >nul 2>&1
if %errorlevel% neq 0 (
    echo Creating application pool...
    %SystemRoot%\system32\inetsrv\appcmd.exe add apppool /name:"AngularAppPool" /managedRuntimeVersion:""
)

REM Create web application in IIS
%SystemRoot%\system32\inetsrv\appcmd.exe list app "Default Web Site/AngularApp" >nul 2>&1
if %errorlevel% neq 0 (
    echo Creating IIS application...
    %SystemRoot%\system32\inetsrv\appcmd.exe add app /site.name:"Default Web Site" /path:/AngularApp /physicalPath:C:\inetpub\wwwroot\dist
)

REM Start IIS
echo Starting IIS...
iisreset /start

echo IIS configured and started for Angular app