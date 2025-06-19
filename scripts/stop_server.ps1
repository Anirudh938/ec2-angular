# PowerShell deployment preparation script
Write-Host "Starting deployment preparation..."

# Log the start
$logFile = "C:\codedeploy-debug.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "$timestamp - BeforeInstall script started"

# Gracefully stop IIS sites instead of hard reset
Write-Host "Stopping IIS sites gracefully..."

$sites = & "$env:SystemRoot\system32\inetsrv\appcmd.exe" list sites /text:name
foreach ($site in $sites) {
    if ($site.Trim()) {
        Write-Host "Stopping site: $site"
        & "$env:SystemRoot\system32\inetsrv\appcmd.exe" stop site "$site" *>> $logFile
    }
}

# Wait a moment for sites to stop
Start-Sleep -Seconds 5

# Stop application pools
Write-Host "Stopping application pools..."

$appPools = & "$env:SystemRoot\system32\inetsrv\appcmd.exe" list apppool /text:name
foreach ($appPool in $appPools) {
    if ($appPool.Trim()) {
        Write-Host "Stopping app pool: $appPool"
        & "$env:SystemRoot\system32\inetsrv\appcmd.exe" stop apppool "$appPool" *>> $logFile
    }
}

# Wait for app pools to stop
Start-Sleep -Seconds 5

# Kill any remaining processes
Write-Host "Killing Node.js processes..."

Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "ng" -ErrorAction SilentlyContinue | Stop-Process -Force

# Verify CodeDeploy agent is still running
Get-Service -Name "codedeployagent" *>> $logFile

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "$timestamp - BeforeInstall script completed"
Write-Host "Deployment preparation completed successfully"

exit 0