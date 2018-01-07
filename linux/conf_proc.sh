#! /bin/bash

# cp ~/.emacs ~/ws/cmos_linux/linux/dotfiles/.emacs
# cp ~/.bashrc ~/ws/cmos_linux/linux/dotfiles/.bashrc
# cp ~/.bash_profile ~/ws/cmos_linux/linux/dotfiles/.bash_profile
# cp ~/.vimrc ~/ws/cmos_linux/linux/dotfiles/.vimrc
# cp ~/.xinitrc ~/ws/cmos_linux/linux/dotfiles/.xinitrc
# cp ~/.Xresources ~/ws/cmos_linux/linux/dotfiles/.Xresources
# cp ~/.gitconfig ~/ws/cmos_linux/linux/dotfiles/.gitconfig
# cp ~/.config/i3/config ~/ws/cmos_linux/linux/dotfiles/.config/i3/config
# cp ~/.config/i3status/config ~/ws/cmos_linux/linux/dotfiles/.config/i3status/config
# cp ~/.config/dunst/dunstrc ~/ws/cmos_linux/linux/dotfiles/.config/dunst/dunstrc

mode_str=""
while getopts "abch" arg
do
    case $arg in
        a)
            echo 'applying dotfiles...'
            mode_str="${mode_str}a"
            ;;
        b)
            echo 'backing up dotfiles...'
            mode_str="${mode_str}b"
            ;;
        c)
            echo 'checking dotfiles...'
            mode_str="${mode_str}c"
            ;;
        h)
            echo 'three basic arguments provided:'
            echo '-a: applying related dotfiles from repo to $HOME'
            echo '-b: backing up related dotfiles from $HOME to repo'
            echo '-c: checking and diffing related dotfiles between $HOME and repo'
            ;;
        ?)
        echo "error: unkonw argument"
        exit 1
        ;;
    esac
done

if [ ${#mode_str} -ne 1 ]; then
    echo "error: please act one by one"
    exit 1
fi

proc_dir=`dirname $0`
for f in `find "$proc_dir/dotfiles/" -type f`
do
    if [ $mode_str == "c" ]; then
        echo "${f/[d]/~}"
    fi
done
