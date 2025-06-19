$fileToDelete = "C:\application-log.txt"
if (Test-Path $fileToDelete) {
    Remove-Item $fileToDelete -Force
    Write-Host "Deleted existing file: $fileToDelete"
}

# PowerShell script to install Angular dependencies
Write-Host "Installing Angular dependencies..."

# Change to parent directory (equivalent to cd /d "%~dp0\..")
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$parentPath = Split-Path -Parent $scriptPath
Set-Location $parentPath

Write-Host "Current directory: $(Get-Location)"
Write-Host "Files in directory:"
Get-ChildItem -Name

# Set Node.js and npm paths
$NODE_EXE = "C:\Program Files\nodejs\node.exe"
$NPM_EXE = "C:\Program Files\nodejs\npm.cmd"
$NG_EXE = "C:\Users\Administrator\AppData\Roaming\npm\ng.cmd"

# Add Node.js to PATH permanently if not already there
$nodePath = "C:\Program Files\nodejs"
$npmGlobalPath = "C:\Users\Administrator\AppData\Roaming\npm"

$currentSystemPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
$pathsToAdd = @()

if ($currentSystemPath -notlike "*$nodePath*") {
    $pathsToAdd += $nodePath
}
if ($currentSystemPath -notlike "*$npmGlobalPath*") {
    $pathsToAdd += $npmGlobalPath
}

if ($pathsToAdd.Count -gt 0) {
    Write-Host "Adding Node.js paths to system PATH permanently..."
    $newSystemPath = $currentSystemPath
    foreach ($path in $pathsToAdd) {
        $newSystemPath = "$newSystemPath;$path"
    }
    [Environment]::SetEnvironmentVariable("PATH", $newSystemPath, [EnvironmentVariableTarget]::Machine)
    
    # Also update current session
    $env:PATH = "$nodePath;$npmGlobalPath;$env:PATH"
    Write-Host "PATH updated permanently and for current session"
}

# Set Node.js environment variables
$env:NODE_HOME = "C:\Program Files\nodejs"
$env:NPM_CONFIG_PREFIX = "C:\Users\Administrator\AppData\Roaming\npm"

Write-Host "Checking Node.js installation..."
if (Test-Path $NODE_EXE) {
    Add-Content -Path "C:\application-log.txt" -Value "Node.js found at $NODE_EXE"
    Write-Host "Node.js found at $NODE_EXE"
} else {
    Add-Content -Path "C:\application-log.txt" -Value "ERROR: Node.js not found at $NODE_EXE"
    Write-Host "ERROR: Node.js not found at $NODE_EXE"
    exit 1
}

if (Test-Path "package.json") {
    Write-Host "Found package.json, installing ALL dependencies including dev dependencies..."
    
    # Use npm install to get both prod and dev dependencies
    Write-Host "Running npm install with optimizations..."
    & $NPM_EXE install --prefer-offline --no-audit --no-fund
    
    if ($LASTEXITCODE -ne 0) {
        Add-Content -Path "C:\application-log.txt" -Value "npm install failed, trying without optimizations..."
        Write-Host "npm install failed, trying without optimizations..."
        
        & $NPM_EXE install
        
        if ($LASTEXITCODE -ne 0) {
            Add-Content -Path "C:\application-log.txt" -Value "npm install failed completely"
            Write-Host "npm install failed completely"
            exit 1
        }
    }
    
    Write-Host "Dependencies installed successfully"
} else {
    Write-Host "ERROR: No package.json found"
    exit 1
}

if (-not (Test-Path $NG_EXE)) {
    Write-Host "Installing Angular CLI..."
    & $NPM_EXE install -g @angular/cli
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Angular CLI installation failed"
        exit 1
    }
    
    Write-Host "Angular CLI installed successfully"
} else {
    Write-Host "Angular CLI already installed"
}

Write-Host "Configuring Windows Firewall..."
# Remove existing rule (suppress errors if it doesn't exist)
netsh advfirewall firewall delete rule name="Angular Dev Server" 2>$null

# Add new firewall rule
netsh advfirewall firewall add rule name="Angular Dev Server" dir=in action=allow protocol=TCP localport=4200

if ($LASTEXITCODE -eq 0) {
    Add-Content -Path "C:\application-log.txt" -Value "Firewall rule configured successfully"
} else {
    Add-Content -Path "C:\application-log.txt" -Value "Warning: Firewall rule configuration may have failed"
}

Write-Host "Install script completed successfully"
exit 0