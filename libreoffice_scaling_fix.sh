#!/bin/bash
    echo "Applying LibreOffice DPI scaling fix..."
    for file in /usr/share/applications/libreoffice-*.desktop; do
        if [ -f "$file" ]; then
            echo "Patching $file"
	   sudo sed -i 's|^Exec=\(.*\)|Exec=env SAL_FORCEDPI=144 XCURSOR_SIZE=24 \1|' /usr/share/applications/libreoffice-*.desktop
        fi
    done
    sudo update-desktop-database /usr/share/applications
    echo "LibreOffice scaling fix applied."
