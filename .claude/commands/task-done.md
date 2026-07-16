# 任务完成收尾

请按以下步骤完成本任务的收尾工作：

## 步骤

1. **确认任务日志**
   - 检查 `journal/` 下是否有本次任务的日志文件（`YYYY-MM-DD-任务标题-english-slug.md`）
   - 如果没有，运行脚本创建：
     ```bash
     bash scripts/new-log.sh -t "标签1, 标签2" -s "一句话摘要" "任务标题" "english-slug"
     ```
   - 如果已有（比如任务过程中手动创建了），确认 frontmatter 包含 date、tags、summary，章节包含：背景、完成事项、踩坑记录、关键文件、下一步计划

2. **更新 README.md**
   - 如果步骤 1 调用了 `new-log.sh`，README 已自动更新
   - 如果日志文件已存在而未调用脚本，手动更新：目录表格新增一行，标签索引补充新标签

3. **更新 _status.md**
   - 将本次任务相关的进行中条目勾掉
   - 从 journal 日志的"下一步计划"提取新条目到 _status.md 的"下一步"

4. **提交到本地仓库**
   - `git add -A`
   - `git commit -m "docs: 任务标题"`
   - 不执行 git push（需用户手动推送）

5. **展示摘要**
   - 列出本次 commit 包含的文件
   - 统计新增/修改行数
   - 提示用户可以 `/commit` 推送
