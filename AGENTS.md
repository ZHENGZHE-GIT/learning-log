# Learning Log -- 项目说明

Agent 应用开发实习准备的学习日志，记录工具链搭建、踩坑、代码实践。

## 目录结构

```
learning-log/
  _inbox.md              # 快速捕获入口，每周清空，归档到 journal/ 或 notes/
  journal/               # 每日任务日志（时间驱动，日期前缀命名）
  notes/                 # 知识点笔记（主题驱动，按 Agent 学习阶段分子目录）
    01-foundations/      #   LLM 原理、Transformer、RLHF
    02-agent-loop/       #   ReAct、工具调用、最小 Agent
    03-tools-rag/        #   工具设计、检索增强、向量数据库
    04-harness/          #   真实 Agent 系统源码分析
    05-multi-agent/      #   多 Agent 协作模式
    06-protocols/        #   MCP、A2A、Skills
    07-evals-safety/     #   评估体系、安全边界
    08-projects/         #   项目实战文档
  troubleshooting/       # 问题排查记录（独立成文，被 journal 引用）
  references/            # 外部资源索引（教程链接、论文、工具列表）
  templates/             # 日志模板
  scripts/               # 自动化脚本
  assets/                # 截图和附件（按日志日期建子目录）
```

### 各目录定位

| 目录 | 定位 | 文件命名 | 对应心智模式 |
|------|------|----------|-------------|
| `_inbox.md` | 快速捕获，零分类摩擦 | 单文件追加 | 捕获 |
| `journal/` | 时间驱动的任务记录 | `YYYY-MM-DD-标题-slug.md` | 执行 |
| `notes/` | 主题驱动的概念笔记 | `概念名-slug.md`（无日期） | 沉淀 |
| `troubleshooting/` | 独立的问题排查 | `YYYY-MM-DD-问题-slug.md` | 排查 |
| `references/` | 外部资源和索引 | 不限 | 检索 |

> 核心设计：inbox → journal → notes 对应学习过程中的三种心智模式，捕获瞬间不需当场决定"这是日志还是笔记"。

## 日志规范

### 文件命名

**journal（任务日志）**：`YYYY-MM-DD-中文标题-english-slug.md`

同一天多个任务各自独立成文，示例：
- `2025-07-15-开发环境搭建-dev-env-setup.md`
- `2026-07-15-协作体系搭建-vibe-coding-setup.md`
- `2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md`

**notes（知识笔记）**：`概念名-slug.md`（无日期前缀）

笔记按 Agent 学习阶段放入对应子目录，通用基础类放根层级：
- `notes/Git基础认知-从零到够用.md`（根层级，通用知识）
- `notes/02-agent-loop/ReAct模式实现-react-pattern.md`（阶段子目录）

**troubleshooting（问题排查）**：`YYYY-MM-DD-问题描述-slug.md`

### YAML Frontmatter

每篇日志以 YAML frontmatter 开头：

```yaml
---
date: 2025-07-15
tags: [环境搭建, 工具链, 代理]
summary: "一句话摘要"
---
```

### journal 日志结构

- 背景 —— 学习目标
- 完成事项 —— 每个事项含 **做了什么** 和 **学到了什么**
- 当前工具链总览 —— ASCII 框图
- 踩坑记录 —— 问题/原因/解决 表格
- 关键文件 —— 相关文件路径
- 下一步计划 —— checkbox 列表

## Inbox 工作流

`_inbox.md` 是快速捕获入口，学习过程中产生的想法、链接、待深究概念直接追加到"待处理"列表，不需当场分类。

每周清空一次：
- 可执行的想法 → 创建 `journal/` 任务日志
- 概念性理解 → 写入 `notes/` 对应子目录
- 外部链接/工具 → 补充到 `references/`

> 如果 inbox 积累超过 20 条未处理，说明清空频率需要提高。

## 自动化脚本

```bash
# 创建今日日志（默认 journal/）
bash scripts/new-log.sh "标题" "english-slug"

# 完整参数
bash scripts/new-log.sh -t "标签1, 标签2" -s "摘要" "标题" "slug"

# 指定类型
bash scripts/new-log.sh --type troubleshooting -t "标签" -s "摘要" "问题标题" "issue-slug"
bash scripts/new-log.sh --type notes --subdir 02-agent-loop -t "标签" -s "摘要" "笔记标题" "note-slug"

# 编辑今日已有日志
bash scripts/new-log.sh -a

# 预览（不执行 git 操作）
bash scripts/new-log.sh -n "标题" "slug"

# 帮助
bash scripts/new-log.sh -h
```

### 参数说明

| 参数 | 说明 |
|------|------|
| `-t, --tags` | 标签（逗号分隔） |
| `-s, --summary` | 一句话摘要 |
| `-a, --append` | 编辑今日已有日志 |
| `-n, --dry-run` | 预览模式，不执行 git 操作 |
| `--type` | 日志类型：`journal`（默认）、`troubleshooting`、`notes` |
| `--subdir` | notes 子目录（仅 `--type notes` 时有效，如 `02-agent-loop`） |
| `-h, --help` | 帮助信息 |

> 注意：脚本只做本地提交，不自动 push。推送需手动执行 `git push`。

## 周期性回顾命令

| 命令 | 用途 | 频率 |
|------|------|------|
| `/review-weekly` | 清空 inbox + 蒸馏本周 journal → notes | 每周 |
| `/review-monthly` | 跨日志模式识别 + 月度学习总结 | 每月 |
| `/task-done` | 任务完成收尾（日志 + README + _status.md + 提交）| 每次任务后 |

## Git 规范

- Commit 格式：`docs: 任务标题`（日志），`chore:`（工具/配置变更），`refactor:`（目录重构）
- 每个任务独立 commit，`git log` 即任务历史
- 不自动 push，需用户确认

## 外部依赖与相关项目

| 项目/文件 | 说明 |
|-----------|------|
| `E:\code\hello-agents` | AI Agent 教学框架（ReAct、Plan-and-Solve、Reflection）|
| `C:\Users\不会再相遇\.continue\config.json` | Continue.dev 配置 |
| `C:\Users\不会再相遇\.codex\.env` | 含 `no_proxy=127.0.0.1,localhost` |
| `references/常用指令速查.md` | Codex / Git / Shell 命令速查手册 |
| OpenRouter | API 中转，中国区只能用 Mistral/Llama/Kimi |
| DeepSeek API | Codex 后端（兼容 Anthropic 格式）|

## Codex 三层配置体系

本项目采用三层配置叠加，下层不能覆盖上层的 deny 规则：

```
全局层 (~/.Codex/settings.json) ── API key、代理、安全 deny 规则
  │
  ├── learning-log ── permissions + hooks（文档编辑用 acceptEdits）
  │
  └── 代码项目 ── 从 project-template/ 复制，按需调整（代码项目用 default）
```

| 层 | 文件 | 职责 |
|----|------|------|
| 全局 | `~/.Codex/settings.json` | API key、模型映射、代理、全局 deny 规则 |
| 全局 | `~/.Codex/AGENTS.md` | 沟通规则、红线操作、工具偏好 |
| 项目 | `.Codex/settings.json` | 项目级 permissions.allow + defaultMode + hooks |
| 项目 | `AGENTS.md` | 项目架构、运行方式、代码规范 |

### 配置叠加规则

1. 全局 deny 始终生效（`.env*`、secrets、`rm -rf`、`git push/merge/rebase` 等），项目层不能覆盖
2. 项目层 permissions.allow 只能在全局 deny 的约束下增加允许项
3. 项目层 settings.json 建议加入 `.gitignore`（权限偏好是个人设置），AGENTS.md 应纳入版本控制

### 新建项目参考

模板文件：`.Codex/project-template/`（`settings.json` + `AGENTS.md`）

1. 在项目根目录创建 `.Codex/` 目录
2. 复制模板文件并替换占位符（`<project-path>`、`<runtime>`、`<project-name>`）
3. 根据项目语言添加对应的 Bash 权限（如 `Bash(python *)`、`Bash(npm *)`）

## 写作规范

- 中文为主，技术术语保留英文（工具名、API、文件路径、命令）
- 代码块标注语言类型（```bash、```python、```json）
- 表格用于对比和故障排查（踩坑记录用"问题/原因/解决"三列）
- ASCII 框图用于工具链总览

## 学习工作流（CODE 框架）

本项目遵循 CODE 框架的四步循环，由 AI 和用户协作完成：

```
Capture → Organize → Distill → Express
 (inbox)  (分类归档)  (提炼笔记)  (产出+回顾)
```

### Capture（捕获）

学习过程中产生的想法、链接、待深究概念 → 直接追加到 `_inbox.md` 的"待处理"列表。零摩擦，不需当场分类。

### Organize（组织）

Inbox 条目在每周回顾中分类归档：
- 可执行的任务 → `journal/`
- 概念性理解 → `notes/` 对应子目录
- 外部链接/工具 → `references/`

### Distill（蒸馏）

两个层次的周期性回顾（由 AI 执行）：

- **每周回顾（`/review-weekly`）**：清空 inbox，从本周 journal 提取关键收获 → `notes/`
- **每月合成（`/review-monthly`）**：跨日志识别模式，生成月度总结 → `journal/`

### Express（表达）

每次任务完成后的产出流程，详见下方"任务完成收尾"。

### 状态追踪

`_status.md` 记录进行中的任务和下一步计划，由 task-done 和 review 命令自动维护。

## 任务完成收尾（核心）

每个任务结束时，AI **必须**按顺序执行以下步骤，确保每次任务都有迹可循：

### 步骤

1. **确认任务日志** —— 检查 `journal/` 下是否有本次任务的日志文件
   - 如果没有，使用脚本创建：`bash scripts/new-log.sh -t "标签" -s "摘要" "标题" "slug"`
   - 如果已有，确认 frontmatter 和章节结构完整
   - 日志必须包含：背景、完成事项（做了什么/学到了什么）、踩坑记录、关键文件、下一步计划

2. **更新 README.md** —— 在目录表格和标签索引中添加新条目
   - 如果步骤 1 调用了 `new-log.sh`，README 已自动更新
   - 否则手动更新索引表（最新在前）和标签索引

3. **更新 _status.md** —— 勾掉已完成条目，从"下一步计划"提取新条目

4. **提交到本地仓库** —— `git add -A && git commit -m "docs: 任务标题"`
   - Commit message 使用任务标题作为摘要
   - 不 push（等用户明确要求）

5. **展示任务摘要** —— 列出本次任务的文件变更和关键成果

### 回退机制

如果某个任务的改动有问题：
```bash
git log --oneline          # 查看任务历史，每个任务一个 commit
git revert <commit>        # 安全回退某个任务（保留历史记录）
# 或
git reset --hard <commit>  # 彻底回到某个任务之前的状态（丢弃后续所有改动）
```

> 核心原则：任务前 git stash 保存草稿，任务后 git commit 存档 —— 确保每一步都可回溯。
