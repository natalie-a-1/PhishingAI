# Phishing Lab Tools

This repository contains tools for learning and practicing phishing techniques in a controlled lab environment. These tools are for educational purposes only and should never be used for malicious activities.

## Overview

This lab includes:

1. A phishing email generator that creates convincing HTML emails
2. A website cloning tool that can clone login pages from popular websites
3. A credential harvesting system that captures and logs user input

## Setup

The easiest way to set up everything is to use the provided setup script:

```
chmod +x setup.sh
./setup.sh
```

Alternatively, you can set up manually:

1. Clone this repository to your local machine
2. Create a `.env` file by copying `.env.example` and filling in your details
3. Make the scripts executable:
   ```
   chmod +x send_email.sh host_phishing_site.sh view_credentials.sh
   ```

## Using the Tools

### 1. Starting the Phishing Website

```
sudo ./host_phishing_site.sh [url_to_clone]
```

**IMPORTANT**: It's recommended to run the script with `sudo` to use port 80. If you run without sudo, the script will use port 8080 instead, and the emails will be updated accordingly.

Examples:
```
# Host a default login page on port 80
sudo ./host_phishing_site.sh

# Clone and host Microsoft login page on port 80
sudo ./host_phishing_site.sh https://login.microsoft.com
```

### 2. Sending a Phishing Email

```
./send_email.sh [options]
```

Options:
- `-t, --target <target>` - Target information (organization, person, or role)
- `-s, --scenario <type>` - Type of phishing scenario (account, security, invoice, etc.)
- `-u, --urgency <level>` - Urgency level (low, medium, high, critical)
- `-c, --custom <file>` - Use custom HTML template file
- `-w, --website <url>` - URL of website to clone for phishing (e.g., https://github.com/login)

Examples:
```
# Basic email with default template
./send_email.sh

# Targeted security alert for Acme Corp
./send_email.sh -t "Acme Corporation" -s security

# Use custom HTML template
./send_email.sh -c my_template.html

# Clone GitHub login page and send email
./send_email.sh -w https://github.com/login
```

### 3. Monitoring Captured Credentials

The captured credentials are stored in `phishing_site/credentials.txt`. You can view them in real-time by:

```
./view_credentials.sh
```

A more detailed log is also available at `phishing_site/detailed_capture.log`.

## Port Handling

By default, the phishing site will try to run on port 80, which requires root privileges. If you don't run with sudo, it will fall back to port 8080. The system will:

1. Automatically detect the port being used
2. Update the email links to include the port if needed
3. Ensure the cloned website resources load correctly

If you're having issues with the email links not matching the hosted site, make sure to:

1. First start the phishing server (`host_phishing_site.sh`)
2. Then send the email (`send_email.sh`)

This ensures the email script knows which port the server is using.

## Key Features

### Enhanced Email Templates

- All emails use buttons/links to redirect to the phishing site
- No embedded login forms in the emails
- Multiple pre-designed templates for common scenarios
- Custom HTML template support

### Advanced Website Cloning

- Automatic detection and cloning of login pages
- Works with a wide range of websites
- Specialized templates for popular sites like GitHub, PayPal, and Microsoft
- Automatic form detection and modification for credential capture
- Built-in handling for JavaScript forms and AJAX requests

### Improved Credential Harvesting

- Captures username, password, and other sensitive information
- Advanced detection of form fields regardless of naming
- Detailed logging including browser, OS, and device information
- Graceful fallbacks when field names are non-standard

## Technical Details

### How the Email System Works

1. The `send_email.sh` script generates an HTML email based on the selected template
2. It can be customized with different scenarios, urgency levels, and target information
3. The email contains a button that links to your phishing website
4. The email is sent using the `swaks` tool through the configured mail server

### How the Website Cloning Works

1. The `host_phishing_site.sh` script uses `wget` to clone the target website
2. It automatically identifies and modifies forms to submit to `credentials.php`
3. For more complex sites, it injects JavaScript to override form submissions
4. It can handle different types of login forms, including AJAX-based logins

### How the Credential Harvesting Works

1. When a user submits the form, the data is sent to `credentials.php`
2. The script analyzes the form data to identify username, password, and other fields
3. All data is logged to `credentials.txt` and `detailed_capture.log`
4. The user is then redirected to the legitimate website to avoid suspicion

## Notes for Lab Report

When completing your lab report, include:

1. A description of the template/scenario you chose
2. The website you cloned (if applicable)
3. Screenshots of the email and phishing site
4. Examples of captured credentials (with sensitive information redacted)
5. Analysis of what social engineering techniques were used

## Disclaimer

These tools are provided for educational purposes only. The use of these tools to conduct actual phishing attacks is illegal and unethical. Only use these tools in a controlled lab environment with proper authorization. 