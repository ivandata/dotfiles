#!/usr/bin/env bash

# --------------------------------------------
# Global constants for dotfiles installation
# --------------------------------------------

# GitHub repository info
declare -r GITHUB_REPOSITORY="ivandata/dotfiles"
declare -r DOTFILES_TARBALL_URL="https://github.com/$GITHUB_REPOSITORY/tarball/master"
declare -r DOTFILES_ORIGIN="git@github.com:$GITHUB_REPOSITORY.git"

# Directory structure
declare -r DOTFILES_DIRECTORY="${HOME}/.dotfiles"
declare -r DOTFILES_INSTALL_DIRECTORY="${DOTFILES_DIRECTORY}/.dotfiles"

# Script names
declare -r UTILS_SCRIPT="utils.sh"
declare -r MACOS_SCRIPT="macos.sh"
declare -r INIT_SCRIPT="init.sh"
declare -r CONSTANTS_SCRIPT="constants.sh"

# Remote URLs
declare -r UTILS_REMOTE_URL="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/master/utils.sh"

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
