#!/bin/bash
# 目标系统为 macOS 自带的 /bin/bash 3.2，全程避免 bash 4+ 特性（如关联数组）。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

handle_error() {
    error "安装过程中出现错误（行号: $1），请检查日志"
    exit 1
}
trap 'handle_error $LINENO' ERR

echo -e "\n${CYAN}========== 开始安装 ==========${NC}\n"

# Install Homebrew
install_if_missing "Homebrew" \
    "command -v brew" \
    '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

echo ""

# Install Oh My Zsh
install_if_missing "Oh My Zsh" \
    "[ -d ~/.oh-my-zsh ]" \
    'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

echo ""

# Install brew tools
# 一次性安装，brew 会自动跳过已装包；依赖解析只跑一次，比逐个安装快。
info "安装基础工具..."
TOOLS="pipx eza tlrc fzf atuin zoxide neovim nodejs jq"
brew install $TOOLS
success "基础工具安装完成"

echo ""

# Install Python tools
info "安装 Python 工具..."
if command -v pipx &>/dev/null; then
    if ! pipx install ruff; then
        warn "Python 工具可能已安装"
    fi
    success "Python 工具安装完成"
else
    error "pipx 未安装，请先安装基础工具"
    exit 1
fi

echo ""

# Install uv
install_if_missing "uv" \
    "command -v uv" \
    'curl -LsSf https://astral.sh/uv/install.sh | sh'

echo ""

# Install Rust
install_if_missing "Rust" \
    "command -v cargo" \
    'curl --proto =https --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source "$HOME/.cargo/env"'

echo ""

# Install Bun
install_if_missing "Bun" \
    "command -v bun" \
    'curl -fsSL https://bun.sh/install | bash'

echo ""

# Install Claude Code
install_if_missing "Claude Code" \
    "command -v claude" \
    'curl -fsSL https://claude.ai/install.sh | bash'

echo ""

# Configure LazyVim
install_if_missing "LazyVim" \
    "[ -d ~/.config/nvim ]" \
    'git clone https://github.com/LazyVim/starter ~/.config/nvim && rm -rf ~/.config/nvim/.git'

echo ""

# Install zsh plugins
info "安装 zsh 插件..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# bash 3.2 无关联数组，改用 "name|url" 文本清单 + here-string 循环（不开子 shell）。
PLUGINS="fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting.git
fzf-tab|https://github.com/Aloxaf/fzf-tab
git-open|https://github.com/paulirish/git-open.git
you-should-use|https://github.com/MichaelAquilina/zsh-you-should-use.git
zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"

while IFS="|" read -r plugin url; do
    plugin_dir="$ZSH_CUSTOM/plugins/$plugin"
    if [ ! -d "$plugin_dir" ]; then
        info "安装 $plugin..."
        if err=$(git clone "$url" "$plugin_dir" 2>&1); then
            success "$plugin 安装完成"
        else
            warn "$plugin 安装失败: $err"
        fi
    else
        warn "$plugin 已安装"
    fi
done <<< "$PLUGINS"

success "zsh 插件处理完成"

echo ""

# Copy config files with timestamped backups
info "备份并复制配置文件..."
for file in .zsh_alias .zprofile .zshrc; do
    if [ ! -f "$SCRIPT_DIR/$file" ]; then
        error "配置文件 $file 不存在，跳过复制"
        continue
    fi

    if [ -f ~/"$file" ]; then
        cp ~/"$file" ~/"${file}.backup.$(date +%Y%m%d%H%M%S)"
        info "已备份 $file"
    fi

    cp "$SCRIPT_DIR/$file" ~/
    success "已复制 $file"
done

success "配置文件处理完成"

echo -e "\n${GREEN}========== 安装完成 ==========${NC}"
echo -e "${CYAN}请重启终端或运行: source ~/.zshrc${NC}\n"
