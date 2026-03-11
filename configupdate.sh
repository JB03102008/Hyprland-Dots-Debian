#!/bin/bash
set -e

DOTFILES_REPO="$HOME/Hyprland-Dots-Debian"
BACKUP_DIR="$HOME/hypr_config_backup_$(date +%Y%m%d_%H%M%S)"
MONITOR_CONFIG="$HOME/.config/hypr/conf.d/monitors.conf"

if [ ! -d "$DOTFILES_REPO" ]; then
  echo ">>> Cloning dotfiles from JB03102008's Hyprland-Dots-Debian repository..."
  git clone https://github.com/JB03102008/Hyprland-Dots-Debian.git "$DOTFILES_REPO"
else
  echo ">>> Repository already exists, executing git pull..."
  git -C "$DOTFILES_REPO" pull
fi

mkdir -p "$BACKUP_DIR"

echo ">>> Copying the current config to $BACKUP_DIR ..."
# Make a backup of the monitors config seperately
if [ -f "$MONITOR_CONFIG" ]; then
  cp "$MONITOR_CONFIG" "$BACKUP_DIR/monitors.conf"
fi

# Backup other configurations
for dir in hypr hyprlock waybar wofi wlogout kitty; do
  if [ -d "$HOME/.config/$dir" ]; then
    cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
  fi
done

echo ">>> Copying new config from $DOTFILES_REPO to ~/.config ..."
for dir in hypr hyprlock waybar wofi wlogout kitty; do
  if [ -d "$DOTFILES_REPO/$dir" ]; then
    cp -r "$DOTFILES_REPO/$dir/." "$HOME/.config/$dir/"
  fi
done

# Replace old monitor configuration
if [ -f "$BACKUP_DIR/monitors.conf" ]; then
  echo ">>> Monitorconfig terugzetten..."
  cp "$BACKUP_DIR/monitors.conf" "$MONITOR_CONFIG"
fi

echo ">>> Config files are updated and old config is backed up in: $BACKUP_DIR."
echo "   Please keep the old config files in case the new ones have any bug in them."
echo "   Please reboot your system by typing:"
echo "   sudo systemctl reboot"
