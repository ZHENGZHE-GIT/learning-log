---
date: 2026-07-20
tags: [工作流, hooks, SessionStart, 仪表盘, 进度追踪]
summary: "增强 SessionStart hook：从简单两行信息升级为学习进度仪表盘，展示阶段进度、下一步任务、inbox、最近日志"
---

# SessionStart 仪表盘

> 📅 2026-07-20 | 🏷️ 工作流 · hooks · SessionStart · 仪表盘

## 背景

当前 SessionStart hook 只显示 inbox 计数和上次日志文件名，信息密度太低。每次会话启动时希望能"一屏看清"学习进度——现在学到哪了、接下来做什么、之前做了什么。

## 完成事项

### 1. 设计仪表盘方案

**做了什么：**
- 对比了三种方案：增强 SessionStart hook（终端内自动展示）、静态 HTML 页面（浏览器）、`/status` CLI 命令（手动触发）
- 选择了 SessionStart hook 增强方案——零额外操作，每次打开 Claude Code 自动看到

**学到了什么：**
- 仪表盘的核心价值是"零摩擦"——如果每次要看进度都要手动触发，很快就不看了
- 终端方案比 HTML 更务实：90% 时间在 Claude Code 里，不需要切浏览器

### 2. 实现 session-start.sh 脚本

**做了什么：**
- 创建 `scripts/session-start.sh`，从现有 markdown 文件实时提取数据
- 四个模块：阶段进度（8 个学习阶段，检测 notes/ 子目录有无内容）、下一步（从 `_status.md` 提取前 5 条未完成任务）、Inbox 计数、最近 3 篇日志（提取 markdown 标题行）
- 修复了三个实现问题：bash 关联数组不保序（改用索引数组）、中文 UTF-8 截断乱码（去掉截断）、YAML frontmatter 导致标题取到 `---`（用 awk 跳过 frontmatter）

**学到了什么：**
- 仪表盘数据应该从现有文件**实时提取**而非额外维护一份持久化数据——否则会有数据不一致问题
- bash 在 Git Bash (Windows) 下处理 UTF-8 中文时 `${var:0:n}` 按字节截断会切碎多字节字符

### 3. 更新 SessionStart hook 配置

**做了什么：**
- 修改 `.claude/settings.json`，将 SessionStart hook 命令从内联长命令替换为 `bash scripts/session-start.sh`

**学到了什么：**
- 把 hook 逻辑抽到独立脚本比内联 JSON 字符串好维护得多——可读性、可调试性都大幅提升

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| 阶段显示顺序随机 | bash 关联数组 `declare -A` 不保证迭代顺序 | 改用两个索引数组（`PHASE_DIRS` + `PHASE_DESCS`）按位置对应 |
| 中文任务描述截断后乱码 | `${var:0:50}` 按字节截断，UTF-8 中文占 3 字节，在字符中间切断 | 直接去掉截断逻辑，让终端自行处理换行 |
| 日志标题提取显示 `---` | `head -1` 取到的是 YAML frontmatter 起始分隔符 `---` | 用 awk 跳过 frontmatter 块（`---`...`---`），取第一个 `# ` 标题行 |
| 分类器临时不可用导致 Write/Edit 被拒 | deepseek-v4-pro 分类器暂时下线 | 重试几次后 Edit 恢复 |

## 关键文件

| 文件 | 说明 |
|------|------|
| `scripts/session-start.sh` | 仪表盘脚本，从 markdown 实时提取数据 |
| `.claude/settings.json` | SessionStart hook 指向新脚本 |

## 下一步计划

- [ ] 后续学习中观察仪表盘是否够用——如果信息密度不够再加
- [ ] 考虑是否提取 `_status.md` 中的"当前阶段"标签做高亮
