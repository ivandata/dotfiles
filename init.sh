#!/usr/bin/env bash

source ./utils.sh;

# Before relying on Homebrew, check that packages can be compiled
header_message "Checking Xcode CLI tools...";
if ! command_exists gcc; then
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
if ! command_exists brew; then
  header_message "Installing Homebrew...";
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
else
  success_message "Homebrew already installed.";
fi

# Check for git
header_message "Checking git...";
if ! command_exists git; then
  header_message "Updating Homebrew...";
  brew update;
  header_message "Installing Git...";
  brew install git;
else
  success_message "git already installed.";
fi

# Check for oh-my-zsh
header_message "Checking oh-my-zsh...";
if ! command_exists omz; then
  header_message "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  success_message "oh-my-zsh already installed.";
fi

# Check for ghostty
header_message "Checking ghostty...";
if ! command_exists ghostty; then
  brew install --cask ghostty
  success_message "ghostty installed!"
else
  success_message "ghostty already installed.";
fi

# Check for convco
header_message "Checking convco...";
if ! command_exists convco; then
  brew install convco
  success_message "convco installed!"
else
  success_message "convco already installed.";
fi

# Check for fnm
header_message "Checking fnm...";
if ! command_exists fnm; then
  curl -fsSL https://fnm.vercel.app/install | bash
  success_message "fnm installed!"
else
  success_message "fnm already installed.";
fi

