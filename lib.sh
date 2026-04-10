# Shared logging utilities for setup and update scripts.
# Sourced by setup.sh and dev-up.sh — do not execute directly.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[SKIP]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Install a tool if the check command fails.
# Usage: install_if_missing "Name" "check_cmd" "install_cmd"
install_if_missing() {
    local name="$1" check_cmd="$2" install_cmd="$3"
    info "检查 $name..."
    if ! eval "$check_cmd" &>/dev/null; then
        info "安装 $name..."
        eval "$install_cmd"
        success "$name 安装完成"
    else
        warn "$name 已安装"
    fi
}

# Configure an MCP server for Claude Code.
# Usage: configure_mcp "name" "ENV_VAR" "add_cmd" "manual_hint"
configure_mcp() {
    local name="$1" env_var="$2" add_cmd="$3" manual_hint="$4"
    if ! claude mcp list 2>/dev/null | grep -q "$name"; then
        info "配置 $name MCP 服务器..."
        if [ -n "${!env_var}" ]; then
            eval "$add_cmd" || warn "$name 配置失败"
        else
            warn "未设置 $env_var 环境变量，跳过 $name 配置"
            info "手动运行: $manual_hint"
        fi
    else
        warn "$name 已配置"
    fi
}
