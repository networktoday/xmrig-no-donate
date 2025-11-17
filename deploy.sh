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
echo "Please edit the configuration file:"
echo "  nano $WORK_DIR/config.json"
echo ""
echo "Required changes:"
echo "  1. Set your Monero wallet address in 'user' field"
echo "  2. Set your worker name in 'pass' field"
echo "  3. Optionally change pool URL"
echo ""
read -p "Press Enter to open the editor..."

# Open editor
nano config.json

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
