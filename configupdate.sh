#!/bin/bash
set -e

DOTFILES_REPO="$HOME/Hyprland-Dots-Debian"
BACKUP_DIR="$HOME/hypr_config_backup_$(date +%Y%m%d_%H%M%S)"

if [ ! -d "$DOTFILES_REPO" ]; then
  echo ">>> Clonen van dotfiles van GitHub..."
  git clone https://github.com/JB03102008/Hyprland-Dots-Debian.git "$DOTFILES_REPO"
else
  echo ">>> Repo bestaat al, git pull uitvoeren..."
  git -C "$DOTFILES_REPO" pull
fi

mkdir -p "$BACKUP_DIR"

echo ">>> Backup van huidige config naar $BACKUP_DIR ..."
for dir in hypr hyprlock waybar wofi wlogout kitty; do
  if [ -d "$HOME/.config/$dir" ]; then
    cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
  fi
done

echo ">>> Nieuwe configs kopiëren van $DOTFILES_REPO naar ~/.config ..."
for dir in hypr hyprlock waybar wofi wlogout kitty; do
  if [ -d "$DOTFILES_REPO/$dir" ]; then
    cp -r "$DOTFILES_REPO/$dir/." "$HOME/.config/$dir/"
  fi
done

echo ">>> Configs zijn geüpdatet en oude configs zijn gebackupt."
