#!/usr/bin/env bash

# config {{{
# path to this repo
REPO_URL=https://github.com/v15hv4/init

# dotfiles config
DOTFILES_BRANCH=dotfiles
DOTFILES_DIR=$HOME/dotfiles

# git config
GIT_USERNAME=v15hv4
GIT_EMAIL=vishva2912@gmail.com

# packages to install
PACKAGES=(
  # system
  jq
  git
  feh
  zsh
  bat
  dex
  eza
  tmux
  htop
  curl
  make
  wget
  rsync
  kitty
  unzip
  picom
  upower
  polkit
  ripgrep
  lightdm
  ntfs-3g
  os-prober
  playerctl
  flameshot
  base-devel
  efibootmgr
  polkit-gnome

  # de/wm
  rofi
  bspwm
  dunst
  sxhkd
  arandr
  polybar
  autorandr
  xorg-xsetroot
  lxappearance-gtk3

  # audio
  alsa-lib                                                                                                 
  alsa-utils
  alsa-plugins                                                                                             
  alsa-ucm-conf                                                                                            
  alsa-firmware                                                                                            
  alsa-card-profiles                                                                                       
  alsa-topology-conf                                                                                       
  pamixer
  pavucontrol
  pipewire
  pipewire-alsa
  pipewire-audio
  pipewire-pulse
  wireplumber

  # bluetooth
  bluez
  bluez-libs
  bluez-utils
  blueman

  # editor
  neovim
  tree-sitter-cli

  # fonts
  noto-fonts
  ttf-opensans
  noto-fonts-cjk
  otf-apple-fonts
  noto-fonts-emoji
  noto-fonts-extra
  otf-geist-mono-nerd
  awesome-terminal-fonts
  ttf-material-design-icons-webfont

  # languages
  gcc
  nodejs
  python
  rustup

  # apps
  zathura
  google-chrome
  telegram-desktop-bin
)
# }}}

main() {
  # install yay
  echo "installing yay..."
  sudo pacman -Syu yay --noconfirm

  # update yay
  echo "updating yay..."
  yay -Syu --noconfirm

  # install packages
  echo "installing packages..."
  yay -S ${PACKAGES[@]} --noconfirm

  # zsh plugins
  echo "installing zsh plugins..."
  ## oh-my-zsh
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ## zsh-autosuggestions
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  ## powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  ## autoenv
  git clone --depth=1 https://github.com/zpm-zsh/autoenv ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autoenv

  # clone repo
  echo "cloning repo..."
  [ -e $DOTFILES_DIR ] && mv $DOTFILES_DIR $DOTFILES_DIR.old
  git clone $REPO_URL -b $DOTFILES_BRANCH $DOTFILES_DIR

  # link .configs
  for filename in $(ls -A $DOTFILES_DIR/.config); do
    [ -e ~/.config/$filename ] && mv ~/.config/$filename ~/.config/$filename.old
    ln -s $(realpath $DOTFILES_DIR/.config/$filename) ~/.config
  done

  # link dotfiles
  for filename in $(ls -A $DOTFILES_DIR | grep -v -E ".git|.config"); do
    [ -e ~/$filename ] && mv ~/$filename ~/$filename.old
    ln -s $(realpath $DOTFILES_DIR/$filename) ~
  done

  # misc stuff and things
  ln -s /tmp ~/tmp
  sudo mkdir /mnt/ext
  sudo systemctl enable bluetooth

  # nvidia
  yay -S optimus-manager --noconfirm
  sudo sed -i "s/^\(startup_mode=\).*/\1auto/g" /etc/optimus-manager/optimus-manager.conf # autodetect graphics on startup

  # setup git
  echo "setting up git..."
  git config --global user.name $GIT_USERNAME
  git config --global user.email $GIT_EMAIL

  # setup virtualization
  yay -Syu podman podman-compose podman-docker vagrant libvirt qemu-full --noconfirm
  sudo touch /etc/containers/nodocker
  echo 'unqualified-search-registries = ["docker.io"]' | sudo tee -a /etc/containers/registries.conf
  export VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1
  sudo systemctl enable libvirtd nfs-server
  vagrant plugin install vagrant-libvirt

  # clean up yay cache
  yay -R $(yay -Qtdq) --noconfirm
  yay -Scc --noconfirm

  echo "done!"
}

main
