#!/bin/bash

set -e

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
info "安装基础工具..."
TOOLS="pipx eza tlrc fzf atuin zoxide neovim nodejs jq"
for tool in $TOOLS; do
    if brew list "$tool" &>/dev/null; then
        warn "$tool 已安装"
    else
        info "安装 $tool..."
        brew install "$tool"
    fi
done
success "基础工具安装完成"

echo ""

# Install Python tools
info "安装 Python 工具..."
if command -v pipx &>/dev/null; then
    if ! pipx install ruff pyrefly; then
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

# Configure MCP servers
info "配置 MCP 服务器..."
if command -v claude &>/dev/null; then
    configure_mcp "ace-tool" "ACE_TOOL_TOKEN" \
        'claude mcp add ace-tool -s user --transport stdio -- npx ace-tool --base-url https://acemcp.heroman.wtf/relay/ --token "$ACE_TOOL_TOKEN"' \
        'claude mcp add ace-tool -s user --transport stdio -- npx ace-tool --base-url https://acemcp.heroman.wtf/relay/ --token <your_token>'

    configure_mcp "context7" "CONTEXT7_API_KEY" \
        'claude mcp add context7 -s user --transport http --url https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY:$CONTEXT7_API_KEY"' \
        'claude mcp add context7 -s user --transport http --url https://mcp.context7.com/mcp --header CONTEXT7_API_KEY:<your_key>'

    configure_mcp "sequential-thinking" "" \
        'claude mcp add sequential-thinking -s user --transport stdio -- npx -y @modelcontextprotocol/server-sequential-thinking' \
        'claude mcp add sequential-thinking -s user --transport stdio -- npx -y @modelcontextprotocol/server-sequential-thinking'

    success "MCP 服务器配置完成"
else
    warn "Claude Code 未安装，跳过 MCP 服务器配置"
fi

echo ""

# Configure LazyVim
install_if_missing "LazyVim" \
    "[ -d ~/.config/nvim ]" \
    'git clone https://github.com/LazyVim/starter ~/.config/nvim && rm -rf ~/.config/nvim/.git'

echo ""

# Install zsh plugins
info "安装 zsh 插件..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

declare -A plugins=(
    ["fast-syntax-highlighting"]="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
    ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab"
    ["git-open"]="https://github.com/paulirish/git-open.git"
    ["you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
)

for plugin in "${!plugins[@]}"; do
    plugin_dir="$ZSH_CUSTOM/plugins/$plugin"
    if [ ! -d "$plugin_dir" ]; then
        info "安装 $plugin..."
        local err
        if err=$(git clone "${plugins[$plugin]}" "$plugin_dir" 2>&1); then
            success "$plugin 安装完成"
        else
            warn "$plugin 安装失败: $err"
        fi
    else
        warn "$plugin 已安装"
    fi
done

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
