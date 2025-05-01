#!/usr/bin/env bash

# Load constants and utilities if not already loaded
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONSTANTS_SCRIPT="constants.sh"
UTILS_SCRIPT="utils.sh"

# Load constants if they exist
if [ -f "${SCRIPT_DIR}/${CONSTANTS_SCRIPT}" ]; then
  source "${SCRIPT_DIR}/${CONSTANTS_SCRIPT}"
fi

# Load utilities if they exist and aren't already loaded
if [ -f "${SCRIPT_DIR}/${UTILS_SCRIPT}" ] && ! type header_message &>/dev/null; then
  source "${SCRIPT_DIR}/${UTILS_SCRIPT}"
fi

header_message "Applying macOS system preferences..."

# General UI/UX
defaults write NSGlobalDomain AppleShowScrollBars -string "Always" # Always show scrollbars
defaults write com.apple.menuextra.battery ShowPercent -string "YES" # Show battery percentage

# Finder
defaults write com.apple.finder ShowPathbar -bool true # Show path bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true # Show status bar in Finder
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # Use list view in Finder by default

# Dock
defaults write com.apple.dock autohide -bool false # Auto-hide Dock
defaults write com.apple.dock tilesize -int 50 # Set Dock tile size

# Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots" # Save screenshots to ~/Pictures/Screenshots
mkdir -p "${HOME}/Pictures/Screenshots"

# Restart services to apply changes
killall Finder
killall Dock
killall SystemUIServer

success_message "macOS system preferences applied!"
