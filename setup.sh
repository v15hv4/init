#!/usr/bin/env bash

# this repo
REPO_URL=https://github.com/v15hv4/init

# init profile config
INIT_PROFILE_BRANCH=ubu-work
INIT_PROFILE_DIR=$HOME/.init-profile

# dotfiles config
DOTFILES_BRANCH=dotfiles
DOTFILES_DIR=$HOME/.dotfiles

# packages {{{
PACKAGES=(
  # system
  vim
  feh
  zsh
  curl
  bat
  eza
  tmux
  htop
  make
  kitty
  ripgrep
  ca-certificates

  # de/wm
  bspwm

  # editor
  neovim
  tree-sitter-cli

  # languages
  gcc
  npm
  nodejs
  rustup
  python3
  python-is-python3

  # apps
  ansible
  zathura
  zathura-pdf-poppler
  magic-wormhole
)
# }}}

# helpers {{{
install_packages() {
  echo "installing packages..."
  sudo apt update
  sudo apt install ${PACKAGES[@]} -y
}

install_zsh_plugins() {
  echo "installing zsh plugins..."
  # oh-my-zsh
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  # zsh-autosuggestions
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  # powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  # autoenv
  git clone --depth=1 https://github.com/zpm-zsh/autoenv ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autoenv
}

setup_dotfiles() {
  # link .configs
  if [ -e $1/.config ]; then
    for filename in $(ls -A $1/.config); do
      [ -e ~/.config/$filename ] && mv ~/.config/$filename ~/.config/$filename.old
      ln -s $(realpath $1/.config/$filename) ~/.config
    done
  fi

  # link dotfiles
  for filename in $(ls -A $1 | grep -v -E "^(.git|.config)$"); do
    [ -e ~/$filename ] && mv ~/$filename ~/$filename.old
    ln -s $(realpath $1/$filename) ~
  done
}

setup_filesystem() {
  ln -s /tmp ~/tmp
  sudo mkdir /mnt/ext
}

setup_docker() {
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker $(whoami)
}

cleanup() {
  sudo apt clean
}
# }}}

main() {
  install_packages
  install_zsh_plugins

  setup_filesystem
  setup_systemctl
  setup_docker

  [ -e $DOTFILES_DIR ] && rm -rf $DOTFILES_DIR.old && mv $DOTFILES_DIR $DOTFILES_DIR.old
  git clone $REPO_URL --single-branch -b $DOTFILES_BRANCH $DOTFILES_DIR
  setup_dotfiles $DOTFILES_DIR

  [ -e $INIT_PROFILE_DIR ] && rm -rf $INIT_PROFILE_DIR.old && mv $INIT_PROFILE_DIR $INIT_PROFILE_DIR.old
  git clone $REPO_URL -b $INIT_PROFILE_BRANCH $INIT_PROFILE_DIR
  setup_dotfiles $INIT_PROFILE_DIR/dotfiles

  cleanup
}

main
