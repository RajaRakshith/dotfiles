#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[info]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }
error() { echo -e "${RED}[error]${NC} $*"; exit 1; }

# ── symlink helper ─────────────────────────────────────────────────────────────
# usage: link <src> <dst>
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "Backing up existing $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  info "Linked $(basename "$src") → $dst"
}

# ── homebrew ───────────────────────────────────────────────────────────────────
install_brew() {
  if command -v brew &>/dev/null; then
    info "Homebrew already installed"
    return
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for the rest of this script on Apple Silicon
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

brew_install() {
  local pkg="$1"
  if brew list --formula "$pkg" &>/dev/null 2>&1; then
    info "$pkg already installed"
  else
    info "Installing $pkg..."
    brew install "$pkg"
  fi
}

# ── oh-my-zsh ──────────────────────────────────────────────────────────────────
install_omz() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    info "Oh My Zsh already installed"
    return
  fi
  info "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_zsh_plugins() {
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local plugins=(
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-autosuggestions"
  )
  for repo in "${plugins[@]}"; do
    local name="${repo##*/}"
    local dst="$custom/plugins/$name"
    if [ -d "$dst" ]; then
      info "$name already installed"
    else
      info "Installing $name..."
      git clone --depth=1 "https://github.com/$repo.git" "$dst"
    fi
  done
}

# ── neovim config ──────────────────────────────────────────────────────────────
# .config/ in this repo is the nvim config root; spotify-player lives inside it.
link_nvim() {
  local nvim_dst="$HOME/.config/nvim"
  mkdir -p "$nvim_dst"

  for item in init.lua lua lazy-lock.json; do
    local src="$DOTFILES/.config/$item"
    [ -e "$src" ] && link "$src" "$nvim_dst/$item"
  done
}

# ── main ───────────────────────────────────────────────────────────────────────
main() {
  info "Dotfiles: $DOTFILES"

  if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script currently supports macOS only."
  fi

  install_brew

  brew_install tmux
  brew_install neovim
  brew_install ruby   # required by .zshrc PATH entries

  install_omz
  install_zsh_plugins

  # Shell / terminal
  link "$DOTFILES/.zshrc"     "$HOME/.zshrc"
  link "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"

  # Neovim
  link_nvim

  # Spotify TUI
  link "$DOTFILES/.config/spotify-player" "$HOME/.config/spotify-player"

  echo ""
  info "Done. Open a new terminal or run: source ~/.zshrc"
}

main "$@"
