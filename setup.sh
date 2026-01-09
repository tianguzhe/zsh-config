#!/bin/bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[SKIP]${NC} $1"; }

echo -e "\n${CYAN}========== 开始安装 ==========${NC}\n"

# 安装 Homebrew
info "检查 Homebrew..."
if ! command -v brew &> /dev/null; then
    info "安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Homebrew 安装完成"
else
    warn "Homebrew 已安装"
fi

echo ""

# 安装 Oh My Zsh
info "检查 Oh My Zsh..."
if [ ! -d ~/.oh-my-zsh ]; then
    info "安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh 安装完成"
else
    warn "Oh My Zsh 已安装"
fi

echo ""

# 安装基础工具
info "安装基础工具..."
brew install pipx eza tldr fzf atuin zoxide neovim
success "基础工具安装完成"

echo ""

# 安装 Python 工具
info "安装 Python 工具..."
pipx install ruff pyrefly
# 把 ~/.local/bin 添加到 PATH
# pipx ensurepath
success "Python 工具安装完成"

echo ""

# 安装 uv
info "安装 uv..."
curl -LsSf https://astral.ac.cn/uv/install.sh | sh
success "uv 安装完成"

echo ""

# 安装 Rust
info "检查 Rust..."
if ! command -v cargo &> /dev/null; then
    info "安装 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    success "Rust 安装完成"
else
    warn "Rust 已安装"
fi

echo ""

# 安装 Bun
info "检查 Bun..."
if ! command -v bun &> /dev/null; then
    info "安装 Bun..."
    curl -fsSL https://bun.sh/install | bash
    success "Bun 安装完成"
else
    warn "Bun 已安装"
fi

echo ""

# 配置 LazyVim
info "检查 LazyVim..."
if [ ! -d ~/.config/nvim ]; then
    info "配置 LazyVim..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    success "LazyVim 配置完成"
else
    warn "LazyVim 已配置"
fi

echo ""

# 安装 zsh 插件
info "安装 zsh 插件..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

[ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ] && \
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ] && \
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
[ ! -d "$ZSH_CUSTOM/plugins/git-open" ] && \
    git clone https://github.com/paulirish/git-open.git "$ZSH_CUSTOM/plugins/git-open"
[ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ] && \
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

success "zsh 插件安装完成"

echo ""

# 复制配置文件
info "备份并复制配置文件..."
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.backup
[ -f ~/.zprofile ] && cp ~/.zprofile ~/.zprofile.backup
[ -f ~/.zsh_alias ] && cp ~/.zsh_alias ~/.zsh_alias.backup
cp .zsh_alias .zprofile .zshrc ~/
success "配置文件复制完成"

echo -e "\n${GREEN}========== 安装完成 ==========${NC}"
echo -e "${CYAN}请重启终端或运行: source ~/.zshrc${NC}\n"
