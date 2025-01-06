#!/usr/bin/env bash

# Print in colors
print_in_red() {
    printf "\033[31m%s\033[0m" "$1"
}

print_in_green() {
    printf "\033[32m%s\033[0m" "$1"
}

print_in_yellow() {
    printf "\033[33m%s\033[0m" "$1"
}

print_in_white() {
    printf "\033[37m%s\033[0m" "$1"
}

# Messages and questions
ask_question() {
    printf "\\n"
    read -r -p "$(printf "\033[33m[?]\033[0m %s Continue? (y/n) " "$@")" -n 1 REPLY
    printf "\\n"
}

header_message() {
    printf "\033[37m[➜] %s\033[0m\\n" "$1"
}

warning_message() {
    printf "\033[33m[!] %s\033[0m\\n" "$1"
}

success_message() {
    printf "\033[32m[✔] %s\033[0m\\n" "$1"
}

error_message() {
    printf "\033[31m[✖] %s\033[0m\\n" "$1"
}

# Test whether the result of an 'ask' is a confirmation
is_confirmed() {
    [[ "$REPLY" =~ ^[Yy]$ ]]
}

# Force create/replace the symlink
link() {
    ln -fs "$1/$2" "$HOME/$3"
    if [ $? -eq 0 ]; then
        success_message "Symlink created for $2"
    else
        error_message "Failed to create symlink for $2"
        exit 1
    fi
}

# Test whether a command exists
# $1 - cmd to test
command_exists() {
    command -v "$1" &>/dev/null
}

# Ensure a command exists or exit
require_command() {
    if ! command_exists "$1"; then
        error_message "Required command '$1' not found. Please install it and retry."
        exit 1
    fi
}

# Ask for the administrator password upfront
ask_for_sudo() {
    sudo -v &>/dev/null

    # Update existing `sudo` timestamp until this script finishes
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &>/dev/null &
}
