# Serena MCP Server

Serena MCP Server 的安装与配置指南。该插件并非独立的 MCP Server，而是 Serena MCP Server 的代码智能后端，需要同时安装插件和 Serena MCP Server 才能使用。

## 添加 MCP Server

```bash
claude mcp add serena -- uvx --python 3.13 \
  --from git+https://github.com/oraios/serena \
  serena start-mcp-server --context claude-code --project "$(pwd)"
```

## 快速开始

1. 安装 JetBrains 插件，按照 [Serena Client Connection Guide](https://github.com/oraios/serena) 连接 Serena MCP 到你的客户端
2. 编辑全局 Serena 配置文件：
   - macOS / Linux: `~/.serena/serena_config.yml`
   - Windows: `%USERPROFILE%\.serena\serena_config.yml`

   > 如果从未启动过 Serena MCP Server，配置文件可能尚不存在，先运行以下命令生成：

   ```bash
   uvx -p 3.13 --from git+https://github.com/oraios/serena serena config edit
   ```

3. 将 `language_backend` 设置修改为：

   ```yaml
   language_backend: JetBrains
   ```

   此配置让 Serena 使用已打开的 IDE 实例作为后端，以启用更多高级功能。

## 参考

- [Serena MCP Server 文档](https://github.com/oraios/serena)
- [JetBrains 插件说明](https://github.com/oraios/serena#jetbrains)
