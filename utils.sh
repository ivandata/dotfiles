#!/usr/bin/env bash

# Print in colors
print_in_red() {
    printf "$(tput setaf 001)$1"
}

print_in_green() {
    printf "$(tput setaf 002)$1"
}

print_in_yellow() {
    printf "$(tput setaf 003)$1"
}

print_in_white() {
    printf "$(tput setaf 007)$1"
}

# Messages and questions
ask_question() {
    printf "\n"
    read -p "$(tput setaf 003)[?] $(tput sgr0)$@ Continue? (y/n) " -n 1;
    printf "\e[mR\n"
}

header_message() {
    print_in_white "[➜] $(tput sgr0)$1 \n"
}

warning_message() {
    print_in_yellow "[!] $(tput sgr0)$1 \n";
}

success_message() {
    print_in_green "[✔] $(tput sgr0)$1 \n";
}

error_message() {
    print_in_red "[✖] $(tput sgr0)$1 \n";
}

# Test whether the result of an 'ask' is a confirmation
is_confirmed() {

    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      return 0
    fi

    return 1
}

# Force create/replace the symlink.
link() {
    ln -fs "${1}/${2}" "${HOME}/${3}"
}

# Test whether a command exists
# $1 - cmd to test
command_exists() {
    type -P "$1" &>/dev/null
}

# Ask for the administrator password upfront.
ask_for_sudo() {

    sudo -v &> /dev/null

    # Update existing `sudo` time stamp
    # until this script has finished.
    #
    # https://gist.github.com/cowboy/3118588

    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &

}
