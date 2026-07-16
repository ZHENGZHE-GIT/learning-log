---
date: 2026-07-16
tags: [CODE框架, 知识管理, PARA, Zettelkasten, 工作流, 日志规范]
summary: "CODE 框架四步循环、PARA + Zettelkasten 混合知识管理、journal vs notes 分离原则、任务完成工作流"
---

# CODE 框架与知识管理

## CODE 框架：四步学习循环

```
Capture → Organize → Distill → Express
 (inbox)  (分类归档)  (提炼笔记)  (产出+回顾)
```

### Capture（捕获）

学习过程中产生的想法、链接、待深究概念 → 直接追加到 `_inbox.md`。零摩擦，不需当场分类。

### Organize（组织）

Inbox 条目在每周回顾中分类归档：
- 可执行的任务 → `journal/`
- 概念性理解 → `notes/` 对应子目录
- 外部链接/工具 → `references/`

### Distill（蒸馏）

两个层次的周期性回顾：

| 层次 | 频率 | 输入 | 输出 | 核心动作 |
|------|------|------|------|---------|
| 每周回顾 | 每周 | inbox + 本周 journal | notes/ | 提取关键收获 → 概念笔记 |
| 每月合成 | 每月 | 本月 notes | 月度总结 | 跨日志模式识别 + 方向校准 |

> **核心价值在 Distill**——知识不提炼就是笔记坟场。LLM 天然适合做"周期性知识压缩"，这正是人类不擅长的事。

### Express（表达）

每次任务完成 → 日志 + README + _status.md + commit。确保每次任务都有迹可循。

---

## 知识管理：PARA + Zettelkasten 混合

### 核心理念

**日志用 PARA（按时间/任务），笔记用 Zettelkasten（按主题/概念）**。

| 方法 | 适合 | 本项目中对应 |
|------|------|-------------|
| PARA | 行动管理（"我今天要做什么"） | journal/（Projects）、notes/（Areas）、references/（Resources） |
| Zettelkasten | 知识沉淀（"我理解了什么"） | notes/ 子目录（原子化概念笔记） |

### Journal vs Notes 是最核心的拆分

| 维度 | journal/ | notes/ |
|------|----------|--------|
| 索引方式 | 时间（日期前缀） | 主题（概念名） |
| 文件命名 | `YYYY-MM-DD-标题-slug.md` | `概念名-slug.md`（无日期） |
| 心智模式 | "我今天做了什么" | "我理解了什么概念" |
| 生命周期 | 写完后基本不变 | 持续更新、跨日志链接 |

> 按时间索引和按主题索引的文件混在一起会互相干扰——这是拆分的最根本原因。

### 不做什么

- ❌ 不引入 seed/bud/evergreen 成熟度标注（现阶段维护成本太高）
- ❌ 不引入 Obsidian 双向链接语法（`[[]]`）——保持纯 Markdown 兼容性
- ❌ 不给日志加版本号——日志本身就是版本记录

---

## 日志规范要点

### 文件命名

- **journal**：`YYYY-MM-DD-中文标题-english-slug.md`，按任务独立成文（同一天多任务 = 多个文件）
- **notes**：`概念名-slug.md`（无日期前缀），按 Agent 学习阶段放入对应子目录
- **troubleshooting**：`YYYY-MM-DD-问题描述-slug.md`

### 日志阈值

不是每个操作都值得建日志：
- 涉及技术原理理解 → 独立日志
- 拼写/配置名写错 → commit message 记录即可
- 判断标准：**有没有学到新东西？**

### 任务完成收尾（4 步强制流程）

1. **确认任务日志** — 检查/创建 journal 文件，确保结构完整
2. **更新 README.md** — 目录表格和标签索引
3. **更新 _status.md** — 勾掉完成项，提取新下一步
4. **提交到本地仓库** — `git add -A && git commit -m "docs: 标题"`（不 push）

> 核心原则：任务前 git stash 保存草稿，任务后 git commit 存档——每一步都可回溯。

---

## Inbox 工作流

`_inbox.md` 是快速捕获入口。每周清空一次：可执行想法 → journal，概念理解 → notes，外部资源 → references。超过 20 条未处理 = 清空频率需要提高。

---
来源:
- journal/2026-07-15-重构日志组织方式-restructure-docs.md
- journal/2026-07-16-目录结构重构计划-restructure-plan.md
- journal/2026-07-16-工作流改善-workflow-improvement.md
