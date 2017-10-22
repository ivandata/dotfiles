#!/usr/bin/env bash

DOTFILES_DIRECTORY="${HOME}/.dotfiles"

# set 256 color profile where possible
if [[ $COLORTERM == gnome-* && $TERM == xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

source ${DOTFILES_DIRECTORY}/.exports # Exports
source ${DOTFILES_DIRECTORY}/.aliases # Aliases

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"


unset load_dotfiles