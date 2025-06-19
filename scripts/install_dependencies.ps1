# Simple Working Angular Install Script
$logFile = "C:\application-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "Installing Angular dependencies - SIMPLE VERSION"
Add-Content -Path $logFile -Value "$timestamp - Starting simple dependency installation"

# Go to app directory
Set-Location "C:\app"
Add-Content -Path $logFile -Value "$timestamp - Changed to C:\app"

# Set up Node.js path
$nodePath = "C:\Program Files\nodejs"
$npmGlobalPath = "C:\Users\Administrator\AppData\Roaming\npm"

# Add to system PATH
$systemPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
if ($systemPath -notlike "*$nodePath*") {
    [Environment]::SetEnvironmentVariable("PATH", "$systemPath;$nodePath;$npmGlobalPath", [EnvironmentVariableTarget]::Machine)
    Add-Content -Path $logFile -Value "$timestamp - Added Node.js to system PATH"
}

# Set current session PATH
$env:PATH = "$nodePath;$npmGlobalPath;$env:PATH"

# Verify setup
if (-not (Test-Path "$nodePath\node.exe")) {
    Add-Content -Path $logFile -Value "$timestamp - ERROR: Node.js not found"
    exit 1
}

if (-not (Test-Path "package.json")) {
    Add-Content -Path $logFile -Value "$timestamp - ERROR: package.json not found"
    exit 1
}

Add-Content -Path $logFile -Value "$timestamp - Node.js and package.json verified"

# Simple npm install
Write-Host "Running npm install..."
Add-Content -Path $logFile -Value "$timestamp - Running npm install"

$npmCmd = "$nodePath\npm.cmd"
$installResult = & $npmCmd install 2>&1
Add-Content -Path $logFile -Value "$timestamp - npm install result: $installResult"

if ($LASTEXITCODE -ne 0) {
    Add-Content -Path $logFile -Value "$timestamp - npm install failed, trying cache clean"
    & $npmCmd cache clean --force
    $installResult = & $npmCmd install 2>&1
    Add-Content -Path $logFile -Value "$timestamp - Second npm install result: $installResult"
}

# Install Angular CLI globally
Write-Host "Installing Angular CLI..."
Add-Content -Path $logFile -Value "$timestamp - Installing Angular CLI globally"
& $npmCmd install -g @angular/cli

# Verify installation
if (Test-Path "node_modules\@angular\core") {
    Add-Content -Path $logFile -Value "$timestamp - SUCCESS: @angular/core found"
} else {
    Add-Content -Path $logFile -Value "$timestamp - ERROR: @angular/core not found"
}

if (Test-Path "node_modules\@angular-devkit\build-angular") {
    Add-Content -Path $logFile -Value "$timestamp - SUCCESS: @angular-devkit/build-angular found"
} else {
    Add-Content -Path $logFile -Value "$timestamp - ERROR: @angular-devkit/build-angular not found"
}

# Configure firewall
netsh advfirewall firewall delete rule name="Angular Dev Server" 2>$null
netsh advfirewall firewall add rule name="Angular Dev Server" dir=in action=allow protocol=TCP localport=4200
Add-Content -Path $logFile -Value "$timestamp - Firewall configured"

Add-Content -Path $logFile -Value "$timestamp - Simple installation completed"
Write-Host "Installation completed"
exit 0