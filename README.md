# Phishing Lab Exercise

This repository contains all necessary tools and scripts to complete the email phishing lab exercise for the Lumon Industries cyber range.

## Overview

This lab simulates a common phishing attack where an attacker:
1. Creates a fake login page that looks identical to a legitimate site
2. Sends a convincing email with a link to the fake page
3. Captures credentials when users enter them on the fake page

## Project Structure

- `setup.sh` - Main setup script to configure everything automatically
- `phishing_site/` - Directory containing the cloned website and capture script
- `html_email_template.html` - Template for the HTML phishing email
- `send_email.sh` - Script to send the phishing email
- `view_credentials.sh` - Script to view captured credentials
- `.env.example` - Example configuration file (copy to `.env` and modify)

## Step-by-Step Instructions

**Website Cloning:** You can now clone real websites by passing a URL: `./setup.sh https://example.com`

### 1. Initial Setup

1. Copy the example environment file and edit it with your credentials:
   ```
   cp .env.example .env
   nano .env
   ```
   Fill in your:
   - Email username (based on your SSH port)
   - Email password
   - Kali VM IP address
   - Target email (or leave blank to send to yourself)

2. Make the setup script executable and run it:
   ```
   chmod +x setup.sh
   
   # Option 1: Use the default Lumon login page
   ./setup.sh
   
   # Option 2: Clone a real website
   ./setup.sh https://target-website.com
   ```
   
   This script will:
   - Install any necessary dependencies
   - Set up the phishing website (default or cloned from URL)
   - Configure email templates with your server IP
   - Create scripts for monitoring and sending

### 2. Running the Phishing Website

1. Start the web server to host the phishing site:
   ```
   cd phishing_site
   sudo ./start_server.sh
   ```
   This starts a PHP server on port 80 to host the phishing page.

2. Keep this terminal window open while the web server runs. Open a new terminal for the next steps.

### 3. Sending the Phishing Email

1. In a new terminal, send the phishing email:
   ```
   ./send_email.sh
   ```

2. The script will use the credentials from your `.env` file to send an HTML email through the Lumon mail server.

3. The email will contain a "Verify Account" button that links to your phishing site.

### 4. Capturing Credentials

1. In another terminal window, monitor for captured credentials:
   ```
   ./view_credentials.sh
   ```

2. When someone clicks the link in your email and enters credentials, they will be captured and displayed in this terminal.

3. All captured credentials are also stored in `phishing_site/captured_credentials.txt` for your reference.

### 5. Understanding How It Works

#### The Phishing Website
- When using the default template: A pre-designed Lumon Industries login page
- When cloning a website: A replica of the target website with forms modified to capture credentials
- All credentials are processed by `phishing_site/credentials.php`
- The PHP script is designed to capture credentials from various form field names
- After capturing credentials, users are redirected to a legitimate site to avoid suspicion

#### The Phishing Email
- Uses HTML formatting to appear legitimate
- Contains official-looking branding and urgent language
- Includes a button that links to your phishing site (using your Kali VM's IP)
- Uses social engineering tactics to create urgency (security alert, account verification)

#### Credential Harvesting
- The form on the fake page submits to a PHP script
- The script captures:
  - Username/email
  - Password
  - IP address
  - User agent (browser info)
  - Timestamp
  - All form fields submitted (for forms with non-standard field names)
- All data is logged to a text file and can be monitored in real-time

## Website Cloning Features

When you use the URL cloning option:

1. The script will download the content of the target website
2. It will automatically modify any forms to submit to your credential capture script
3. The script attempts to detect various login form fields, even if they use non-standard names
4. If cloning fails, it will fall back to the default login page

Best practices for website cloning:
- Target specific login pages rather than home pages
- Choose simpler websites without complex JavaScript-based forms
- You may need to manually adjust the cloned files for more complex sites

## Lab Report Tips

When completing your lab report, include:

1. **Screenshots of**:
   - Your phishing email as seen by the recipient
   - Your cloned phishing website
   - Captured credentials

2. **Description of your approach**:
   - Social engineering tactics used in your email
   - Technical setup details
   - Any challenges encountered and how you solved them

3. **Analysis of effectiveness**:
   - Why the phishing attempt might succeed
   - How it could be improved
   - How organizations can protect against such attacks

## Security Notice

This lab is for educational purposes only. The techniques demonstrated should only be used in authorized environments such as the provided cyber range. Unauthorized use of these techniques against real systems or individuals is illegal and unethical. 