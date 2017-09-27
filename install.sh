#!/usr/bin/env bash

DOTFILES_DIRECTORY="${HOME}/repo/dotfiles"

cd ${DOTFILES_DIRECTORY}

source ./utils.sh

link() {
    # Force create/replace the symlink.
    ln -fs "${DOTFILES_DIRECTORY}/${1}" "${HOME}/${2}"
}

mirrorfiles() {
    # Copy `.gitconfig`.
    # Any global git commands in `~/.bash_profile.local` will be written to
    # `.gitconfig`. This prevents them being committed to the repository.
    rsync -avz --quiet ${DOTFILES_DIRECTORY}/.gitconfig  ${HOME}/.gitconfig

    # Create the necessary symbolic links between the `.dotfiles` and `HOME`
    # directory. The `bash_profile` sources other files directly from the
    # `.dotfiles` repository.

    link ".bash_profile" ".bash_profile"
    link ".zshrc"  ".zshrc"
}


# Ask before potentially overwriting files
ask_question "Warning: This step may overwrite your existing dotfiles."

if is_confirmed; then
    mirrorfiles
    success_message "Dotfiles update complete!"
    source ${HOME}/.bash_profile
else
    printf "Aborting...\n"
    exit 1
fi

# Ask before potentially overwriting OS X defaults
ask_question "Warning: This step may modify your OS X system defaults."

if is_confirmed; then
    sh ./macos.sh
    success_message "OS X settings updated! You may need to restart."
else
    printf "Skipped OS X settings update.\n"
fi