#!/usr/bin/env bash

# Constants
declare -r GITHUB_REPOSITORY="ivandata/dotfiles"
declare -r DOTFILES_DIRECTORY="${HOME}/.dotfiles"
declare -r DOTFILES_INSTALL_DIRECTORY="${DOTFILES_DIRECTORY}/.dotfiles"
declare -r DOTFILES_TARBALL_URL="https://github.com/$GITHUB_REPOSITORY/tarball/master"
declare -r DOTFILES_ORIGIN="git@github.com:$GITHUB_REPOSITORY.git"

# Include utilities
source ./utils.sh

# Print header
cat <<EOT
OS X dotfiles - Ivan Malov - https://github.com/ivandata
Documentation: https://github.com/ivandata/dotfiles
Licensed under the MIT license.
EOT

# Confirm before proceeding
ask_question "This installation may overwrite existing files in your home directory. Are you sure?"
if ! is_confirmed; then
  error_message "Installation aborted."
  exit 1
fi

# Dry-run option
dry_run=false
for opt in "$@"; do
  case ${opt} in
    --dry-run) dry_run=true ;;
    --up) update=true ;;
    -*|--*) warning_message "Warning: invalid option $opt" ;;
  esac
done

# Function to download dotfiles
download_dotfiles() {
  header_message "Downloading dotfiles..."
  mkdir -p "${DOTFILES_INSTALL_DIRECTORY}"
  curl -fsSL "${DOTFILES_TARBALL_URL}" -o "${DOTFILES_INSTALL_DIRECTORY}/dotfiles.tar.gz" || handle_error "Failed to download dotfiles."

  header_message "Extracting dotfiles..."
  tar -zxf "${DOTFILES_INSTALL_DIRECTORY}/dotfiles.tar.gz" --strip-components 1 -C "${DOTFILES_INSTALL_DIRECTORY}" || handle_error "Failed to extract dotfiles."

  success_message "Dotfiles downloaded and extracted."
}

# Function to copy dotfiles
copy_dotfiles() {
  header_message "Copying dotfiles..."
  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude "README.md" \
    --exclude ".gitignore" \
    --exclude ".idea/" \
    --exclude "init.sh" \
    --exclude "install.sh" \
    --exclude "utils.sh" \
    -a "${DOTFILES_INSTALL_DIRECTORY}/shell/" "${DOTFILES_DIRECTORY}" \
    -a "${DOTFILES_INSTALL_DIRECTORY}/themes/" "${DOTFILES_DIRECTORY}" || handle_error "Failed to copy dotfiles."
  success_message "Dotfiles copied to ${DOTFILES_DIRECTORY}."
}

# Function to remove temporary directory
remove_install_directory() {
  header_message "Removing temporary installation directory..."
  rm -rf "${DOTFILES_INSTALL_DIRECTORY}" || warning_message "Failed to remove installation directory."
  success_message "Temporary directory removed."
}

# Main installation logic
main() {
  if [[ $dry_run == true ]]; then
    warning_message "Dry run enabled. No changes will be made."
    return
  fi

  if [[ ! -d ${DOTFILES_DIRECTORY} ]]; then
    mkdir -p "${DOTFILES_DIRECTORY}" || handle_error "Failed to create dotfiles directory."
  fi

  download_dotfiles
  copy_dotfiles

  # Example of symlinks
  link "${DOTFILES_DIRECTORY}" ".gitconfig" ".gitconfig"
  link "${DOTFILES_DIRECTORY}" ".bash_profile" ".bash_profile"
  link "${DOTFILES_DIRECTORY}" ".zshrc" ".zshrc"

  remove_install_directory
  success_message "Dotfiles installation complete!"
}

# Run the script
main
