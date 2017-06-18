#!/bin/bash
#
# Name: livecd_install.sh
# Description: The CloverOS installation script.
# Authors: See https://github.com/chiru-no/cloveros
# Version: dev

main() {
    check_as_root
    partition
    set_password
    setup_chroot_squashfs
    config_setup
    bootloader_install
    sys_sw_config
    livecd_cleanup
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

# Partition disks
# Usage: partition
partition() {
    read -p "Automatic partitioning (a) or manual partitioning? (m) [a/m] " -n 1 partitioning
    echo
    if [[ $partitioning = "a" ]]; then
        read -e -p "Enter drive for CloverOS installation: " -i "/dev/sda" drive
        partition=${drive}1
    elif [[ $partitioning = "m" ]]; then
        read -e -p "Enter partition for CloverOS installation: " -i "/dev/sda1" partition
        drive=${partition%"${partition##*[!0-9]}"}
    else
        p_error "Invalid option!"
        exit 1
    fi
    drive=${drive#*/dev/}
    partition=${partition#*/dev/}
    read -p "Partitioning: $partitioning
    Drive: /dev/$drive
    Partition: /dev/$partition
    Is this correct? [y/n] " -n 1 yn
    if [[ $yn != "y" ]]; then
        exit 1
    fi
    echo
    
    if [[ $partitioning = "a" ]]; then
        echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/$drive
    fi
    
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
setup_chroot_squashfs() {
    unsquashfs -f -d gentoo /mnt/cdrom/image.squashfs
}

# Syncs the gentoo tree and sets up the initial configuration 
# Usage: config_setup
config_setup () {
    chroot .

    emerge-webrsync

    echo -e '\nPORTAGE_BINHOST="https://cloveros.ga"\nMAKEOPTS="-j8"\nEMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"\nCFLAGS="-O3 -pipe -funroll-loops -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution"\nCXXFLAGS="${CFLAGS}"' >> /etc/portage/make.conf

#   emerge gentoo-sources genkernel
#   wget http://liquorix.net/sources/4.9/config.amd64
#   genkernel --kernel-config=config.amd64 all
}

# Installs the bootloader
# Usage: bootloader_install
bootloader_install() {
    emerge grub dhcpcd

    grub-install /dev/$drive
    grub-mkconfig > /boot/grub/grub.cfg

    rc-update add dhcpcd default

    echo -e "$rootpassword\n$rootpassword" | passwd
    useradd $user
    echo -e "$userpassword\n$userpassword" | passwd $user
    gpasswd -a $user wheel
}

# System software configuration
# Usage: sys_sw_config
sys_sw_config() {
    sed -i "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
    sed -Ei "s@c([2-6]):2345:respawn:/sbin/agetty 38400 tty@#\0@" /etc/inittab
    sed -i "s@c1:12345:respawn:/sbin/agetty 38400 tty1 linux@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@" /etc/inittab
    sed -i "s/set timeout=5/set timeout=0/" /boot/grub/grub.cfg
    echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel\nupdate_config=1" > /etc/wpa_supplicant/wpa_supplicant.conf
        
    gpasswd -a $user audio
    gpasswd -a $user video
}

# Cleans up for the livecd
# Usage: livecd_cleanup
livecd_cleanup() {
    mv /home/user/ /home/$user/
    chown -R $user /home/$user/
    if [[ $user != "user" ]]; then
        userdel user
    fi
    rm /home/$user/livecd_install.sh
}
    
# Reboot the system; made as a function for different means of rebooting
# Usage: reboot_system
reboot_system() {
    reboot
}

main "$@"
