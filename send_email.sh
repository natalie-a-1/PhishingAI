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
echo "║         PHISHING EMAIL SENDER                   ║"
echo "║                                                 ║"
echo "╚═════════════════════════════════════════════════╝"
echo -e "${NC}"

# Load environment variables
source .env

# Check if target email is set, otherwise use self
if [ -z "$TARGET_EMAIL" ]; then
    TARGET_EMAIL="$EMAIL_USERNAME"
    echo -e "${YELLOW}[INFO]${NC} No target specified in .env, sending to yourself: $TARGET_EMAIL"
fi

# Send email using swaks with proper HTML content type
echo -e "${YELLOW}[INFO]${NC} Sending email using swaks..."
swaks --to "$TARGET_EMAIL" \
      --from "$EMAIL_USERNAME" \
      --server mail.lumoninc.com \
      --port 25 \
      --auth-user "$EMAIL_USERNAME" \
      --auth-password "$EMAIL_PASSWORD" \
      --h-Subject "Urgent: Security Alert - Immediate Action Required" \
      --h-Content-Type "text/html; charset=UTF-8" \
      --body "$(cat html_email_template.html)"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS]${NC} Email sent successfully to $TARGET_EMAIL"
else
    echo -e "${RED}[FAILED]${NC} Failed to send email with swaks."
    echo -e "${YELLOW}[INFO]${NC} Check your email credentials and connectivity."
fi

# Provide info for manual testing
echo -e "${YELLOW}[INFO]${NC} For manual email testing, use these settings:"
echo -e "    SMTP Server: mail.lumoninc.com"
echo -e "    Port: 25"
echo -e "    Username: $EMAIL_USERNAME"
echo -e "    Password: (your password in .env)"
echo -e "    Security: None" 