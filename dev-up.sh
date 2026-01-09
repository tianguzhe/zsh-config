#!/bin/bash

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }

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

info "更新 pipx 包..."
pipx upgrade-all
success "pipx 更新完成"

echo ""

info "更新 Rust..."
rustup update
success "Rust 更新完成"

echo ""

info "更新 Bun..."
bun upgrade
success "Bun 更新完成"

echo ""

info "更新 uv..."
uv self update
success "uv 更新完成"

echo -e "\n${GREEN}========== 更新完成 ==========${NC}\n"
