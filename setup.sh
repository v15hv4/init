#!/usr/bin/env bash

# this repo
REPO_URL=https://github.com/v15hv4/init

# init profile config
INIT_PROFILE_BRANCH=fedora-work
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

  # audio
  alsa-firmware
  pamixer
  pavucontrol
  pipewire
  pipewire-alsa
  wireplumber

  # bluetooth
  bluez
  bluez-libs
  blueman
  
  # editor
  neovim
  tree-sitter-cli

  # languages
  gcc
  nodejs
  python
  rustup

  # apps
  ansible
  tailscale
  timeshift
  zathura
  zathura-pdf-poppler

  # virtualization
  podman
  podman-compose
  podman-docker
  vagrant-libvirt
)
# }}}

# helpers {{{
install_packages() {
  echo "installing packages..."

  dnf install -y ${PACKAGES[@]}
}

install_localpackages() {
  echo "installing local packages..."

  mkdir -p /tmp/localpackages

  # google chrome
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/localpackages/chrome.rpm
  # i3lock-color
  wget https://download.copr.fedorainfracloud.org/results/rubemlrm/i3lock-color/fedora-40-x86_64/07280720-i3lock-color/i3lock-color-2.13.c.5-1.fc40.x86_64.rpm -O /tmp/localpackages/i3lock-color.rpm
  # telegram-desktop
  wget https://download1.rpmfusion.org/free/fedora/updates/40/x86_64/t/telegram-desktop-5.2.3-1.fc40.x86_64.rpm -O /tmp/localpackages/telegram-desktop.rpm
  # slack-desktop
  wget https://ftp.nluug.nl/pub/os/Linux/distr/pclinuxos/pclinuxos/apt/pclinuxos/64bit/RPMS.x86_64/slack-desktop-4.36.140-1pclos2024.x86_64.rpm -O /tmp/localpackages/slack-desktop.rpm
  # capitaine-cursors
  wget https://rpmfind.net/linux/fedora/linux/releases/39/Everything/aarch64/os/Packages/l/la-capitaine-cursor-theme-4-5.20210303git06c8843.fc39.noarch.rpm -O /tmp/localpackages/capitaine-cursors.rpm

  dnf localinstall -y /tmp/localpackages/*
}

install_fonts() {
  echo "installing fonts..."

  sudo cp -r $INIT_PROFILE_DIR/fonts/* /usr/share/fonts
  sudo dnf install -y google-noto-* --allowerasing --skip-broken
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
  # sudo systemctl enable grub-btrfsd
}

setup_podman() {
  sudo touch /etc/containers/nodocker
  echo 'unqualified-search-registries = ["docker.io"]' | sudo tee -a /etc/containers/registries.conf
}

setup_vagrant() {
  export VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1
  vagrant plugin install vagrant-libvirt
}

# setup_snapshots() {
#   sed "s:\(grub-btrfsd --syslog\) /.snapshots:\1 -t:g" /etc/systemd/system/grub-btrfsd.service
# }

cleanup() {
  dnf clean all
}
# }}}

main() {
  install_packages
  install_localpackages
  install_zsh_plugins
  install_fonts

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
}

main
