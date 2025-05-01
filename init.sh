#!/usr/bin/env bash
set -euo pipefail

# Load constants if they exist, otherwise use script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONSTANTS_SCRIPT="constants.sh"

if [ -f "${SCRIPT_DIR}/${CONSTANTS_SCRIPT}" ]; then
  source "${SCRIPT_DIR}/${CONSTANTS_SCRIPT}"
fi

# Access to utils.sh
UTILS_SCRIPT="utils.sh"
if [ -f "${SCRIPT_DIR}/${UTILS_SCRIPT}" ]; then
  source "${SCRIPT_DIR}/${UTILS_SCRIPT}"
else
  echo "Error: ${UTILS_SCRIPT} not found! Exiting."
  exit 1
fi

# Function to load Homebrew environment from known locations
load_brew_env() {
  local brew_path=""
  if command -v brew &>/dev/null; then
    brew_path="$(command -v brew)"
  elif [ -x "/opt/homebrew/bin/brew" ]; then
    brew_path="/opt/homebrew/bin/brew"
  elif [ -x "/usr/local/bin/brew" ]; then
    brew_path="/usr/local/bin/brew"
  fi

  if [ -n "$brew_path" ]; then
    echo "🌱 Loading Homebrew into this shell…"
    eval "$($brew_path shellenv)"
    hash -r
  else
    echo "⚠️ Homebrew not found; skipping environment load"
  fi
}

# Helper to install a tool if missing
ensure_installed() {
  local name="$1" install_cmd="$2"
  header_message "Checking for ${name}…"
  if ! command_exists "${name}"; then
    warning_message "${name} not found; installing…"
    eval "${install_cmd}" || handle_error "Failed to install ${name}"
    success_message "${name} installed"
  else
    success_message "${name} is already installed"
  fi
}

install_xcode_cli_tools() {
  header_message "Xcode CLI tools…"
  if ! xcode-select -p &>/dev/null; then
    warning_message "Installing Xcode CLI…"
    xcode-select --install
    until xcode-select -p &>/dev/null; do sleep 5; done
    success_message "Xcode CLI installed"
  else
    success_message "Xcode CLI already present"
  fi
}

install_homebrew() {
  header_message "Homebrew…"
  if ! command -v brew &>/dev/null; then
    warning_message "Installing Homebrew…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success_message "Homebrew installed"
  else
    success_message "Homebrew already installed"
  fi
  load_brew_env
}

install_git() {
  ensure_installed "git" "brew install git"
}

install_oh_my_zsh() {
  header_message "Oh My Zsh…"
  if [ -d "${HOME}/.oh-my-zsh" ]; then
    success_message "Oh My Zsh already installed"
  else
    warning_message "Installing Oh My Zsh…"
    git clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh" \
      || handle_error "git clone failed"
    cp -n "${HOME}/.oh-my-zsh/templates/zshrc.zsh-template" "${HOME}/.zshrc" \
      || warning_message "~/.zshrc exists; skipping template"
    success_message "Oh My Zsh installed"
  fi
}

install_ghostty() {
  header_message "Ghostty…"
  load_brew_env
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
  header_message "Applying macOS system preferences…"
  MACOS_SCRIPT="macos.sh"
  if [ -f "${SCRIPT_DIR}/${MACOS_SCRIPT}" ]; then
    # Source the script to ensure it has access to utility functions
    source "${SCRIPT_DIR}/${MACOS_SCRIPT}"
    success_message "macOS settings applied"
  else
    warning_message "${MACOS_SCRIPT} not found. Skipping macOS settings."
  fi
}

install_fonts() {
  header_message "Installing fonts..."
  brew install font-fira-code font-ibm-plex-mono
}

install_pyenv() {
  ensure_installed "pyenv" "brew install pyenv"
}

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
