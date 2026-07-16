---
date: 2026-07-16
tags: [Git, 版本控制, 项目优化, 目录结构, 日志规范]
summary: "生成 Git 从零到够用认知文档、修复 SessionEnd hook、更新 README 项目定位、制定目录重构计划"
---

# Git 认知文档生成 + 项目优化

> 📅 2026-07-16 | 🏷️ Git · 版本控制 · 项目优化 · 目录结构

## 背景

对 Git 一窍不通（add/commit/push、分支、合并），需要一份从零开始的系统性认知文档。同时借此机会优化项目的 README 结构，让项目定位更清晰。

---

## 完成事项

### 1. 生成 Git 认知文档

**做了什么：**
- 写了 `docs/Git基础认知-从零到够用.md`，覆盖 9 个章节

| 章节 | 内容 |
|------|------|
| add/commit/push 本质 | 工作目录 → 暂存区 → 本地仓库 → 远程仓库（超市购物车类比） |
| 为什么需要分支 | 并行宇宙概念，master 直接改的困境 |
| 日常流程 | 单人项目最简版和标准版命令流程 |
| 合并冲突 | 产生原因、标记格式、解决步骤、三个决策原则 |
| stash | 写到一半切任务、stash pop/apply/drop |
| reset/revert | reset 四种模式对比、revert 适用场景、"时光机 vs 道歉信" |
| rebase | 交互式变基（pick/squash/fixup）、黄金法则 |
| 远程协作 | fetch vs pull、origin/master 本质、协作场景实战 |
| reflog | 终极后悔药，reset 错了也能找回 |

**学到了什么：**
- commit 不是"保存文件"而是"整个项目的快照"——这是理解 Git 一切行为的基础
- 分支只是一根 41 字节的指针，创建瞬间完成，所以"多建分支"没有性能代价
- `git pull --rebase` 是大多数团队的默认选择，避免无意义的 merge commit
- rebase 的黄金法则：绝不 rebase 已 push 的 commit
- 文档尾部附了按周拆分的学习路径和命令速查表

`★ Insight ─────────────────────────────────────`

**教别人是最好的学习方式。** 这份文档在解释"为什么"上花的篇幅远多于"怎么做"。比如解释"commit 是快照而非差异"这个事实，一下子就能理解为什么 Git 操作这么快、为什么切换分支这么轻量——这比背命令有用得多。

**Git 的边界感很清晰：本地 vs 远程。** commit 是私人的（本地存档），push 是公开的（发布给团队）。理解这个边界后，reset/rebase 什么时候能用、什么时候不能用的规则就自然推导出来了——能改的只有还没 push 的历史。

`─────────────────────────────────────────────────`

### 2. 修复 SessionEnd hook 拼写错误

**做了什么：**
- `.claude/settings.json` 中 `preSessionEnd` → `SessionEnd`
- 原因是 Claude Code 的 hook 事件名精确匹配，不存在 `pre` 前缀变体

**学到了什么：**
- 错误信息里列出的就是全部有效事件名，照着改就行
- 这种单行拼写修正不需要独立日志，直接在 commit message 里记录即可

### 3. 更新 README.md 项目定位

**做了什么：**
- 新增"项目定位"段落，说明这个仓库是"第二大脑"，不只是每日日志
- 新增 Git 认知文档和目录重构计划的目录条目
- 标签索引新增：版本控制、基础概念、进阶、目录结构、重构

**学到了什么：**
- CLAUDE.md 管"怎么写"，README.md 管"是什么"——两者分工不同
- README 有项目全景图，AI 能更快理解文件之间的关系

### 4. 制定目录重构计划

**做了什么：**
- 调研了 PARA、Zettelkasten、Digital Garden 三种知识管理方案
- 选择 PARA + ZK 混合方案：日志用 PARA（按时间/任务），笔记用 Zettelkasten（按主题/概念）
- 写入 `docs/2026-07-16-目录结构重构计划-restructure-plan.md`，含完整的文件移动清单和 7 步实施步骤

**学到了什么：**
- PARA 适合行动管理（"我今天要做什么"），Zettelkasten 适合知识沉淀（"我理解了什么"）
- 学习日志场景最核心的拆分是 journal vs notes——按时间索引和按主题索引混在一起互相干扰
- 不引入成熟度标注（seed/bud/evergreen）现阶段维护成本太高

### 5. 建立日志阈值习惯

**做了什么：**
- 写入 Memory：机械修正不建日志，有学习价值的才建
- 判断标准：涉及技术原理理解 → 独立日志；拼写/配置名写错 → commit message 记录即可

---

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| Claude Code 启动报 hook 警告 | 事件名写成了 `preSessionEnd` | 改为 `SessionEnd` |

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `docs/Git基础认知-从零到够用.md` | Git 从零到够用认知文档 |
| `docs/2026-07-16-目录结构重构计划-restructure-plan.md` | 目录重构实施计划（明天执行） |
| `README.md` | 新增项目定位 + 新文档索引 |
| `.claude/settings.json` | 修复 hook 事件名 |

---

## 下一步计划

- [ ] **明天**：按重构计划执行目录拆分（docs/ → journal/notes/troubleshooting/roadmap/references/）
- [ ] 练习 Git 操作：在 hello-agents 项目里创建分支、故意制造冲突、用 rebase 整理 commit
- [ ] 把尚硅谷教程的笔记从 journal 拆出原子化概念卡片，放入 notes/
