# Mac Work Dotfiles

Dotfiles and setup scripts for my work machine. From zero to productive in one script.

## Quick Setup (New Machine)

```bash
# 1. Install Xcode CLI tools (needed for git)
xcode-select --install

# 2. Clone and run
git clone <this-repo> ~/dotfilesmw
cd ~/dotfilesmw
bash scripts/setup.sh
```

The setup script handles everything: Homebrew, stow, packages, runtimes, containers, and macOS preferences.

## What's Included

### Dotfiles (managed by stow)
- `.zshrc` — Zsh config with zinit, starship, fzf, zoxide, mise
- `.config/brew/.BrewfileWork` — Homebrew packages and casks
- `.config/starship.toml` — Catppuccin Mocha prompt theme
- `.config/mise/config.toml` — Global runtime versions (Java 21, Node latest)
- `.config/eza/theme.yml` — EZA color theme
- `.config/git/` — Global gitignore
- `.config/tmux/tmux.conf` — Tmux config

### Scripts
- `scripts/setup.sh` — Full bootstrap (run once on new machine)
- `scripts/macos-defaults.sh` — macOS system preferences
- `scripts/containers-setup.sh` — Podman machine + MySQL 8.4 + MongoDB Atlas Local

## Runtime Management

Uses **mise** for all runtime version management (replaced nvm + sdkman):

```bash
# Global defaults (in ~/.config/mise/config.toml)
java = "zulu-21"    # default JDK
node = "latest"     # default Node

# Per-project overrides (in project .mise.toml)
java = "zulu-8"     # e.g., ePACT needs Java 8
```

## Manual Steps After Setup

1. Open a new terminal
2. `az login` — Azure CLI
3. Connect Twingate — VPN
4. Import SSH keys
5. Clone work repos to `~/_devroot/`
6. Open Claude Code, run `/ep-pr-setup`
7. Configure IntelliJ JDKs (paths printed by setup script)

## Day-to-Day

```bash
# Sync Homebrew packages after editing Brewfile
bsync

# Re-stow after editing dotfiles
cd ~/dotfilesmw && stow .
```
