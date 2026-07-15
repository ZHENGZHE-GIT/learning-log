# Learning Log -- 项目说明

Agent 应用开发实习准备的学习日志，记录工具链搭建、踩坑、代码实践。

## 目录结构

```
learning-log/
  docs/          # 每日日志（Markdown），按日期命名
  templates/     # 日志模板
  scripts/       # 自动化脚本
  assets/        # 截图和附件（按日志日期建子目录）
```

## 日志规范

### 文件命名

`YYYY-MM-DD-中文标题-english-slug.md`

示例：`2025-07-15-开发环境搭建-dev-env-setup.md`

### YAML Frontmatter

每篇日志以 YAML frontmatter 开头：

```yaml
---
date: 2025-07-15
day: 1
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

- Commit 格式：`docs: Day N - 标题`（日志），`chore:`（工具/配置变更）
- 不自动 push，需用户确认

## 外部依赖与相关项目

| 项目/文件 | 说明 |
|-----------|------|
| `E:\code\hello-agents` | AI Agent 教学框架（ReAct、Plan-and-Solve、Reflection）|
| `C:\Users\不会再相遇\.continue\config.json` | Continue.dev 配置 |
| `C:\Users\不会再相遇\.codex\.env` | 含 `no_proxy=127.0.0.1,localhost` |
| OpenRouter | API 中转，中国区只能用 Mistral/Llama/Kimi |
| DeepSeek API | Claude Code 后端（兼容 Anthropic 格式）|

## 写作规范

- 中文为主，技术术语保留英文（工具名、API、文件路径、命令）
- 代码块标注语言类型（```bash、```python、```json）
- 表格用于对比和故障排查（踩坑记录用"问题/原因/解决"三列）
- ASCII 框图用于工具链总览

## 日常工作流

1. 当天学习/实验
2. 手动编写日志或让 AI 辅助，参照 `templates/daily-log.md` 结构
3. 日志放入 `docs/` 目录，文件名：`YYYY-MM-DD-中文标题-english-slug.md`
4. 更新 README.md 目录表格（或等 AI 帮你更新）
5. `git add docs/ && git commit -m "docs: Day N - 标题"`
