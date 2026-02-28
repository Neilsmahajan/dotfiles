# Neil's Dotfiles

Opinionated macOS dotfiles managed with GNU Stow. The repo mirrors `$HOME` exactly, so a single command symlinks everything into place:

    stow .

## What this repo is

- A source of truth for shell, editor, terminal, and keyboard configs
- Structured to mirror `$HOME` so Stow creates symlinks in the right places
- Portable across Macs; Linux is a secondary target

## Prerequisites

- Git
- GNU Stow — `brew install stow`

## What is tracked and stowed

Shell and prompt

- `~/.zshrc`, `~/.zprofile`, `~/.zshenv`
- `~/.p10k.zsh` (Powerlevel10k)

Editors

- Neovim: `~/.config/nvim/`
- Vim: `~/.vimrc`, `~/.vim/`

Terminal and themes

- Ghostty themes: `~/.config/ghostty/themes/`
- Ghostty main config: `~/Library/Application Support/com.mitchellh.ghostty/config`
  (macOS only — Ghostty does not support XDG on macOS for its main config file)

Keyboard and automation

- Karabiner Elements: `~/.config/karabiner/karabiner.json`
- Hammerspoon: `~/.hammerspoon/init.lua`

Terminal multiplexer

- tmux: `~/.tmux.conf`
- Sessionizer receipt: `~/.config/tmux-sessionizer/`

Scripts

- `~/.local/bin/` — custom scripts (copilot-notify, helium-sync, helium-unstow,
  tmux-platform, tmux-sessionizer)

Homebrew

- `~/.Brewfile`

Git

- `~/.gitconfig` — name, email, and aliases
  - For machine-specific identity overrides, create `~/.gitconfig.local` (git-ignored);
    it is automatically included via `[include]` in `.gitconfig`

AWS (localstack)

- `~/.aws/config` — localstack profile (`endpoint_url = http://localhost:4566`)
- `~/.aws/credentials` — localstack dummy credentials (`aws_access_key_id = test`)
  These are not real secrets; they are the standard localstack test values.
  If you ever add real AWS profiles, put them in `~/.aws/config.local` and keep them
  out of git.

GitHub CLI

- `~/.config/gh/config.yml` — preferences and aliases (e.g. `co: pr checkout`)
  `hosts.yml` and `ai/` are machine-bound and git-ignored; run `gh auth login` on
  each machine.

Not stowed by design

- `~/.oh-my-zsh/` — installed per machine via the oh-my-zsh installer
- Helium bookmarks (see below)
- `~/.config/gh/hosts.yml` and `~/.config/gh/ai/` — machine-bound auth state
- `~/.gitconfig.local` — machine-local git identity overrides

## Quick start

1. Clone into `~/dotfiles`

2. Dry run to preview (safe — makes no changes):

       stow -nvt ~ .

3. When the dry run looks good, apply:

       stow .

4. Restore Helium bookmarks on a new machine:

       helium-unstow

## Updating and restowing

After making changes in the repo, re-sync symlinks:

    stow -R .

To remove all symlinks created by Stow:

    stow -D .

## Handling conflicts

If a real file already exists where a symlink would go, Stow will refuse to overwrite it.

- Backup the conflicting file manually (e.g. `mv ~/.zshrc ~/.zshrc.bak`), then restow.
- Or adopt it into the repo (review `git diff` carefully after):

      stow --adopt .

## Helium bookmarks

Helium manages its own profile directory and does not support symlinks for its `Bookmarks`
file — it writes a real file there. Stow cannot manage it directly.

Two scripts handle this:

- **`helium-sync`** — copies the live `~/Library/.../Bookmarks` into the repo so it can be
  committed. Run this before committing when bookmarks have changed.
- **`helium-unstow`** — copies `Bookmarks` from the repo back to the live location. Run this
  on a new machine after cloning (Helium must have been opened at least once first).

## Per-machine local settings

Use `*.local` and `local/` conventions to keep secrets or host-specific tweaks out of git.

- Zsh: have `.zshrc` source `~/.zshrc.local` if it exists (not tracked)
- Neovim: place machine-specific config in `.config/nvim/local.lua` or `.config/nvim/local/`

These patterns are already respected by `.gitignore` files in the repo.

## Neovim notes

- `lazy-lock.json` is tracked to pin plugin versions across machines
- Open `nvim` once after stowing to let lazy.nvim bootstrap and sync plugins

## Troubleshooting

- **Stow touches files it shouldn't**: use `stow -nvt ~ .` to preview, then add entries to
  `.stow-local-ignore` to exclude repo-only files
- **See exactly what will change**: `stow -nvv .`
- **Strange symlink locations**: ensure you are running from inside `~/dotfiles`
