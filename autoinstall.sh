#!/bin/bash
set -e

# ─────────────────────────────────────────────
#  Hyprland Setup Script - Debian Testing
# ─────────────────────────────────────────────

# ─────────────────────────────────────────────
#  Bevestiging voor start
# ─────────────────────────────────────────────
echo "⚠️  WAARSCHUWING: Dit script gaat Debian Testing repo's toevoegen en Hyprland installeren."
read -p "Weet je zeker dat je wilt doorgaan? (y/n) " -n 1 -r
echo    # Ga naar een nieuwe regel
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installatie geannuleerd door gebruiker."
    exit 1
fi

echo ">>> Debian Testing repo toevoegen..."
sudo tee /etc/apt/sources.list.d/testing.list > /dev/null <<EOF
deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware
EOF

# Zorg dat testing niet de standaard wordt
sudo tee /etc/apt/preferences.d/testing.pref > /dev/null <<EOF
Package: *
Pin: release a=testing
Pin-Priority: 100

Package: *
Pin: release a=stable
Pin-Priority: 500
EOF

echo ">>> Pakketlijsten updaten..."
sudo apt update

echo ">>> Pakketten installeren..."
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
  thunar

echo ">>> Config mappen aanmaken..."
mkdir -p ~/.config/hypr/conf.d
mkdir -p ~/.config/hyprlock
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wofi
mkdir -p ~/.config/wlogout
mkdir -p ~/.config/kitty

echo ">>> Dotfiles klonen van GitHub..."
TMPDIR=$(mktemp -d)
git clone https://github.com/JB03102008/Hyprland-Dots-Debian.git "$TMPDIR/dots"

echo ">>> Dotfiles kopiëren naar ~/.config/..."
cp -r "$TMPDIR/dots/hypr/."        ~/.config/hypr/
cp -r "$TMPDIR/dots/hyprlock/."    ~/.config/hyprlock/
cp -r "$TMPDIR/dots/waybar/."      ~/.config/waybar/
cp -r "$TMPDIR/dots/wofi/."        ~/.config/wofi/
cp -r "$TMPDIR/dots/wlogout/."     ~/.config/wlogout/

# Kopieer kitty config als die bestaat
if [ -d "$TMPDIR/dots/kitty" ] && [ "$(ls -A "$TMPDIR/dots/kitty")" ]; then
  cp -r "$TMPDIR/dots/kitty/." ~/.config/kitty/
fi

echo ">>> Tijdelijke bestanden opruimen..."
rm -rf "$TMPDIR"

echo ">>> songdetail.sh uitvoerbaar maken..."
chmod +x ~/.config/hyprlock/songdetail.sh

echo ">>> PipeWire inschakelen voor huidige gebruiker..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber

echo ">>> Hyprland sessiebestand aanmaken voor SDDM..."
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

echo ">>> SDDM inschakelen als display manager..."
sudo systemctl enable sddm
sudo systemctl set-default graphical.target

sudo apt remove nautilus

echo ""
echo "✅ Klaar! SDDM start automatisch op bij de volgende reboot."
echo "   Herstart je systeem met:"
echo "   sudo reboot"
