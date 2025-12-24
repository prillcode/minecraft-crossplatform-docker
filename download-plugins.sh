#!/bin/bash
# download-plugins.sh
# Downloads required Minecraft plugins that can't be auto-downloaded by docker-compose file.

set -e  # Exit on error

PLUGINS_DIR="data/plugins"
TEMP_DIR="/tmp/mc-plugins-$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Minecraft Server Plugin Downloader"
echo "========================================="
echo ""

# Create plugins directory if it doesn't exist
if [ ! -d "$PLUGINS_DIR" ]; then
    echo -e "${YELLOW}Creating plugins directory...${NC}"
    mkdir -p "$PLUGINS_DIR"
fi

# Create temp directory
mkdir -p "$TEMP_DIR"

# Function to download plugin
download_plugin() {
    local name=$1
    local url=$2
    local filename=$3
    
    echo -e "${YELLOW}Downloading $name...${NC}"
    
    if wget -q -O "$TEMP_DIR/$filename" "$url"; then
        mv "$TEMP_DIR/$filename" "$PLUGINS_DIR/$filename"
        echo -e "${GREEN}✓ $name downloaded successfully${NC}"
    else
        echo -e "${RED}✗ Failed to download $name${NC}"
        echo -e "${RED}  URL: $url${NC}"
        return 1
    fi
}

# Download Multiverse-Core
download_plugin \
    "Multiverse-Core" \
    "https://hangar.papermc.io/api/v1/projects/Multiverse/Multiverse-Core/versions/5.4.0/PAPER/download" \
    "Multiverse-Core.jar"

# Download Multiverse-Inventories
download_plugin \
    "Multiverse-Inventories" \
    "https://hangar.papermc.io/api/v1/projects/Multiverse/Multiverse-Inventories/versions/5.2.1/PAPER/download" \
    "Multiverse-Inventories.jar"

# Download Multiverse-Portals
download_plugin \
    "Multiverse-Portals" \
    "https://hangar.papermc.io/api/v1/projects/Multiverse/Multiverse-Portals/versions/5.0.1/PAPER/download" \
    "Multiverse-Portals.jar"

# Clean up temp directory
rm -rf "$TEMP_DIR"

echo ""
echo "========================================="
echo -e "${GREEN}Plugin downloads complete!${NC}"
echo "========================================="
echo ""
echo -e "${YELLOW}NOTE: LuckPerms must be downloaded manually:${NC}"
echo "1. Visit https://luckperms.net/download"
echo "2. Click 'Bukkit' button"
echo "3. Save file to $PLUGINS_DIR/"
echo ""
echo "Then run: docker compose up -d"
echo ""
