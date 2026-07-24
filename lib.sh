# Shared logging utilities for setup and update scripts.
# Sourced by setup.sh and dev-up.sh — do not execute directly.

# Catppuccin Mocha colors
RED='\033[38;2;243;139;168m'
GREEN='\033[38;2;166;227;161m'
YELLOW='\033[38;2;249;226;175m'
BLUE='\033[38;2;137;180;250m'
CYAN='\033[38;2;148;226;213m'
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
