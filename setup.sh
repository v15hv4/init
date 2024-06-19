#!/usr/bin/env bash

# this repo
REPO_URL=https://github.com/v15hv4/init

# directory to clone this repo into
INIT_DIR=$HOME/init

# packages to install
PACKAGES=(
  # system
  jq
  git
  feh
  zsh
  bat
  eza
  tmux
  htop
  curl
  make
  wget
  rsync
  unzip
  upower
  polkit
  lightdm
  ripgrep
  os-prober
  playerctl
  flameshot
  efibootmgr
  polkit-gnome
  optimus-manager

  # de/wm
  rofi
  bspwm
  dunst
  sxhkd
  arandr
  polybar
  autorandr
  i3lock-color
  lxappearance-gtk3
  qt5-svg
  qt5-base
  qt5-x11extras
  qt5-declarative
  qt5-translations

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
  pipewire-jack
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
  # apple-fonts
  ttf-opensans
  noto-fonts-cjk
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

# update yay
echo "updating yay..."
yay -Syu --noconfirm

# install packages
echo "installing packages..."
yay -S ${PACKAGES[@]} --noconfirm

# zsh plugins
echo "installing zsh plugins..."
## oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
## zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
## powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
## autoenv
git clone --depth=1 https://github.com/zpm-zsh/autoenv ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autoenv

# clone repo
echo "cloning repo..."
git clone $REPO_URL $INIT_DIR

# link .configs
for filename in $(ls -A $INIT_DIR/.config); do
  [ -e ~/.config/$filename ] && mv ~/.config/$filename ~/.config/$filename.old
  ln -s $(realpath $filename) ~/.config
done

# link dotfiles
for filename in $(ls -A $INIT_DIR | grep -v -E ".git|.config|setup.sh"); do
  [ -e ~/$filename ] && mv ~/$filename ~/$filename.old
  ln -s $(realpath $filename) ~
done

# setup git
git config --global user.name "v15hv4"
git config --global user.email "vishva2912@gmail.com"
