# Learning Log

> AI Agent 应用开发实习准备 —— 工具链搭建、踩坑记录、学习笔记、知识沉淀

## 项目定位

这个仓库不只是"每日日志"，它是我的**第二大脑**：

| 内容类型 | 存放位置 | 说明 |
|----------|----------|------|
| 任务日志 | `journal/` | 每天做了什么、学到了什么 |
| 知识笔记 | `notes/` | 教程蒸馏、概念理解、技术文档（按 Agent 学习阶段分子目录） |
| 问题排查 | `troubleshooting/` | 独立的问题诊断和修复记录 |
| 参考资料 | `references/` | 指令速查、教程原文、外部链接 |
| 快速捕获 | `_inbox.md` | 想法/链接/待深究概念，每周清空归档 |

> 📋 目录结构设计说明见 [目录结构重构计划](./journal/2026-07-16-目录结构重构计划-restructure-plan.md)

## 目录

<!-- INDEX_TABLE_START -->
| 日期 | 主题 | 标签 |
|------|------|------|
| [2026-07-16](./troubleshooting/2026-07-16-Clash代理与国内服务冲突排查-clash-proxy-domestic-services.md) | Clash 代理与国内服务冲突：npm ECONNRESET + Codex SSE 流断连,直连规则解决 | Clash · 代理 · Codex · npm · 故障排查 |
| [2026-07-16](./journal/2026-07-16-工作流改善-workflow-improvement.md) | 工作流改善：CODE 框架 + 周期性回顾 + 修复不一致 | 工作流 · CODE框架 · 周期性回顾 · CLAUDE.md · hooks · 项目优化 |
| [2026-07-16](./journal/2026-07-16-Claude-Code配置修复-hook-and-proxy-fix.md) | Claude Code 配置修复：Hook 结构 + API 代理隔离（NO_PROXY） | Claude Code · 代理 · 配置修复 · hooks · NO_PROXY |
| [2026-07-16](./notes/Git基础认知-从零到够用.md) | Git 认知文档：从零到够用（分支/冲突/stash/reset/rebase/远程协作） | Git · 版本控制 · 基础概念 · 进阶 |
| [2026-07-16](./journal/2026-07-16-目录结构重构计划-restructure-plan.md) | 目录结构重构计划：docs/ 拆分为多目录 | 项目优化 · 目录结构 · 重构 |
| [2026-07-16](./troubleshooting/2026-07-16-代理端口修正-clash-port-fix.md) | 代理端口修正：Clash Verge Rev 端口 7890 → 7897 + Claude Code 接入代理 | 代理 · 工具链 · Clash Verge Rev · Claude Code · 故障排查 |
| [2026-07-15](./journal/2026-07-15-重构日志组织方式-restructure-docs.md) | 重构日志组织方式 + 建立任务完成工作流 | 项目优化 · 日志规范 · Git · CLAUDE.md |
| [2026-07-15](./journal/2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md) | 尚硅谷 AI Coding 教程核心知识蒸馏 | AI Coding教程 · 知识蒸馏 · Vibe Coding · Claude Code |
| [2026-07-15](./journal/2026-07-15-协作体系搭建-vibe-coding-setup.md) | Vibe Coding 协作体系搭建（CLAUDE.md / Memory / 插件 / Git hooks） | Vibe Coding · Claude Code · 插件 · Memory · Git · CLAUDE.md |
| [2025-07-15](./journal/2025-07-15-开发环境搭建-dev-env-setup.md) | AI 开发环境从零搭建（含 OpenRouter 探索 + Continue.dev 方案） | 环境搭建 · 工具链 · 代理 · Codex · OpenRouter · Continue.dev |
<!-- INDEX_TABLE_END -->

## 标签索引

<!-- TAGS_START -->
- **AI Coding教程** — [知识蒸馏](./journal/2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md)
- **CLAUDE.md** — [环境搭建](./journal/2025-07-15-开发环境搭建-dev-env-setup.md)、[协作体系](./journal/2026-07-15-协作体系搭建-vibe-coding-setup.md)、[重构日志](./journal/2026-07-15-重构日志组织方式-restructure-docs.md)、[工作流改善](./journal/2026-07-16-工作流改善-workflow-improvement.md)
- **CODE框架** — [工作流改善](./journal/2026-07-16-工作流改善-workflow-improvement.md)
- **Clash Verge Rev** — [端口修正](./troubleshooting/2026-07-16-代理端口修正-clash-port-fix.md)、[代理冲突排查](./troubleshooting/2026-07-16-Clash代理与国内服务冲突排查-clash-proxy-domestic-services.md)
- **Claude Code** — [协作体系](./journal/2026-07-15-协作体系搭建-vibe-coding-setup.md)、[端口修正](./troubleshooting/2026-07-16-代理端口修正-clash-port-fix.md)、[配置修复](./journal/2026-07-16-Claude-Code配置修复-hook-and-proxy-fix.md)
- **Codex** — [环境搭建](./journal/2025-07-15-开发环境搭建-dev-env-setup.md)、[代理冲突排查](./troubleshooting/2026-07-16-Clash代理与国内服务冲突排查-clash-proxy-domestic-services.md)
- **Continue.dev** — [环境搭建](./journal/2025-07-15-开发环境搭建-dev-env-setup.md)
- **Git** — [协作体系](./journal/2026-07-15-协作体系搭建-vibe-coding-setup.md)、[重构日志](./journal/2026-07-15-重构日志组织方式-restructure-docs.md)、[Git 认知文档](./notes/Git基础认知-从零到够用.md)
- **Memory** — [协作体系](./journal/2026-07-15-协作体系搭建-vibe-coding-setup.md)
- **npm** — [代理冲突排查](./troubleshooting/2026-07-16-Clash代理与国内服务冲突排查-clash-proxy-domestic-services.md)
- **OpenRouter** — [环境搭建](./journal/2025-07-15-开发环境搭建-dev-env-setup.md)
- **Vibe Coding** — [协作体系](./journal/2026-07-15-协作体系搭建-vibe-coding-setup.md)、[知识蒸馏](./journal/2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md)
- **版本控制** — [Git 认知文档](./notes/Git基础认知-从零到够用.md)
- **代理** — [环境搭建](./journal/2025-07-15-开发环境搭建-dev-env-setup.md)、[端口修正](./troubleshooting/2026-07-16-代理端口修正-clash-port-fix.md)、[配置修复](./journal/2026-07-16-Claude-Code配置修复-hook-and-proxy-fix.md)、[代理冲突排查](./troubleshooting/2026-07-16-Clash代理与国内服务冲突排查-clash-proxy-domestic-services.md)
- **工作流** — [工作流改善](./journal/2026-07-16-工作流改善-workflow-improvement.md)
- **工具链** — [环境搭建](./journal/2025-07-15-开发环境搭建-dev-env-setup.md)、[端口修正](./troubleshooting/2026-07-16-代理端口修正-clash-port-fix.md)
- **故障排查** — [端口修正](./troubleshooting/2026-07-16-代理端口修正-clash-port-fix.md)、[配置修复](./journal/2026-07-16-Claude-Code配置修复-hook-and-proxy-fix.md)、[代理冲突排查](./troubleshooting/2026-07-16-Clash代理与国内服务冲突排查-clash-proxy-domestic-services.md)
- **环境搭建** — [环境搭建](./journal/2025-07-15-开发环境搭建-dev-env-setup.md)
- **基础概念** — [Git 认知文档](./notes/Git基础认知-从零到够用.md)
- **进阶** — [Git 认知文档](./notes/Git基础认知-从零到够用.md)
- **目录结构** — [重构计划](./journal/2026-07-16-目录结构重构计划-restructure-plan.md)
- **日志规范** — [重构日志](./journal/2026-07-15-重构日志组织方式-restructure-docs.md)
- **项目优化** — [重构日志](./journal/2026-07-15-重构日志组织方式-restructure-docs.md)、[重构计划](./journal/2026-07-16-目录结构重构计划-restructure-plan.md)、[工作流改善](./journal/2026-07-16-工作流改善-workflow-improvement.md)
- **知识蒸馏** — [知识蒸馏](./journal/2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md)
- **重构** — [重构日志](./journal/2026-07-15-重构日志组织方式-restructure-docs.md)、[重构计划](./journal/2026-07-16-目录结构重构计划-restructure-plan.md)
- **hooks** — [配置修复](./journal/2026-07-16-Claude-Code配置修复-hook-and-proxy-fix.md)、[工作流改善](./journal/2026-07-16-工作流改善-workflow-improvement.md)
- **周期性回顾** — [工作流改善](./journal/2026-07-16-工作流改善-workflow-improvement.md)
- **NO_PROXY** — [配置修复](./journal/2026-07-16-Claude-Code配置修复-hook-and-proxy-fix.md)
- **配置修复** — [配置修复](./journal/2026-07-16-Claude-Code配置修复-hook-and-proxy-fix.md)
<!-- TAGS_END -->

## 参考文档

固定参考资料，非任务日志：

| 文档 | 说明 |
|------|------|
| [常用指令速查](./references/常用指令速查.md) | Claude Code / Git / Shell 命令索引，忘记时回来翻 |
| [尚硅谷 AI Coding 教程](./notes/尚硅谷AI-Coding教程.md) | 尚硅谷 AI Coding 零基础实战教程原文 |
