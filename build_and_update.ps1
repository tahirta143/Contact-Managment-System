# ── Build & Auto-Disable Old Versions ───────────────────────────────────────
# This script builds your APK and tells the live server to disable old versions.

$ADMIN_KEY = "your_secret_password_123"
$API_URL = "https://api.contact.afaqmis.com/api/app-config/update"

Write-Host "🚀 Starting Build and Update process..." -ForegroundColor Cyan

# 1. Read Version from pubspec.yaml
Write-Host 'Reading version from pubspec.yaml...'
$pubspec = Get-Content 'pubspec.yaml' -Raw
if ($pubspec -match 'version: (\d+\.\d+\.\d+)') {
    $currentVersion = $Matches[1]
    Write-Host "Target Version: $currentVersion" -ForegroundColor Green
} else {
    Write-Host 'Error: Could not find version in pubspec.yaml' -ForegroundColor Red
    exit
}

# 2. Run Flutter Build
Write-Host "🛠 Building APK (please wait)..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed! Not updating server." -ForegroundColor Red
    exit
}
Write-Host "✅ APK Build Complete!" -ForegroundColor Green

# 3. Inform Live Server
Write-Host "🌐 Telling Live Server to disable old versions..." -ForegroundColor Yellow
$body = @{
    version = $currentVersion
    admin_key = $ADMIN_KEY
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $API_URL -Method Post -Body $body -ContentType "application/json"
    if ($response.status -eq "success") {
        Write-Host "🎊 SUCCESS! Server updated. Version $currentVersion is now the minimum." -ForegroundColor Green
    } else {
        Write-Host "❌ Server Error: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Failed to connect to server: $_" -ForegroundColor Red
}

Write-Host 'Process complete!' -ForegroundColor Cyan
Pause
