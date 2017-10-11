#!/usr/bin/env bash

DOTFILES_DIRECTORY="${HOME}/.dotfiles";
DOTFILES_INSTALL_DIRECTORY="${HOME}/.dotfiles/temp";
DOTFILES_TARBALL_PATH="https://github.com/ivandata/dotfiles/tarball/master";
DOTFILES_GIT_REMOTE="git@github.com:ivandata/dotfiles.git"

cat <<EOT
OS X dotfiles - Ivan Malov - https://github.com/ivandata
Documentation can be found at https://github.com/ivandata/dotfiles
Copyright (c) Ivan Malov
Licensed under the MIT license.
EOT

echo "";
read -p "$(tput bold)$(tput setaf 003)[?] $(tput sgr0)$(tput bold)This installation may overwrite existing files in your home directory. $(tput bold)$(tput setaf 003)Are you sure? (y/n) " -n 1;
printf "\e[mR\n";
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    START_TIME=$SECONDS
    echo "";
else
    printf "Aborting...\n";
    exit 1;
fi

# Test for known flags
for opt in $@
do
    case ${opt} in
        --up) update=true ;;
        -*|--*) printf "$(tput setaf 003) Warning: invalid option $opt" ;;
    esac
done

install_dotfiles() {
    printf "$(tput setaf 007) Downloading dotfiles...\033[m\n";
    mkdir ${DOTFILES_INSTALL_DIRECTORY};
    # Get the tarball
    curl -fsSLo ${DOTFILES_INSTALL_DIRECTORY}/dotfiles.tar.gz ${DOTFILES_TARBALL_PATH};

    printf "$(tput setaf 007) Extract dotfiles...\033[m\n";
    tar -zxf ${DOTFILES_INSTALL_DIRECTORY}/dotfiles.tar.gz --strip-components 1 -C ${DOTFILES_INSTALL_DIRECTORY};

    printf "$(tput setaf 007) Copy dotfiles into .dotfiles directory...\033[m\n";
    rsync --exclude ".git/" \
          --exclude ".DS_Store" \
          --exclude "README.md" \
          --exclude ".gitignore" \
          --exclude ".idea/" \
          --exclude "install.sh" \
          -a "${DOTFILES_INSTALL_DIRECTORY}/" "${DOTFILES_DIRECTORY}";

    printf "$(tput setaf 007) Remove temp folder...\033[m\n";
    rm -rf ${DOTFILES_INSTALL_DIRECTORY};
    printf "$(tput setaf 002) [✔] Download complete. \n";
}

# If missing, make dir, download and extract the dotfiles repository
if [[ ! -d ${DOTFILES_DIRECTORY} ]]; then
    mkdir ${DOTFILES_DIRECTORY};
    install_dotfiles
elif [[ ${update} ]]; then
    install_dotfiles
fi

rsync --exclude ".git/" \
      --exclude ".DS_Store" \
      --exclude "README.md" \
      --exclude ".gitignore" \
      --exclude ".idea/" \
      --exclude "install.sh" \
      -a "${HOME}/repo/dotfiles/" "${DOTFILES_DIRECTORY}";

cd ${DOTFILES_DIRECTORY};

source ./utils.sh;

# Before relying on Homebrew, check that packages can be compiled
header_message "Checking Xcode CLI tools...";
if ! command_exists 'gcc'; then
    ask_question "Xcode CLI tools not found. Installing them? (required)";
	if is_confirmed; then
		xcode-select --install &> /dev/null;
		while ! xcode-select -p &> /dev/null; do
		    sleep 5;
		done
		success_message "Xcode Command Line Tools installed";
	else
		error_message "The XCode Command Line Tools must be installed first.";
		warning_message "  Download them from: https://developer.apple.com/downloads\n";
        warning_message "  Then run: bash ~/.dotfiles/bin/dotfiles\n";
		exit 1;
    fi
else
  success_message "Xcode CLI tools already installed.";
fi

# Check for Homebrew
header_message "Checking Homebrew...";
if ! command_exists 'brew'; then
    header_message "Installing Homebrew...";
    ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)";
else
    success_message "Homebrew already installed.";
fi

# Check for git
header_message "Checking git...";
if ! command_exists 'git'; then
    header_message "Updating Homebrew...";
    brew update;
    header_message "Installing Git...";
    brew install git;
else
    success_message "git already installed.";
fi

# Check for oh-my-zsh
header_message "Checking oh-my-zsh...";
if [ ! -n "$ZSH" ]; then
    header_message "Installing oh-my-zsh..."
    export ZSH="${DOTFILES_DIRECTORY}/oh-my-zsh"; sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)";
else
    success_message "oh-my-zsh already installed.";
fi

# Ask before potentially overwriting files
ask_question "Warning: This step may overwrite your existing dotfiles."
if is_confirmed; then
    link ${DOTFILES_DIRECTORY} ".gitconfig" ".gitconfig";
    link ${DOTFILES_DIRECTORY} ".bash_profile" ".bash_profile";
    link ${DOTFILES_DIRECTORY} ".zshrc"  ".zshrc";
    success_message "Dotfiles update complete!";
    source ${HOME}/.bash_profile
else
    printf "Aborting...\n"
    exit 1
fi

# Ask before potentially overwriting OS X defaults
ask_question "Warning: This step may modify your OS X system defaults.";
if is_confirmed; then
    sh ./macos.sh
    success_message "OS X settings updated! You may need to restart.";
else
    printf "Skipped OS X settings update.\n"
fi

ELAPSED_TIME=$((${SECONDS} - ${START_TIME}))
ELAPSED_MIN=$((${ELAPSED_TIME}/60))
ELAPSED_SEC=$((${ELAPSED_TIME}%60))

echo "\n✨  All done in ${ELAPSED_MIN} min ${ELAPSED_SEC} sec.\n"