# Set the console's code page to UTF-8
chcp 65001

# Set the output encoding for all PowerShell streams to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Read configuration from config.txt
$configFile = "config.txt"

# If config.txt does not exist, create it with default values.
if (-not (Test-Path $configFile)) {
    @"
# GitHub repository owner and name.
ProjectOwner=ARandomAxolotl
ProjectRepo=t-t

# Option to allow "snapshot" builds (y = 3).
# Valid values are 'true' or 'false'.
AllowSnapshots=false

# The name of the helper script that performs final cleanup.
CleanupScript=yaimstllfck.ps1
"@ | Out-File -FilePath $configFile -Encoding UTF8
}

$config = Get-Content -Path $configFile | ConvertFrom-StringData

# Extract project details from the configuration
$repoOwner = $config.ProjectOwner
$repoName = $config.ProjectRepo
$allowSnapshots = [System.Convert]::ToBoolean($config.AllowSnapshots)
$cleanupScript = $config.CleanupScript

Write-Host "Updating project '$repoName'..."

# Construct the API URL to get all releases
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases"

try {
    # Fetch all releases
    $releases = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop

    # Filter releases based on your custom versioning scheme
    $availableReleases = @()
    foreach ($release in $releases) {
        # Check if the tag name matches the x.y.z format
        if ($release.tag_name -match '^v?(\d+)\.(\d+)\.(\d+)$') {
            $versionX = [int]$Matches[1]
            $versionY = [int]$Matches[2]
            $versionZ = [int]$Matches[3]
            if ($versionY -le 2 -or ($versionY -eq 3 -and $allowSnapshots)) {
                $availableReleases += [PSCustomObject]@{
                    Tag = $release.tag_name
                    Url = $release.zipball_url
                    Version = [version]"$versionX.$versionY.$versionZ"
                }
            }
        }
    }

    if ($availableReleases.Count -eq 0) {
        Write-Host "No suitable releases found."
        exit
    }

    # Sort to find the latest version
    $latestRelease = $availableReleases | Sort-Object -Property Version -Descending | Select-Object -First 1

    Write-Host "Found latest release: $($latestRelease.Tag)"

    # Get the current folder name to pass to the cleanup script
    $currentProjectFolder = (Get-Location).Path

    # Download the latest release
    $downloadUrl = $latestRelease.Url
    $zipFile = "latest-release.zip"
    Write-Host "Downloading file: $zipFile"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile

    # Extract the archive
    Write-Host "Extracting file..."
    Expand-Archive -Path $zipFile -DestinationPath "." -Force

    # Find the newly extracted folder (e.g., 't-t-longhash')
    $extractedDir = (Get-ChildItem -Directory | Where-Object { $_.Name -like "$repoName-*" }).Name

    # Run the cleanup script to finalize the update
    # The -ExecutionPolicy Bypass parameter is often necessary
    Write-Host "Calling helper script to finalize update..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "$extractedDir\$cleanupScript", "-OldFolder", "`"$currentProjectFolder`""
    
    # Exit the main script so it can be deleted
    exit
    
} catch {
    Write-Error "An error occurred during the update: $($
