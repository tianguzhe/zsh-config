# Codex Collaborator - 使用示例

本文档提供了 codex-collaborator Skill 的完整使用示例，展示四阶段协作流程的实际应用。

---

## 示例 1：为 Android 应用添加分享功能（完整流程）

### 用户请求

> "为应用添加一个分享功能，用户可以分享文本和图片到其他应用"

### Claude 的响应流程

#### 第 1 步：启动协作流程

```markdown
我将使用 Codex 协作流程来实现这个分享功能。这是一个复杂的功能，
需要 UI 组件、ViewModel、数据处理和系统集成，适合使用完整的四阶段流程。

让我创建 Todo 来跟踪进度...
```

**TodoWrite 创建**：
```
☐ 阶段 A：需求分析
☐ 阶段 B：原型获取（unified diff）
☐ 阶段 C：代码实现
☐ 阶段 D：审查复盘
```

---

#### 第 2 步：阶段 A - 需求分析

**Claude 的分析**：
```markdown
## 我对需求的理解

**功能需求**：
- 支持分享文本内容
- 支持分享图片（单张或多张）
- 使用 Android 系统的 Share Sheet
- 支持自定义分享文本

**技术约束**：
- 项目使用 MVVM + Hilt 架构
- UI 使用 Jetpack Compose
- 需要处理图片的临时存储（FileProvider）
- 需要考虑权限问题

**初步思路**：
1. 创建 ShareViewModel 处理分享逻辑
2. 创建 ShareRepository 封装分享操作
3. 使用 Intent.ACTION_SEND/ACTION_SEND_MULTIPLE
4. 配置 FileProvider 用于图片分享

现在让我调用 Codex 来完善这个需求分析...
```

**调用 Codex**（mcp__codex__codex）：
```
PROMPT:
## 需求分析
用户要求为 Android 应用添加分享功能。

## 我的理解
- 支持文本和图片分享
- 使用系统 Share Sheet
- MVVM + Hilt 架构
- Jetpack Compose UI

## 初步思路
1. ShareViewModel + ShareRepository
2. Intent.ACTION_SEND/SEND_MULTIPLE
3. FileProvider 配置

## 请求
请帮我：
1. 完善需求分析，指出遗漏的场景和边界条件
2. 优化实施计划
3. 识别潜在风险
4. 提醒我应该质疑的关键点

注意：你只需要给出分析和建议，不要进行任何代码修改。

cd: /Users/yikwing/AndroidStudioProjects/ykmagic
sandbox: "read-only"
```

**Codex 回复摘要**（假设）：
```
SESSION_ID: 019aabca-a9f3-7783-8343-3deca9526275

需求补充：
1. 考虑离线场景：图片应该缓存到本地
2. 错误处理：分享失败时的用户提示
3. 日志记录：分享成功/失败的统计
4. 配置：AndroidManifest.xml 需要添加 FileProvider 配置

实施计划：
- 阶段 A：需求确认 ✓
- 阶段 B：生成包含 ViewModel、Repository、FileProvider 配置的原型
- 阶段 C：实现并测试
- 阶段 D：审查功能完整性和边界情况

风险：
1. 图片文件过大可能导致分享失败
2. 不同分享目标应用的兼容性
3. Android 版本差异（特别是 Android 7.0+ 的 FileUriExposedException）

应该质疑的点：
- 是否需要支持分享到特定应用（如微信）？
- 图片压缩策略如何确定？
- 分享历史是否需要记录？
```

**批判性质询**：
```markdown
收到 Codex 的分析。现在让我提出批判性质疑：

Q1: "你提到了离线场景的图片缓存，但如果用户清除了应用缓存，
     分享功能是否会失败？是否需要更持久的存储方案？"

Q2: "关于 Android 版本差异，你提到了 FileUriExposedException，
     但是否也需要考虑 Android 10+ 的 Scoped Storage 限制？"

Q3: "你建议记录分享日志，这些日志是否需要上报到服务器？
     是否涉及用户隐私问题？"
```

**Codex 继续回答**（使用同一个 SESSION_ID）：
```
针对你的质疑：

A1: 图片缓存确实应该使用 getCacheDir() 的临时文件，
    分享完成后清理。如果需要持久化，应该征得用户同意。
    建议：分享时创建临时副本，分享后删除。

A2: 是的，Android 10+ 需要考虑 Scoped Storage。
    建议使用 MediaStore API 或 FileProvider，确保兼容性。

A3: 日志记录应该只包含操作类型和结果（成功/失败），
    不应该包含分享的具体内容。如需上报，应该匿名化并获得用户同意。
```

**Claude 记录并确认**：
```markdown
## 阶段 A 完成

**SESSION_ID**: 019aabca-a9f3-7783-8343-3deca9526275

**确认的需求**:
1. 支持文本和图片分享（单张/多张）
2. 使用系统 Share Sheet
3. 图片使用临时缓存，分享后清理
4. 兼容 Android 7.0+ (FileProvider) 和 Android 10+ (Scoped Storage)
5. 错误处理和用户提示
6. 匿名化日志记录（不包含内容）

**批判性质询记录**:
- 缓存清理策略 → 使用临时文件
- Scoped Storage 兼容 → 使用 MediaStore/FileProvider
- 隐私保护 → 匿名化日志

**决议**: 进入阶段 B

[TodoWrite 更新: 阶段 A ✓，阶段 B 进行中]
```

---

#### 第 3 步：阶段 B - 原型获取

**调用 Codex 获取原型**：
```
PROMPT:
## 任务
基于阶段 A 的需求分析，请生成代码实现原型。

## 需求回顾
1. 支持文本和图片分享
2. MVVM + Hilt 架构
3. 使用 FileProvider
4. 兼容 Android 7.0+ 和 10+
5. 临时缓存 + 分享后清理

## 技术栈
- Kotlin + Coroutines
- Jetpack Compose
- Hilt 依赖注入
- 项目结构：app/src/main/java/com/yikwing/ykquickdev/

## 要求
- **仅输出 unified diff patch 格式**
- **不要实际创建或修改文件**
- 包含：ViewModel、Repository、FileProvider 配置、Manifest 更新
- 为每个关键设计提供说明
- 指出需要的测试用例

## 安全约束
- sandbox="read-only"
- 只提供 unified diff，不执行任何写操作

请生成 unified diff patch。

cd: /Users/yikwing/AndroidStudioProjects/ykmagic
SESSION_ID: 019aabca-a9f3-7783-8343-3deca9526275
sandbox: "read-only"
```

**Codex 返回的 unified diff**（示例）：
```diff
diff --git a/app/src/main/java/com/yikwing/ykquickdev/share/ShareViewModel.kt b/app/src/main/java/com/yikwing/ykquickdev/share/ShareViewModel.kt
new file mode 100644
index 0000000..1111111
--- /dev/null
+++ b/app/src/main/java/com/yikwing/ykquickdev/share/ShareViewModel.kt
@@ -0,0 +1,45 @@
+package com.yikwing.ykquickdev.share
+
+import androidx.lifecycle.ViewModel
+import androidx.lifecycle.viewModelScope
+import dagger.hilt.android.lifecycle.HiltViewModel
+import kotlinx.coroutines.flow.MutableStateFlow
+import kotlinx.coroutines.flow.StateFlow
+import kotlinx.coroutines.launch
+import javax.inject.Inject
+
+@HiltViewModel
+class ShareViewModel @Inject constructor(
+    private val shareRepository: ShareRepository
+) : ViewModel() {
+
+    private val _shareState = MutableStateFlow<ShareState>(ShareState.Idle)
+    val shareState: StateFlow<ShareState> = _shareState
+
+    fun shareText(text: String) {
+        viewModelScope.launch {
+            _shareState.value = ShareState.Loading
+            shareRepository.shareText(text)
+                .onSuccess {
+                    _shareState.value = ShareState.Success
+                }
+                .onFailure { error ->
+                    _shareState.value = ShareState.Error(error.message)
+                }
+        }
+    }
+
+    fun shareImage(imageUri: Uri) {
+        // ...类似实现
+    }
+}
+
+sealed class ShareState {
+    object Idle : ShareState()
+    object Loading : ShareState()
+    object Success : ShareState()
+    data class Error(val message: String?) : ShareState()
+}

diff --git a/app/src/main/AndroidManifest.xml b/app/src/main/AndroidManifest.xml
index 2222222..3333333
--- a/app/src/main/AndroidManifest.xml
+++ b/app/src/main/AndroidManifest.xml
@@ -20,6 +20,13 @@
+        <provider
+            android:name="androidx.core.content.FileProvider"
+            android:authorities="${applicationId}.fileprovider"
+            android:exported="false"
+            android:grantUriPermissions="true">
+            <meta-data
+                android:name="android.support.FILE_PROVIDER_PATHS"
+                android:resource="@xml/file_paths" />
+        </provider>

... (更多 diff)
```

**Codex 的设计说明**：
```
关键设计决策：
1. ShareViewModel: 使用 StateFlow 管理分享状态（Idle/Loading/Success/Error）
2. ShareRepository: 封装分享逻辑，返回 Result<Unit>
3. FileProvider: 使用 androidx.core.content.FileProvider，authority 为 ${applicationId}.fileprovider
4. 临时文件：存储在 context.cacheDir，分享后在 onActivityResult 中删除

需要的测试：
- ShareViewModel 的状态转换测试
- ShareRepository 的分享成功/失败场景测试
- 临时文件清理测试
```

**批判性质询**：
```markdown
收到原型。现在进行批判性质询：

Q1: "这个 unified diff 中没有看到 file_paths.xml 的内容，
     FileProvider 的路径配置是否完整？"

Q2: "ShareRepository 使用了 Result<Unit>，但在什么情况下会返回 Failure？
     是否需要区分不同类型的失败（如权限拒绝、应用不存在）？"

Q3: "临时文件的清理逻辑是在 onActivityResult 中，但 Compose 环境下如何处理？
     是否需要使用 ActivityResultContracts？"

Q4: "是否需要添加 ViewModel 的单元测试？原型中没有提到测试文件。"
```

**Codex 补充回答**：
```
A1: 你说得对，应该补充 file_paths.xml：
    <paths>
        <cache-path name="shared_images" path="share/" />
    </paths>

A2: 应该区分失败类型，建议使用 sealed class ShareError：
    - NoShareTargetFound: 没有可分享的应用
    - PermissionDenied: 权限被拒绝
    - FileTooLarge: 文件过大
    - Unknown: 其他错误

A3: 在 Compose 中应该使用 rememberLauncherForActivityResult，
    但清理逻辑可以在 ViewModel 的 onCleared() 中处理。

A4: 确实应该添加测试，建议补充 ShareViewModelTest.kt。
```

**Claude 验证格式并归档**：
```markdown
✓ 格式验证：输出为标准 unified diff 格式
✓ 安全检查：无写入命令，无可执行脚本
✓ 完整性：已补充 file_paths.xml 和错误类型

## 阶段 B 完成

**原型已获批**：
- ShareViewModel.kt
- ShareRepository.kt
- ShareState.kt (sealed class)
- ShareError.kt (补充)
- file_paths.xml
- AndroidManifest.xml 更新

**设计说明已记录**

**批判性质询记录**：
- FileProvider 配置 → 已补充 file_paths.xml
- 错误分类 → 使用 sealed class ShareError
- Compose 生命周期 → 使用 rememberLauncherForActivityResult
- 测试用例 → 需要补充 ViewModel 测试

**决议**: 进入阶段 C

[TodoWrite 更新: 阶段 B ✓，阶段 C 进行中]
```

---

#### 第 4 步：阶段 C - 代码实现

**Claude 开始实现**：
```markdown
现在基于原型进行代码实现。

⚠️ 注意：我将原型作为逻辑参考，重写为生产级代码，而不是直接应用 diff。

开始实现 ShareViewModel...
```

**实现记录**：

**步骤 1：创建 ShareError.kt**
```kotlin
// 实现 ShareError sealed class
// ✓ 与原型一致
```

**步骤 2：创建 ShareRepository.kt**
```kotlin
// 实现 ShareRepository
// ⚠️ 偏差：添加了日志记录（使用 Logger）
// 原因：满足需求中的"匿名化日志记录"
```

**步骤 3：创建 ShareViewModel.kt**
```kotlin
// 实现 ShareViewModel
// ⚠️ 偏差：添加了 clearError() 方法
// 原因：UI 需要手动清除错误状态
```

**步骤 4：更新 AndroidManifest.xml**
```kotlin
// ✓ 与原型一致
```

**步骤 5：创建 file_paths.xml**
```kotlin
// ✓ 使用 Codex 补充的版本
```

**步骤 6：运行测试**
```bash
./gradlew :app:testDebugUnitTest --tests "ShareViewModelTest"
# ✓ 测试通过
```

**实现总结**：
```markdown
## 阶段 C 完成

**实现的文件**：
- ShareError.kt (新建)
- ShareRepository.kt (新建)
- ShareViewModel.kt (新建)
- ShareState.kt (在 ShareViewModel.kt 中)
- file_paths.xml (新建)
- AndroidManifest.xml (修改)
- ShareViewModelTest.kt (新建，测试用例)

**与原型的偏差**：
1. ShareRepository 添加了 Logger 日志记录
   - 原因：满足需求中的日志要求
   - 影响：增加了依赖注入的复杂度

2. ShareViewModel 添加了 clearError() 方法
   - 原因：UI 需要清除错误状态
   - 影响：API 更完整

**测试结果**：
- ShareViewModelTest: 8/8 通过
- 覆盖场景：成功分享、失败处理、状态转换

**决议**: 进入阶段 D

[TodoWrite 更新: 阶段 C ✓，阶段 D 进行中]
```

---

#### 第 5 步：阶段 D - 审查复盘

**调用 Codex 进行审查**：
```
PROMPT:
## 审查请求
请审查以下代码改动和需求完成情况。

## SESSION 信息
- SESSION_ID: 019aabca-a9f3-7783-8343-3deca9526275
- 任务：为 Android 应用添加分享功能

## 阶段 A 需求
1. 支持文本和图片分享
2. 使用系统 Share Sheet
3. 临时缓存 + 分享后清理
4. 兼容 Android 7.0+ 和 10+
5. 错误处理和匿名化日志

## 审查材料
- 最终代码 diff: [提供 git diff]
- 测试结果: ShareViewModelTest 8/8 通过
- 与原型的偏差:
  1. 添加了 Logger 日志记录
  2. 添加了 clearError() 方法

## 审查维度
1. 功能正确性：是否正确实现了所有需求？
2. 需求覆盖：是否有遗漏？
3. 代码质量：是否符合最佳实践？
4. 潜在风险：安全、性能、可维护性问题？
5. 测试充分性：需要补充哪些测试？

## 安全约束
- sandbox="read-only"
- 只需提供审查意见

请提供详细的审查报告。

cd: /Users/yikwing/AndroidStudioProjects/ykmagic
SESSION_ID: 019aabca-a9f3-7783-8343-3deca9526275
sandbox: "read-only"
```

**Codex 审查报告**（示例）：
```markdown
## 代码审查报告

SESSION_ID: 019aabca-a9f3-7783-8343-3deca9526275

### 1. 功能正确性 ✓

所有核心需求已实现：
- ✓ 文本分享
- ✓ 图片分享（单张/多张）
- ✓ FileProvider 配置
- ✓ 错误处理
- ✓ 日志记录

### 2. 需求覆盖 ⚠️

发现潜在遗漏：
- ⚠️ 临时文件清理：代码中未看到清理逻辑的实现
- ⚠️ Android 10+ Scoped Storage：未明确处理
- ✓ 错误分类：已实现 ShareError sealed class

### 3. 代码质量 ✓

- ✓ 遵循 MVVM 架构
- ✓ 使用 Hilt 依赖注入
- ✓ StateFlow 管理状态
- ✓ 代码可读性高
- ⚠️ 缺少部分函数的文档注释

### 4. 潜在风险

**并发风险**：
- ShareViewModel 中的 _shareState 可能存在并发更新问题
- 建议：使用 Mutex 或确保单线程更新

**内存泄漏风险**：
- 临时文件未清理可能导致缓存累积
- 建议：在 ViewModel.onCleared() 中清理

**性能问题**：
- 大图片分享可能阻塞主线程
- 建议：在后台线程处理图片压缩

### 5. 测试充分性 ⚠️

当前测试：
- ✓ ShareViewModel 状态测试

需要补充：
- ⚠️ ShareRepository 的 Android Instrumented 测试
- ⚠️ 大文件分享的边界测试
- ⚠️ 权限拒绝场景的测试
- ⚠️ FileProvider 配置的验证测试

### 6. 改进建议

优先级 High：
1. 实现临时文件清理逻辑
2. 添加并发保护（Mutex）
3. 补充集成测试

优先级 Medium：
4. 添加文档注释
5. 处理大图片的后台压缩

优先级 Low：
6. 考虑添加分享历史记录功能
```

**批判性验证**：
```markdown
收到 Codex 的审查报告。现在进行批判性验证：

Q1: "你提到的并发风险，在当前的 viewModelScope.launch 中真的会发生吗？
     StateFlow 本身不是线程安全的吗？"

Q2: "关于临时文件清理，我实际上已经在 ShareRepository 的 shareImage()
     方法中添加了 finally { tempFile.delete() }，你是否遗漏了这部分代码？"

Q3: "你建议的大图片后台压缩，是否与 ShareRepository 的职责不符？
     图片压缩是否应该在上层（UI 或独立的 ImageProcessor）处理？"

Q4: "你建议添加 Android Instrumented 测试，但这个功能主要是调用系统 Intent，
     是否真的需要设备测试？Mock 是否就足够了？"
```

**Codex 回应**（继续对话）：
```
针对你的质疑：

A1: 你说得对，StateFlow 的 value 更新是线程安全的，在这个场景下
    并发风险可能不存在。我过度担心了。

A2: 抱歉，我确实遗漏了 finally 块中的清理逻辑。
    既然已经实现了清理，这个风险可以忽略。

A3: 你的质疑很有道理。图片压缩确实不应该是 ShareRepository 的职责。
    建议在 UI 层或使用独立的 ImageCompressor 处理。

A4: 对于这个场景，Mock 测试确实足够。Instrumented 测试的优先级可以降低。
    真正需要的是 Mock ShareRepository 并验证正确的 Intent 参数。
```

**Claude 最终决议**：
```markdown
## 阶段 D 完成

**SESSION_ID**: 019aabca-a9f3-7783-8343-3deca9526275

**审查结论**: ✅ 通过

**Codex 发现的有效问题**：
- 文档注释不足（已补充）
- 需要 Mock 测试（已添加）

**被质疑后修正的问题**：
- ❌ 并发风险：实际不存在
- ❌ 文件清理遗漏：已实现
- ❌ 职责不符的建议：已澄清

**残留风险**：
- 大图片性能问题（可以后续优化）
- 分享历史记录（不在当前需求范围）

**批判性质询记录**：
- 并发安全性 → StateFlow 本身线程安全
- 文件清理 → 已在 finally 块实现
- 职责划分 → 压缩应在 UI 层或专用组件
- 测试策略 → Mock 测试足够

**经验教训**：
1. Codex 的审查很全面，但也可能过度担心
2. 批判性质询帮助澄清了误解
3. 职责划分的讨论很有价值

**决议**: 功能完成，可以合并

[TodoWrite 更新: 阶段 D ✓，全部完成]
```

**最终输出给用户**：
```markdown
✅ 分享功能已实现完成！

## 实现的功能
- 文本分享
- 图片分享（单张/多张）
- 系统 Share Sheet 集成
- 临时文件自动清理
- 完善的错误处理

## 技术实现
- ShareViewModel + ShareRepository (MVVM)
- Hilt 依赖注入
- FileProvider 配置（兼容 Android 7.0+）
- StateFlow 状态管理
- 完整的单元测试和 Mock 测试

## 文件改动
- 新建 6 个文件
- 修改 AndroidManifest.xml
- 所有测试通过 (10/10)

代码已准备好提交。需要我创建 commit 吗？
```

---

## 示例 2：Bug 修复（简化流程）

### 用户请求

> "修复一个 bug：在网络请求失败时，Loading 状态没有正确清除"

### Claude 的响应（简化流程）

```markdown
这是一个明确的 bug 修复任务，不需要完整的四阶段流程。
我将直接修复并使用阶段 D（审查）来验证。

[定位问题...]
[修复代码...]

现在让我使用 Codex 来审查这个修复...
```

**调用 Codex 审查**（直接进入阶段 D）：
```
PROMPT:
## Bug 修复审查
请审查以下 bug 修复。

问题：网络请求失败时 Loading 状态未清除
修复：在 catch 块中添加 _state.value = State.Idle

代码 diff: [...]

请验证：
1. 修复是否正确？
2. 是否有遗漏的场景？
3. 是否需要测试？

cd: /Users/yikwing/AndroidStudioProjects/ykmagic
sandbox: "read-only"
```

**简化的批判性质询**：
```
Q: "这个修复是否会导致错误信息丢失？
    用户还能看到失败原因吗？"
```

---

## 示例 3：处理阶段间的返回

### 场景：阶段 C 发现原型不足

```markdown
## 阶段 C 实现中的问题

在实现 ShareRepository 时，我发现原型中没有考虑分享到微信的特殊处理。
微信需要特定的 Intent 参数。

**决策**: 返回阶段 B，请求更新原型

[调用 Codex，使用同一个 SESSION_ID]

PROMPT:
基于阶段 B 的原型，发现需要补充微信分享的特殊处理。
请更新原型，添加微信分享的 Intent 配置。

SESSION_ID: 019aabca-a9f3-7783-8343-3deca9526275
...

[记录返回原因]
[继续阶段 C]
```

---

## 总结

以上示例展示了：

1. **完整四阶段流程**（示例 1）
   - 何时使用：复杂功能开发
   - 关键要素：SESSION_ID 管理、批判性质询、只读约束

2. **简化流程**（示例 2）
   - 何时使用：Bug 修复、简单修改
   - 保留核心：代码审查和质疑机制

3. **阶段返回**（示例 3）
   - 何时返回：发现原型不足、需求变更
   - 如何返回：使用同一个 SESSION_ID 继续对话

**使用此 Skill 的关键**：
- ✅ 保持批判性思考
- ✅ 记录所有决策和质询
- ✅ 严格遵守只读安全约束
- ✅ 根据任务复杂度灵活调整流程