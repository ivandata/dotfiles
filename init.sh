#!/usr/bin/env bash
set -euo pipefail

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Load utilities
source "${SCRIPT_DIR}/utils.sh"

# Immediately load Homebrew env if installed
# (will run only if brew already exists from a previous run)
if command -v brew &>/dev/null; then
  echo "🌱 Loading Homebrew into this shell…"
  eval "$(brew --prefix)/bin/brew shellenv"
  hash -r
fi

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
  echo "🌱 Loading Homebrew into this shell…"
  eval "$( $(brew --prefix)/bin/brew shellenv )"
  hash -r
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
  # Reload Homebrew env in case overwritten
  if command -v brew &>/dev/null; then
    eval "$( $(brew --prefix)/bin/brew shellenv )"
    hash -r
  fi

  ensure_installed "ghostty" "brew install --cask ghostty"
}

main() {
  install_xcode_cli_tools
  install_homebrew
  install_git
  install_oh_my_zsh
  install_ghostty
  # ... any other installers ...
}

main
