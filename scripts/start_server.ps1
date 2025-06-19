# PowerShell script to start Angular server
# Set console to UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Change to parent directory (equivalent to cd /d "%~dp0\..")
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$parentPath = Split-Path -Parent $scriptPath
Set-Location $parentPath

# Add Node.js and npm to PATH
$env:PATH = "C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;$env:PATH"

Write-Host "Starting Angular server..."
Add-Content -Path "C:\application-log.txt" -Value "Starting Angular server..."

# Start Angular server in background (equivalent to start /B)
$process = Start-Process -FilePath "ng" -ArgumentList "serve", "--host", "0.0.0.0", "--port", "4200", "--disable-host-check" -NoNewWindow -PassThru -RedirectStandardOutput "C:\application-log.txt" -RedirectStandardError "C:\application-log.txt"

# Wait for 30 seconds (equivalent to ping 127.0.0.1 -n 31)
Start-Sleep -Seconds 30

Add-Content -Path "C:\application-log.txt" -Value "Angular server startup script completed."
Write-Host "Angular server startup script completed."

exit 0