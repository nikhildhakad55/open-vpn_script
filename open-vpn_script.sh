Link :- https://www.cyberciti.biz/faq/howto-setup-openvpn-server-on-ubuntu-linux-14-04-or-16-04-lts/

Step 1.  sudo wget https://git.io/vpn -O openvpn-install.sh

Step 2. devops-pradeep-fdgcx.ovpn

Step3. Make sure you provide needed information:-

Welcome to this OpenVPN road warrior installer!

Which protocol should OpenVPN use?
   1) UDP (recommended)
   2) TCP
Protocol [1]: 1

What port should OpenVPN listen to?
Port [1194]: 

Select a DNS server for the clients:
   1) Current system resolvers
   2) Google
   3) 1.1.1.1
   4) OpenDNS
   5) Quad9
   6) AdGuard
DNS server [1]: 2

Enter a name for the first client:
Name [client]: iphone

OpenVPN installation is ready to begin.
Press any key to continue

Port :- UDP 1194  0.0.0.0.0/0 


========================================================================================================================================================================================================================

#!/bin/bash

################################################################################
# OpenVPN Server Automated Setup Script
# This script automates the installation of OpenVPN server on Ubuntu
# Based on: https://www.cyberciti.biz/faq/howto-setup-openvpn-server-on-ubuntu-linux-14-04-or-16-04-lts/
################################################################################

set -e  # Exit on any error

################################################################################
# CONFIGURATION SECTION - Modify these values as needed
################################################################################

PROTOCOL="1"           # 1 for UDP (recommended), 2 for TCP
PORT="1194"           # Default OpenVPN port
DNS_SERVER="2"        # 1=System, 2=Google, 3=1.1.1.1, 4=OpenDNS, 5=Quad9, 6=AdGuard
CLIENT_NAME="iphone"  # Default client name
SCRIPT_NAME="openvpn-install.sh"
SCRIPT_URL="https://git.io/vpn"

################################################################################
# COLOR CODES FOR OUTPUT
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

################################################################################
# FUNCTIONS
################################################################################

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print section headers
print_header() {
    local message=$1
    echo ""
    print_message "$CYAN" "========================================="
    print_message "$CYAN" "$message"
    print_message "$CYAN" "========================================="
}

# Function to check if running as root
check_root() {
    print_message "$BLUE" "Checking for root privileges..."
    
    if [[ $EUID -ne 0 ]]; then
        print_message "$RED" "✗ Error: This script must be run as root or with sudo"
        print_message "$YELLOW" "  Please run: sudo $0"
        exit 1
    fi
    
    print_message "$GREEN" "✓ Running with root privileges"
}

# Function to check internet connectivity
check_internet() {
    print_message "$BLUE" "Checking internet connectivity..."
    
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_message "$GREEN" "✓ Internet connection is active"
    else
        print_message "$RED" "✗ No internet connection detected"
        print_message "$YELLOW" "  Please check your network connection and try again"
        exit 1
    fi
}

# Function to check system requirements
check_requirements() {
    print_message "$BLUE" "Checking system requirements..."
    
    # Check if wget is installed
    if ! command -v wget &> /dev/null; then
        print_message "$YELLOW" "wget is not installed. Installing..."
        apt-get update && apt-get install -y wget
    fi
    
    print_message "$GREEN" "✓ All requirements met"
}

# Function to backup existing OpenVPN configuration
backup_existing() {
    if [[ -d "/etc/openvpn" ]]; then
        print_message "$YELLOW" "Existing OpenVPN installation detected"
        BACKUP_DIR="/etc/openvpn.backup.$(date +%Y%m%d_%H%M%S)"
        print_message "$BLUE" "Creating backup at: $BACKUP_DIR"
        cp -r /etc/openvpn "$BACKUP_DIR"
        print_message "$GREEN" "✓ Backup created successfully"
    fi
}

# Function to download OpenVPN installer
download_installer() {
    print_header "STEP 1: Downloading OpenVPN Installer"
    
    # Remove old installer if exists
    if [[ -f "$SCRIPT_NAME" ]]; then
        print_message "$YELLOW" "Removing old installer script..."
        rm -f "$SCRIPT_NAME"
    fi
    
    print_message "$BLUE" "Downloading from: $SCRIPT_URL"
    
    if wget "$SCRIPT_URL" -O "$SCRIPT_NAME"; then
        print_message "$GREEN" "✓ Installer downloaded successfully"
        chmod +x "$SCRIPT_NAME"
        print_message "$GREEN" "✓ Made installer executable"
    else
        print_message "$RED" "✗ Failed to download installer"
        print_message "$YELLOW" "  Please check your internet connection and try again"
        exit 1
    fi
}

# Function to get DNS server name
get_dns_name() {
    case $1 in
        1) echo "Current system resolvers" ;;
        2) echo "Google (8.8.8.8)" ;;
        3) echo "Cloudflare (1.1.1.1)" ;;
        4) echo "OpenDNS" ;;
        5) echo "Quad9" ;;
        6) echo "AdGuard" ;;
        *) echo "Unknown" ;;
    esac
}

# Function to display configuration summary
show_configuration() {
    print_header "STEP 2: Configuration Summary"
    
    print_message "$YELLOW" "The following configuration will be used:"
    echo ""
    print_message "$CYAN" "  Protocol:    $([ $PROTOCOL -eq 1 ] && echo 'UDP (Recommended)' || echo 'TCP')"
    print_message "$CYAN" "  Port:        $PORT"
    print_message "$CYAN" "  DNS Server:  $(get_dns_name $DNS_SERVER)"
    print_message "$CYAN" "  Client Name: $CLIENT_NAME"
    echo ""
}

# Function to run OpenVPN installer with automated inputs
run_installer() {
    print_header "STEP 3: Running OpenVPN Installation"
    
    show_configuration
    
    print_message "$YELLOW" "Starting installation automatically in 3 seconds..."
    sleep 3
    
    print_message "$BLUE" "Starting OpenVPN installation..."
    echo ""
    
    # Run the installer with automated responses
    bash "$SCRIPT_NAME" <<EOF
$PROTOCOL
$PORT
$DNS_SERVER
$CLIENT_NAME

EOF
    
    print_message "$GREEN" "✓ OpenVPN installation completed"
}

# Function to locate client configuration file
find_client_config() {
    local config_file=""
    
    # Check common locations
    if [[ -f "/root/${CLIENT_NAME}.ovpn" ]]; then
        config_file="/root/${CLIENT_NAME}.ovpn"
    elif [[ -f "$(pwd)/${CLIENT_NAME}.ovpn" ]]; then
        config_file="$(pwd)/${CLIENT_NAME}.ovpn"
    elif [[ -f "/etc/openvpn/client/${CLIENT_NAME}.ovpn" ]]; then
        config_file="/etc/openvpn/client/${CLIENT_NAME}.ovpn"
    fi
    
    echo "$config_file"
}

# Function to display completion message and instructions
show_completion() {
    print_header "Installation Complete!"
    
    print_message "$GREEN" "OpenVPN server has been successfully installed and configured!"
    echo ""
    
    # Find client configuration file
    CLIENT_CONFIG=$(find_client_config)
    
    if [[ -n "$CLIENT_CONFIG" ]]; then
        print_message "$YELLOW" "📁 Client Configuration File:"
        print_message "$CYAN" "   $CLIENT_CONFIG"
        echo ""
        
        print_message "$YELLOW" "📱 To connect from your device:"
        print_message "$CYAN" "   1. Copy the .ovpn file to your device"
        print_message "$CYAN" "   2. Import it into your OpenVPN client app"
        print_message "$CYAN" "   3. Connect to the VPN"
        echo ""
        
        print_message "$YELLOW" "📋 To copy the file (example using SCP):"
        print_message "$CYAN" "   scp $CLIENT_CONFIG user@your-device:/path/"
    else
        print_message "$YELLOW" "Client configuration file location:"
        print_message "$CYAN" "   Check /root/ or current directory for ${CLIENT_NAME}.ovpn"
    fi
    
    echo ""
    print_message "$YELLOW" "🔧 Useful Commands:"
    print_message "$CYAN" "   Add new client:        sudo bash $SCRIPT_NAME"
    print_message "$CYAN" "   Check VPN status:      sudo systemctl status openvpn@server"
    print_message "$CYAN" "   View VPN logs:         sudo journalctl -u openvpn@server -f"
    print_message "$CYAN" "   Restart VPN service:   sudo systemctl restart openvpn@server"
    
    echo ""
    print_message "$YELLOW" "🔐 Security Notes:"
    print_message "$CYAN" "   • Keep your .ovpn files secure"
    print_message "$CYAN" "   • Don't share them publicly"
    print_message "$CYAN" "   • Use firewall rules to restrict access if needed"
    
    echo ""
    print_message "$GREEN" "========================================="
    print_message "$GREEN" "Thank you for using this setup script! writen by Pradeep Kumar"
    print_message "$GREEN" "========================================="
    echo ""
}

# Run main function
main "$@"
