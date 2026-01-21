# Claude MCP Add 命令详细指南

## 基本语法

```bash
claude mcp add [options] <name> [url-or-command]
```

或者对于 stdio 服务器：

```bash
claude mcp add [options] <name> -- <command> [args...]
```

**参数说明：**
- `<name>` - MCP 服务器的唯一标识符（必需）
- `[url-or-command]` - 服务器地址或命令（取决于传输类型）

---

## 核心参数详解

### 1. `-s/--scope` 参数（作用域）

**作用：** 指定 MCP 服务器配置的存储位置和可访问范围。

| 值 | 存储位置 | 可访问范围 | 用途 |
|---|---------|---------|------|
| `local` (默认) | `~/.claude.json` (项目路径下) | 仅当前项目 | 个人开发、实验配置、敏感凭证 |
| `project` | `.mcp.json` (项目根目录) | 团队共享 | 团队协作、版本控制 |
| `user` | `~/.claude.json` (全局) | 所有项目 | 跨项目工具、个人实用程序 |

**示例：**

```bash
# 本地作用域（默认，仅当前项目）
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server

# 项目作用域（团队共享）
claude mcp add codex -s project -- uvx --from git+https://github.com/GuDaStudio/codexmcp.git codexmcp

# 用户作用域（跨所有项目）
claude mcp add github -s user --transport http https://api.githubcopilot.com/mcp/
```

**优先级：** 当同名服务器存在于多个作用域时，优先级为：
1. **Local** (最高优先级)
2. **Project**
3. **User** (最低优先级)

---

### 2. `--transport` 参数（传输方式）

**作用：** 指定 MCP 服务器的通信方式。

| 值 | 说明 | 用途 | 示例 |
|---|------|------|------|
| `http` | HTTP 远程服务器 | 云服务、远程 API | `--transport http https://mcp.notion.com/mcp` |
| `sse` | Server-Sent Events（已弃用） | 旧版远程服务器 | `--transport sse https://mcp.asana.com/sse` |
| `stdio` | 本地进程 | 本地工具、脚本 | `--transport stdio -- npx server` |

**默认值：** 如果不指定，根据 URL 格式自动判断（HTTP/HTTPS 为 `http`）

**示例：**

```bash
# HTTP 远程服务器
claude mcp add notion --transport http https://mcp.notion.com/mcp

# Stdio 本地服务器
claude mcp add airtable --transport stdio -- npx -y airtable-mcp-server

# 带认证的 HTTP 服务器
claude mcp add secure-api --transport http https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

---

### 3. `--` 分隔符

**作用：** 分隔 Claude 的选项和传递给 MCP 服务器的命令/参数。

**重要规则：**
- 所有 Claude 选项（`--transport`、`--env`、`--scope`、`--header`）必须在 `--` 之前
- `--` 之后的所有内容都作为命令和参数传递给 MCP 服务器
- 防止 Claude 的标志与服务器的标志冲突

**示例对比：**

```bash
# 正确：选项在前，命令在后
claude mcp add --transport stdio --env KEY=value myserver -- npx server --port 8080
# 执行：npx server --port 8080（KEY=value 在环境中）

# 错误：会导致 --port 被 Claude 解析
claude mcp add --transport stdio myserver -- npx server --port 8080 --env KEY=value
```

---

### 4. 其他常用参数

#### `--env` 参数
设置环境变量，可重复使用。

```bash
claude mcp add --transport stdio --env API_KEY=abc123 --env DEBUG=true myserver -- python server.py
```

#### `--header` 参数
为 HTTP 服务器添加认证头。

```bash
claude mcp add --transport http api --header "Authorization: Bearer token" https://api.example.com/mcp
```

---

## 实际配置示例

### 示例 1：Serena 服务器（代码导航和分析）

```bash
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context claude-code --project "$(pwd)"
```

**分解说明：**
- `claude mcp add` - 添加 MCP 服务器
- `serena` - 服务器名称
- `--` - 分隔符
- `uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context claude-code --project "$(pwd)"` - 完整命令
  - `uvx` - 运行 uv 工具
  - `--from git+https://...` - 从 Git 仓库安装
  - `serena start-mcp-server` - 启动 Serena MCP 服务器
  - `--context claude-code` - 传递给 Serena 的参数
  - `--project "$(pwd)"` - 当前项目路径

**配置特点：**
- 作用域：`local`（默认，仅当前项目）
- 传输方式：`stdio`（默认，本地进程）

---

### 示例 2：Codex 服务器（AI 辅助编码）

```bash
claude mcp add codex -s user --transport stdio -- uvx --from git+https://github.com/GuDaStudio/codexmcp.git codexmcp
```

**分解说明：**
- `claude mcp add` - 添加 MCP 服务器
- `codex` - 服务器名称
- `-s user` - 用户作用域（跨所有项目）
- `--transport stdio` - 本地进程传输
- `--` - 分隔符
- `uvx --from git+https://github.com/GuDaStudio/codexmcp.git codexmcp` - 完整命令

**配置特点：**
- 作用域：`user`（全局可用）
- 传输方式：`stdio`（本地进程）

---

## 配置不同类型的 MCP 服务器

### 类型 1：HTTP 远程服务器

```bash
# 基础 HTTP 服务器
claude mcp add notion --transport http https://mcp.notion.com/mcp

# 带认证的 HTTP 服务器
claude mcp add github --transport http https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer your-token"

# 项目作用域（团队共享）
claude mcp add sentry -s project --transport http https://mcp.sentry.dev/mcp
```

### 类型 2：Stdio 本地服务器

```bash
# 基础 stdio 服务器
claude mcp add airtable --transport stdio -- npx -y airtable-mcp-server

# 带环境变量的 stdio 服务器
claude mcp add database --transport stdio \
  --env DB_URL="postgresql://user:pass@localhost/db" \
  -- npx -y @bytebase/dbhub

# Python 脚本服务器
claude mcp add custom --transport stdio -- python /path/to/server.py --config config.json

# Windows 上的 stdio 服务器（需要 cmd /c 包装）
claude mcp add my-server --transport stdio -- cmd /c npx -y @some/package
```

### 类型 3：SSE 远程服务器（已弃用）

```bash
# 基础 SSE 服务器
claude mcp add asana --transport sse https://mcp.asana.com/sse

# 带认证的 SSE 服务器
claude mcp add private-api --transport sse https://api.company.com/sse \
  --header "X-API-Key: your-key-here"
```

---

## 管理 MCP 服务器

```bash
# 列出所有配置的服务器
claude mcp list

# 获取特定服务器的详情
claude mcp get <name>

# 移除服务器
claude mcp remove <name>

# 在 Claude Code 中检查服务器状态
/mcp

# 重置项目作用域的选择
claude mcp reset-project-choices
```

---

## 关键要点总结

1. **参数顺序很重要** - 所有选项必须在服务器名称之前，`--` 之后的内容传递给服务器
2. **作用域决定可访问性** - `local`（默认）仅当前项目，`project` 团队共享，`user` 跨项目
3. **传输类型选择** - `http` 用于云服务，`stdio` 用于本地工具
4. **环境变量和认证** - 使用 `--env` 和 `--header` 传递敏感信息
5. **Windows 特殊处理** - Stdio 服务器需要 `cmd /c` 包装

## 配置文件位置

- **Local/User**: `~/.claude.json`
- **Project**: `.mcp.json`（可提交到版本控制）

---

## 常见问题

### Q: 如何选择合适的作用域？

- **local**：个人实验、包含敏感信息的配置
- **project**：团队协作、需要版本控制的配置
- **user**：跨项目使用的通用工具

### Q: HTTP 和 stdio 有什么区别？

- **HTTP**：连接到远程服务器，适合云服务
- **stdio**：启动本地进程，适合本地工具和脚本

### Q: 如何传递环境变量？

使用 `--env` 参数，可以多次使用：

```bash
claude mcp add myserver --transport stdio \
  --env API_KEY=abc123 \
  --env DEBUG=true \
  -- python server.py
```

### Q: 如何为 HTTP 服务器添加认证？

使用 `--header` 参数：

```bash
claude mcp add api --transport http https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```
