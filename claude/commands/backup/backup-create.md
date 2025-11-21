# /backup/create — 单文件备份

将目标文件复制到相同目录下并附带时间戳，便于快速追踪备份。

## 需求

1. 将 `$ARGUMENTS` 指定的文件备份到同目录下
2. 备份文件命名格式: `原文件名.backup.YYYYMMDD_HHMMSS.扩展名`
3. 执行前验证：文件存在、是常规文件、可读、目录可写
4. 备份成功输出 `✅ 备份成功: <绝对路径>`
5. 失败时输出 `❌ <具体原因>`

## 安全要求

- 实现必须使用 `cp -- "$src" "$dst"` 完整引用参数
- 拒绝操作符号链接 (使用 `[ -L "$file" ]` 检测)
- 使用原子性操作: 先拷贝到 .tmp 再 rename

## 示例

```
/backup/create /path/to/config.json
→ ✅ 备份成功: /path/to/config.backup.20250121_143052.json

/backup/create /path/to/Makefile
→ ✅ 备份成功: /path/to/Makefile.backup.20250121_143105
```