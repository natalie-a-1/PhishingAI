# Email Client Configuration Guide

## Quick Reference

Use these settings to configure your email client for the Lumon Industries cyber range:

### Incoming Mail Server (IMAP)
- **Protocol**: IMAP
- **Server**: mail.lumoninc.com
- **Port**: 143
- **Connection Security**: None
- **Authentication Method**: Normal password
- **Username**: sABC@mail.lumoninc.com (replace ABC with your assigned digits)

### Outgoing Mail Server (SMTP)
- **Server**: mail.lumoninc.com
- **Port**: 25
- **Connection Security**: None
- **Authentication Method**: Normal password
- **Username**: sABC@mail.lumoninc.com (same as above)

## Setting Up Thunderbird Email Client

1. Open Thunderbird
2. Go to **Menu** > **New** > **Existing Email Account**
3. Enter your details:
   - Your name: Your Name
   - Email address: sABC@mail.lumoninc.com
   - Password: Your assigned password
4. Click **Continue**
5. Select **Manual config**
6. Enter the settings as shown in the quick reference above
7. Click **Done**

## Setting Up Evolution Email Client

1. Open Evolution
2. If it's your first time, the setup wizard will appear. Otherwise, go to **Edit** > **Accounts**
3. Click **Add** if you're in the Accounts dialog, or follow the wizard
4. Enter your identity information:
   - Full Name: Your Name
   - Email Address: sABC@mail.lumoninc.com
5. For receiving email:
   - Server Type: IMAP
   - Server: mail.lumoninc.com
   - Port: 143
   - Security: None
   - Authentication: Password
   - Username: sABC@mail.lumoninc.com
6. For sending email:
   - Server Type: SMTP
   - Server: mail.lumoninc.com
   - Port: 25
   - Security: None
   - Authentication: Password
   - Username: sABC@mail.lumoninc.com

## Command-Line Email Configuration

### Using msmtp (for sending emails)

Create a configuration file at `~/.msmtprc`:

```
account lumon
host mail.lumoninc.com
port 25
auth on
user sABC@mail.lumoninc.com
password YOUR_PASSWORD
tls off

account default : lumon
```

Make it secure:
```bash
chmod 600 ~/.msmtprc
```

### Using swaks (for testing/sending emails)

Send a test email:
```bash
swaks --to recipient@mail.lumoninc.com \
  --from sABC@mail.lumoninc.com \
  --server mail.lumoninc.com \
  --port 25 \
  --auth-user sABC@mail.lumoninc.com \
  --auth-password YOUR_PASSWORD \
  --h-Subject "Test Email" \
  --body "This is a test email."
```

## Troubleshooting

If you encounter issues with email configuration:

1. **Authentication failures**:
   - Double-check your username format (sABC@mail.lumoninc.com)
   - Verify your password is correct
   - Ensure you're using the correct ports (143 for IMAP, 25 for SMTP)

2. **Connection issues**:
   - Verify you're connected to the cyber range network
   - Check that no firewall is blocking the required ports
   - Try using telnet to test connectivity: `telnet mail.lumoninc.com 25`

3. **Email not sending/receiving**:
   - Confirm the mail server is running in the cyber range
   - Verify your recipient address is valid within the cyber range
   - Check for any error messages in your email client

If problems persist, contact your lab instructor for assistance. 