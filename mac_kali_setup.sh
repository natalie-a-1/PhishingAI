#!/bin/bash
# Mac-Kali VM Phishing Lab Setup Script
# This script configures the phishing lab to run on Kali while allowing viewing on Mac

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display banner
echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════╗"
echo "║                                                ║"
echo "║      MAC-KALI PHISHING LAB CONFIGURATION       ║"
echo "║                                                ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get Kali VM's IP address
echo -e "${YELLOW}[INFO]${NC} Determining Kali VM's IP address..."
KALI_IP=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}[SUCCESS]${NC} Kali VM IP: ${KALI_IP}"

# Create a directory to store Mac-accessible URLs
mkdir -p mac_access
echo -e "${GREEN}[SUCCESS]${NC} Created mac_access directory"

# Create a file with all the URLs to open on Mac
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
echo -e "${GREEN}[SUCCESS]${NC} Created Mac access links file"

# Create a script to copy this file to Mac
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
echo -e "${GREEN}[SUCCESS]${NC} Created Mac access instructions"

# Create the email preview file
mkdir -p phishing_site
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
echo -e "${GREEN}[SUCCESS]${NC} Created email preview file"

# Create a PHP script to view captured credentials
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
echo -e "${GREEN}[SUCCESS]${NC} Created credentials viewing script"

# Update the setup_phishing.sh script to include the Mac access files
echo -e "${YELLOW}[INFO]${NC} Updating main setup script to include Mac access..."
cat >> setup_phishing.sh << EOF

# Copy Mac access files to phishing_site directory
echo -e "\${YELLOW}[INFO]\${NC} Setting up Mac access files..."
cp phishing_site/phishing_email_preview.html phishing_site/
cp phishing_site/view_credentials.php phishing_site/
echo -e "\${GREEN}[SUCCESS]\${NC} Mac access files configured"

echo -e "\${YELLOW}\n============================================================\${NC}"
echo -e "\${GREEN}MAC ACCESS INSTRUCTIONS:\${NC}"
echo -e "\${YELLOW}============================================================\${NC}"
echo -e "To take screenshots on your Mac:"
echo -e "1. Copy the open_on_mac.html file to your Mac (instructions in mac_access/how_to_access_from_mac.txt)"
echo -e "2. Open the HTML file on your Mac browser"
echo -e "3. Use the provided links to view and screenshot each component"
echo -e "\${YELLOW}============================================================\${NC}"
EOF
echo -e "${GREEN}[SUCCESS]${NC} Updated main setup script"

# Make the file executable
chmod +x mac_kali_setup.sh
echo -e "${GREEN}[SUCCESS]${NC} Made the script executable"

# Final instructions
echo -e "${YELLOW}\n============================================================${NC}"
echo -e "${GREEN}Mac-Kali Configuration Complete!${NC}"
echo -e "${YELLOW}============================================================${NC}"
echo -e "Next steps:"
echo -e "1. Run the main setup script: ${GREEN}./setup_phishing.sh${NC}"
echo -e "2. Start the web server on Kali: ${GREEN}cd phishing_site && ./start_server.sh${NC}"
echo -e "3. Follow the instructions in: ${GREEN}mac_access/how_to_access_from_mac.txt${NC} to access from your Mac"
echo -e "${YELLOW}============================================================${NC}"
echo -e "${GREEN}Your Kali VM IP is: ${KALI_IP}${NC}"
echo -e "${GREEN}All URLs will use this IP to allow access from your Mac${NC}"
echo -e "${YELLOW}============================================================${NC}" 