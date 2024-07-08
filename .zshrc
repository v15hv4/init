# enable Powerlevel10k instant prompt; should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# oh-my-zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions autoenv docker docker-compose systemd)
source $ZSH/oh-my-zsh.sh

# preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# aliases
source $HOME/.zsh_aliases

# load p10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# match wildcards
setopt nonomatch

# local binaries
export PATH=$PATH:$HOME/.local/bin

# xssh completions
compdef _ssh xssh=ssh
