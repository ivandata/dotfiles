#!/usr/bin/env bash

source ./utils.sh;

# Before relying on Homebrew, check that packages can be compiled
header_message "Checking Xcode CLI tools...";
if ! command_exists 'gcc'; then
    ask_question "Xcode CLI tools not found. Installing them? (required)";
	if is_confirmed; then
		xcode-select --install &> /dev/null;
		while ! xcode-select -p &> /dev/null; do
		    sleep 5;
		done
		success_message "Xcode Command Line Tools installed";
	else
		error_message "The XCode Command Line Tools must be installed first.";
		warning_message "  Download them from: https://developer.apple.com/downloads\n";
        warning_message "  Then run: bash ~/.dotfiles/bin/dotfiles\n";
		exit 1;
    fi
else
  success_message "Xcode CLI tools already installed.";
fi

# Check for Homebrew
header_message "Checking Homebrew...";
if ! command_exists 'brew'; then
    header_message "Installing Homebrew...";
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
else
    success_message "Homebrew already installed.";
fi

# Check for git
header_message "Checking git...";
if ! command_exists 'git'; then
    header_message "Updating Homebrew...";
    brew update;
    header_message "Installing Git...";
    brew install git;
else
    success_message "git already installed.";
fi

# Check for oh-my-zsh
header_message "Checking oh-my-zsh...";
if [ ! -n "$ZSH" ]; then
    header_message "Installing oh-my-zsh..."
    export ZSH="${DOTFILES_DIRECTORY}/oh-my-zsh"; sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)";
else
    success_message "oh-my-zsh already installed.";
fi
