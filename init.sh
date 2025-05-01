#!/usr/bin/env bash
set -euo pipefail

# Determine script directory\ nSCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Load utilities
source "${SCRIPT_DIR}/utils.sh"

# Immediately load Homebrew env if installed
if command -v brew &>/dev/null; then
  echo "🌱 Loading Homebrew into this shell…"
  eval "$( $(brew --prefix)/bin/brew shellenv )"
  hash -r
fi

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

install_pyenv() {
  ensure_installed "pyenv" "brew install pyenv"
}

install_oh_my_zsh() {
  header_message "Oh My Zsh…"
  if [ -d "${HOME}/.oh-my-zsh" ]; then
    success_message "Oh My Zsh already installed"
  else
    warning_message "Oh My Zsh not found. Installing (manual clone)…"
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" \
      || handle_error "Failed to clone Oh My Zsh."
    cp -n "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc" \
      || warning_message "~/.zshrc exists; skipping template copy."
    success_message "Oh My Zsh installed (no shell exec)."
  fi
}

# Ensure Ghostty is installed
install_ghostty() {
  # re-load brew env in case something overwritten it
  if command -v brew &>/dev/null; then
    eval "$($(brew --prefix)/bin/brew shellenv)"
    hash -r
  fi

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

# Apply macOS-specific settings
apply_macos_settings() {
  header_message "Applying macOS system preferences..."
  if [ -f ./macos.sh ]; then
    bash ./macos.sh || handle_error "Failed to apply macOS system preferences."
  else
    warning_message "macos.sh not found. Skipping macOS settings."
  fi
}

install_fonts() {
  header_message "Installing fonts..."
  brew install font-fira-code font-ibm-plex-mono
}

# Main setup steps
main() {
  install_xcode_cli_tools
  install_homebrew
  install_git
  install_oh_my_zsh
  install_ghostty
  install_convco
  install_fnm
  install_pyenv
  apply_macos_settings
  install_fonts
}

main
