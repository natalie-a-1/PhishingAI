# Email Phishing Lab: Mac + Kali VM Setup

This phishing lab is designed to run the server infrastructure on your **Kali VM** while allowing you to view and take screenshots easily on your **Mac** for better performance and lab submission.

## What This Lab Does

This lab automates the setup of:

1. A phishing website on your Kali VM that mimics a login page
2. A credential-capturing system that logs any entered usernames/passwords
3. HTML email templates for sending through the Lumon Industries mail server
4. Convenient browser-based viewing pages for screenshots on your Mac

## System Requirements

- **Kali Linux VM**: Where all server components run
- **Mac**: For viewing and taking screenshots of the components
- Both machines must be on the same network

## Quick Setup Guide

### On Kali VM:

1. Download all files to your Kali VM
2. Make the setup script executable:
   ```bash
   chmod +x setup.sh
   ```
3. Run the setup script:
   ```bash
   ./setup.sh
   ```
4. Start the web server:
   ```bash
   cd phishing_site
   ./start_server.sh
   ```

### On Mac:

1. Get the HTML access file from Kali using one of these methods:

   **Option 1: Use a temporary web server**
   ```bash
   # On Kali VM
   cd mac_access
   python3 -m http.server 8000
   ```
   Then on your Mac, browse to `http://KALI_IP:8000/open_on_mac.html` and save the page.

   **Option 2: Use secure copy (SCP)**
   ```bash
   # On Mac Terminal
   scp kali@KALI_IP:/path/to/lab/mac_access/open_on_mac.html ~/Desktop/
   ```

2. Open the saved HTML file on your Mac
3. Use the buttons to access and screenshot each component

## What Runs Where

### On Kali VM (Infrastructure):
- Web server hosting the phishing site
- PHP scripts that capture credentials
- Email sending functionality
- Credential monitoring

### On Mac (Viewing & Screenshots):
- Phishing website preview
- Email template preview
- Captured credentials viewer
- Taking screenshots for lab report

## Step-by-Step Lab Completion

1. **Set Up Infrastructure (Kali VM)**
   ```bash
   ./setup.sh
   cd phishing_site
   ./start_server.sh
   ```

2. **Access Viewing Links (Mac)**
   - Get the `open_on_mac.html` file using one of the methods above
   - Open it in your browser
   - Verify you can see the phishing site through the links

3. **Send Phishing Email (Kali VM)**
   ```bash
   # In a new terminal on Kali
   ./send_phishing_email.sh
   ```
   - Enter your SSH port number when prompted (for email username)
   - Enter your password
   - Enter target email (or leave blank to send to yourself)

4. **Test and Capture Credentials (Kali VM + Mac)**
   - Click the link in the email preview on your Mac
   - Enter test credentials on the phishing site
   - In a new terminal on Kali, monitor for captured credentials:
     ```bash
     cd phishing_site
     ./monitor_credentials.sh
     ```
   - Refresh the credentials page on your Mac to see and screenshot the captured data

5. **Complete Lab Report**
   - Use the screenshots taken on your Mac
   - Fill in the lab report template
   - Include analysis of the phishing technique

## Important Files

- `setup.sh`: Main setup script to run on Kali
- `phishing_site/`: Directory containing the phishing website and capture scripts
- `mac_access/open_on_mac.html`: HTML file with links for viewing on Mac
- `send_phishing_email.sh`: Script to send phishing emails
- `lab_report_template.md`: Template for your lab submission

## Troubleshooting

- **Can't access Kali from Mac**: Check that both machines are on the same network
- **Web server won't start**: Install required packages with `sudo apt update && sudo apt install php`
- **Email sending fails**: Check your VM's connectivity to the mail server in the lab environment
- **No credentials captured**: Make sure form fields on the phishing page match what the capture script expects

## Security Notice

This lab is for educational purposes only. The techniques should only be applied within authorized environments and the provided cyber range. Unauthorized use of these techniques is illegal and unethical. 