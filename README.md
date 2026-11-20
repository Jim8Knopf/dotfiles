# dotfiles
dotfiles with stow
If you wanna aply a config you need stow installed and and you aply the config with ``stow 'program name'``

```bash
pacman -S stow
```

```bash
stow --target="$HOME" hypr waybar
```

Link the additional packages with:

```bash
stow --target="$HOME" ghostty wallpapers signal
stow --target="$HOME" --no-folding cliamp quickshell
stow --target="$HOME" --no-folding hyprpaper
systemctl --user daemon-reload
```
