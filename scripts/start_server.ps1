# Start Angular Server for CodeDeploy
$logFile = "C:\application-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Content -Path $logFile -Value "$timestamp - Starting Angular server script"

# Navigate to application directory
Set-Location "C:\app"
Add-Content -Path $logFile -Value "$timestamp - Changed to directory: C:\app"

# Set PATH
$env:PATH = "C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;$env:PATH"
Add-Content -Path $logFile -Value "$timestamp - Updated PATH for current session"

Write-Host "Starting Angular server..."
Add-Content -Path $logFile -Value "$timestamp - Attempting to start Angular server"

# Kill any existing Angular processes first
Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*ng serve*" } | Stop-Process -Force
Add-Content -Path $logFile -Value "$timestamp - Killed any existing Angular processes"

# Create batch script to start server
@"
@echo off
set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;%PATH%"
cd /d C:\app
echo Starting ng serve with development configuration... >> C:\application-log.txt
ng serve --configuration=development --host 0.0.0.0 --port 4200 --disable-host-check >> C:\application-log.txt 2>&1
"@ | Out-File -FilePath "start_ng.bat" -Encoding ASCII

Add-Content -Path $logFile -Value "$timestamp - Created start_ng.bat script with development configuration"

# Start the server in background
Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "start_ng.bat" -WindowStyle Hidden
Add-Content -Path $logFile -Value "$timestamp - Started Angular server process"

# Wait for server to initialize
Add-Content -Path $logFile -Value "$timestamp - Waiting 30 seconds for server to start"
Start-Sleep -Seconds 30

# Check if server is running on port 4200
$serverRunning = $false
try {
    $connection = Test-NetConnection -ComputerName "localhost" -Port 4200 -ErrorAction SilentlyContinue
    if ($connection.TcpTestSucceeded) {
        $serverRunning = $true
        Add-Content -Path $logFile -Value "$timestamp - ✓ Angular server is running on port 4200"
        Write-Host "✓ Angular server is running on port 4200"
    }
} catch {
    Add-Content -Path $logFile -Value "$timestamp - Could not test port 4200 connectivity"
}

# Alternative check using netstat
if (-not $serverRunning) {
    $netstatResult = netstat -an | Select-String ":4200"
    if ($netstatResult) {
        Add-Content -Path $logFile -Value "$timestamp - ✓ Port 4200 is listening (netstat check)"
        Write-Host "✓ Port 4200 is listening"
        $serverRunning = $true
    } else {
        Add-Content -Path $logFile -Value "$timestamp - ⚠ Port 4200 is not listening"
        Write-Host "⚠ Port 4200 is not listening"
    }
}

# Check for running node processes
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    Add-Content -Path $logFile -Value "$timestamp - Found $($nodeProcesses.Count) Node.js process(es) running"
    foreach ($process in $nodeProcesses) {
        Add-Content -Path $logFile -Value "$timestamp - Node process PID: $($process.Id)"
    }
} else {
    Add-Content -Path $logFile -Value "$timestamp - ⚠ No Node.js processes found running"
}

# Cleanup
Remove-Item "start_ng.bat" -Force -ErrorAction SilentlyContinue
Add-Content -Path $logFile -Value "$timestamp - Cleaned up start_ng.bat"

$finalTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
if ($serverRunning) {
    Add-Content -Path $logFile -Value "$finalTimestamp - Angular server started successfully"
    Write-Host "Angular server started successfully"
} else {
    Add-Content -Path $logFile -Value "$finalTimestamp - Angular server may not have started properly"
    Write-Host "Angular server may not have started properly"
}

exit 0