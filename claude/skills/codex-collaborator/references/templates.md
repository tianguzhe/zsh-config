# PROMPT 模板库

## 使用说明

1. **选择场景**：根据任务类型选择对应模板
2. **填写字段**：优先填写 `Minimal`（必填），按需补充 `Optional`（增强）
3. **粘贴约束**：将【通用约束片段】粘贴到模板的约束处
4. **保持只读**：确保 `sandbox="read-only"`

---

## 通用约束片段

> 手动粘贴到每个模板的 `## 约束` 部分

```markdown
## 安全约束
- 仅提供分析/建议/unified diff，**不要实际创建或修改文件**
- `sandbox="read-only"`，禁止任何写入命令或脚本
- 不要执行 rm、mv、cat >、echo >、touch、mkdir 等写操作
```

---

## 占位符说明

| 占位符 | 说明 | 示例 |
|--------|------|------|
| `{{PROJECT_PATH}}` | 项目根目录 | `/Users/dev/MyApp` |
| `{{SESSION_ID}}` | 会话 ID（首次留空） | `019aabca-a9f3-...` |
| `{{REQUIREMENTS}}` | 需求描述/验收标准 | 支持文本和图片分享 |
| `{{CONTEXT_FILES}}` | 相关文件/架构信息 | `src/share/`, MVVM + Hilt |
| `{{RISKS}}` | 已知风险/关注点 | 大文件性能、权限兼容 |
| `{{TEST_PLAN}}` | 测试策略/结果 | 单元测试 8/8 通过 |

---

## 阶段 A：需求分析模板

**Minimal**：`{{PROJECT_PATH}}`, `{{REQUIREMENTS}}`（目标与验收）, 现有架构/技术栈
**Optional**：`{{CONTEXT_FILES}}`, `{{RISKS}}`, 依赖/集成点

```markdown
## 背景
项目：{{PROJECT_PATH}}
SESSION_ID：{{SESSION_ID}}  <!-- 首次调用留空，记录返回值 -->
架构/技术栈：[例如 Kotlin + MVVM + Hilt + Compose]

## 需求
{{REQUIREMENTS}}

## 初步思路
[你对实现方案的初步理解]

## 请求
请帮我：
1. 完善需求分析，指出遗漏的场景和边界条件
2. 优化实施计划，建议具体的实现步骤（按 A→B→C→D 阶段）
3. 识别潜在风险和依赖
4. 提醒我应该质疑的关键点

{{RISKS}}  <!-- 如有已知风险，列在此处 -->

## 安全约束
- 仅提供分析/建议，**不要实际创建或修改文件**
- `sandbox="read-only"`，禁止任何写入命令或脚本
```

---

## 阶段 B：原型获取模板

**Minimal**：`{{PROJECT_PATH}}`, `{{SESSION_ID}}`, `{{REQUIREMENTS}}`（确认的需求）
**Optional**：`{{CONTEXT_FILES}}`, `{{RISKS}}`, 测试策略

```markdown
## 任务
基于阶段 A 的需求分析，请生成代码实现原型。

## 背景
项目：{{PROJECT_PATH}}
SESSION_ID：{{SESSION_ID}}
架构/技术栈：{{CONTEXT_FILES}}

## 确认的需求
{{REQUIREMENTS}}

## 要求
- **仅输出 unified diff patch 格式**
- **不要实际创建或修改文件**
- 为每个关键设计决策提供说明
- 指出需要补充的测试用例
- 列出需要更新的配置文件（如有）

## 输出格式示例
    diff --git a/path/to/file.kt b/path/to/file.kt
    new file mode 100644
    --- /dev/null
    +++ b/path/to/file.kt
    @@ -0,0 +1,XX @@
    +[代码内容]

## 安全约束
- **仅输出 unified diff patch 格式**
- `sandbox="read-only"`，禁止任何写入命令或脚本
- 不要执行任何命令，不要生成可执行脚本
```

---

## 阶段 D：代码审查模板

**Minimal**：`{{PROJECT_PATH}}`, `{{SESSION_ID}}`, 最终 diff/文件列表, `{{REQUIREMENTS}}`（验收清单）, `{{TEST_PLAN}}`
**Optional**：与原型偏差、`{{RISKS}}`（关注点）

```markdown
## 审查请求
请审查以下代码改动和需求完成情况。

## 背景
项目：{{PROJECT_PATH}}
SESSION_ID：{{SESSION_ID}}

## 变更材料
- **Diff/文件**：{{CONTEXT_FILES}}
- **需求/验收**：{{REQUIREMENTS}}
- **测试结果**：{{TEST_PLAN}}
- **与原型偏差**（如有）：
  1. [偏差描述] - 原因：[说明]

## 审查维度
1. **功能正确性**：代码是否正确实现了所有需求？
2. **需求覆盖**：是否有遗漏的需求或边界情况？
3. **代码质量**：是否符合项目规范和最佳实践？
4. **潜在风险**：是否存在安全、性能或可维护性问题？
5. **测试充分性**：需要补充哪些测试用例？

## 输出格式
请按以下结构输出审查报告：
- 功能正确性：✓/⚠️/✗ + 说明
- 需求覆盖：✓/⚠️ + 遗漏项
- 代码质量：评分 + 改进建议
- 潜在风险：按优先级列出
- 测试建议：需补充的测试用例

## 安全约束
- 仅提供审查意见，**不要实际修改文件**
- `sandbox="read-only"`，禁止任何写入命令或脚本
```

---

## 场景模板：新功能开发（Feature）

适用于：新功能模块、业务逻辑实现

**Minimal**：`{{PROJECT_PATH}}`, `{{REQUIREMENTS}}`（目标与验收）, 现有架构/技术栈
**Optional**：`{{CONTEXT_FILES}}`, `{{RISKS}}`, 依赖/集成点, 测试策略

```markdown
## 背景
项目：{{PROJECT_PATH}}
SESSION_ID：{{SESSION_ID}}
架构/技术栈：{{CONTEXT_FILES}}

## 功能需求
{{REQUIREMENTS}}

## 请求
请帮我：
1. 补全需求边界和验收标准
2. 设计实现方案（组件划分、数据流、接口定义）
3. 制定分阶段计划（A/B/C/D）
4. 识别风险与测试建议

{{RISKS}}

## 安全约束
- 仅提供分析/建议，**不要实际创建或修改文件**
- `sandbox="read-only"`，禁止任何写入命令或脚本
```

---

## 场景模板：Bug 修复（Bugfix）

适用于：问题定位、修复方案设计

**Minimal**：`{{PROJECT_PATH}}`, 问题描述与重现步骤, 期望行为
**Optional**：`{{SESSION_ID}}`, `{{CONTEXT_FILES}}`（涉及文件/日志）, 已尝试方案, 影响面

```markdown
## 问题描述
{{REQUIREMENTS}}  <!-- 现象、重现步骤、期望行为 -->

## 上下文
项目：{{PROJECT_PATH}}
SESSION_ID：{{SESSION_ID}}
涉及文件/位置：{{CONTEXT_FILES}}
已知风险：{{RISKS}}

## 请求
1. 补全遗漏场景/边界条件
2. 建议最小修复方案（避免过度改动）
3. 列出需要的测试用例
4. 标注潜在回归点

## 安全约束
- 仅提供分析/建议，**不要实际创建或修改文件**
- `sandbox="read-only"`，禁止任何写入命令或脚本
```

---

## 场景模板：代码重构（Refactor）

适用于：架构优化、技术债清理、性能改进

**Minimal**：`{{PROJECT_PATH}}`, 重构目标与成功标准
**Optional**：`{{SESSION_ID}}`, `{{CONTEXT_FILES}}`（当前结构/痛点）, `{{RISKS}}`（回归点/性能）

```markdown
## 重构目标
{{REQUIREMENTS}}  <!-- 目的：可维护性/性能/解耦等，成功标准 -->

## 现状
项目：{{PROJECT_PATH}}
SESSION_ID：{{SESSION_ID}}
痛点/文件：{{CONTEXT_FILES}}
风险/约束：{{RISKS}}

## 请求
1. 提出可行重构方案与分步计划
2. 标注风险与回退策略
3. 建议必要测试/基准（确保不引入回归）
4. 评估改动范围和影响

## 安全约束
- 仅提供分析/建议，**不要实际创建或修改文件**
- `sandbox="read-only"`，禁止任何写入命令或脚本
```

---

## 快速参考：字段必填性

| 模板 | Minimal（必填） | Optional（增强） |
|------|----------------|-----------------|
| 阶段 A | PROJECT_PATH, REQUIREMENTS, 架构 | CONTEXT_FILES, RISKS |
| 阶段 B | PROJECT_PATH, SESSION_ID, REQUIREMENTS | CONTEXT_FILES, RISKS |
| 阶段 D | PROJECT_PATH, SESSION_ID, diff, REQUIREMENTS, TEST_PLAN | 偏差说明, RISKS |
| Feature | PROJECT_PATH, REQUIREMENTS, 架构 | CONTEXT_FILES, RISKS |
| Bugfix | PROJECT_PATH, 问题描述, 期望行为 | SESSION_ID, CONTEXT_FILES |
| Refactor | PROJECT_PATH, 重构目标 | SESSION_ID, CONTEXT_FILES, RISKS |

---

## 注意事项

1. **SESSION_ID 管理**：首次调用后立即记录返回的 SESSION_ID，后续调用复用
2. **上下文充分性**：如需求有不确定性，至少补充相关文件路径/接口描述
3. **格式验证**：阶段 B 收到回复后，检查是否为标准 unified diff 格式
4. **安全检查**：拒收包含写入命令的输出，要求 Codex 修正
