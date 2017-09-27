#!/usr/bin/env bash

DOTFILES_DIRECTORY="${HOME}/repo/dotfiles"

# set 256 color profile where possible
if [[ $COLORTERM == gnome-* && $TERM == xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM=xterm-256color
fi


#load_dotfiles() {
#    declare -a files=(
#        ${DOTFILES_DIRECTORY}/.exports # Exports
#        ${DOTFILES_DIRECTORY}/.aliases # Aliases
#    )
#
#    # if these files are readable, source them
#    for index in "${files}"
##    for index in files
#    do
#        if [[ -r ${files[$index]} ]]; then
#            source ${files[$index]}
#        fi
#    done
#}
source ${DOTFILES_DIRECTORY}/.exports # Exports
source ${DOTFILES_DIRECTORY}/.aliases # Aliases

#load_dotfiles

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"


unset load_dotfiles