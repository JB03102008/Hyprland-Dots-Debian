#!/bin/bash
set -e

# ─────────────────────────────────────────────
#  Hyprland Setup Script - Debian Testing
# ─────────────────────────────────────────────

echo "⚠️  WARNING! WARNING! WARNING! This script will enable Debian testing APT repositories and install the Hyprland compositor alongside with some tools."
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation aborted by user."
    exit 1
fi

# ─────────────────────────────────────────────
#  Remove old repositories
# ─────────────────────────────────────────────
sudo sed -i '/deb .*stable/d' /etc/apt/sources.list
sudo sed -i '/deb .*testing/d' /etc/apt/sources.list

# ─────────────────────────────────────────────
#  Add Debian testing repo
# ─────────────────────────────────────────────
echo ">>> Adding Debian testing repositories..."
sudo tee /etc/apt/sources.list.d/testing.list > /dev/null <<EOF
deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security testing-security main contrib non-free-firmware
deb http://deb.debian.org/debian testing-updates main contrib non-free-firmware
EOF

# ─────────────────────────────────────────────
#  Set testing to default using pinning
# ─────────────────────────────────────────────
sudo tee /etc/apt/preferences.d/testing.pref > /dev/null <<EOF
Package: *
Pin: release a=testing
Pin-Priority: 900
EOF

echo ">>> Running apt update..."
sudo apt update

echo ">>> Installing needed packages..."
sudo apt install -t testing -y \
  sddm \
  hyprland \
  hyprpaper \
  hyprlock \
  waybar \
  wofi \
  wlogout \
  dunst \
  kitty \
  nautilus \
  firefox-esr \
  pipewire \
  pipewire-pulse \
  wireplumber \
  pavucontrol \
  wl-clipboard \
  playerctl \
  polkit-kde-agent-1 \
  git \
  curl \
  wget \
  cliphist \
  zsh \
  thunar \
  hypridle \
  hyprland-guiutils \
  grim

echo ">>> Creating config folders..."
mkdir -p ~/.config/hypr/conf.d
mkdir -p ~/.config/hyprlock
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wofi
mkdir -p ~/.config/wlogout
mkdir -p ~/.config/kitty

echo ">>> Cloning dotfiles frm JB03102008's Hyprland-Dots-Debian repository..."
TMPDIR=$(mktemp -d)
git clone https://github.com/JB03102008/Hyprland-Dots-Debian.git "$TMPDIR/dots"

echo ">>> Copying files to ~/.config/..."
cp -r "$TMPDIR/dots/hypr/."        ~/.config/hypr/
cp -r "$TMPDIR/dots/hyprlock/."    ~/.config/hyprlock/
cp -r "$TMPDIR/dots/waybar/."      ~/.config/waybar/
cp -r "$TMPDIR/dots/wofi/."        ~/.config/wofi/
cp -r "$TMPDIR/dots/wlogout/."     ~/.config/wlogout/

if [ -d "$TMPDIR/dots/kitty" ] && [ "$(ls -A "$TMPDIR/dots/kitty")" ]; then
  cp -r "$TMPDIR/dots/kitty/." ~/.config/kitty/
fi

echo ">>> Installing fonts..."
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip \
&& cd ~/.local/share/fonts \
&& unzip JetBrainsMono.zip \
&& rm JetBrainsMono.zip \
&& fc-cache -fv

echo ">>> Deleting temporary files..."
rm -rf "$TMPDIR"

echo ">>> Making some scripts executable..."
chmod +x ~/.config/hyprlock/songdetail.sh

echo ">>> Enabling PipeWire..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber

echo ">>> Creating Hyprland session file for SDDM..."
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=start-hyprland
Type=Application
EOF

echo ">>> Enabling SDDM..."
sudo systemctl enable sddm
sudo systemctl set-default graphical.target

sudo apt remove nautilus

echo ">>> Installing Oh-My-ZSH..."
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh
sed -i.tmp 's:env zsh::g' install.sh
sed -i.tmp 's:chsh -s .*$::g' install.sh
sh install.sh

read -p "Do you want to run a script to install some popular apps (y/n): " choice

if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo "Downloading and running the installation script..."
    
    curl -sL https://https://github.com/JB03102008/Hyprland-Dots-Debian/raw/main/autoinstallpackages.sh | bash
else
    echo "Exiting without running the installation script."
fi

echo ""
echo "✅ Done! SDDM wil start automatically at reboot."
echo "   Please reboot your system now by typing:"
echo "   sudo systemctl reboot"
