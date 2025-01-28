#!/usr/bin/env bash

# Constants
declare -r GITHUB_REPOSITORY="ivandata/dotfiles"
declare -r DOTFILES_DIRECTORY="${HOME}/.dotfiles"
declare -r DOTFILES_INSTALL_DIRECTORY="${DOTFILES_DIRECTORY}/.dotfiles"
declare -r DOTFILES_TARBALL_URL="https://github.com/$GITHUB_REPOSITORY/tarball/master"
declare -r DOTFILES_ORIGIN="git@github.com:$GITHUB_REPOSITORY.git"

# Determine the directory of the currently executing script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utils.sh from the same directory as install.sh
source "$SCRIPT_DIR/utils.sh"

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


# Function to execute init.sh
run_init_script() {
  header_message "Running init.sh..."
  if [ -f "${DOTFILES_DIRECTORY}/init.sh" ]; then
    bash "${DOTFILES_DIRECTORY}/init.sh" || handle_error "init.sh encountered an error."
    success_message "init.sh executed successfully."
  else
    warning_message "init.sh not found. Skipping initialization."
  fi
}

# Function to remove temporary directory
remove_install_directory() {
  header_message "Removing temporary installation directory..."
  rm -rf "${DOTFILES_INSTALL_DIRECTORY}" || warning_message "Failed to remove installation directory."
  success_message "Temporary directory removed."
}

link_ghostty_config() {
  header_message "Linking .ghostty configuration..."

  # Define source and destination paths
  local source="${DOTFILES_DIRECTORY}/.ghostty"
  local destination="${HOME}/.config/ghostty/config"

  # Check if the source file exists
  if [ -f "$source" ]; then
    # Ensure destination directory exists
    mkdir -p "$(dirname "$destination")" || handle_error "Failed to create ghostty directory."

    # Create a symlink
    ln -sf "$source" "$destination" || handle_error "Failed to link .ghostty configuration."
    success_message "Linked .ghostty to $destination."
  else
    # If source file does not exist, create directory and empty file
    mkdir -p "$(dirname "$destination")" || handle_error "Failed to create ghostty directory."
    touch "$destination" || handle_error "Failed to create ghostty config file."
    warning_message "No .ghostty file found in $DOTFILES_DIRECTORY. Created an empty config file at $destination."
  fi
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
  run_init_script

  # Example of symlinks
  link "${DOTFILES_DIRECTORY}" ".gitconfig" ".gitconfig"
  link "${DOTFILES_DIRECTORY}" ".bash_profile" ".bash_profile"
  link "${DOTFILES_DIRECTORY}" ".zshrc" ".zshrc"

  link_ghostty_config

  remove_install_directory
  success_message "Dotfiles installation complete!"
}

# Run the script
main
