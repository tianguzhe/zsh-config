# Git Archive

将当前仓库打包为归档文件。

## 执行流程

1. 确认在 git 仓库内
2. 执行打包：
   ```bash
   git archive --format=tar.gz --prefix="<repo>/" -o "<repo>-archive-$(date +%Y%m%d%H%M%S).tar.gz" HEAD -- . ':(exclude).DS_Store' ':(exclude,glob)**/.DS_Store'
   ```
3. 确认文件生成：`ls -lh <output>`
