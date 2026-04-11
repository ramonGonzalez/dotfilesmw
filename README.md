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

## SSH Keys (YubiKey)

SSH keys are stored on the YubiKey as FIDO2 resident keys — the private key never touches disk and can't be extracted from the hardware.

Two YubiKeys are registered everywhere (main + backup). If one is lost, plug in the other and it works immediately.

### First-time setup (run once per YubiKey)

Requires Homebrew's OpenSSH and libfido2 (handled by `setup.sh`):

```bash
ssh-keygen -t ed25519-sk -O resident -C "yubikey-main"   # main key
ssh-keygen -t ed25519-sk -O resident -C "yubikey-backup"  # backup key
```

Then register both public keys with GitHub, GitLab, or any other service.

### New machine setup

No key generation needed — just pull the resident key from the YubiKey:

```bash
# Plug in YubiKey, then:
ssh-keygen -K
mv id_ed25519_sk_rk ~/.ssh/
mv id_ed25519_sk_rk.pub ~/.ssh/
```

> The private key handle on disk is not the actual private key — it only works when the YubiKey is physically present.

---

## Manual Steps After Setup

1. Open a new terminal
2. `az login` — Azure CLI
3. Connect Twingate — VPN
4. Pull SSH keys from YubiKey (see section above)
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
