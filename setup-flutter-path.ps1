# Flutter PATH Setup Script for Windows
# Run this in PowerShell to automatically add Flutter to your PATH

$flutterPath = "C:\src\flutter\bin"

# Check if Flutter exists at the expected location
if (-Not (Test-Path $flutterPath)) {
    Write-Host "❌ Error: Flutter not found at C:\src\flutter\bin" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please make sure you've:" -ForegroundColor Yellow
    Write-Host "1. Downloaded Flutter SDK from https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Write-Host "2. Extracted it to C:\src\flutter" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "The folder C:\src\flutter\bin should exist!" -ForegroundColor Yellow
    exit 1
}

# Get current User PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if Flutter is already in PATH
if ($userPath -like "*$flutterPath*") {
    Write-Host "✅ Flutter is already in your PATH!" -ForegroundColor Green
} else {
    # Add Flutter to PATH
    $newPath = "$userPath;$flutterPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✅ Successfully added Flutter to PATH!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Path added: $flutterPath" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "⚠️  IMPORTANT NEXT STEP:" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Close this PowerShell window and open a NEW one!" -ForegroundColor Yellow
Write-Host "PATH changes only take effect in new terminal sessions." -ForegroundColor Yellow
Write-Host ""
Write-Host "Then run: flutter --version" -ForegroundColor Green
Write-Host ""
