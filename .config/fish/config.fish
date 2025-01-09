if status is-interactive
    # pyenv
    pyenv init - | source
    pyenv virtualenv-init - | source
end

# language encoding
set -gx LANG en_US.UTF-8
set -x LC_CTYPE en_US.UTF-8

# Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
  source ~/.fish_profile
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Add ruby gems to PATH
if test -d ~/.local/share/gem/ruby/3.3.0/bin
    if not contains -- ~/.local/share/gem/ruby/3.3.0/bin $PATH
        set -p PATH ~/.local/share/gem/ruby/3.3.0/bin
    end
end

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end

## Useful aliases
# Replace ls with eza
alias ls='eza --color=always --icons'                               # ls with icons
alias la='eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias l='eza -l --color=always --group-directories-first --icons'   # long format
alias l.="eza -a | grep -e '^\.'"                                   # show only dotfiles

# pain
abbr sl 'ls'
alias rg="rg --hidden --glob '!.git'"

# docker
abbr dps 'docker ps'
abbr dim 'docker images'
abbr dex 'docker exec -it'
abbr dspr 'docker system prune'

# Common use
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias grep='grep --color=auto'
alias fixpacman="sudo rm /var/lib/pacman/db.lck"

# Get fastest mirrors
alias mirror="sudo cachyos-rate-mirrors"

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'

## Custom stuff
# newline between commands
function postexec_test --on-event fish_postexec
   echo
end

# vagrant
alias v='vagrant_libvirt'

# abbreviations
abbr df 'duf'
abbr http 'curlie'
abbr dc 'docker-compose'
abbr rs 'rsync -avzWP'
abbr ap 'ansible-playbook'

# git
abbr gss 'git status'
abbr ga 'git add'
abbr gap 'git add -p'
abbr gc 'git commit'
abbr gb 'git branch'
abbr gl 'git pull'
abbr gp 'git push'
abbr gd 'git diff'
abbr gco 'git checkout'
abbr gcob 'git checkout -b'
abbr gcl 'git clone'
abbr glo 'git log --oneline --decorate'

# crustdata
alias crust="docker compose -f ~/scratch/docker/compose.yml --env-file ~/scratch/docker/.env.development"

# xssh
complete -c xssh --wraps ssh
