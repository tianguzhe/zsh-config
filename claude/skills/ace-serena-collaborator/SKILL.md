---
name: ace-serena-collaborator
description: |
  Ace-Tool 与 Serena MCP 协作流程，用于代码库理解、导航和编辑。触发场景：(1) 需要理解代码库结构或架构 (2) 语义代码搜索（"这个功能是怎么实现的"） (3) 符号级代码定位和引用追踪 (4) 代码导航和依赖分析 (5) 基于符号的代码插入或重命名重构。即使用户没有明确提到这两个工具，只要涉及代码探索、符号查找、引用追踪、类型层次分析、或需要理解大型代码库中某个功能的实现方式，都应考虑使用此 skill。
---

# Ace-Tool & Serena 协作指南

Ace-Tool 和 Serena 是两个互补的 MCP 工具。Ace-Tool 擅长"从模糊到具体"的语义发现，Serena 擅长"从具体到精确"的符号级操作。两者结合形成 **语义发现 → 精确操作** 的完整工作流。

## 何时使用 MCP 工具 vs 内置工具

Claude Code 自带 Grep、Glob、Read 等工具，很多场景已经够用。MCP 工具的价值在于它们能做到内置工具做不到的事：

| 场景 | 推荐工具 | 原因 |
|------|----------|------|
| 知道关键词，想找所有出现位置 | **Grep** | 精确文本匹配，内置工具最快 |
| 知道文件名模式 | **Glob** | 文件查找，内置工具最快 |
| 知道文件路径，想读内容 | **Read** | 直接读取，无需中间步骤 |
| 不知道代码在哪，用自然语言描述功能 | **Ace-Tool** | 语义搜索理解意图，跨文件关联 |
| 知道符号名，想看定义+子符号+文档 | **Serena** | LSP 级别的符号理解，比 Grep 更结构化 |
| 想看谁引用了某个类/方法 | **Serena** | `find_referencing_symbols` 比 Grep 更准确（排除注释、字符串中的同名文本） |
| 想看继承/实现关系 | **Serena** | `type_hierarchy` 提供完整的类型树，Grep 做不到 |
| 需要在符号旁插入代码 | **Serena** | 基于 LSP 定位，不用手动算行号 |
| 需要跨文件重命名 | **Serena** | `rename_symbol` 语义级重命名，比文本替换安全 |

**简单规则**：知道"找什么"用内置工具，知道"要什么但不知道在哪"用 Ace-Tool，需要"符号级理解或操作"用 Serena。

## 工具速查

### Ace-Tool

| 工具 | 用途 |
|------|------|
| `search_context` | 语义代码搜索（主力），自然语言 → 相关代码片段 |
| `enhance_prompt` | 增强 prompt（仅在用户使用 `-enhance` 标记时调用） |

### Serena — 查询

| 工具 | 用途 |
|------|------|
| `jet_brains_find_symbol` | 按 name_path 模式查找符号定义（支持模糊/精确匹配） |
| `jet_brains_find_referencing_symbols` | 查找引用某符号的所有位置 |
| `jet_brains_get_symbols_overview` | 获取文件的顶层符号概览（了解结构用） |
| `jet_brains_type_hierarchy` | 获取类型继承层次（super/sub/both） |
| `search_for_pattern` | 正则模式搜索（支持非代码文件） |
| `find_file` | 按文件名/通配符查找文件 |
| `list_dir` | 列出目录内容 |

### Serena — 写入

| 工具 | 用途 |
|------|------|
| `insert_after_symbol` | 在符号定义之后插入代码 |
| `insert_before_symbol` | 在符号定义之前插入代码 |
| `rename_symbol` | 全局重命名符号（跨整个代码库） |

> 写入操作基于 LSP 的符号理解，比文本替换更安全。适合添加新方法/字段或跨文件重命名。

详细参数见 [references/serena-tools.md](references/serena-tools.md)

## 协作流程

### 场景 1：探索未知代码

用户问"某个功能是怎么实现的"，但你不确定代码位置：

```
用户："网络请求的重试机制是怎么实现的？"

1. Ace-Tool search_context
   → query: "网络请求重试机制实现 Keywords: retry, interceptor, ktor"
   → 获取相关文件和代码片段

2. Serena get_symbols_overview（可选）
   → 对关键文件获取符号概览，快速了解结构

3. Serena find_symbol（可选）
   → include_body=true 读取关键符号的实现
```

### 场景 2：定位已知符号及其引用

用户提到了具体类名/方法名：

```
用户："找到 NetConnectManager 的所有使用位置"

1. Serena find_symbol → 定位定义
2. Serena find_referencing_symbols → 获取所有引用位置
```

### 场景 3：理解类型层次

需要了解继承关系或接口实现：

```
用户："有哪些类实现了 InitTask 接口？"

1. Serena find_symbol → 定位接口定义
2. Serena type_hierarchy (hierarchy_type="sub") → 获取所有实现类
```

### 场景 4：基于符号的精确编辑

需要在特定位置插入代码或重命名：

```
用户："在 AppModule 中添加一个新的 Koin module"

1. Serena find_symbol (include_body=true) → 了解现有结构
2. Serena insert_after_symbol → 在合适位置插入
```

## 工具选择决策树

```
你的目标？
│
├── 探索/理解代码
│   ├── 不知道在哪 → Ace-Tool search_context
│   ├── 知道文件，想了解结构 → Serena get_symbols_overview
│   ├── 知道符号名，想看实现 → Serena find_symbol (include_body=true)
│   ├── 想看谁引用了某符号 → Serena find_referencing_symbols
│   └── 想看继承/实现关系 → Serena type_hierarchy
│
├── 搜索代码
│   ├── 知道关键词文本 → Grep（内置，更快）
│   ├── 自然语言描述功能 → Ace-Tool search_context
│   ├── 正则 + 非代码文件 → Serena search_for_pattern
│   └── 查找文件 → Glob（内置）或 Serena find_file
│
└── 编辑代码
    ├── 在符号旁插入新代码 → Serena insert_before/after_symbol
    ├── 全局重命名 → Serena rename_symbol
    └── 其他修改 → Edit/Write（内置）
```

## 高效使用技巧

1. **先广后深** — 不确定位置时，先 Ace-Tool 语义搜索缩小范围，再 Serena 精确定位
2. **概览优先于全文** — 用 `get_symbols_overview` 了解文件结构，避免读取整个大文件
3. **善用 name_path 模式** — `find_symbol` 支持 `Class/method` 路径，直接定位嵌套符号
4. **search_for_pattern 用于非代码** — 配置文件（yaml/json/properties）的搜索用它
5. **符号写入优先** — 插入代码时优先用 `insert_after/before_symbol`，比手算行号可靠

## 常见误用

- **用 Ace-Tool 搜精确字符串** — 如果你知道确切的类名或方法名，直接用 Grep 或 Serena find_symbol 更快
- **用 Serena 做探索性搜索** — 如果你不知道要找什么符号，Serena 帮不上忙，先用 Ace-Tool
- **忘记 relative_path** — `find_referencing_symbols` 的 `relative_path` 是必需参数，必须先用 `find_symbol` 定位文件
- **对大文件直接 find_symbol + include_body** — 先用 `get_symbols_overview` 确认目标，再精确读取
