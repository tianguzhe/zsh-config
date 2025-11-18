#!/bin/bash

set -e

echo "开始安装..."

# 安装 homebrew
if ! command -v brew &> /dev/null; then
    echo "安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 安装 oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    echo "安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 安装基础工具
echo "安装基础工具..."
brew install pipx eza tldr fzf atuin zoxide neovim

# 安装 Python 工具
pipx install ruff pyrefly
pipx ensurepath

# 安装 uv
curl -LsSf https://astral.ac.cn/uv/install.sh | sh

# 安装 Rust
if ! command -v cargo &> /dev/null; then
    echo "安装 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# 安装 bun
if ! command -v bun &> /dev/null; then
    echo "安装 Bun..."
    curl -fsSL https://bun.sh/install | bash
fi

# 配置 LazyVim
if [ ! -d ~/.config/nvim ]; then
    echo "配置 LazyVim..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
fi

# 安装 zsh 插件
echo "安装 zsh 插件..."
[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting ] && \
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab ] && \
    git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/git-open ] && \
    git clone https://github.com/paulirish/git-open.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/git-open
[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use ] && \
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 复制配置文件
echo "复制配置文件..."
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.backup
[ -f ~/.zprofile ] && cp ~/.zprofile ~/.zprofile.backup
[ -f ~/.zsh_alias ] && cp ~/.zsh_alias ~/.zsh_alias.backup
cp .zsh_alias .zprofile .zshrc ~/

echo "安装完成！请重启终端或运行: source ~/.zshrc"
