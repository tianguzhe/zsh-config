# Git Force Push

执行强制推送，用于本地历史已被修改（rebase/amend/reset）的情况。

**默认使用安全方式**：`--force-with-lease`（检查远程是否有新提交，避免覆盖他人工作）

## 执行步骤

1. 检查当前分支状态：`git status`
2. 检查远程差异：`git log origin/<branch>..HEAD --oneline`
3. **在 main/master 分支必须警告用户并要求确认**
4. 执行推送：
   ```bash
   git push --force-with-lease origin <branch>
   ```

## 仅在以下场景使用

- 修改了提交历史（rebase/amend/reset）
- 个人开发分支
- 团队已知晓的共享分支修改

⚠️ **永远不要在公共主分支使用，除非完全了解后果**
