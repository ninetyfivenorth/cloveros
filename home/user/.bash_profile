if [ -z "$DISPLAY" ]; then
    read -p "Start X? [y/n]" -n 1 yn
    if [[ $yn == "Y" || $yn == "y" ]]; then
       export DISPLAY=:0
       X&
       sleep 1
       twm&
       feh --bg-max wallpaper.png
    fi
fi

# color layout for bash sessions with git integration, currently broken
#export PS1='\[\033[01;30m\]\t `if [ $? = 0 ]; then echo "\[\033[01;32m\]ツ"; else echo "\[\033[01;31m\]✗"; fi` \[\033[00;32m\]\h\[\033[00;37m\]:\[\033[31m\]$(__git_ps1 "(%s)\[\033[01m\]")\[\033[00;34m\]\w\[\033[00m\] >'
