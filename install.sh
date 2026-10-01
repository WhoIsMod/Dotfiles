#!/usr/bin/env bash
# Installs the Cozy Dark Sway setup into $HOME, backing up existing files.
# Usage: ./install.sh [--deps]   (--deps installs packages with pacman first)
# Note: swww was renamed awww; install whichever your repos provide.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ "${1:-}" == "--deps" ]]; then
    sudo pacman -S --needed sway waybar fuzzel mako swaylock swayidle grim slurp wl-clipboard \
        brightnessctl playerctl pavucontrol pipewire pipewire-pulse pipewire-alsa wireplumber \
        xdg-desktop-portal-wlr network-manager-applet power-profiles-daemon gamemode libnotify \
        kitty dolphin openvpn polkit-gnome zenity ttf-jetbrains-mono-nerd ttf-font-awesome curl
    echo ">> Also install the wallpaper daemon: awww (formerly swww), e.g. 'paru -S awww' or 'pacman -S awww'"
    echo ">> Optional: swayfx (rounded corners + blur) instead of sway"
fi

cd "$HERE"
find .config .local -type f ! -name 'fx.conf.swayfx' | while read -r f; do
    dest="$HOME/$f"
    mkdir -p "$(dirname "$dest")"
    [[ -e "$dest" ]] && cp "$dest" "$dest.bak-$STAMP"
    cp "$f" "$dest"
done

# SwayFX effects only if SwayFX is installed; otherwise an empty include.
FX="$HOME/.config/sway/fx.conf"
[[ -e "$FX" ]] && cp "$FX" "$FX.bak-$STAMP"
if command -v swayfx >/dev/null 2>&1 || sway --version 2>/dev/null | grep -qi swayfx; then
    cp .config/sway/fx.conf.swayfx "$FX"
else
    echo "# plain Sway: no effects" > "$FX"
fi

# Hook the colour scheme into kitty
mkdir -p ~/.config/kitty
grep -qs 'cozy-dark.conf' ~/.config/kitty/kitty.conf || echo 'include cozy-dark.conf' >> ~/.config/kitty/kitty.conf

chmod +x ~/.local/bin/{desktop-mode,waybar-mode,waybar-weather,waybar-uptime,launch-game,wallpaper,openvpn-menu,openvpn-status}
mkdir -p ~/.local/state ~/Pictures/Wallpapers ~/.config/openvpn-gui
echo "Done. Put wallpapers in ~/Pictures/Wallpapers, then validate with: sway -C"
