#!/usr/bin/env bash

# this repo
REPO_URL=https://github.com/v15hv4/init

# init profile config
INIT_PROFILE_BRANCH=cos-work
INIT_PROFILE_DIR=$HOME/.init-profile

# dotfiles config
DOTFILES_BRANCH=dotfiles
DOTFILES_DIR=$HOME/.dotfiles

# packages {{{
PACKAGES=(
  # system
  jq
  git
  vim
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
  ntfs-3g
  os-prober
  playerctl
  flameshot
  base-devel
  efibootmgr
  polkit-gnome
  brightnessctl
  inotify-tools

  # de/wm
  rofi
  bspwm
  dunst
  sxhkd
  arandr
  polybar
  autorandr
  i3lock-color
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
  google-chrome
  telegram-desktop-bin
  zathura
  zathura-pdf-poppler
  slack-desktop
  ansible
  tailscale
  magic-wormhole


  # virtualization
  podman
  podman-compose
  podman-docker
  vagrant libvirt
  qemu-full 

  # snapshots
  grub-btrfs
  timeshift
  timeshift-autosnap
)
# }}}

# helpers {{{
install_yay() {
  echo "installing yay..."
  sudo pacman -Syu yay --noconfirm

  echo "updating yay..."
  yay -Syu --noconfirm
}

install_packages() {
  echo "installing packages..."
  yay -S ${PACKAGES[@]} --noconfirm
}

uninstall_packages() {
  echo "uninstalling unnecessary packages..."
  yay -R alacritty kvantum cachy-browser cachyos-hello btop eog fish cachyos-gnome-settings fisher fish-autopair fish-pure-prompt cachyos-fish-config kvantum-theme-libadwaita-git --noconfirm
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

setup_user() {
  sudo usermod -aG video $(whoami)
}

setup_gtk() {
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
  gsettings set org.gnome.desktop.interface icon-theme 'Adwaita' 
  gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'
  gsettings set org.gnome.desktop.interface font-name 'SF Pro Text 10'
}

setup_filesystem() {
  ln -s /tmp ~/tmp
  sudo mkdir /mnt/ext
}

setup_systemctl() {
  sudo systemctl enable bluetooth
  sudo systemctl enable libvirtd 
  sudo systemctl enable nfs-server
  sudo systemctl enable grub-btrfsd
}

setup_podman() {
  sudo touch /etc/containers/nodocker
  echo 'unqualified-search-registries = ["docker.io"]' | sudo tee -a /etc/containers/registries.conf
}

setup_vagrant() {
  export VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1
  vagrant plugin install vagrant-libvirt
}

setup_snapshots() {
  sed "s:\(grub-btrfsd --syslog\) /.snapshots:\1 -t:g" /etc/systemd/system/grub-btrfsd.service
}

cleanup() {
  yay -R $(yay -Qtdq) --noconfirm
  yay -Scc --noconfirm
}
# }}}

main() {
  install_yay
  install_packages
  install_zsh_plugins

  setup_user
  setup_gtk
  setup_filesystem
  setup_systemctl
  setup_podman
  setup_vagrant

  [ -e $DOTFILES_DIR ] && rm -rf $DOTFILES_DIR.old && mv $DOTFILES_DIR $DOTFILES_DIR.old
  git clone $REPO_URL -b $DOTFILES_BRANCH $DOTFILES_DIR
  setup_dotfiles $DOTFILES_DIR

  [ -e $INIT_PROFILE_DIR ] && rm -rf $INIT_PROFILE_DIR.old && mv $INIT_PROFILE_DIR $INIT_PROFILE_DIR.old
  git clone $REPO_URL -b $INIT_PROFILE_BRANCH $INIT_PROFILE_DIR
  setup_dotfiles $INIT_PROFILE_DIR/dotfiles

  cleanup
  reboot
}

main
