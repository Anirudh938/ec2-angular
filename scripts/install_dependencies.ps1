# Simple Angular Dependencies Installation Script

# Delete old log file
if (Test-Path "C:\application-log.txt") {
    Remove-Item "C:\application-log.txt" -Force
}

Write-Host "Installing Angular dependencies..."

# Go to parent directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$parentPath = Split-Path -Parent $scriptPath
Set-Location $parentPath

Write-Host "Current directory: $(Get-Location)"

# Set paths
$nodePath = "C:\Program Files\nodejs"
$npmPath = "C:\Program Files\nodejs\npm.cmd"

# Add Node.js to system PATH permanently
$systemPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
if ($systemPath -notlike "*$nodePath*") {
    Write-Host "Adding Node.js to system PATH..."
    [Environment]::SetEnvironmentVariable("PATH", "$systemPath;$nodePath", [EnvironmentVariableTarget]::Machine)
}

# Set PATH for current session
$env:PATH = "$nodePath;$env:PATH"

# Check Node.js
if (-not (Test-Path "$nodePath\node.exe")) {
    Write-Host "ERROR: Node.js not found!"
    exit 1
}

Write-Host "Node.js found"

# Check package.json
if (-not (Test-Path "package.json")) {
    Write-Host "ERROR: No package.json found"
    exit 1
}

# Install dependencies using batch command to ensure proper PATH
$batchCommand = @"
@echo off
set "PATH=$nodePath;%PATH%"
cd /d "$(Get-Location)"
"$npmPath" install
"@

$batchCommand | Out-File -FilePath "install.bat" -Encoding ASCII

Write-Host "Installing dependencies..."
cmd.exe /c install.bat

if ($LASTEXITCODE -eq 0) {
    Write-Host "Dependencies installed successfully"
} else {
    Write-Host "ERROR: npm install failed"
    exit 1
}

# Install Angular CLI
Write-Host "Installing Angular CLI..."
cmd.exe /c "set PATH=$nodePath;%PATH% && `"$npmPath`" install -g @angular/cli"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Angular CLI installed successfully"
} else {
    Write-Host "ERROR: Angular CLI installation failed"
}

# Configure firewall
Write-Host "Configuring firewall..."
netsh advfirewall firewall delete rule name="Angular Dev Server" 2>$null
netsh advfirewall firewall add rule name="Angular Dev Server" dir=in action=allow protocol=TCP localport=4200

# Clean up
Remove-Item "install.bat" -Force -ErrorAction SilentlyContinue

Write-Host "Installation completed"
exit 0