# Delete old log file
if (Test-Path "C:\application-log.txt") {
    Remove-Item "C:\application-log.txt" -Force
}
# Install Dependencies for CodeDeploy
$logFile = "C:\application-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-Content -Path $logFile -Value "$timestamp - Starting dependency installation"
Write-Host "Installing Angular dependencies..."

# Navigate to application directory
Set-Location "C:\app"
Add-Content -Path $logFile -Value "$timestamp - Changed to directory: C:\app"

# Add Node.js to system PATH permanently
$nodePath = "C:\Program Files\nodejs"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)

if ($currentPath -notlike "*$nodePath*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$nodePath", [EnvironmentVariableTarget]::Machine)
    Add-Content -Path $logFile -Value "$timestamp - Added Node.js to system PATH: $nodePath"
    Write-Host "Added Node.js to system PATH"
} else {
    Add-Content -Path $logFile -Value "$timestamp - Node.js already in system PATH"
}

# Set PATH for current session
$env:PATH = "$nodePath;$env:PATH"
Add-Content -Path $logFile -Value "$timestamp - Updated current session PATH"

# Verify Node.js
if (-not (Test-Path "$nodePath\node.exe")) {
    $errorMsg = "ERROR: Node.js not found at $nodePath"
    Add-Content -Path $logFile -Value "$timestamp - $errorMsg"
    Write-Host $errorMsg
    exit 1
}

Add-Content -Path $logFile -Value "$timestamp - Node.js verified at $nodePath\node.exe"

# Check package.json
if (-not (Test-Path "package.json")) {
    $errorMsg = "ERROR: No package.json found in C:\app"
    Add-Content -Path $logFile -Value "$timestamp - $errorMsg"
    Write-Host $errorMsg
    exit 1
}

Add-Content -Path $logFile -Value "$timestamp - Found package.json in C:\app"

# Create batch script to ensure proper environment and install required packages
@"
@echo off
set "PATH=$nodePath;C:\Users\Administrator\AppData\Roaming\npm;C:\Windows\system32\config\systemprofile\AppData\Roaming\npm;%PATH%"
cd /d C:\app
echo Installing all dependencies including dev dependencies... >> C:\application-log.txt
npm install
echo Checking for missing Angular build tools... >> C:\application-log.txt
npm list @angular-devkit/build-angular >> C:\application-log.txt 2>&1
if errorlevel 1 (
    echo @angular-devkit/build-angular is missing, installing... >> C:\application-log.txt
    npm install @angular-devkit/build-angular --save-dev --force
) else (
    echo @angular-devkit/build-angular is already installed >> C:\application-log.txt
)
echo Verifying other Angular packages... >> C:\application-log.txt
npm list @angular/cli >> C:\application-log.txt 2>&1
npm list @angular/core >> C:\application-log.txt 2>&1
npm list typescript >> C:\application-log.txt 2>&1
if errorlevel 1 (
    echo Installing missing Angular packages... >> C:\application-log.txt
    npm install typescript --save-dev --force
)
echo Final package verification... >> C:\application-log.txt
npm list @angular-devkit/build-angular @angular/cli @angular/core typescript >> C:\application-log.txt 2>&1
"@ | Out-File -FilePath "npm_install.bat" -Encoding ASCII

Add-Content -Path $logFile -Value "$timestamp - Created comprehensive npm install batch script with both Angular CLI paths"

# Run npm install
Write-Host "Installing npm dependencies..."
Add-Content -Path $logFile -Value "$timestamp - Starting npm install"

cmd.exe /c npm_install.bat

if ($LASTEXITCODE -ne 0) {
    $errorMsg = "ERROR: npm install failed with exit code $LASTEXITCODE"
    Add-Content -Path $logFile -Value "$timestamp - $errorMsg"
    Write-Host $errorMsg
    exit 1
}

Add-Content -Path $logFile -Value "$timestamp - npm install completed successfully"

# Verify critical Angular packages are installed
Add-Content -Path $logFile -Value "$timestamp - Verifying Angular packages installation"
@"
@echo off
set "PATH=$nodePath;%PATH%"
cd /d C:\app
echo Checking Angular CLI locally... >> C:\application-log.txt
npm list @angular/cli >> C:\application-log.txt 2>&1
echo Checking Angular Core... >> C:\application-log.txt
npm list @angular/core >> C:\application-log.txt 2>&1
echo Checking build-angular... >> C:\application-log.txt
npm list @angular-devkit/build-angular >> C:\application-log.txt 2>&1
"@ | Out-File -FilePath "verify_packages.bat" -Encoding ASCII

cmd.exe /c verify_packages.bat
Remove-Item "verify_packages.bat" -Force -ErrorAction SilentlyContinue

# Install Angular CLI globally
@"
@echo off
set "PATH=$nodePath;%PATH%"
npm install -g @angular/cli
"@ | Out-File -FilePath "ng_install.bat" -Encoding ASCII

Write-Host "Installing Angular CLI..."
Add-Content -Path $logFile -Value "$timestamp - Starting Angular CLI installation"

cmd.exe /c ng_install.bat

if ($LASTEXITCODE -ne 0) {
    Add-Content -Path $logFile -Value "$timestamp - WARNING: Angular CLI installation failed with exit code $LASTEXITCODE"
} else {
    Add-Content -Path $logFile -Value "$timestamp - Angular CLI installed successfully"
}

# Configure firewall
Add-Content -Path $logFile -Value "$timestamp - Configuring firewall for Angular Dev Server"
netsh advfirewall firewall delete rule name="Angular Dev Server" 2>$null
netsh advfirewall firewall add rule name="Angular Dev Server" dir=in action=allow protocol=TCP localport=4200

if ($LASTEXITCODE -eq 0) {
    Add-Content -Path $logFile -Value "$timestamp - Firewall rule configured successfully"
} else {
    Add-Content -Path $logFile -Value "$timestamp - WARNING: Firewall configuration may have failed"
}

# Cleanup
Remove-Item "npm_install.bat" -Force -ErrorAction SilentlyContinue
Remove-Item "ng_install.bat" -Force -ErrorAction SilentlyContinue
Add-Content -Path $logFile -Value "$timestamp - Cleaned up temporary batch files"

$finalTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "$finalTimestamp - Dependencies installed successfully - Script completed"
Write-Host "Dependencies installed successfully"
exit 0