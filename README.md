# Neil's Dotfiles

Opinionated, cross‑platform (macOS + Linux) dotfiles managed with GNU Stow. The goal is dead‑simple bootstrap on a new machine with just:

    	stow .

This repo currently includes `.zshrc` and Neovim config (`.config/nvim/`). More stacks (tmux, Ghostty, oh‑my‑zsh, Powerlevel10k, Karabiner, Raycast, etc.) can be added incrementally using the same pattern.

## What this repo is

- A source of truth for your shell/editor configs
- Structured to mirror $HOME so Stow can create symlinks safely
- Portable across macOS and Linux with minimal conditionals

## Prerequisites

- Git
- GNU Stow
  - macOS: `brew install stow`
  - Debian/Ubuntu: `sudo apt-get install stow`
  - Fedora/RHEL: `sudo dnf install stow`
  - Arch: `sudo pacman -S stow`

## Layout and conventions

- Place files/folders exactly as you want them to appear under `$HOME`
  - Example: `.zshrc` (file), `.config/nvim/` (folder)
- Machine‑local overrides live in `*.local` files or `local/` folders which are git‑ignored
- Plugin version locks that aid reproducibility (e.g. `lazy-lock.json`) are tracked
- Non‑config repo content (README, .git, etc.) is protected from stowing via `.stow-local-ignore`

## Quick start (recommended)

1.  Clone into `~/dotfiles` (the commands below assume this exact path)

2.  Dry run to preview actions (safe):

        stow -nvt ~ .

3.  When the dry run looks good, apply:

        stow .

Notes:

- Running inside `~/dotfiles` with no `-t` target will symlink into the parent directory (`~`) by default.
- If you keep the repo elsewhere, specify a target: `stow -t ~ .`

## Updating, restowing, and removing

- After making changes in the repo, re‑sync symlinks:

      	stow -R .

- To remove symlinks created by Stow (unstow):

      	stow -D .

- To preview any of the above, add `-n` for a dry run and `-v` for verbosity.

## Handling conflicts safely

If a real file already exists where a symlink would go, Stow will refuse to overwrite it.

Options:

- Backup manually (recommended): rename `~/.zshrc` to `~/.zshrc.bak`, then restow
- Adopt existing files into the repo (advanced):

      	stow --adopt .

  This moves conflicting files into the repo and replaces them with symlinks. Review `git status` carefully afterwards.

## Per‑machine/local settings

Use `*.local` and `local/` conventions to keep secrets or host‑specific tweaks out of version control.

Examples:

- Zsh: have `.zshrc` source `~/.zshrc.local` if it exists (not tracked)
- Neovim: place machine‑specific config in `.config/nvim/local.lua` or `.config/nvim/local/` (git‑ignored)

These patterns are already respected by `.gitignore` files in the repo.

## Neovim notes

- Keep `lazy-lock.json` tracked to pin plugin versions for reproducibility across machines
- Swap/backup/undo files are ignored
- If you use a first‑run bootstrap, simply open Neovim and let your plugin manager sync; e.g.: open `nvim` once after stowing

## Future additions (recommended structure)

You can add these later as top‑level peers so a single `stow .` keeps working:

- `.tmux.conf` and/or `.config/tmux/`
- `.config/ghostty/`
- `oh-my-zsh/` custom files or just keep `ZSH_CUSTOM` files under `.oh-my-zsh/custom/` if you prefer; manage `.zshrc` here
- Powerlevel10k: track `~/.p10k.zsh`
- Vim (if needed in addition to Neovim): `.vimrc`, `.vim/`
- Karabiner: `.config/karabiner/karabiner.json`
- Raycast: export settings; Raycast sync isn’t purely file‑based, but you can keep snippets/scripts here

Tip: Prefer XDG paths (`~/.config/...`) where possible so macOS/Linux align.

## Troubleshooting

- Stow is touching files it shouldn’t: see `.stow-local-ignore` in this repo
- I want to see exactly what will change: use `stow -nvv .`
- Strange symlink locations: ensure you’re in `~/dotfiles` and/or pass `-t ~`

## Why GNU Stow?

- Simple, declarative symlink management
- Safe by default (refuses to overwrite real files)
- Easy to adopt/remove per “package” or everything at once

---

Happy stowing! If you add new tool configs, mirror the `$HOME` layout and they’ll integrate seamlessly with `stow .`.
