# Quick Start Guide: Mac + Kali VM Setup

This guide shows you how to run the phishing lab infrastructure on your **Kali VM** while viewing and taking screenshots on your **Mac**.

## Step 1: Setup on Kali VM

1. Download all files to your Kali VM
2. Make the scripts executable:
   ```bash
   chmod +x mac_kali_setup.sh setup_phishing.sh
   ```
3. Run the Mac-Kali configuration script:
   ```bash
   ./mac_kali_setup.sh
   ```
4. Run the main setup script:
   ```bash
   ./setup_phishing.sh
   ```
5. Start the web server:
   ```bash
   cd phishing_site
   ./start_server.sh
   ```

## Step 2: Transfer Link Page to Mac

You have multiple options:

### Option 1: Run a temporary server
```bash
# On Kali VM
cd mac_access
python3 -m http.server 8000
```

Then on your Mac, open a browser and navigate to:
```
http://KALI_VM_IP:8000/open_on_mac.html
```
*(Replace KALI_VM_IP with your Kali VM's actual IP address)*

Save this page to your Mac.

### Option 2: Use SCP from Mac
```bash
# On Mac terminal
scp kali@KALI_VM_IP:/path/to/lab/mac_access/open_on_mac.html ~/Desktop/
```

## Step 3: View and Screenshot from Mac

1. Open the `open_on_mac.html` file on your Mac browser
2. Use the provided links to:
   - View the phishing website
   - Preview the phishing email
   - Check captured credentials

3. Take screenshots of each component for your lab report

## Step 4: Complete the Lab on Kali VM

1. In a new terminal on Kali, send the phishing email:
   ```bash
   ./send_phishing_email.sh
   ```

2. Monitor for captured credentials:
   ```bash
   cd phishing_site
   ./monitor_credentials.sh
   ```

3. When credentials are captured, refresh the credentials page on your Mac to see and screenshot them

## Step 5: Complete Lab Report

Fill in the lab report template with:
- Screenshots taken from your Mac
- Details of your implementation
- Analysis of the phishing technique

## Troubleshooting

- If you can't access the Kali VM from your Mac, check that:
  - Both machines are on the same network
  - The Kali VM's firewall allows incoming connections (port 80)
  - You're using the correct IP address

- If the web server won't start on Kali:
  ```bash
  sudo apt update
  sudo apt install php   # For PHP server
  # or
  sudo apt install python3  # For Python server
  ``` 