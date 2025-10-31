# Sets PUB_CACHE to D:\pub_cache for this session, creates the folder if missing,
# runs flutter clean and flutter pub get.
# Usage: Open PowerShell, cd to project root, then: .\tools\set_pub_cache_to_d.ps1

$pubCachePath = 'D:\pub_cache'

Write-Host "Ensuring pub cache directory exists at: $pubCachePath"
if (-Not (Test-Path -Path $pubCachePath)) {
    New-Item -ItemType Directory -Path $pubCachePath -Force | Out-Null
    Write-Host "Created directory: $pubCachePath"
} else {
    Write-Host "Directory already exists: $pubCachePath"
}

Write-Host "Setting environment variable PUB_CACHE for this PowerShell session..."
$env:PUB_CACHE = $pubCachePath

Write-Host "Running flutter clean..."
flutter clean

Write-Host "Running flutter pub get (using PUB_CACHE=$pubCachePath)..."
flutter pub get

Write-Host "Done. Please restart VS Code or open a new terminal to persist PUB_CACHE if you used setx."

# If user wants to persist the change, uncomment the following lines and run the script as Administrator:
# Write-Host "Setting PUB_CACHE permanently for current user (requires new terminal to take effect)..."
# setx PUB_CACHE "$pubCachePath"
# Write-Host "PUB_CACHE set permanently (user). Restart terminal/VS Code to take effect."