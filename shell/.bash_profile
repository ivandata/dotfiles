#!/usr/bin/env bash

# set 256 color profile where possible
if [[ $COLORTERM == gnome-* && $TERM == xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

source $HOME/.dotfiles/.exports # Exports
source $HOME/.dotfiles/.aliases # Aliases

if [[ -d ${HOME}/.bash_profile.local ]]; then
    source ${HOME}/.bash_profile.local
fi

