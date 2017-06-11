if [ -z "$DISPLAY" ]; then
    read -p "Start X? y/n" -n 1 yn
    if [[ $yn == "Y" || $yn == "y" ]]; then
       export DISPLAY=:0
       X&
       sleep 1
       twm&
       feh --bg-max wallpaper.png
    fi
fi

alias public-ip='dig +short myip.opendns.com @resolver1.opendns.com' # Returns public IP
alias ls='ls --color=auto' # color ls output
alias grep='grep --color=auto' # color grep output
alias diff='colordiff' # color diff output
alias ports='netstat -tulanp' # lists open network ports
alias wget='wget -c' # make wget default to continue download on lost connections
alias meminfo='free -m -l -t' # memory and swap information humanreadable output

# color layout for bash sessions with git integration, currently broken
#export PS1='\[\033[01;30m\]\t `if [ $? = 0 ]; then echo "\[\033[01;32m\]ツ"; else echo "\[\033[01;31m\]✗"; fi` \[\033[00;32m\]\h\[\033[00;37m\]:\[\033[31m\]$(__git_ps1 "(%s)\[\033[01m\]")\[\033[00;34m\]\w\[\033[00m\] >'
