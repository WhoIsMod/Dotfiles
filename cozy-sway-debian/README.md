# Cozy Dark Sway (Debian edition)

A cozy dark Wayland desktop built on **Sway**, styled after a navy and lavender
KDE-style reference, with:

- **Waybar** bottom panel (workspace dots, dock-style launchers, coloured icons)
- **PipeWire / WirePlumber** audio (`wpctl` keybinds, volume module)
- **swww / awww** wallpaper manager with transitions
- **Game Mode / Business Mode** toggle (GameMode, power profiles, effects on/off)
- **OpenVPN tray-style icon** (pick a `.ovpn`, connect, disconnect)
- Matching themes for fuzzel, mako, swaylock and kitty

> Sway is Wayland-only. `swww`/`awww` also needs Wayland, so none of this runs in
> an X11 session. Pick **Sway** at your login screen (or run
> `sway --unsupported-gpu` from a TTY if you use the proprietary NVIDIA driver).

## Install (Debian 13 "trixie")

```
unzip cozy-sway-debian.zip && cd cozy-sway-debian
mv local .local
mv config .config
bash install.sh --deps      # --deps installs packages with apt first
sway -C                     # validate the config
```

Then log out and choose the **Sway** session at the login screen. `install.sh`
backs up any file it replaces as `<file>.bak-<timestamp>`.

What `--deps` does beyond `apt install`:

- installs a polkit agent (needed for the VPN password prompt), picking the first of
  `policykit-1-gnome`, `polkit-kde-agent-1`, `mate-polkit`, `lxpolkit` that exists
- downloads **JetBrainsMono Nerd Font** into `~/.local/share/fonts` (not in Debian)
- installs the wallpaper daemon **awww** (formerly swww) from apt if packaged,
  otherwise builds it with `cargo`. If that fails, install it from the project's
  page and put the binaries in `~/.local/bin`
- enables the PipeWire user services

Notes for Debian:

- **Debian 12 (bookworm)** has older Sway/Waybar and no `fuzzel`; use trixie, or
  install those from backports or source.
- **SwayFX** (rounded corners and blur) isn't packaged in Debian. Plain Sway works
  fine; effects only apply if you build SwayFX yourself.
- If `pulseaudio` is installed, remove it so `pipewire-pulse` takes over:
  `sudo apt remove pulseaudio`.
- `openvpn` lives in `/usr/sbin` on Debian; the VPN script handles that.
- The file manager launcher uses Dolphin (pulls in KDE libraries). To use something
  lighter, install `thunar` and change `dolphin` in `~/.config/sway/config` and
  `~/.config/waybar/config.jsonc`.
- NVIDIA proprietary driver: run Sway with `sway --unsupported-gpu`.

## Keybinds (`$mod` = Super)

| Keys | Action |
|---|---|
| `$mod+Return` | Terminal (kitty) |
| `$mod+d` | App launcher (fuzzel) |
| `$mod+b` / `$mod+e` | Browser / Files (Dolphin) |
| `$mod+Shift+q` | Close window |
| `$mod+Shift+c` | Reload config |
| `$mod+h/j/k/l` or arrows | Focus (add `Shift` to move the window) |
| `$mod+1..0` | Switch workspace (`Shift` to move window there) |
| `$mod+v` / `$mod+s` | Split vertical / horizontal |
| `$mod+f` | Fullscreen |
| `$mod+space` | Toggle floating |
| `$mod+r` | Resize mode (`Esc` to leave) |
| `$mod+g` | **Toggle Game / Business mode** |
| `$mod+Shift+g` | Enable Game mode and launch Steam/Lutris |
| `$mod+Shift+b` | Business mode |
| `$mod+m` | Mode menu (modes, lock, logout, reboot, shutdown) |
| `$mod+Escape` | System mode (g/b/l/q) |
| `$mod+w` / `$mod+Shift+w` | Next / random wallpaper |
| `$mod+Shift+v` | VPN menu |
| `$mod+n` / `$mod+Shift+n` | Volume control / network editor |
| `$mod+Shift+x` | Lock screen |
| `Print` / `Shift+Print` | Screenshot region / full screen |

Volume, mute, media and brightness keys work via `wpctl`, `playerctl` and
`brightnessctl`.

## The panel

- **Left:** app grid (fuzzel), workspace dots, window title
- **Centre:** clickable launchers: terminal, files, browser, Discord, Spotify, Steam
- **Right:** now playing, mode pill, idle inhibitor, clock, weather, CPU, RAM,
  uptime, **VPN**, volume, network, tray, power menu

Click targets: mode pill toggles Game/Business (right-click: menu); volume opens
`pavucontrol` (right-click: mute); clock click swaps to the date; power button
opens the mode menu.

## Game / Business mode

| | Game | Business |
|---|---|---|
| GameMode client | running (`gamemoderun sleep infinity`) | stopped |
| Power profile | performance | balanced |
| Compositor effects (SwayFX) | blur, shadows, rounded corners off | on |

Config for GameMode is in `~/.config/gamemode.ini`. For individual Steam games you
can also use `gamemoderun %command%` in the launch options. Test with
`gamemoded -t`.

## Wallpapers

Put images in `~/Pictures/Wallpapers` (override with `WALLPAPER_DIR`).

```
~/.local/bin/wallpaper init            # restore last (runs on login)
~/.local/bin/wallpaper next | random
~/.local/bin/wallpaper set /path/to/img.png
```

You never need to start `awww-daemon` by hand; the script starts it. If it
reports it can't connect to a Wayland socket, you aren't inside a Sway session.

## Audio

PipeWire + WirePlumber + `pipewire-pulse`. If there's no sound:

```
systemctl --user enable --now pipewire pipewire-pulse wireplumber
wpctl status                  # default sink has a *
wpctl set-default <id>        # pick the right output (not HDMI on the GPU)
wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
speaker-test -c 2 -t wav -l 1
```

## OpenVPN tray-style icon

The shield icon on the right of the panel works like OpenVPN GUI on Windows.

- **Grey** disconnected, **yellow** connecting, **green** connected (the tooltip
  shows the config name and tunnel IP)
- **Left-click:** menu listing your configs (`●` marks the active one), plus
  Import config, Disconnect, Open folder, Show log
- **Right-click:** disconnect

Put `.ovpn` files in `~/.config/openvpn-gui/`, run `openvpn-menu import /path/to/file.ovpn`, or use **Import config**, which also
copies cert/key files referenced next to the config. Connecting runs
`openvpn` through `pkexec`, so a polkit prompt appears (an agent starts with Sway).
If a config needs a username and password you'll be prompted for them; they are
kept in a temporary file in `$XDG_RUNTIME_DIR` and deleted once the tunnel is up.

Needs `openvpn`, `polkit-gnome` and `zenity` (or `kdialog`).

## Files

```
~/.config/sway/config            main config
~/.config/sway/fx.conf           SwayFX effects (empty on plain Sway)
~/.config/waybar/{config.jsonc,style.css}
~/.config/{fuzzel,mako,swaylock}/  themes
~/.config/kitty/cozy-dark.conf   colours (included from kitty.conf)
~/.config/gamemode.ini
~/.local/bin/
    polkit-agent                 starts whichever polkit agent is installed
    desktop-mode                 game/business controller
    waybar-mode, waybar-weather, waybar-uptime
    wallpaper                    swww/awww manager
    openvpn-menu, openvpn-status VPN module
    launch-game
```

## Palette

| | | |
|---|---|---|
| bg `#1a1d2b` | surface `#2c3147` | text `#d9deee` |
| blue `#8aa4ff` | lavender `#b4a0ff` | cyan `#8ad6e0` |
| green `#a9d9a0` | yellow `#ecd08a` | red `#ef8e9a` |

## Troubleshooting

- **Waybar missing at login:** `exec_always` lines must not contain a bare `;`
  (Sway treats it as a command separator); the config uses
  `sh -c 'pkill -x waybar; exec waybar'`. To see errors run
  `pkill waybar; waybar -l debug`.
- **`awww-daemon` can't find the Wayland socket:** you aren't in a Wayland
  session. Log in to Sway.
- **File picker doesn't open in browsers:** needs `xdg-desktop-portal` +
  `xdg-desktop-portal-gtk`, the portal config in
  `~/.config/xdg-desktop-portal/sway-portals.conf`, and the
  `dbus-update-activation-environment` line in the Sway config. Then run
  `systemctl --user restart xdg-desktop-portal xdg-desktop-portal-gtk` (or log out
  and back in). Check logs with `journalctl --user -u xdg-desktop-portal -b`.
- **Empty box instead of an icon:** your Nerd Font lacks that glyph; install
  `ttf-jetbrains-mono-nerd` and `ttf-font-awesome`.
- **No battery module:** the setup assumes a desktop; add a Waybar `battery`
  module for a laptop.
- **Weather:** location is detected by IP via wttr.in; edit `waybar-weather` to
  pin a city.
- **NVIDIA:** Sway needs `--unsupported-gpu`; you may also need
  `WLR_NO_HARDWARE_CURSORS=1`.
- **GTK/Qt apps (e.g. Dolphin) don't match the theme:** set a dark theme with
  `nwg-look` or `kvantum`.
