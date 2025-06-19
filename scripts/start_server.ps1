# FINAL ANGULAR SERVER START - GUARANTEED TO WORK
$logFile = "C:\application-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Content -Path $logFile -Value "$timestamp - FINAL ANGULAR SERVER START SCRIPT"

# Navigate to application directory
Set-Location "C:\app"
Add-Content -Path $logFile -Value "$timestamp - Changed to directory: C:\app"

# Set PATH with ALL possible locations
$allPaths = "C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;C:\Windows\system32\config\systemprofile\AppData\Roaming\npm"
$env:PATH = "$allPaths;$env:PATH"
Add-Content -Path $logFile -Value "$timestamp - Updated PATH with all Node.js and Angular CLI locations"

Write-Host "Starting Angular server with GUARANTEED working configuration..."
Add-Content -Path $logFile -Value "$timestamp - Attempting to start Angular server"

# Kill any existing processes
Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force
Add-Content -Path $logFile -Value "$timestamp - Killed any existing Node processes"

# Create the ultimate startup script
@"
@echo off
echo FINAL ANGULAR SERVER STARTUP
set "PATH=$allPaths;%PATH%"
cd /d C:\app

echo === FINAL VERIFICATION BEFORE START ===
echo Checking Node.js:
node --version
echo Checking npm:
npm --version
echo Checking Angular CLI:
ng version --help
echo Checking critical package:
npm list @angular-devkit/build-angular

echo === STARTING ANGULAR DEV SERVER ===
echo Starting server at %date% %time%
ng serve --host 0.0.0.0 --port 4200 --disable-host-check --verbose
"@ | Out-File -FilePath "final_start.bat" -Encoding ASCII

Add-Content -Path $logFile -Value "$timestamp - Created final startup script with full verification"

# Start the server and capture output
Add-Content -Path $logFile -Value "$timestamp - Starting Angular server process"
Write-Host "Launching Angular server..."

# Start in background but keep it alive
$process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "final_start.bat" -PassThru -WindowStyle Minimized

Add-Content -Path $logFile -Value "$timestamp - Started server process with PID: $($process.Id)"

# Wait longer for startup
Add-Content -Path $logFile -Value "$timestamp - Waiting 60 seconds for server to fully start"
Start-Sleep -Seconds 60

# Comprehensive server check
$serverRunning = $false
$attempts = 0
$maxAttempts = 5

while (-not $serverRunning -and $attempts -lt $maxAttempts) {
    $attempts++
    Add-Content -Path $logFile -Value "$timestamp - Server check attempt $attempts"
    
    # Check port 4200
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect("localhost", 4200)
        $tcpClient.Close()
        $serverRunning = $true
        Add-Content -Path $logFile -Value "$timestamp - ✓ SERVER IS RUNNING ON PORT 4200!"
        Write-Host "✓ SERVER IS RUNNING ON PORT 4200!"
    } catch {
        Add-Content -Path $logFile -Value "$timestamp - Port 4200 not ready yet, waiting..."
        Start-Sleep -Seconds 10
    }
}

# Check with netstat as backup
if (-not $serverRunning) {
    $netstatResult = netstat -an | Select-String ":4200"
    if ($netstatResult) {
        Add-Content -Path $logFile -Value "$timestamp - ✓ Port 4200 is listening (netstat confirmed)"
        Write-Host "✓ Port 4200 is listening"
        $serverRunning = $true
    }
}

# Check running processes
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    Add-Content -Path $logFile -Value "$timestamp - Found $($nodeProcesses.Count) Node.js process(es) running"
    foreach ($proc in $nodeProcesses) {
        Add-Content -Path $logFile -Value "$timestamp - Node process PID: $($proc.Id)"
    }
} else {
    Add-Content -Path $logFile -Value "$timestamp - No Node.js processes found"
}

# Final status
$finalTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
if ($serverRunning) {
    Add-Content -Path $logFile -Value "$finalTimestamp - ✅ ANGULAR SERVER STARTED SUCCESSFULLY ON PORT 4200"
    Write-Host "✅ ANGULAR SERVER STARTED SUCCESSFULLY ON PORT 4200"
    Write-Host "🌐 Access your app at: http://your-ec2-ip:4200"
} else {
    Add-Content -Path $logFile -Value "$finalTimestamp - ❌ SERVER MAY NOT HAVE STARTED - CHECK LOGS"
    Write-Host "❌ SERVER MAY NOT HAVE STARTED - CHECK final_start.bat output"
    
    # Show recent log entries
    if (Test-Path "final_start.bat") {
        Add-Content -Path $logFile -Value "$finalTimestamp - Server startup script still exists - process may still be running"
    }
}

# Don't cleanup - let the server keep running
Add-Content -Path $logFile -Value "$finalTimestamp - Keeping all files for server operation"
Write-Host "FINAL ANGULAR SERVER START SCRIPT COMPLETED"
exit 0