# Serena MCP 工具参考

## 符号查找与分析

### jet_brains_find_symbol

按 name_path 模式查找符号定义。支持模糊匹配和精确路径。

```
参数：
- name_path_pattern (string, 必需): 匹配模式
  - 简单名称: "MyClass" → 匹配任何同名符号
  - 相对路径: "MyClass/myMethod" → 匹配路径后缀
  - 绝对路径: "/MyClass/myMethod" → 精确匹配
  - 重载索引: "MyClass/myMethod[0]" → 匹配特定重载
- relative_path (string, 可选): 限定搜索范围（文件或目录）
- include_body (bool, 默认 false): 包含源代码
- include_info (bool, 默认 false): 包含悬停信息（签名、文档）
- depth (int, 默认 0): 子符号深度（1 = 类的方法列表）
- search_deps (bool, 默认 false): 搜索项目依赖
- max_matches (int, 默认 -1): 最大匹配数（1 = 精确查找）
```

### jet_brains_find_referencing_symbols

查找引用指定符号的所有位置。

```
参数：
- name_path (string, 必需): 被引用符号的 name_path
- relative_path (string, 必需): 符号所在文件路径（必须是文件，不能是目录）
```

### jet_brains_get_symbols_overview

获取文件的顶层符号概览，按类型分组。适合快速了解文件结构。

```
参数：
- relative_path (string, 必需): 文件路径
- depth (int, 默认 0): 子符号深度
- include_file_documentation (bool, 默认 false): 包含文件级文档
```

### jet_brains_type_hierarchy

获取类型的继承层次关系。

```
参数：
- name_path (string, 必需): 符号的 name_path
- relative_path (string, 必需): 符号所在文件
- hierarchy_type (enum, 默认 "both"): "super" | "sub" | "both"
- depth (int, 默认 1): 层次深度（0 = 无限）
```

## 搜索工具

### search_for_pattern

正则表达式搜索，支持代码和非代码文件。比 grep 更灵活。

```
参数：
- substring_pattern (string, 必需): 正则表达式（DOTALL 模式，. 匹配换行符）
- relative_path (string, 可选): 限定搜索目录/文件
- paths_include_glob (string, 可选): 包含文件 glob（如 "*.kt"）
- paths_exclude_glob (string, 可选): 排除文件 glob（如 "*test*"）
- restrict_search_to_code_files (bool, 默认 false): 仅搜索代码文件
- context_lines_before/after (int, 默认 0): 上下文行数

注意：避免在模式开头/末尾使用 .*，用非贪婪 .*? 避免过度匹配
```

### find_file

按文件名/通配符查找文件。

```
参数：
- file_mask (string, 必需): 文件名或通配符（如 "*.kt", "Build*.kts"）
- relative_path (string, 必需): 搜索起始目录（"." = 项目根）
```

## 写入工具

### insert_after_symbol / insert_before_symbol

在符号定义的前/后插入代码。

```
参数：
- name_path (string, 必需): 参照符号的 name_path
- relative_path (string, 必需): 符号所在文件
- body (string, 必需): 要插入的代码内容
```

### rename_symbol

全局重命名符号（跨整个代码库）。

```
参数：
- name_path (string, 必需): 要重命名的符号
- relative_path (string, 必需): 符号所在文件
- new_name (string, 必需): 新名称
```

## 使用示例

### 查找 ViewModel 类及其方法

```
工具: jet_brains_find_symbol
参数: { "name_path_pattern": "HomeViewModel", "depth": 1 }
→ 返回类定义及所有方法列表
```

### 查看方法实现

```
工具: jet_brains_find_symbol
参数: {
  "name_path_pattern": "HomeViewModel/loadData",
  "include_body": true,
  "max_matches": 1
}
```

### 查找接口的所有实现

```
工具: jet_brains_type_hierarchy
参数: {
  "name_path": "InitTask",
  "relative_path": "module_proxy/src/.../InitTask.kt",
  "hierarchy_type": "sub"
}
```

### 在配置文件中搜索

```
工具: search_for_pattern
参数: {
  "substring_pattern": "base_url",
  "paths_include_glob": "*.{json,properties,toml}"
}
```
