#!/bin/bash
#
# Install prerequisite packages for SonoBus build on Arch Linux / Manjaro / CachyOS
# Optimized for Wayland (skips X11 libs)

PKG_LIST=()

# --- libfreetype ---
if pacman -Q freetype2 &>/dev/null; then
    echo "libfreetype already installed, skipping"
else
    FREETYPES=""
    if command -v paru &>/dev/null; then
        FREETYPES=$(paru -Ss libfreetype 2>/dev/null | grep -v '^\s*$' | head -1 | grep -oP '(?<=/)\S+')
    fi
    if [[ -z "$FREETYPES" ]]; then
        FREETYPES=$(pacman -Ss libfreetype 2>/dev/null | head -1 | grep -oP '(?<=/)\S+')
    fi
    if [[ -z "$FREETYPES" ]]; then
        echo "Couldn't find libfreetype dev package"
        exit 1
    fi
    PKG_LIST+=("$FREETYPES")
fi

# --- libcurl (ssl or gnutls) ---
if pacman -Q libcurl 2>/dev/null; then
    echo "libcurl already installed, skipping"
else
    CURLPKG=""
    if command -v paru &>/dev/null; then
        CURLPKG=$(paru -Ss libcurl 2>/dev/null | grep -E 'ssl|gnutls' | grep -v '^\s*$' | head -1 | grep -oP '(?<=/)\S+')
    fi
    if [[ -z "$CURLPKG" ]]; then
        CURLPKG=$(pacman -Ss libcurl 2>/dev/null | grep -E 'ssl|gnutls' | head -1 | grep -oP '(?<=/)\S+')
    fi
    if [[ -z "$CURLPKG" ]]; then
        echo "Couldn't find libcurl ssl/tls package"
        exit 1
    fi
    PKG_LIST+=("$CURLPKG")
fi

# --- Core packages ---
CORE_PKGS=("git" "base-devel" "opus" "opus-tools" "alsa-lib" "cmake")
PKG_LIST+=("${CORE_PKGS[@]}")

echo ""
echo "Installing prerequisites - $(date)"
echo ""

if command -v paru &>/dev/null; then
    echo "Detected paru (AUR helper). Installing..."
    paru -S --noconfirm "${PKG_LIST[@]}"
else
    echo "Detected pacman. Installing..."
    sudo pacman -S --noconfirm "${PKG_LIST[@]}"
fi

function ver { printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' '); }

cmakever=$(cmake --version | head -1 | cut -d" " -f3)

if [ $(ver $cmakever) -lt $(ver 3.16) ] ; then
  echo "Your CMake is too old! You need version 3.16 or higher. Try to get a newer version, or compile CMake from source."
  exit 1
fi
