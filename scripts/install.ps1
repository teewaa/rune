# ---------------------------------------------
# Determine install directory
# ---------------------------------------------
$DefaultInstallDir = Join-Path $env:LOCALAPPDATA "Rune"
Write-Host "Installing Rune"
Write-Host ""
Write-Host "Default installation directory: $DefaultInstallDir"
$customPath = Read-Host "Enter custom installation path (or press Enter for default)"

$InstallDir = if ([string]::IsNullOrWhiteSpace($customPath)) { 
    $DefaultInstallDir 
} else { 
    $customPath 
}

$CloneDir   = Join-Path $InstallDir "Rune"
$RepoURL    = "https://github.com/dalapierre/rune.git"

Write-Host ""
Write-Host "Rune will be installed at: $InstallDir"
$confirm = Read-Host "Do you wish to proceed? [y/N]"
if ($confirm.ToLower() -ne "y") {
    Write-Host "`nInstallation cancelled."
    exit 0
}
Write-Host ""

# ---------------------------------------------
# Check Git installation
# ---------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "`nError: Git is not installed or not in PATH."
    Write-Host "Please install Git and try again."
    exit 1
}

# ---------------------------------------------
# Ensure install directory exists
# ---------------------------------------------
if (-not (Test-Path $InstallDir)) {
    Write-Host "Creating installation directory..."
    try {
        New-Item -ItemType Directory -Path $InstallDir | Out-Null
    } catch {
        Write-Host "`nFailed to create installation directory."
        exit 1
    }
}

# ---------------------------------------------
# Remove previous clone
# ---------------------------------------------
if (Test-Path $CloneDir) {
    Write-Host "`nRemoving old installation..."
    Remove-Item -Recurse -Force $CloneDir
}

# ---------------------------------------------
# Clone repository
# ---------------------------------------------
Write-Host "Cloning Rune repository..."
if ((git clone --quiet $RepoURL $CloneDir) -ne $null) {
    Write-Host "`nFailed to clone repository."
    exit 1
}

# ---------------------------------------------
# Run the build script
# ---------------------------------------------
$buildScript = Join-Path $CloneDir "scripts\build.bat"
if (-not (Test-Path $buildScript)) {
    Write-Host "`nBuild script not found."
    exit 1
}

Push-Location $CloneDir
cmd.exe /c $buildScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nBuild failed."
    Pop-Location
    exit 1
}
Pop-Location

# ---------------------------------------------
# Check that rune.exe was built
# ---------------------------------------------
$BuiltExe = Join-Path $CloneDir "bin\rune.exe"
if (-not (Test-Path $BuiltExe)) {
    Write-Host "`nError: Build succeeded but rune.exe was not found."
    exit 1
}

# ---------------------------------------------
# Copy final binary
# ---------------------------------------------
$FinalExe = Join-Path $InstallDir "rune.exe"
try {
    Copy-Item -Force $BuiltExe $FinalExe
} catch {
    Write-Host "`nFailed to copy rune.exe"
    exit 1
}

# ---------------------------------------------
# Cleanup clone
# ---------------------------------------------
Write-Host "Clean up..."
Remove-Item -Recurse -Force $CloneDir

Write-Host "`nInstallation complete!"
Write-Host "Don't forget to add $InstallDir to your PATH to use rune from anywhere."