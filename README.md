# cloveros
![CloverOS GNU/Linux](https://raw.githubusercontent.com/chiru-no/cloveros/master/logo.png "CloverOS GNU/Linux")

CloverOS GNU/Linux is a GNU/Linux distro that runs on Gentoo GNU/Linux and tries to be like CrunchBang. It consists of the install script and the CloverOS GNU/Linux packages repo (Binhost) that contains unique USE flags and CFLAGS. You can download CloverOS GNU/Linux here https://github.com/chiru-no/cloveros/releases

## Cheat sheet

### Installing program
`emerge filezilla`

### Upgrading system
`emerge --sync`

`emerge -uavD world`

### Installing a program when emerge gives an error
`emerge -uavD filezilla world`

`dispatch-conf`

`emerge -uavD filezilla world`

## FAQ

### Is this an overlay?
No, this uses regular Gentoo Portage only. Same versions and USE flag options.

### Package isn't available
Make an issue so I can add the package. In the meantime, edit /etc/make.conf and edit the following line:

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"`

to

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"`

This disables the binhost and uses Portage's ebuilds for packages.
