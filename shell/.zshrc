
export ZSH="$HOME/.oh-my-zsh"
export PATH=/opt/homebrew/bin:$PATH

ZSH_THEME="imalov"

plugins=(git node)

source $ZSH/oh-my-zsh.sh
source $HOME/.bash_profile

eval "$(fnm env --use-on-cd --shell zsh)"

eval "$(pyenv init --path)" 