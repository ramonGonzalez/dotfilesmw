#!/usr/bin/env bash
# Bootstrap a new Mac from zero — run from the dotfiles repo root
# Usage: git clone <repo> ~/dotfilesmw && cd ~/dotfilesmw && bash scripts/setup.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "================================================"
echo "  Mac Work Setup — from zero to productive"
echo "================================================"
echo ""

# ── 1. Homebrew ────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "[1/6] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "[1/6] Homebrew already installed."
fi

# ── 2. Stow dotfiles ──────────────────────────────────────────────
echo "[2/6] Stowing dotfiles..."
if ! command -v stow &>/dev/null; then
  brew install stow
fi
cd "$DOTFILES_DIR" && stow .
echo "  Linked: .zshrc, .config/brew, .config/starship, .config/mise, .config/git, .config/tmux, .config/eza"

# ── 3. Brew bundle ─────────────────────────────────────────────────
echo "[3/6] Installing Homebrew packages..."
export HOMEBREW_BUNDLE_FILE="$HOME/.config/brew/.BrewfileWork"
brew bundle install --verbose

# ── 4. Runtimes via mise ──────────────────────────────────────────
echo "[4/6] Installing runtimes via mise..."
eval "$(mise activate bash)"
mise install --yes
echo "  Installed: $(mise current java) | $(mise current node)"

# Register JDKs with macOS for IntelliJ discovery
echo ""
echo "  To register JDKs with IntelliJ (requires sudo):"
for JDK_DIR in "$HOME/.local/share/mise/installs/java"/*/; do
  JDK_NAME=$(basename "$JDK_DIR")
  JDK_BUNDLE=$(find "$JDK_DIR" -maxdepth 1 -name "*.jdk" -type d | head -1)
  if [ -n "$JDK_BUNDLE" ] && [ -d "$JDK_BUNDLE/Contents" ]; then
    TARGET="/Library/Java/JavaVirtualMachines/${JDK_NAME}.jdk"
    if [ ! -d "$TARGET" ]; then
      echo "    sudo mkdir -p $TARGET && sudo ln -sf $JDK_BUNDLE/Contents $TARGET/Contents"
    fi
  fi
done

# ── 5. Containers ─────────────────────────────────────────────────
echo "[5/6] Setting up dev containers..."
bash "$DOTFILES_DIR/scripts/containers-setup.sh"

# ── 6. macOS defaults ─────────────────────────────────────────────
echo "[6/6] Applying macOS defaults..."
bash "$DOTFILES_DIR/scripts/macos-defaults.sh"

# ── Done ───────────────────────────────────────────────────────────
echo ""
echo "================================================"
echo "  Setup complete!"
echo "================================================"
echo ""
echo "Manual steps remaining:"
echo "  1. Open a new terminal (to load .zshrc)"
echo "  2. az login                    — Azure CLI auth"
echo "  3. Connect Twingate            — VPN access"
echo "  4. Pull SSH keys from YubiKey  — plug in YubiKey, run: ssh-keygen -K && mv id_ed25519_sk_rk* ~/.ssh/"
echo "  5. Clone work repos to ~/\_devroot/"
echo "  6. Open Claude Code, run /ep-pr-setup"
echo "  7. Configure IntelliJ JDKs     — see paths above"
echo "  8. Install SDKMAN (if needed)  — only for legacy Java tooling"
echo ""
echo "Optional:"
echo "  - pass init <gpg-id>           — password store"
echo "  - gh auth login                — GitHub CLI"
echo ""
