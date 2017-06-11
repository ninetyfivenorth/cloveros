HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

autoload -U compinit promptinit
compinit
promptinit; prompt gentoo

zstyle ':completion::complete:*' use-cache 1
