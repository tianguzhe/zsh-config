# macOS 开发环境配置

一键配置 macOS 开发环境，包含 Zsh、Oh My Zsh、常用开发工具和插件。

## 功能特性

- **Shell 配置**: Oh My Zsh + ys 主题
- **开发工具**: Homebrew, Rust, Bun, Neovim (LazyVim)
- **Python 工具**: uv, ruff, pyrefly, claude-tap
- **npm 工具**: @antfu/ni, @anthropic-ai/claude-code, @openai/codex
- **实用工具**: eza, tldr, fzf, atuin, zoxide, fd, ripgrep, cloudflared
- **Zsh 插件**:
  - fast-syntax-highlighting (语法高亮)
  - fzf-tab (模糊搜索)
  - zsh-autosuggestions (命令建议)
  - you-should-use (别名提示)
  - git-open (快速打开 Git 仓库)
  - extract (解压万能命令)
  - copypath (复制路径到剪贴板)
  - uv (uv/uvx 自动补全)

## 快速开始

```bash
chmod +x setup.sh
./setup.sh
```

安装完成后重启终端或执行：
```bash
source ~/.zshrc
```

## 更新开发工具

```bash
chmod +x dev-up.sh
./dev-up.sh
```

批量更新 Homebrew、npm、uv tool、Rust、Bun 等开发工具。

## uv 常用命令

```bash
# 全局 CLI 工具管理（替代 pipx）
uv tool install <package>    # 安装全局工具
uv tool list                 # 列出已安装工具
uv tool upgrade <package>    # 升级指定工具
uv tool upgrade --all        # 升级所有工具
uv tool uninstall <package>  # 卸载工具

# 单文件脚本
uv run script.py             # 运行脚本（自动解析内联依赖）

# 项目依赖管理
uv init                      # 初始化新项目
uv add <package>             # 添加依赖
uv remove <package>          # 移除依赖
uv sync                      # 同步依赖
uv lock                      # 锁定依赖版本
```

## 包含的配置文件

- `.zshrc` - Zsh 主配置
- `.zprofile` - 环境变量配置
- `.zsh_alias` - 命令别名
- `lib.sh` - 共享日志工具函数（供 setup/dev-up 脚本使用）
- `config/ws/config.toml` - ws 搜索工具配置

## 自定义别名

- `ls` → `eza --git --icons`
- `man` → `tldr`
- `st` → 打开 Sublime Text
- `code` → 打开 Visual Studio Code
- `csp` → `claude --dangerously-skip-permissions`
- `claude-live` / `claude-live-ds` / `claude-live-any` → claude-tap 代理模式

## ws 搜索工具

自定义搜索命令行工具，[ws-search](https://github.com/tianguzhe/ws-search)。

```bash
ws google rust        # Google 搜索
ws gh -q "rust async" # GitHub 搜索
ws --list             # 查看所有别名
```

配置：`config/ws/config.toml`

## cloudflared 内网穿透

Cloudflare Tunnel 客户端，把本地服务暴露为公网 HTTPS 地址（由 `setup.sh` 安装）。

```bash
# 临时隧道：自动分配 *.trycloudflare.com 域名，无需登录
cloudflared tunnel --url http://localhost:8787

# 命名隧道：长期可用，需 Cloudflare 账号和已托管域名
cloudflared tunnel login                             # 浏览器授权
cloudflared tunnel create my-app                     # 创建隧道
cloudflared tunnel route dns my-app app.example.com  # 绑定域名
cloudflared tunnel run my-app                        # 启动
```

临时隧道仅供测试，进程退出后地址即失效；长期使用改用命名隧道。

隧道会把本地端口公开到互联网，启动前先确认该端口上跑的确实是要对外的服务：

```bash
lsof -nP -iTCP:8787 -sTCP:LISTEN
```

## 备份说明

安装脚本会自动备份现有配置文件为 `.backup` 后缀。

## Claude Code 配置

本项目集成了 Claude Code CLI 配置，提供自定义命令和状态栏。

### Commands（自定义命令）

- **/explain-code** - 代码功能分析器：系统化代码分析流程
- **/git-commit** - Git Commit 生成器：自动分析变更并生成规范的 commit 消息
- **/git-reset** - Git 重置命令：清除未提交的更改
- **/git-force-push** - Git 强制推送：默认使用 `--force-with-lease` 安全推送
- **/git-archive** - Git 归档：将仓库打包为 tar.gz
- **/backup/create** - 单文件备份：带时间戳的快速备份
- **/backup/cleanup** - 备份清理：清理旧备份文件
- **/todo/clear-all** - 清除全部待办（危险操作，需确认）

### 状态栏功能

自定义两行状态栏：
- **第1行**：路径 • Git 分支 • 模型名称 · 成本 · 对话轮数 · 上下文使用率 · Token 详情
- **第2行**：Usage 进度条 + 重置时间（订阅用户专属，7 天用量 ≥80% 时显示）

### 使用示例

**使用 Commands：**
```bash
# 分析代码功能
/explain-code src/main.ts

# 生成 commit 消息
/git-commit
```

## 许可证

MIT
