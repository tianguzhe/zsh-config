#!/bin/bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 错误处理（仅在非预期错误时触发）
handle_error() {
    error "安装过程中出现错误（行号: $1），请检查日志"
    exit 1
}
trap 'handle_error $LINENO' ERR

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
TOOLS="pipx eza tldr fzf atuin zoxide neovim nodejs jq"
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

# 安装 Python 工具
info "安装 Python 工具..."
if command -v pipx &> /dev/null; then
    set +e  # 临时禁用错误退出
    pipx install ruff pyrefly 2>/dev/null
    if [ $? -ne 0 ]; then
        warn "Python 工具可能已安装"
    fi
    set -e  # 重新启用错误退出
    success "Python 工具安装完成"
else
    error "pipx 未安装，请先安装基础工具"
    exit 1
fi

echo ""

# 安装 uv
info "检查 uv..."
if ! command -v uv &> /dev/null; then
    info "安装 uv..."
    curl -LsSf https://astral.ac.cn/uv/install.sh | sh
    success "uv 安装完成"
else
    warn "uv 已安装"
fi

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

# 安装 Claude Code
info "检查 Claude Code..."
if ! command -v claude &> /dev/null; then
    info "安装 Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    success "Claude Code 安装完成"
else
    warn "Claude Code 已安装"
fi

echo ""

# 配置 MCP 服务器
info "配置 MCP 服务器..."
if command -v claude &> /dev/null; then
    set +e  # 临时禁用错误退出，因为 MCP 配置可能失败

    # 检查 MCP 服务器是否已配置
    if ! claude mcp list 2>/dev/null | grep -q "ace-tool"; then
        info "配置 ace-tool MCP 服务器..."
        # 检查是否设置了环境变量
        if [ -n "$ACE_TOOL_TOKEN" ]; then
            claude mcp add ace-tool -s user --transport stdio -- npx ace-tool --base-url https://acemcp.heroman.wtf/relay/ --token "$ACE_TOOL_TOKEN"
            [ $? -ne 0 ] && warn "ace-tool 配置失败"
        else
            warn "未设置 ACE_TOOL_TOKEN 环境变量，跳过 ace-tool 配置"
            info "请设置环境变量后手动运行: claude mcp add ace-tool -s user --transport stdio -- npx ace-tool --base-url https://acemcp.heroman.wtf/relay/ --token <your_token>"
        fi
    else
        warn "ace-tool 已配置"
    fi

    if ! claude mcp list 2>/dev/null | grep -q "context7"; then
        info "配置 context7 MCP 服务器..."
        if [ -n "$CONTEXT7_API_KEY" ]; then
            claude mcp add context7 -s user --transport http --url https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY:$CONTEXT7_API_KEY"
            [ $? -ne 0 ] && warn "context7 配置失败"
        else
            warn "未设置 CONTEXT7_API_KEY 环境变量，跳过 context7 配置"
            info "请设置环境变量后手动运行: claude mcp add context7 -s user --transport http --url https://mcp.context7.com/mcp --header CONTEXT7_API_KEY:<your_key>"
        fi
    else
        warn "context7 已配置"
    fi

    if ! claude mcp list 2>/dev/null | grep -q "sequential-thinking"; then
        info "配置 sequential-thinking MCP 服务器..."
        claude mcp add sequential-thinking -s user --transport stdio -- npx -y @modelcontextprotocol/server-sequential-thinking
        [ $? -ne 0 ] && warn "sequential-thinking 配置失败"
    else
        warn "sequential-thinking 已配置"
    fi

    set -e  # 重新启用错误退出
    success "MCP 服务器配置完成"
else
    warn "Claude Code 未安装，跳过 MCP 服务器配置"
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

# 定义插件列表
declare -A plugins=(
    ["fast-syntax-highlighting"]="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
    ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab"
    ["git-open"]="https://github.com/paulirish/git-open.git"
    ["you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
)

set +e  # 临时禁用错误退出

# 安装插件
for plugin in "${!plugins[@]}"; do
    plugin_dir="$ZSH_CUSTOM/plugins/$plugin"
    if [ ! -d "$plugin_dir" ]; then
        info "安装 $plugin..."
        git clone "${plugins[$plugin]}" "$plugin_dir" 2>/dev/null
        if [ $? -eq 0 ]; then
            success "$plugin 安装完成"
        else
            warn "$plugin 安装失败，请手动安装"
        fi
    else
        warn "$plugin 已安装"
    fi
done

set -e  # 重新启用错误退出

success "zsh 插件处理完成"

echo ""

# 复制配置文件
info "备份并复制配置文件..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查源文件是否存在
for file in .zsh_alias .zprofile .zshrc; do
    if [ ! -f "$SCRIPT_DIR/$file" ]; then
        error "配置文件 $file 不存在，跳过复制"
        continue
    fi

    # 备份现有文件
    if [ -f ~/"$file" ]; then
        cp ~/"$file" ~/"${file}.backup"
        info "已备份 $file"
    fi

    # 复制新文件
    cp "$SCRIPT_DIR/$file" ~/
    success "已复制 $file"
done

success "配置文件处理完成"

echo -e "\n${GREEN}========== 安装完成 ==========${NC}"
echo -e "${CYAN}请重启终端或运行: source ~/.zshrc${NC}\n"
