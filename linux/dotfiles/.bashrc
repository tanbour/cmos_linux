#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# PS1='[\u@\h: \W]\$ '
PS1='[\u@\h: $(pwd)]\$ '
# csh: set prompt = '[%n@%m: %~]$ '

export TERM=linux
export EDITOR='emacsclient -c -a emacs'
export PATH=$PATH:~/eod_c8_64

complete -cf sudo

alias atu='echo "\033AnSiTu" $USER'
alias ath='echo "\033AnSiTh" $HOST'
alias atc='echo "\033AnSiTc" $PWD'
alias ec='emacsclient -c -a emacs'
alias ls='ls --color=auto'
alias ll='ls -al'
alias grep='grep --color=auto'
