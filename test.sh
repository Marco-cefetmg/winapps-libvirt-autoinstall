#!/bin/bash
AUTOUNATTENDED_XML="./virtio-wwin.iso"


if [ ! -f "$AUTOUNATTENDED_XML" ]; then
    echo "File $AUTOUNATTENDED_XML not found. Searching..."
    AUTOUNATTENDED_XML=$(find . -maxdepth 1 -type f -iname "*windows*.iso" -o -iname "*win1*.iso" -exec readlink -f {} \;)
    if [ $? == 0 ] && [ $AUTOUNATTENDED_XML != null ]; then
        echo "File $AUTOUNATTENDED_XML found."
        exit 0
    else
    echo "File $AUTOUNATTENDED_XML not found. Downloading..."
    curl "https://raw.githubusercontent.com/ElliotKillick/Mido/refs/heads/main/Mido.sh" | bash -s -- win10x64-enterprise-ltsc-eval || {
        echo "Error downloading $AUTOUNATTENDED_XML."
        exit 1
    }
    AUTOUNATTENDED_XML=$(find . -maxdepth 1 -type f -iname "*windows*.iso" -o -iname "*win1*.iso" -exec readlink -f {} \;)
    fi
fi
curl "https://raw.githubusercontent.com/ElliotKillick/Mido/refs/heads/main/Mido.sh" | bash -s -- win10x64-ente
rprise-ltsc-eval