#!/bin/bash
#
# Name: build_live.sh
# Description: Admin script for building the livecd.
# Authors: See https://github.com/chiru-no/cloveros
# Version: dev

main() {
    check_as_root
    set_password_auto
    setup_chroot
    config_setup
    kernel_install
    bootloader_install
    user_sw_install
    sys_sw_config
    sw_config
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

# Set passwords
# Usage: set_password
set_password_auto() {
    rootpassword=password
    user=user
    userpassword=password
}

# Sets up chrooting
# Usage: setup_chroot
setup_chroot() {
    mkdir image
    cd image

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

#   emerge gentoo-sources genkernel
#   wget http://liquorix.net/sources/4.9/config.amd64
#   genkernel --kernel-config=config.amd64 all
}

# Installs the kernel
# Usage: kernel_install
kernel_install() {
    wget -O - https://raw.githubusercontent.com/chiru-no/cloveros/master/kernel.tar.xz | tar xJ -C /boot/
    mkdir /lib/modules/
    wget -O - https://raw.githubusercontent.com/chiru-no/cloveros/master/modules.tar.xz | tar xJ -C /lib/modules/
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

# Sets up user software installation
# Usage: user_sw_install
user_sw_install() {
    emerge -1 openssh openssl gcc
    echo "media-video/mpv ~amd64" >> /etc/portage/package.accept_keywords
    emerge xorg-server twm feh aterm sudo xfe wpa_supplicant dash porthole firefox emacs gimp mpv smplayer rtorrent weechat conky linux-firmware alsa-utils rxvt-unicode zsh zsh-completions gentoo-zsh-completions inconsolata vlgothic liberation-fonts bind-tools colordiff xdg-utils nano filezilla screenfetch scrot
    rm -Rf /usr/portage/packages/*
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

# Configuration of user software, and final preparation
sw_config() {
    rc-update add alsasound default
    rc-update add wpa_supplicant default
    eselect fontconfig enable 52-infinality.conf
    eselect infinality set infinality
    eselect lcdfilter set infinality

    cd /home/$user/
    rm .bash_profile
    
    wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.bash_profile
    wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.zshrc
    wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.twmrc
    wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.Xdefaults
    wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/wallpaper.png
    echo -e "session = /home/$user/.rtorrent\ndirectory = /home/$user/Downloads/\nport_range = 53165-62153\ndht = on\npeer_exchange = yes\nuse_udp_trackers = yes" > .rtorrent.rc
    
    mkdir Downloads
    mkdir .rtorrent
    mkdir .mpv
    cd .mpv
    wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.mpv/config
    
    chown -R $user /home/$user/
    
    livecd_config
    
#   Exit the chroot
    exit
}

# Extra configuration for livecd building
# Usage: livecd_config
livecd_config() {
    emerge gparted squashfs-tools
    sed -i "s@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@c1:12345:respawn:/sbin/agetty -a user --noclear 38400 tty1 linux@" /etc/inittab
    sed -i "s@twm\&@twm\&\nurxvt -e sudo ./livecd_install.sh \&@" /home/user/.bash_profile
    sed -i "2,3 s/^/#/" /home/user/.bash_profile
    sed -i "10 s/^/#/" /home/user/.bash_profile
    wget https://raw.githubusercontent.com/chiru-no/cloveros/master/livecd_install.sh -O /home/user/livecd_install.sh
    chmod +x /home/user/livecd_install.sh

    emerge -uvD world
    emerge --depclean
    rm -Rf /usr/portage/packages/*
}

# Create the squashfs and delete the image directory
# Usage: create_squashfs
create_squashfs() {
    umount -l image/*
    mksquashfs image image.squashfs -b 1024k -comp xz -Xbcj x86 -Xdict-size 100%
    rm -Rf image/
}

main "$@"
