#!/bin/bash

# XMRig No-Donate - Quick Deploy Script
# Usage: curl -sSL https://raw.githubusercontent.com/networktoday/xmrig-no-donate/main/deploy.sh | bash

set -e

echo "=========================================="
echo "XMRig No-Donate - Quick Deploy"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
    echo "✅ Docker installed successfully"
else
    echo "✅ Docker is already installed"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Installing..."
    apt-get update && apt-get install -y docker-compose
    echo "✅ Docker Compose installed successfully"
else
    echo "✅ Docker Compose is already installed"
fi

# Create working directory
WORK_DIR="/opt/xmrig-miner"
echo ""
echo "Creating working directory: $WORK_DIR"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Download docker-compose.yml
echo "Downloading docker-compose.yml..."
curl -sSL https://raw.githubusercontent.com/networktoday/xmrig-no-donate/main/docker-compose.yml -o docker-compose.yml

# Download config.json.example
echo "Downloading config template..."
curl -sSL https://raw.githubusercontent.com/networktoday/xmrig-no-donate/main/config.json.example -o config.json

echo ""
echo "=========================================="
echo "⚠️  CONFIGURATION REQUIRED"
echo "=========================================="
echo ""

# Ask for wallet address
read -p "Enter your Monero wallet address: " WALLET_ADDRESS
while [[ -z "$WALLET_ADDRESS" ]]; do
    echo "❌ Wallet address cannot be empty!"
    read -p "Enter your Monero wallet address: " WALLET_ADDRESS
done

# Ask for worker name
read -p "Enter worker name (e.g., WORKER001): " WORKER_NAME
while [[ -z "$WORKER_NAME" ]]; do
    echo "❌ Worker name cannot be empty!"
    read -p "Enter worker name (e.g., WORKER001): " WORKER_NAME
done

# Ask if user wants to change pool (optional)
read -p "Use default pool (pool.supportxmr.com:443)? [Y/n]: " USE_DEFAULT_POOL
USE_DEFAULT_POOL=${USE_DEFAULT_POOL:-Y}

if [[ "$USE_DEFAULT_POOL" =~ ^[Nn]$ ]]; then
    read -p "Enter pool URL (e.g., pool.hashvault.pro:443): " POOL_URL
    read -p "Use TLS/SSL? [Y/n]: " USE_TLS
    USE_TLS=${USE_TLS:-Y}
    if [[ "$USE_TLS" =~ ^[Yy]$ ]]; then
        TLS_VALUE="true"
    else
        TLS_VALUE="false"
    fi
    # Update pool URL and TLS
    sed -i "s|\"url\": \".*\"|\"url\": \"$POOL_URL\"|" config.json
    sed -i "s|\"tls\": true|\"tls\": $TLS_VALUE|" config.json
fi

# Update wallet and worker name in config.json
sed -i "s|\"user\": \".*\"|\"user\": \"$WALLET_ADDRESS\"|" config.json
sed -i "s|\"pass\": \".*\"|\"pass\": \"$WORKER_NAME\"|" config.json

echo ""
echo "✅ Configuration updated:"
echo "   Wallet: $WALLET_ADDRESS"
echo "   Worker: $WORKER_NAME"
echo ""
read -p "Do you want to edit config.json manually? [y/N]: " EDIT_CONFIG
if [[ "$EDIT_CONFIG" =~ ^[Yy]$ ]]; then
    nano config.json
fi

echo ""
echo "=========================================="
echo "Starting XMRig miner..."
echo "=========================================="
echo ""

# Edit docker-compose to use pre-built image
sed -i 's|# image:|image:|' docker-compose.yml
sed -i 's|build: .|# build: .|' docker-compose.yml

# Start container
docker-compose up -d

echo ""
echo "=========================================="
echo "✅ XMRig miner deployed successfully!"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  View logs:     docker logs -f xmrig-miner"
echo "  Check status:  docker stats xmrig-miner"
echo "  Stop miner:    cd $WORK_DIR && docker-compose down"
echo "  Restart:       cd $WORK_DIR && docker-compose restart"
echo ""
echo "Checking logs (press Ctrl+C to exit)..."
sleep 3
docker logs -f xmrig-miner
