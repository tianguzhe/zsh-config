# /backup/cleanup — 备份清理

清理由 `/backup/create` 命令产生的备份文件，释放空间并保持目录整洁。

## 需求

1. 根据 `$ARGUMENTS` 指定的原文件，查找同目录下匹配的备份文件
2. 备份文件格式: `原文件名.backup.YYYYMMDD_HHMMSS.扩展名`
3. 执行前验证：原文件存在、是常规文件、目录可写
4. 列出所有找到的备份文件，请求用户确认后再删除
5. 未找到备份时输出 `ℹ️ 未找到任何备份`
6. 删除成功输出 `✅ 已删除 N 个备份文件`
7. 用户取消时输出 `⚠️ 已取消`

## 安全要求

- 使用 `find` + `-maxdepth 1` 精确匹配,禁止通配符删除
- 删除前验证文件所有权和类型 (`-O` 和 `! -L`)
- 提供 `--dry-run` 模式供用户预览

## 示例

```
/backup/cleanup /path/to/config.json

→ 以下备份将被删除:
    - /path/to/config.backup.20250121_143052.json
    - /path/to/config.backup.20250121_150230.json
  确认删除? (y/N): y
→ ✅ 已删除 2 个备份文件
```