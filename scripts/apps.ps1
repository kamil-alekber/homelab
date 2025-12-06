# Array of software packages to install
$softwareList = @(
    "Google.Chrome",
    "Microsoft.VisualStudioCode",
    "SumatraPDF.SumatraPDF",
    "Alacritty.Alacritty",
    "7zip.7zip",
    "Git.Git",
    "Notepad++.Notepad++",
    "VLC.VLC",
    # "Python.Python.3",
    # "NodeJS.NodeJS.LTS",
    # "Docker.DockerDesktop",
    # "Postman.Postman",
    # "SlackTechnologies.Slack",
    # "Spotify.Spotify"  
)

# Function to install a package
function Install-Package {
    param (
        [string]$packageId
    )
    
    Write-Host "Installing $packageId..." -ForegroundColor Cyan
    
    try {
        $output = winget install --id $packageId --exact --silent --accept-package-agreements --accept-source-agreements 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Successfully installed $packageId" -ForegroundColor Green
        } elseif ($LASTEXITCODE -eq -1978335189 -or $output -match "already installed" -or $output -match "No applicable update found") {
            Write-Host "→ $packageId is already installed, skipping..." -ForegroundColor Yellow
        } else {
            Write-Host "✗ Failed to install $packageId (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ Error installing $packageId : $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Main installation loop
Write-Host "Starting software installation..." -ForegroundColor Yellow
Write-Host "Total packages: $($softwareList.Count)" -ForegroundColor Yellow
Write-Host ""

foreach ($software in $softwareList) {
    Install-Package -packageId $software
}

Write-Host "Installation process complete!" -ForegroundColor Green