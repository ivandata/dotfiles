#!/usr/bin/env bash

# Print in colors
print_in_red() {
    printf "$(tput setaf 001) $1 \n"
}

print_in_green() {
    printf "$(tput setaf 002) $1 \n"
}

print_in_yellow() {
    printf "$(tput setaf 003) $1 \n"
}

print_in_white() {
    printf "$(tput setaf 004) $1 \n"
}

# Messages and questions
ask_question() {
    printf "\n"
    print_in_yellow "[?] $@"
    read -p "Continue? (y/n) " -n 1;
    printf "\e[mR\n"
}

header_message() {
    print_in_white "$1\n"
}

warning_message() {
    print_in_yellow "[!] $1\n"
}

success_message() {
    print_in_green "[✔] $1\n"
}

error_message() {
    print_in_red "[✖] $1 $2\n"
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
    if [ $(type -P $1) ]; then
      return 0
    fi
    return 1
}