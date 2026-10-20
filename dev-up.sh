#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

echo -e "\n${CYAN}========== 更新开发工具 ==========${NC}\n"

info "更新 Homebrew..."
brew update && brew upgrade && brew cleanup
success "Homebrew 更新完成"

echo ""

info "更新 npm 全局包..."
npm outdated -g || true
npm update -g
success "npm 更新完成"

echo ""

info "更新 uv..."
uv self update
success "uv 更新完成"

echo ""

info "更新 uv 工具..."
uv tool upgrade --all
success "uv 工具更新完成"

echo ""

info "更新 Rust..."
rustup update
success "Rust 更新完成"

echo ""

info "更新 Bun..."
bun upgrade
success "Bun 更新完成"

echo -e "\n${GREEN}========== 更新完成 ==========${NC}\n"
