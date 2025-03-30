#!/bin/bash

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display banner
echo -e "${YELLOW}"
echo "╔═════════════════════════════════════════════════╗"
echo "║                                                 ║"
echo "║         PHISHING EMAIL SENDER                   ║"
echo "║                                                 ║"
echo "╚═════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to display usage
show_usage() {
    echo -e "Usage: $0 [options]"
    echo -e "Options:"
    echo -e "  -t, --target <target>    Target information (organization, person, or role)"
    echo -e "  -s, --scenario <type>    Type of phishing scenario (account, security, invoice, etc.)"
    echo -e "  -u, --urgency <level>    Urgency level (low, medium, high, critical)"
    echo -e "  -c, --custom <file>      Use custom HTML template file"
    echo -e "  -h, --help               Display this help message"
    echo -e "\nExamples:"
    echo -e "  $0                                      # Basic email with default template"
    echo -e "  $0 -t \"Acme Corporation\" -s security   # Targeted security alert for Acme Corp"
    echo -e "  $0 -c my_template.html                  # Use custom HTML template"
    exit 1
}

# Default values
TARGET_INFO=""
SCENARIO="security"
URGENCY="high"
CUSTOM_TEMPLATE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--target)
            TARGET_INFO="$2"
            shift 2
            ;;
        -s|--scenario)
            SCENARIO="$2"
            shift 2
            ;;
        -u|--urgency)
            URGENCY="$2"
            shift 2
            ;;
        -c|--custom)
            CUSTOM_TEMPLATE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} Unknown option: $1"
            show_usage
            ;;
    esac
done

# Load environment variables
source .env

# Check if target email is set, otherwise use self
if [ -z "$TARGET_EMAIL" ]; then
    TARGET_EMAIL="$EMAIL_USERNAME"
    echo -e "${YELLOW}[INFO]${NC} No target specified in .env, sending to yourself: $TARGET_EMAIL"
fi

# Function to generate company name if not provided
generate_company_name() {
    local companies=("Acme Industries" "Global Tech" "SecureNet" "TrustBank" "Lumon Industries" "CloudSync" "InfoCore" "DataSphere" "NetSecure" "Omnicorp")
    echo "${companies[$RANDOM % ${#companies[@]}]}"
}

# Function to generate email subject based on scenario
generate_subject() {
    local scenario=$1
    local urgency=$2
    
    case $scenario in
        security)
            case $urgency in
                low)
                    echo "Security Notification - Action Recommended"
                    ;;
                medium)
                    echo "Security Alert - Action Required Soon"
                    ;;
                high)
                    echo "URGENT: Security Alert - Immediate Action Required"
                    ;;
                critical)
                    echo "CRITICAL SECURITY BREACH - IMMEDIATE ACTION REQUIRED"
                    ;;
                *)
                    echo "Security Alert - Action Required"
                    ;;
            esac
            ;;
        account)
            case $urgency in
                low)
                    echo "Account Verification Needed"
                    ;;
                medium)
                    echo "Important: Account Verification Required"
                    ;;
                high)
                    echo "URGENT: Account Access Will Be Suspended"
                    ;;
                critical)
                    echo "CRITICAL: YOUR ACCOUNT HAS BEEN COMPROMISED"
                    ;;
                *)
                    echo "Account Verification Required"
                    ;;
            esac
            ;;
        invoice)
            case $urgency in
                low)
                    echo "Invoice Payment Notification"
                    ;;
                medium)
                    echo "Important: Invoice Payment Due"
                    ;;
                high)
                    echo "URGENT: Overdue Invoice Payment"
                    ;;
                critical)
                    echo "FINAL NOTICE: OVERDUE PAYMENT - LEGAL ACTION PENDING"
                    ;;
                *)
                    echo "Invoice Payment Required"
                    ;;
            esac
            ;;
        document)
            case $urgency in
                low)
                    echo "Document Requires Your Review"
                    ;;
                medium)
                    echo "Important Document Awaiting Your Signature"
                    ;;
                high)
                    echo "URGENT: Document Requires Immediate Review"
                    ;;
                critical)
                    echo "CRITICAL: TIME-SENSITIVE DOCUMENT EXPIRING TODAY"
                    ;;
                *)
                    echo "Document Requires Attention"
                    ;;
            esac
            ;;
        *)
            echo "Important Notification - Action Required"
            ;;
    esac
}

# Function to generate HTML email based on scenario and target
generate_html_email() {
    local target="$1"
    local scenario="$2"
    local urgency="$3"
    
    # If target is empty, generate a company name
    if [ -z "$target" ]; then
        target=$(generate_company_name)
    fi
    
    local subject=$(generate_subject "$scenario" "$urgency")
    local button_text=""
    local main_text=""
    local color="#003366"
    
    # Set button text based on scenario
    case $scenario in
        security)
            button_text="Verify Security Settings"
            main_text="Our security system has detected unusual login attempts on your account. To protect your information, we require immediate verification of your identity."
            color="#D32F2F" # Red for security
            ;;
        account)
            button_text="Verify Account Now"
            main_text="Your account requires verification to ensure continued access to all services. Failure to verify may result in temporary account suspension."
            color="#1976D2" # Blue for account
            ;;
        invoice)
            button_text="View Invoice Details"
            main_text="An important invoice requires your immediate attention. Please review the payment details and process this transaction as soon as possible."
            color="#388E3C" # Green for invoices
            ;;
        document)
            button_text="View Document"
            main_text="An important document is awaiting your review and signature. This document requires your attention before it expires."
            color="#F57C00" # Orange for documents
            ;;
        *)
            button_text="Continue"
            main_text="Please verify your information to continue accessing your account services."
            ;;
    esac
    
    # Create the HTML email
    cat > html_email_template.html << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${subject}</title>
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; line-height: 1.6;">
    <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px; border-collapse: collapse;">
        <!-- HEADER WITH LOGO -->
        <tr>
            <td align="center" bgcolor="${color}" style="padding: 20px 0;">
                <h1 style="color: white; margin: 0;">${target}</h1>
            </td>
        </tr>
        
        <!-- CONTENT AREA -->
        <tr>
            <td bgcolor="#ffffff" style="padding: 40px 30px;">
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td style="color: #153643; font-size: 24px; font-weight: bold;">
                            ${subject}
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 20px 0;">
                            <p>Dear Valued User,</p>
                            
                            <p>${main_text}</p>
EOF

    # Add urgency-specific text
    case $urgency in
        low)
            cat >> html_email_template.html << EOF
                            <p>Please complete this verification at your earliest convenience.</p>
EOF
            ;;
        medium)
            cat >> html_email_template.html << EOF
                            <p>Please complete this verification within the next 48 hours to avoid any service interruptions.</p>
EOF
            ;;
        high)
            cat >> html_email_template.html << EOF
                            <p><strong>You must complete this verification within the next 24 hours</strong> to maintain access to all services.</p>
                            
                            <p>This verification is mandatory according to our security policy.</p>
EOF
            ;;
        critical)
            cat >> html_email_template.html << EOF
                            <p><strong>IMMEDIATE ACTION REQUIRED: You must complete this verification IMMEDIATELY.</strong> Your account access has already been restricted.</p>
                            
                            <p>Failure to act immediately will result in complete account lockout within the next 2 hours.</p>
EOF
            ;;
    esac

    # Complete the email template
    cat >> html_email_template.html << EOF
                        </td>
                    </tr>
                    <tr>
                        <td align="center" style="padding: 30px 0;">
                            <table border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" bgcolor="${color}" style="border-radius: 4px;">
                                        <a href="http://${SERVER_IP}" target="_blank" style="display: inline-block; padding: 15px 30px; font-size: 16px; color: #ffffff; text-decoration: none; font-weight: bold;">${button_text}</a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
EOF

    # Add scenario-specific closing text
    case $scenario in
        security)
            cat >> html_email_template.html << EOF
                            <p>If you did not attempt to access your account, please complete the verification process immediately and then contact our security team.</p>
                            
                            <p>For security reasons, please do not reply to this email.</p>
EOF
            ;;
        account)
            cat >> html_email_template.html << EOF
                            <p>This verification process helps us ensure that your account remains secure and accessible only to you.</p>
                            
                            <p>If you have any questions, please contact our support team after completing verification.</p>
EOF
            ;;
        invoice)
            cat >> html_email_template.html << EOF
                            <p>This invoice requires processing by the indicated due date to avoid any late fees or service interruptions.</p>
                            
                            <p>If you believe this invoice was sent in error, please verify your details first, then contact our billing department.</p>
EOF
            ;;
        document)
            cat >> html_email_template.html << EOF
                            <p>The document will expire if not reviewed in a timely manner, which may result in delays or additional processing requirements.</p>
                            
                            <p>Please ensure you have access to your account credentials before proceeding.</p>
EOF
            ;;
    esac

    # Finish the email template
    cat >> html_email_template.html << EOF
                            <p>Thank you for your prompt attention to this matter.</p>
                            
                            <p>Regards,<br>
                            ${target} Support Team</p>
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
                            <p>&copy; 2023 ${target}. All rights reserved.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
EOF

    echo -e "${GREEN}[SUCCESS]${NC} Generated ${urgency} urgency ${scenario} phishing email for ${target}"
}

# Determine which template to use
email_template="html_email_template.html"
subject="Urgent: Security Alert - Immediate Action Required"

if [ -n "$CUSTOM_TEMPLATE" ] && [ -f "$CUSTOM_TEMPLATE" ]; then
    # Use custom template provided
    cp "$CUSTOM_TEMPLATE" html_email_template.html
    echo -e "${YELLOW}[INFO]${NC} Using custom HTML template: $CUSTOM_TEMPLATE"
elif [ -n "$TARGET_INFO" ]; then
    # Generate dynamic template based on provided information
    generate_html_email "$TARGET_INFO" "$SCENARIO" "$URGENCY"
    subject=$(generate_subject "$SCENARIO" "$URGENCY")
elif [ -f "html_email_template.html" ]; then
    # Use existing template
    echo -e "${YELLOW}[INFO]${NC} Using existing HTML template"
else
    # Generate default template
    generate_html_email "" "$SCENARIO" "$URGENCY"
    subject=$(generate_subject "$SCENARIO" "$URGENCY")
fi

# Send email using swaks with proper HTML content type
echo -e "${YELLOW}[INFO]${NC} Sending email using swaks..."
swaks --to "$TARGET_EMAIL" \
      --from "$EMAIL_USERNAME" \
      --server mail.lumoninc.com \
      --port 25 \
      --auth-user "$EMAIL_USERNAME" \
      --auth-password "$EMAIL_PASSWORD" \
      --h-Subject "$subject" \
      --h-Content-Type "text/html; charset=UTF-8" \
      --body "$(cat html_email_template.html)"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS]${NC} Email sent successfully to $TARGET_EMAIL"
else
    echo -e "${RED}[FAILED]${NC} Failed to send email with swaks."
    echo -e "${YELLOW}[INFO]${NC} Check your email credentials and connectivity."
fi

# Provide info for manual testing
echo -e "${YELLOW}[INFO]${NC} For manual email testing, use these settings:"
echo -e "    SMTP Server: mail.lumoninc.com"
echo -e "    Port: 25"
echo -e "    Username: $EMAIL_USERNAME"
echo -e "    Password: (your password in .env)"
echo -e "    Security: None" 