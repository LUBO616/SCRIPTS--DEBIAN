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

preventive_maintenance() {
    echo "======================================"
    echo "INITIALIZING MAINTENANCE..."
    echo "======================================"

    echo "FULL PREVENTIVE MAINTENANCE FOR YOUR DISK"
    echo "======================================"
    echo "DETECTING ROOT DISK AND PARTITION..."
    
    ROOT_DISK=$(lsblk -ndo PKNAME $(df / | awk 'NR==2 {print $1}'))
    ROOT_PART=$(df / | awk 'NR==2 {print $1}')
    
    echo "Detected root disk: $ROOT_DISK"
    echo "Detected root partition: $ROOT_PART"
    echo "-Done-"

    echo "CHECKING DISK HEALTH..."
    sudo smartctl -H /dev/$ROOT_DISK
    sudo smartctl -t long /dev/$ROOT_DISK
    echo "-Done-"
    
    echo "VERIFYING AND REPAIRING BTRFS FILE SYSTEM..."
    sudo btrfs scrub start /
    sudo btrfs scrub start /home
    sudo btrfs scrub status /
    echo "-Done-"

    echo "REVIEWING AND CLEANING UP SUBVOLUMES..."
    sudo btrfs subvolume list /

    read -p "Do you want to delete the /path/to/snapshot directory? [Y/N] " option
    while true; do
        if [[ "$option" =~ ^[Yy]$ ]]; then
            sudo btrfs subvolume delete /path/to/snapshot
            echo "ELIMINATING /path/to/snapshot... Done"
            break
        elif [[ "$option" =~ ^[Nn]$ ]]; then
            echo "SAVING /path/to/snapshot... Done"
            break
        else
            echo "❌ Invalid option, try again."
            read -p "Do you want to delete the /path/to/snapshot directory? [Y/N] " option
        fi
    done

    echo "CHECKING AND REPAIRING EFI PARTITION..."
    EFI_PART=$(lsblk -lno NAME,MOUNTPOINT | awk '$2=="/boot/efi" {print $1}')
    if [ -n "$EFI_PART" ]; then
        sudo fsck.vfat /dev/$EFI_PART
    fi

    echo "======================================"
    echo "Resolving broken dependencies..."
    sudo apt --fix-broken install
    sudo dpkg --configure -a
    echo "-Done-"

    echo "Upgrading packages and removing obsolete dependencies..."
    sudo apt upgrade -y
    echo "-Done-"

    echo "Updating the Xapian index..."
    sudo update-apt-xapian-index
    echo "-Done-"

    echo "Checking for broken or missing dependencies..."
    sudo apt install -f
    echo "-Done-"

    echo "Successful"
    read -n 1 -s -r -p "Press any key to exit..."
    echo "Bye"
    exit 0
}

main_menu() {
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

        read -p "Enter your choice: " option
        
        case "$option" in
            1) system_summary ;;
            2) preventive_maintenance ;;
            3) echo "Exiting..."; exit 0 ;;
            *) echo "❌ Invalid option. Please enter 1, 2, or 3." ;;
        esac
    done
}

main_menu
