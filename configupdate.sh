#!/bin/bash
set -e

DOTFILES_REPO="$HOME/Hyprland-Dots-Debian"
BACKUP_DIR="$HOME/hypr_config_backup_$(date +%Y%m%d_%H%M%S)"
MONITOR_CONFIG="$HOME/.config/hypr/conf.d/monitors.conf"

if [ ! -d "$DOTFILES_REPO" ]; then
  echo ">>> Clonen van dotfiles van GitHub..."
  git clone https://github.com/JB03102008/Hyprland-Dots-Debian.git "$DOTFILES_REPO"
else
  echo ">>> Repo bestaat al, git pull uitvoeren..."
  git -C "$DOTFILES_REPO" pull
fi

mkdir -p "$BACKUP_DIR"

echo ">>> Backup van huidige config naar $BACKUP_DIR ..."
# Maak een backup van de monitorconfiguratie
if [ -f "$MONITOR_CONFIG" ]; then
  cp "$MONITOR_CONFIG" "$BACKUP_DIR/monitors.conf"
fi

# Backup van andere configuraties
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

# Zet de monitorconfig terug vanuit de backup
if [ -f "$BACKUP_DIR/monitors.conf" ]; then
  echo ">>> Monitorconfig terugzetten..."
  cp "$BACKUP_DIR/monitors.conf" "$MONITOR_CONFIG"
fi

echo ">>> Configs zijn geüpdatet en oude configs zijn gebackupt."
