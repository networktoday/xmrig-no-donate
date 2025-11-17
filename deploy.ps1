# XMRig No-Donate - Quick Deploy Script for Windows
# Usage: powershell -ExecutionPolicy Bypass -File deploy.ps1
# Or: iwr -useb https://raw.githubusercontent.com/networktoday/xmrig-no-donate/main/deploy.ps1 | iex

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "XMRig No-Donate - Quick Deploy (Windows)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
Write-Host "Checking Docker installation..." -ForegroundColor Yellow
$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue

if (-not $dockerInstalled) {
    Write-Host "❌ Docker is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Docker Desktop for Windows:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -ForegroundColor White
    Write-Host "  2. Run the installer" -ForegroundColor White
    Write-Host "  3. Restart your computer" -ForegroundColor White
    Write-Host "  4. Run this script again" -ForegroundColor White
    Write-Host ""

    $openBrowser = Read-Host "Open Docker Desktop download page? (Y/n)"
    if ($openBrowser -eq "" -or $openBrowser -eq "Y" -or $openBrowser -eq "y") {
        Start-Process "https://www.docker.com/products/docker-desktop/"
    }

    exit 1
} else {
    Write-Host "✅ Docker is installed" -ForegroundColor Green
}

# Check if Docker is running
Write-Host "Checking if Docker is running..." -ForegroundColor Yellow
try {
    docker ps 2>&1 | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}

# Create working directory
$WORK_DIR = "$env:USERPROFILE\xmrig-miner"
Write-Host ""
Write-Host "Creating working directory: $WORK_DIR" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $WORK_DIR | Out-Null
Set-Location $WORK_DIR

# Download docker-compose.yml
Write-Host "Downloading docker-compose.yml..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/networktoday/xmrig-no-donate/main/docker-compose.yml" -OutFile "docker-compose.yml"
    Write-Host "✅ docker-compose.yml downloaded" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download docker-compose.yml" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Download config.json.example
Write-Host "Downloading config template..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/networktoday/xmrig-no-donate/main/config.json.example" -OutFile "config.json"
    Write-Host "✅ config.json downloaded" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download config.json" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "⚠️  CONFIGURATION REQUIRED" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Ask for wallet address
do {
    $WALLET_ADDRESS = Read-Host "Enter your Monero wallet address"
    if ([string]::IsNullOrWhiteSpace($WALLET_ADDRESS)) {
        Write-Host "❌ Wallet address cannot be empty!" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($WALLET_ADDRESS))

# Ask for worker name
do {
    $WORKER_NAME = Read-Host "Enter worker name (e.g., WORKER001)"
    if ([string]::IsNullOrWhiteSpace($WORKER_NAME)) {
        Write-Host "❌ Worker name cannot be empty!" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($WORKER_NAME))

# Ask if user wants to change pool (optional)
$USE_DEFAULT_POOL = Read-Host "Use default pool (pool.supportxmr.com:443)? (Y/n)"
if ([string]::IsNullOrWhiteSpace($USE_DEFAULT_POOL)) { $USE_DEFAULT_POOL = "Y" }

if ($USE_DEFAULT_POOL -eq "n" -or $USE_DEFAULT_POOL -eq "N") {
    $POOL_URL = Read-Host "Enter pool URL (e.g., pool.hashvault.pro:443)"
    $USE_TLS = Read-Host "Use TLS/SSL? (Y/n)"
    if ([string]::IsNullOrWhiteSpace($USE_TLS)) { $USE_TLS = "Y" }

    if ($USE_TLS -eq "Y" -or $USE_TLS -eq "y") {
        $TLS_VALUE = "true"
    } else {
        $TLS_VALUE = "false"
    }

    # Update pool URL and TLS in config.json
    $configContent = Get-Content "config.json" -Raw
    $configContent = $configContent -replace '"url":\s*"[^"]*"', "`"url`": `"$POOL_URL`""
    $configContent = $configContent -replace '"tls":\s*(true|false)', "`"tls`": $TLS_VALUE"
    Set-Content "config.json" -Value $configContent
}

# Update wallet and worker name in config.json
$configContent = Get-Content "config.json" -Raw
$configContent = $configContent -replace '"user":\s*"[^"]*"', "`"user`": `"$WALLET_ADDRESS`""
$configContent = $configContent -replace '"pass":\s*"[^"]*"', "`"pass`": `"$WORKER_NAME`""
Set-Content "config.json" -Value $configContent

Write-Host ""
Write-Host "✅ Configuration updated:" -ForegroundColor Green
Write-Host "   Wallet: $WALLET_ADDRESS" -ForegroundColor White
Write-Host "   Worker: $WORKER_NAME" -ForegroundColor White
Write-Host ""

$EDIT_CONFIG = Read-Host "Do you want to edit config.json manually? (y/N)"
if ($EDIT_CONFIG -eq "y" -or $EDIT_CONFIG -eq "Y") {
    notepad "config.json"
    Write-Host "Press Enter after saving the file..." -ForegroundColor Yellow
    Read-Host
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Starting XMRig miner..." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Edit docker-compose to use pre-built image
$dockerComposeContent = Get-Content "docker-compose.yml" -Raw
$dockerComposeContent = $dockerComposeContent -replace '# image:', 'image:'
$dockerComposeContent = $dockerComposeContent -replace 'build: \.', '# build: .'
Set-Content "docker-compose.yml" -Value $dockerComposeContent

# Start container
Write-Host "Starting Docker container..." -ForegroundColor Yellow
try {
    docker-compose up -d
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "✅ XMRig miner deployed successfully!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Cyan
    Write-Host "  View logs:     docker logs -f xmrig-miner" -ForegroundColor White
    Write-Host "  Check status:  docker stats xmrig-miner" -ForegroundColor White
    Write-Host "  Stop miner:    docker-compose down" -ForegroundColor White
    Write-Host "  Restart:       docker-compose restart" -ForegroundColor White
    Write-Host ""
    Write-Host "Working directory: $WORK_DIR" -ForegroundColor Yellow
    Write-Host ""

    $VIEW_LOGS = Read-Host "View logs now? (Y/n)"
    if ([string]::IsNullOrWhiteSpace($VIEW_LOGS) -or $VIEW_LOGS -eq "Y" -or $VIEW_LOGS -eq "y") {
        Write-Host ""
        Write-Host "Showing logs (press Ctrl+C to exit)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        docker logs -f xmrig-miner
    }
} catch {
    Write-Host ""
    Write-Host "❌ Failed to start container!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Make sure Docker Desktop is running" -ForegroundColor White
    Write-Host "  2. Check if virtualization is enabled in BIOS" -ForegroundColor White
    Write-Host "  3. Try restarting Docker Desktop" -ForegroundColor White
    exit 1
}
