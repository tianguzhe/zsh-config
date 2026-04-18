---
name: android-dp-adapter
description: 为 Android 项目生成多屏幕适配的 dimens.xml（sw 限定符方案）。触发场景：(1) 用户提到"dp 适配"、"屏幕适配"、"多分辨率适配"、"values-sw"；(2) 开发初期要生成一份 base dimens（默认 -20..200）供布局引用；(3) 开发过程中要临时加几个 dimen 值（如 332、500、0.5）到 base 文件；(4) 开发完成后按设计稿基准宽度（如 375dp）批量生成 320/360/411/480/600dp 等 sw 桶；(5) 需要生成 dp_16、dp_0_5、dp__4 这类命名的 dimen。即使用户没明说"skill"，只要涉及"生成 base dimens"、"加几个 dp 值"或"生成不同屏宽 dimens"都应触发。
---

# Android dp 适配 dimens 生成器

## 背景

Android 设计稿通常按单一基准宽度（如 375dp）标注。真实设备 sw 从 320dp 到 600+dp，直接用原始 dp 在小屏挤、大屏空。

业界方案：**sw 限定符 + 多份 dimens.xml**。布局只写 `@dimen/dp_20`，系统按设备 sw 自动选桶——base 文件（`values/dimens.xml`）里 `dp_20 = 20dp`，sw600 桶里 `dp_20 = 32dp`（= 20 × 600/375）。

原理、命名约定、局限见 `references/adaptation-guide.md`。

## 核心原则

**`values/dimens.xml` 是唯一的真源**。所有 sw 桶都从它派生：
- 开发期：只维护 base 文件。增删 dp 值都改它。
- 发布期：运行脚本的"sync 模式"，读 base → 按比例生成所有 sw 桶。

**因此"sync sw 桶"时不需要（也不该）再传 `--start`/`--end`/`--extra`** ——那会让 base 和 sw 桶内容不一致。

## 两阶段工作流

### 阶段一：开发期 — 初始化/维护 base

**首次生成**（默认 -20..200）：

```bash
python3 ~/.claude/skills/android-dp-adapter/scripts/generate_dimens.py \
  --base 375 \
  --output app/src/main/res \
  --default-only
```

> macOS / 新版 Linux 发行版默认 `python` 不可用，必须用 `python3`。若执行 `python` 报 `command not found`，换成 `python3` 即可。

产出：`app/src/main/res/values/dimens.xml`，包含 `dp__20..dp__1`、`dp_0`、`dp_1..dp_200` 共 221 个条目。

**后续加临时值**（如设计给了 332、500，或 0.5dp 细边）：

```bash
python3 .../generate_dimens.py \
  --base 375 --output app/src/main/res --default-only \
  --extra 332,500,0.5
```

⚠️ **`--default-only` 每次全量覆盖 `values/dimens.xml`**。`--extra` 要带全**所有历史新增值**，否则之前加的会丢。建议用户把 extras 列表记在项目 README 或一个 txt 里。

（如果需要更改连续区间，加 `--start` / `--end`；不传走默认 `-20..200`。）

### 阶段二：开发完成 — 生成 sw 桶

```bash
python3 .../generate_dimens.py \
  --base 375 \
  --output app/src/main/res \
  --targets 320,360,375,392,411,420,480,600
```

脚本会：
1. 读取 `app/src/main/res/values/dimens.xml`（必须已存在）
2. 删除 `app/src/main/res/` 下**所有** `values-sw*dp/` 目录（清理旧桶）
3. 为每个 target 生成 `values-sw<N>dp/dimens.xml`，dimen 列表与 base 完全一致，值按 `N/base` 比例缩放

这样无论 base 有哪些新增的 332、500 之类，sw 桶自动同步，**不会漏、不会脏**。

## 参数速查

| 参数 | 说明 | 阶段一 | 阶段二 |
|------|------|--------|--------|
| `--base` | 设计稿基准宽度 | 必填 | 必填 |
| `--output` | res 根目录（如 `app/src/main/res`） | 必填 | 必填 |
| `--default-only` | 初始化/重写 `values/dimens.xml` | ✅ | ❌（互斥） |
| `--targets` | sw 桶列表，逗号分隔 | ❌（互斥） | 必填 |
| `--start --end` | 连续 dp 区间（默认 -20..200） | 可选 | 忽略 |
| `--extra` | 额外离散值（含小数/负数） | 可选 | 忽略 |
| `--decimals` | 小数位（默认 1） | ✅ | ✅ |
| `--prefix` | 前缀（默认 `dp`） | ✅ | ✅ |

`--default-only` 和 `--targets` 互斥——脚本会报错提醒，防止误用。

**命名约定**：`20 → dp_20`，`0.5 → dp_0_5`，`-4 → dp__4`（双下划线表负）。XML 禁 `-` 与 `.`，统一规则让 `R.dimen.dp_0_5` 在 Kotlin 侧可直接引用。

## 辨认用户意图

| 用户话术 | 对应模式 |
|---------|---------|
| "先生成 dimens"、"初始化"、"先来一份 base" | 阶段一无 `--extra` |
| "加个 332"、"把 0.5 补上"、"临时加几个" | 阶段一带 `--extra`（含所有历史值） |
| "生成不同屏宽"、"开发完了"、"补 sw 桶"、"出各分辨率" | 阶段二 |

不确定就问："这次是改 base 文件、还是把 sw 桶同步出来？"

## 避坑

- **阶段二前必须先跑过阶段一**——base 文件不存在脚本会报错。
- **阶段二会删掉旧 sw 桶**：如果项目在 `values-sw<N>dp/` 下放了其他资源（如 sw 专属的 `strings.xml`），同目录的 `dimens.xml` 会连同整个桶目录一起被删。提醒用户：本 skill 假设 `values-sw*dp/` 目录是**由本脚本完全管辖**。若用户有其他 sw 专属资源，让他们先确认迁移或隔离。
- **`--extra` 只在阶段一有效**：阶段二忽略，避免两份清单不同步。
- **字体用 sp** 不要用本方案——字体应遵循无障碍设置。
- **保留 `values/dimens.xml`**：阶段二不会动它，它是最终兜底（服务于未命中任何 sw 桶的设备）。