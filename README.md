# cloveros
![CloverOS GNU/Linux](https://raw.githubusercontent.com/chiru-no/cloveros/master/logo.png "CloverOS GNU/Linux")

CloverOS GNU/Linux is a GNU/Linux distro that runs on Gentoo GNU/Linux and tries to be like CrunchBang. It consists of the install script and the CloverOS GNU/Linux packages repo (Binhost) that contains unique USE flags and CFLAGS.

## Quick Start
Boot up a Linux LiveCD and run `bash <(curl -s https://cloveros.ga/s/installscript.sh)`. **This wipes /dev/sda**, installer coming soon.

## Cheat sheet

### Installing program
`emerge filezilla`

### Upgrading system
`emerge --sync`

`emerge -uavD world`

### Installing a program when emerge gives an error
`emerge -auvDG filezilla world`

`dispatch-conf`

`emerge -auvDG filezilla world`

## FAQ

### Is this an overlay?
No, this uses regular Gentoo Portage only. Same versions and USE flag options.

### Manual partitoning
Edit the following lines of the install script:

`echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/sda` <-- Remove this entirely.

`mkfs.ext4 -F /dev/sda1` <-- Change /dev/sda1

`mount /dev/sda1 gentoo` <-- Change /dev/sda1

`grub-install /dev/sda` <-- Change to correct drive letter. When booting, use F12 to manually select drive.
