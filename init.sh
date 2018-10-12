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
    export ZSH="${DOTFILES_DIRECTORY}/oh-my-zsh";
    git clone https://github.com/robbyrussell/oh-my-zsh.git ${ZSH}
    link ${DOTFILES_DIRECTORY} ".zshrc"  ".zshrc";
    chsh -s /bin/zsh
else
    success_message "oh-my-zsh already installed.";
fi

# Check for oh-my-zsh
header_message "Checking nvm...";
if ! command_exists 'nvm'; then
 git clone https://github.com/creationix/nvm.git "$NVM_DIR";
 cd "$NVM_DIR";
 git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
 \. "$NVM_DIR/nvm.sh"
else
    success_message "nvm already installed.";
fi
