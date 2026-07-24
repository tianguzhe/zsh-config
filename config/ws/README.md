# ws 搜索工具配置

## 安装

源码：[ws-search](https://github.com/tianguzhe/ws-search)，需要 Rust 工具链编译：

```bash
cargo build --release
cp target/release/ws ~/.local/bin/
```

## 配置文件

`config.toml` 放在 `~/.config/ws/config.toml`，`setup.sh` 会自动复制。

## 用法

```bash
ws google rust            # 位置参数
ws google -q rust         # -q 标志
ws google -q "rust async" # 多词搜索
ws --list                 # 列出所有别名
ws --help                 # 帮助信息
```

## 已配置别名

| 别名 | 网站 |
|------|------|
| google | Google |
| bing | Bing |
| baidu | 百度 |
| gh | GitHub |
| maven | Maven Repository |
| npm | npmx.dev |
| crates | crates.io |
| docker | Docker Hub |

## 添加新别名

编辑 `config.toml`，格式：

```toml
[aliases]
别名 = "https://example.com/search?q="
```

URL 末尾的 `?q=` 会被搜索词替换。
