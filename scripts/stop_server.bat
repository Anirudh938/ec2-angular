@echo off
echo Starting deployment preparation...

REM Log the start
echo %date% %time% - BeforeInstall script started >> C:\codedeploy-debug.log

REM Gracefully stop IIS sites instead of hard reset
echo Stopping IIS sites gracefully...
for /f "tokens=*" %%i in ('"%systemroot%\system32\inetsrv\appcmd.exe" list sites /text:name') do (
    echo Stopping site: %%i
    "%systemroot%\system32\inetsrv\appcmd.exe" stop site "%%i" >> C:\codedeploy-debug.log 2>&1
)

REM Wait a moment for sites to stop
timeout /t 5 /nobreak

REM Stop application pools
echo Stopping application pools...
for /f "tokens=*" %%i in ('"%systemroot%\system32\inetsrv\appcmd.exe" list apppool /text:name') do (
    echo Stopping app pool: %%i
    "%systemroot%\system32\inetsrv\appcmd.exe" stop apppool "%%i" >> C:\codedeploy-debug.log 2>&1
)

REM Wait for app pools to stop
timeout /t 5 /nobreak

REM Kill any remaining processes
echo Killing Node.js processes...
taskkill /f /im node.exe 2>nul
taskkill /f /im ng.exe 2>nul

REM Verify CodeDeploy agent is still running
sc query codedeployagent >> C:\codedeploy-debug.log 2>&1

echo %date% %time% - BeforeInstall script completed >> C:\codedeploy-debug.log
echo Deployment preparation completed successfully
exit /b 0