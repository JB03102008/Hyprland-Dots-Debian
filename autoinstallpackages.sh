#!/bin/bash

# Function to install a package
install_package() {
    echo "Installing $1..."
    sudo apt update && sudo apt install -y $1
}

# Function to install Firefox (non-ESR) via an alternative method
install_firefox_non_esr() {
    echo "Installing Firefox (non-ESR)..."
    sudo apt update
    sudo apt install -y wget
    wget -qO- https://dl.mozilla.org/firefox/releases/latest/linux-x86_64/en-US/firefox-$(curl -s https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt | grep -oP '(\d+\.\d+\.\d+)')-en-US.tar.bz2 | sudo tar xjf - -C /opt
    sudo ln -sf /opt/firefox/firefox /usr/bin/firefox
    echo "Firefox (non-ESR) is installed."
}

# Function to install Spotify from the official repository
install_spotify() {
    echo "Installing Spotify..."
    sudo apt update
    sudo apt install -y curl
    curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt install -y spotify-client
    echo "Spotify is installed."
}

# Function to display the main menu
show_menu() {
    echo "Select the packages you want to install (you can select multiple by entering numbers separated by spaces):"
    echo "1) Htop"
    echo "2) Nvtop"
    echo "3) LibreOffice"
    echo "4) Firefox (non-ESR)"
    echo "5) Spotify"
    echo "6) Exit"
}

# Main part of the script
while true; do
    show_menu
    read -p "Enter your choice(s) (1-6): " choices

    # Loop through each selected choice
    for choice in $choices; do
        case $choice in
            1)
                install_package "htop"
                ;;
            2)
                install_package "nvtop"
                ;;
            3)
                install_package "libreoffice"
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
    done
done
