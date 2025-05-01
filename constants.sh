#!/usr/bin/env bash

# --------------------------------------------
# Global constants for dotfiles installation
# --------------------------------------------

# GitHub repository info
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-ivandata/dotfiles}"
DOTFILES_TARBALL_URL="${DOTFILES_TARBALL_URL:-https://github.com/$GITHUB_REPOSITORY/tarball/master}"
DOTFILES_ORIGIN="${DOTFILES_ORIGIN:-git@github.com:$GITHUB_REPOSITORY.git}"

# Directory structure
# Using standard variables instead of readonly to avoid issues when sourced in different contexts
DOTFILES_DIRECTORY="${DOTFILES_DIRECTORY:-${HOME}/.dotfiles}"
DOTFILES_INSTALL_DIRECTORY="${DOTFILES_INSTALL_DIRECTORY:-${DOTFILES_DIRECTORY}/.dotfiles}"

# Script names
UTILS_SCRIPT="${UTILS_SCRIPT:-utils.sh}"
MACOS_SCRIPT="${MACOS_SCRIPT:-macos.sh}"
INIT_SCRIPT="${INIT_SCRIPT:-init.sh}"
CONSTANTS_SCRIPT="${CONSTANTS_SCRIPT:-constants.sh}"

# Remote URLs
UTILS_REMOTE_URL="${UTILS_REMOTE_URL:-https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/master/utils.sh}"

# Export for subshells
export GITHUB_REPOSITORY
export DOTFILES_TARBALL_URL
export DOTFILES_ORIGIN
export DOTFILES_DIRECTORY
export DOTFILES_INSTALL_DIRECTORY
export UTILS_SCRIPT
export MACOS_SCRIPT
export INIT_SCRIPT
export CONSTANTS_SCRIPT
export UTILS_REMOTE_URL
