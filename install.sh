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
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    local backup="$dst.bak" n=1
    while [ -e "$backup" ] || [ -L "$backup" ]; do
      backup="$dst.bak.$n"
      n=$((n + 1))
    done
    warn "Backing up existing $dst → $backup"
    mv "$dst" "$backup"
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
  # Homebrew may already be installed but absent from a fresh shell's PATH.
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$brew_bin" ]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done
  if command -v brew &>/dev/null; then
    info "Homebrew already installed"
    return
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$brew_bin" ]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done
  command -v brew &>/dev/null || error "Homebrew was installed but could not be found in PATH."
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
# Link the individual Neovim config entries, preserving unrelated files.
link_nvim() {
  local nvim_dst="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  mkdir -p "$nvim_dst"

  for item in init.lua lua lazy-lock.json; do
    local src="$DOTFILES/.config/nvim/$item"
    [ -e "$src" ] || error "Missing Neovim config: $src"
    link "$src" "$nvim_dst/$item"
  done
}

# ── main ───────────────────────────────────────────────────────────────────────
main() {
  info "Dotfiles: $DOTFILES"

  case "$OSTYPE" in
    darwin*) platform=macos ;;
    linux*) platform=linux ;;
    *) error "This script supports macOS and Linux only." ;;
  esac

  install_brew

  brew_install tmux
  brew_install neovim
  brew_install ruby
  brew_install ripgrep
  brew_install spotify-player
  brew_install openjdk@17
  if [ "$platform" = linux ]; then
    brew_install zsh
  fi

  install_omz
  install_zsh_plugins

  # Shell / terminal
  link "$DOTFILES/.zshrc"     "$HOME/.zshrc"
  link "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
  if [ "$platform" = macos ]; then
    link "$DOTFILES/ghostty/config" \
      "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  else
    link "$DOTFILES/ghostty/config" "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
  fi

  # Neovim
  link_nvim

  # Spotify TUI
  link "$DOTFILES/.config/spotify-player" "${XDG_CONFIG_HOME:-$HOME/.config}/spotify-player"

  echo ""
  info "Done. Open a new terminal or run: source ~/.zshrc"
}

main "$@"
