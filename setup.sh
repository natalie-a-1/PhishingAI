#!/bin/bash

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display banner
echo -e "${YELLOW}"
echo "╔═════════════════════════════════════════════════╗"
echo "║                                                 ║"
echo "║         PHISHING LAB SETUP                      ║"
echo "║                                                 ║"
echo "╚═════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if required tools are installed
check_dependencies() {
    missing_deps=()
    
    # Check for wget
    if ! command -v wget &> /dev/null; then
        missing_deps+=("wget")
    fi
    
    # Check for php
    if ! command -v php &> /dev/null; then
        missing_deps+=("php")
    fi
    
    # Check for sed
    if ! command -v sed &> /dev/null; then
        missing_deps+=("sed")
    fi
    
    # Check for swaks
    if ! command -v swaks &> /dev/null; then
        missing_deps+=("swaks")
    fi
    
    # Install missing dependencies
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}[INFO]${NC} Installing missing dependencies: ${missing_deps[*]}"
        sudo apt-get update -qq && sudo apt-get install -y "${missing_deps[@]}"
    fi
}

# Check dependencies
check_dependencies

# Check if .env file exists, if not create it from example
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        echo -e "${YELLOW}[INFO]${NC} Creating .env file from example..."
        cp .env.example .env
        echo -e "${GREEN}[SUCCESS]${NC} Created .env file. Please edit it with your details:"
        echo -e "nano .env"
    else
        echo -e "${RED}[ERROR]${NC} No .env.example file found. Please create a .env file manually."
        exit 1
    fi
fi

# Make scripts executable
echo -e "${YELLOW}[INFO]${NC} Making scripts executable..."
chmod +x send_email.sh host_phishing_site.sh view_credentials.sh

# Check for command line arguments
WEBSITE_URL=""
if [ $# -gt 0 ]; then
    WEBSITE_URL="$1"
    echo -e "${YELLOW}[INFO]${NC} Will clone website: $WEBSITE_URL"
fi

# Display setup instructions
echo -e "\n${GREEN}[SUCCESS]${NC} Setup complete! Here's how to use the phishing lab:"
echo -e "\n1. Start the phishing website:"
if [ -n "$WEBSITE_URL" ]; then
    echo -e "   sudo ./host_phishing_site.sh \"$WEBSITE_URL\""
else
    echo -e "   sudo ./host_phishing_site.sh"
    echo -e "   or"
    echo -e "   sudo ./host_phishing_site.sh https://login.website.com"
fi
echo -e "\n2. Send a phishing email (in a different terminal):"
if [ -n "$WEBSITE_URL" ]; then
    echo -e "   ./send_email.sh -w \"$WEBSITE_URL\""
else
    echo -e "   ./send_email.sh"
    echo -e "   or with options:"
    echo -e "   ./send_email.sh -t \"Target Company\" -s security -u high"
fi
echo -e "\n3. Monitor captured credentials (in a different terminal):"
echo -e "   ./view_credentials.sh"

echo -e "\n${YELLOW}[IMPORTANT]${NC} Make sure to edit the .env file with your email credentials and server IP!"
echo -e "${YELLOW}[IMPORTANT]${NC} For more options, run the scripts with --help flag"

exit 0 