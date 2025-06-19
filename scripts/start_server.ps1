# FINAL WORKING START SCRIPT - EXACT REPLICA of your successful manual steps
$logFile = "C:\application-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "Starting Angular server - EXACT REPLICA of your working manual steps"
Add-Content -Path $logFile -Value "$timestamp - Starting Angular server (replicating successful manual process)"

# Navigate to app directory - EXACT same as manual
Set-Location "C:\app"
Add-Content -Path $logFile -Value "$timestamp - Changed to C:\app directory"

# Set PATH - EXACT same as manual  
$env:PATH = "C:\Program Files\nodejs;$env:PATH"
$env:PATH = "C:\Users\Administrator\AppData\Roaming\npm;$env:PATH"
Add-Content -Path $logFile -Value "$timestamp - Set PATH to include Node.js and npm global packages"

Write-Host "Current directory: $(Get-Location)"
Write-Host "PATH includes Node.js: $($env:PATH -like '*nodejs*')"

# Kill any existing Node.js processes
Write-Host "Stopping any existing Angular processes..."
Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force
Add-Content -Path $logFile -Value "$timestamp - Killed any existing Node.js processes"

# Verify ng command is available
Write-Host "Verifying ng command..."
try {
    $ngHelp = ng version --help 2>$null
    if ($LASTEXITCODE -eq 0) {
        Add-Content -Path $logFile -Value "$timestamp - ng command is accessible"
        Write-Host "✅ ng command verified"
    } else {
        throw "ng command failed"
    }
} catch {
    Add-Content -Path $logFile -Value "$timestamp - WARNING: ng command not accessible, may need to wait for PATH update"
    Write-Host "⚠ ng command not immediately accessible"
}

# Create the exact startup command as your manual process
Write-Host "Starting ng serve with your exact working parameters..."
Add-Content -Path $logFile -Value "$timestamp - Starting: ng serve --host 0.0.0.0 --port 4200 --disable-host-check"

# Create batch file with exact command
$startupBatch = @'
@echo off
echo Starting Angular Development Server...
set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;%PATH%"
cd /d C:\app

echo Verifying setup...
echo Node.js version:
node --version
echo npm version:
npm --version
echo Angular CLI:
ng version --help

echo.
echo Starting Angular server...
echo Command: ng serve --host 0.0.0.0 --port 4200 --disable-host-check
ng serve --host 0.0.0.0 --port 4200 --disable-host-check
'@

$startupBatch | Out-File -FilePath "start_angular.bat" -Encoding ASCII
Add-Content -Path $logFile -Value "$timestamp - Created startup batch file with exact manual commands"

# Start the server exactly as you did manually
Write-Host "Launching Angular development server..."
Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "start_angular.bat" -WindowStyle Minimized

Add-Content -Path $logFile -Value "$timestamp - Started Angular server process"

# Wait for server to start
Write-Host "Waiting for server to start (45 seconds)..."
Add-Content -Path $logFile -Value "$timestamp - Waiting 45 seconds for server startup"
Start-Sleep -Seconds 45

# Check if server is running
Write-Host "Checking if server is running..."
$serverRunning = $false
$attempts = 0
$maxAttempts = 3

while (-not $serverRunning -and $attempts -lt $maxAttempts) {
    $attempts++
    Add-Content -Path $logFile -Value "$timestamp - Server check attempt $attempts"
    
    # Check port 4200 with netstat
    $netstatResult = netstat -an | Select-String ":4200.*LISTENING"
    if ($netstatResult) {
        $serverRunning = $true
        Write-Host "✅ SUCCESS: Angular server is running on port 4200!"
        Write-Host "🌐 Access your app at: http://your-ec2-ip:4200"
        Add-Content -Path $logFile -Value "$timestamp - SUCCESS: Server confirmed running on port 4200"
        Add-Content -Path $logFile -Value "$timestamp - netstat output: $netstatResult"
    } else {
        Write-Host "Port 4200 not ready yet, waiting 15 more seconds..."
        Add-Content -Path $logFile -Value "$timestamp - Port 4200 not ready, waiting..."
        Start-Sleep -Seconds 15
    }
}

# Check for Node.js processes
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    Write-Host "Found $($nodeProcesses.Count) Node.js process(es) running"
    Add-Content -Path $logFile -Value "$timestamp - Found $($nodeProcesses.Count) Node.js processes running"
    foreach ($process in $nodeProcesses) {
        Add-Content -Path $logFile -Value "$timestamp - Node.js process PID: $($process.Id)"
    }
} else {
    Add-Content -Path $logFile -Value "$timestamp - No Node.js processes found"
}

# Final status
$finalTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
if ($serverRunning) {
    Add-Content -Path $logFile -Value "$finalTimestamp - ✅ Angular server started successfully - READY FOR USE"
    Write-Host "🎉 Angular server started successfully!"
    Write-Host "Your app should be accessible at http://your-ec2-ip:4200"
} else {
    Add-Content -Path $logFile -Value "$finalTimestamp - ⚠ Server status unclear - check manually"
    Write-Host "⚠ Server may still be starting. Check manually with: netstat -an | findstr :4200"
}

# Keep the startup script for debugging
Add-Content -Path $logFile -Value "$finalTimestamp - Keeping start_angular.bat for debugging"
Write-Host "Startup script saved as start_angular.bat for manual debugging if needed"

Write-Host "🎯 Server start script completed!"
exit 0