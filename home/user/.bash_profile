if [ -z "$DISPLAY" ]; then
    echo "WM Options: (3) i3 (a) Awesome (k) KDE (m) MATE (x) XFCE (l) LXDE"
    read -p "Start X? [y/n]" -n 1 choice
    declare -A wms
    declare -A wmspkg
    declare -A wmspost
    wms[y]=twm
    wms[Y]=twm
    wms[3]=i3
    wms[a]=awesome
    wms[k]=startkde
    wms[m]=startmate
    wms[x]=startxfce4
    wms[l]=startlxde
    wmpkgs[y]=twm
    wmspkg[Y]=twm
    wmspkg[3]=i3
    wmspkg[a]=awesome
    wmspkg[k]=plasma-desktop
    wmspkg[m]=mate
    wmspkg[x]=xfce4-meta
    wmspkg[l]=lxde-meta
    wmspost[y]="feh --bg-max wallpaper.png"
    wmspost[Y]="feh --bg-max wallpaper.png"
    wmspost[3]="feh --bg-max wallpaper.png"
    wmspost[a]="feh --bg-max wallpaper.png"
    wmspost[k]="feh --bg-max wallpaper.png"
    wmspost[m]="feh --bg-max wallpaper.png"
    wmspost[x]="feh --bg-max wallpaper.png"
    wmspost[l]="feh --bg-max wallpaper.png"
    if [ -n "${wms[$choice] + 1}" ]; then
        if [ ! -f /usr/bin/${wms[$choice]} ]; then
            echo
            echo ${wms[$choice]} is not installed. Install it by running:
            echo $ sudo emerge ${wmspkg[$choice]}
            exit 1
        fi
        export DISPLAY=:0
        X&
	$($wms[$choice])&
        sleep 1
        $($wmpost[$choice])
    fi
fi
