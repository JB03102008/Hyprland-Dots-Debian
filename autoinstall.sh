#!/bin/bash
set -e

# ─────────────────────────────────────────────
#  Hyprland Setup Script - Debian Testing
# ─────────────────────────────────────────────

echo "⚠️  WARNING! This script will enable Debian testing repositories and install Hyprland."
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 1
fi

# ─────────────────────────────────────────────
#  Hardware Detection
# ─────────────────────────────────────────────
IS_LAPTOP=false
if [ -d /sys/class/power_supply/BAT* ] || [ -d /sys/class/power_supply/battery ]; then
    IS_LAPTOP=true
    echo "🔍 System detected as: LAPTOP"
else
    echo "🔍 System detected as: DESKTOP"
fi

read -p "Do you want to install laptop-specific tools (brightnessctl, battery-scripts)? (y/n) [Detected: $( [ "$IS_LAPTOP" = true ] && echo "y" || echo "n" )]: " CHASSIS_CHOICE
CHASSIS_CHOICE=${CHASSIS_CHOICE:-$( [ "$IS_LAPTOP" = true ] && echo "y" || echo "n" )}

EXTRA_PACKAGES=""
if [[ "$CHASSIS_CHOICE" =~ ^[Yy]$ ]]; then
    echo ">>> Adding laptop tools to install list..."
    EXTRA_PACKAGES="brightnessctl bluez bluez-utils"
else
    echo ">>> Skipping laptop-only packages."
fi

# ─────────────────────────────────────────────
#  Repository Management
# ─────────────────────────────────────────────
echo ">>> Cleaning up old repositories..."
sudo sed -i '/deb .*stable/d' /etc/apt/sources.list
sudo sed -i '/deb .*testing/d' /etc/apt/sources.list

echo ">>> Adding Debian testing repositories..."
sudo tee /etc/apt/sources.list.d/testing.list > /dev/null <<EOF
deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security testing-security main contrib non-free-firmware
deb http://deb.debian.org/debian testing-updates main contrib non-free-firmware
EOF

echo ">>> Setting APT pinning for testing..."
sudo tee /etc/apt/preferences.d/testing.pref > /dev/null <<EOF
Package: *
Pin: release a=testing
Pin-Priority: 900
EOF

echo ">>> Running apt update..."
sudo apt update

# ─────────────────────────────────────────────
#  Package Installation
# ─────────────────────────────────────────────
echo ">>> Installing core packages and NetworkManager..."
sudo apt install -t testing -y \
  sddm hyprland hyprpaper hyprlock waybar wofi wlogout \
  dunst kitty nautilus firefox-esr pipewire pipewire-pulse libspa-0.2-bluetooth \
  wireplumber pavucontrol wl-clipboard playerctl polkit-kde-agent-1 \
  git curl wget cliphist zsh thunar hypridle hyprland-guiutils grim \
  networkmanager \
  $EXTRA_PACKAGES

# ─────────────────────────────────────────────
#  Network Migration (ifupdown to NetworkManager)
# ─────────────────────────────────────────────
echo ">>> Migrating network management to NetworkManager..."

# Backup old interfaces file and reset it to loopback only to avoid conflicts
if [ -f /etc/network/interfaces ]; then
    echo ">>> Backing up /etc/network/interfaces to /etc/network/interfaces.bak"
    sudo cp /etc/network/interfaces /etc/network/interfaces.bak
    sudo tee /etc/network/interfaces > /dev/null <<EOF
# Standard loopback interface (Managed by ifupdown)
auto lo
iface lo inet loopback

# Other interfaces are now managed by NetworkManager
EOF
fi

# Disable old networking service and enable NetworkManager
sudo systemctl stop networking || true
sudo systemctl disable networking || true
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# ─────────────────────────────────────────────
#  Configuration & Dotfiles
# ─────────────────────────────────────────────
echo ">>> Creating config folders..."
mkdir -p ~/.config/hypr/conf.d ~/.config/hyprlock ~/.config/waybar ~/.config/wofi ~/.config/wlogout ~/.config/kitty

echo ">>> Cloning dotfiles from repository..."
TMPDIR=$(mktemp -d)
git clone https://github.com/JB03102008/Hyprland-Dots-Debian.git "$TMPDIR/dots"

echo ">>> Copying configuration files..."
cp -r "$TMPDIR/dots/hypr/."     ~/.config/hypr/
cp -r "$TMPDIR/dots/hyprlock/." ~/.config/hyprlock/
cp -r "$TMPDIR/dots/waybar/."   ~/.config/waybar/
cp -r "$TMPDIR/dots/wofi/."     ~/.config/wofi/
cp -r "$TMPDIR/dots/wlogout/."  ~/.config/wlogout/

if [ -d "$TMPDIR/dots/kitty" ] && [ "$(ls -A "$TMPDIR/dots/kitty")" ]; then
  cp -r "$TMPDIR/dots/kitty/." ~/.config/kitty/
fi

# ─────────────────────────────────────────────
#  Fonts & Services
# ─────────────────────────────────────────────
echo ">>> Installing JetBrainsMono Nerd Font..."
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip \
&& cd ~/.local/share/fonts && unzip JetBrainsMono.zip && rm JetBrainsMono.zip && fc-cache -fv

rm -rf "$TMPDIR"

echo ">>> Setting script permissions..."
[ -f ~/.config/hyprlock/songdetail.sh ] && chmod +x ~/.config/hyprlock/songdetail.sh

echo ">>> Enabling user services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber
sudo systemctl enable sddm
sudo systemctl set-default graphical.target

# ─────────────────────────────────────────────
#  ZSH & Additional Apps
# ─────────────────────────────────────────────
echo ">>> Installing Oh-My-ZSH..."
wget -O install_zsh.sh https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh
sed -i 's:env zsh::g' install_zsh.sh
sed -i 's:chsh -s .*$::g' install_zsh.sh
sh install_zsh.sh --unattended && rm install_zsh.sh

read -p "Do you want to run the automated package installation script for popular apps? (y/n): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo ">>> Running external installation script..."
    curl -sL https://github.com/JB03102008/Hyprland-Dots-Debian/raw/main/autoinstallpackages.sh | bash
fi

echo ""
echo "✅ Done! NetworkManager is now managing your connection."
echo "   Please reboot your system now by typing: sudo systemctl reboot"
