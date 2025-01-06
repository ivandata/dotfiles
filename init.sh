#!/usr/bin/env bash

# Load utilities
source ./utils.sh

# Reusable function to ensure a command is installed
ensure_installed() {
  local name="$1"
  local install_cmd="$2"

  header_message "Checking $name..."
  if ! command_exists "$name"; then
    warning_message "$name not found. Installing..."
    eval "$install_cmd" || handle_error "Failed to install $name."
    success_message "$name installed!"
  else
    success_message "$name is already installed."
  fi
}

# Ensure Xcode CLI tools are installed
install_xcode_cli_tools() {
  header_message "Checking Xcode CLI tools..."
  if ! command_exists gcc; then
    ask_question "Xcode CLI tools not found. Install them? (required)"
    if is_confirmed; then
      xcode-select --install &> /dev/null
      while ! xcode-select -p &> /dev/null; do
        sleep 5
      done
      success_message "Xcode Command Line Tools installed."
    else
      handle_error "Xcode CLI tools must be installed first."
    fi
  else
    success_message "Xcode CLI tools are already installed."
  fi
}

# Ensure Homebrew is installed
install_homebrew() {
  ensure_installed "brew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
}

# Ensure Git is installed
install_git() {
  ensure_installed "git" "brew install git"
}

# Ensure oh-my-zsh is installed
install_oh_my_zsh() {
  header_message "Checking omz..."
  if [ -d "$HOME/.oh-my-zsh" ]; then
    success_message "omz is already installed."
  else
    warning_message "omz not found. Installing..."
    if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
      handle_error "Failed to install omz."
    fi
    success_message "omz installed!"
  fi
}

# Ensure Ghostty is installed
install_ghostty() {
  ensure_installed "ghostty" "brew install --cask ghostty"
}

# Ensure Convco is installed
install_convco() {
  ensure_installed "convco" "brew install convco"
}

# Ensure Fast Node Manager (fnm) is installed
install_fnm() {
  ensure_installed "fnm" "curl -fsSL https://fnm.vercel.app/install | bash"
}

# Ensure browsers are installed
install_browsers() {
  header_message "Checking browsers..."
  local browsers=("google-chrome" "firefox" "opera")
  for browser in "${browsers[@]}"; do
    if brew list --cask "$browser" &>/dev/null; then
      success_message "$browser is already installed."
    else
      warning_message "$browser not found. Installing..."
      brew install --cask "$browser" || handle_error "Failed to install $browser."
      success_message "$browser installed."
    fi
  done
}

# Main setup steps
main() {
  install_xcode_cli_tools
  install_homebrew
  install_git
  install_oh_my_zsh
  install_browsers
  install_ghostty
  install_convco
  install_fnm
}

main
