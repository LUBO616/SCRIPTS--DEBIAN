#!/bin/bash

system_summary() {
    echo "SHOWING SYSTEM SUMMARY..."
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

    echo "======================================"
    echo "SHOWING DISK PARTITIONS... "
    
    # Check if hwinfo is installed
    if ! dpkg -l | grep -q "hwinfo"; then
        echo "INSTALLING HWINFO..."
        apt install -y hwinfo
        echo "Done"
    else
        echo "HWINFO DETECTED"
    fi

    lsblk

    # Ask user if they want more disk information
    while true; do
        read -p "Do you want more disk information [Y/N]? " option

        if [[ "$option" =~ ^[Yy]$ ]]; then
            echo "SHOWING MORE INFORMATION..."
            hwinfo --disk
            echo "Done..."
            break
        elif [[ "$option" =~ ^[Nn]$ ]]; then
            break
        else
            echo "❌ Invalid input. Please enter Y or N."
        fi
    done

    echo "===================================="
    echo "ANALYSIS COMPLETED"
    main_menu
}
preventive_maintenance(){
echo "without service"
main_menu
}

main_menu(){
	# Check if the script is running as root
	if [ "$(id -u)" -ne 0 ]; then
	    echo "❌ Error: This script must be run as root (use sudo)."
	    exit 1
	fi
	while true; do
		echo "=============================="
    echo "       MAIN MENU"
    echo "=============================="
		echo "1. System Summary"
		echo "2. Preventive Maintenance"
		echo "3. Exit"

		# Read user input
		read -p "Enter your choice: " option
		
		case "$option" in
			1) system_summary;;
			2) precentive_maintenance;;
			3) echo "Exiting..."; exit 0;;
			*) echo "❌ Invalid option. Please enter 1, 2 or 3." main_menu;;
		esac
	done
}

main_menu
