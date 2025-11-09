# macOS 开发环境配置

一键配置 macOS 开发环境，包含 Zsh、Oh My Zsh、常用开发工具和插件。

## 功能特性

- **Shell 配置**: Oh My Zsh + ys 主题
- **开发工具**: Homebrew, Rust, Bun, Neovim (LazyVim)
- **Python 工具**: pipx, ruff, pyrefly, uv
- **实用工具**: eza, tldr, fzf, atuin, zoxide
- **Zsh 插件**:
  - fast-syntax-highlighting (语法高亮)
  - fzf-tab (模糊搜索)
  - zsh-autosuggestions (命令建议)
  - you-should-use (别名提示)
  - git-open (快速打开 Git 仓库)

## 快速开始

```bash
chmod +x setup.sh
./setup.sh
```

安装完成后重启终端或执行：
```bash
source ~/.zshrc
```

## 包含的配置文件

- `.zshrc` - Zsh 主配置
- `.zshenv` - 环境变量配置
- `.zsh_alias` - 命令别名

## 自定义别名

- `ls` → `eza --git --icons`
- `man` → `tldr`
- `st` → 打开 Sublime Text
- `code` → 打开 Visual Studio Code

## 备份说明

安装脚本会自动备份现有配置文件为 `.backup` 后缀。

## 许可证

MIT
