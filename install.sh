#!/usr/bin/env bash

declare -r GITHUB_REPOSITORY="ivandata/dotfiles"

declare -r DOTFILES_DIRECTORY="${HOME}/.dotfiles";
declare -r DOTFILES_INSTALL_DIRECTORY="${HOME}/.dotfiles/temp";
declare -r DOTFILES_TARBALL_PURL="https://github.com/$GITHUB_REPOSITORY/tarball/master";
declare -r DOTFILES_ORIGIN="git@github.com:$GITHUB_REPOSITORY.git"

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

download_dotfiles() {
    printf "$(tput setaf 007) Downloading dotfiles...\033[m\n";
    mkdir ${DOTFILES_INSTALL_DIRECTORY};
    curl -fsSLo ${DOTFILES_INSTALL_DIRECTORY}/dotfiles.tar.gz ${DOTFILES_TARBALL_PURL};

    printf "$(tput setaf 007) Extract dotfiles...\033[m\n";
    tar -zxf ${DOTFILES_INSTALL_DIRECTORY}/dotfiles.tar.gz --strip-components 1 -C ${DOTFILES_INSTALL_DIRECTORY};

    printf "$(tput setaf 002) [✔] Download complete. \n";
}

copy_dotfiles() {
    printf "$(tput setaf 007) Copy dotfiles into .dotfiles directory...\033[m\n";
    rsync --exclude ".git/" \
          --exclude ".DS_Store" \
          --exclude "README.md" \
          --exclude ".gitignore" \
          --exclude ".idea/" \
          --exclude "init.sh" \
          --exclude "install.sh" \
          --exclude "utils.sh" \
          -a "${DOTFILES_INSTALL_DIRECTORY}/shell/" "${DOTFILES_DIRECTORY}";
}

remove_install_directory() {
    printf "$(tput setaf 007) Remove dotfiles install directory...\033[m\n";
    rm -rf ${DOTFILES_INSTALL_DIRECTORY};
    printf "$(tput setaf 002) [✔] dotfiles install directory removed. \033[m\n";
}

# If missing, make dir, download and extract the dotfiles repository
if [[ ! -d ${DOTFILES_DIRECTORY} ]]; then
    mkdir ${DOTFILES_DIRECTORY};
    download_dotfiles
elif [[ ${update} ]]; then
    download_dotfiles
else
    printf "$(tput setaf 003) dotfiles already installed. If you need update dotfiles, please run installation with --up flag.";
    printf "\e[mR\n";
    remove_install_directory
    exit 1;
fi

cd ${DOTFILES_INSTALL_DIRECTORY};

source ./utils.sh;

# Ask before potentially overwriting files
ask_question "Warning: This step may overwrite your existing dotfiles."
if is_confirmed; then
    copy_dotfiles
    link ${DOTFILES_DIRECTORY} ".gitconfig" ".gitconfig";
    link ${DOTFILES_DIRECTORY} ".bash_profile" ".bash_profile";
    link ${DOTFILES_DIRECTORY} ".aliases"  ".aliases";
    success_message "Dotfiles update complete!";
    source ${HOME}/.bash_profile
else
    printf "Aborting...\n"
    exit 1
fi

source ./init.sh;

# Ask before potentially overwriting OS X defaults
ask_question "Warning: This step may modify your OS X system defaults.";
if is_confirmed; then
    sh ./macos.sh
    success_message "OS X settings updated! You may need to restart.";
else
    printf "Skipped OS X settings update.\n"
fi

remove_install_directory

ELAPSED_TIME=$((${SECONDS} - ${START_TIME}))
ELAPSED_MIN=$((${ELAPSED_TIME}/60))
ELAPSED_SEC=$((${ELAPSED_TIME}%60))

echo "\n✨  All done in ${ELAPSED_MIN} min ${ELAPSED_SEC} sec.\n"
