# Learning Log -- 项目说明

Agent 应用开发实习准备的学习日志，记录工具链搭建、踩坑、代码实践。

## 目录结构

```
learning-log/
  docs/          # 任务日志（Markdown），按日期前缀排序，一个任务一个文件
  templates/     # 日志模板
  scripts/       # 自动化脚本
  assets/        # 截图和附件（按日志日期建子目录）
```

## 日志规范

### 文件命名

`YYYY-MM-DD-中文标题-english-slug.md`

同一天多个任务各自独立成文，示例：
- `2025-07-15-开发环境搭建-dev-env-setup.md`
- `2026-07-15-协作体系搭建-vibe-coding-setup.md`
- `2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md`

### YAML Frontmatter

每篇日志以 YAML frontmatter 开头：

```yaml
---
date: 2025-07-15
tags: [环境搭建, 工具链, 代理]
summary: "一句话摘要"
---
```

### 日志结构

- 背景 —— 学习目标
- 完成事项 —— 每个事项含 **做了什么** 和 **学到了什么**
- 当前工具链总览 —— ASCII 框图
- 踩坑记录 —— 问题/原因/解决 表格
- 关键文件 —— 相关文件路径
- 下一步计划 —— checkbox 列表

## 自动化脚本

```bash
# 创建今日日志
bash scripts/new-log.sh "标题" "english-slug"

# 完整参数
bash scripts/new-log.sh -t "标签1, 标签2" -s "摘要" "标题" "slug"

# 编辑今日已有日志
bash scripts/new-log.sh -a

# 预览（不执行 git 操作）
bash scripts/new-log.sh -n "标题" "slug"

# 帮助
bash scripts/new-log.sh -h
```

## Git 规范

- Commit 格式：`docs: 任务标题`（日志），`chore:`（工具/配置变更）
- 每个任务独立 commit，`git log` 即任务历史
- 不自动 push，需用户确认

## 外部依赖与相关项目

| 项目/文件 | 说明 |
|-----------|------|
| `E:\code\hello-agents` | AI Agent 教学框架（ReAct、Plan-and-Solve、Reflection）|
| `C:\Users\不会再相遇\.continue\config.json` | Continue.dev 配置 |
| `C:\Users\不会再相遇\.codex\.env` | 含 `no_proxy=127.0.0.1,localhost` |
| `docs/常用指令速查.md` | Claude Code / Git / Shell 命令速查手册 |
| OpenRouter | API 中转，中国区只能用 Mistral/Llama/Kimi |
| DeepSeek API | Claude Code 后端（兼容 Anthropic 格式）|

## 写作规范

- 中文为主，技术术语保留英文（工具名、API、文件路径、命令）
- 代码块标注语言类型（```bash、```python、```json）
- 表格用于对比和故障排查（踩坑记录用"问题/原因/解决"三列）
- ASCII 框图用于工具链总览

## 任务完成工作流（核心）

每个任务结束时，AI **必须**按顺序执行以下步骤，确保每次任务都有迹可循：

### 步骤

1. **生成任务日志** —— 按模板结构写入 `docs/YYYY-MM-DD-任务标题-english-slug.md`
   - 参照 `templates/daily-log.md` 结构
   - 包含：背景、完成事项（做了什么/学到了什么）、踩坑记录、关键文件、下一步计划

2. **更新 README.md** —— 在目录表格和标签索引中添加新条目
   - 新日志添加到表格第一行（最新在前）
   - 新标签添加到索引对应位置

3. **提交到本地仓库** —— `git add -A && git commit -m "docs: 任务标题"`
   - Commit message 使用任务标题作为摘要
   - 不 push（等用户明确要求）

4. **展示任务摘要** —— 列出本次任务的文件变更和关键成果

### 回退机制

如果某个任务的改动有问题：
```bash
git log --oneline          # 查看任务历史，每个任务一个 commit
git revert <commit>        # 安全回退某个任务（保留历史记录）
# 或
git reset --hard <commit>  # 彻底回到某个任务之前的状态（丢弃后续所有改动）
```

> 核心原则：任务前 git stash 保存草稿，任务后 git commit 存档 —— 确保每一步都可回溯。
