---
date: 2026-07-16
tags: [项目优化, 目录结构, PARA, Zettelkasten, 重构]
summary: "重构 learning-log 目录结构：从扁平 docs/ 拆分为 journal/notes/troubleshooting/roadmap/references/"
---

# 重构 learning-log 目录结构 — 实施计划

> 📅 制定于 2026-07-16 | 🏷️ 项目优化 · 目录结构 · 重构

## 背景

当前 `docs/` 扁平存放所有日志（任务记录、问题排查、知识点笔记混在一起），文件多了之后查找困难。需要按**内容类型**拆分目录，让每种类型的文件有清晰的归属。

## 方案：PARA + Zettelkasten 混合（轻量版）

核心理念：**日志用 PARA（按时间/任务），笔记用 Zettelkasten（按主题/概念）**。

### 目标结构

```
learning-log/
  journal/            # 每日任务日志（原 docs 主要内容）
  notes/              # 知识点笔记（原子化，可相互链接）
  troubleshooting/    # 问题排查记录（独立成文，被 journal 引用）
  roadmap/            # 学习路线规划
  references/         # 外部资源索引（教程链接、论文、工具列表）
  templates/          # 日志模板（现有，保留）
  scripts/            # 自动化脚本（现有，保留）
  assets/             # 截图和附件（现有，保留）
```

### 各目录定位

| 目录 | 定位 | 文件命名 | 类比 |
|------|------|----------|------|
| `journal/` | 时间驱动的任务记录 | `YYYY-MM-DD-标题-slug.md` | PARA Projects |
| `notes/` | 主题驱动的概念笔记 | `概念名-slug.md`（无日期）| ZK Permanent Notes |
| `troubleshooting/` | 独立的问题排查 | `YYYY-MM-DD-问题-slug.md` | ZK Literature Notes |
| `roadmap/` | 学习路线和规划 | 不限 | PARA Areas |
| `references/` | 外部资源和索引 | 不限 | PARA Resources |

### 为什么这么分

1. **journal vs notes 分离** — 任务日志是"我在哪天做了什么"，笔记是"我理解了什么概念"。前者按时间索引，后者按主题索引。
2. **troubleshooting 独立** — 端口修正这类问题排查不是常规任务日志也不是概念笔记，独立成目录方便搜索和引用。
3. **不引入成熟度标注** — Digital Garden 的 seed/bud/evergreen 现阶段维护成本太高，用 `tags:` frontmatter 灵活标注即可。
4. **date-prefix 仅用于 journal/troubleshooting** — 笔记是长效知识，文件名反映内容而非创建日期。

---

## 待移动文件

| 原路径 | 新路径 | 原因 |
|--------|--------|------|
| `docs/2025-07-15-开发环境搭建-dev-env-setup.md` | `journal/2025-07-15-开发环境搭建-dev-env-setup.md` | 任务日志 |
| `docs/2026-07-15-协作体系搭建-vibe-coding-setup.md` | `journal/2026-07-15-协作体系搭建-vibe-coding-setup.md` | 任务日志 |
| `docs/2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md` | `journal/2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md` | 任务日志 |
| `docs/2026-07-15-重构日志组织方式-restructure-docs.md` | `journal/2026-07-15-重构日志组织方式-restructure-docs.md` | 任务日志 |
| `docs/2026-07-16-代理端口修正-clash-port-fix.md` | `troubleshooting/2026-07-16-代理端口修正-clash-port-fix.md` | 问题排查 |
| `docs/常用指令速查.md` | `references/常用指令速查.md` | 参考手册 |
| `docs/尚硅谷AI Coding教程.md` | `notes/尚硅谷AI-Coding教程.md` | 课程笔记 |

> 本计划文件 `docs/2026-07-16-目录结构重构计划-restructure-plan.md` 执行完后移到 `journal/`。

---

## 实施步骤

### 1. 创建新目录

```bash
mkdir -p journal notes troubleshooting roadmap references
```

### 2. 移动文件

使用 `git mv`（保留 Git 历史）逐个搬运上面的 7 个文件。

### 3. 更新交叉引用

所有被移动文件内部的相对链接需要更新，例如：
- `[代理端口修正日志](2026-07-16-代理端口修正-clash-port-fix.md)` → `[代理端口修正日志](../troubleshooting/2026-07-16-代理端口修正-clash-port-fix.md)`

### 4. 更新 CLAUDE.md

修改目录结构说明、文件命名规范、各目录用途。

需要改的部分：
- "## 目录结构" 整段
- "### 文件命名" 增加 journal/notes 的命名差异
- "### 日志结构" → 改为"journal 日志结构"
- "## 自动化脚本" 更新 `new-log.sh` 用法

### 5. 更新 README.md

目录表格拆分为按新目录结构的分组索引。

### 6. 更新 scripts/new-log.sh

支持 `--type` 参数：
- `--type journal`（默认）→ 输出到 `journal/`
- `--type troubleshooting` → 输出到 `troubleshooting/`
- `--type notes` → 输出到 `notes/`

### 7. 更新 templates/daily-log.md

更新模板中的路径引用说明。

### 8. Git 提交

```bash
git add -A
git commit -m "refactor: 重构目录结构 — docs/ 拆分为 journal/notes/troubleshooting/roadmap/references/"
```

---

## 不做

- ❌ 不引入 Zettelkasten 的 seed/bud/evergreen 成熟度标注（现阶段维护成本高）
- ❌ 不给每个日志文件加"版本号"——日志本身已是版本记录
- ❌ 不引入 Obsidian 双向链接语法（`[[]]`）——保持纯 Markdown 兼容性

---

## 验证清单

- [ ] 所有交叉引用链接可点击且指向正确文件
- [ ] `scripts/new-log.sh -h` 显示新参数正常
- [ ] `git log --follow` 对移动后的文件仍能显示完整历史
- [ ] `docs/` 目录清空后可删除
