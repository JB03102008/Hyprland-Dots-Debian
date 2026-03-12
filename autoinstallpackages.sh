#!/bin/bash

# Function to install a package
install_package() {
    echo "Installing $1..."
    sudo apt update -y
    sudo apt install -y $1
}

# Function to fix LibreOffice scaling
fix_libreoffice_scaling() {
    echo "Applying LibreOffice DPI scaling fix..."
    for file in /usr/share/applications/libreoffice-*.desktop; do
        if [ -f "$file" ]; then
            echo "Patching $file"
            sudo sed -i 's|Exec=libreoffice|Exec=env SAL_FORCEDPI=192 libreoffice|g' "$file"
        fi
    done
    sudo update-desktop-database /usr/share/applications
    echo "LibreOffice scaling fix applied."
}

# Function to install LibreOffice
install_libreoffice() {
    echo "Installing LibreOffice..."
    sudo apt update -y
    sudo apt install -y libreoffice
    fix_libreoffice_scaling
}

# Function to install Firefox (non-ESR)
install_firefox_non_esr() {
    echo "Installing Firefox (non-ESR)..."
    sudo apt update -y
    sudo apt install -y wget curl
    wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"
    sudo tar xjf firefox.tar.bz2 -C /opt
    sudo ln -sf /opt/firefox/firefox /usr/bin/firefox
    rm firefox.tar.bz2
    echo "Firefox (non-ESR) is installed."
}

# Function to install Spotify
install_spotify() {
    echo "Installing Spotify..."
    sudo apt update -y
    sudo apt install -y curl
    curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update -y
    sudo apt install -y spotify-client
    echo "Spotify is installed."
}

# Function to display the main menu
show_menu() {
    echo ""
    echo "Select the package you want to install:"
    echo "1) Htop"
    echo "2) Nvtop"
    echo "3) LibreOffice"
    echo "4) Firefox (non-ESR)"
    echo "5) Spotify"
    echo "6) Exit"
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice (1-6): " choice

    case "$choice" in
        1)
            install_package "htop"
            ;;
        2)
            install_package "nvtop"
            ;;
        3)
            install_libreoffice
            ;;
        4)
            install_firefox_non_esr
            ;;
        5)
            install_spotify
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac

    echo ""
    echo "Done installing selected package."
done
