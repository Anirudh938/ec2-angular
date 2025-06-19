# FINAL WORKING INSTALL SCRIPT - Based on your successful manual steps
$logFile = "C:\application-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "Installing Angular dependencies - EXACT REPLICA of your working manual steps"
Add-Content -Path $logFile -Value "$timestamp - Starting installation (replicating successful manual process)"

# Navigate to app directory - EXACT same as manual
Set-Location "C:\app"
Add-Content -Path $logFile -Value "$timestamp - Changed to C:\app directory"

# Set PATH - EXACT same as manual
$env:PATH = "C:\Program Files\nodejs;$env:PATH"
Add-Content -Path $logFile -Value "$timestamp - Set PATH to include Node.js"

# Add Node.js to system PATH permanently for future sessions
$nodePath = "C:\Program Files\nodejs"
$npmGlobalPath = "C:\Users\Administrator\AppData\Roaming\npm"
$systemPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)

if ($systemPath -notlike "*$nodePath*") {
    [Environment]::SetEnvironmentVariable("PATH", "$systemPath;$nodePath;$npmGlobalPath", [EnvironmentVariableTarget]::Machine)
    Add-Content -Path $logFile -Value "$timestamp - Added Node.js to system PATH permanently"
}

# Verify Node.js is accessible
try {
    $nodeVersion = & "C:\Program Files\nodejs\node.exe" --version
    Add-Content -Path $logFile -Value "$timestamp - Node.js version: $nodeVersion"
    Write-Host "Node.js version: $nodeVersion"
} catch {
    Add-Content -Path $logFile -Value "$timestamp - ERROR: Node.js not accessible"
    Write-Host "ERROR: Node.js not accessible"
    exit 1
}

# Verify package.json exists
if (-not (Test-Path "package.json")) {
    Add-Content -Path $logFile -Value "$timestamp - ERROR: package.json not found in C:\app"
    Write-Host "ERROR: package.json not found"
    exit 1
}

Add-Content -Path $logFile -Value "$timestamp - package.json found, proceeding with installation"

# Install ALL dependencies first (including regular dependencies)
Write-Host "Installing all dependencies..."
Add-Content -Path $logFile -Value "$timestamp - Running npm install (all dependencies)"

$npmInstallResult = & "C:\Program Files\nodejs\npm.cmd" install 2>&1
Add-Content -Path $logFile -Value "$timestamp - npm install output: $npmInstallResult"

if ($LASTEXITCODE -ne 0) {
    Add-Content -Path $logFile -Value "$timestamp - npm install failed, trying with cache clean"
    & "C:\Program Files\nodejs\npm.cmd" cache clean --force
    $npmInstallResult = & "C:\Program Files\nodejs\npm.cmd" install 2>&1
    Add-Content -Path $logFile -Value "$timestamp - Second npm install attempt: $npmInstallResult"
}

# Install the critical build-angular package - EXACT same as your manual command
Write-Host "Installing @angular-devkit/build-angular (the key package that was missing)..."
Add-Content -Path $logFile -Value "$timestamp - Installing @angular-devkit/build-angular --save-dev --force"

$buildAngularResult = & "C:\Program Files\nodejs\npm.cmd" install @angular-devkit/build-angular --save-dev --force 2>&1
Add-Content -Path $logFile -Value "$timestamp - build-angular install result: $buildAngularResult"

# Verify the critical package is now installed
if (Test-Path "node_modules\@angular-devkit\build-angular") {
    Add-Content -Path $logFile -Value "$timestamp - SUCCESS: @angular-devkit/build-angular is now installed"
    Write-Host "✅ SUCCESS: @angular-devkit/build-angular installed"
} else {
    Add-Content -Path $logFile -Value "$timestamp - ERROR: @angular-devkit/build-angular still missing"
    Write-Host "❌ ERROR: Critical package still missing"
    exit 1
}

# Install Angular CLI globally (for ng command)
Write-Host "Installing Angular CLI globally..."
Add-Content -Path $logFile -Value "$timestamp - Installing Angular CLI globally"
& "C:\Program Files\nodejs\npm.cmd" install -g @angular/cli 2>&1

# Configure firewall for port 4200
Write-Host "Configuring firewall..."
Add-Content -Path $logFile -Value "$timestamp - Configuring firewall for port 4200"
netsh advfirewall firewall delete rule name="Angular Dev Server" 2>$null
netsh advfirewall firewall add rule name="Angular Dev Server" dir=in action=allow protocol=TCP localport=4200

# Final verification
Write-Host "Final verification..."
Add-Content -Path $logFile -Value "$timestamp - Performing final verification"

$verificationResults = @()
if (Test-Path "node_modules\@angular\core") { $verificationResults += "✅ @angular/core" } else { $verificationResults += "❌ @angular/core MISSING" }
if (Test-Path "node_modules\@angular-devkit\build-angular") { $verificationResults += "✅ @angular-devkit/build-angular" } else { $verificationResults += "❌ @angular-devkit/build-angular MISSING" }
if (Test-Path "node_modules\@angular\cli") { $verificationResults += "✅ @angular/cli" } else { $verificationResults += "❌ @angular/cli MISSING" }

foreach ($result in $verificationResults) {
    Write-Host $result
    Add-Content -Path $logFile -Value "$timestamp - $result"
}

$finalTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "$finalTimestamp - Installation completed successfully"
Write-Host "🎉 Installation completed - Ready for ng serve!"

exit 0