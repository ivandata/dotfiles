#!/usr/bin/env bats

# Setup and teardown for temporary directory
setup() {
  # Create a temporary directory for testing
  export TEST_DIR=$(mktemp -d)
  export DOTFILES_DIRECTORY="$TEST_DIR/.dotfiles"
  export DOTFILES_INSTALL_DIRECTORY="$DOTFILES_DIRECTORY/temp"
}

teardown() {
  # Remove the temporary directory after the test
  rm -rf "$TEST_DIR"
}

# Load utilities and script
load ./utils.sh
source ./install.sh

# Test download_dotfiles
@test "download_dotfiles downloads and extracts dotfiles to the temporary directory" {
  run download_dotfiles
  [[ -d "$DOTFILES_INSTALL_DIRECTORY" ]]
  [[ -f "$DOTFILES_INSTALL_DIRECTORY/dotfiles.tar.gz" ]]
}

# Test copy_dotfiles
@test "copy_dotfiles copies dotfiles to the temporary dotfiles directory" {
  mkdir -p "$DOTFILES_INSTALL_DIRECTORY/shell"
  touch "$DOTFILES_INSTALL_DIRECTORY/shell/test-file"
  run copy_dotfiles
  [[ -f "$DOTFILES_DIRECTORY/shell/test-file" ]]
}

# Test remove_install_directory
@test "remove_install_directory removes the temporary installation directory" {
  mkdir -p "$DOTFILES_INSTALL_DIRECTORY"
  run remove_install_directory
  [[ ! -d "$DOTFILES_INSTALL_DIRECTORY" ]]
}

# Test dry-run mode
@test "main runs in dry-run mode without making changes to the temporary folder" {
  run ./install.sh --dry-run
  [[ "$output" =~ "Dry run enabled. No changes will be made." ]]
}

# Test symlink creation in temporary directory
@test "link creates a symlink in the temporary folder" {
  mkdir -p "$TEST_DIR/source"
  touch "$TEST_DIR/source/test-file"
  run link "$TEST_DIR/source" "test-file" "test-link"
  [[ -L "$HOME/test-link" ]]
  [[ "$(readlink "$HOME/test-link")" == "$TEST_DIR/source/test-file" ]]
  rm "$HOME/test-link"
}

@test "install_browsers installs browsers if missing" {
  # Mock brew to simulate missing browsers
  function brew() {
    if [[ "$1" == "list" && "$2" == "--cask" ]]; then
      return 1
    fi
    command brew "$@"
}

  run install_browsers
  [[ "$output" =~ "google-chrome installed" ]]
  [[ "$output" =~ "firefox installed" ]]
  [[ "$output" =~ "opera installed" ]]
}
