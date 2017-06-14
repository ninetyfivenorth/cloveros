read -p "Automatic partitioning (a) or manual partitioning? (m) [a/m] " -n 1 partitioning
echo
if [[ $partitioning = "a" ]]; then
    read -e -p "Enter drive for CloverOS installation: " -i "/dev/sda" drive
    partition=${drive}1
elif [[ $partitioning = "m" ]]; then
    read -e -p "Enter partition for CloverOS installation: " -i "/dev/sda1" partition
    drive=${partition%"${partition##*[!0-9]}"}
else
    echo "Invalid option."
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

read -p "Enter preferred root password " rootpassword
read -p "Enter preferred username " user
read -p "Enter preferred user password " userpassword

mkdir gentoo

if [[ $partitioning = "a" ]]; then
    echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/$drive
fi
mkfs.ext4 -F /dev/$partition
tune2fs -O ^metadata_csum /dev/$partition
mount /dev/$partition gentoo

unsquashfs -f -d gentoo /mnt/cdrom/image.squashfs

cat << EOF | chroot gentoo

echo -e "$rootpassword\n$rootpassword" | passwd
useradd $user
echo -e "$userpassword\n$userpassword" | passwd $user
gpasswd -a $user wheel

mv /home/user/ /home/$user/
chown -R $user /home/$user/

grub-install /dev/$drive
grub-mkconfig > /boot/grub/grub.cfg

sed -i "s@c1:12345:respawn:/sbin/agetty -a user --noclear 38400 tty1 linux@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@" /etc/inittab
sed -i "s@urxvt -e sudo ./livecd_install.sh \&@@" /home/$user/.bash_profile
sed -i "2,3 s/^#*//" /home/$user/.bash_profile
sed -i "10 s/^#*//" /home/$user/.bash_profile
sed -i "/urxvt -e sudo .\/livecd_install.sh &/d" /home/$user/.bash_profile

rm /home/$user/livecd_install.sh

EOF

reboot
