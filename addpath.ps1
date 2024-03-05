# Get the directory of the script directory
$fullPath = $PSScriptRoot
Write-Host "Script directory: $fullPath"

# Get the current user's profile
$userPath = $PROFILE.CurrentUserCurrentHost

# Get the path part of the userPath
$userDirectory = Split-Path $userPath
Write-Host "User's profile script: $userPath"

# Check if the profile script file exists
if (-not (Test-Path $userPath -PathType Leaf)) {
    # Check if the directory path exists and create it if missing
    if (-not (Test-Path $userDirectory -PathType Container)) {
        $null = New-Item -Path $userDirectory -ItemType Directory -Force
    }
    # Create the profile script if it doesn't exist
    $null = New-Item -Path $userPath -ItemType File
}

# Check if the exact line already exists in the profile script
$existingLine = (Get-Content $userPath -ErrorAction SilentlyContinue) -contains "`$env:Path += ';$fullPath'"

if (-not $existingLine) {
    # Add your directory to the user's profile script
    Add-Content $userPath -Value "`n`$env:Path += ';$fullPath'"
    Write-Host "Directory $fullPath added to the user's profile script $userPath."
} else {
    Write-Host "Directory is already in the user's profile script."
}
