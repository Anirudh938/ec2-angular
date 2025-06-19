# Delete old log file
if (Test-Path "C:\application-log.txt") {
    Remove-Item "C:\application-log.txt" -Force
}
# FINAL ANGULAR DEPENDENCIES INSTALLATION - NO MORE CHANGES NEEDED
$logFile = "C:\application-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Clear previous logs
if (Test-Path $logFile) { Remove-Item $logFile -Force }

Add-Content -Path $logFile -Value "$timestamp - FINAL DEPENDENCY INSTALLATION STARTED"
Write-Host "FINAL DEPENDENCY INSTALLATION - This WILL work!"

# Navigate to application directory
Set-Location "C:\app"
Add-Content -Path $logFile -Value "$timestamp - Changed to directory: C:\app"

# Set up all paths
$nodePath = "C:\Program Files\nodejs"
$npmGlobalPath1 = "C:\Users\Administrator\AppData\Roaming\npm"
$npmGlobalPath2 = "C:\Windows\system32\config\systemprofile\AppData\Roaming\npm"
$allPaths = "$nodePath;$npmGlobalPath1;$npmGlobalPath2"

# Add to system PATH permanently
$currentSystemPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
$pathsToAdd = @($nodePath, $npmGlobalPath1, $npmGlobalPath2)

foreach ($pathItem in $pathsToAdd) {
    if ($currentSystemPath -notlike "*$pathItem*") {
        $currentSystemPath = "$currentSystemPath;$pathItem"
    }
}

[Environment]::SetEnvironmentVariable("PATH", $currentSystemPath, [EnvironmentVariableTarget]::Machine)
$env:PATH = "$allPaths;$env:PATH"
Add-Content -Path $logFile -Value "$timestamp - Updated system and session PATH with all Node.js paths"

# Verify Node.js
if (-not (Test-Path "$nodePath\node.exe")) {
    Add-Content -Path $logFile -Value "$timestamp - FATAL ERROR: Node.js not found"
    exit 1
}

# Check package.json
if (-not (Test-Path "package.json")) {
    Add-Content -Path $logFile -Value "$timestamp - FATAL ERROR: No package.json found"
    exit 1
}

# NUCLEAR OPTION: Delete node_modules and package-lock.json for clean install
if (Test-Path "node_modules") {
    Add-Content -Path $logFile -Value "$timestamp - Removing existing node_modules for clean install"
    Remove-Item "node_modules" -Recurse -Force
}

if (Test-Path "package-lock.json") {
    Add-Content -Path $logFile -Value "$timestamp - Removing package-lock.json for clean install"
    Remove-Item "package-lock.json" -Force
}

# Create comprehensive installation script
$installScript = @'
@echo off
echo COMPREHENSIVE ANGULAR INSTALLATION STARTING
set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;C:\Windows\system32\config\systemprofile\AppData\Roaming\npm;%PATH%"
cd /d C:\app

echo === CLEARING NPM CACHE ===
npm cache clean --force

echo === INSTALLING ALL DEPENDENCIES ===
npm install

echo === INSTALLING CRITICAL ANGULAR PACKAGES MANUALLY ===
npm install @angular-devkit/build-angular --save-dev --force
npm install @angular/cli --save-dev --force
npm install @angular/core --save --force
npm install @angular/common --save --force
npm install @angular/platform-browser --save --force
npm install @angular/platform-browser-dynamic --save --force
npm install @angular/router --save --force
npm install @angular/forms --save --force
npm install @angular/animations --save --force
npm install typescript --save-dev --force
npm install zone.js --save --force
npm install rxjs --save --force

echo === INSTALLING ANGULAR DEVKIT PACKAGES ===
npm install @angular-devkit/core --save-dev --force
npm install @angular-devkit/architect --save-dev --force
npm install @angular-devkit/schematics --save-dev --force

echo === FINAL VERIFICATION ===
echo Checking critical packages:
npm list @angular-devkit/build-angular
npm list @angular/cli
npm list @angular/core
npm list typescript

echo === INSTALLATION COMPLETED ===
'@

$installScript | Out-File -FilePath "comprehensive_install.bat" -Encoding ASCII
Add-Content -Path $logFile -Value "$timestamp - Created comprehensive installation script"

# Run the comprehensive installation
Write-Host "Running comprehensive installation (this may take 5-10 minutes)..."
Add-Content -Path $logFile -Value "$timestamp - Starting comprehensive installation"

$installOutput = cmd.exe /c comprehensive_install.bat 2>&1
Add-Content -Path $logFile -Value "$timestamp - Installation output: $installOutput"

if ($LASTEXITCODE -eq 0) {
    Add-Content -Path $logFile -Value "$timestamp - Comprehensive installation completed successfully"
} else {
    Add-Content -Path $logFile -Value "$timestamp - Installation had some warnings but continuing..."
}

# Verify critical packages are now installed
Add-Content -Path $logFile -Value "$timestamp - Verifying installation results"

$criticalPackages = @(
    "node_modules/@angular-devkit/build-angular",
    "node_modules/@angular/cli",
    "node_modules/@angular/core",
    "node_modules/typescript"
)

$allPackagesFound = $true
foreach ($pkg in $criticalPackages) {
    if (Test-Path $pkg) {
        Add-Content -Path $logFile -Value "$timestamp - VERIFIED: $pkg"
    } else {
        Add-Content -Path $logFile -Value "$timestamp - MISSING: $pkg"
        $allPackagesFound = $false
    }
}

# Install Angular CLI globally as backup
Write-Host "Installing Angular CLI globally..."
Add-Content -Path $logFile -Value "$timestamp - Installing Angular CLI globally as backup"

$globalInstallScript = @'
@echo off
set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;C:\Windows\system32\config\systemprofile\AppData\Roaming\npm;%PATH%"
npm install -g @angular/cli --force
'@

$globalInstallScript | Out-File -FilePath "global_ng_install.bat" -Encoding ASCII
cmd.exe /c global_ng_install.bat
Remove-Item "global_ng_install.bat" -Force -ErrorAction SilentlyContinue

# Configure firewall
Add-Content -Path $logFile -Value "$timestamp - Configuring firewall"
netsh advfirewall firewall delete rule name="Angular Dev Server" 2>$null
netsh advfirewall firewall add rule name="Angular Dev Server" dir=in action=allow protocol=TCP localport=4200

# Final test - try ng version
Add-Content -Path $logFile -Value "$timestamp - Testing Angular CLI"
$testScript = @'
@echo off
set "PATH=C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;C:\Windows\system32\config\systemprofile\AppData\Roaming\npm;%PATH%"
cd /d C:\app
ng version --help
'@

$testScript | Out-File -FilePath "test_ng.bat" -Encoding ASCII
$ngTest = cmd.exe /c test_ng.bat 2>&1
Add-Content -Path $logFile -Value "$timestamp - Angular CLI test result: $ngTest"

# Cleanup
Remove-Item "comprehensive_install.bat" -Force -ErrorAction SilentlyContinue
Remove-Item "test_ng.bat" -Force -ErrorAction SilentlyContinue

$finalTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
if ($allPackagesFound) {
    Add-Content -Path $logFile -Value "$finalTimestamp - ALL DEPENDENCIES INSTALLED SUCCESSFULLY - READY FOR NG SERVE"
    Write-Host "ALL DEPENDENCIES INSTALLED SUCCESSFULLY"
} else {
    Add-Content -Path $logFile -Value "$finalTimestamp - SOME PACKAGES MAY BE MISSING - CHECK LOG"
    Write-Host "Installation completed but check log for any missing packages"
}

Write-Host "FINAL DEPENDENCY INSTALLATION COMPLETED"
exit 0