# Cozy Dark Sway

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

## Install

```
unzip cozy-sway.zip && cd cozy-sway
bash install.sh --deps      # --deps installs packages with pacman first
sway -C                     # validate the config
```

Then log out and choose the **Sway** session. `install.sh` backs up any file it
replaces as `<file>.bak-<timestamp>`.

Install the wallpaper daemon separately. `swww` was renamed **`awww`**; install
whichever your repos provide (the scripts support both):

```
paru -S awww        # or: sudo pacman -S awww   (or swww)
```

Optional: install **SwayFX** instead of plain Sway for rounded corners and blur.
The installer enables `fx.conf` only when SwayFX is detected.

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

Put `.ovpn` files in `~/.config/openvpn-gui/` or use **Import config**, which also
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
