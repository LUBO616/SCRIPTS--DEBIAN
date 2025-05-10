#!/bin/bash

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Error: This script must be run as root (use sudo)."
    exit 1
fi

echo "Select an option:"
echo "1. System Summary"
echo "2. Preventive Maintenance"
echo "3. Exit"

# Read user input
read -p "Enter your choice: " option

if [ "$option" -eq 1 ]; then
    echo "Showing system summary..."
    echo "======================================="

    # Display system information
    echo "Operating System: $(uname -s)"
    echo "Kernel Version: $(uname -r)"
    echo "Processor Architecture: $(uname -m)"
    echo "Host Name: $(uname -n)"

    echo "======================================="
    echo "LISTING SYSTEM USERS..."
    
    # Get all system users and iterate correctly
    while IFS=: read -r username _; do
        if groups "$username" | grep -q "sudo"; then
            echo "👑 $username → Administrator (sudo)"
        else
            echo "🔒 $username → Limited User"
        fi
    done < /etc/passwd

    echo "Analysis completed"

elif [ "$option" -eq 2 ]; then
    echo "======================================"
    echo "Initializing maintenance..."
    echo "upgrade packages and remove obsolete dependencies..."
    apt full-upgrade;
    echo "-Done-"
    echo"Updates the Xaplan index..."
    update-apt-xapian-index;
    echo "-Done-"
    echo "Resolves dependencies..."
    aptitude safe-upgrade;
    echo "-Done-"
    echo "Checks for broken or missing dependencies..."
    apt install -f;
    echo "-Done-"
    echo "Completes interrupted installations..."
    sudo dpkg --configure -a;
    echo "-Done-"
    sudo apt --fix-broken install
    echo "Successful"
    echo "Press any key to exit..."
    read -n 1
    echo "Bye"
    exit 0

elif [ "$option" -eq 3 ]; then
    echo "Exiting..."
    exit 0
else
    echo "Invalid option. Please try again."
fi

