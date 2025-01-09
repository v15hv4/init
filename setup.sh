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
  ripgrep
  ntfs-3g
  os-prober
  flameshot
  base-devel
  efibootmgr

  # de/wm
  bspwm
  sxhkd
  autorandr

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
  pyenv
  pyenv-virtualenv

  # apps
  google-chrome
  zathura
  zathura-pdf-poppler
  ansible
  magic-wormhole

  # virtualization
  libvirt
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

setup_snapshots() {
  sed "s:\(grub-btrfsd --syslog\) /.snapshots:\1 -t:g" /etc/systemd/system/grub-btrfsd.service
}

setup_wm() {
  systemctl --user mask plasma-kwin_x11.service
  systemctl --user enable plasma-bspwm.service
}

cleanup() {
  yay -R $(yay -Qtdq) --noconfirm
  yay -Scc --noconfirm
}
# }}}

main() {
  install_yay
  install_packages

  setup_user
  setup_filesystem
  setup_systemctl

  [ -e $DOTFILES_DIR ] && rm -rf $DOTFILES_DIR.old && mv $DOTFILES_DIR $DOTFILES_DIR.old
  git clone $REPO_URL -b $DOTFILES_BRANCH $DOTFILES_DIR
  setup_dotfiles $DOTFILES_DIR

  [ -e $INIT_PROFILE_DIR ] && rm -rf $INIT_PROFILE_DIR.old && mv $INIT_PROFILE_DIR $INIT_PROFILE_DIR.old
  git clone $REPO_URL -b $INIT_PROFILE_BRANCH $INIT_PROFILE_DIR
  setup_dotfiles $INIT_PROFILE_DIR/dotfiles

  setup_wm

  cleanup
}

main
