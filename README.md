# macOS 开发环境配置

一键配置 macOS 开发环境，包含 Zsh、Oh My Zsh、常用开发工具和插件。

## 功能特性

- **Shell 配置**: Oh My Zsh + ys 主题
- **开发工具**: Homebrew, Rust, Bun, Neovim (LazyVim)
- **Python 工具**: uv, ruff, pyrefly, claude-tap
- **npm 工具**: @antfu/ni, @anthropic-ai/claude-code, @openai/codex
- **实用工具**: eza, tldr, fzf, atuin, zoxide, fd, ripgrep
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
- `.zshenv` - 环境变量配置
- `.zsh_alias` - 命令别名

## 自定义别名

- `ls` → `eza --git --icons`
- `man` → `tldr`
- `st` → 打开 Sublime Text
- `code` → 打开 Visual Studio Code

## 备份说明

安装脚本会自动备份现有配置文件为 `.backup` 后缀。

## Claude Code 配置

本项目集成了完整的 Claude Code CLI 配置系统，提供 AI 辅助开发能力。

### 环境变量配置

使用 MCP 服务器前需要配置以下环境变量：

```bash
export MCP_API_KEY="your_api_key"
export MCP_PROFILE="your_profile"
```

### Agents（AI 助手角色）

- **backend-architect** - 后端架构师：RESTful API 设计、微服务架构、数据库设计
- **frontend-developer** - 前端开发者：React 组件、响应式设计、性能优化
- **code-reviewer** - 代码审查专家：代码质量、安全性、可维护性检查
- **mcp-expert** - MCP 集成专家：MCP 服务器配置、协议规范

### Commands（自定义命令）

- **/explain-code** - 代码功能分析器：16 步系统化代码分析流程
- **/git-commit** - Git Commit 生成器：自动分析变更并生成规范的 commit 消息
- **/git-reset** - Git 重置命令
- **/git-force-push** - Git 强制推送命令

### Skills（专业技能包）

- **hilt** - Android 依赖注入（基于 Dagger）
- **koin** - Kotlin 依赖注入框架（支持 Android、Ktor、KMP）

**更多 Skills 资源：**

- 访问 [Skills Marketplace](https://skillsmp.com/) 获取更多社区贡献的 Claude Code Skills
- 浏览、安装和分享专业领域的 AI 技能包

### MCP 服务器

- **chrome-devtools** - Chrome 浏览器自动化
- **context7** - 代码文档上下文检索
- **exa** - AI 驱动的网络搜索
- **sequential-thinking** - 多步骤思维推理
- **serena** - 代码导航和分析工具
- **codex** - AI 辅助编码和代码生成工具

#### 添加 Serena MCP 服务器

```bash
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context claude-code --project "$(pwd)"
```

#### 添加 Codex MCP 服务器

```bash
claude mcp add codex -s user --transport stdio -- uvx --from git+https://github.com/GuDaStudio/codexmcp.git codexmcp
```

### 状态栏功能

自定义状态栏显示：
- 模型名称和成本统计
- 对话轮数和上下文使用率
- Token 详情（输入/输出/缓存命中率）
- IP 地理位置信息
- 会话时长和 Git 分支

### 使用示例

**使用 Commands：**
```bash
# 分析代码功能
/explain-code src/main.ts

# 生成 commit 消息
/git-commit
```

**使用 Skills：**
```bash
# 获取 Hilt 依赖注入帮助
/hilt

# 获取 Koin 依赖注入帮助
/koin
```

**Agents 会在相关任务时自动触发**，例如：
- 编写代码后自动触发 code-reviewer 进行审查
- 设计 API 时自动触发 backend-architect 提供建议

## 许可证

MIT
