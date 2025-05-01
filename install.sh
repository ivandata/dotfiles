#!/usr/bin/env bash
set -euo pipefail

## ─── BOOTSTRAP constants.sh & utils.sh ────────────────────────────────────────────
# Ensure utils.sh is available so helper functions exist
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# First, download constants.sh if not exist
if [ ! -f "${SCRIPT_DIR}/constants.sh" ]; then
  echo "[➜] Downloading constants.sh..."
  curl -fsSL "https://raw.githubusercontent.com/ivandata/dotfiles/master/constants.sh" \
    -o "${SCRIPT_DIR}/constants.sh" \
    || { echo "Failed to fetch constants.sh"; exit 1; }
fi
source "${SCRIPT_DIR}/constants.sh"

# Then, download utils.sh if not exist
if [ ! -f "${SCRIPT_DIR}/${UTILS_SCRIPT}" ]; then
  echo "[➜] Downloading helper functions..."
  curl -fsSL "${UTILS_REMOTE_URL}" \
    -o "${SCRIPT_DIR}/${UTILS_SCRIPT}" \
    || { echo "Failed to fetch ${UTILS_SCRIPT}"; exit 1; }
fi
source "${SCRIPT_DIR}/${UTILS_SCRIPT}"
## ─── end BOOTSTRAP ────────────────────────────────────────────────────────────────

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

# Dry-run / update options
dry_run=false
update=false
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
  curl -fsSL "${DOTFILES_TARBALL_URL}" -o "${DOTFILES_INSTALL_DIRECTORY}/dotfiles.tar.gz" \
    || handle_error "Failed to download dotfiles."

  header_message "Extracting dotfiles..."
  tar -zxf "${DOTFILES_INSTALL_DIRECTORY}/dotfiles.tar.gz" --strip-components 1 \
    -C "${DOTFILES_INSTALL_DIRECTORY}" \
    || handle_error "Failed to extract dotfiles."

  # Copy constants file to the install directory
  if [ -f "${SCRIPT_DIR}/constants.sh" ]; then
    cp "${SCRIPT_DIR}/constants.sh" "${DOTFILES_INSTALL_DIRECTORY}/${CONSTANTS_SCRIPT}"
    chmod +x "${DOTFILES_INSTALL_DIRECTORY}/${CONSTANTS_SCRIPT}"
  fi

  success_message "Dotfiles downloaded and extracted."
}

# Function to copy dotfiles (including init.sh)
copy_dotfiles() {
  header_message "Copying dotfiles & init.sh..."
  # 1) copy shell & themes
  rsync --exclude ".git/" \
        --exclude ".DS_Store" \
        --exclude "README.md" \
        --exclude ".gitignore" \
        --exclude ".idea/" \
        --exclude "install.sh" \
        -a "${DOTFILES_INSTALL_DIRECTORY}/shell/"  "${DOTFILES_DIRECTORY}" \
        -a "${DOTFILES_INSTALL_DIRECTORY}/themes/" "${DOTFILES_DIRECTORY}" \
    || handle_error "Failed to rsync shell/themes."

  # 2) explicitly copy essential scripts
  for script in "${INIT_SCRIPT}" "${UTILS_SCRIPT}" "${MACOS_SCRIPT}" "${CONSTANTS_SCRIPT}"; do
    if [ -f "${DOTFILES_INSTALL_DIRECTORY}/${script}" ]; then
      cp "${DOTFILES_INSTALL_DIRECTORY}/${script}" "${DOTFILES_DIRECTORY}/${script}"
      chmod +x "${DOTFILES_DIRECTORY}/${script}"
      success_message "Copied ${script} to ${DOTFILES_DIRECTORY}."
    else
      warning_message "${script} not found in downloaded files. Skipping."
    fi
  done

  success_message "Dotfiles (incl. scripts) copied to ${DOTFILES_DIRECTORY}."
}

# Function to execute init.sh
run_init_script() {
  header_message "Running init.sh..."
  if [ -f "${DOTFILES_DIRECTORY}/${INIT_SCRIPT}" ]; then
    # Pass the directories as environment variables
    DOTFILES_DIRECTORY="${DOTFILES_DIRECTORY}" \
    DOTFILES_INSTALL_DIRECTORY="${DOTFILES_INSTALL_DIRECTORY}" \
    bash "${DOTFILES_DIRECTORY}/${INIT_SCRIPT}" || handle_error "init.sh encountered an error."
    success_message "init.sh executed successfully."
  else
    warning_message "${INIT_SCRIPT} not found. Skipping initialization."
  fi
}

# Link .ghostty config
link_ghostty_config() {
  header_message "Linking .ghostty configuration..."
  local source="${DOTFILES_DIRECTORY}/.ghostty"
  local destination="${HOME}/.config/ghostty/config"

  if [ -f "$source" ]; then
    mkdir -p "$(dirname "$destination")" \
      || handle_error "Failed to create ghostty directory."
    ln -sf "$source" "$destination" \
      || handle_error "Failed to link .ghostty configuration."
    success_message "Linked .ghostty to $destination."
  else
    mkdir -p "$(dirname "$destination")" \
      || handle_error "Failed to create ghostty directory."
    touch "$destination" \
      || handle_error "Failed to create ghostty config file."
    warning_message "No .ghostty file in ${DOTFILES_DIRECTORY}. Created empty config at $destination."
  fi
}

# Remove temporary dotfiles install directory
remove_install_directory() {
  header_message "Removing temporary installation directory..."
  rm -rf "${DOTFILES_INSTALL_DIRECTORY}" \
    || warning_message "Failed to remove installation directory."
  success_message "Temporary directory removed."
}

# Main installation logic
main() {
  if [[ $dry_run == true ]]; then
    warning_message "Dry run enabled. No changes will be made."
    return
  fi

  # Ensure dotfiles dir exists
  if [[ ! -d ${DOTFILES_DIRECTORY} ]]; then
    mkdir -p "${DOTFILES_DIRECTORY}" \
      || handle_error "Failed to create dotfiles directory."
  fi

  download_dotfiles
  copy_dotfiles

  # Create standard symlinks
  link "${DOTFILES_DIRECTORY}" ".gitconfig"    ".gitconfig"
  link "${DOTFILES_DIRECTORY}" ".bash_profile" ".bash_profile"
  link "${DOTFILES_DIRECTORY}" ".zshrc"        ".zshrc"

  run_init_script
  link_ghostty_config
  remove_install_directory

  success_message "Dotfiles installation complete!"
}

# Execute
main
