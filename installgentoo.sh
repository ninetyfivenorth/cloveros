#!/bin/bash
#
# Name: installgentoo.sh
# Description: The CloverOS installation script.
# Authors: See https://github.com/chiru-no/cloveros
# Version: dev

main() {
    check_as_root
    partition_auto
    set_password
    setup_chroot
    config_setup
    reboot_system
}

## Print functions
# Used to print messages.

# Define colors
GOOD=$(printf '\033[32;01m')
WARN=$(printf '\033[33;01m')
BAD=$(printf '\033[31;01m')
HILITE=$(printf '\033[36;01m')
BRACKET=$(printf '\033[34;01m')
NORMAL=$(printf '\033[0m')

# Print error messages ########################################################
# Usage: p_error [message]
p_error() {
    printf "${BAD}*${NORMAL} %s\n" "$1"
}

## Worker functions ###########################################################
# For usage in main loop: each of these do a specific action. Designed to be
# able to be swapped out indepently, much like Alpine's install scripts.

# Checks for root status
# Usage: check_root
check_as_root() {
    if [ "$(id -u)" != "0" ]; then
        p_error "This script must be run as root!" 1>&2
        exit 1
    fi
}

# Partition disks, automatically
# Usage: partition
partition_auto() {
    echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/$drive
    
    mkfs.ext4 -F /dev/$partition
    tune2fs -O ^metadata_csum /dev/$partition
    mount /dev/$partition gentoo
}

# Set passwords
# Usage: set_password
set_password() {
    read -p "Enter preferred root password " rootpassword
    read -p "Enter preferred username " user
    read -p "Enter preferred user password " userpassword
}

# Sets up chrooting
# Usage: setup_chroot
setup_chroot() {
    mkdir gentoo
    cd gentoo

    wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20170615.tar.bz2
    tar pxf stage3*
    rm -f stage3*

    cp /etc/resolv.conf etc
    mount -t proc none proc
    mount --rbind /dev dev
    mount --rbind /sys sys
}

# Syncs the gentoo tree and sets up the initial configuration 
# Usage: config_setup
config_setup () {
    chroot .

    emerge-webrsync

    echo -e '\nPORTAGE_BINHOST="https://cloveros.ga"\nMAKEOPTS="-j8"\nEMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"\nCFLAGS="-O3 -pipe -funroll-loops -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution"\nCXXFLAGS="${CFLAGS}"' >> /etc/portage/make.conf

    emerge gentoo-sources genkernel
    wget http://liquorix.net/sources/4.9/config.amd64
    genkernel --kernel-config=config.amd64 all
}


reboot_system() {
    reboot
}

main "$@"
